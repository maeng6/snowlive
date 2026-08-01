import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 검색어와 일치하는 구간만 색을 바꿔 보여주는 텍스트.
///
/// 커뮤니티 검색 결과에서 제목·본문 미리보기의 일치 구간을 파랗게 칠하는 데 쓴다.
/// `RichText`가 아니라 `Text.rich`를 쓰는 이유: `RichText`는 DefaultTextStyle을
/// 상속하지 않아서 폰트가 엔진 기본으로 떨어진다.
class HighlightedText extends StatelessWidget {
  final String text;

  /// 강조할 검색어. 비어 있으면 강조 없이 평범한 텍스트로 그린다.
  final String query;
  final TextStyle style;
  final Color highlightColor;
  final int? maxLines;
  final TextOverflow overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    this.highlightColor = SDSColor.snowliveBlue,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    final spans = _buildSpans();
    if (spans == null) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }
    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// 강조가 필요 없으면 null을 반환한다(그때는 평범한 Text로 그린다).
  List<TextSpan>? _buildSpans() {
    final needle = query.trim();
    // 빈 검색어로 indexOf 루프를 돌리면 start가 늘지 않아 무한 루프에 빠진다.
    if (needle.isEmpty || text.isEmpty) return null;

    final haystack = text.toLowerCase();
    final lowerNeedle = needle.toLowerCase();
    // toLowerCase가 길이를 바꾸는 언어가 있다. 인덱스를 원문에 그대로 쓰므로
    // 길이가 달라지면 강조를 포기하는 게 안전하다.
    if (haystack.length != text.length) return null;

    final spans = <TextSpan>[];
    final highlightStyle = style.copyWith(color: highlightColor);
    var from = 0;
    while (true) {
      final idx = haystack.indexOf(lowerNeedle, from);
      if (idx < 0) break;
      if (idx > from) spans.add(TextSpan(text: text.substring(from, idx)));
      // 잘라내는 건 원문 — 대소문자를 보존한다.
      spans.add(TextSpan(text: text.substring(idx, idx + needle.length), style: highlightStyle));
      from = idx + needle.length;
    }
    if (spans.isEmpty) return null;
    // 마지막 매치 뒤의 꼬리를 빼먹으면 텍스트가 잘려 보인다.
    if (from < text.length) spans.add(TextSpan(text: text.substring(from)));
    return spans;
  }
}
