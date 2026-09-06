import 'dart:math' as math;
import 'slope_geometry.dart';

/// 커밋(라이딩 인정) 이벤트 — commit-ride API 입력을 모두 담는다.
class CommitEvent {
  final int slopeId;
  final String name;
  final double coverageM;
  final double distanceM;     // 실제 GPS 활강거리(m)
  final int points;           // 궤적 점 수
  final DateTime at;          // 세션 종료 시각
  final double entryProgress; // 탄 구간 시작 진행률 0~1
  final double exitProgress;  // 탄 구간 끝 진행률 0~1 (=max_progress)
  final DateTime startedAt;   // 세션 시작(소급) 시각
  final double avgSpeedKmh;   // 평균 속도(km/h)
  final double coverageRatio; // 진행률(bin 비율) 0~1
  final List<GeoPt> track;    // 세션 궤적(유료 저장·서버 전송용)
  CommitEvent(
    this.slopeId,
    this.name,
    this.coverageM,
    this.distanceM,
    this.points,
    this.at, {
    this.entryProgress = 0,
    this.exitProgress = 1,
    DateTime? startedAt,
    this.avgSpeedKmh = 0,
    this.coverageRatio = 0,
    List<GeoPt>? track,
  })  : startedAt = startedAt ?? at,
        track = track ?? const [];
}

class _Cand {
  final SlopePoly s;
  final double entryProgress;
  double maxProgress;
  final DateTime startedAt;
  DateTime lastInsideAt;
  DateTime? endedAt;
  GeoPt lastInsidePt;
  final List<GeoPt> track = [];
  final Set<int> bins = {};   // 실제로 지나간 축 구간(bin) 집합
  final int nbins;            // 축을 5m 단위로 나눈 총 구간 수
  String reason = '';
  int outside = 0;
  bool active = true;
  double lastPr;              // 직전 진행률 (연속 역행 판정용)
  double retreatM = 0;        // 연속 역행 누적(m) — 전진 시 0으로 리셋

  _Cand(this.s, this.entryProgress, this.startedAt, this.lastInsideAt, this.lastInsidePt)
      : maxProgress = entryProgress,
        lastPr = entryProgress,
        nbins = math.max(1, (s.axisLen / 5).round()) {
    addBin(entryProgress);
  }

  void addBin(double pr) {
    int b = (pr * nbins).floor();
    if (b < 0) b = 0;
    if (b >= nbins) b = nbins - 1;
    bins.add(b);
  }

  /// 진행률(비율): 실제 지나간 bin 수 / 전체 bin 수 — 투영 스팬 착시 방지
  double get covRatio {
    final r = nbins == 0 ? 0.0 : bins.length / nbins;
    return r > 1 ? 1.0 : r;
  }

  double get coverageM => covRatio * s.axisLen;
}

/// 폴리곤 라이딩 판별 상태머신 (계획서 §3). 순수 로직 — GPS/서버 의존 없음.
/// dedup: 종료된 후보 그룹을 **최종 진행률(비율)** 로 비교해 가장 완주에 가까운
/// 슬로프만 남긴다(bounded hold). 절대 거리(m)가 아니라 비율이라 길이 편향이 없다.
class PolygonSessionMachine {
  final List<SlopePoly> slopes;
  final int entryConfirm;   // 진입 확정 연속 점수 (하강)
  final int exitConfirm;    // 이탈 확정 연속 점수 (밖)
  final double bandM;       // 연속 후퇴 밴드(m) → 초과 시 세션 분리(폴리곤 내부 리프트 왕복 대응)
  final double noiseFloorM; // 최소 커버리지 하한(m)
  final double minDescentM;     // 순 하강량 절대 하한(m)
  final double minDescentRatio; // 순 하강량 상대 하한(축길이 비율) — 리프트횡단/역행 배제

  PolygonSessionMachine(this.slopes,
      {this.entryConfirm = 2, this.exitConfirm = 2, this.bandM = 25, this.noiseFloorM = 5,
      this.minDescentM = 15, this.minDescentRatio = 0.05});

  final Map<int, _Cand> _active = {};
  final Map<int, int> _entryStreak = {};
  final Map<int, double> _lastPr = {};
  final List<_Cand> _cluster = []; // 시간상 겹치는 후보 그룹 (dedup용)

