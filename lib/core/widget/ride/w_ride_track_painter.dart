import 'package:com.snowlive/core/model/m_rideDetail.dart';
import 'package:flutter/material.dart';

/// 슬로프 폴리곤 경계 + 궤적을 진행방향(위→아래)으로 그리는 페인터.
/// 서버 _render_track_svg_slope와 동일한 회전/스케일 기하를 Dart로 포팅.
/// [progress] 0..1 : 궤적을 그만큼만 그린다(재생 애니메이션). 1이면 전체(정지 이미지).
class RideTrackPainter extends CustomPainter {
  final RideDetail detail;
  final double progress;
  final bool showGpsPoints;
  final bool showMovingMarker;

  /// 재생/영상용: 궤적을 Catmull-Rom으로 5배 촘촘히 보간해 부드럽게 그린다.
  final bool smooth;

  RideTrackPainter({
    required this.detail,
    this.progress = 1.0,
    this.showGpsPoints = true,
    this.showMovingMarker = false,
    this.smooth = false,
  });

  static const Color _bg = Color(0xFF0B1220);
  static const Color _poly = Color(0xFF94A3B8);
  static const Color _axis = Color(0xFF334155);
  static const Color _line = Color(0xFF3D83ED);
  static const Color _start = Color(0xFF22C55E);
  static const Color _end = Color(0xFFEF4444);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const pad = 22.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = _bg);

    final slope = detail.slope;
    final ring = slope?.area ?? const <List<double>>[];
    final axis = slope?.axis ?? const <List<double>>[];
    final track = detail.track;
    if (track.isEmpty && ring.isEmpty) return;

    final proj = RideProjection.build(ring: ring, axis: axis, track: track);
    final ringS = ring.map(proj.rot).toList();
    final trackS = track.map(proj.rot).toList();
    final axisS = axis.map(proj.rot).toList();

    final sc = _min((w - 2 * pad) / proj.spanx, (h - 2 * pad) / proj.spany);
    final offx = (w - proj.spanx * sc) / 2;
    final offy = (h - proj.spany * sc) / 2;
    Offset map(List<double> s) => Offset(
          offx + (s[0] - proj.minsx) * sc,
          offy + (s[1] - proj.minsy) * sc,
        );

    // 슬로프 폴리곤
    if (ringS.length >= 3) {
      final path = Path()..moveTo(map(ringS.first).dx, map(ringS.first).dy);
      for (final s in ringS.skip(1)) {
        final o = map(s);
        path.lineTo(o.dx, o.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = _poly.withValues(alpha: 0.12));
      canvas.drawPath(
          path,
          Paint()
            ..color = _poly
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeJoin = StrokeJoin.round);
    }

    // 진행축(점선)
    if (axisS.length >= 2) {
      _dashedLine(canvas, map(axisS.first), map(axisS.last),
          Paint()..color = _axis..strokeWidth = 1.5);
    }

    // "↓ 진행방향" 라벨
    _text(canvas, '↓ 진행방향', Offset(w / 2, 14), const Color(0xFF64748B), 12);

    // 궤적(progress까지). 마커를 샘플 사이에서 선형보간해 끊김 없이 이동시킨다.
    if (trackS.length >= 2) {
      final raw = trackS.map(map).toList();
      final rawN = raw.length;

      // 큰 점프(= 리프트로 다시 올라간 구간: GPS 공백)에서 '끊는다' → 연속 구간(run)들로 분리.
      final segLen = <double>[];
      for (int k = 1; k < rawN; k++) {
        segLen.add((raw[k] - raw[k - 1]).distance);
      }
      final sorted = [...segLen]..sort();
      final median = sorted.isEmpty ? 0.0 : sorted[sorted.length ~/ 2];
      final gapThreshold = (median * 6).clamp(40.0, double.infinity).toDouble();

      // 연속 구간들로 분리(공백 세그먼트에서 끊음).
      final runs = <List<Offset>>[];
      var cur = <Offset>[raw.first];
      for (int k = 1; k < rawN; k++) {
        if (segLen[k - 1] > gapThreshold) {
          runs.add(cur);
          cur = <Offset>[raw[k]];
        } else {
          cur.add(raw[k]);
        }
      }
      runs.add(cur);

      // 렌더용 점열: smooth면 run마다 Catmull-Rom로 5배 보간. runStart=각 run의 시작 인덱스.
      final pts = <Offset>[];
      final runStart = <int>{};
      for (final run in runs) {
        runStart.add(pts.length);
        pts.addAll(smooth ? _smoothRun(run) : run);
      }
      final n = pts.length;
      bool isRunStart(int k) => runStart.contains(k);

      final p = progress.clamp(0.0, 1.0);
      final fpos = p * (n - 1);
      final i = fpos.floor().clamp(0, n - 1);
      final frac = (fpos - i).clamp(0.0, 1.0);
      // 현재 위치: 다음 점이 새 run의 시작(=리프트 공백)이면 직선비행 대신 현재 점에 머무른다.
      final Offset head = (i >= n - 1)
          ? pts[n - 1]
          : (isRunStart(i + 1) ? pts[i] : Offset.lerp(pts[i], pts[i + 1], frac)!);

      // 지나온 경로: run 경계에서는 선을 잇지 않고 새로 시작(moveTo).
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int k = 1; k <= i; k++) {
        if (isRunStart(k)) {
          path.moveTo(pts[k].dx, pts[k].dy);
        } else {
          path.lineTo(pts[k].dx, pts[k].dy);
        }
      }
      if (i < n - 1 && !isRunStart(i + 1)) path.lineTo(head.dx, head.dy);
      canvas.drawPath(
          path,
          Paint()
            ..color = _line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round);

      if (showGpsPoints) {
        final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.32);
        final rawCount = (rawN * p).clamp(0, rawN).toInt();
        for (int k = 0; k < rawCount; k++) {
          canvas.drawCircle(raw[k], 2.2, dotPaint);
        }
      }

      canvas.drawCircle(raw.first, 6, Paint()..color = _start);
      if (progress >= 1.0) {
        canvas.drawCircle(raw.last, 6, Paint()..color = _end);
      } else if (showMovingMarker) {
        canvas.drawCircle(head, 5.5, Paint()..color = Colors.white);
        canvas.drawCircle(head, 3.5, Paint()..color = _line);
      }
    }
  }

  /// 세그먼트 길이(px)에 비례해 분할 수를 정한다 — GPS가 성겨 점 간격이 멀어도
  /// 픽셀상 균일(≈3px)하게 쪼개져 재생이 '점으로 뚝뚝' 끊기지 않고 선형으로 흐른다.
  static int _stepsFor(double distPx) => (distPx / 3).ceil().clamp(2, 160);

  /// 한 연속 구간을 Catmull-Rom 스플라인으로 **길이에 비례해** 촘촘히 보간한다.
  /// 2점짜리(아주 성긴) 구간도 직선으로 촘촘히 나눠 끊김을 없앤다.
  List<Offset> _smoothRun(List<Offset> pRun) {
    if (pRun.length < 2) return pRun;
    final out = <Offset>[];
    if (pRun.length == 2) {
      final steps = _stepsFor((pRun[1] - pRun[0]).distance);
      for (int s = 0; s < steps; s++) {
        out.add(Offset.lerp(pRun[0], pRun[1], s / steps)!);
      }
      out.add(pRun[1]);
      return out;
    }
    for (int j = 0; j < pRun.length - 1; j++) {
      final p0 = pRun[j == 0 ? 0 : j - 1];
      final p1 = pRun[j];
      final p2 = pRun[j + 1];
      final p3 = pRun[j + 2 >= pRun.length ? pRun.length - 1 : j + 2];
      final steps = _stepsFor((p2 - p1).distance);
      for (int s = 0; s < steps; s++) {
        out.add(_catmullRom(p0, p1, p2, p3, s / steps));
      }
    }
    out.add(pRun.last);
    return out;
  }

  Offset _catmullRom(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final t2 = t * t, t3 = t2 * t;
    double c(double a, double b, double cc, double d) =>
        0.5 *
        ((2 * b) +
            (-a + cc) * t +
            (2 * a - 5 * b + 4 * cc - d) * t2 +
            (-a + 3 * b - 3 * cc + d) * t3);
    return Offset(
        c(p0.dx, p1.dx, p2.dx, p3.dx), c(p0.dy, p1.dy, p2.dy, p3.dy));
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 6.0, gap = 6.0;
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    double d = 0;
    while (d < total) {
      final s = a + dir * d;
      final e = a + dir * (d + dash).clamp(0, total).toDouble();
      canvas.drawLine(s, e, paint);
      d += dash + gap;
    }
  }

  void _text(Canvas canvas, String s, Offset center, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(color: color, fontSize: size, fontFamily: 'Pretendard')),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  double _min(double a, double b) => a < b ? a : b;

  @override
  bool shouldRepaint(covariant RideTrackPainter old) =>
      old.progress != progress ||
      old.detail != detail ||
      old.showGpsPoints != showGpsPoints ||
      old.showMovingMarker != showMovingMarker ||
      old.smooth != smooth;
}
