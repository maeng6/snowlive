import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_current_route_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  /// 웹 전용 벡터 아이콘 쌍. 있으면 이걸 먼저 쓴다(배율에 상관없이 선명하다).
  /// 활성은 채워진 `_select`, 비활성은 외곽선 버전이다.
  final String? assetIconSvgOn;
  final String? assetIconSvgOff;

  /// "메뉴명"처럼 아직 정해지지 않은 자리표시자 항목은 true로 두면
  /// 탭 자체가 비활성화된다(다른 항목은 화면이 없어도 "준비 중" 안내는 뜬다).
  final bool isPlaceholder;

  const GnbNavItemData({
    required this.label,
    this.routePrefix,
    this.materialIcon,
    this.assetIconOn,
    this.assetIconOff,
    this.assetIconSvgOn,
    this.assetIconSvgOff,
    this.isPlaceholder = false,
  });
}

/// 1차 그룹: 홈 / 중고거래 / 각종소식 / 커뮤니티 / 라이브톡 / 랭킹 / 라이브크루 /
/// 슬로프크래프트 / 라이딩 기록 카드
const List<GnbNavItemData> kGnbPrimaryItems = [
  GnbNavItemData(
    label: '홈',
    routePrefix: WebRoutes.home,
    assetIconSvgOn: 'assets/imgs/icons/icon_web_home_select.svg',
    assetIconSvgOff: 'assets/imgs/icons/icon_web_home.svg',
  ),
  GnbNavItemData(
    label: '중고거래',
    routePrefix: '/fleamarket',
    assetIconSvgOn: 'assets/imgs/icons/icon_web_fleamarket_select.svg',
    assetIconSvgOff: 'assets/imgs/icons/icon_web_fleamarket.svg',
  ),
  GnbNavItemData(
    label: '각종소식',
    routePrefix: '/event',
    assetIconSvgOn: 'assets/imgs/icons/icon_web_news_select.svg',
    assetIconSvgOff: 'assets/imgs/icons/icon_web_news.svg',
  ),
  GnbNavItemData(
    label: '커뮤니티',
    routePrefix: '/community',
    assetIconSvgOn: 'assets/imgs/icons/icon_web_community_select.svg',
    assetIconSvgOff: 'assets/imgs/icons/icon_web_community.svg',
  ),
  GnbNavItemData(
    label: '라이브톡',
    routePrefix: '/livetalk',
    assetIconSvgOn: 'assets/imgs/icons/icon_web_livetalk_select.svg',
    assetIconSvgOff: 'assets/imgs/icons/icon_web_livetalk.svg',
  ),
  GnbNavItemData(
    label: '랭킹',
    routePrefix: '/ranking',
    assetIconSvgOn: 'assets/imgs/icons/icon_web_ranking_select.svg',
    assetIconSvgOff: 'assets/imgs/icons/icon_web_ranking.svg',
  ),
  GnbNavItemData(
    label: '라이브크루',
    routePrefix: '/livecrew',
    assetIconSvgOn: 'assets/imgs/icons/icon_web_crew_select.svg',
    assetIconSvgOff: 'assets/imgs/icons/icon_web_crew.svg',
  ),
  GnbNavItemData(
    label: '슬로프크래프트',
    routePrefix: '/slopecraft',
    assetIconSvgOn: 'assets/imgs/icons/icon_web_slopecraft_select.svg',
    assetIconSvgOff: 'assets/imgs/icons/icon_web_slopecraft.svg',
  ),
  GnbNavItemData(
    label: '라이딩 기록 카드',
    routePrefix: '/riding-cards',
    assetIconSvgOn: 'assets/imgs/icons/icon_web_ridingcard_select.svg',
    assetIconSvgOff: 'assets/imgs/icons/icon_web_ridingcard.svg',
  ),
];

/// 2차 그룹: 친구 / 설정.
/// 목업대로 **아이콘 없이 텍스트만** 쓴다(1차 그룹만 아이콘을 갖는다).
const List<GnbNavItemData> kGnbSecondaryItems = [
  GnbNavItemData(label: '친구', routePrefix: WebRoutes.friend),
  GnbNavItemData(label: '설정', routePrefix: WebRoutes.settings),
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
      final Widget? icon = _buildIcon(item, active: active, fg: fg);

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
                // 아이콘이 없는 항목(친구·설정)은 자리도 비우지 않고 글자만 둔다.
                if (icon != null) ...[
                  SizedBox(width: 22, height: 22, child: icon),
                  const SizedBox(width: 12),
                ],
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

  /// 아이콘 우선순위: 웹 벡터 쌍 → PNG on/off 쌍 → 머티리얼 아이콘.
  ///
  /// 벡터는 색을 덧칠하지 않는다 — 활성/비활성이 **채움 vs 외곽선**으로 이미
  /// 구분되고, 슬로프크래프트·라이브톡처럼 안쪽에 흰 채움이 있는 그림은 단색으로
  /// 덧칠하면 그 겹침이 사라진다.
  /// 아이콘이 지정되지 않은 항목은 null을 돌려준다(2차 그룹은 텍스트만).
  Widget? _buildIcon(GnbNavItemData item, {required bool active, required Color fg}) {
    final svgOff = item.assetIconSvgOff;
    if (svgOff != null) {
      final svg = active ? (item.assetIconSvgOn ?? svgOff) : svgOff;
      final icon = SvgPicture.asset(svg, width: 22, height: 22, fit: BoxFit.contain);
      return item.isPlaceholder ? Opacity(opacity: 0.35, child: icon) : icon;
    }
    if (item.assetIconOn != null) {
      return Image.asset(
        active ? item.assetIconOn! : item.assetIconOff!,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
      );
    }
    final materialIcon = item.materialIcon;
    if (materialIcon == null) return null;
    return Icon(materialIcon, size: 20, color: fg);
  }
}
