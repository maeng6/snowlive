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
class WebNetworkImage extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = (url == null || url!.isEmpty)
        ? _fallback()
        : Image.network(
            url!,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: gaplessPlayback,
            // Firebase Storage가 Access-Control-Allow-Origin을 주지 않아서, 캔버스에
            // 그리려고 바이트를 받아오는 기본 경로가 CORS로 막힌다 → 이 옵션이 없으면
            // 웹에서 원격 이미지가 전부 빈 칸이 된다.
            // (실측: 일반 <img> 로드는 성공, crossOrigin과 fetch는 실패)
            // fallback을 켜면 디코드 실패 시 <img> 엘리먼트 경로로 넘어가 정상 표시된다.
            // 버킷에 CORS 설정이 들어가면 기본 경로로 돌아가므로 그대로 둬도 무해하다.
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return SkeletonShimmer(
                child: SkeletonBox(
                  width: width,
                  height: height,
                  radius: borderRadius,
                  isCircle: isCircle,
                ),
              );
            },
            // 디코드가 끝나는 순간 페이드인. 라우트 전환과 같은 150ms로 맞춰 통일감을 준다.
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
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

    if (isCircle) return ClipOval(child: content);
    if (borderRadius > 0) {
      return ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: content);
    }
    return content;
  }

  Widget _fallback() {
    if (fallback != null) return fallback!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: SDSColor.gray100,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
      ),
      child: Icon(Icons.image_outlined, size: 16, color: SDSColor.gray300),
    );
  }
}
