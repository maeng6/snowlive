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

  /// 제목 옆 '더보기' → 개장 미리보기 페이지로. null이면 버튼을 숨긴다.
  final VoidCallback? onMore;

  const HomeOpenPreviewWeb({super.key, required this.items, this.onMore});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '개장 미리보기',
              style: SDSTextStyle.extraBold.copyWith(
                fontSize: isMobile ? 18 : 22,
                color: SDSColor.gray900,
              ),
            ),
            const Spacer(),
            if (onMore != null) _OpenPreviewMoreButton(onTap: onMore!),
          ],
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
                    child: OpenPreviewCard(item: it, bottomLabel: it.resort),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 홈 '더보기' 버튼 — 다른 홈 섹션(`_MoreButton`)과 같은 톤(gray100·bold 13).
class _OpenPreviewMoreButton extends StatelessWidget {
  final VoidCallback onTap;

  const _OpenPreviewMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.gray100,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.black.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Text(
            '더보기',
            style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
          ),
        ),
      ),
    );
  }
}

/// 웹캠 카드 1개 — 홈 섹션과 개장 미리보기 페이지가 공유한다.
///
/// 슬로프명은 **영상 위(좌상단)에 오버레이**한다. 영상 아래에는 [bottomLabel](홈에선
/// 스키장명, 페이지에선 null — 스키장은 그룹 제목으로 이미 보여서 생략)만 둔다.
/// 임베드된 iframe은 탭 오버레이로 **덮지 않는다** — 그래야 자동재생·플레이어 조작이
/// 막히지 않는다(URL 열기는 임베드 못하는 자리에서만).
class OpenPreviewCard extends StatelessWidget {
  final OpenPreviewItem item;

  /// 영상 아래에 둘 라벨(홈=스키장명). null이면 아래 라벨 없음(페이지).
  final String? bottomLabel;

  const OpenPreviewCard({super.key, required this.item, this.bottomLabel});

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
    final embedded = hasCam && heavyOk;

    final Widget video = embedded
        ? webcamEmbedView(url: item.webcamUrl)
        // 임베드 못하는 자리(모바일·URL없음)는 탭하면 새 탭으로 연다.
        : MouseRegion(
            cursor: hasCam ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hasCam ? _open : null,
              child: _CamPlaceholder(hasCam: hasCam),
            ),
          );

    final camArea = AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: SDSColor.gray100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              video,
              // 슬로프명을 영상 위 좌상단에 — 사진 위에서도 읽히게 반투명 검정 pill.
              if (item.slopeName.trim().isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  child: IgnorePointer(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: SDSColor.gray900.withOpacity(0.62),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.slopeName,
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 12,
                          height: 1.2,
                          color: SDSColor.snowliveWhite,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final label = bottomLabel?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        camArea,
        if (label.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
          ),
        ],
      ],
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
