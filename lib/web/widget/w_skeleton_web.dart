import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/w_community_row_web.dart' show communityTableRowShell, CommunityMetaWidths;
import 'package:com.snowlive/web/view/community/w_event_row_web.dart' show eventTableRowShell, EventMetaWidths;
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_feed_item_web.dart'
    show
        kLiveTalkFeedImageRadius,
        kLiveTalkFeedImageRatio,
        liveTalkFeedItemGap;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart' show kFleamarketPhotoRadius;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_grid_web.dart'
    show FleamarketGridLayout, kFleamarketCardTextBlockHeight;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// 로딩 자리표시(스켈레톤) 위젯 모음.
///
/// 화면 중앙 스피너 대신 "곧 나올 콘텐츠의 형태"를 미리 그려두는 방식으로,
/// 데이터가 도착했을 때 레이아웃이 튀지 않고 체감 대기시간도 짧아진다.
///
/// ⚠️ [SkeletonShimmer]는 **섹션당 하나만** 쓸 것. 카드 30개를 각각 감싸면
/// AnimationController가 30개 생긴다. 합성 스켈레톤들은 루트에서 한 번만 감싸고
/// 내부는 [SkeletonBox]/[SkeletonLine]만 사용한다.

/// 스켈레톤 색/애니메이션의 단일 출처.
///
/// 바탕 **gray200(#DEDEDE)** ↔ 반짝임 **gray100(#EFEFEF)**.
/// 반짝임을 gray50(#F5F5F5)에서 한 단계 내려 흰색처럼 튀지 않게 했고, 두 색 차이도
/// 23/255 → 17/255로 줄여 **은은하게** 흐른다.
class SkeletonShimmer extends StatelessWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: SDSColor.gray200,
      highlightColor: SDSColor.gray100,
      child: child,
    );
  }
}

/// 스켈레톤 조각 하나. 반드시 [SkeletonShimmer] 하위에서 사용한다.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final bool isCircle;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 4,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Shimmer가 자식의 불투명 픽셀을 마스크로 쓰므로 색 자체는 무엇이든 상관없다.
        color: SDSColor.snowliveWhite,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// 텍스트 한 줄 자리표시.
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonLine({super.key, this.width, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(width: width, height: height, radius: 3);
  }
}

/// 중고거래 상품 그리드 자리표시.
/// 열 수/간격/상단 여백은 실제 그리드와 같은 [FleamarketGridLayout]에서 가져온다 —
/// 여기가 어긋나면 데이터 도착 시 레이아웃이 튄다.
class FleamarketGridSkeleton extends StatelessWidget {
  final int itemCount;

