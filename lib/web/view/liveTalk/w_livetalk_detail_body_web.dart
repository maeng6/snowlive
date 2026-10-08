import 'dart:ui' as ui;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_feed_item_web.dart'
    show
        LiveTalkCountButton,
        kLiveTalkLikeOnAsset,
        kLiveTalkLikeOffAsset,
        kLiveTalkReplyOnAsset,
        kLiveTalkReplyOffAsset;
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:flutter/material.dart';

/// 라이브톡 글 하나를 보여주는 조각들. **상세 오버레이(PC·태블릿)와 모바일
/// 상세 화면이 공유**한다 — 한쪽만 고치면 규격이 갈라지므로 여기 모아둔다.

/// 사진 칸 배경 블러 세기. 너무 높이면 웹에서 무거워진다(버벅이면 20으로).
const double _kImagePaneBlur = 30;

/// 배경 블러를 노출 영역보다 이만큼 키운다. 블러는 가장자리가 흐려지며 옅어지는데,
/// 그 부분을 클립 밖으로 밀어내야 화면이 꽉 차 보인다.
const double _kImagePaneBlurScale = 1.2;

/// 블러 위에 덮는 딤(검정 45%) — 원본 사진이 묻히지 않게.
const Color _kImagePaneScrim = Color(0x73000000);

/// 사진(또는 라이딩 카드) 영역. 칸 비율과 사진 비율이 달라 남는 자리는
/// **같은 사진의 블러**로 채운다. 사진 자체는 `contain`이라 잘리지 않는다.
class LiveTalkImagePane extends StatelessWidget {
  final String? url;

  /// 사진을 넘겨 가며 보는 화면(크루 갤러리 뷰어)에서 켠다 — 다음 사진이 올 때까지
  /// 이전 프레임을 들고 있어 흰 깜빡임이 없다.
  final bool gaplessPlayback;

  const LiveTalkImagePane({super.key, required this.url, this.gaplessPlayback = false});

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    // ⚠️ ClipRect 필수 — 블러는 자식 경계 **바깥까지 번져서** 옆 패널을 침범한다
    // (카드 바깥 클립만으로는 형제 위젯을 못 막는다).
    return ClipRect(
      child: ColoredBox(
        // 블러 레이어가 아직/끝내 안 그려졌을 때의 바닥.
        color: SDSColor.snowliveWhite,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null && url.isNotEmpty) ...[
              // ⚠️ 여기엔 WebNetworkImage를 쓰지 않는다. 그 위젯은 CORS 실패 시
              // HTML <img> 폴백으로 넘어가는데, 플랫폼 뷰라 **블러가 안 걸린
              // 선명한 사진이 배경에 깔린다**. 바이트 경로 전용 Image.network를
              // 쓰고, 실패하면 조용히 사라져 위의 바닥색이 남게 한다.
              Transform.scale(
                scale: _kImagePaneBlurScale,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: _kImagePaneBlur,
                    sigmaY: _kImagePaneBlur,
                    tileMode: TileMode.clamp,
                  ),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
              // 블러가 화려하면 원본이 묻힌다 — 한 겹 눌러준다.
              const ColoredBox(color: _kImagePaneScrim),
            ],
            WebNetworkImage(
              url: url,
              fit: BoxFit.contain,
              gaplessPlayback: gaplessPlayback,
            ),
          ],
        ),
      ),
    );
  }
}

/// 글 헤더 — [아바타 32 + 10 + 이름] … [시간 + 12 + ⋯ 26] / 본문 / 좋아요·댓글 줄.
/// 규격은 피그마 80:220257(헤더행↔본문 10, 본문↔액션 12, 액션 사이 8).
class LiveTalkPostHeader extends StatelessWidget {
  final LiveTalk detail;

  /// 좌우·상하 여백. PC 24 / 태블릿·모바일 20.
  final double padding;

  /// 내 글이면 삭제, 남의 글이면 신고·숨기기.
  final bool isAuthor;
  final ValueChanged<WebMoreAction> onMoreAction;
  final VoidCallback onToggleLike;

  const LiveTalkPostHeader({
    super.key,
    required this.detail,
    required this.padding,
    required this.isAuthor,
    required this.onMoreAction,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    final userInfo = detail.userInfo;
    final time = detail.uploadTime != null
        ? GetDatetime().getAgoString(detail.uploadTime!)
        : '';
    final hasText =
        detail.description != null && detail.description!.trim().isNotEmpty;
    final isLiked = detail.isLiked == true;
    final commentCount = detail.commentCount ?? 0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WebProfileTap(
                userId: detail.userId,
                name: userInfo?.displayName,
                avatarUrl: userInfo?.profileImageUrl,
                child: ClipOval(
                  child: (userInfo?.profileImageUrl?.isNotEmpty ?? false)
                      ? WebNetworkImage(
                          url: userInfo!.profileImageUrl,
                          width: 32,
                          height: 32,
                          fallback: const _DefaultAvatar(),
                        )
                      : const _DefaultAvatar(),
                ),
              ),
              // 아바타 ↔ 이름 10 — 피드 카드와 같은 값(사용자 확정).
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  userInfo?.displayName ?? '익명',
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 13,
                    color: SDSColor.gray900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                time,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 13,
                  color: SDSColor.gray500,
                ),
              ),
              // 시간 ↔ ⋯ 12, ⋯ 26(클릭 영역 28) — 피드 카드와 동일.
              const SizedBox(width: 12),
              WebMoreButton(
                iconSize: 26,
                hitPadding: 1,
                iconColor: SDSColor.gray500,
                actions: isAuthor
                    ? const [WebMoreAction.edit, WebMoreAction.delete]
                    : const [WebMoreAction.reportPost, WebMoreAction.hideUser],
                onSelected: onMoreAction,
              ),
            ],
          ),
          if (hasText) ...[
            const SizedBox(height: 10),
            Text(
              detail.description!,
              style: SDSTextStyle.regular.copyWith(
                fontSize: 14,
                color: SDSColor.gray900,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              // 피드와 같은 버튼·에셋·색 규칙(숫자 색 = 아이콘 on/off와 동일).
              LiveTalkCountButton(
                asset: isLiked ? kLiveTalkLikeOnAsset : kLiveTalkLikeOffAsset,
                textColor: isLiked ? SDSColor.gray900 : SDSColor.gray400,
                count: detail.likeCount ?? 0,
                onTap: onToggleLike,
              ),
              const SizedBox(width: 8),
              LiveTalkCountButton(
                asset: commentCount > 0
                    ? kLiveTalkReplyOnAsset
                    : kLiveTalkReplyOffAsset,
                textColor: commentCount > 0
                    ? SDSColor.gray900
                    : SDSColor.gray400,
                count: commentCount,
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SDSColor.gray100,
      ),
      child: Icon(Icons.person, size: 18, color: SDSColor.gray400),
    );
  }
}
