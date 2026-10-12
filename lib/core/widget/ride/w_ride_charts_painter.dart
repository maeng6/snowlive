import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 거리(x) 대비 값(y) 미니 라인차트. 속도/고도/경사 공용.
class MiniChartPainter extends CustomPainter {
  final List<double> xs; // 누적 거리(m)
  final List<double> ys; // 값(nan은 건너뜀)
  final Color color;

  MiniChartPainter({required this.xs, required this.ys, required this.color});

  static const Color _bg = Color(0xFF0B1220);
  static const Color _grid = Color(0xFF1F2A44);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const pad = 8.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = _bg);
    if (xs.length < 2 || ys.length < 2) return;

    final n = math.min(xs.length, ys.length);
    double xMin = xs[0], xMax = xs[0];
    double yMin = double.infinity, yMax = -double.infinity;
    for (int i = 0; i < n; i++) {
      if (xs[i] < xMin) xMin = xs[i];
      if (xs[i] > xMax) xMax = xs[i];
      final y = ys[i];
      if (y.isNaN) continue;
      if (y < yMin) yMin = y;
      if (y > yMax) yMax = y;
    }
    if (!yMin.isFinite || !yMax.isFinite) return;
    final xSpan = (xMax - xMin) == 0 ? 1.0 : (xMax - xMin);
    final ySpan = (yMax - yMin) == 0 ? 1.0 : (yMax - yMin);

    double px(double x) => pad + (x - xMin) / xSpan * (w - 2 * pad);
    double py(double y) => h - pad - (y - yMin) / ySpan * (h - 2 * pad);

    // 기준선(가운데)
    canvas.drawLine(Offset(pad, h / 2), Offset(w - pad, h / 2),
        Paint()..color = _grid..strokeWidth = 1);

    final path = Path();
    bool started = false;
    for (int i = 0; i < n; i++) {
      final y = ys[i];
      if (y.isNaN) continue;
      final o = Offset(px(xs[i]), py(y));
      if (!started) {
        path.moveTo(o.dx, o.dy);
        started = true;
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant MiniChartPainter old) =>
      old.xs != xs || old.ys != ys || old.color != color;
}