  const FleamarketGridSkeleton({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout =
              FleamarketGridLayout.of(context.screenType, constraints.maxWidth);
          final cellWidth = layout.cellWidth;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: layout.topPadding),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: layout.crossAxisCount,
              crossAxisSpacing: layout.spacing,
              mainAxisSpacing: layout.runSpacing,
              mainAxisExtent: cellWidth + kFleamarketCardTextBlockHeight,
            ),
            itemBuilder: (context, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 라운드는 실제 썸네일(kFleamarketPhotoRadius)과 동일해야
                // 데이터 도착 시 모서리가 튀지 않는다.
                SkeletonBox(
                    width: cellWidth,
                    height: cellWidth,
                    radius: kFleamarketPhotoRadius),
                const SizedBox(height: 10),
                const SkeletonLine(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                SkeletonLine(width: cellWidth * 0.6, height: 12),
                const SizedBox(height: 10),
                SkeletonLine(width: cellWidth * 0.45, height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 커뮤니티 목록 자리표시. 실제 화면과 같은 규칙으로 모바일은 카드형, 그 외는
/// 표형 골격을 그린다(열 폭이 어긋나면 데이터 도착 시 레이아웃이 튄다).
class CommunityListSkeleton extends StatelessWidget {
  final int rowCount;

  const CommunityListSkeleton({super.key, this.rowCount = 8});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    // 셔머 컨트롤러는 섹션당 1개만 — 행마다 감싸면 컨트롤러가 rowCount개가 된다.
    return SkeletonShimmer(
      child: Column(
        children: List.generate(
          rowCount,
          (_) => isMobile ? const _CommunityCardRowSkeleton() : const _CommunityTableRowSkeleton(),
        ),
      ),
    );
  }
}

class _CommunityTableRowSkeleton extends StatelessWidget {
  const _CommunityTableRowSkeleton();

  @override
  Widget build(BuildContext context) {
    // 실제 행과 동일 규격 — 행 높이 52 고정, 배지 20(간격 12), 제목 15, 메타 14.
    return communityTableRowShell(
      // 데이터가 오면 실제 값으로 다시 잡히므로, 그때 열이 크게 안 움직이도록
      // 표본 기준 폭을 쓴다. 메타 자리는 열을 꽉 채워 폭이 바뀌어도 안 넘친다.
      widths: CommunityMetaWidths.skeleton,
      rowHeight: 52,
      border: Border(bottom: BorderSide(color: SDSColor.gray100)),
      titleCell: Row(
        children: const [
          SkeletonBox(width: 42, height: 20),
          SizedBox(width: 12),
          Expanded(child: SkeletonLine(height: 15)),
        ],
      ),
      authorCell: const SkeletonLine(height: 14),
      dateCell: const SkeletonLine(height: 14),
      viewsCell: const SkeletonLine(height: 14),
    );
  }
}

class _CommunityCardRowSkeleton extends StatelessWidget {
  const _CommunityCardRowSkeleton();

  @override
  Widget build(BuildContext context) {
    // 실제 카드 행과 동일 규격 — 패딩 13, 배지 20(간격 12), 제목 15,
    // 제목↔메타 10, 메타 13.
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: SDSColor.gray100))),
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    SkeletonBox(width: 42, height: 20),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonLine(height: 15)),
                  ],
                ),
                SizedBox(height: 10),
                SkeletonLine(width: 180, height: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 각종소식 목록 자리표시. 표 열 구성이 커뮤니티와 달라(분류·이름 열, 제목 우측
/// 정사각 썸네일) 실제와 같은 [eventTableRowShell]로 골격을 그린다.
class EventListSkeleton extends StatelessWidget {
  final int rowCount;

  const EventListSkeleton({super.key, this.rowCount = 8});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    return SkeletonShimmer(
      child: Column(
        children: List.generate(
          rowCount,
          (_) => isMobile ? const _EventCardRowSkeleton() : const _EventTableRowSkeleton(),
        ),
      ),
    );
  }
}

class _EventCardRowSkeleton extends StatelessWidget {
  const _EventCardRowSkeleton();

  @override
  Widget build(BuildContext context) {
    // 실제 카드와 동일 규격 — 패딩 13, 칩 20(간격 8), 제목 15,
    // 제목↔메타 10, 메타 13, 우측 정사각 썸네일 40.
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: SDSColor.gray100))),
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 42, height: 20),
                    SizedBox(width: 8),
                    Expanded(child: SkeletonLine(height: 15)),
                  ],
                ),
                SizedBox(height: 10),
                SkeletonLine(width: 180, height: 13),
              ],
            ),
          ),
          // 실제 카드 썸네일(제목 2줄 + 10 + 메타 16 고정) 근사값.
          SizedBox(width: 16),
          SkeletonBox(width: 68, height: 68),
        ],
      ),
    );
  }
}

class _EventTableRowSkeleton extends StatelessWidget {
  const _EventTableRowSkeleton();

  @override
  Widget build(BuildContext context) {
    // 실제 행과 동일 규격 — 행 높이 52 고정, 분류 칩 20(hug), 이름 14,
    // 제목 15 + 우측 정사각 썸네일 30, 메타 14.
    return eventTableRowShell(
      widths: EventMetaWidths.skeleton,
      rowHeight: 52,
      border: Border(bottom: BorderSide(color: SDSColor.gray100)),
      categoryCell: Row(children: const [SkeletonBox(width: 42, height: 20)]),
      nameCell: const SkeletonLine(height: 14),
      titleCell: Row(
        children: const [
          Expanded(child: SkeletonLine(height: 15)),
          SizedBox(width: 8),
          SkeletonBox(width: 30, height: 30),
        ],
      ),
      dateCell: const SkeletonLine(height: 14),
      viewsCell: const SkeletonLine(height: 14),
    );
  }
}

/// 라이브톡 피드 자리표시. 표형이 아니라 SNS 피드형이라 전용으로 둔다.
/// 실제 카드 순서대로 [아바타 30 + 이름] → **사진(1:1, 라운드 4)** → 본문 →
/// 액션 줄을 그린다 — 사진 있는 글이 대부분이라 사진 자리를 비워두면 데이터
/// 도착 시 목록이 크게 밀린다. 비율은 실제로는 원본대로라 1:1은 어림값이고,
/// 실제 카드의 로딩 자리표시(`WebNetworkImage.placeholderAspectRatio`)와 **같은
/// 값이어야 한다** — 다르면 스켈레톤에서 사진으로 넘어갈 때 크기가 튄다.
class LiveTalkFeedSkeleton extends StatelessWidget {
  final int itemCount;

