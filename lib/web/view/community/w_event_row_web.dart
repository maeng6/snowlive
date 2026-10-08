import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_event.dart';
import 'package:com.snowlive/web/view/community/w_community_row_web.dart';
import 'package:com.snowlive/web/view/community/w_event_preview_dialog_web.dart';
import 'package:com.snowlive/web/viewmodel/event/vm_eventListPagination_web.dart';
import 'package:com.snowlive/web/widget/w_highlighted_text_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 각종소식(이벤트) 표 열 규격. 헤더와 데이터 행이 [eventTableRowShell] 하나를
// 공유해 열이 어긋나지 않게 한다. 커뮤니티와 열 구성이 달라(분류·이름 별도 열,
// 작성자 없음, 제목에 썸네일) 전용 셸을 두되, 간격·날짜/조회수 폭은
// 커뮤니티 표와 동일값을 쓴다.
// 열 사이 간격. 커뮤니티 표(20)와 **다르다** — 각종소식은 열이 하나 더 많아
// (분류·이름·제목·작성일·조회수) 20에서는 빽빽해 보여 30으로 둔다(사용자 확정).
const double kEventColGap = 30;

/// 각종소식 표의 메타 열(이름·작성일·조회수) 폭. 커뮤니티 표와 같은 방식으로
/// **그 페이지의 가장 긴 값**(헤더 글자 포함)을 재서 헤더·모든 행이 공유한다.
class EventMetaWidths {
  final double name;
  final double date;
  final double views;

  const EventMetaWidths({required this.name, required this.date, required this.views});

  /// 로딩 스켈레톤이 쓰는 폭(커뮤니티 표와 같은 이유로 표본을 재둔다).
  static final EventMetaWidths skeleton = EventMetaWidths._from(
    const ['스노우라이브'],
    const ['2026. 10. 03'],
    const ['1234'],
  );

  static final EventMetaWidths headerOnly = EventMetaWidths._from(const [], const [], const []);

  factory EventMetaWidths._from(List<String> names, List<String> dates, List<String> views) {
    final meta = SDSTextStyle.regular.copyWith(fontSize: 14);
    final header = SDSTextStyle.bold.copyWith(fontSize: 14);
    double widest(List<String> values, String headerText) {
      var max = measureWebTextWidth(headerText, header);
      for (final v in values) {
        final w = measureWebTextWidth(v, meta);
        if (w > max) max = w;
      }
      return max.ceilToDouble() + 2;
    }

    return EventMetaWidths(
      name: widest(names, '이름'),
      date: widest(dates, '작성일'),
      views: widest(views, '조회수'),
    );
  }

  factory EventMetaWidths.of(List<EventModel> items) => EventMetaWidths._from(
        [for (final e in items) e.crawlAccountName ?? e.crawlAccountUsername ?? ''],
        [for (final e in items) communityDateLabelOf(e.uploadTime)],
        [for (final e in items) '${e.viewCount ?? 0}'],
      );
}

// 분류 열은 고정폭 없이 내용대로(hug) — 사용자 확정. 행마다 칩 폭이 다르면
// 이름 열 시작선이 어긋날 수 있다(감수하기로 함).

/// 크롤링된 캡션 원문을 목록용 한 줄로 누른다.
/// 줄바꿈이 그대로 들어가면 행 높이가 밀리고 말줄임이 안 걸린다.
String eventTitleLine(EventModel event) {
  final raw = event.title ?? '';
  return raw.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// 이벤트 항목을 눌렀을 때: 조회수를 올리고 **사이트 내 미리보기 다이얼로그**를 연다.
///
/// 원본은 인스타그램이라 iframe 임베드가 막혀(프레임 차단) 다이얼로그에 원본을
/// 그대로 띄울 수 없다 → 크롤해둔 데이터로 미리보기를 보여주고, 원할 때만
/// 다이얼로그 안의 "원본 보기"로 새 탭 이동한다(사이트 이탈 최소화).
void openEventPreview(BuildContext context, EventModel event) {
  Get.find<EventListPaginationViewModelWeb>().countView(event);
  showEventPreviewDialog(context: context, event: event);
}

/// 각종소식 표 한 줄의 골격. 헤더 행과 데이터 행이 공유한다.
Widget eventTableRowShell({
  required EventMetaWidths widths,
  required Widget categoryCell,
  required Widget nameCell,
  required Widget titleCell,
  required Widget dateCell,
  required Widget viewsCell,
  required Border border,
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 12),

  /// 지정하면 패딩 대신 **고정 높이**로 행을 그린다(커뮤니티 표와 동일 규칙).
  /// 하단 보더 1px 포함 높이다.
  double? rowHeight,
}) {
  final Widget row = Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // 행 앞(좌측) 여백 10 — 커뮤니티 표와 동일.
      const SizedBox(width: 10),
      categoryCell,
      const SizedBox(width: kEventColGap),
      SizedBox(width: widths.name, child: nameCell),
      const SizedBox(width: kEventColGap),
      Expanded(child: titleCell),
      const SizedBox(width: kEventColGap),
      SizedBox(width: widths.date, child: dateCell),
      const SizedBox(width: kEventColGap),
      SizedBox(width: widths.views, child: viewsCell),
    ],
  );
  return Container(
    decoration: BoxDecoration(border: border),
    padding: rowHeight != null ? EdgeInsets.zero : padding,
    child: rowHeight != null
        ? SizedBox(height: rowHeight - border.bottom.width, child: row)
        : row,
  );
}

