import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:url_launcher/url_launcher.dart';

/// 본문 한 덩어리. 문단(텍스트) 또는 이미지.
sealed class CommunityBodyBlock {
  const CommunityBodyBlock();
}

class CommunityTextBlock extends CommunityBodyBlock {
  final List<_Piece> pieces;
  const CommunityTextBlock(this.pieces);
}

class CommunityImageBlock extends CommunityBodyBlock {
  final String url;

  /// **이미지들 사이의 순번**(블록 인덱스가 아니다). 라이트박스에 그대로 넘긴다.
  final int imageIndex;
  const CommunityImageBlock(this.url, this.imageIndex);
}

class _Piece {
  final String text;
  final bool bold;
  final bool underline;
  final String? link;
  const _Piece(this.text, {this.bold = false, this.underline = false, this.link});
}

/// Delta 파싱 결과. 블록과 이미지 URL 목록을 **한 번의 순회로 함께** 만든다.
class CommunityBodyParseResult {
  final List<CommunityBodyBlock> blocks;
  final List<String> imageUrls;
  const CommunityBodyParseResult(this.blocks, this.imageUrls);
}

/// Quill Delta → 블록 목록.
///
/// 주의할 점 두 가지:
///  - **op 경계와 문단 경계는 다르다.** 하나의 문자열 op 안에 개행이 여러 개 있을 수
///    있으므로 op 단위로 문단을 나누면 안 되고 `\n`으로 잘라야 한다.
///  - 이미지 인덱스를 **이 순회 안에서** 매긴다. 렌더링용 순회와 뷰어용 이미지 수집을
///    따로 돌면 인덱스가 어긋나서 엉뚱한 사진이 열린다.
CommunityBodyParseResult parseCommunityBody(quill.Document? document) {
  final blocks = <CommunityBodyBlock>[];
  final imageUrls = <String>[];
  if (document == null) return CommunityBodyParseResult(blocks, imageUrls);

  // Operation/Delta 타입은 flutter_quill barrel에 없다. toJson()으로 순수 Map을 받는다.
  final List<Map<String, dynamic>> ops;
  try {
    ops = document.toDelta().toJson();
  } catch (_) {
    return CommunityBodyParseResult(blocks, imageUrls);
  }

  var current = <_Piece>[];
  void flush() {
    // 공백뿐인 문단은 버린다. Quill 문서는 항상 '\n'으로 끝나서 빈 문단이 하나 남는다.
    if (current.any((p) => p.text.trim().isNotEmpty)) {
      blocks.add(CommunityTextBlock(List.unmodifiable(current)));
    }
    current = <_Piece>[];
  }

  for (final op in ops) {
    final data = op['insert'];
    final attrs = op['attributes'] as Map<String, dynamic>?;

    if (data is Map) {
      final url = data['image'];
      if (url is String && url.isNotEmpty) {
        flush();
        blocks.add(CommunityImageBlock(url, imageUrls.length));
        imageUrls.add(url);
      }
      // 실데이터의 임베드는 image뿐이다. 그 외는 무시한다.
      continue;
    }

    if (data is! String) continue;

    final bold = attrs?['bold'] == true;
    final underline = attrs?['underline'] == true;
    final link = attrs?['link'] is String ? attrs!['link'] as String : null;

    final segments = data.split('\n');
    for (var i = 0; i < segments.length; i++) {
      if (segments[i].isNotEmpty) {
        current.add(_Piece(segments[i], bold: bold, underline: underline, link: link));
      }
      // 마지막 조각 뒤에는 개행이 없다.
      if (i < segments.length - 1) flush();
    }
  }
  flush();

  return CommunityBodyParseResult(blocks, imageUrls);
}

/// 커뮤니티 본문 렌더러.
///
/// QuillEditor를 쓰지 않는다 — 읽기 전용 화면에 에디터의 스크롤·포커스 기계를 얹으면
/// 웹의 긴 페이지에서 중첩 스크롤이 생기고, 이미지 탭·문단 간격을 정확히 제어하기 어렵다.
/// 실데이터가 쓰는 서식은 bold·underline·link 3종뿐이라 직접 그리는 편이 단순하다.
class CommunityBodyWeb extends StatefulWidget {
  final quill.Document? document;

  /// 본문 이미지를 탭했을 때. 이미지 전체 목록과 탭한 인덱스를 넘긴다.
  final void Function(List<String> imageUrls, int index) onImageTap;

  const CommunityBodyWeb({super.key, required this.document, required this.onImageTap});

  @override
  State<CommunityBodyWeb> createState() => _CommunityBodyWebState();
}

class _CommunityBodyWebState extends State<CommunityBodyWeb> {
  late CommunityBodyParseResult _parsed;

  /// 링크 탭 인식기는 반드시 해제해야 한다(build마다 새로 만들면 누수).
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _parsed = parseCommunityBody(widget.document);
  }

  @override
  void didUpdateWidget(covariant CommunityBodyWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.document, widget.document)) {
      _disposeRecognizers();
      _parsed = parseCommunityBody(widget.document);
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  Future<void> _openLink(String raw) async {
    final uri = Uri.tryParse(raw);
    // http/https만 연다(javascript: 같은 스킴 차단).
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_parsed.blocks.isEmpty) return const SizedBox.shrink();
    _disposeRecognizers();

    final children = <Widget>[];
    for (var i = 0; i < _parsed.blocks.length; i++) {
      final block = _parsed.blocks[i];
      if (i > 0) children.add(SizedBox(height: block is CommunityImageBlock ? 16 : 12));

      switch (block) {
        case CommunityTextBlock(:final pieces):
          children.add(SelectableText.rich(TextSpan(children: _spansOf(pieces))));
        case CommunityImageBlock(:final url, :final imageIndex):
          children.add(
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.onImageTap(_parsed.imageUrls, imageIndex),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  // 원본 크기를 모르므로 박스를 먼저 잡아 로딩 중 셔머가 찌그러지지 않게 한다.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 200, maxHeight: 640),
                    child: WebNetworkImage(url: url, width: double.infinity, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          );
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  List<TextSpan> _spansOf(List<_Piece> pieces) {
    final base = SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900, height: 1.6);
    return [
      for (final p in pieces)
        if (p.link != null)
          TextSpan(
            text: p.text,
            style: base.copyWith(
              color: SDSColor.snowliveBlue,
              decoration: TextDecoration.underline,
              decorationColor: SDSColor.snowliveBlue,
            ),
            recognizer: _linkRecognizer(p.link!),
          )
        else
          TextSpan(
            text: p.text,
            style: (p.bold ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
              fontSize: 15,
              color: SDSColor.gray900,
              height: 1.6,
              decoration: p.underline ? TextDecoration.underline : null,
            ),
          ),
    ];
  }

  TapGestureRecognizer _linkRecognizer(String url) {
    final recognizer = TapGestureRecognizer()..onTap = () => _openLink(url);
    _recognizers.add(recognizer);
    return recognizer;
  }
}
