import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_communityList.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/widget/w_highlighted_text_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// 표 형태 목록의 열 규격. 헤더와 데이터 행이 **같은 상수**를 쓰는 것만으로는
// 부족해서(구조가 갈라지면 결국 어긋난다) 아래 communityTableRowShell 하나를
// 공유하게 한다. 제목만 가변폭(Expanded)이다.
const double kCommunityColGap = SDSSpacing.md;
const double kCommunityColAuthor = 96;
const double kCommunityColDate = 88;
const double kCommunityColCounts = 100;

/// 썸네일 열은 이미지가 없는 행에서도 폭을 예약한다. 그러지 않으면 행마다 제목
/// 칸의 실제 폭이 달라져 말줄임 위치가 들쭉날쭉해진다(실데이터 82건 중 14건만 썸네일).
const double kCommunityColThumb = 50;

final DateFormat _communityDateFormat = DateFormat('yyyy. MM. dd');

/// 목록에 쓰는 날짜 표기. 기존 `GetDatetime().yyyymmddFormatFromString`은 형식이
/// `yyyy.MM.dd`(공백 없음)이고 파싱 실패 시 예외를 던져서, 30건을 그리는 경로에는
/// 쓰지 않는다.
String communityDateLabel(String? uploadTime) {
  if (uploadTime == null) return '';
  final parsed = DateTime.tryParse(uploadTime);
  if (parsed == null) return '';
  return _communityDateFormat.format(parsed);
}

/// Quill Delta에서 뽑은 한 줄 미리보기. 본문이 이미지뿐이면 빈 문자열이 된다.
String communityPreviewText(Community community) {
  try {
    final raw = community.description?.toPlainText() ?? '';
    return raw
        // toPlainText는 이미지/임베드를 U+FFFC로 남긴다. 그대로 그리면 두부 박스가 보인다.
        .replaceAll('￼', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  } catch (_) {
    return '';
  }
}

/// 게시글 상세로 이동. 목록에서 VM을 미리 채우는 방식(중고거래)이 아니라 **id를 URL에
/// 실어** 보내서, 새로고침·링크 공유로 직접 들어와도 상세가 열리게 한다.
void openCommunityDetail(Community community) {
  final id = community.communityId;
  if (id == null) return;
  Get.toNamed('${WebRoutes.communityDetail}?id=$id');
}

/// 표 한 줄의 골격. **헤더 행과 데이터 행이 이 함수를 공유**하므로 열이 어긋나지 않는다.
Widget communityTableRowShell({
  required Widget titleCell,
  required Widget authorCell,
  required Widget dateCell,
  required Widget countsCell,
  Widget? thumbCell,
  Widget? previewLine,
  required Border border,
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 14),
}) {
  return Container(
    decoration: BoxDecoration(border: border),
    padding: padding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleCell),
            const SizedBox(width: kCommunityColGap),
            SizedBox(width: kCommunityColAuthor, child: authorCell),
            const SizedBox(width: kCommunityColGap),
            SizedBox(width: kCommunityColDate, child: dateCell),
            const SizedBox(width: kCommunityColGap),
            SizedBox(width: kCommunityColCounts, child: countsCell),
            const SizedBox(width: kCommunityColGap),
            SizedBox(width: kCommunityColThumb, child: thumbCell ?? const SizedBox.shrink()),
          ],
        ),
        if (previewLine != null)
          Padding(padding: const EdgeInsets.only(top: 6), child: previewLine),
      ],
    ),
  );
}

/// 표 헤더 행 (태블릿·데스크탑).
class CommunityTableHeaderRow extends StatelessWidget {
  const CommunityTableHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    final style = SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900);
    return communityTableRowShell(
      padding: const EdgeInsets.symmetric(vertical: 12),
      border: Border(bottom: BorderSide(color: SDSColor.gray200)),
      titleCell: Text('제목', style: style),
      authorCell: Text('작성자', style: style),
      dateCell: Text('작성일', style: style),
      countsCell: Text('조회수·댓글', style: style),
    );
  }
}

/// 표 데이터 행 (태블릿·데스크탑).
class CommunityTableRow extends StatelessWidget {
  final Community community;

  /// 강조할 검색어. 비어 있으면 강조하지 않고 미리보기 줄도 그리지 않는다.
  final String query;

  const CommunityTableRow({super.key, required this.community, required this.query});

  @override
  Widget build(BuildContext context) {
    final metaStyle = SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray700);
    final preview = query.isEmpty ? '' : communityPreviewText(community);
    final thumb = community.thumbImg;
    final hasThumb = thumb != null && thumb.isNotEmpty;

