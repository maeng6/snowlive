import 'dart:math' as math;
import 'slope_geometry.dart';

/// 커밋(라이딩 인정) 이벤트
class CommitEvent {
  final int slopeId;
  final String name;
  final double coverageM;
  final double distanceM;
  final int points;
  final DateTime at;
  CommitEvent(this.slopeId, this.name, this.coverageM, this.distanceM, this.points, this.at);
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

  _Cand(this.s, this.entryProgress, this.startedAt, this.lastInsideAt, this.lastInsidePt)
      : maxProgress = entryProgress,
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
  final double bandM;       // max_progress 후퇴 밴드(m) → 리프트/걸어오름 종료
  final double noiseFloorM; // 최소 하강 하한(m)

  PolygonSessionMachine(this.slopes,
      {this.entryConfirm = 2, this.exitConfirm = 2, this.bandM = 25, this.noiseFloorM = 5});

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
          final bandPr = s.axisLen > 0 ? bandM / s.axisLen : 0.05;
          if (pr < c.maxProgress - bandPr) {
            _end(c, t, '후퇴(밴드)');
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

  /// 종료된 후보 그룹을 최종 진행률(비율)로 비교 → 지배 판정 후 커밋
  void _finalizeGroup() {
    final cands = _cluster.where((c) => c.coverageM >= noiseFloorM).toList();
    final Map<int, _Cand> best = {};
    for (final c in cands) {
      final covr = c.covRatio;
      // 시간상 겹친 다른 후보의 최종 진행률이 더 크면 폐기
      final dominated = cands.any((o) =>
          !identical(o, c) &&
          o.startedAt.isBefore(c.endedAt!) &&
          o.endedAt!.isAfter(c.startedAt) &&
          o.covRatio > covr + 1e-6);
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
      final ev = CommitEvent(c.s.slopeId, c.s.name, c.coverageM, dist, c.track.length, c.endedAt!);
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