/// 각종소식 표 헤더 (태블릿·데스크탑) — 분류 | 이름 | 제목 | 작성일 | 조회수.
class EventTableHeaderRow extends StatelessWidget {
  final EventMetaWidths widths;

  const EventTableHeaderRow({super.key, required this.widths});

  @override
  Widget build(BuildContext context) {
    // 커뮤니티 표 헤더와 동일 — bold 14, 상 5 / 하 13(구분선까지).
    final style = SDSTextStyle.bold.copyWith(
      fontSize: 14,
      color: SDSColor.gray900,
    );
    return eventTableRowShell(
      widths: widths,
      padding: const EdgeInsets.only(top: 5, bottom: 13),
      border: Border(bottom: BorderSide(color: SDSColor.gray200)),
      categoryCell: Text('분류', style: style),
      nameCell: Text('이름', style: style),
      titleCell: Text('제목', style: style),
      dateCell: Text('작성일', style: style),
      viewsCell: Text('조회수', style: style),
    );
  }
}

/// 각종소식 표 데이터 행 (태블릿·데스크탑).
class EventTableRow extends StatelessWidget {
  final EventMetaWidths widths;
  final EventModel event;

  /// 강조할 검색어. 비어 있으면 강조하지 않는다.
  final String query;

  const EventTableRow({super.key, required this.widths, required this.event, required this.query});

  @override
  Widget build(BuildContext context) {
    // 메타 regular 14 gray500 (커뮤니티 표와 동일).
    final metaStyle = SDSTextStyle.regular.copyWith(
      fontSize: 14,
      color: SDSColor.gray500,
    );
    final category = event.category;

    // hover 잉크는 조상 Material 캔버스에 그려진다 — 페이지 흰 배경 Container가
    // 그 위를 덮어 안 보이므로, 행 바로 위에 투명 Material을 끼운다.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => openEventPreview(context, event),
        // hover 시 행 배경 — 검정 3% (커뮤니티 표 행과 동일).
        hoverColor: SDSColor.gray900.withValues(alpha: 0.03),
        child: eventTableRowShell(
          widths: widths,
          // 행 높이 52 고정(구분선 포함) — 커뮤니티 표와 동일.
          rowHeight: 52,
          border: Border(bottom: BorderSide(color: SDSColor.gray100)),
          categoryCell: (category == null || category.isEmpty)
              ? const SizedBox.shrink()
              // Row로 감싸야 칩이 내용 폭으로 hug된다 — Align 아래에 두면
              // 칩 Container(alignment 있음)가 열 폭(76)까지 늘어난다(실측).
              : Row(
                  children: [
                    CommunityCategoryChip(
                      label: category,
                      background: SDSColor.blue50,
                      textColor: SDSColor.snowliveBlue,
                    ),
                  ],
                ),
          nameCell: Text(
            event.crawlAccountName ?? event.crawlAccountUsername ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // 이름은 메타(gray500)와 달리 블랙 — 사용자 확정.
            style: metaStyle.copyWith(color: SDSColor.gray900),
          ),
          titleCell: _EventTitleLine(event: event, query: query),
          dateCell: Text(
            communityDateLabelOf(event.uploadTime),
            maxLines: 1,
            style: metaStyle,
          ),
          viewsCell: Text(
            '${event.viewCount ?? 0}',
            maxLines: 1,
            style: metaStyle,
          ),
        ),
      ),
    );
  }
}

/// 각종소식 모바일 카드 행 — 썸네일 + 제목, 아래 이름 | 작성일 | 조회수.
class EventCardRow extends StatelessWidget {
  final EventModel event;
  final String query;

  const EventCardRow({super.key, required this.event, required this.query});