  final List<CommitEvent> commits = [];
  void Function(String)? onLog;
  void Function(CommitEvent)? onCommit;

  // 디버그 스냅샷
  final Map<int, bool> inside = {};
  final Map<int, double> progress = {};
  String get activeSummary => _active.isEmpty
      ? 'IDLE'
      : _active.values
          .map((c) => '${c.s.name}(pr ${(c.maxProgress).toStringAsFixed(2)}, cov ${(c.covRatio * 100).toStringAsFixed(0)}%)')
          .join(' + ');

  void onPoint(GeoPt p, DateTime t) {
    for (final s in slopes) {
      if (!s.hasPolygon) continue;
      final ins = s.inBbox(p) && s.contains(p);
      final double pr = ins ? s.progress(p) : -1.0;
      inside[s.slopeId] = ins;
      progress[s.slopeId] = pr;

      final c = _active[s.slopeId];
      if (c == null) {
        // 진입 판별: 폴리곤 안 + 하강(진행률 증가)
        if (ins && pr >= 0) {
          final last = _lastPr[s.slopeId];
          final descending = last != null && pr > last + 1e-9;
          _entryStreak[s.slopeId] = descending ? (_entryStreak[s.slopeId] ?? 0) + 1 : 0;
          _lastPr[s.slopeId] = pr;
          if ((_entryStreak[s.slopeId] ?? 0) >= entryConfirm - 1 && last != null) {
            final cand = _Cand(s, last, t, t, p);
            cand.maxProgress = pr;
            cand.addBin(pr);
            cand.track.add(p);
            _active[s.slopeId] = cand;
            _cluster.add(cand);
            _log('▶ 세션시작 ${s.name} (진입 pr=${last.toStringAsFixed(2)})');
          }
        } else {
          if (pr >= 0) _lastPr[s.slopeId] = pr;
          _entryStreak[s.slopeId] = 0;
        }
      } else {
        // 활성 세션
        if (ins && pr >= 0) {
          c.track.add(p);
          c.lastInsideAt = t;
          c.lastInsidePt = p;
          c.outside = 0;
          c.addBin(pr);
          if (pr > c.maxProgress) c.maxProgress = pr;
          // 연속 역행 누적: 뒤로 가면 쌓고, 앞으로(또는 정체) 가면 0으로 리셋.
          // 폴리곤 내부에서 리프트 타고 올라갔다 내려오면 밴드(bandM=25m) 초과 후퇴로 세션이
          // 분리돼 재하강이 새 커밋이 된다. (S자 카빙의 순간 역행은 곧 전진으로 리셋돼 안 쌓임)
          if (pr < c.lastPr - 1e-9) {
            c.retreatM += (c.lastPr - pr) * s.axisLen;
          } else {
            c.retreatM = 0;
          }
          c.lastPr = pr;
          if (c.retreatM >= bandM) {
            _end(c, t, '연속후퇴');
          }
        } else {
          c.outside++;
          if (c.outside >= exitConfirm) {
            _end(c, t, '폴리곤이탈');
          }
        }
      }
    }
    // 그룹이 모두 종료되면 확정 판정
    if (_active.isEmpty && _cluster.isNotEmpty && _cluster.every((c) => !c.active)) {
      _finalizeGroup();
    }
  }

  /// 스트림 종료 시 남은 활성 세션을 정산(테스트/세션 종료용)
  void flush(DateTime t) {
    for (final c in List<_Cand>.from(_active.values)) {
      _end(c, t, '세션종료');
    }
    if (_cluster.isNotEmpty) _finalizeGroup();
  }

  void _end(_Cand c, DateTime t, String reason) {
    c.active = false;
    c.endedAt = t;
    c.reason = reason;
    _active.remove(c.s.slopeId);
    _entryStreak[c.s.slopeId] = 0;
  }

  // o 세션이 c를 시간상 완전히 감쌈(먼저 시작·늦게 끝남, 동일구간 제외)
  bool _contains(_Cand o, _Cand c) =>
      !o.startedAt.isAfter(c.startedAt) &&
      !o.endedAt!.isBefore(c.endedAt!) &&
      !(o.startedAt.isAtSameMomentAs(c.startedAt) && o.endedAt!.isAtSameMomentAs(c.endedAt!));