    return InkWell(
      onTap: () => openCommunityDetail(community),
      child: communityTableRowShell(
      border: Border(bottom: BorderSide(color: SDSColor.gray100)),
      titleCell: Row(
        children: [
          ...communityCategoryChips(community),
          Expanded(
            child: HighlightedText(
              text: community.title ?? '',
              query: query,
              maxLines: 1,
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
        ],
      ),
      authorCell: Text(
        community.userInfo?.displayName ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: metaStyle,
      ),
      dateCell: Text(communityDateLabel(community.uploadTime), maxLines: 1, style: metaStyle),
      countsCell: CommunityCounts(community: community, alignEnd: false),
      thumbCell: hasThumb ? CommunityThumb(url: thumb) : null,
      previewLine: preview.isEmpty
          ? null
          : HighlightedText(
              text: preview,
              query: query,
              maxLines: 2,
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
            ),
      ),
    );
  }
}

/// 모바일 카드형 행.
class CommunityCardRow extends StatelessWidget {
  final Community community;
  final String query;

  const CommunityCardRow({super.key, required this.community, required this.query});

  @override
  Widget build(BuildContext context) {
    final preview = query.isEmpty ? '' : communityPreviewText(community);
    final thumb = community.thumbImg;
    final hasThumb = thumb != null && thumb.isNotEmpty;
    final metaStyle = SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray700);

    return InkWell(
      onTap: () => openCommunityDetail(community),
      child: Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: SDSColor.gray100))),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...communityCategoryChips(community),
                    Expanded(
                      child: HighlightedText(
                        text: community.title ?? '',
                        query: query,
                        maxLines: 1,
                        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                      ),
                    ),
                  ],
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  HighlightedText(
                    text: preview,
                    query: query,
                    maxLines: 2,
                    style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        community.userInfo?.displayName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: metaStyle,
                      ),
                    ),
                    _metaDivider(),
                    Text(communityDateLabel(community.uploadTime), style: metaStyle),
                    _metaDivider(),
                    CommunityCounts(community: community, alignEnd: false),
                  ],
                ),
              ],
            ),
          ),
          if (hasThumb) ...[
            const SizedBox(width: SDSSpacing.md),
            CommunityThumb(url: thumb),
          ],
        ],
      ),
      ),
    );
  }
}

Widget _metaDivider() => Text(
      '  |  ',
      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray300),
    );

/// 카테고리 칩. 모바일 앱 목록과 같은 규칙 — 시즌방일 때만 하위 카테고리 칩이 붙는다.
List<Widget> communityCategoryChips(Community community) {
  final sub = community.categorySub;
  if (sub == null || sub.isEmpty) return const [];
  final sub2 = community.categorySub2;
  return [
    CommunityCategoryChip(label: sub, background: SDSColor.blue50, textColor: SDSColor.snowliveBlue),
    const SizedBox(width: 6),
    if (sub == '시즌방' && sub2 != null && sub2.isNotEmpty) ...[
      CommunityCategoryChip(label: sub2, background: SDSColor.gray50, textColor: SDSColor.gray700),
      const SizedBox(width: 6),
    ],
  ];
}

class CommunityCategoryChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;

  const CommunityCategoryChip({super.key, required this.label, required this.background, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: SDSTextStyle.regular.copyWith(fontSize: 11, color: textColor)),
    );
  }
}

/// 조회수·댓글수. 아이콘은 모바일 앱 목록과 같은 에셋을 쓴다.
class CommunityCounts extends StatelessWidget {
  final Community community;
  final bool alignEnd;

  const CommunityCounts({super.key, required this.community, required this.alignEnd});

  @override
  Widget build(BuildContext context) {
    final style = SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray700);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Image.asset('assets/imgs/icons/icon_eye_rounded.png', width: 14, height: 14),
        const SizedBox(width: 2),
        Text('${community.viewsCount ?? 0}', style: style),
        const SizedBox(width: 6),
        Image.asset('assets/imgs/icons/icon_reply_rounded.png', width: 14, height: 14),
        const SizedBox(width: 2),
        Text('${community.commentCount ?? 0}', style: style),
      ],
    );
  }
}

class CommunityThumb extends StatelessWidget {
  final String url;

  const CommunityThumb({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 0.5, color: SDSColor.gray200),
      ),
      clipBehavior: Clip.antiAlias,
      child: WebNetworkImage(url: url, width: 50, height: 50),
    );
  }
}
