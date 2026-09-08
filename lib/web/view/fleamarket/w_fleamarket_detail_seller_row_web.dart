import 'package:com.snowlive/core/api/api_fleamarket.dart';
import 'package:com.snowlive/core/api/api_user.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketMyActivity_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        WebProfileTap(
          userId: detail.userId,
          name: userInfo?.displayName,
          avatarUrl: userInfo?.profileImageUrlUser,
          child: ClipOval(
            child: (userInfo?.profileImageUrlUser?.isNotEmpty ?? false)
                ? WebNetworkImage(
                    url: userInfo!.profileImageUrlUser,
                    width: 32,
                    height: 32,
                    fallback: _defaultAvatar(),
                  )
                : _defaultAvatar(),
          ),
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
            // 찜한 상태는 같은 북마크 모양을 꽉 채운 에셋으로 구분한다(목업).
            icon: SvgPicture.asset(
              detail.isFavorite == true
                  ? 'assets/imgs/icons/icon_header_bookmark_fill_web.svg'
                  : 'assets/imgs/icons/icon_header_bookmark_web.svg',
              width: 22,
              height: 22,
            ),
          ),
        if (!isOwner)
          // 커뮤니티와 같은 공용 메뉴 — 데스크탑 앵커 드롭다운 / 태블릿 중앙 딤 /
          // 모바일 하단 딤 + 확인 다이얼로그. PopupMenuButton은 라우트 Navigator의
          // 오버레이를 써서 GNB 위로 못 올라가므로 쓰지 않는다.
          WebMoreButton(
            iconSize: 22,
            actions: const [WebMoreAction.report, WebMoreAction.hideUser],
            onSelected: (action) {
              final userId = userVm.user.user_id;
              if (userId == null) {
                Get.snackbar('알림', '로그인이 필요합니다.');
                return;
              }
              handleWebMoreAction(
                context,
                action: action,
                // core VM의 reportFleamarket / block_user는 내부에서 Get.back()을
                // 호출해 상세 라우트를 pop 시킨다 → API를 직접 부른다.
                onReport: () => mapWebActionResponse(
                  () => FleamarketAPI().reportFleamarket({
                    'user_id': userId,
                    'flea_id': detail.fleaId,
                  }),
                ),
                onHideUser: () => mapWebActionResponse(
                  () => UserAPI().blockUser({
                    'user_id': userId,
                    'block_user_id': detail.userId,
                  }),
                ),
              );
            },
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