  // 두 세션 겹침이 짧은 쪽 길이의 50% 이상(경계 스침 제외)
  bool _substantial(_Cand o, _Cand c) {
    final ovStart = o.startedAt.isAfter(c.startedAt) ? o.startedAt : c.startedAt;
    final ovEnd = o.endedAt!.isBefore(c.endedAt!) ? o.endedAt! : c.endedAt!;
    final ov = ovEnd.difference(ovStart).inMilliseconds;
    final durO = o.endedAt!.difference(o.startedAt).inMilliseconds;
    final durC = c.endedAt!.difference(c.startedAt).inMilliseconds;
    final short = math.max(1, math.min(durO, durC));
    return ov >= 0.5 * short;
  }

  // 세션의 순 하강량(m) = (최고 진행률 − 진입 진행률) × 축길이
  double _netDescent(_Cand c) => (c.maxProgress - c.entryProgress) * c.s.axisLen;

  /// 종료된 후보 그룹을 시간포함(nesting) 기반으로 dedup → 커밋
  void _finalizeGroup() {
    // 커버리지 하한 + 순 하강량 하한(리프트/역행/횡단처럼 하강 없는 세션 배제).
    // 상대(축길이×비율)와 절대 중 큰 값 — 긴 슬로프에선 축곡률로 횡단이 수십m 진행률을 만들어서.
    final cands = _cluster
        .where((c) =>
            c.coverageM >= noiseFloorM &&
            _netDescent(c) >= math.max(minDescentM, minDescentRatio * c.s.axisLen))
        .toList();
    final Map<int, _Cand> best = {};
    for (final c in cands) {
      final covr = c.covRatio;
      // 폐기: (1) 다른 후보 o가 c를 시간상 감쌈(nesting) → c는 승객
      //       (2) o와 실질적으로 겹치고 o 진행률이 더 큼 — 단 c가 o를 감싸면 예외
      final dominated = cands.any((o) =>
          !identical(o, c) &&
          o.coverageM >= noiseFloorM &&
          (_contains(o, c) ||
              (_substantial(o, c) && o.covRatio > covr + 1e-6 && !_contains(c, o))));
      if (dominated) {
        _log('✕ 폐기 ${c.s.name} (${c.reason}, 진행률 ${(covr * 100).toStringAsFixed(0)}% 지배당함)');
        continue;
      }
      final prev = best[c.s.slopeId];
      if (prev == null || covr > prev.covRatio) best[c.s.slopeId] = c;
    }
    for (final c in best.values) {
      double dist = 0;
      for (int i = 1; i < c.track.length; i++) {
        dist += metersBetween(c.track[i - 1], c.track[i]);
      }
      final secs = c.endedAt!.difference(c.startedAt).inMilliseconds / 1000.0;
      final avgSpeed = secs > 0 ? (dist / secs) * 3.6 : 0.0; // m/s→km/h
      final ev = CommitEvent(
        c.s.slopeId, c.s.name, c.coverageM, dist, c.track.length, c.endedAt!,
        entryProgress: c.entryProgress,
        exitProgress: c.maxProgress,
        startedAt: c.startedAt,
        avgSpeedKmh: avgSpeed,
        coverageRatio: c.covRatio,
        track: List<GeoPt>.from(c.track),
      );
      commits.add(ev);
      onCommit?.call(ev);
      _log('✅ 커밋 ${c.s.name} (${c.reason}) 진행률 ${(c.covRatio * 100).toStringAsFixed(0)}% cov ${c.coverageM.toStringAsFixed(0)}m 거리 ${dist.toStringAsFixed(0)}m');
    }
    // 폐기된 노이즈 후보 로그
    for (final c in _cluster) {
      if (c.coverageM < noiseFloorM) {
        _log('✕ 폐기 ${c.s.name} (${c.reason}, cov ${c.coverageM.toStringAsFixed(0)}m < 하한)');
      }
    }
    _cluster.clear();
  }

  void _log(String m) => onLog?.call(m);
}
