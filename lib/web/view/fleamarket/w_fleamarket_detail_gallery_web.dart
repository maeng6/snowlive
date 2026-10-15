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

/// 캐러셀 디코드 폭(px). 600px 서버 썸네일은 레티나 풀폭으로 늘리면 흐릿해서,
/// 원본을 이 폭으로 디코드해 선명하게 보여준다(메모리도 이 폭으로 묶임).
const int _kCarouselDecodeWidth = 2048;

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
///
/// 게시글에 들어오는 즉시 모든 장을 백그라운드에서 선로딩해 둔다 —
/// 캐러셀은 보이는 장만 lazy로 그리지만, 브라우저 HTTP 캐시에 이미 받아놨으면
/// 넘기는 순간 바로 뜬다(스켈레톤이 잠깐만 보인다).
class FleamarketDetailGalleryWeb extends StatefulWidget {
  final List<Photo> photos;

  const FleamarketDetailGalleryWeb({super.key, required this.photos});

  @override
  State<FleamarketDetailGalleryWeb> createState() =>
      _FleamarketDetailGalleryWebState();
}

class _FleamarketDetailGalleryWebState
    extends State<FleamarketDetailGalleryWeb> {
  /// 이미 precache 요청을 건 원본 URL들(중복 방지). photos가 늦게 도착하거나
  /// Obx 재빌드로 바뀌어도, 새로 들어온 URL만 골라 precache하기 위해 집합으로 추적.
  final Set<String> _precachedUrls = {};

  @override
  void initState() {
    super.initState();
    // 새 게시글로 진입할 때마다 캐러셀 위치를 **항상 첫 장으로 리셋**한다.
    // (FleamarketDetailViewModel이 싱글톤이라 직전 글에서 보던 currentIndex가
    //  남아 점 인디케이터/시작 위치가 이어지던 문제.) build 중 Rx 변경은 금지라
    //  다음 프레임으로 미룬다. 캐러셀 위젯 자체도 아래 key로 새로 시작시킨다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Get.find<FleamarketDetailViewModel>().updateCurrentIndex(0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAll();
  }

  @override
  void didUpdateWidget(covariant FleamarketDetailGalleryWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 상세 데이터가 늦게 도착해 photos가 뒤늦게 채워지는 경우(Obx 재빌드)에도
    // 반드시 precache가 돌도록 한다 — didChangeDependencies는 재실행되지 않는다.
    _precacheAll();
  }

  /// 캐러셀에 표시할 사진들을 Flutter 이미지 캐시에 **디코드까지** 미리 올려둔다.
  /// 소스는 **원본(선명)**을 2048px로 디코드한다 — 600px 서버 썸네일은 레티나 풀폭에서
  /// 흐릿했다(화질 불만). 원본 바이트는 뷰어용으로도 쓰이므로 추가 다운로드가 아니고,
  /// 메모리는 2048로 묶인다. CarouselSlider가 보이는 장만 lazy로 만들어도, 이미 캐시에
  /// 있으면 **생성 즉시(스켈레톤 없이)** 그려진다.
  ///
  /// 키 일치가 핵심: 캐러셀의 WebNetworkImage(decodeWidth: 2048)는 내부적으로
  /// Image.network(url, cacheWidth: 2048) = `ResizeImage.resizeIfNeeded(2048, null,
  /// NetworkImage(url))`를 만든다 → precache도 **똑같은 식**으로 만들어 키를 맞춘다.
  void _precacheAll() {
    for (final p in widget.photos) {
      final u = p.urlFleaPhoto;
      if (u == null || u.isEmpty) continue;
      if (!_precachedUrls.add(u)) continue; // 이미 요청한 URL은 건너뜀
      // 실패(CORS/404 등)해도 캐러셀은 그 자리에서 다시 받으므로 조용히 무시.
      precacheImage(
        ResizeImage.resizeIfNeeded(_kCarouselDecodeWidth, null, NetworkImage(u)),
        context,
        onError: (_, __) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
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
              // 게시글이 바뀌면 key가 바뀌어 캐러셀 state를 처음부터 다시 만든다
              // (직전 글의 페이지 위치가 남지 않게). photos.first 원본 URL로 식별.
              key: ValueKey(photos.isNotEmpty ? photos.first.urlFleaPhoto : ''),
              options: CarouselOptions(
                viewportFraction: 1,
                aspectRatio: 1,
                initialPage: 0,
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
                  // 캐러셀 소스는 **원본**을 2048px로 디코드(선명). 600 썸네일은 풀폭에서
                  //   흐릿했다. 원본 바이트는 뷰어용으로 진입 시 선로딩되어 추가 전송 없음.
                  // decodeWidth: didChangeDependencies의 precache(ResizeImage width:2048)와
                  //   키가 같아 미리 디코드해 둔 걸 그대로 재사용 → 넘겨도 즉시 표시.
                  // placeholderAspectRatio: 선로딩 전/캐시 미스일 때만 잠깐 정사각 스켈레톤.
                  // gaplessPlayback: 넘길 때 다음 장이 준비될 때까지 이전 장을 유지.
                  child: WebNetworkImage(
                    url: p.urlFleaPhoto,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    decodeWidth: _kCarouselDecodeWidth,
                    placeholderAspectRatio: 1,
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
