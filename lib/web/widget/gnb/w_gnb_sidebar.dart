import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_nav_items.dart';
import 'package:flutter/material.dart';

const double kGnbSidebarWidth = 240;

/// 데스크탑(>=1024px) 전용 좌측 고정 사이드바.
/// 로고/로그인/회원가입은 상단 [WebGnbDesktopTopBar]가 전체 폭으로 담당하고,
/// 이 사이드바는 네비게이션 항목만 그린다.
class WebGnbSidebar extends StatelessWidget {
  const WebGnbSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kGnbSidebarWidth,
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(right: BorderSide(color: SDSColor.gray100)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in kGnbPrimaryItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GnbNavRow(item: item),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: SDSColor.gray100, height: 1),
            ),
            for (final item in kGnbSecondaryItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GnbNavRow(item: item),
              ),
          ],
        ),
      ),
    );
  }
}
