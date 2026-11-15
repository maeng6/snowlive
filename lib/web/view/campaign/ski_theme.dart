import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 스키장 도트(픽셀아트) 테마.
///
/// 배경 설경이 **하늘색 단색 계열**이라 카드도 같은 기운을 머금어야 한 화면으로
/// 읽힌다. 원래 쨍한 게임톤 12색이었는데 배경 위에서 혼자 튀었고, 한때 채도를
/// 너무 내렸더니 물 빠진 회색이 됐다. 지금 값은 그 중간 — 조절은 채도가 아니라
/// **색상을 하늘색 쪽으로 당기는 것**으로 할 것.
abstract final class SkiColors {
  /// 글자·외곽선. 배경 침엽수와 같은 짙은 청록녹색.
  static const night = Color(0xFF1F3B42);
  static const deepBlue = Color(0xFF3D6683);

  /// 카드 채움 4색 — 얼리버드(모래)·패스트(얼음)·슬로우(민트)·베스트(장미).
  static const yellow = Color(0xFFEFC877);
  static const ice = Color(0xFFA9D2E8);
  static const mint = Color(0xFF8FC9B4);
  static const pink = Color(0xFFE0A3B6);

  /// 어두운 카드 3색 — 얼리버드·슬로우·베스트.
  /// 흰 눈 위에서 대비로 떠오르게 하는 용도라, 명도는 낮게 유지하고 색상만
  /// 다르게 둔다. 밝히면 중간 톤이 되면서 배경과 엉긴다.
  static const cardEarly = Color(0xFF2E4F5C);
  static const cardSlow = Color(0xFF2C5147);
  static const cardBest = Color(0xFF4A3A4C);

  /// OOTD 패널 채움. 카드 4색보다 한 단계만 묵직하다 — [night]를 그대로 쓰면
  /// 페이지에서 혼자 압도적으로 어두워 흰 블록 바로 아래에서 점프가 생긴다.
  static const panel = Color(0xFF24444E);

  /// 어두운 카드 위 글자·선.
  static const onDark = Color(0xFFE6F0F8);
  static const onDarkDim = Color(0xFFA9C0CE);

  /// 액션 색 — 스노우라이브 브랜드 블루. 버튼·날짜칩·발표 뱃지처럼
  /// **누르는 것·알리는 것**에만 쓴다. 설경 팔레트 바깥의 유일한 고채도라
  /// 넓은 면에 칠하면 혼자 튄다.
  static const action = SDSColor.snowliveBlue;
  static const actionShadow = SDSColor.blue700;
  static const onAction = Color(0xFFFFFFFF);

  /// 어두운 면 위에 올리는 블루. [action]을 그대로 쓰면 짙은 바탕에서
  /// 대비가 3:1 수준이라 작은 글자가 안 읽힌다.
  static const actionLit = SDSColor.blue300;

  /// 보조 — 그림자·강조.
  static const orange = Color(0xFFDBA961);
  static const red = Color(0xFFC9565F);
  static const sky = Color(0xFFE3EFF9);
  static const snow = Color(0xFFF5F9FD);
  static const pine = Color(0xFF3E8A78);
  static const wood = Color(0xFF8A6B55);
  static const white = Color(0xFFFFFFFF);
}

// ── 글꼴 ──
// 일반 텍스트(카드 제목·본문·닉네임)는 **Pretendard**(SDSTextStyle)를 쓴다 —
// 다른 웹 화면과 같은 글꼴이라야 이 페이지만 떠 보이지 않는다.
// 여기 있는 두 글꼴은 장식용이다: 한글 도트는 [pxDot](히어로·섹션 제목),
// 숫자·영문 라벨은 [pxLabel](Press Start 2P).
// Do Hyeon을 쓰던 pxTitle은 제거했다 — 한글 제목이 Galmuri와 두 글꼴로 갈렸다.

/// 한글 도트 폰트(Galmuri11, OFL). 11px 비트맵에서 뽑은 글꼴이라 **11의 배수**
/// 크기(22·33·44…)에서만 획이 정수 도트로 떨어진다 — 그 외 값은 획이 뭉갠다.
///
/// [bold]는 합성이 아니라 **Bold 페이스**를 쓴다. 도트 폰트에 합성 볼드를
/// 걸면 획이 번져 격자가 깨진다 — w700 외의 두께를 쓰지 말 것.
TextStyle pxDot(
  double size,
  Color color, {
  double height = 1.2,
  double spacing = 0,
  bool bold = false,
}) => TextStyle(
  fontFamily: 'Galmuri11',
  fontSize: size,
  color: color,
  height: height,
  letterSpacing: spacing,
  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
);

/// 도트 글자 + 8방향 하드 외곽선. 흐림 없는 오프셋 복사본을 깔아 배경 위에서도
/// 글자가 또렷하게 뜬다(Paint stroke는 안티에일리어싱이 생겨 도트가 흐려진다).
class PixelOutlinedText extends StatelessWidget {
  final String text;
  final TextStyle style;

  /// 외곽선 색과 두께(논리 px). 도트 한 칸과 맞추면 깔끔하다.
  final Color outline;
  final double width;
  final TextAlign align;

  const PixelOutlinedText(
    this.text, {
    super.key,
    required this.style,
    this.outline = SkiColors.night,
    this.width = 2,
    this.align = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    const dirs = [
      Offset(-1, 0),
      Offset(1, 0),
      Offset(0, -1),
      Offset(0, 1),
      Offset(-1, -1),
      Offset(1, -1),
      Offset(-1, 1),
      Offset(1, 1),
    ];
    final outlineStyle = style.copyWith(color: outline);
    return Stack(
      // 외곽선 복사본이 글자 상자 밖으로 나가므로 자르면 안 된다.
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        for (final d in dirs)
          Transform.translate(
            offset: d * width,
            child: Text(text, style: outlineStyle, textAlign: align),
          ),
        Text(text, style: style, textAlign: align),
      ],
    );
  }
}

