import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 찜하기 아이콘은 아웃라인/채움 두 에셋을 상태에 따라 갈아 끼운다.
/// 두 에셋의 실루엣(path)이 같아야 토글할 때 모양이 튀지 않는다.
void main() {
  const outline = 'assets/imgs/icons/icon_header_bookmark_web.svg';
  const filled = 'assets/imgs/icons/icon_header_bookmark_fill_web.svg';

  String pathOf(String svg) =>
      RegExp(r'd="([^"]+)"').firstMatch(svg)!.group(1)!;

  test('채움 아이콘이 아웃라인과 같은 북마크 실루엣이다', () {
    final outlineSvg = File(outline).readAsStringSync();
    final filledSvg = File(filled).readAsStringSync();

    expect(pathOf(filledSvg), pathOf(outlineSvg));
    // 아웃라인은 stroke만, 채움은 fill까지 — 색은 같은 #111111.
    expect(outlineSvg, isNot(contains('fill="#111111"')));
    expect(filledSvg, contains('fill="#111111"'));
    expect(filledSvg, contains('stroke="#111111"'));
    // 두 아이콘의 캔버스가 같아야 토글 시 크기가 튀지 않는다.
    expect(RegExp(r'viewBox="([^"]+)"').firstMatch(filledSvg)!.group(1),
        RegExp(r'viewBox="([^"]+)"').firstMatch(outlineSvg)!.group(1));
  });
}
