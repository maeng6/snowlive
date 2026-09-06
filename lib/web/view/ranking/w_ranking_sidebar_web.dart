import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_tier_guide_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 좌측 여백(lg)을 포함한 폭. 콘텐츠 최대폭(kRankingContentMaxWidth) 안에서
/// 이 폭을 뺀 나머지가 목록 영역이 된다 — 중고거래 사이드바와 같은 구조.
const double kRankingSidebarWidth = 304;

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
      width: kRankingSidebarWidth,
      // 타이틀 줄(28px) + 아래 여백만큼 내려서 첫 카드가 탭/필터 줄과 나란히 오게 한다.
      padding: const EdgeInsets.only(left: SDSSpacing.lg, top: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RankingLinkCard(
            label: '랭킹 기록실',
            onTap: () => Get.toNamed(WebRoutes.rankingArchive),
          ),
          const SizedBox(height: 12),
          _RankingLinkCard(
            label: '랭킹 등급표 안내',
            onTap: () => showRankingTierGuide(context),
          ),
        ],
      ),
    );
  }
}

class _RankingLinkCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RankingLinkCard({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      // 회색 채움이 아니라 얇은 아웃라인 카드(목업). 테두리 색은 필터 pill의
      // 비활성 테두리와 같은 값으로 맞춘다.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: SDSColor.gray100),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
              ),
              Icon(Icons.chevron_right, size: 18, color: SDSColor.gray300),
            ],
          ),
        ),
      ),
    );
  }
}
