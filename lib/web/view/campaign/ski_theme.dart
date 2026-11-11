import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 스키장 도트(픽셀아트) 테마 — SNOWLIVE_EVENT_UI_GUIDE.md.
/// 팔레트 12색 고정 + 흰색. 모서리 0, night 2px 외곽선, 흐림 없는 4px 단색 그림자.
abstract final class SkiColors {
  static const night = Color(0xFF141B3C);
  static const deepBlue = Color(0xFF2B3F7E);
  static const ice = Color(0xFF8FC7F2);
  static const sky = Color(0xFFCDEBFF);
  static const snow = Color(0xFFF7FBFF);
  static const pine = Color(0xFF1F7A5C);
  static const mint = Color(0xFF5FD9A0);
  static const wood = Color(0xFF9A5B3C);
  static const red = Color(0xFFFF3B4E);
  static const yellow = Color(0xFFFFD23F);
  static const orange = Color(0xFFFF8A3D);
  static const pink = Color(0xFFFF5FB0);
  static const white = Color(0xFFFFFFFF);
}

// ── 픽셀 폰트 ──
// 제목(한글): Do Hyeon. 숫자·영문 라벨: Press Start 2P. 둘 다 weight 400.
TextStyle pxTitle(double size, Color color, {double height = 1.1}) =>
    GoogleFonts.doHyeon(fontSize: size, color: color, height: height);
TextStyle pxLabel(double size, Color color, {double height = 1.2, double spacing = 0}) =>
    GoogleFonts.pressStart2p(
        fontSize: size, color: color, height: height, letterSpacing: spacing);

/// 각진 박스 — 채움 + night 2px 외곽선 + (옵션) 흐림 없는 4px 단색 그림자.
BoxDecoration skiBox({
  required Color fill,
  Color border = SkiColors.night,
  Color? shadow,
  double borderW = 2,
}) =>
    BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.zero,
      border: Border.all(color: border, width: borderW),
      boxShadow: shadow == null
          ? null
          : [BoxShadow(color: shadow, offset: const Offset(4, 4), blurRadius: 0)],
    );

/// 2px 점선 가로 구분선.
class SkiDashedLine extends StatelessWidget {
  final Color color;
  const SkiDashedLine({super.key, this.color = SkiColors.night});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter(color)),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..isAntiAlias = false;
    const dash = 4.0, gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawRect(Rect.fromLTWH(x, 0, dash, 2), p);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

// ── 도트 스프라이트 ──
const Map<String, Color> _legend = {
  'n': SkiColors.night,
  'd': SkiColors.deepBlue,
  'i': SkiColors.ice,
  'w': SkiColors.snow,
  'f': SkiColors.pine,
  'm': SkiColors.mint,
  'b': SkiColors.wood,
  'r': SkiColors.red,
  'y': SkiColors.yellow,
  'o': SkiColors.orange,
  'p': SkiColors.pink,
};

/// 격자 문자열을 정수 배율로 그리는 재사용 스프라이트. [mono]를 주면 한 색으로 칠한다.
class PixelSprite extends StatelessWidget {
  final List<String> data;
  final double scale;
  final Color? mono;
  const PixelSprite(this.data, {super.key, this.scale = 3, this.mono});

