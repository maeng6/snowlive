import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_communityList.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_highlighted_text_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// 표 형태 목록의 열 규격(피그마 64:112373). 헤더와 데이터 행이 **같은 상수**를
// 쓰는 것만으로는 부족해서(구조가 갈라지면 결국 어긋난다) 아래
// communityTableRowShell 하나를 공유하게 한다. 제목만 가변폭(Expanded)이다.
// 메타 열(작성자/작성일/조회수) 사이 간격 — 목업 12 대신 눈으로 맞춘 확정값.
const double kCommunityColGap = 30;

/// 제목 영역 ↔ 메타 영역(작성자부터) 간격 — 열 간격(12)보다 넓다(목업 30).
const double kCommunityTitleMetaGap = 30;
const double kCommunityColAuthor = 80;
const double kCommunityColDate = 80;

/// 조회수 열. 댓글수는 제목 뒤 파란 `(N)`으로 옮겼고 썸네일 열은 없앴다(목업).
const double kCommunityColViews = 60;

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

/// 이미 파싱된 DateTime용(이벤트 모델은 DateTime으로 들고 있다).
/// 표기 형식을 한 곳에만 두기 위해 같은 포매터를 쓴다.
String communityDateLabelOf(DateTime? uploadTime) =>
    uploadTime == null ? '' : _communityDateFormat.format(uploadTime);

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
  required Widget viewsCell,
  Widget? previewLine,
  required Border border,
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 14),

  /// 지정하면 패딩 대신 **고정 높이**로 행을 그린다(텍스트 메트릭에 흔들리지 않음).
  /// 하단 보더 1px 포함 높이다. 검색 미리보기 줄은 이 높이 아래에 추가로 붙는다.
  double? rowHeight,
}) {
  final Widget row = Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // 행 앞(좌측) 여백 10 — hover 배경이 텍스트에 바로 붙지 않게(사용자 확정,
      // 헤더 행도 같은 셸이라 함께 밀려 열이 어긋나지 않는다).
      const SizedBox(width: 10),
      Expanded(child: titleCell),
      const SizedBox(width: kCommunityTitleMetaGap),
      SizedBox(width: kCommunityColAuthor, child: authorCell),
      const SizedBox(width: kCommunityColGap),
      SizedBox(width: kCommunityColDate, child: dateCell),
      const SizedBox(width: kCommunityColGap),
      SizedBox(width: kCommunityColViews, child: viewsCell),
    ],
  );

  return Container(
    decoration: BoxDecoration(border: border),
    padding: rowHeight != null ? EdgeInsets.zero : padding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rowHeight != null)
          SizedBox(height: rowHeight - border.bottom.width, child: row)
        else
          row,
        if (previewLine != null)
          Padding(
            // 좌 10 — 행 앞 여백과 시작선을 맞춘다.
            padding: const EdgeInsets.only(left: 10, top: 6, bottom: 12),
            child: previewLine,
          ),
      ],
    ),
  );
}

/// 표 헤더 행 (태블릿·데스크탑).
class CommunityTableHeaderRow extends StatelessWidget {
  const CommunityTableHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    // 피그마 64:112377 — 헤더 bold 14, 상 5 / 하 13(구분선까지).
    final style = SDSTextStyle.bold.copyWith(
      fontSize: 14,
      color: SDSColor.gray900,
    );
    return communityTableRowShell(
      padding: const EdgeInsets.only(top: 5, bottom: 13),
      border: Border(bottom: BorderSide(color: SDSColor.gray200)),
      titleCell: Text('제목', style: style),
      authorCell: Text('작성자', style: style),
      dateCell: Text('작성일', style: style),
      viewsCell: Text('조회수', style: style),
    );
  }
}

/// 표 데이터 행 (태블릿·데스크탑).
class CommunityTableRow extends StatelessWidget {
  final Community community;

  /// 강조할 검색어. 비어 있으면 강조하지 않고 미리보기 줄도 그리지 않는다.
  final String query;

  const CommunityTableRow({
    super.key,
    required this.community,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    // 메타 regular 14 gray500 (중고거래와 색 통일).
    final metaStyle = SDSTextStyle.regular.copyWith(
      fontSize: 14,
      color: SDSColor.gray500,
    );
    final preview = query.isEmpty ? '' : communityPreviewText(community);

    // hover 잉크는 조상 Material 캔버스에 그려진다 — 페이지 흰 배경 Container가
    // 그 위를 덮어 안 보이므로, 행 바로 위에 투명 Material을 끼운다.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => openCommunityDetail(community),
        // hover 시 행 배경 — gray50(≈검정 4%)보다 연한 검정 3% (사용자 확정,
        // 각종소식과 동일). 맞는 토큰이 없어 opacity로 만든다.
        hoverColor: SDSColor.gray900.withValues(alpha: 0.03),
        child: communityTableRowShell(
          // 행 높이 52 고정(구분선 포함, 확정값).
          rowHeight: 52,
          border: Border(bottom: BorderSide(color: SDSColor.gray100)),
          titleCell: CommunityTitleLine(community: community, query: query),
          authorCell: Text(
            community.userInfo?.displayName ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: metaStyle,
          ),
          dateCell: Text(
            communityDateLabel(community.uploadTime),
            maxLines: 1,
            style: metaStyle,
          ),
          viewsCell: Text(
            '${community.viewsCount ?? 0}',
            maxLines: 1,
            style: metaStyle,
          ),
          previewLine: preview.isEmpty
              ? null
              : HighlightedText(
                  text: preview,
                  query: query,
                  maxLines: 2,
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: SDSColor.gray500,
                  ),
                ),
        ),
      ),
    );
  }
}

