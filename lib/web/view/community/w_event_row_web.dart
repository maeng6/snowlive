import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_event.dart';
import 'package:com.snowlive/web/view/community/w_community_row_web.dart';
import 'package:com.snowlive/web/viewmodel/event/vm_eventListPagination_web.dart';
import 'package:com.snowlive/web/widget/w_highlighted_text_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 각종소식(이벤트) 표 열 규격. 헤더와 데이터 행이 [eventTableRowShell] 하나를
// 공유해 열이 어긋나지 않게 한다. 커뮤니티와 열 구성이 달라(분류·이름 별도 열,
// 작성자 없음, 제목에 썸네일) 전용 셸을 둔다.
const double kEventColGap = SDSSpacing.md;
const double kEventColCategory = 76; // 분류
const double kEventColName = 110; // 이름(출처 계정)
const double kEventColDate = 88; // 작성일
const double kEventColViews = 64; // 조회수

/// 크롤링된 캡션 원문을 목록용 한 줄로 누른다.
/// 줄바꿈이 그대로 들어가면 행 높이가 밀리고 말줄임이 안 걸린다.
String eventTitleLine(EventModel event) {
  final raw = event.title ?? '';
  return raw.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// 이벤트 항목을 눌렀을 때: 조회수를 올리고 랜딩 URL로 외부 이동한다.
///
/// 이벤트는 상세 화면이 없다(크롤링 데이터) → 행을 누르면 원본으로 보낸다.
/// 조회수 증가·URL 검증(http/https만)·게스트 처리는 모두 뷰모델이 맡는다.
void openEventLanding(EventModel event) {
  Get.find<EventListPaginationViewModelWeb>().openEvent(event);
}

/// 각종소식 표 한 줄의 골격. 헤더 행과 데이터 행이 공유한다.
Widget eventTableRowShell({
  required Widget categoryCell,
  required Widget nameCell,
  required Widget titleCell,
  required Widget dateCell,
  required Widget viewsCell,
  required Border border,
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 12),
}) {
  return Container(
    decoration: BoxDecoration(border: border),
    padding: padding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: kEventColCategory, child: categoryCell),
        const SizedBox(width: kEventColGap),
        SizedBox(width: kEventColName, child: nameCell),
        const SizedBox(width: kEventColGap),
        Expanded(child: titleCell),
        const SizedBox(width: kEventColGap),
        SizedBox(width: kEventColDate, child: dateCell),
        const SizedBox(width: kEventColGap),
        SizedBox(width: kEventColViews, child: viewsCell),
      ],
    ),
  );
}

/// 각종소식 표 헤더 (태블릿·데스크탑) — 분류 | 이름 | 제목 | 작성일 | 조회수.
class EventTableHeaderRow extends StatelessWidget {
  const EventTableHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    final style = SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900);
    return eventTableRowShell(
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
  final EventModel event;

  /// 강조할 검색어. 비어 있으면 강조하지 않는다.
  final String query;

  const EventTableRow({super.key, required this.event, required this.query});

  @override
  Widget build(BuildContext context) {
    final metaStyle = SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray700);
    final category = event.category;

    return InkWell(
      onTap: () => openEventLanding(event),
      child: eventTableRowShell(
        border: Border(bottom: BorderSide(color: SDSColor.gray100)),
        categoryCell: (category == null || category.isEmpty)
            ? const SizedBox.shrink()
            : Align(
                alignment: Alignment.centerLeft,
                child: CommunityCategoryChip(
                  label: category,
                  background: SDSColor.blue50,
                  textColor: SDSColor.snowliveBlue,
                ),
              ),
        nameCell: Text(
          event.crawlAccountName ?? event.crawlAccountUsername ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: metaStyle,
        ),
        titleCell: _EventTitleLine(event: event, query: query),
        dateCell: Text(communityDateLabelOf(event.uploadTime), maxLines: 1, style: metaStyle),
        viewsCell: Text('${event.viewCount ?? 0}', maxLines: 1, style: metaStyle),
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
    final metaStyle = SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray700);

    return InkWell(
      onTap: () => openEventLanding(event),
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: SDSColor.gray100))),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventThumbnail(url: event.thumbImgUrl),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightedText(
                    text: eventTitleLine(event),
                    query: query,
                    maxLines: 2,
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          event.crawlAccountName ?? event.crawlAccountUsername ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: metaStyle,
                        ),
                      ),
                      Text('  |  ',
                          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray300)),
                      Text(communityDateLabelOf(event.uploadTime), style: metaStyle),
                      Text('  |  ',
                          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray300)),
                      Image.asset('assets/imgs/icons/icon_eye_rounded.png', width: 14, height: 14),
                      const SizedBox(width: 3),
                      Text('${event.viewCount ?? 0}', style: metaStyle),
                    ],
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

/// 제목 셀 — `[썸네일] 제목` 한 줄. 분류는 별도 열로 빠졌다.
class _EventTitleLine extends StatelessWidget {
  final EventModel event;
  final String query;

  const _EventTitleLine({required this.event, required this.query});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EventThumbnail(url: event.thumbImgUrl, width: 44, height: 30),
        const SizedBox(width: 8),
        Flexible(
          child: HighlightedText(
            text: eventTitleLine(event),
            query: query,
            maxLines: 1,
            style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
          ),
        ),
      ],
    );
  }
}

/// 썸네일 이미지. 없거나 로드 실패 시 회색 자리표시자.
class EventThumbnail extends StatelessWidget {
  final String? url;
  final double width;
  final double height;

  const EventThumbnail({super.key, required this.url, this.width = 56, this.height = 40});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: SDSColor.gray100, borderRadius: BorderRadius.circular(4)),
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
