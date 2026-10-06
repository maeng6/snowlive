import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 섹션 제목줄 오른쪽의 **전체보기 링크 버튼** — `전체 슬로프 보기` · `전체 멤버` ·
/// `전체 크루톡 보기`가 모두 이것이다(목업 161:86998).
///
/// 규격: 테두리 gray100 · 라운드 6 · 패딩 12/10 · 높이 36 · Bold 13 gray900.
/// hover는 웹 라인 버튼 공통 — **테두리·글자는 그대로, 면이 gray50으로 어두워진다**
/// (리플·그림자·전환 애니메이션 없음). `OutlinedButton` 기본값을 그대로 쓰면
/// Material 오버레이와 리플이 떠서 다른 화면과 어긋난다.
class WebSectionLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const WebSectionLinkButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        animationDuration: Duration.zero,
        side: const WidgetStatePropertyAll(BorderSide(color: SDSColor.gray100)),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered)
              ? SDSColor.gray50
              : SDSColor.snowliveWhite,
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
        // 웹 기본 compact density가 높이를 깎으므로 표준으로 고정한다.
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
      ),
    );
  }
}