/// 모바일 카드형 행.
class CommunityCardRow extends StatelessWidget {
  final Community community;
  final String query;

  const CommunityCardRow({
    super.key,
    required this.community,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final preview = query.isEmpty ? '' : communityPreviewText(community);
    // 메타 regular 13 gray500(lh16) — 중고거래와 색 통일, 표 행과 동일.
    final metaStyle = SDSTextStyle.regular.copyWith(
      fontSize: 13,
      height: 16 / 13,
      color: SDSColor.gray500,
    );

    return InkWell(
      onTap: () => openCommunityDetail(community),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: SDSColor.gray100)),
        ),
        // 피그마 64:117265 — 행 pitch 73(콘텐츠 46 + 13*2 + 구분선 1).
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 표와 같은 제목 줄 규칙 — 칩 + 제목 + 이미지 아이콘 + 파란 (N)
            CommunityTitleLine(community: community, query: query),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 4),
              HighlightedText(
                text: preview,
                query: query,
                maxLines: 2,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 13,
                  color: SDSColor.gray500,
                ),
              ),
            ],
            // 제목 줄 ↔ 메타 줄 10 (피그마 64:117459)
            const SizedBox(height: 10),
            // 목업: 작성자 | 날짜 | 👁 조회수 — 구분자는 1×10 세로선(gray200).
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
                communityMetaDivider(),
                Text(
                  communityDateLabel(community.uploadTime),
                  style: metaStyle,
                ),
                communityMetaDivider(),
                // 아웃라인 눈 아이콘(목업 에셋) — PNG는 틴트하면 눈알(흰색)까지
                // 단색으로 덮여 실루엣이 된다. 틴트는 메타 텍스트와 동일(gray600).
                Icon(Icons.visibility, size: 14, color: SDSColor.gray400),
                const SizedBox(width: 2),
                Text('${community.viewsCount ?? 0}', style: metaStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 메타 구분자 — 1×10 세로선 gray200, 좌우 간격 10 (피그마 64:117471).
/// 각종소식 모바일 카드도 같은 구분자를 쓴다.
Widget communityMetaDivider() => Container(
  width: 1,
  height: 10,
  margin: const EdgeInsets.symmetric(horizontal: 10),
  color: SDSColor.gray200,
);

/// 카테고리 칩. 모바일 앱 목록과 같은 규칙 — 시즌방일 때만 하위 카테고리 칩이 붙는다.
List<Widget> communityCategoryChips(
  Community community, {
  // 마지막 배지 ↔ 제목: PC·태블릿 12 / 모바일 8 (확정값 — 배지가 하나여도 동일).
  double titleGap = 12,
}) {
  final sub = community.categorySub;
  if (sub == null || sub.isEmpty) return const [];
  final sub2 = community.categorySub2;
  // 배지 사이 6.
  return [
    CommunityCategoryChip(
      label: sub,
      background: SDSColor.blue50,
      textColor: SDSColor.snowliveBlue,
    ),
    if (sub == '시즌방' && sub2 != null && sub2.isNotEmpty) ...[
      const SizedBox(width: 6),
      CommunityCategoryChip(
        label: sub2,
        background: SDSColor.gray50,
        textColor: SDSColor.gray700,
      ),
    ],
    SizedBox(width: titleGap),
  ];
}

class CommunityCategoryChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;

  const CommunityCategoryChip({
    super.key,
    required this.label,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // 피그마 64:112414 — 라운드 2, 좌우 패딩 4, regular 11, 높이 20 고정.
    // ⚠️ minHeight+alignment 조합은 금물 — alignment가 있으면 Container가 부모의
    // 최대 높이(고정 행 47px)까지 늘어나 배지가 세로로 길어진다(실측).
    return Container(
      height: 20,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(fontSize: 11, color: textColor),
      ),
    );
  }
}

/// 제목 줄 — `[칩] 제목 [🖼] [(N)]` (목업).
///
/// 사진이 있으면 제목 뒤에 이미지 아이콘, 댓글이 있으면 파란 `(N)`이 붙는다.
/// 둘 다 **있을 때만** 그린다 — 0건에 `(0)`을 붙이면 줄이 지저분해진다.
class CommunityTitleLine extends StatelessWidget {
  final Community community;
  final String query;

  const CommunityTitleLine({
    super.key,
    required this.community,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final commentCount = community.commentCount ?? 0;
    final thumb = community.thumbImg;
    final hasImage = thumb != null && thumb.isNotEmpty;

    // 피그마 64:112417 — 제목 regular 15, 사진 아이콘 18(목업 에셋), (N) bold 15, 간격 4.
    return Row(
      children: [
        ...communityCategoryChips(
          community,
          titleGap: context.screenType == WebScreenType.mobile ? 8 : 12,
        ),
        Flexible(
          child: HighlightedText(
            text: community.title ?? '',
            query: query,
            maxLines: 1,
            style: SDSTextStyle.regular.copyWith(
              fontSize: 15,
              color: SDSColor.gray900,
            ),
          ),
        ),
        if (hasImage) ...[
          const SizedBox(width: 4),
          // 사진 아이콘: PC·태블릿 18 / 모바일 16 (목업 20 대신 눈으로 맞춘 확정값).
          SvgPicture.asset(
            'assets/imgs/icons/icon_community_photo.svg',
            width: context.screenType == WebScreenType.mobile ? 16 : 18,
            height: context.screenType == WebScreenType.mobile ? 16 : 18,
          ),
        ],
        if (commentCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($commentCount)',
            style: SDSTextStyle.bold.copyWith(
              fontSize: 15,
              color: SDSColor.snowliveBlue,
            ),
          ),
        ],
      ],
    );
  }
}
