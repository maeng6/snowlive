import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 좌측 여백(lg)을 포함한 폭. 콘텐츠 최대폭 안에서 이 폭을 뺀 나머지가 목록 영역이다.
const double kCommunitySidebarWidth = 280;

/// 데스크탑 전용 우측 열. 목업에는 `게시글 올리기` 버튼만 있다.
/// (태블릿·모바일에서는 이 열을 접고 콘텐츠 끝에 전체폭 버튼을 둔다)
class CommunitySidebarWeb extends StatelessWidget {
  final VoidCallback onWritePost;

  const CommunitySidebarWeb({super.key, required this.onWritePost});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kCommunitySidebarWidth,
      // 카테고리 탭 줄과 버튼이 나란히 오도록 내린다(중고거래 사이드바와 같은 규격).
      padding: const EdgeInsets.only(left: SDSSpacing.lg, top: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [CommunityWritePostButton(onTap: onWritePost)],
      ),
    );
  }
}

/// 파란 `게시글 올리기` 버튼. 데스크탑은 사이드바, 그 외는 콘텐츠 끝에서 쓴다.
class CommunityWritePostButton extends StatelessWidget {
  final VoidCallback onTap;

  const CommunityWritePostButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        elevation: 0,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        '게시글 올리기',
        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite),
      ),
    );
  }
}
