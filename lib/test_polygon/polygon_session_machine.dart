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
  int outside = 0;
  bool active = true;
  _Cand(this.s, this.entryProgress, this.startedAt, this.lastInsideAt, this.lastInsidePt)
      : maxProgress = entryProgress;
  double get coverageM => (maxProgress - entryProgress).clamp(0.0, 1.0) * s.axisLen;
}

/// 폴리곤 라이딩 판별 상태머신 (계획서 §3). 순수 로직 — GPS/서버 의존 없음.
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
          .map((c) => '${c.s.name}(pr ${(c.maxProgress).toStringAsFixed(2)}, cov ${c.coverageM.toStringAsFixed(0)}m)')
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
    if (_active.isEmpty && _cluster.isNotEmpty && _cluster.every((c) => !c.active)) {
      _cluster.clear();
    }
  }

  void _end(_Cand c, DateTime t, String reason) {
    c.active = false;
    c.endedAt = t;
    _active.remove(c.s.slopeId);
    _entryStreak[c.s.slopeId] = 0;
    final cov = c.coverageM;

    // 지배(domination) 판정: 시간상 겹친 다른 후보가 커버리지 ≥ 이면 폐기
    _Cand? by;
    for (final o in _cluster) {
      if (identical(o, c)) continue;
      final oEnd = o.endedAt ?? t;
      final overlap = o.startedAt.isBefore(t) && oEnd.isAfter(c.startedAt);
      if (overlap && o.coverageM >= cov) {
        by = o;
        break;
      }
    }

    if (cov < noiseFloorM) {
      _log('✕ 폐기 ${c.s.name} ($reason, cov ${cov.toStringAsFixed(0)}m < 하한 ${noiseFloorM.toStringAsFixed(0)}m)');
    } else if (by != null) {
      _log('✕ 폐기 ${c.s.name} ($reason, ${by.s.name}에 지배 cov ${cov.toStringAsFixed(0)}m)');
    } else {
      double dist = 0;
      for (int i = 1; i < c.track.length; i++) {
        dist += metersBetween(c.track[i - 1], c.track[i]);
      }
      final ev = CommitEvent(c.s.slopeId, c.s.name, cov, dist, c.track.length, t);
      commits.add(ev);
      onCommit?.call(ev);
      _log('✅ 커밋 ${c.s.name} ($reason) cov ${cov.toStringAsFixed(0)}m 거리 ${dist.toStringAsFixed(0)}m 점 ${c.track.length}');
    }
  }

  void _log(String m) => onLog?.call(m);
}
