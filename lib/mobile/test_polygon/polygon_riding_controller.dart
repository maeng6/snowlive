import 'slope_geometry.dart';
import 'polygon_session_machine.dart';
import 'package:com.snowlive/core/api/api_ranking.dart';

/// 폴리곤 라이딩 통합 컨트롤러 (Phase 3).
/// check-wb 응답으로 폴리곤/노브를 초기화하고, GPS 점을 세션머신에 흘려
/// 라이딩이 커밋되면 commit-ride로 서버 전송한다. vm_resortHome(poly=true) 및
/// 테스트 앱에서 공통으로 사용.
///
/// 연결 예)
///   final ctl = PolygonRidingController(userId);
///   ctl.onLog = (m) => debugPrint(m);
///   ctl.configureFromCheckWb(checkWbResponseData);   // 리조트 진입 시 1회
///   ...위치 스트림에서... ctl.onPosition(pos.latitude, pos.longitude);
///   ...라이브오프/리조트 이탈 시... ctl.flush();
class PolygonRidingController {
  final int userId;
  final RankingAPI _api = RankingAPI();

  PolygonSessionMachine? _machine;

  /// 병행전환 플래그 (check-wb의 riding_config에서 수신)
  bool writePolygon = true;
  bool writeLegacy = true;

  void Function(String message)? onLog;

  /// 서버 커밋 완료 콜백 (CommitEvent, commit-ride 응답 data 또는 null)
  void Function(CommitEvent ev, Map<String, dynamic>? resp)? onCommitted;

  PolygonRidingController(this.userId);

  bool get ready => _machine != null;
  int get slopeCount => _machine?.slopes.length ?? 0;

  /// check-wb 응답(data)으로 폴리곤 슬로프 + 세션노브 초기화.
  /// data['slope_info_2627'] (GeoJSON) + data['riding_config'] 사용.
  void configureFromCheckWb(Map<String, dynamic> data) {
    final rawSlopes = (data['slope_info_2627'] as List?) ?? const [];
    final slopes = rawSlopes
        .map((j) => SlopePoly.fromJson(j as Map<String, dynamic>))
        .where((s) => s.hasPolygon)
        .toList();

    final cfg = (data['riding_config'] as Map<String, dynamic>?) ?? const {};
    writePolygon = (cfg['write_polygon'] ?? true) == true;
    writeLegacy = (cfg['write_legacy'] ?? true) == true;
    final exitTol = (cfg['exit_tolerance'] as num?)?.toInt() ?? 3;
    final band = (cfg['band_meters'] as num?)?.toDouble() ?? 25.0;

    final m = PolygonSessionMachine(slopes, exitConfirm: exitTol, bandM: band);
    m.onLog = (msg) {
      onLog?.call(msg);
    };
    m.onCommit = (ev) {
      _handleCommit(ev); // fire-and-forget (서버 전송)
    };
    _machine = m;
    onLog?.call('폴리곤 슬로프 ${slopes.length}개 로드 (exit=$exitTol, band=$band)');
  }

  /// 위치 스트림에서 매 좌표 호출 (writePolygon일 때만 판별)
  void onPosition(double lat, double lng, {DateTime? at}) {
    if (!writePolygon) return;
    _machine?.onPoint(GeoPt(lat, lng), at ?? DateTime.now());
  }

  /// 현재 라이딩 중인 슬로프 id (없으면 null) — live position is_riding/slope_id용
  int? get currentSlopeId {
    final ins = _machine?.inside;
    if (ins == null) return null;
    for (final e in ins.entries) {
      if (e.value == true) return e.key;
    }
    return null;
  }

  bool get isRiding => (_machine?.activeSummary ?? 'IDLE') != 'IDLE';

  /// 세션 종료(라이브오프/리조트 이탈) 시 남은 활성 세션 정산 → 커밋 트리거
  void flush() => _machine?.flush(DateTime.now());

  Future<void> _handleCommit(CommitEvent ev) async {
    if (!writePolygon) return;
    final session = <String, dynamic>{
      'slope_id': ev.slopeId,
      'distance': ev.distanceM,
      'entry_progress': ev.entryProgress,
      'exit_progress': ev.exitProgress,
      'avg_speed': ev.avgSpeedKmh,
      'coverage': ev.coverageRatio,
      'started_at': ev.startedAt.toUtc().toIso8601String(),
      'ended_at': ev.at.toUtc().toIso8601String(),
      'track': ev.track.map((p) => [p.lng, p.lat]).toList(),
    };
    try {
      final res = await _api.commitRide({
        'user_id': userId,
        'sessions': [session],
      });
      final data = res.success ? (res.data as Map<String, dynamic>?) : null;
      onCommitted?.call(ev, data);
      onLog?.call('☁ commit-ride ${ev.name} (${ev.distanceM.toStringAsFixed(0)}m) '
          '→ ${data?['inserted_count'] ?? '실패'}');
    } catch (e) {
      onLog?.call('commit-ride 예외: $e');
    }
  }
}
