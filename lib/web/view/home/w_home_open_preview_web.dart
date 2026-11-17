import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_open_preview.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/webcam_embed.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 홈 '개장 미리보기' 섹션 — 어드민에서 노출 체크한 스키장 웹캠을 카드로 보여준다.
///
/// 웹캠 iframe은 데스크탑/태블릿에서만 임베드한다(모바일은 iframe 과다 시 WebKit
/// 크래시가 있어 '웹캠 보기' 카드로 대체 — 추천상품과 같은 규칙). 카드를 누르면
/// 웹캠 URL이 새 탭으로 열린다.
class HomeOpenPreviewWeb extends StatelessWidget {
  final List<OpenPreviewItem> items;

  const HomeOpenPreviewWeb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '개장 미리보기',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: isMobile ? 18 : 22,
            color: SDSColor.gray900,
          ),
        ),
        const SizedBox(height: SDSSpacing.md),
        LayoutBuilder(
          builder: (context, c) {
            // 데스크탑/태블릿 2열, 모바일 1열.
            final columns = isMobile ? 1 : 2;
            const gap = 16.0;
            final cellW = (c.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final it in items)
                  SizedBox(
                    width: cellW,
                    child: _PreviewCard(item: it),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final OpenPreviewItem item;

  const _PreviewCard({required this.item});

  Future<void> _open() async {
    final url = item.webcamUrl.trim();
    if (!url.startsWith('http')) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    // 모바일·인앱 브라우저는 iframe 과다 시 크래시 → 임베드는 데스크탑/태블릿만.
    final bool heavyOk = context.screenType != WebScreenType.mobile;
    final hasCam = item.webcamUrl.trim().startsWith('http');

    final Widget camArea = AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: SDSColor.gray100,
          child: (hasCam && heavyOk)
              ? webcamEmbedView(url: item.webcamUrl)
              : _CamPlaceholder(hasCam: hasCam),
        ),
      ),
    );

    return MouseRegion(
      cursor: hasCam ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: hasCam ? _open : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            camArea,
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text(
                    item.resort,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.bold
                        .copyWith(fontSize: 15, color: SDSColor.gray900),
                  ),
                ),
                if (item.slopeName.trim().isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.slopeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 14, color: SDSColor.gray500),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 임베드 못하는 자리(모바일 또는 URL 없음) 대체 — 탭하면 새 탭으로 연다는 안내.
class _CamPlaceholder extends StatelessWidget {
  final bool hasCam;

  const _CamPlaceholder({required this.hasCam});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasCam ? Icons.play_circle_outline_rounded : Icons.videocam_off_outlined,
            size: 34,
            color: SDSColor.gray400,
          ),
          const SizedBox(height: 6),
          Text(
            hasCam ? '실시간 웹캠 보기' : '웹캠 준비 중',
            style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray500),
          ),
        ],
      ),
    );
  }
}
