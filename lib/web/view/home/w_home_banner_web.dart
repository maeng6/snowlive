import 'dart:async';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 홈 상단 배너.
///
/// 앱과 같은 방식이다 — 운영에서 `visible`로 껐다 켠 배너만 노출하고, **2장 이상일 때만**
/// 5초 간격으로 자동 롤링한다(1장이면 정지). 이미지를 누르면 랜딩 URL을 새 탭으로 연다.
class HomeBannerWeb extends StatefulWidget {
  final List<HomeBanner> banners;

  /// Firestore 문서를 받았는지. 받기 전에는 자리를 잡고(스켈레톤), 받은 뒤
  /// 켜진 배너가 없으면 영역을 감춘다.
  final bool isLoaded;

  const HomeBannerWeb({super.key, required this.banners, required this.isLoaded});

  @override
  State<HomeBannerWeb> createState() => _HomeBannerWebState();
}

class _HomeBannerWebState extends State<HomeBannerWeb> {
  /// 목업 비율 — 데스크탑/태블릿은 넓고 모바일은 세로로 길다.
  static const double _wideAspect = 1164 / 344;
  static const double _mobileAspect = 343 / 404;

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(HomeBannerWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _index = 0;
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    // 1장이면 롤링하지 않는다(앱과 동일).
    if (widget.banners.length < 2) return;
    _timer = Timer.periodic(kHomeBannerInterval, (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.banners.length);
    });
  }

  Future<void> _open(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final aspect = isMobile ? _mobileAspect : _wideAspect;
    final radius = BorderRadius.circular(isMobile ? 12 : 16);

    // 운영에서 배너를 다 끄면 영역 자체가 없다(앱과 동일).
    if (widget.isLoaded && widget.banners.isEmpty) return const SizedBox.shrink();

    // 문서를 받기 전에는 자리만 잡아둔다(레이아웃이 튀지 않게).
    if (widget.banners.isEmpty) {
      return AspectRatio(
        aspectRatio: aspect,
        child: SkeletonShimmer(
          child: SkeletonBox(width: double.infinity, height: double.infinity, radius: radius.topLeft.x),
        ),
      );
    }

    final banner = widget.banners[_index.clamp(0, widget.banners.length - 1)];

    return AspectRatio(
      aspectRatio: aspect,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MouseRegion(
              cursor: banner.landingUrl.isEmpty
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _open(banner.landingUrl),
                child: WebNetworkImage(
                  url: banner.imageUrl,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),
            if (widget.banners.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < widget.banners.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _index
                                ? SDSColor.snowliveWhite
                                : SDSColor.snowliveWhite.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