  @override
  Widget build(BuildContext context) {
    final h = data.length;
    final w = data.isEmpty ? 0 : data[0].length;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(w * scale, h * scale),
          painter: _SpritePainter(data, scale, mono),
        ),
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final List<String> data;
  final double scale;
  final Color? mono;
  _SpritePainter(this.data, this.scale, this.mono);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = false;
    for (int y = 0; y < data.length; y++) {
      final row = data[y];
      for (int x = 0; x < row.length; x++) {
        final ch = row[x];
        if (ch == '.') continue;
        final color = mono ?? _legend[ch];
        if (color == null) continue;
        paint.color = color;
        canvas.drawRect(
            Rect.fromLTWH(x * scale, y * scale, scale, scale), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpritePainter old) => false;
}

// 스프라이트 데이터(가이드 격자 그대로).
const spTree = [
  '....w....',
  '...wmf...',
  '...mmf...',
  '..wmmff..',
  '..mmmff..',
  '.wmmmfff.',
  '.mmmmfff.',
  '....b....',
  '....b....',
];

const spXmasTree = [
  '....y....',
  '....mf...',
  '...mmf...',
  '...rmff..',
  '..mmmff..',
  '..mmmrff.',
  '.mrmmfff.',
  '....b....',
  '....b....',
];

const spFlagRed = [
  '.n.......',
  '.nrrrr...',
  '.nrrrrr..',
  '.nrrrr...',
  '.n.......',
  '.n.......',
  '.n.......',
  '.n.......',
  'iiii.....',
];

const spFlagBlue = [
  '.n.......',
  '.ndddd...',
  '.nddddd..',
  '.ndddd...',
  '.n.......',
  '.n.......',
  '.n.......',
  '.n.......',
  'iiii.....',
];

const spSun = [
  '....o....',
  '.o..o..o.',
  '.........',
  '...wyy...',
  'oo.yyy.oo',
  '...yyy...',
  '.........',
  '.o..o..o.',
  '....o....',
];

const spCloud = [
  '..wwww...',
  '.wwwwwww.',
  'wwwwwwwww',
];

const spCoin = [
  '..nnnnn..',
  '.nyyyyyn.',
  'nywyyyoon',
  'nywyoyoon',
  'nyyyoyoon',
  'nyyyoyoon',
  'nyyyyyoon',
  '.nooooon.',
  '..nnnnn..',
];

const spHeart = [
  '.........',
  '..pw.pr..',
  '.pwppprr.',
  '.ppppppr.',
  '.ppppprr.',
  '..ppppr..',
  '...ppr...',
  '....r....',
  '.........',
];

const spLightning = [
  '.....rr..',
  '....rr...',
  '...rr....',
  '..rrrrr..',
  '....rr...',
  '...rr....',
  '..rr.....',
  '..r......',
  '.........',
];

const spSnowflake = [
  '....d....',
  '.d..d..d.',
  '..d.d.d..',
  '....d....',
  'ddddddddd',
  '....d....',
  '..d.d.d..',
  '.d..d..d.',
  '....d....',
];

const spStar = [
  '....o....',
  '....o....',
  '...ooo...',
  'ooooooooo',
  '.ooooooo.',
  '..ooooo..',
  '..oo.oo..',
  '.oo...oo.',
  '.........',
];

const spTrophy = [
  '.yyyyyoo.',
  'oywyyyooo',
  'oywyyyooo',
  '.yyyyyoo.',
  '..yyyyo..',
  '...yyo...',
  '....y....',
  '..yyyyy..',
  '..ooooo..',
];

// 인스타그램(SNS) 카메라 아이콘. p=핑크 프레임, n=렌즈, d=코너 점.
const spInstagram = [
  '.ppppppp.',
  'p.......p',
  'p..nnn.dp',
  'p.n...n.p',
  'p.n...n.p',
  'p.n...n.p',
  'p..nnn..p',
  'p.......p',
  '.ppppppp.',
];

/// 정렬(위·아래 화살표) 아이콘 — 폰트 의존 없이 직접 그려 항상 보인다.
class SkiSortIcon extends StatelessWidget {
  final double size;
  final Color color;
  const SkiSortIcon({super.key, this.size = 18, this.color = SkiColors.night});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _SortPainter(color)));
}

class _SortPainter extends CustomPainter {
  final Color color;
  _SortPainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..isAntiAlias = false;
    final w = s.width, h = s.height;
    final up = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..lineTo(w * 0.22, h * 0.44)
      ..lineTo(w * 0.78, h * 0.44)
      ..close();
    final down = Path()
      ..moveTo(w * 0.5, h * 0.94)
      ..lineTo(w * 0.22, h * 0.56)
      ..lineTo(w * 0.78, h * 0.56)
      ..close();
    canvas.drawPath(up, p);
    canvas.drawPath(down, p);
  }

  @override
  bool shouldRepaint(covariant _SortPainter old) => old.color != color;
}

const spSnowMountain = [
  '.......................................',
  '.......................................',
  '...........................ww..........',
  '..........................wwww.........',
  '.........................iwiwwi........',
  '........ww..............iiiiiiii.......',
  '.......wwww............iiiiiiiiii......',
  '......iwiwii..........iiiiiiiiiiii.....',
  '.....iiiiiiii........iiiiiiiiiiiiii....',
  'wwwwiiiiiiiiiiwwwwwwiiiiiiiiiiiiiiiwwww',
  'wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww',
  'wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww',
];
