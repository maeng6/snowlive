import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_event.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/community/w_community_row_web.dart';
import 'package:com.snowlive/web/viewmodel/event/vm_eventListPagination_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 미리보기 카드 폭(PC·태블릿). 모바일은 뷰포트에서 좌우 여백(모달 기본 패딩)만
/// 빼고 꽉 채운다. 피드 글이라 본문·사진을 편히 읽을 정도의 폭.
const double _kEventPreviewWidth = 460;

/// 각종소식 **사이트 내 미리보기 다이얼로그**.
///
/// 원본은 인스타그램 게시물이라 iframe 임베드가 막혀(프레임 차단) 다이얼로그 안에
/// 원본 페이지를 그대로 띄울 수 없다. 대신 크롤해둔 데이터(썸네일·제목·본문)를
/// 보여주고, 원할 때만 "인스타그램에서 원본 보기"로 새 탭 이동한다 → 사이트 이탈 최소화.
///
/// 디자인은 웹 공통 팝업 규칙을 따른다(흰 카드·라운드 16·공통 토큰).
Future<void> showEventPreviewDialog({
  required BuildContext context,
  required EventModel event,
}) {
  return showWebOverlayModal<void>(
    context: context,
    builder: (ctx, close) => _EventPreviewCard(event: event, onClose: close),
  );
}

class _EventPreviewCard extends StatelessWidget {
  final EventModel event;
  final void Function([void result]) onClose;

  const _EventPreviewCard({required this.event, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    // 모달 기본 좌우 패딩(24*2)을 빼면 모바일에서 넘치지 않는다.
    final double maxWidth = isMobile
        ? (MediaQuery.of(context).size.width - 48).clamp(0.0, _kEventPreviewWidth)
        : _kEventPreviewWidth;
    // 세로로 길어도 뷰포트를 넘지 않게 — 넘치면 본문이 카드 안에서 스크롤된다.
    final double maxHeight = MediaQuery.of(context).size.height * 0.86;

    final category = event.category;
    final name = event.crawlAccountName ?? event.crawlAccountUsername ?? '';
    final body = (event.description ?? '').trim();

    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 헤더: 분류 칩 + 이름(계정) ────────────── 닫기(X) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  if (category != null && category.isNotEmpty) ...[
                    CommunityCategoryChip(
                      label: category,
                      background: SDSColor.blue50,
                      textColor: SDSColor.snowliveBlue,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 14,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CloseButton(onTap: onClose),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: SDSColor.gray100),
            // ── 본문(스크롤): 썸네일 + 제목 + 작성일 + 캡션 ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.thumbImgUrl != null && event.thumbImgUrl!.isNotEmpty) ...[
                      // 인스타 썸네일은 보통 정사각 — 1:1로 자리를 잡는다.
                      // 라운드 클립은 WebNetworkImage가 담당(borderRadius).
                      AspectRatio(
                        aspectRatio: 1,
                        child: WebNetworkImage(
                          url: event.thumbImgUrl,
                          fit: BoxFit.cover,
                          borderRadius: 8,
                          placeholderAspectRatio: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (event.uploadTime != null)
                      Text(
                        communityDateLabelOf(event.uploadTime),
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.gray500,
                        ),
                      ),
                    if (body.isNotEmpty) ...[
                      if (event.uploadTime != null) const SizedBox(height: 14),
                      _ExpandableText(text: body),
                    ],
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: SDSColor.gray100),
            // ── 하단: 원본 보기(새 탭) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.find<EventListPaginationViewModelWeb>().openLanding(event);
                  },
                  style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(0),
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                    shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                    animationDuration: Duration.zero,
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.hovered)
                          ? Color.alphaBlend(
                              Colors.black.withValues(alpha: 0.1), SDSColor.snowliveBlue)
                          : SDSColor.snowliveBlue,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.open_in_new, size: 18, color: SDSColor.snowliveWhite),
                      const SizedBox(width: 8),
                      Text(
                        '인스타그램에서 원본 보기',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 16,
                          color: SDSColor.snowliveWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 우측 상단 닫기(X). hover 시 배경 연회색(웹 공통 아이콘 버튼 톤).
class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      hoverColor: SDSColor.gray900.withValues(alpha: 0.04),
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(Icons.close, size: 20, color: SDSColor.gray500),
      ),
    );
  }
}

/// 캡션 본문 — 기본 접힘(최대 [maxLines]줄), 길면 "더보기/접기"로 펼친다.
/// 크롤 캡션은 길고 해시태그가 많아 그대로 펼치면 다이얼로그가 과하게 길어진다.
class _ExpandableText extends StatefulWidget {
  final String text;

  const _ExpandableText({required this.text});

  /// 접힘 상태에서 보여줄 최대 줄 수.
  static const int _maxLines = 6;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = SDSTextStyle.regular.copyWith(
      fontSize: 14,
      height: 22 / 14,
      color: SDSColor.gray800,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // 접힘 상태에서 maxLines를 넘기는지 실측해 토글 노출을 결정한다.
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _ExpandableText._maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _expanded ? null : _ExpandableText._maxLines,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: style,
            ),
            if (overflows) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? '접기' : '더보기',
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 13,
                    color: SDSColor.gray500,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
