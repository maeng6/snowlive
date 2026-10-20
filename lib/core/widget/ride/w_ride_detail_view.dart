import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rideDetail.dart';
import 'package:com.snowlive/core/widget/ride/ride_image_save.dart';
import 'package:com.snowlive/core/widget/ride/ride_video_export.dart';
import 'package:com.snowlive/core/widget/ride/w_ride_charts_painter.dart';
import 'package:com.snowlive/core/widget/ride/w_ride_route_3d_view.dart';
import 'package:com.snowlive/core/widget/ride/w_ride_track_painter.dart';
import 'package:com.snowlive/web/util/web_image_save.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 유료 궤적 상세 공통 위젯(앱·웹 공유).
/// 궤적 이미지(슬로프 경계·진행방향) + 재생 애니메이션 + 속도/고도/경사 차트 + 이미지 다운로드.
class RideDetailView extends StatefulWidget {
  final RideDetail detail;
  const RideDetailView({super.key, required this.detail});

  @override
  State<RideDetailView> createState() => _RideDetailViewState();
}

class _RideDetailViewState extends State<RideDetailView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final GlobalKey _captureKey = GlobalKey();
  bool _exportingVideo = false;

  // 차트용 파생 데이터
  List<double> _cumDist = const [];
  List<double> _gradient = const [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6));
    // 끝점 도달(완료)·처음복귀 시 버튼 라벨('일시정지'↔'재생')을 다시 그린다.
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (mounted) setState(() {});
      }
    });
    _computeDerived();
  }

  void _computeDerived() {
    final s = widget.detail.samples;
    if (s == null || !s.hasData) return;
    final n = s.length;
    final cum = List<double>.filled(n, 0);
    for (int i = 1; i < n; i++) {
      cum[i] = cum[i - 1] + _haversine(s.lat[i - 1], s.lng[i - 1], s.lat[i], s.lng[i]);
    }
    final grad = List<double>.filled(n, double.nan);
    for (int i = 1; i < n; i++) {
      final a0 = s.alt.length > i ? s.alt[i - 1] : null;
      final a1 = s.alt.length > i ? s.alt[i] : null;
      final step = cum[i] - cum[i - 1];
      if (a0 != null && a1 != null && step > 0.5) {
        grad[i] = (a1 - a0) / step * 100.0;
      }
    }
    _cumDist = cum;
    _gradient = grad;
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_ctrl.isAnimating) {
      _ctrl.stop();
    } else {
      if (_ctrl.value >= 1.0) _ctrl.reset();
      _ctrl.forward();
    }
    setState(() {});
  }

  /// 궤적 이미지를 전체화면에서 핀치/스크롤로 확대해 본다(앱·웹 공통).
  void _openTrackZoom(BuildContext context) {
    final d = widget.detail;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 1,
              maxScale: 6,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(painter: RideTrackPainter(detail: d)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final png = bytes.buffer.asUint8List();
      final fname = 'snowlive_track_${widget.detail.ridingTrackId}.png';

      // 앱(모바일): 라이딩 카드와 동일하게 gal로 'Snowlive' 앨범에 바로 저장한다.
      if (!kIsWeb) {
        final ok = await saveRideImageToGallery(bytes: png, filename: fname);
        if (!mounted) return;
        messenger?.showSnackBar(SnackBar(
            content: Text(ok ? '사진 앨범에 저장했어요.' : '이미지 저장에 실패했어요.')));
        return;
      }

      // 웹: 아이폰 웹은 공유 시트(→ 사진 앱)로, 안드로이드·PC는 다운로드로 저장한다.
      var result = await saveWebPngToDevice(bytes: png, filename: fname);
      if (!mounted) return;

      // 캡처가 길어 Safari가 공유 시트를 막으면(탭 직후만 허용) 한 번 더 탭하게 안내한다.
      if (result == WebImageSaveResult.needsUserTap) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('이미지가 준비됐어요',
                style: SDSTextStyle.bold.copyWith(fontSize: 16)),
            content: Text('사진 앱에 저장하려면 공유 화면에서\n‘이미지 저장’을 눌러주세요.',
                style: SDSTextStyle.regular.copyWith(fontSize: 14)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('닫기',
                      style: SDSTextStyle.bold.copyWith(
                          fontSize: 14, color: SDSColor.gray500))),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('사진에 저장',
                      style: SDSTextStyle.bold.copyWith(
                          fontSize: 14, color: SDSColor.snowliveBlue))),
            ],
          ),
        );
        if (ok != true || !mounted) return;
        // 이 탭 핸들러 안에서 바로 연다(캡처는 이미 끝났다).
        result = await shareWebPngNow(bytes: png, filename: fname);
        if (!mounted) return;
      }

      switch (result) {
        case WebImageSaveResult.shared:
        case WebImageSaveResult.cancelled:
          // 공유 시트에서 저장했거나 닫았다 — 웹은 무엇을 골랐는지 모른다(안내 생략).
          break;
        case WebImageSaveResult.downloaded:
          messenger?.showSnackBar(
              const SnackBar(content: Text('이미지를 저장했어요.')));
        case WebImageSaveResult.needsUserTap:
        case WebImageSaveResult.failed:
          // 앱(stub) 경로는 failed를 돌려주므로 실패 안내는 웹에서만 한다.
          if (kIsWeb) {
            messenger?.showSnackBar(
                const SnackBar(content: Text('이미지 저장에 실패했어요.')));
          }
      }
    } catch (_) {}
  }

  Future<void> _exportVideo() async {
    if (_exportingVideo) return;
    setState(() => _exportingVideo = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(const SnackBar(
        content: Text('영상을 만들고 있어요… 잠시만 기다려주세요.')));
    final result = await exportRideVideo(detail: widget.detail);
    if (!mounted) return;
    setState(() => _exportingVideo = false);
    String msg;
    switch (result) {
      case RideVideoResult.saved:
        msg = '영상을 갤러리에 저장했어요.';
        break;
      case RideVideoResult.unsupported:
        msg = '영상 저장은 앱에서만 가능해요.';
        break;
      default:
        msg = '영상 저장에 실패했어요.';
    }
    messenger?.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;
    final s = d.samples;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 2),
        // 3D 궤적 — 자동 회전 입체 애니메이션(속도색). samples 있을 때만.
        if (s != null && s.hasData) ...[
          _label('3D 궤적 · 자동 회전 (슬로프 면 위 라이딩)'),
          RideRoute3DView(
              samples: s,
              slope: d.slope,
              score: d.record?.score,
              distance: d.record?.distance),
          const SizedBox(height: 14),
          _label('따라 내려가기 · 카메라 추적'),
          RideRoute3DView(
              samples: s,
              slope: d.slope,
              follow: true,
              score: d.record?.score,
              distance: d.record?.distance),
          const SizedBox(height: 14),
        ],
        // 궤적 이미지(캡처 대상) — 탭하면 전체화면에서 핀치/스크롤로 확대.
        _label('궤적 (슬로프 경계 · 진행방향) · 탭하면 확대'),
        GestureDetector(
          onTap: () => _openTrackZoom(context),
          child: RepaintBoundary(
            key: _captureKey,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(painter: RideTrackPainter(detail: d)),
                    const Positioned(
                      right: 8,
                      bottom: 8,
                      child: Icon(Icons.zoom_in,
                          size: 20, color: Color(0xCCFFFFFF)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: _saveImage,
              child: Text('이미지 저장',
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 13, color: SDSColor.snowliveBlue)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (s != null && s.hasData) ...[
          _label('재생 애니메이션 · 옅은 점 간격이 넓을수록 빠른 구간'),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: RideTrackPainter(
                    detail: d,
                    progress: _ctrl.value == 0 ? 0.001 : _ctrl.value,
                    showMovingMarker: true,
                    showGpsPoints: false, // 재생 궤적엔 점 미표시
                    smooth: true, // 5배 보간으로 부드럽게
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: _togglePlay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SDSColor.snowliveBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_ctrl.isAnimating ? '일시정지' : '재생',
                    style: SDSTextStyle.bold
                        .copyWith(fontSize: 14, color: SDSColor.snowliveWhite)),
              ),
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final idx = (s.length * _ctrl.value)
                      .clamp(0, s.length - 1)
                      .toInt();
                  final spd = s.spd.length > idx ? s.spd[idx] : 0.0;
                  return Text('${spd.toStringAsFixed(1)} km/h',
                      style: SDSTextStyle.extraBold
                          .copyWith(fontSize: 18, color: const Color(0xFFFDE047)));
                },
              ),
            ],
          ),
          if (!kIsWeb)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextButton(
                onPressed: _exportingVideo ? null : _exportVideo,
                child: Text(_exportingVideo ? '영상 만드는 중…' : '영상 저장',
                    style: SDSTextStyle.bold.copyWith(
                        fontSize: 13, color: SDSColor.snowliveBlue)),
              ),
            ),
          const SizedBox(height: 14),
          _chart('속도 (km/h) · 거리', s.spd, const Color(0xFFFDE047)),
          _chart('고도 (m) · 거리',
              s.alt.map((e) => e ?? double.nan).toList(), const Color(0xFF60A5FA)),
          _chart('경사도 (%) · 거리', _gradient, const Color(0xFF34D399)),
        ],
      ],
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)),
      );

  Widget _chart(String label, List<double> ys, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(label),
          SizedBox(
            height: 110,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: MiniChartPainter(xs: _cumDist, ys: ys, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
