import 'package:flutter/painting.dart';

/// 파스텔 도트 아케이드 색 팔레트(COLOR GUIDE.md, 12색 고정).
/// 이 UI는 여기 정의된 토큰만 참조한다 — hex 직접 사용 금지.
abstract final class GameColors {
  static const ink = Color(0xFF3B3355); // 외곽선, 본문 텍스트, 어두운 배경
  static const shadow = Color(0xFF6C5B8C); // 그림자, 보조 텍스트
  static const cream = Color(0xFFFFF4E0); // 기본 배경, 패널, 어두운 배경 위 텍스트
  static const white = Color(0xFFFFFFFF); // 하이라이트 전용
  static const sky = Color(0xFFA8D8F0); // 하늘, 물, 정보
  static const mint = Color(0xFFA8E6CF); // 풀, 아이템, 성공
  static const teal = Color(0xFF6FC3B2); // mint 그림자
  static const lemon = Color(0xFFFFE59A); // 코인, 점수, 강조
  static const peach = Color(0xFFFFC3A0); // 캐릭터, 기본 버튼, lemon 그림자
  static const pink = Color(0xFFFFA8C5); // 하트, 포인트
  static const coral = Color(0xFFFF8B8B); // 적, 경고, HP, pink 그림자
  static const lavender = Color(0xFFC9B6F2); // 마법, 보너스, 특수
}
