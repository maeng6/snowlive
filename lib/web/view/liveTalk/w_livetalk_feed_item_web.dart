import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 좋아요/댓글 아이콘 — 모바일 앱([v_liveTalk_feedItem.dart])과 같은 에셋.
const String kLiveTalkLikeOnAsset = 'assets/imgs/icons/icon_livetalk_like_on.svg';
const String kLiveTalkLikeOffAsset = 'assets/imgs/icons/icon_livetalk_like_off.svg';
const String kLiveTalkReplyOnAsset = 'assets/imgs/icons/icon_livetalk_reply_on.svg';
const String kLiveTalkReplyOffAsset = 'assets/imgs/icons/icon_livetalk_reply_off.svg';

/// 라이브톡 피드 1건. 세 폭 공용 — 폭에 따라 달라지는 건 바깥 열 너비뿐이다.
///
/// 목업에 닉네임 오른쪽으로 리조트명(`휘닉스`)이 있지만 API에 필드가 없어서
/// 넣지 않았다(user_info는 user_id/display_name/profile_image_url뿐).
class LiveTalkFeedItemWeb extends StatelessWidget {
  final LiveTalk item;

  /// 이미지(또는 라이딩 카드)를 탭했을 때.
  final VoidCallback onTapImage;

  /// 댓글 수를 탭했을 때. 데스크탑·태블릿은 상세 오버레이, 모바일은 댓글 화면.
  final VoidCallback onTapComment;

  final VoidCallback onTapLike;

  /// null이면 ⋯를 그리지 않는다(현재는 항상 그린다).
  final List<WebMoreAction> moreActions;
  final ValueChanged<WebMoreAction> onMoreAction;

  /// 마지막 항목은 구분선을 그리지 않는다.
  final bool isLast;

  const LiveTalkFeedItemWeb({
    super.key,
    required this.item,
    required this.onTapImage,
    required this.onTapComment,
    required this.onTapLike,
    required this.moreActions,
    required this.onMoreAction,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = item.description != null && item.description!.trim().isNotEmpty;
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: SDSColor.gray50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (hasText) ...[
            const SizedBox(height: 6),
            Text(
              item.description!,
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900, height: 1.45),
            ),
          ],
          if (hasImage) ...[
            const SizedBox(height: 10),
            _buildImage(),
          ],
          const SizedBox(height: 12),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final userInfo = item.userInfo;
    final time = item.uploadTime != null ? GetDatetime().getAgoString(item.uploadTime!) : '';

    return Row(
      children: [
        WebProfileTap(
          userId: item.userId,
          name: userInfo?.displayName,
          avatarUrl: userInfo?.profileImageUrl,
          child: ClipOval(
            child: (userInfo?.profileImageUrl?.isNotEmpty ?? false)
                ? WebNetworkImage(
                    url: userInfo!.profileImageUrl,
                    width: 28,
                    height: 28,
                    fallback: _defaultAvatar(),
                  )
                : _defaultAvatar(),
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        Expanded(
          child: Text(
            userInfo?.displayName ?? '익명',
            style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(time, style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400)),
        const SizedBox(width: 4),
        WebMoreButton(iconSize: 20, actions: moreActions, onSelected: onMoreAction),
      ],
    );
  }

  Widget _buildImage() {
    // 세로로 긴 사진(라이딩 카드 등)이 화면을 다 먹지 않도록 상한을 둔다.
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTapImage,
            child: WebNetworkImage(
              url: item.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    final isLiked = item.isLiked == true;
    final commentCount = item.commentCount ?? 0;
    return Row(
      children: [
        LiveTalkCountButton(
          // 아이콘은 모바일 앱과 같은 에셋을 그대로 쓴다.
          asset: isLiked ? kLiveTalkLikeOnAsset : kLiveTalkLikeOffAsset,
          textColor: isLiked ? SDSColor.gray900 : SDSColor.gray400,
          count: item.likeCount ?? 0,
          onTap: onTapLike,
        ),
        const SizedBox(width: SDSSpacing.md),
        LiveTalkCountButton(
          asset: commentCount > 0 ? kLiveTalkReplyOnAsset : kLiveTalkReplyOffAsset,
          textColor: SDSColor.gray400,
          count: commentCount,
          onTap: onTapComment,
        ),
      ],
    );
  }

  Widget _defaultAvatar() => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(shape: BoxShape.circle, color: SDSColor.gray100),
        child: Icon(Icons.person, size: 16, color: SDSColor.gray400),
      );
}

/// 좋아요/댓글 수 버튼. 피드와 상세 패널이 공유한다.
/// 아이콘은 모바일 앱과 같은 SVG 에셋을 쓴다(색을 코드에서 입히지 않는다 —
/// 에셋 자체가 on/off 색을 들고 있다).
class LiveTalkCountButton extends StatelessWidget {
  final String asset;
  final Color textColor;
  final int count;

  /// null이면 표시만 하고 탭을 받지 않는다(상세 패널의 댓글 수).
  final VoidCallback? onTap;

  const LiveTalkCountButton({
    super.key,
    required this.asset,
    required this.textColor,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(asset, width: 20, height: 20),
            const SizedBox(width: 4),
            Text('$count', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: textColor)),
          ],
        ),
      ),
    );
  }
}
