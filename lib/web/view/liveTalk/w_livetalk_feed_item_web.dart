import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
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

/// 카드 사이 간격 — PC·태블릿 44 / 모바일 40 (둘 다 목업 32에서 넓힘, 사용자 확정).
/// 구분선 없이 여백으로만 글을 나눈다. 카드 자체에는 상하 패딩이 없으므로
/// **쓰는 쪽이** 이 간격을 넣는다.
double liveTalkFeedItemGap(BuildContext context) =>
    context.screenType == WebScreenType.mobile ? 40 : 44;

/// 본문 사진 규격. 로딩 자리표시 비율은 어림값 —
/// 스켈레톤([LiveTalkFeedSkeleton])이 **같은 값을 써야** 스켈레톤 → 사진 전환에서
/// 크기가 튀지 않는다.
///
/// 사진 높이 상한 = 열 너비 × 이 비율(4:5 — 인스타그램 피드의 세로 한계).
///
/// 인스타그램 피드와 같은 규칙(사용자 확정) — **항상 폭을 꽉 채우고**, 높이는
/// 원본 비율대로 늘되 이 상한까지만. 상한을 넘는 사진(라이딩 카드 등)은 위아래가
/// 잘린다(인스타는 업로드 때 크롭시키지만 우리는 크롭 단계가 없어 표시에서 자른다).
///
/// ⚠️ 라이딩 카드를 **타입으로 구분할 방법이 없다** — 응답에 타입 필드가 없고
/// 저장 경로도 사진과 공용(`livetalk/{userId}_{ts}.{ext}`)이다. 확장자도 단서가
/// 못 된다: 카드는 항상 `.png`지만 앱에서 PNG 사진을 고르면 그것도 `.png`다
/// (`vm_liveTalk.dart`의 `_uploadImage`). 카드를 따로 다루려면 서버 필드가 필요하다.
const double kLiveTalkFeedImageMaxRatio = 1.25;
const double kLiveTalkFeedImageRatio = 1;
const double kLiveTalkFeedImageRadius = 4;

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

  const LiveTalkFeedItemWeb({
    super.key,
    required this.item,
    required this.onTapImage,
    required this.onTapComment,
    required this.onTapLike,
    required this.moreActions,
    required this.onMoreAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = item.description != null && item.description!.trim().isNotEmpty;
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    // 카드에는 패딩·구분선이 없다(피그마 80:217022) — 글 사이는 여백
    // [kLiveTalkFeedItemGap]으로만 나눈다.
    //
    // 순서는 헤더 → **사진 → 글** → 액션이다(사용자 결정). 목업은 글이 사진 위지만,
    // 사진을 헤더 바로 아래에 두면 카드마다 사진 위치가 일정해 훑기 좋고 글이
    // 캡션처럼 읽힌다.
    //
    // 모바일은 블록 사이를 2씩 좁힌다(사용자 확정) — 카드 안이 조밀해질수록
    // 구분선 없이도 카드 사이 여백이 더 또렷하게 읽힌다.
    final tighten = context.screenType == WebScreenType.mobile ? 2.0 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        if (hasImage) ...[
          SizedBox(height: 10 - tighten),
          _buildImage(),
        ],
        if (hasText) ...[
          // 사진 ↔ 글은 조금 넓게(14) — 헤더↔사진 10보다 한 단계 위(사용자 확정).
          SizedBox(height: (hasImage ? 14 : 10) - tighten),
          Text(
            item.description!,
            style: SDSTextStyle.regular.copyWith(
              // PC만 15로 키운다(사용자 확정) — 태블릿·모바일은 목업값 14 유지,
              // 폭 패스 때 함께 정리.
              fontSize: context.isDesktop ? 15 : 14,
              color: SDSColor.gray900,
              // 목업 lh 21 / 14.
              height: 1.5,
            ),
          ),
        ],
        // 본문 블록 ↔ 액션 줄 12.
        SizedBox(height: 12 - tighten),
        _buildActions(),
      ],
    );
  }

  Widget _buildHeader() {
    final userInfo = item.userInfo;
    final time = item.uploadTime != null ? GetDatetime().getAgoString(item.uploadTime!) : '';

    // 피그마 80:217026 — [아바타 30 + 12 + 이름 bold13] … 20 … [시간 + 12 + ⋯ 26].
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              WebProfileTap(
                userId: item.userId,
                name: userInfo?.displayName,
                avatarUrl: userInfo?.profileImageUrl,
                child: ClipOval(
                  child: (userInfo?.profileImageUrl?.isNotEmpty ?? false)
                      ? WebNetworkImage(
                          url: userInfo!.profileImageUrl,
                          width: 30,
                          height: 30,
                          fallback: _defaultAvatar(),
                        )
                      : _defaultAvatar(),
                ),
              ),
              // 아바타 ↔ 이름 10 (목업 12에서 줄임 — 사용자 확정, 세 폭 공통).
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  userInfo?.displayName ?? '익명',
                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Text(time, style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500)),
        const SizedBox(width: 12),
        // 아이콘 26 + 히트 여백 1 = 클릭 영역 28 (웹 공통 표준).
        // 색은 옆의 시간 텍스트와 동일(gray500).
        WebMoreButton(
          iconSize: 26,
          hitPadding: 1,
          iconColor: SDSColor.gray500,
          actions: moreActions,
          onSelected: onMoreAction,
        ),
      ],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      // 라운드 4 (피그마 80:217065).
      borderRadius: BorderRadius.circular(kLiveTalkFeedImageRadius),
      child: LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          // 상한을 열 너비 기준으로 잡아야 폭이 다른 세 브레이크포인트에서
          // 같은 비율 규칙이 적용된다.
          constraints: BoxConstraints(
            maxHeight: constraints.maxWidth * kLiveTalkFeedImageMaxRatio,
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTapImage,
              child: WebNetworkImage(
                url: item.imageUrl,
                width: double.infinity,
                // 폭을 항상 채운다 — 상한을 넘는 사진은 위아래가 잘린다(인스타 방식).
                fit: BoxFit.cover,
                // 원본 비율로 그리므로 크기를 미리 알 수 없다 — 로딩 동안 1:1로
                // 자리를 잡아두고, 받으면 원본 비율로 바뀐다(사용자 확정).
                placeholderAspectRatio: kLiveTalkFeedImageRatio,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    final isLiked = item.isLiked == true;
    final commentCount = item.commentCount ?? 0;
    // 숫자 색은 **아이콘 on/off와 같이 움직인다**(피그마 80:217034 — 좋아요는
    // 내가 눌렀을 때, 댓글은 댓글이 있을 때 검정). on이면 gray900 / off면 gray400.
    return Row(
      children: [
        LiveTalkCountButton(
          // 아이콘은 모바일 앱과 같은 에셋을 그대로 쓴다.
          asset: isLiked ? kLiveTalkLikeOnAsset : kLiveTalkLikeOffAsset,
          textColor: isLiked ? SDSColor.gray900 : SDSColor.gray400,
          count: item.likeCount ?? 0,
          onTap: onTapLike,
        ),
        // 카운트 버튼 사이 8 (피그마 80:217042).
        const SizedBox(width: 8),
        LiveTalkCountButton(
          asset: commentCount > 0 ? kLiveTalkReplyOnAsset : kLiveTalkReplyOffAsset,
          textColor: commentCount > 0 ? SDSColor.gray900 : SDSColor.gray400,
          count: commentCount,
          onTap: onTapComment,
        ),
      ],
    );
  }

  Widget _defaultAvatar() => Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(shape: BoxShape.circle, color: SDSColor.gray100),
        child: Icon(Icons.person, size: 18, color: SDSColor.gray400),
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
            // 아이콘 ↔ 숫자 2, 숫자 regular 13 (피그마 80:217037).
            const SizedBox(width: 2),
            Text('$count', style: SDSTextStyle.regular.copyWith(fontSize: 13, color: textColor)),
          ],
        ),
      ),
    );
  }
}
