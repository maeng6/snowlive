import 'package:flutter/material.dart';

class GradientBorderPainter extends CustomPainter {
  final LinearGradient gradient;

  GradientBorderPainter(this.gradient);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4; // Border width

    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(40));
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}