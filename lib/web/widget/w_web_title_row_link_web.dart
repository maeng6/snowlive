import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 타이틀 줄 **제일 우측**에 붙는 텍스트 버튼 — 글자 + 꺾쇠.
///
/// 우측 열(사이드바)이 접히는 폭에서 사이드바 버튼이 갈 자리로 쓴다.
/// `가입 신청한 크루`(라이브크루 홈 태블릿·모바일) · `가입 신청하기`(크루홈 모바일)가 이것이다.
///
/// 규격: Bold 13 gray600 + 꺾쇠 16, 상하 히트 여백 6.
/// hover는 아이콘·링크 공통 — **불투명도 0.6**(애니메이션 없음).
class WebTitleRowLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  /// 줄 높이를 **직접 맞춰야 할 때** 쓴다(크루홈 — 크루명 글줄과 세로 중심을 맞추고
  /// 부제를 밀지 않으려면 이 박스가 글줄과 같은 높이여야 한다).
  ///
  /// ⚠️ 바깥에서 `SizedBox`+`Center`로 감싸면 안 된다 — 아래의 상하 패딩까지 함께
  /// 조여져 **글자 아래가 잘린다**. 여기로 넘기면 패딩 대신 이 높이를 쓴다.
  final double? boxHeight;

  const WebTitleRowLink({
    super.key,
    required this.label,
    required this.onTap,
    this.boxHeight,
  });

  @override
  State<WebTitleRowLink> createState() => _WebTitleRowLinkState();
}

class _WebTitleRowLinkState extends State<WebTitleRowLink> {
  bool _hovered = false;

  /// 높이를 지정하면 그 안에서 **가운데** 두고(누를 높이도 그만큼),
  /// 아니면 상하 6 패딩으로 누를 높이를 확보한다.
  Widget _box(Widget child) {
    final height = widget.boxHeight;
    if (height == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: child,
      );
    }
    return SizedBox(height: height, child: Center(child: child));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Opacity(
          opacity: _hovered ? 0.6 : 1.0,
          child: _box(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray600),
                ),
                const Icon(Icons.chevron_right, size: 16, color: SDSColor.gray600),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
