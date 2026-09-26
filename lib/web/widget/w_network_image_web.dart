import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';

/// 웹의 원격 이미지는 모두 이걸로 통일한다.
///
/// 기존엔 대부분 `Image.network`를 그대로 써서 (1) 로딩 중 빈 칸이 보이다가 툭 나타나고,
/// (2) 404면 빨간 에러 박스가 뜨고, (3) 처리 방식이 파일마다 달랐다.
///
/// ⚠️ [width]/[height]를 주거나 상위에서 `AspectRatio`/`SizedBox`로 크기를 고정할 것.
/// 레이아웃이 튀지 않게 하는 실제 해결책은 "박스를 먼저 잡는 것"이고 셔머는 그 다음이다.
class WebNetworkImage extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final bool isCircle;

  /// 이미지가 없거나 로드에 실패했을 때 대신 그릴 위젯. 없으면 회색 박스.
  final Widget? fallback;

  /// 여러 장을 갈아끼우는 경우(갤러리 등) true로 두면 다음 이미지가 준비될 때까지
  /// 이전 이미지를 유지해서 흰 깜빡임이 사라진다.
  final bool gaplessPlayback;

  /// **높이를 고정하지 않는 이미지**(원본 비율로 그리는 피드 사진)의 로딩 중
  /// 자리를 이 비율(가로/세로)로 잡아둔다 — 실제 크기는 받아봐야 알 수 있으니
  /// 어림값이다. 로드되면 원본 비율로 바뀐다.
  ///
  /// 자리표시는 이미지를 **감싸지 않고 뒤에 깔린다**(Stack이 둘 중 큰 높이를
  /// 따른다) — 감싸면 CORS 폴백처럼 로드 신호가 안 오는 경로에서 사진이 이 비율로
  /// 잘려버린다.
  final double? placeholderAspectRatio;

  const WebNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.isCircle = false,
    this.fallback,
    this.gaplessPlayback = false,
    this.placeholderAspectRatio,
  });

  @override
  State<WebNetworkImage> createState() => _WebNetworkImageState();
}

class _WebNetworkImageState extends State<WebNetworkImage> {
  /// 바이트 경로에서 첫 프레임이 나오면 true — 스켈레톤 밑판을 걷는다.
  /// CORS가 막혀 `<img>` 폴백 경로로 가면 frameBuilder가 안 불려 false로 남는데,
  /// 그 경우 로드된 `<img>`(플랫폼 뷰)가 밑판을 덮으므로 보이는 문제는 없다.
  bool _loaded = false;

  @override
  void didUpdateWidget(covariant WebNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _loaded = false;
  }

  void _markLoaded() {
    if (_loaded || !mounted) return;
    // frameBuilder는 빌드 도중 불린다 — 같은 프레임에 setState하면 예외.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_loaded) setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width;
    final height = widget.height;

    Widget content;
    if (widget.url == null || widget.url!.isEmpty) {
      content = _fallback();
    } else {
      final image = Image.network(
        widget.url!,
        width: width,
        height: height,
        fit: widget.fit,
        gaplessPlayback: widget.gaplessPlayback,
        // Firebase Storage가 Access-Control-Allow-Origin을 주지 않아서, 캔버스에
        // 그리려고 바이트를 받아오는 기본 경로가 CORS로 막힌다 → 이 옵션이 없으면
        // 웹에서 원격 이미지가 전부 빈 칸이 된다.
        // (실측: 일반 <img> 로드는 성공, crossOrigin과 fetch는 실패)
        // fallback을 켜면 디코드 실패 시 <img> 엘리먼트 경로로 넘어가 정상 표시된다
        // 버킷에 CORS 설정이 들어가면 기본 경로로 돌아가므로 그대로 둬도 무해하다.
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        // 디코드가 끝나는 순간 페이드인. 라우트 전환과 같은 150ms로 맞춰 통일감을 준다
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null || wasSynchronouslyLoaded) _markLoaded();
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stack) => _fallback(),
      );

      // 크기가 고정된 이미지는 로딩 동안 스켈레톤을 **밑판**으로 깐다.
      // loadingBuilder만으로는 부족하다 — CORS가 막힌 호스트는 <img> 폴백으로
      // 렌더되는데 그 경로에서는 loadingBuilder/frameBuilder가 불리지 않아
      // 스켈레톤 없이 빈 칸 → 툭 나타나는 문제가 있었다(프사 등, 실측).
      final placeholderRatio = widget.placeholderAspectRatio;
      if (width != null && height != null && !_loaded) {
        content = Stack(
          children: [
            SkeletonShimmer(
              child: SkeletonBox(
                width: width,
                height: height,
                radius: widget.borderRadius,
                isCircle: widget.isCircle,
              ),
            ),
            image,
          ],
        );
      } else if (placeholderRatio != null && !_loaded) {
        // 높이가 정해지지 않은 이미지 — 자리만 어림 비율로 잡아둔다.
        // Stack은 둘 중 **큰** 높이를 따르므로, 로드 신호가 끝내 안 와도
        // 사진이 이 비율에 갇히지 않는다(아래 빈 공간이 남을 뿐).
        content = Stack(
          alignment: Alignment.topCenter,
          children: [
            AspectRatio(
              aspectRatio: placeholderRatio,
              child: SkeletonShimmer(
                child: SkeletonBox(radius: widget.borderRadius),
              ),
            ),
            image,
          ],
        );
      } else {
        content = image;
      }
    }

    if (widget.isCircle) return ClipOval(child: content);
    if (widget.borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: content,
      );
    }
    return content;
  }

  Widget _fallback() {
    if (widget.fallback != null) return widget.fallback!;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: SDSColor.gray100,
        shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            widget.isCircle ? null : BorderRadius.circular(widget.borderRadius),
      ),
      child: const Icon(Icons.image_outlined, size: 16, color: SDSColor.gray300),
    );
  }
}
