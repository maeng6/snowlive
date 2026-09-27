import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';

/// 우측 열 폭(피그마 64:112972 246 대신 공통 블록 1560 유지용 240 —
/// 중고거래 사이드바와 동일). 목록과의 간격 40은 홈 Row가 담당한다.
const double kCommunitySidebarWidth = 240;

/// 데스크탑 전용 우측 열. 목업(64:112373)은 `게시글 올리기` 버튼 + 배너 3개인데,
/// 배너는 운영 이미지가 아직 없어 추후 작업이다(버튼만 둔다).
/// (태블릿·모바일에서는 이 열을 접고 하단 플로팅 바를 쓴다)
class CommunitySidebarWeb extends StatelessWidget {
  final VoidCallback onWritePost;

  const CommunitySidebarWeb({super.key, required this.onWritePost});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kCommunitySidebarWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [CommunityWritePostButton(onTap: onWritePost)],
      ),
    );
  }
}

/// 파란 `게시글 올리기` 버튼 — 246×48 comp_button(피그마 64:112972)을 폭 240에 적용.
/// 높이는 공용 [webActionButtonHeight](웹 visualDensity가 minimumSize를 깎으므로 SizedBox로 강제),
/// 라운드 5, bold 16. hover는 배경 검정 10% 블렌드 즉시(웹 공통, 리플 없음).
class CommunityWritePostButton extends StatelessWidget {
  final VoidCallback onTap;

  const CommunityWritePostButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final height = webActionButtonHeight(context);
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          animationDuration: Duration.zero,
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered)
                ? Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.1),
                    SDSColor.snowliveBlue,
                  )
                : SDSColor.snowliveBlue,
          ),
          minimumSize: WidgetStatePropertyAll(Size(0, height)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        child: Text(
          '게시글 올리기',
          style: SDSTextStyle.bold.copyWith(
            fontSize: 16,
            color: SDSColor.snowliveWhite,
          ),
        ),
      ),
    );
  }
}
