import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketMyActivity_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 판매자 아바타/이름 + 찜(북마크) 토글 + 더보기(신고/차단) 메뉴.
/// 모바일의 공유 버튼은 죽은 코드라 web에도 포함하지 않는다.
class FleamarketDetailSellerRowWeb extends StatelessWidget {
  final FleamarketDetailModel detail;

  const FleamarketDetailSellerRowWeb({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final detailVm = Get.find<FleamarketDetailViewModel>();
    final userVm = Get.find<UserViewModel>();
    final userInfo = detail.userInfo;
    final isOwner = detail.userId != null && detail.userId == userVm.user.user_id;

    return Row(
      children: [
        ClipOval(
          child: (userInfo?.profileImageUrlUser?.isNotEmpty ?? false)
              ? WebNetworkImage(
                  url: userInfo!.profileImageUrlUser,
                  width: 32,
                  height: 32,
                  fallback: _defaultAvatar(),
                )
              : _defaultAvatar(),
        ),
        const SizedBox(width: SDSSpacing.sm),
        Expanded(
          child: Text(
            userInfo?.displayName ?? '',
            style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
          ),
        ),
        if (!isOwner)
          IconButton(
            onPressed: () async {
              final userId = userVm.user.user_id;
              if (userId == null) {
                Get.snackbar('알림', '로그인이 필요합니다.');
                return;
              }
              if (detail.isFavorite == true) {
                await detailVm.deleteFavoriteFleamarket(fleamarketID: detail.fleaId, body: {'user_id': userId});
              } else {
                await detailVm.addFavoriteFleamarket(fleamarketID: detail.fleaId, body: {'user_id': userId});
              }
              // 우측 사이드바 "찜 목록"도 즉시 반영되도록 새로고침.
              Get.find<FleamarketMyActivityViewModel>().fetchMyActivity(userId: userId);
            },
            icon: Icon(
              detail.isFavorite == true ? Icons.bookmark : Icons.bookmark_border,
              color: SDSColor.gray900,
            ),
          ),
        if (!isOwner)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: SDSColor.gray900),
            onSelected: (value) {
              final userId = userVm.user.user_id;
              if (userId == null) {
                Get.snackbar('알림', '로그인이 필요합니다.');
                return;
              }
              if (value == 'report') {
                detailVm.reportFleamarket({'user_id': userId, 'flea_id': detail.fleaId});
              } else if (value == 'block') {
                userVm.block_user({'user_id': userId, 'block_user_id': detail.userId});
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'report', child: Text('신고하기')),
              PopupMenuItem(value: 'block', child: Text('이 회원의 모든 글 숨기기')),
            ],
          ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: SDSColor.gray100),
      child: Icon(Icons.person, size: 18, color: SDSColor.gray400),
    );
  }
}
