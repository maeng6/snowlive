import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_liveTalk.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveTalkFeedItem extends StatelessWidget {
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final LiveTalk liveTalk;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onMore;

  LiveTalkFeedItem({
    Key? key,
    required this.liveTalk,
    required this.onLike,
    required this.onComment,
    required this.onMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F1F3), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 프로필 + 닉네임 + 시간 + 더보기
          _buildHeader(),

          // 중간: 이미지 (있는 경우)
          if (liveTalk.imageUrl != null && liveTalk.imageUrl!.isNotEmpty)
            _buildImage(),

          // 중간: 텍스트 본문 (있는 경우)
          if (liveTalk.description != null && liveTalk.description!.isNotEmpty)
            _buildContent(),

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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: _navigateToProfile,
            child: Container(
              width: 40,
              height: 40,
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
                        loadStateChanged: (state) {
                          if (state.extendedImageLoadState == LoadState.failed) {
                            return _buildDefaultAvatar();
                          }
                          return null;
                        },
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 닉네임
          GestureDetector(
            onTap: _navigateToProfile,
            child: Text(
              userInfo?.displayName ?? '익명',
              style: SDSTextStyle.bold.copyWith(
                fontSize: 14,
                color: SDSColor.gray900,
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
              fontSize: 12,
              color: SDSColor.gray500,
            ),
          ),

          // 더보기 버튼
          GestureDetector(
            onTap: onMore,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.more_horiz,
                color: SDSColor.gray400,
                size: 20,
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
          color: SDSColor.gray400,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: () {
        // TODO: 이미지 풀스크린 보기
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExtendedImage.network(
          liveTalk.imageUrl!,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          cache: true,
          loadStateChanged: (state) {
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                return Container(
                  height: 200,
                  color: SDSColor.gray100,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: SDSColor.gray300,
                      strokeWidth: 2,
                    ),
                  ),
                );
              case LoadState.failed:
                return Container(
                  height: 200,
                  color: SDSColor.gray100,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: SDSColor.gray400,
                      size: 48,
                    ),
                  ),
                );
              case LoadState.completed:
                return null;
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        liveTalk.description!,
        style: SDSTextStyle.regular.copyWith(
          fontSize: 15,
          color: SDSColor.gray900,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActions() {
    final isLiked = liveTalk.isLiked ?? false;
    final likeCount = liveTalk.likeCount ?? 0;
    final commentCount = liveTalk.commentCount ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 좋아요 버튼
          GestureDetector(
            onTap: onLike,
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? SDSColor.red : SDSColor.gray500,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  likeCount > 0 ? '$likeCount' : '좋아요',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: isLiked ? SDSColor.red : SDSColor.gray600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // 댓글 버튼
          GestureDetector(
            onTap: onComment,
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: SDSColor.gray500,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  commentCount > 0 ? '$commentCount' : '댓글',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.gray600,
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
