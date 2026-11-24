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
  final double maxSpeedKmh;   // 최고 순간속도(km/h, 세그먼트 기반)
  final double coverageRatio; // 진행률(bin 비율) 0~1
  final List<GeoPt> track;    // 세션 궤적(유료 저장·서버 전송용)
  final Map<String, dynamic>? samples; // per-point 샘플 {t,lat,lng,alt,spd}
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
    this.maxSpeedKmh = 0,
    this.coverageRatio = 0,
    List<GeoPt>? track,
    this.samples,
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
  final List<DateTime> trackT = [];   // track[i] 시각 (per-point 샘플용)
  final List<double?> trackAlt = [];  // track[i] 고도(m, 없으면 null)

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
  final int reentryGraceMs;     // 짧은 이탈 후 재진입 시 같은 세션으로 이어붙이는 유예(ms)
  final double altRiseTolM;     // 진입 시 고도 상승 허용치(m) — 이보다 오르면 리프트로 보고 세션 시작 안 함
  final double minNetDescentM;  // 커밋 전 순 하강(고도) 하한(m) — 안 내려오면 리프트/평탄으로 드롭
  // 🎿 속도 우선: GPS 고도는 부정확(활강 중 100m+ 튐)해서 고도만으로 리프트를 판정하면
  // '빠른 실제 라이딩'을 오삭제한다. 평활 속도의 상위값(p80)이 이 스키속도(km/h) 이상이면
  // 고도가 어떻든 실제 하강(라이딩)으로 보고 고도 가드로 드롭하지 않는다(리프트는 3~6km/h).
  final double skiSpeedKmh;

  PolygonSessionMachine(this.slopes,
      {this.entryConfirm = 2, this.exitConfirm = 2, this.bandM = 25, this.noiseFloorM = 5,
      this.minDescentM = 15, this.minDescentRatio = 0.05, this.reentryGraceMs = 8000,
      this.altRiseTolM = 1.0, this.minNetDescentM = 3.0, this.skiSpeedKmh = 15.0});

  final Map<int, _Cand> _active = {};
  final Map<int, int> _entryStreak = {};
  final Map<int, double> _lastPr = {};
  double? _prevAlt; // 직전 점의 고도(기기 단일 스트림) — 진입 시 '고도 상승 여부' 판별용
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

  void onPoint(GeoPt p, DateTime t, {double? alt}) {
    // [임시/디버그] 포인트별 상세 로그용 — 이 점에서 '폴리곤 안'에 든 슬로프 수집
    final List<String> insNames = [];
    for (final s in slopes) {
      if (!s.hasPolygon) continue;
      final ins = s.inBbox(p) && s.contains(p);
      final double pr = ins ? s.progress(p) : -1.0;
      inside[s.slopeId] = ins;
      progress[s.slopeId] = pr;
      if (ins) insNames.add('${s.name}:${pr.toStringAsFixed(2)}');

      final c = _active[s.slopeId];
      if (c == null) {
        // 진입 판별: 폴리곤 안 + 하강(진행률 증가) + 고도 안 오름(리프트 배제)
        if (ins && pr >= 0) {
          final last = _lastPr[s.slopeId];
          // 진입 판별: 진행률 증가(하강) + 고도 안 오름(per-point 급상승이면 리프트로 보고 제외).
          // 실측상 리프트는 진행률이 '감소'하므로 "진행률 증가 필수" 조건만으로도 대부분 막힌다.
          // (전진투영으로 진행률 증가하는 리프트는 데이터상 없음 — 그런 궤적은 실제 라이딩이었음)
          final altRising = alt != null && _prevAlt != null && alt > _prevAlt! + altRiseTolM;
          final descending = last != null && pr > last + 1e-9 && !altRising;
          _entryStreak[s.slopeId] = descending ? (_entryStreak[s.slopeId] ?? 0) + 1 : 0;
          _lastPr[s.slopeId] = pr;
          if ((_entryStreak[s.slopeId] ?? 0) >= entryConfirm - 1 && last != null) {
            final cand = _Cand(s, last, t, t, p);
            cand.maxProgress = pr;
            cand.addBin(pr);
            cand.track.add(p);
            cand.trackT.add(t);
            cand.trackAlt.add(alt);
            _active[s.slopeId] = cand;
            _cluster.add(cand);
            _log('▶ 세션시작 ${s.name} (진입 pr=${last.toStringAsFixed(2)})');
          }
        } else {
          // 폴리곤 밖이면 진입 기준선(_lastPr)을 리셋한다. 안 그러면 '직전 방문의 오래된
          // 진행률'이 남아, 바닥(여러 슬로프가 겹치는 구간)에 다시 들어올 때 pr 점프(예: 0.71→1.0)가
          // '진행률 증가'로 오인돼 유령 세션이 시작된다. 그 세션이 이어서 리프트 상승(진행률 감소)을
          // 기록한다 — 겹친 슬로프에 리프트가 세션으로 잡히던 근본 원인. 리셋하면 재진입 후
          // '새로 연속 하강'해야만 진입하므로, 진행률이 감소하는 리프트는 애초에 시작되지 않는다.
          _lastPr.remove(s.slopeId);
          _entryStreak[s.slopeId] = 0;
        }
      } else {
        // 활성 세션
        if (ins && pr >= 0) {
          c.track.add(p);
          c.trackT.add(t);
          c.trackAlt.add(alt);
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
          // 재진입 유예(reentry grace): 짧은 이탈(GPS 튐·경계 스침)로 세션이 끊겨
          // 한 번의 라이딩이 둘로 쪼개지는(=라이딩 횟수 중복) 걸 막는다.
          // 연속 exitConfirm점 밖 '그리고' 마지막 내부점으로부터 grace 이상 지나야 실제 종료.
          // (유예 안에 다시 들어오면 c.outside=0으로 리셋돼 같은 세션으로 이어진다.)
          final outMs = t.difference(c.lastInsideAt).inMilliseconds;
          if (c.outside >= exitConfirm && outMs >= reentryGraceMs) {
            // 종료 시각은 실제로 마지막으로 폴리곤 안에 있던 시점(이탈 공백 제외).
            _end(c, c.lastInsideAt, '폴리곤이탈');
          }
        }
      }
    }
    // 직전 고도 갱신(기기 단일 스트림) — 다음 점의 진입 고도판별용.
    if (alt != null) _prevAlt = alt;
    // [임시/디버그] 포인트별 상세 로그: 좌표 + 이 점에서 안에 든 슬로프(진행률) + 활성세션 상태
    _log('· (${p.lat.toStringAsFixed(6)},${p.lng.toStringAsFixed(6)}) '
        'in=[${insNames.join(', ')}] act=[$activeSummary]');
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
    // [임시/디버그] 세션 종료 시점·사유 로그(폴리곤이탈/연속후퇴/세션종료)
    _log('◂ 세션종료 ${c.s.name} ($reason) maxPr=${c.maxProgress.toStringAsFixed(2)} '
        'cov=${c.coverageM.toStringAsFixed(0)}m 점=${c.track.length}');
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

  // 고도상 실제로 내려왔는가 — 리프트가 폴리곤 가장자리/축밖을 지나 진행률만 증가하는
  // 케이스를 고도(수직 진실)로 막는다. 고도 데이터가 없으면(판정불가) true(기존 필터에 위임).
  bool _altDescends(_Cand c) {
    // 🎿 속도 우선(지터 아닐 때만): 지속 스키속도(p80)가 나오고 궤적이 지터가 아니면
    // — GPS 고도가 어떻든 — 실제 라이딩이다. 리프트는 느려서 못 미치고, 지터는 가짜 속도를
    // 만들 수 있어 곡률로 걸러낸다. (빠른 실제 라이딩 오삭제 방지)
    if (_rideSpeedP80(c) >= skiSpeedKmh && _curvature(c) <= 1.8) return true;
    final a = <double>[];
    for (final v in c.trackAlt) {
      if (v != null) a.add(v);
    }
    if (a.length < 6) return true;
    final head = (a[0] + a[1] + a[2]) / 3.0;
    final tail = (a[a.length - 1] + a[a.length - 2] + a[a.length - 3]) / 3.0;
    return (head - tail) >= minNetDescentM;
  }

  /// 점간 속도(km/h)의 80퍼센타일 — 단일 GPS 튐에 강건. 리프트/라이딩 판별용.
  double _rideSpeedP80(_Cand c) {
    final n = c.track.length;
    if (n < 5 || c.trackT.length != n) return 0;
    final sp = <double>[];
    for (int i = 1; i < n; i++) {
      final dt = c.trackT[i].difference(c.trackT[i - 1]).inMilliseconds / 1000.0;
      if (dt > 0) sp.add(metersBetween(c.track[i - 1], c.track[i]) / dt * 3.6);
    }
    if (sp.isEmpty) return 0;
    sp.sort();
    return sp[math.min(sp.length - 1, (sp.length - 1) * 8 ~/ 10)];
  }

  /// 궤적 경로길이/직선변위 비율. 1=직선, 클수록 구불. 실제 라이딩~1~1.8, 리프트~1.0,
  /// GPS 지터(제자리 튐)는 2.5+ (경로만 길고 실제론 안 움직임).
  double _curvature(_Cand c) {
    final n = c.track.length;
    if (n < 3) return 1.0;
    double path = 0;
    for (int i = 1; i < n; i++) {
      path += metersBetween(c.track[i - 1], c.track[i]);
    }
    final straight = metersBetween(c.track[0], c.track[n - 1]);
    return straight > 1.0 ? path / straight : 99.0;
  }

  /// GPS 지터(바닥 승차장/정지 중 좌표가 좁은 영역서 튐)로 생긴 가짜 세션.
  bool _isJitter(_Cand c) => c.track.length >= 8 && _curvature(c) >= 2.5;

  /// 종료된 후보 그룹을 시간포함(nesting) 기반으로 dedup → 커밋
  void _finalizeGroup() {
    // 커버리지 하한 + 순 하강량 하한(리프트/역행/횡단처럼 하강 없는 세션 배제).
    // 상대(축길이×비율)와 절대 중 큰 값 — 긴 슬로프에선 축곡률로 횡단이 수십m 진행률을 만들어서.
    final cands = _cluster
        .where((c) =>
            c.coverageM >= noiseFloorM &&
            !_isJitter(c) &&  // GPS 지터(제자리 튐)로 생긴 가짜 세션 제외
            _netDescent(c) >= math.max(minDescentM, minDescentRatio * c.s.axisLen) &&
            _altDescends(c))
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
      final n = c.track.length;
      // 누적 경로거리(m)
      final cum = List<double>.filled(n, 0.0);
      for (int i = 1; i < n; i++) {
        cum[i] = cum[i - 1] + metersBetween(c.track[i - 1], c.track[i]);
      }
      final dist = n > 0 ? cum[n - 1] : 0.0;
      final secs = c.endedAt!.difference(c.startedAt).inMilliseconds / 1000.0;
      final avgSpeed = secs > 0 ? (dist / secs) * 3.6 : 0.0; // m/s→km/h

      // 노이즈 없는 속도: 각 점을 중심으로 ±3초 창의 (경로거리/시간)으로 평활화.
      // 단일 GPS 튐이 섞여도 창 평균이라 스파이크가 사라진다. 상한 120km/h.
      const winMs = 3000;
      final spd = List<double>.filled(n, 0.0);
      for (int i = 0; i < n; i++) {
        int j = i, k = i;
        while (j > 0 && c.trackT[i].difference(c.trackT[j]).inMilliseconds < winMs) j--;
        while (k < n - 1 && c.trackT[k].difference(c.trackT[i]).inMilliseconds < winMs) k++;
        final dt = c.trackT[k].difference(c.trackT[j]).inMilliseconds / 1000.0;
        double v = dt > 0 ? (cum[k] - cum[j]) / dt * 3.6 : 0.0;
        if (v < 0) v = 0.0;
        if (v > 120) v = 120.0;
        spd[i] = v;
      }
      final maxSpeed = spd.isEmpty ? 0.0 : spd.reduce(math.max);

      // per-point 샘플(JSON) — 시간오프셋(ms)·좌표·고도·평활속도(km/h)
      final t0 = c.startedAt;
      final sT = <int>[];
      final sLat = <double>[], sLng = <double>[], sSpd = <double>[];
      final sAlt = <double?>[];
      for (int i = 0; i < n; i++) {
        sT.add(c.trackT[i].difference(t0).inMilliseconds);
        sLat.add(double.parse(c.track[i].lat.toStringAsFixed(6)));
        sLng.add(double.parse(c.track[i].lng.toStringAsFixed(6)));
        sAlt.add(c.trackAlt[i] == null ? null : double.parse(c.trackAlt[i]!.toStringAsFixed(1)));
        sSpd.add(double.parse(spd[i].toStringAsFixed(1)));
      }
      final samples = {'t': sT, 'lat': sLat, 'lng': sLng, 'alt': sAlt, 'spd': sSpd};

      final ev = CommitEvent(
        c.s.slopeId, c.s.name, c.coverageM, dist, c.track.length, c.endedAt!,
        entryProgress: c.entryProgress,
        exitProgress: c.maxProgress,
        startedAt: c.startedAt,
        avgSpeedKmh: avgSpeed,
        maxSpeedKmh: maxSpeed,
        coverageRatio: c.covRatio,
        track: List<GeoPt>.from(c.track),
        samples: samples,
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
