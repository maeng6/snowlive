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
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 판매자 아바타/이름 + 찜(북마크) 토글 + 공유(URL 복사) + 더보기(신고/차단) 메뉴.
/// 공유는 웹에서는 현재 페이지 URL 복사로 동작한다(피그마 46:12903).
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
                    width: 30,
                    height: 30,
                    fallback: _defaultAvatar(),
                  )
                : _defaultAvatar(),
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        Expanded(
          child: Text(
            userInfo?.displayName ?? '',
            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
          ),
        ),
        if (!isOwner)
          WebIconButton(
            onTap: () async {
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
            // 앱 상세와 동일한 스크랩 에셋 — 찜 상태는 _on으로 구분.
            icon: Image.asset(
              detail.isFavorite == true
                  ? 'assets/imgs/icons/icon_flea_appbar_scrap_on.png'
                  : 'assets/imgs/icons/icon_flea_appbar_scrap.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        // 아이콘 버튼 사이 간격 8.
        if (!isOwner) const SizedBox(width: 8),
        // 공유 — 상세 URL에 id가 실려 있어(딥링크 지원) 현재 주소가 곧 공유 링크다.
        // 소유자에게도 노출한다(자기 글 공유).
        WebIconButton(
          onTap: () async {
            await Clipboard.setData(
                ClipboardData(text: Uri.base.toString()));
            if (context.mounted) {
              showWebToast(context, '링크가 복사되었어요');
            }
          },
          // 앱 상세와 동일한 공유 에셋.
          icon: Image.asset(
            'assets/imgs/icons/icon_flea_appbar_share.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        if (!isOwner) const SizedBox(width: 8),
        if (!isOwner)
          // 커뮤니티와 같은 공용 메뉴 — 데스크탑 앵커 드롭다운 / 태블릿 중앙 딤 /
          // 모바일 하단 딤 + 확인 다이얼로그. PopupMenuButton은 라우트 Navigator의
          // 오버레이를 써서 GNB 위로 못 올라가므로 쓰지 않는다.
          WebMoreButton(
            iconSize: 24,
            // 앱 상세와 동일한 더보기 에셋.
            iconAsset: 'assets/imgs/icons/icon_flea_appbar_more.png',
            // 태블릿도 PC와 같은 앵커 드롭다운.
            dropdownOnTablet: true,
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
                // 호출해 상세 라우트를 pop 시킨다 → API를 직접 부른다
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
      width: 30,
      height: 30,
      decoration: BoxDecoration(shape: BoxShape.circle, color: SDSColor.gray100),
      child: Icon(Icons.person, size: 18, color: SDSColor.gray400),
    );
  }
}
