import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_nav_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kGnbSidebarWidth = 200;
// 접힘 시 항목 배경이 정확히 44x44 정사각형이 되도록:
// 좌우 여백 24 + 행 폭 44(패딩 10+아이콘 24+패딩 10) + 우측 보더 1 = 69.
const double kGnbSidebarCollapsedWidth = 69;

/// LNB 접힘 상태. 접히면 아이콘만 남고, 친구/설정(텍스트 전용)은 숨긴다.
final RxBool gnbSidebarCollapsed = false.obs;

/// 데스크탑(>=1024px) 전용 좌측 고정 사이드바.
/// 로고/로그인/회원가입은 상단 [WebGnbDesktopTopBar]가 전체 폭으로 담당하고,
/// 이 사이드바는 네비게이션 항목만 그린다.
class WebGnbSidebar extends StatelessWidget {
  const WebGnbSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool collapsed = gnbSidebarCollapsed.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: collapsed ? kGnbSidebarCollapsedWidth : kGnbSidebarWidth,
        decoration: BoxDecoration(
          color: SDSColor.snowliveWhite,
          border: Border(right: BorderSide(color: SDSColor.gray100)),
        ),
        // 폭이 줄어드는 동안 라벨이 삐져나오며 overflow 경고가 뜨지 않게 잘라낸다.
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in kGnbPrimaryItems)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GnbNavRow(item: item, collapsed: collapsed),
                ),
              if (!collapsed) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: SDSColor.gray100, height: 1),
                ),
                for (final item in kGnbSecondaryItems)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GnbNavRow(item: item),
                  ),
              ],
              const Spacer(),
              // 접기/펼치기 토글 버튼(원형, 1px 보더).
              // 좌측 오프셋 16(=12+4)에 고정하면 접힘 폭(69)에서 정확히 가운데가 되어
              // 접고 펼 때 버튼이 움직이지 않는다.
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    shape: CircleBorder(side: BorderSide(color: SDSColor.gray100)),
                    child: InkWell(
                      onTap: () => gnbSidebarCollapsed.toggle(),
                      customBorder: const CircleBorder(),
                      hoverColor: SDSColor.gray50,
                      // 클릭 시 스플래시/하이라이트 효과 제거.
                      splashFactory: NoSplash.splashFactory,
                      highlightColor: Colors.transparent,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          collapsed ? Icons.chevron_right : Icons.chevron_left,
                          size: 20,
                          color: SDSColor.gray700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