  @override
  Widget build(BuildContext context) {
    final category = event.category;
    // 메타 regular 13 gray500(lh16) — 커뮤니티 카드와 동일.
    final metaStyle = SDSTextStyle.regular.copyWith(
      fontSize: 13,
      height: 16 / 13,
      color: SDSColor.gray500,
    );
    final titleStyle = SDSTextStyle.regular.copyWith(
      fontSize: 15,
      color: SDSColor.gray900,
    );

    return InkWell(
      onTap: () => openEventPreview(context, event),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: SDSColor.gray100)),
        ),
        // 커뮤니티 카드와 동일 — 패딩 13.
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Builder(
          builder: (context) {
            // 썸네일 변 = 제목 2줄 + 10 + 메타(16) 높이 고정 — 제목이 1줄이어도
            // 같은 크기(사용자 확정, 목록 썸네일 크기 통일). 제목 한 줄 높이는
            // TextPainter로 실측한다(IntrinsicHeight는 제목 안의 칩 placeholder
            // 때문에 예외가 나서 못 쓴다).
            final lineProbe = TextPainter(
              text: TextSpan(text: ' ', style: titleStyle),
              textDirection: TextDirection.ltr,
            )..layout();
            final side = lineProbe.preferredLineHeight * 2 + 10 + 16;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 표와 같은 제목 줄 규칙 — [분류 칩] 제목 (모바일 칩↔제목 8).
                      // 제목은 모바일만 2줄까지(사용자 확정). 칩은 Row가 아니라
                      // **텍스트 흐름 안**(WidgetSpan) — Row로 두면 둘째 줄이 칩
                      // 오른쪽에 들여써지는데, 인라인이면 왼쪽 끝부터 이어진다.
                      HighlightedText(
                        text: eventTitleLine(event),
                        query: query,
                        maxLines: 2,
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 15,
                          color: SDSColor.gray900,
                        ),
                        leading: (category == null || category.isEmpty)
                            ? null
                            : WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  // WidgetSpan은 줄 너비를 제약으로 주므로 칩
                                  // Container(alignment 있음)가 늘어난다 — Row(min)로
                                  // 감싸 내용 폭으로 hug시킨다(표 분류 셀과 동일 트릭).
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CommunityCategoryChip(
                                        label: category,
                                        background: SDSColor.blue50,
                                        textColor: SDSColor.snowliveBlue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      // 제목 줄 ↔ 메타 줄 10 (커뮤니티 카드와 동일).
                      const SizedBox(height: 10),
                      // 이름 | 작성일 | 👁 조회수 — 구분자는 1×10 세로선(gray200).
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              event.crawlAccountName ??
                                  event.crawlAccountUsername ??
                                  '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              // 이름은 블랙 — 표와 동일 결정.
                              style: metaStyle.copyWith(
                                color: SDSColor.gray900,
                              ),
                            ),
                          ),
                          communityMetaDivider(),
                          Text(
                            communityDateLabelOf(event.uploadTime),
                            style: metaStyle,
                          ),
                          communityMetaDivider(),
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: SDSColor.gray400,
                          ),
                          const SizedBox(width: 2),
                          Text('${event.viewCount ?? 0}', style: metaStyle),
                        ],
                      ),
                    ],
                  ),
                ),
                // 콘텐츠 ↔ 썸네일 16 (사용자 확정).
                const SizedBox(width: 16),
                // 정사각 썸네일 **우측**(표와 동일 결정) — 변은 콘텐츠 높이.
                EventThumbnail(
                  url: event.thumbImgUrl,
                  width: side,
                  height: side,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}

/// 제목 셀 — `[썸네일] 제목` 한 줄. 분류는 별도 열로 빠졌다.
class _EventTitleLine extends StatelessWidget {
  final EventModel event;
  final String query;

  const _EventTitleLine({required this.event, required this.query});

  @override
  Widget build(BuildContext context) {
    // 제목 regular 15(커뮤니티 표 제목과 동일), 썸네일은 제목 **오른쪽**
    // (커뮤니티의 사진 아이콘 자리 — 사용자 결정).
    return Row(
      children: [
        Flexible(
          child: HighlightedText(
            text: eventTitleLine(event),
            query: query,
            maxLines: 1,
            style: SDSTextStyle.regular.copyWith(
              fontSize: 15,
              color: SDSColor.gray900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 정사각 썸네일(사용자 확정) — 높이는 기존 30 유지.
        EventThumbnail(url: event.thumbImgUrl, width: 30, height: 30),
      ],
    );
  }
}

/// 썸네일 이미지. 없거나 로드 실패 시 회색 자리표시자.
class EventThumbnail extends StatelessWidget {
  final String? url;
  final double width;
  final double height;

  const EventThumbnail({
    super.key,
    required this.url,
    this.width = 56,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: SDSColor.gray100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(Icons.image_outlined, size: 16, color: SDSColor.gray400),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        url!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}
