import 'dart:ui' as ui;

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
// 메타 열(작성자/작성일/조회수) 사이 간격. 각종소식 표(kEventColGap)도 같은 30이지만
// 상수는 분리돼 있다 — 두 표의 열 구성이 달라 따로 조정할 수 있어야 한다.
const double kCommunityColGap = 30;

/// 글자 폭 실측. 열 폭을 숫자로 박으면 글꼴 메트릭에 따라 끝이 잘린다(날짜 80에서
/// '일'이 잘렸다). 그렇다고 폭을 풀면 행마다 열 시작선이 어긋난다 → 재서 고정한다.
///
/// [textScaler]를 꼭 넘긴다 — 브라우저 글자 배율이 100%가 아니면 실제 렌더가
/// 측정값보다 넓어져 끝 글자가 다시 잘린다.
double measureWebTextWidth(
  String text,
  TextStyle style, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    // `intl`도 TextDirection을 내보내서 이름이 겹친다 → 별칭을 쓴다.
    textDirection: ui.TextDirection.ltr,
    textScaler: textScaler,
  )..layout();
  return painter.width;
}

/// 표 메타 셀 글자 — 두 표(커뮤니티·각종소식)의 행·헤더·측정이 **같은 값**을 쓴다.
/// 측정과 렌더가 다른 스타일을 쓰면 폭이 어긋나 끝 글자가 잘린다.
TextStyle get webTableMetaStyle => SDSTextStyle.regular.copyWith(fontSize: 14);
TextStyle get webTableHeaderStyle => SDSTextStyle.bold.copyWith(fontSize: 14);

/// 열 폭에 더하는 여유. 서브픽셀 반올림·배율 환산에서 1px이 모자라 끝 글자가
/// 잘리는 걸 막는다(남는 4px은 열 간격 30 안에서 눈에 띄지 않는다).
const double _kMetaColumnSlack = 4;

/// 가장 넓은 숫자 글리프. Pretendard는 고정폭 숫자가 아니라 숫자에 따라 폭이 다르다.
String _widestDigitGlyph(TextScaler textScaler) {
  var widest = '0';
  var max = 0.0;
  for (var d = 0; d <= 9; d++) {
    final w = measureWebTextWidth('$d', webTableMetaStyle, textScaler: textScaler);
    if (w > max) {
      max = w;
      widest = '$d';
    }
  }
  return widest;
}

/// 날짜 열 측정용 **최악 표본** — 표시 형식에 가장 넓은 숫자를 채운 문자열.
///
/// 그 페이지에 실제로 있는 날짜만 재면 (1) 다른 숫자 조합이 더 넓을 때 잘리고,
/// (2) 페이지를 넘길 때마다 열 폭이 흔들린다. 형식이 고정이므로 최악을 재는 게 맞다.
String worstCaseDateSample(TextScaler textScaler) {
  final digit = _widestDigitGlyph(textScaler);
  return _communityDateFormat
      .format(DateTime(2222, 12, 22))
      .replaceAll(RegExp(r'\d'), digit);
}

/// 숫자 열(조회수) 측정용 최악 표본 — 가장 긴 값의 자릿수를 가장 넓은 숫자로 채운다.
String worstCaseNumberSample(List<String> values, TextScaler textScaler) {
  var digits = 1;
  for (final v in values) {
    if (v.length > digits) digits = v.length;
  }
  return _widestDigitGlyph(textScaler) * digits;
}

/// 메타 열 한 칸의 폭 — 헤더 글자와 주어진 표본 중 가장 넓은 값 + 여유.
double metaColumnWidth({
  required List<String> samples,
  required String headerText,
  required TextScaler textScaler,
}) {
  var max = measureWebTextWidth(headerText, webTableHeaderStyle, textScaler: textScaler);
  for (final v in samples) {
    final w = measureWebTextWidth(v, webTableMetaStyle, textScaler: textScaler);
    if (w > max) max = w;
  }
  return max.ceilToDouble() + _kMetaColumnSlack;
}

/// 표 메타 열(작성자·작성일·조회수) 폭.
///
/// 닉네임(작성자)은 **그 페이지에 실제로 있는 값 중 가장 긴 것**, 숫자 열(작성일·
/// 조회수)은 **형식상 최악의 값**을 재서 헤더와 모든 행이 같은 폭을 쓴다 —
/// 잘리지도, 행마다 어긋나지도 않는다.
///
/// ⚠️ 폭을 `static final`로 캐시하지 않는다 — 웹에서는 글꼴(Pretendard)이 늦게
/// 로드되는데, 그전에 한 번 재서 굳히면 실제 렌더보다 좁은 폭이 세션 내내 남아
/// 끝 글자가 잘린다. 측정은 TextPainter 몇 번이라 매 빌드에 재도 싸다.
class CommunityMetaWidths {
  final double author;
  final double date;
  final double views;

  const CommunityMetaWidths({required this.author, required this.date, required this.views});

