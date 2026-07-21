import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_liveTalk.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/view/community/liveTalk/v_liveTalk_imageScreen.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/liveTalk/vm_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class LiveTalkFeedItem extends StatelessWidget {
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final LiveTalkViewModel _liveTalkViewModel = Get.find<LiveTalkViewModel>();
  final LiveTalk liveTalk;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onMore;
  final bool isLast;

  LiveTalkFeedItem({
    Key? key,
    required this.liveTalk,
    required this.onLike,
    required this.onComment,
    required this.onMore,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: SDSColor.gray50, width: 1),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 프로필 + 닉네임 + 시간 + 더보기
          _buildHeader(),

          // 중간: 텍스트 본문 (있는 경우)
          if (liveTalk.description != null && liveTalk.description!.isNotEmpty)
            _buildContent(),

          // 중간: 이미지 (있는 경우)
          if (liveTalk.imageUrl != null && liveTalk.imageUrl!.isNotEmpty)
            _buildImage(context),

          // 하단: 좋아요 + 댓글
          _buildActions(),
        ],
      ),
    );
  }

  void _navigateToProfile() async {
    final userId = liveTalk.userId;
    if (userId == null) return;

    Get.toNamed(AppRoutes.friendDetail);
    await _friendDetailViewModel.fetchFriendDetailInfo(
      userId: _userViewModel.user.user_id,
      friendUserId: userId,
      season: _friendDetailViewModel.seasonDate,
    );
  }

  Widget _buildHeader() {
    final userInfo = liveTalk.userInfo;
    final uploadTime = liveTalk.uploadTime;

    return Padding(
      padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 6),
      child: Row(
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: _navigateToProfile,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SDSColor.gray100,
              ),
              child: ClipOval(
                child: userInfo?.profileImageUrl != null &&
                        userInfo!.profileImageUrl!.isNotEmpty
                    ? ExtendedImage.network(
                        userInfo.profileImageUrl!,
                        fit: BoxFit.cover,
                        cache: true,
                        cacheWidth: 90,
                        cacheHeight: 90,
                        loadStateChanged: (state) {
                          switch (state.extendedImageLoadState) {
                            case LoadState.loading:
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  color: Colors.white,
                                ),
                              );
                            case LoadState.failed:
                              return _buildDefaultAvatar();
                            case LoadState.completed:
                              return null;
                          }
                        },
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 닉네임
          GestureDetector(
            onTap: _navigateToProfile,
            child: Text(
              userInfo?.displayName ?? '익명',
              style: SDSTextStyle.bold.copyWith(
                fontSize: 14,
                color: SDSColor.snowliveBlack,
              ),
            ),
          ),

          // 공간 확보
          const Spacer(),

          // 시간
          Text(
            uploadTime != null
                ? GetDatetime().getAgoString(uploadTime)
                : '',
            style: SDSTextStyle.regular.copyWith(
              fontSize: 13,
              color: SDSColor.gray400,
            ),
          ),

          // 더보기 버튼
          GestureDetector(
            onTap: onMore,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                Icons.more_horiz,
                color: SDSColor.gray300,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: SDSColor.gray100,
      child: Center(
        child: Icon(
          Icons.person,
          color: SDSColor.gray300,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    const double maxHeight = 400;
    final imageUrl = liveTalk.imageUrl!;

    // 캐시된 크기가 있는지 확인
    final cachedSize = _liveTalkViewModel.getCachedImageSize(imageUrl);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveTalkImageScreen(
              imageUrls: [imageUrl],
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;

            // 캐시된 크기로 placeholder 높이 결정
            double placeholderHeight = 240;
            if (cachedSize != null) {
              placeholderHeight = cachedSize.height;
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ExtendedImage.network(
                imageUrl,
                cache: true,
                cacheHeight: 1600,
                loadStateChanged: (state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        period: const Duration(milliseconds: 1000),
                        child: Container(
                          width: maxWidth,
                          height: placeholderHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    case LoadState.failed:
                      return Container(
                        width: maxWidth,
                        height: placeholderHeight,
                        decoration: BoxDecoration(
                          color: SDSColor.gray100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: SDSColor.gray400,
                            size: 48,
                          ),
                        ),
                      );
                    case LoadState.completed:
                      final rawImage = state.extendedImageInfo?.image;
                      if (rawImage == null) return null;

                      final originalWidth = rawImage.width.toDouble();
                      final originalHeight = rawImage.height.toDouble();
                      final aspectRatio = originalWidth / originalHeight;

                      // 너비 기준으로 계산한 높이
                      final heightByWidth = maxWidth / aspectRatio;

                      double finalWidth;
                      double finalHeight;

                      if (heightByWidth > maxHeight) {
                        // 높이가 400을 넘으면 높이 400 기준으로 너비 계산
                        finalHeight = maxHeight;
                        finalWidth = maxHeight * aspectRatio;
                      } else {
                        // 높이가 400 이하면 너비 꽉 차게
                        finalWidth = maxWidth;
                        finalHeight = heightByWidth;
                      }

                      // 크기를 캐시에 저장 (다음 스크롤 시 사용)
                      _liveTalkViewModel.cacheImageSize(imageUrl, finalWidth, finalHeight);

                      return Center(
                        child: SizedBox(
                          width: finalWidth,
                          height: finalHeight,
                          child: ExtendedRawImage(
                            image: rawImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
      child: Text(
        liveTalk.description!,
        style: SDSTextStyle.regular.copyWith(
          fontSize: 15,
          color: SDSColor.snowliveBlack,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildActions() {
    final isLiked = liveTalk.isLiked ?? false;
    final likeCount = liveTalk.likeCount ?? 0;
    final commentCount = liveTalk.commentCount ?? 0;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 6),
      child: Row(
        children: [
          // 좋아요 버튼
          GestureDetector(
            onTap: onLike,
            child: Row(
              children: [
                SvgPicture.asset(
                  isLiked
                      ? 'assets/imgs/icons/icon_livetalk_like_on.svg'
                      : 'assets/imgs/icons/icon_livetalk_like_off.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 2),
                Text(
                  likeCount > 0 ? '$likeCount' : '좋아요',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: isLiked ? SDSColor.snowliveBlack : SDSColor.gray500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // 댓글 버튼
          GestureDetector(
            onTap: onComment,
            child: Row(
              children: [
                SvgPicture.asset(
                  commentCount > 0
                      ? 'assets/imgs/icons/icon_livetalk_reply_on.svg'
                      : 'assets/imgs/icons/icon_livetalk_reply_off.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 2),
                Text(
                  commentCount > 0 ? '$commentCount' : '댓글',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: SDSColor.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
