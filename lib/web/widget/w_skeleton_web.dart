import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/w_community_row_web.dart' show communityTableRowShell;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_grid_web.dart' show kFleamarketCardTextBlockHeight;
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
/// 값은 기존 카드 이미지 로딩(w_fleamarket_card_web.dart)에서 쓰던 조합을 그대로 승계.
class SkeletonShimmer extends StatelessWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: SDSColor.gray200,
      highlightColor: SDSColor.gray50,
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
/// 실제 그리드와 **같은 열 수/간격/mainAxisExtent**를 써야 데이터 도착 시 점프가 없다.
class FleamarketGridSkeleton extends StatelessWidget {
  final int itemCount;

  const FleamarketGridSkeleton({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.isDesktop ? 5 : 2;
    const spacing = SDSSpacing.md;

    return SkeletonShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 16),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: SDSSpacing.lg,
              mainAxisExtent: cellWidth + kFleamarketCardTextBlockHeight,
            ),
            itemBuilder: (context, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: cellWidth, height: cellWidth, radius: 8),
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
    return communityTableRowShell(
      border: Border(bottom: BorderSide(color: SDSColor.gray100)),
      titleCell: Row(
        children: const [
          SkeletonBox(width: 42, height: 17),
          SizedBox(width: 6),
          Expanded(child: SkeletonLine(height: 14)),
        ],
      ),
      authorCell: const SkeletonLine(width: 56, height: 13),
      dateCell: const SkeletonLine(width: 72, height: 13),
      countsCell: const SkeletonLine(width: 72, height: 13),
    );
  }
}

class _CommunityCardRowSkeleton extends StatelessWidget {
  const _CommunityCardRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: SDSColor.gray100))),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    SkeletonBox(width: 42, height: 17),
                    SizedBox(width: 6),
                    Expanded(child: SkeletonLine(height: 14)),
                  ],
                ),
                SizedBox(height: 8),
                SkeletonLine(width: 180, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 랭킹 리스트 자리표시. 데스크탑은 실제 화면과 동일하게 2단으로 그린다.
class RankingListSkeleton extends StatelessWidget {
  final int rowCount;

  const RankingListSkeleton({super.key, this.rowCount = 10});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final perColumn = isDesktop ? (rowCount / 2).ceil() : rowCount;

    Widget column() => Column(
          children: List.generate(perColumn, (_) => const _RankingRowSkeleton()),
        );

    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: column()),
                  const SizedBox(width: SDSSpacing.xl),
                  Expanded(child: column()),
                ],
              )
            : column(),
      ),
    );
  }
}

class _RankingRowSkeleton extends StatelessWidget {
  const _RankingRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SkeletonBox(width: 20, height: 14),
          const SizedBox(width: 14),
          const SkeletonBox(width: 32, height: 32, isCircle: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(width: 90, height: 13),
                const SizedBox(height: 6),
                const SkeletonLine(width: 130, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const SkeletonLine(width: 60, height: 14),
          const SizedBox(width: 8),
          const SkeletonBox(width: 24, height: 24, isCircle: true),
        ],
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
    // 모바일 카드는 값/라벨을 위아래로 쌓아서 더 높다 — 자리표시 높이도 같이 맞춰야
    // 데이터가 도착할 때 아래 리스트가 밀리지 않는다.
    final isMobile = context.screenType == WebScreenType.mobile;

    return Container(
      height: isMobile ? 84 : 72,
      margin: const EdgeInsets.only(bottom: SDSSpacing.xl),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const SkeletonShimmer(
        child: Row(
          children: [
            SkeletonLine(width: 60, height: 14),
            Spacer(),
            SkeletonLine(width: 80, height: 14),
            SizedBox(width: SDSSpacing.lg),
            SkeletonLine(width: 60, height: 14),
            SizedBox(width: SDSSpacing.lg),
            SkeletonBox(width: 28, height: 28, isCircle: true),
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