  const LiveTalkFeedSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    // 셔머 컨트롤러는 섹션당 1개만 — 카드마다 감싸면 컨트롤러가 itemCount개가 된다.
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            // 실제 카드와 같은 간격.
            if (i > 0) SizedBox(height: liveTalkFeedItemGap(context)),
            const _LiveTalkFeedItemSkeleton(),
          ],
        ],
      ),
    );
  }
}

class _LiveTalkFeedItemSkeleton extends StatelessWidget {
  const _LiveTalkFeedItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            SkeletonBox(width: 30, height: 30, isCircle: true),
            SizedBox(width: 12),
            SkeletonLine(width: 70, height: 13),
            Spacer(),
            SkeletonLine(width: 60, height: 13),
          ],
        ),
        // 헤더 ↔ 사진 10. 비율·라운드는 실제 카드의 로딩 자리표시와 같은 상수를 쓴다
        // (다르면 스켈레톤 → 사진으로 넘어갈 때 크기가 튄다).
        const SizedBox(height: 10),
        const AspectRatio(
          aspectRatio: kLiveTalkFeedImageRatio,
          child: SkeletonBox(radius: kLiveTalkFeedImageRadius),
        ),
        // 사진 ↔ 글 14.
        const SizedBox(height: 14),
        const SkeletonLine(width: double.infinity, height: 14),
        const SizedBox(height: 6),
        const SkeletonLine(width: 220, height: 14),
        const SizedBox(height: 12),
        const Row(
          children: [
            SkeletonLine(width: 44, height: 20),
            SizedBox(width: 8),
            SkeletonLine(width: 44, height: 20),
          ],
        ),
      ],
    );
  }
}

/// 랭킹 리스트 자리표시. 데스크탑은 실제 화면과 동일하게 2단으로 그린다.
/// 랭킹 목록 행 규격. 실제 행과 스켈레톤이 **같은 값**을 써야 로딩 → 데이터 전환에서
/// 목록 길이가 안 튄다.
///
/// 모바일은 목업(106:30699)이 더 촘촘하다 — 행 36 + 간격 14 = 피치 50, 아바타 32,
/// 순위↔아바타 6 / 아바타↔이름 10, 이름 14 / 소속 12 / 점수 15.
/// PC·태블릿은 사용자가 눈으로 키운 값(아바타 36, 간격 12/12, 이름 15 / 소속 13 / 점수 16).
class RankingRowMetrics {
  final double contentHeight;
  final double verticalPadding;
  final double avatar;
  final double rankGap;
  final double nameGap;
  final double nameSize;
  final double subSize;
  final double scoreSize;

  const RankingRowMetrics._({
    required this.contentHeight,
    required this.verticalPadding,
    required this.avatar,
    required this.rankGap,
    required this.nameGap,
    required this.nameSize,
    required this.subSize,
    required this.scoreSize,
  });

  /// 패딩까지 포함한 행 박스 높이(hover 박스 크기이기도 하다).
  double get boxHeight => contentHeight + verticalPadding * 2;

  static const _mobile = RankingRowMetrics._(
    contentHeight: 36,
    verticalPadding: 3,
    avatar: 32,
    rankGap: 6,
    nameGap: 10,
    nameSize: 14,
    subSize: 12,
    scoreSize: 15,
  );

  static const _wide = RankingRowMetrics._(
    contentHeight: 38,
    verticalPadding: 6,
    avatar: 36,
    rankGap: 12,
    nameGap: 12,
    nameSize: 15,
    subSize: 13,
    scoreSize: 16,
  );

  static RankingRowMetrics of(BuildContext context) =>
      context.screenType == WebScreenType.mobile ? _mobile : _wide;
}

class RankingListSkeleton extends StatelessWidget {
  final int rowCount;

  /// 개인은 원형 프로필, 크루는 라운드 8 로고.
  final bool circleAvatar;

  /// 티어 자리를 그릴지. 랭킹 홈의 **크루 랭킹만 티어가 없다**(사양).
  final bool showTier;

  /// 기록실은 이름/소속/점수가 14·12·15로 홈(15·13·16)보다 한 단계 작다.
  final bool compactText;

  const RankingListSkeleton({
    super.key,
    this.rowCount = 10,
    this.circleAvatar = true,
    this.showTier = true,
    this.compactText = false,
  });