  /// 로딩 스켈레톤·헤더가 쓰는 폭. 실제 데이터가 올 때 열이 크게 안 움직이도록
  /// **대표적인 길이의 표본**으로 재둔다(닉네임 6자, 날짜·조회수는 최악값).
  static CommunityMetaWidths skeletonOf(BuildContext context) => CommunityMetaWidths._from(
        const ['스노우라이버'],
        const ['1234'],
        MediaQuery.textScalerOf(context),
      );

  factory CommunityMetaWidths._from(
      List<String> authors, List<String> views, TextScaler textScaler) {
    return CommunityMetaWidths(
      author: metaColumnWidth(
        samples: authors,
        headerText: '작성자',
        textScaler: textScaler,
      ),
      date: metaColumnWidth(
        samples: [worstCaseDateSample(textScaler)],
        headerText: '작성일',
        textScaler: textScaler,
      ),
      views: metaColumnWidth(
        samples: [worstCaseNumberSample(views, textScaler)],
        headerText: '조회수',
        textScaler: textScaler,
      ),
    );
  }

  factory CommunityMetaWidths.of(BuildContext context, List<Community> items) =>
      CommunityMetaWidths._from(
        [for (final c in items) c.userInfo?.displayName ?? ''],
        [for (final c in items) '${c.viewsCount ?? 0}'],
        MediaQuery.textScalerOf(context),
      );
}

/// 제목 영역 ↔ 메타 영역(작성자부터) 간격 — 열 간격(12)보다 넓다(목업 30).
const double kCommunityTitleMetaGap = 30;


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

/// 열 폭이 어떤 이유로든 모자랄 때 **자르지 않고** 열 간격(30) 쪽으로 넘겨 그린다.
/// 끝 글자가 사라지는 것보다 간격을 몇 px 먹는 편이 낫다 — 열 폭은 이미 최악값으로
/// 재므로 평소엔 넘치지 않는다.
Widget webTableNoClipText(String text, TextStyle style) => Text(
  text,
  maxLines: 1,
  softWrap: false,
  overflow: TextOverflow.visible,
  style: style,
);

/// 표 한 줄의 골격. **헤더 행과 데이터 행이 이 함수를 공유**하므로 열이 어긋나지 않는다.
Widget communityTableRowShell({
  required CommunityMetaWidths widths,
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
      // 폭은 숫자로 박지 않고 그 페이지의 가장 긴 값에서 재 온다([CommunityMetaWidths]) —
      // 헤더와 모든 행이 같은 값을 받으므로 열 시작선이 어긋나지 않는다.
      SizedBox(width: widths.author, child: authorCell),
      const SizedBox(width: kCommunityColGap),
      SizedBox(width: widths.date, child: dateCell),
      const SizedBox(width: kCommunityColGap),
      SizedBox(width: widths.views, child: viewsCell),
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
  final CommunityMetaWidths widths;

  const CommunityTableHeaderRow({super.key, required this.widths});

  @override
  Widget build(BuildContext context) {
    // 피그마 64:112377 — 헤더 bold 14, 상 5 / 하 13(구분선까지).
    final style = SDSTextStyle.bold.copyWith(
      fontSize: 14,
      color: SDSColor.gray900,
    );
    return communityTableRowShell(
      widths: widths,
      padding: const EdgeInsets.only(top: 5, bottom: 13),
      border: Border(bottom: BorderSide(color: SDSColor.gray200)),
      titleCell: Text('제목', style: style),
      authorCell: webTableNoClipText('작성자', style),
      dateCell: webTableNoClipText('작성일', style),
      viewsCell: webTableNoClipText('조회수', style),
    );
  }
}

/// 표 데이터 행 (태블릿·데스크탑).
class CommunityTableRow extends StatelessWidget {
  final CommunityMetaWidths widths;
  final Community community;

  /// 강조할 검색어. 비어 있으면 강조하지 않고 미리보기 줄도 그리지 않는다.
  final String query;

  const CommunityTableRow({
    super.key,
    required this.widths,
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
          widths: widths,
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
          dateCell: webTableNoClipText(communityDateLabel(community.uploadTime), metaStyle),
          viewsCell: webTableNoClipText('${community.viewsCount ?? 0}', metaStyle),
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
                webTableNoClipText(
                  communityDateLabel(community.uploadTime),
                  metaStyle,
                ),
                communityMetaDivider(),
                // 아웃라인 눈 아이콘(목업 에셋) — PNG는 틴트하면 눈알(흰색)까지
                // 단색으로 덮여 실루엣이 된다. 틴트는 메타 텍스트와 동일(gray600).
                Icon(Icons.visibility, size: 14, color: SDSColor.gray400),
                const SizedBox(width: 2),
                webTableNoClipText('${community.viewsCount ?? 0}', metaStyle),
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

  /// 제목에 밑줄을 긋는다 — 줄 전체를 칠하는 대신 **제목만** 반응하게 하는
  /// hover 표시(홈 커뮤니티 목록). 목록 화면들은 행 배경으로 반응하므로 false.
  final bool underline;

  const CommunityTitleLine({
    super.key,
    required this.community,
    required this.query,
    this.underline = false,
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
              decoration: underline ? TextDecoration.underline : null,
              decorationColor: SDSColor.gray900,
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
