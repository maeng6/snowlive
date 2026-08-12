import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_current_route_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// GNB(사이드바/드로어)에 표시되는 항목 하나를 표현.
/// 전용 에셋이 없는 항목은 [materialIcon]을 임시로 사용하고,
/// 실제 아이콘 에셋이 있는 항목([assetIconOn]/[assetIconOff])은 그걸 우선한다.
class GnbNavItemData {
  final String label;
  final String? routePrefix;
  final IconData? materialIcon;
  final String? assetIconOn;
  final String? assetIconOff;

  /// "메뉴명"처럼 아직 정해지지 않은 자리표시자 항목은 true로 두면
  /// 탭 자체가 비활성화된다(다른 항목은 화면이 없어도 "준비 중" 안내는 뜬다).
  final bool isPlaceholder;

  const GnbNavItemData({
    required this.label,
    this.routePrefix,
    this.materialIcon,
    this.assetIconOn,
    this.assetIconOff,
    this.isPlaceholder = false,
  });
}

/// 1차 그룹: 홈 / 중고거래 / 각종소식 / 커뮤니티 / 라이브톡 / 랭킹 / 라이브크루
const List<GnbNavItemData> kGnbPrimaryItems = [
  GnbNavItemData(
    label: '홈',
    assetIconOn: 'assets/imgs/icons/icon_home_on.png',
    assetIconOff: 'assets/imgs/icons/icon_home_off.png',
  ),
  GnbNavItemData(
    label: '중고거래',
    routePrefix: '/fleamarket',
    assetIconOn: 'assets/imgs/icons/icon_market_on.png',
    assetIconOff: 'assets/imgs/icons/icon_market_off.png',
  ),
  GnbNavItemData(label: '각종소식', routePrefix: '/event', materialIcon: Icons.campaign_outlined),
  GnbNavItemData(label: '커뮤니티', routePrefix: '/community', materialIcon: Icons.forum_outlined),
  GnbNavItemData(label: '라이브톡', routePrefix: '/livetalk', materialIcon: Icons.podcasts_outlined),
  GnbNavItemData(label: '랭킹', routePrefix: '/ranking', materialIcon: Icons.emoji_events_outlined),
  GnbNavItemData(label: '라이브크루', materialIcon: Icons.groups_outlined),
];

/// 2차 그룹: 친구 / 메뉴명(placeholder) / 설정
const List<GnbNavItemData> kGnbSecondaryItems = [
  GnbNavItemData(
    label: '친구',
    materialIcon: Icons.person_outline,
    routePrefix: WebRoutes.friend,
  ),
  GnbNavItemData(
    label: '메뉴명',
    materialIcon: Icons.widgets_outlined,
    isPlaceholder: true,
  ),
  GnbNavItemData(
    label: '설정',
    assetIconOn: 'assets/imgs/icons/icon_settings.png',
    assetIconOff: 'assets/imgs/icons/icon_settings.png',
  ),
];

bool gnbItemIsActive(GnbNavItemData item, String currentRoute) {
  if (item.routePrefix == null) return false;
  return currentRoute.startsWith(item.routePrefix!);
}

/// 이미 들어와 있는 섹션의 메뉴를 다시 눌렀을 때 메인 목록을 새로고침한다.
///
/// 커뮤니티·각종소식 목록 화면은 StatefulWidget이라 [Get.offAllNamed]로 라우트가
/// 새로 생성되며 initState에서 알아서 재조회한다. 반면 중고거래 목록은
/// StatelessWidget이고 최초 로드가 뷰모델 onInit에서만 일어나므로, 재진입해도
/// 자동 갱신되지 않는다 → 여기서 뷰모델을 직접 다시 로드해준다.
void _reloadSectionList(String prefix) {
  if (prefix == WebRoutes.fleamarketList &&
      Get.isRegistered<FleamarketPaginationViewModelWeb>()) {
    Get.find<FleamarketPaginationViewModelWeb>()
        .loadFirstPage(userId: Get.find<UserViewModel>().user.user_id);
  }
}

/// 사이드바/드로어가 공유하는 항목 1개 행. 라우트가 있으면 이동하고,
/// 아직 화면이 없는 항목은 "준비 중" 스낵바만 띄운다. placeholder는 완전히 비활성.
class GnbNavRow extends StatelessWidget {
  final GnbNavItemData item;
  final VoidCallback? onNavigate;

  const GnbNavRow({super.key, required this.item, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool active = gnbItemIsActive(item, currentRouteWeb.value);
      final Color fg = item.isPlaceholder
          ? SDSColor.gray300
          : (active ? SDSColor.gray900 : SDSColor.gray700);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.isPlaceholder
              ? null
              : () {
                  final prefix = item.routePrefix;
                  if (prefix == null) {
                    Get.snackbar('준비 중입니다', '${item.label} 화면은 아직 준비 중이에요.');
                    onNavigate?.call();
                    return;
                  }
                  if (Get.currentRoute.startsWith(prefix)) {
                    // 이미 이 섹션 안(목록/상세 등)에 있으면 → 메인 목록으로 되돌리며 새로고침.
                    Get.offAllNamed(prefix);
                    _reloadSectionList(prefix);
                  } else {
                    Get.toNamed(prefix);
                  }
                  onNavigate?.call();
                },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: item.assetIconOn != null
                      ? Image.asset(
                          active ? item.assetIconOn! : item.assetIconOff!,
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        )
                      : Icon(item.materialIcon, size: 20, color: fg),
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: (active ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
                    fontSize: 15,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
