import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkBadge_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_nav_items.dart'
    show GnbNavItemData, GnbLiveTalkDot, kGnbPrimaryItems, openGnbSection;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// 홈 **퀵메뉴**(태블릿·모바일 전용). 데스크탑은 좌측 사이드바가 그 역할을 한다.
///
/// 라벨·라우트·아이콘은 GNB 메뉴([kGnbPrimaryItems])에서 **그대로 가져온다** —
/// 메뉴와 두 군데서 따로 적으면 이름이 갈린다.
///
/// 배치: 날씨/오늘의 랭킹 **아래, 중고거래 위**(비시즌엔 랭킹이 없으니 날씨 바로 아래).
///
/// 한 줄 구성은 폭에 따라 갈린다 — **태블릿은 6개 한 줄**, **모바일은 3개씩 두 줄**이다.
/// 모바일 375에서 6개를 한 줄에 넣으면 칸이 56px밖에 안 돼 `라이브크루`(5자)가
/// 11px까지 줄어야 들어간다(실측) → 글자를 읽을 수 있게 두 줄로 나눈다.
class HomeQuickMenuWeb extends StatelessWidget {
  /// 퀵메뉴에 올리는 섹션(사용자 확정 순서).
  static const List<String> prefixes = [
    '/fleamarket',
    '/event',
    '/community',
    '/livetalk',
    '/ranking',
    '/livecrew',
  ];

  /// 퀵메뉴 **전용 아이콘**(route prefix → 에셋). GNB 메뉴 아이콘을 복사해
  /// 따로 둔다(사용자 확정) — 가운데 면에 색을 넣는 등 퀵메뉴만 손볼 수 있어야
  /// 하는데, 같은 파일을 쓰면 사이드바·드로어까지 같이 바뀐다.
  static const Map<String, String> iconAssets = {
    '/fleamarket': 'assets/imgs/icons/quickmenu/icon_quick_fleamarket.svg',
    '/event': 'assets/imgs/icons/quickmenu/icon_quick_news.svg',
    '/community': 'assets/imgs/icons/quickmenu/icon_quick_community.svg',
    '/livetalk': 'assets/imgs/icons/quickmenu/icon_quick_livetalk.svg',
    '/ranking': 'assets/imgs/icons/quickmenu/icon_quick_ranking.svg',
    '/livecrew': 'assets/imgs/icons/quickmenu/icon_quick_crew.svg',
  };

  /// 한 줄 높이 — GNB 메뉴 줄(44)보다 넉넉하게 52(사용자 확정).
  static const double rowHeight = 52;

  const HomeQuickMenuWeb({super.key});

  static List<GnbNavItemData> get _items => [
    for (final prefix in prefixes)
      kGnbPrimaryItems.firstWhere((item) => item.routePrefix == prefix),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final items = _items;
    // 모바일은 3개씩 두 줄, 태블릿은 6개 한 줄.
    final perRow = isMobile ? 3 : items.length;
    final rows = <List<GnbNavItemData>>[
      for (var i = 0; i < items.length; i += perRow)
        items.sublist(i, i + perRow > items.length ? items.length : i + perRow),
    ];

    return Container(
      decoration: BoxDecoration(
        // 배경 gray50(사용자 확정) + 다른 홈 블록과 같은 라운드 10.
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        // 띠 높이는 줄 수만큼만 — 부모가 높이를 넉넉히 주면 늘어나지 않게 못 박는다.
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            // 줄 사이 구분선 — 1px. 세로 구분선과 **같은 두께·같은 토큰(gray200)**인데
            // 가로로 꽉 차서 더 진해 보인다 → 한 톤 연한 gray100으로 맞춘다(사용자 확정).
            if (r > 0)
              Divider(height: 1, thickness: 1, color: SDSColor.gray100),
            SizedBox(
              height: rowHeight,
              child: Padding(
                // 띠 좌우 끝 여백 — 모바일 8 / 태블릿 20(사용자 확정, 16/36에서 줄임).
                // 칸이 그만큼 넓어진다. 줄 사이 가로선은 여백 없이 꽉 채운다.
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 20),
                child: Row(
                  // 칸은 **모두 같은 너비**(사용자 확정) — 남은 폭을 `Expanded`로
                  // 균등 분배하고 내용은 칸 가운데에 둔다. 항목 사이 1×16 gray200
                  // 세로선은 칸 경계에 선다.
                  //
                  // 참고: 이 방식은 띠의 좌우 패딩을 바꿔도 첫/마지막 항목이 크게
                  // 움직이지 않는다(칸이 넓어지며 가운데가 되돌아온다). 끝 여백을
                  // 눈에 보이게 하려면 `spaceBetween` + 내용 폭 방식으로 돌리면 된다.
                  children: [
                    for (var i = 0; i < rows[r].length; i++) ...[
                      if (i > 0)
                        Container(
                          width: 1,
                          height: 16,
                          color: SDSColor.gray200,
                        ),
                      Expanded(child: _QuickCell(item: rows[r][i])),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 퀵메뉴 한 칸 — GNB 메뉴 줄과 같은 구성(아이콘 24 + 간격 6 + Bold 라벨 gray700).
class _QuickCell extends StatelessWidget {
  final GnbNavItemData item;

  const _QuickCell({required this.item});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    // 메뉴 에셋이 아니라 퀵메뉴 전용 복사본을 쓴다([HomeQuickMenuWeb.iconAssets]).
    final svg = HomeQuickMenuWeb.iconAssets[item.routePrefix];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          openGnbSection(item.routePrefix!);
          // 라이브톡 진입 시 읽음 처리(빨간 점 끄기).
          if (item.showsLiveTalkDot && Get.isRegistered<LiveTalkBadgeWeb>()) {
            LiveTalkBadgeWeb.to.markSeen();
          }
        },
        // hover는 웹 공통 — 연회색 면(gray50)에 검정 4%만 덧칠한다.
        hoverColor: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svg != null) ...[
              // 아이콘 + (라이브톡이면) 우상단 새 글 빨간점.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(svg,
                      width: 24, height: 24, fit: BoxFit.contain),
                  if (item.showsLiveTalkDot)
                    const Positioned(
                      right: -2,
                      top: -2,
                      child: GnbLiveTalkDot(padLeft: false),
                    ),
                ],
              ),
              // 아이콘 ↔ 라벨 4(사용자 확정, 6에서 줄임).
              const SizedBox(width: 4),
            ],
            // 폭이 모자라도 자르지 않고 간격 쪽으로 넘긴다(끝 글자가 사라지는 것보다 낫다).
            Text(
              item.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              // GNB 메뉴와 같은 Bold(사용자 확정 — Medium 폰트 에셋이 없어
              // w500을 지정해도 Flutter가 가까운 w600으로 떨어진다).
              style: SDSTextStyle.bold.copyWith(
                fontSize: isMobile ? 13 : 14,
                color: SDSColor.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
