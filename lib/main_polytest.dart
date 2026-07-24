import 'package:flutter/material.dart';
import 'test_polygon/v_polygon_test.dart';

/// 폴리곤 판별 테스트 전용 진입점 (기존 앱 로직과 완전 분리).
/// 실행: flutter run -t lib/main_polytest.dart
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PolygonTestScreen(),
  ));
}
