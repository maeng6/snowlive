import 'package:carousel_slider/carousel_slider.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart' show kFleamarketDefaultImage;
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_detail_image_viewer_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 상세 사진 모서리(디자인 지정 6).
const double kFleamarketDetailPhotoRadius = 6;

/// 스와이프 한 번에 **한 장씩만** 넘어가는 페이지 물리.
/// 기본 PageScrollPhysics는 세게 플링하면 관성 거리만큼 여러 장을 지나친다 —
/// 놓은 지점 기준 ±0.5장 안에서 반올림해 항상 인접 장에 스냅시킨다.
class _SinglePageScrollPhysics extends ScrollPhysics {
  const _SinglePageScrollPhysics({super.parent});

  @override
  _SinglePageScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _SinglePageScrollPhysics(parent: buildParent(ancestor));

  double _page(ScrollMetrics position) =>
      position.pixels / position.viewportDimension;

  double _targetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _page(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return page.roundToDouble() * position.viewportDimension;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);
    final double target = _targetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
          spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

/// 상세화면 상단 이미지 캐러셀 + 점 인디케이터.
class FleamarketDetailGalleryWeb extends StatelessWidget {
  final List<Photo> photos;

  const FleamarketDetailGalleryWeb({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final detailVm = Get.find<FleamarketDetailViewModel>();

    if (photos.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kFleamarketDetailPhotoRadius),
          child: Image.asset(kFleamarketDefaultImage, fit: BoxFit.cover),
        ),
      );
    }

    // 인디케이터를 썸네일 **안쪽 하단**에 올린다. 점이 사진 위에서도
    // 보이도록 아래쪽에 투명→검정 그라데이션 딤을 은은하게 깔고, 점 색은 흰색 계열로.
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kFleamarketDetailPhotoRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                viewportFraction: 1,
                aspectRatio: 1,
                enableInfiniteScroll: photos.length > 1,
                // 빠르게 스와이프하면 관성으로 두 장 이상 넘어갔다(실측) →
                // 항상 인접 장에서 멈추는 물리로 교체.
                scrollPhysics: const _SinglePageScrollPhysics(),
                onPageChanged: (index, _) => detailVm.updateCurrentIndex(index),
              ),
              itemCount: photos.length,
              itemBuilder: (context, index, _) {
                final p = photos[index];
                return GestureDetector(
                  onTap: () => showFleamarketImageViewerWeb(
                    context: context,
                    photos: photos,
                    initialIndex: index,
                    title: detailVm.fleamarketDetail.title ?? '',
                  ),
                  // gaplessPlayback: 사진을 넘길 때 다음 장이 준비될 때까지 이전 장을
                  // 유지해서 흰 화면이 한 번 깜빡이는 걸 막는다.
                  child: WebNetworkImage(
                    url: p.urlFleaPhoto,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    gaplessPlayback: true,
                    fallback: Image.asset(kFleamarketDefaultImage, fit: BoxFit.cover),
                  ),
                );
              },
            ),
            if (photos.length > 1) ...[
              // 하단 딤: 투명 → 검정 35%를 ease 곡선(정지점 근사)으로 올려서
              // 경계선 없이 자연스럽게 어두워진다. 높이는 64px.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 64,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.22),
                          Colors.black.withValues(alpha: 0.35),
                        ],
                        stops: const [0, 0.4, 0.75, 1],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: IgnorePointer(
                  child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < photos.length; i++)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // 딤 위라 흰색 계열 — 비활성은 60% 흰색.
                                color: detailVm.currentIndex == i
                                    ? SDSColor.snowliveWhite
                                    : SDSColor.snowliveWhite
                                        .withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      )),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