  @override
  Widget build(BuildContext context) {
    // 목록이 1열이라 스켈레톤도 한 열로 쌓는다(폭 상관없이 동일).
    // 위쪽 여백은 두지 않는다 — 실제 목록도 0이라, 여백이 있으면 로딩 → 데이터
    // 전환에서 목록이 그만큼 위로 올라붙는다(랭킹 홈·기록실 둘 다 해당).
    return SkeletonShimmer(
      child: Column(
        children: List.generate(
          rowCount,
          (_) => _RankingRowSkeleton(
            circleAvatar: circleAvatar,
            showTier: showTier,
            compactText: compactText,
          ),
        ),
      ),
    );
  }
}

class _RankingRowSkeleton extends StatelessWidget {
  final bool circleAvatar;
  final bool showTier;
  final bool compactText;

  const _RankingRowSkeleton({
    required this.circleAvatar,
    required this.showTier,
    required this.compactText,
  });

  @override
  Widget build(BuildContext context) {
    // 실제 행과 같은 규격 — [RankingRowMetrics]가 폭별 값을 들고 있다.
    final m = RankingRowMetrics.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: m.verticalPadding),
        height: m.boxHeight,
        child: Row(
          children: [
            const SkeletonBox(width: 18, height: 14),
            SizedBox(width: m.rankGap),
            // 개인은 원형 프로필, 크루는 라운드 5 로고(실제 행·카드와 동일).
            SkeletonBox(width: m.avatar, height: m.avatar, isCircle: circleAvatar, radius: 5),
            SizedBox(width: m.nameGap),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: 96, height: compactText ? m.nameSize - 1 : m.nameSize),
                  const SizedBox(height: 4),
                  SkeletonLine(width: 140, height: compactText ? m.subSize - 1 : m.subSize),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SkeletonLine(width: 66, height: compactText ? m.scoreSize - 1 : m.scoreSize),
            // 티어는 자리만 비워둔다 — 셔머 박스를 두면 아이콘이 아니라
            // 사각 썸네일이 오는 것처럼 보인다(사용자 결정).
            if (showTier) const SizedBox(width: 8 + 36),
          ],
        ),
      ),
    );
  }
}

/// "내 랭킹 / 내 크루 랭킹" 카드 자리표시.
/// 실제 카드와 **같은 높이·여백**이어야 데이터 도착 시 아래 리스트가 밀리지 않는다.
/// (실제 카드: vertical 16 패딩 + 콘텐츠 약 40 = 72, 아래 여백 SDSSpacing.xl)
class MyRankingCardSkeleton extends StatelessWidget {
  const MyRankingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // 실제 카드([RankingMyCardShell])와 같은 규격이어야 데이터가 도착할 때 아래
    // 목록이 밀리지 않는다.
    // PC·태블릿: 라운드 16 / 좌우 30 · 상하 7 / 내용 40 → 높이 54.
    // 모바일: 좌우 28 · 상하 10 / 내용 50 → 높이 70, 카드만 페이지 여백보다 4 안쪽.
    final isMobile = context.screenType == WebScreenType.mobile;

    return Container(
      height: isMobile ? 70 : 54,
      // 카드 ↔ 목록 30. 카드가 숨겨질 때 여백도 같이 사라지도록 카드 안에 둔다.
      margin: EdgeInsets.only(bottom: 30, left: isMobile ? 4 : 0, right: isMobile ? 4 : 0),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 28 : 30, vertical: isMobile ? 10 : 7),
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SkeletonShimmer(
        child: isMobile
            // 모바일은 값·라벨을 위아래로 쌓은 묶음 3개가 균등 배치된다.
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  3,
                  (_) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SkeletonLine(width: 56, height: 17),
                      SizedBox(height: 2),
                      SkeletonLine(width: 40, height: 12),
                    ],
                  ),
                ),
              )
            : Row(
                children: [
                  const SkeletonLine(width: 52, height: 15),
                  const Spacer(),
                  const SkeletonLine(width: 96, height: 17),
                  const SizedBox(width: 24),
                  const SkeletonLine(width: 78, height: 17),
                  const SizedBox(width: 20),
                  const SkeletonLine(width: 62, height: 13),
                  // 티어 아이콘 자리는 비워둔다(목록 행과 동일).
                  const SizedBox(width: 8 + 40),
                ],
              ),
      ),
    );
  }
}

/// 중고거래 우측 사이드바(최근 본 상품 / 찜 목록) 자리표시.
class ActivityListSkeleton extends StatelessWidget {
  final int rowCount;

  const ActivityListSkeleton({super.key, this.rowCount = 3});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: List.generate(
          rowCount,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: SDSSpacing.md),
            child: Row(
              children: [
                const SkeletonBox(width: 48, height: 48, radius: 6),
                const SizedBox(width: SDSSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLine(width: double.infinity, height: 12),
                      const SizedBox(height: 6),
                      const SkeletonLine(width: 70, height: 13),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