/// 여러 줄 도트 문장. Flutter는 한글을 **글자 단위**로 끊어서 좁은 폭이면
/// '이벤/트!'처럼 어절이 쪼개진다. 공백으로 미리 나눠 Wrap에 넘겨 어절 단위로
/// 접히게 한다.
class PixelOutlinedWrap extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color outline;
  final double width;
  final WrapAlignment alignment;

  const PixelOutlinedWrap(
    this.text, {
    super.key,
    required this.style,
    this.outline = SkiColors.night,
    this.width = 2,
    this.alignment = WrapAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return Wrap(
      alignment: alignment,
      // 공백 한 칸 ≈ 글자 폭의 절반(Galmuri 기준).
      spacing: (style.fontSize ?? 16) * 0.5,
      runSpacing: (style.fontSize ?? 16) * 0.3,
      children: [
        for (final w in words)
          PixelOutlinedText(w, style: style, outline: outline, width: width),
      ],
    );
  }
}

TextStyle pxLabel(
  double size,
  Color color, {
  double height = 1.2,
  double spacing = 0,
}) => GoogleFonts.pressStart2p(
  fontSize: size,
  color: color,
  height: height,
  letterSpacing: spacing,
);

/// 카드 크롬은 **역할 3단**으로 고정한다. 새 요소를 만들 때 셋 중 하나를 고르고,
/// `BoxDecoration`을 직접 쓰지 말 것 — 한때 한 페이지에 테두리 1·1.5·2px,
/// 그림자 하드/소프트/없음이 뒤섞여 어법이 다섯 개까지 갔다.
///
/// · [skiSurface] **면** — 카드·패널·리스트 블록. 큰 면은 조용해야 배경 설경이 산다.
/// · [skiControl] **조작** — 버튼. 굵은 테두리 + 하드 그림자가 "누를 수 있다"는 신호.
/// · [skiMarker]  **표시** — 칩·뱃지·게이지처럼 박혀 있는 것. 테두리만, 그림자 없음.
///
/// 모서리는 전부 0이다. 라운드를 섞으면 그것만 다른 디자인에서 온 것처럼 보인다.

/// 하드 그림자 오프셋. 버튼을 누를 때 본체가 내려가는 거리이기도 해서, 둘이
/// 같은 값을 써야 눌림이 정확히 그림자 자리에 맞는다.
const double kSkiPress = 3;

/// 면 — 1px 반투명 테두리 + 옅은 그림자.
///
/// 테두리 색은 **채움 밝기를 보고 뒤집는다**. 어두운 면에 어두운 테두리를 두르면
/// 완전히 묻혀서 그 카드만 "크롬 없는 맨 사각형"이 된다(어두운 카드로 바꾼 뒤
/// 실제로 그랬다).
BoxDecoration skiSurface({required Color fill}) {
  final onDarkFill = fill.computeLuminance() < 0.25;
  return BoxDecoration(
    color: fill,
    borderRadius: BorderRadius.zero,
    border: Border.all(
      color: onDarkFill
          ? SkiColors.onDark.withValues(alpha: 0.18)
          : SkiColors.night.withValues(alpha: 0.22),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: SkiColors.night.withValues(alpha: 0.10),
        offset: const Offset(0, 2),
        blurRadius: 6,
      ),
    ],
  );
}

/// 조작 — 2px night 테두리 + 하드 오프셋 그림자.
/// [pressed]면 그림자를 빼고, 호출부가 본체를 [kSkiPress]만큼 내려 눌린 느낌을 낸다.
BoxDecoration skiControl({
  required Color fill,
  Color shadow = SkiColors.night,
  bool pressed = false,
}) => BoxDecoration(
  color: fill,
  borderRadius: BorderRadius.zero,
  border: Border.all(color: SkiColors.night, width: 2),
  boxShadow: pressed
      ? null
      : [
          BoxShadow(
            color: shadow,
            offset: const Offset(kSkiPress, kSkiPress),
            blurRadius: 0,
          ),
        ],
);

/// 표시 — 2px night 테두리만.
BoxDecoration skiMarker({required Color fill}) => BoxDecoration(
  color: fill,
  borderRadius: BorderRadius.zero,
  border: Border.all(color: SkiColors.night, width: 2),
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
  // 빵 전용 — wood(#8A6B55)는 회색빛이라 구운 색으로 안 읽힌다.
  'c': Color(0xFFA2682E),
  'g': Color(0xFFF8E1A8),
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
          Rect.fromLTWH(x * scale, y * scale, scale, scale),
          paint,
        );
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

const spCloud = ['..wwww...', '.wwwwwww.', 'wwwwwwwww'];

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

/// 개장'빵' — 히어로 제목 옆 빵. 직선 막대로 두면 빵으로 안 읽혀서 축을 휘고
/// 두께를 올렸다. 격자를 1칸 넓힌 뒤 외곽선을 둘러야 양 끝 테두리가 안 잘린다.
/// 흰 눈 위에 올라가므로 외곽선(n)이 없으면 묻힌다.
const spBaguette = [
  '...........nnn..',
  '..........nggyn.',
  '.........nggyocn',
  '........nggyoocn',
  '.......ngcyyoocn',
  '......nggcccocn.',
  '.....ngcyyccccn.',
  '....ngcccyoccn..',
  '...nggycccoccn..',
  '..ngccyyccccn...',
  '.nggyccooccn....',
  'nggyycccccn.....',
  'ngyooocccn......',
  'nyoooccnn.......',
  '.ncccnn.........',
  '..nnn...........',
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
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _SortPainter(color)),
  );
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
