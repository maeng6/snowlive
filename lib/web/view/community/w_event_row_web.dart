import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_event.dart';
import 'package:com.snowlive/web/view/community/w_community_row_web.dart';
import 'package:com.snowlive/web/widget/w_highlighted_text_web.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 크롤링된 캡션 원문을 목록용 한 줄로 누른다.
/// 줄바꿈이 그대로 들어가면 행 높이가 밀리고 말줄임이 안 걸린다.
String eventTitleLine(EventModel event) {
  final raw = event.title ?? '';
  return raw.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// 이벤트 항목의 랜딩 URL을 외부 브라우저로 연다.
///
/// 이벤트는 상세 화면이 없다(크롤링 데이터) → 행을 누르면 원본으로 보낸다.
/// [w_community_body_web.dart]의 링크 처리와 같은 규칙 — **http/https만** 연다
/// (`javascript:` 같은 스킴 차단). URL이 없으면 아무 것도 하지 않는다.
Future<void> openEventLanding(EventModel event) async {
  final raw = event.landingUrl;
  if (raw == null || raw.isEmpty) return;
  final uri = Uri.tryParse(raw);
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// 이벤트 표 데이터 행 (태블릿·데스크탑).
/// 커뮤니티 표와 열이 어긋나지 않도록 [communityTableRowShell]을 공유한다.
class EventTableRow extends StatelessWidget {
  final EventModel event;

  /// 강조할 검색어. 비어 있으면 강조하지 않는다.
  final String query;

  const EventTableRow({super.key, required this.event, required this.query});

  @override
  Widget build(BuildContext context) {
    final metaStyle = SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray700);

    return InkWell(
      onTap: () => openEventLanding(event),
      child: communityTableRowShell(
        border: Border(bottom: BorderSide(color: SDSColor.gray100)),
        titleCell: _EventTitleLine(event: event, query: query),
        authorCell: Text(
          event.userInfo?.displayName ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: metaStyle,
        ),
        dateCell: Text(
          communityDateLabelOf(event.uploadTime),
          maxLines: 1,
          style: metaStyle,
        ),
        viewsCell: Text('${event.viewCount ?? 0}', maxLines: 1, style: metaStyle),
      ),
    );
  }
}

/// 이벤트 모바일 카드 행. 커뮤니티 카드와 같은 구성이되 댓글수가 없다.
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EventTitleLine(event: event, query: query),
            const SizedBox(height: 6),
            Row(
              children: [
                Flexible(
                  child: Text(
                    event.userInfo?.displayName ?? '',
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
    );
  }
}

/// `[카테고리 칩] 제목` 한 줄.
///
/// 커뮤니티와 달리 **이미지 아이콘과 댓글수 `(N)`이 없다** — 크롤링 항목은 전부
/// 썸네일이 있어서 아이콘이 항상 켜지면 아무 정보도 주지 못하고, 댓글 기능 자체가 없다.
class _EventTitleLine extends StatelessWidget {
  final EventModel event;
  final String query;

  const _EventTitleLine({required this.event, required this.query});

  @override
  Widget build(BuildContext context) {
    final category = event.category;
    return Row(
      children: [
        if (category != null && category.isNotEmpty) ...[
          CommunityCategoryChip(
            label: category,
            background: SDSColor.blue50,
            textColor: SDSColor.snowliveBlue,
          ),
          const SizedBox(width: 6),
        ],
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
