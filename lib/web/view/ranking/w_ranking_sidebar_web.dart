import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_tier_guide_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 데스크탑 전용 우측 열: "랭킹 기록실"/"랭킹 등급표 안내" 진입 카드.
///
/// 태블릿 이하에서는 이 열을 접는 대신 탭 줄 오른쪽의 텍스트 링크로 노출한다
/// (v_rankingHome_web.dart의 _buildTabRow). 둘 중 하나만 보이므로 진입 경로가
/// 중복되지도, 좁은 화면에서 사라지지도 않는다.
class RankingSidebarWeb extends StatelessWidget {
  const RankingSidebarWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kWebSidebarWidth,
      // 타이틀 줄(28px) + 아래 여백만큼 내려서 첫 카드가 탭/필터 줄과 나란히 오게 한다.
      padding: const EdgeInsets.only(top: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RankingLinkCard(
            label: '랭킹 기록실',
            onTap: () => Get.toNamed(WebRoutes.rankingArchive),
          ),
          const SizedBox(height: SDSSpacing.sm),
          _RankingLinkCard(
            label: '랭킹 등급표 안내',
            onTap: () => showRankingTierGuide(context),
          ),
        ],
      ),
    );
  }
}

class _RankingLinkCard extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _RankingLinkCard({required this.label, required this.onTap});

  @override
  State<_RankingLinkCard> createState() => _RankingLinkCardState();
}

class _RankingLinkCardState extends State<_RankingLinkCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // 크기는 중고거래 사이드바 버튼과 동일 — 폭 220(사이드바 전체),
    // 높이 webActionButtonHeight(PC 44 / 그 외 48), 라운드 6, bold 14.
    // 색은 회색 채움이 아니라 얇은 아웃라인 카드(목업)이고,
    // 테두리 색은 필터 pill의 비활성 테두리와 같은 값이다
    return SizedBox(
      height: webActionButtonHeight(context),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        // 평상시에는 그림자가 없고, hover에서 0 2 2 / 검정 6%(피그마 106:14774 값)가
        // 서서히 올라온다 (배경 틴트 대신 그림자로 반응하는 건 이 카드 전용).
        // 위치·번짐은 고정하고 불투명도만 0 → 6%로 움직여 카드가 뜨는 대신 스며들게 한다.
        // Material의 elevation 그림자는 모양이 달라서 직접 그린다.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: SDSColor.snowliveWhite,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.06 : 0),
                offset: const Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
          child: Material(
            // 배경은 위 AnimatedContainer가 그리므로 잉크만 받는다.
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: SDSColor.gray100),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              // hover 반응은 그림자가 담당한다 — 배경 틴트는 끈다.
              hoverColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(widget.label,
                          style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
                    ),
                    // 화살표는 피그마 값 20 (106:14779).
                    Icon(Icons.chevron_right, size: 20, color: SDSColor.gray300),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
