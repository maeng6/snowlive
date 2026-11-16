import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:com.snowlive/web/view/campaign/ski_slope_scene_web.dart';

/// 슬로프 위에서 **움직이는 것들** — 내려오는 라이더와 올라가는 리프트 의자.
///
/// 지형(눈·나무·산장·케이블)은 [SkiSlopeBackground]가 한 번 구운 비트맵이고,
/// 여기서는 작은 스프라이트 몇 개만 매 프레임 옮겨 그린다. 스프라이트도 미리
/// ui.Image로 구워 두고 drawImageRect로 찍어서, 프레임당 그리기 호출이
/// 액터 수(수십 개)로 끝난다.
///
/// 캐릭터는 **얼굴 없는 작은 실루엣**이다(7x10 도트, 화면 21x30px). 레퍼런스가
/// 그렇다 — 머리·몸통·팔·스키만 구분되고 그 이상은 그리지 않는다. 디테일을
/// 넣으면 비어 있는 눈밭의 고요함이 깨진다.

/// 라이더 자켓색 — 색상(hue)은 서로 멀리 떨어뜨리되 **명도는 비슷하게** 맞춘다.
/// 채도는 배경(청록 계열)과 같은 수준으로: 더 낮추면 물 빠져 보이고, 더 올리면
/// 한 명만 튀어 시선을 끌어간다.
const _accents = [
  Color(0xFFD4635A), // 테라코타
  Color(0xFFD9A24B), // 머스타드
  Color(0xFF5FA882), // 초록
  Color(0xFF3E9AA3), // 청록
  Color(0xFF5E6FB8), // 청보라
  Color(0xFFA85B92), // 자두
];

/// 실루엣은 배경 침엽수와 같은 계열 — 너무 다른 색이면 혼자 다른 그림에서 온
/// 사람처럼 보인다.
const _silhouette = Color(0xFF2B4752);
const _skiDark = Color(0xFF1A3337);

// 레퍼런스(디테일 픽셀 라이더) 톤 — 헬멧/재킷은 라이더별 accent, 나머지는 공통.
const _goggle = Color(0xFFCFEAF6); // 고글(얼음빛)
const _skin = Color(0xFFE7C39B); // 얼굴
// 보드러는 네이비 바지 + 청록 보드, 스키어는 브라운 바지 + 빨강 스키 —
// 다리색·장비색을 달리해 "스키/보드 신었다"가 한눈에 구분된다.
const _pants = Color(0xFF34435A); // 보드러 바지(네이비)
const _board = Color(0xFF357089); // 보드(청록 플랭크)
const _skiPants = Color(0xFF5A4636); // 스키어 바지(브라운)
const _ski = Color(0xFFD9574E); // 스키(빨강)

/// 라이더를 그릴 배율 — 지형 도트(kSceneDot=3)보다 작게 해서 사람을 더 작게.
const double _riderScale = 2.0;

// ── 스프라이트 ──
// 'o' 외곽선 / 'r' 헬멧·재킷(accent) / 'g' 고글 / 's' 얼굴 / 'p' 바지 / 'b' 보드
// 'a' 곤돌라 행어 / 'c' 캐빈 / '.' 투명

/// 라이더(11x14) — 헬멧+고글+얼굴+컬러 재킷+벌린 팔+보드. 직활강 기준 프레임이고,
/// 좌·우 턴 프레임은 [_shift]로 한 칸씩 밀어 만든다.
const _riderMid = [
  '...ooooo...',
  '..orrrrro..',
  '..orrrrro..',
  '..ogggggo..',
  '..ossssso..',
  '...osso....',
  '.oorrrroo..',
  'orrrrrrrro.',
  'o.orrrro.o.',
  '..orrrro...',
  '..oppppo...',
  '..op..po...',
  '.obbbbbbbo.',
  '.obbbbbbbo.',
];

/// 스키어(11x14) — 라이더와 같되 아래가 **두 짝의 스키**. 궤적도 2줄로 남는다.
const _skierMid = [
  '...ooooo...',
  '..orrrrro..',
  '..orrrrro..',
  '..ogggggo..',
  '..ossssso..',
  '...osso....',
  '.oorrrroo..',
  'orrrrrrrro.',
  'o.orrrro.o.',
  '..orrrro...',
  '..oppppo...',
  '..op..po...',
  '..ob..bo...',
  '..ob..bo...',
];

/// 가로로 [dx]칸 민 프레임(좌/우 턴용). 길이는 그대로 유지한다.
List<String> _shift(List<String> g, int dx) => [
      for (final row in g)
        dx < 0
            ? '${row.substring(1)}.'
            : '.${row.substring(0, row.length - 1)}',
    ];

/// 곤돌라 캐빈(9x9) — 케이블 행어 + 창문 달린 캐빈. 의자 대신 매달려 올라간다.
const _gondola = [
  '....a....',
  '...aaa...',
  '.ooooooo.',
  'occccccco',
  'ogggggggo',
  'ogggggggo',
  'occccccco',
  '.ooooooo.',
  '.........',
];

/// 라이더 한 명의 고정 성질 — 프레임마다 다시 뽑으면 사람이 깜빡인다.
class _Actor {
  final int accent;

  /// 0 = 보드(궤적 1줄), 1 = 스키(궤적 2줄).
  final int kind;

  /// 페이지 세로 기준 속도(논리 px/초).
  final double speed;

  /// 루프 안에서의 출발 위치(0~1).
  final double phase;

  /// S자 호 반경 — **화면 너비** 대비(0.33~0.5). 라이더마다 다르게 둬서
  /// 어떤 사람은 좁게, 어떤 사람은 거의 가장자리까지 크게 휜다.
  final double ampFrac;

  /// S 한 굽이의 길이 = 화면 높이 × 이 값. 크면 길고 완만한 호.
  final double waveFactor;

  /// 위상 — 라이더마다 어긋나게 해서 같은 높이라도 좌우로 흩어져 안 겹친다.
  final double swayPhase;

  const _Actor({
    required this.accent,
    required this.kind,
    required this.speed,
    required this.phase,
    required this.ampFrac,
    required this.waveFactor,
    required this.swayPhase,
  });
}

List<_Actor> _buildActors(int count) {
  if (count <= 0) return const [];
  // 라이더마다 **큰 S자**를 그리며 내려온다. 진폭(호 반경)은 화면 너비의
  // 1/3~1/2로 사람마다 다르고, 위상을 골고루 어긋나게 해서(황금비) 같은 높이에
  // 있어도 좌우로 흩어져 서로 겹치지 않는다.
  final out = <_Actor>[];
  for (int i = 0; i < count; i++) {
    final r1 = ((i * 37) % 17) / 17.0;
    final r2 = ((i * 53) % 23) / 23.0;
    // 위상을 황금비로 촘촘히 깔아 좌우 분산을 극대화.
    final golden = (i * 0.6180339887) % 1.0;
    out.add(
      _Actor(
        accent: i % _accents.length, // 사람마다 다른 색
        kind: i % 2, // 스키·보드 번갈아
        // 속도를 거의 균일하게 — 제각각이면 시간이 지나며 뭉쳤다 벌어져
        // "우르르 나왔다가 공백기"가 생긴다. 균일하면 간격이 유지돼 늘 고르다.
        speed: 42 + r1 * 8,
        // 세로로 완전 균등 배치 → 항상 화면에 두엇은 지나간다.
        phase: i / count,
        // 호 반경 = 화면 너비의 1/3 ~ 거의 1/2.
        ampFrac: 0.34 + r2 * 0.14,
        // 한 굽이 길이 = 화면 높이의 0.3~0.9배 랜덤 — 짧고 자주 휘어 S가 잦다.
        waveFactor: 0.3 + r1 * 0.6,
        swayPhase: golden * math.pi * 2,
      ),
    );
  }
  return out;
}

// ── 스프라이트 → ui.Image ──

/// ui.decodeImageFromPixels의 rgba8888 순서(리틀엔디언에서 바이트 R,G,B,A).
int _rgba(Color c) =>
    (0xFF << 24) |
    ((c.b * 255).round() << 16) |
    ((c.g * 255).round() << 8) |
    (c.r * 255).round();

Future<ui.Image> _bake(List<String> data, Map<String, Color> legend) {
  final h = data.length, w = data[0].length;
  final px = Uint32List(w * h);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final c = legend[data[y][x]];
      if (c == null) continue;
      px[y * w + x] = _rgba(c);
    }
  }
  final done = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    px.buffer.asUint8List(),
    w,
    h,
    ui.PixelFormat.rgba8888,
    done.complete,
  );
  return done.future;
}

/// 라이더 한 명분 3프레임(좌·중·우).
class _Frames {
  final ui.Image left;
  final ui.Image mid;
  final ui.Image right;
  const _Frames(this.left, this.mid, this.right);

  void dispose() {
    left.dispose();
    mid.dispose();
    right.dispose();
  }
}

/// 곤돌라 캐빈 색 — 인스턴스마다 번갈아. 빨강·노랑·초록·파랑.
const _gondolaColors = [
  Color(0xFFE4564E), // 빨강
  Color(0xFFE8C14B), // 노랑
  Color(0xFF5FA882), // 초록
  Color(0xFF4E79C4), // 파랑
];

class _Atlas {
  final List<_Frames> riders; // 보드
  final List<_Frames> skiers; // 스키
  final List<ui.Image> gondolas; // 색상별 곤돌라 캐빈
  final int w;
  final int h;
  const _Atlas(this.riders, this.skiers, this.gondolas, this.w, this.h);

  void dispose() {
    for (final f in riders) {
      f.dispose();
    }
    for (final f in skiers) {
      f.dispose();
    }
    for (final g in gondolas) {
      g.dispose();
    }
  }
}

Future<_Frames> _bakeFrames(List<String> mid, Map<String, Color> lg) async =>
    _Frames(
      await _bake(_shift(mid, -1), lg),
      await _bake(mid, lg),
      await _bake(_shift(mid, 1), lg),
    );

Future<_Atlas> _bakeAtlas() async {
  final riders = <_Frames>[];
  final skiers = <_Frames>[];
  for (final accent in _accents) {
    final base = {'o': _silhouette, 'r': accent, 'g': _goggle, 's': _skin};
    // 보드: 네이비 바지 + 청록 보드.
    riders.add(await _bakeFrames(
        _riderMid, {...base, 'p': _pants, 'b': _board}));
    // 스키: 브라운 바지 + 빨강 스키.
    skiers.add(await _bakeFrames(
        _skierMid, {...base, 'p': _skiPants, 'b': _ski}));
  }
  final gondolas = <ui.Image>[];
  for (final c in _gondolaColors) {
    gondolas.add(await _bake(_gondola, {
      'o': _silhouette,
      'a': _skiDark,
      'c': c,
      'g': _goggle,
    }));
  }
  return _Atlas(
      riders, skiers, gondolas, _riderMid[0].length, _riderMid.length);
}

// ── 위젯 ──

/// 지형 위에 얹는 움직이는 레이어. 부모 Stack이 주는 크기 = 페이지 전체 크기.
class SkiSlopeActors extends StatefulWidget {
  /// 지형과 **같은 값**을 줘야 라이더가 슬로프를 벗어나지 않는다.
  final double pisteWidth;
  final double? cellSize;

  /// 페이지 높이 1000px당 슬로프에 둘 라이더 수. 레퍼런스처럼 **드물어야**
  /// 빈 눈밭의 고요함이 산다.
  final double ridersPer1000;

  /// 화면 **하단에서 비워 둘** 높이(논리 px). 라이더·곤돌라가 이 밴드 안으로는
  /// 내려오지 않아 풋터 영역을 침범하지 않는다.
  final double bottomSafe;

  const SkiSlopeActors({
    super.key,
    this.pisteWidth = 1440,
    this.cellSize,
    this.ridersPer1000 = 4.2,
    this.bottomSafe = 0,
  });

  @override
  State<SkiSlopeActors> createState() => _SkiSlopeActorsState();
}

class _SkiSlopeActorsState extends State<SkiSlopeActors>
    with SingleTickerProviderStateMixin {
  /// 티커가 올리는 경과 초. CustomPainter가 이걸 repaint로 물어서, 위젯 트리를
  /// 다시 빌드하지 않고 페인터만 다시 돈다.
  final _clock = ValueNotifier<double>(0);
  late final Ticker _ticker;
  _Atlas? _atlas;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((d) => _clock.value = d.inMilliseconds / 1000.0)
      ..start();
    _bakeAtlas().then((a) {
      if (!mounted) {
        a.dispose();
        return;
      }
      setState(() => _atlas = a);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    _atlas?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final atlas = _atlas;
    if (atlas == null) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
          return const SizedBox.shrink();
        }
        final geo = SlopeGeometry.of(
          w,
          widget.pisteWidth,
          cellSize: widget.cellSize,
        );
        return RepaintBoundary(
          child: CustomPaint(
            size: Size(w, h),
            painter: _ActorPainter(
              clock: _clock,
              geo: geo,
              atlas: atlas,
              bottomSafe: widget.bottomSafe,
              riderCount: math.max(
                2,
                (h / 1000 * widget.ridersPer1000).round(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActorPainter extends CustomPainter {
  final ValueNotifier<double> clock;
  final SlopeGeometry geo;
  final _Atlas atlas;
  final int riderCount;
  final double bottomSafe;

  final List<_Actor> _actors;

  _ActorPainter({
    required this.clock,
    required this.geo,
    required this.atlas,
    required this.riderCount,
    this.bottomSafe = 0,
  }) : _actors = _buildActors(riderCount),
       super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    final loop = size.height + 240; // 위아래로 여유를 두고 순환.
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;

    // z-순서(아래→위): 궤적 → 곤돌라 케이블 → 캐빈 → 라이더 본체.
    // 케이블을 궤적보다 뒤에 두면 자국이 줄을 덮는다 → 케이블을 궤적 위에
    // 다시 그려 **항상 줄이 궤적 위**로 보이게 한다.
    for (final a in _actors) {
      _paintTrailFor(canvas, size, a, t, loop);
    }
    _paintCable(canvas, size);
    _paintChairs(canvas, size, t, paint);
    for (final a in _actors) {
      _paintRiderBody(canvas, size, a, t, loop, paint);
    }
  }

  /// 곤돌라 케이블 — 배경에 구운 줄을 액터 레이어에 **궤적 위**로 덧그린다.
  /// 두께·색은 배경(1 도트, structure)과 맞춘다.
  void _paintCable(Canvas canvas, Size size) {
    final p = Paint()
      ..color = SnowScene.structure
      ..style = PaintingStyle.stroke
      ..strokeWidth = geo.cell
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true; // 매끄러운 사선 케이블
    // 성긴 표본점을 부드러운 곡선(2차 베지어)으로 이어 계단현상을 없앤다.
    const stepY = 24.0;
    final pts = <Offset>[];
    for (double y = 0; y <= size.height + stepY; y += stepY) {
      final yy = math.min(y, size.height);
      pts.add(Offset(geo.cableX(yy), yy));
    }
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length - 1; i++) {
      final mid = Offset(
        (pts[i].dx + pts[i + 1].dx) / 2,
        (pts[i].dy + pts[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(path, p);
  }

  /// 배경 맨 위 몽블랑 스키하우스 박스(도트 좌표 기준). 라이더가 이 안으로는
  /// 들어오지 않게 해서 "건물 양옆에서만" 지나가게 한다. 값은 _paintLodge의
  /// 벽 반폭(W=22, 처마+2) · 높이(지붕12+벽10)와 맞춰 둔 것 + 스프라이트 여유.
  bool _overLodge(double x, double y) {
    final cell = geo.cell;
    final bcx = (geo.cols ~/ 2) * cell;
    return y < 30 * cell && (x - bcx).abs() < 24 * cell + 14;
  }

  /// 라이더별 세로 위치·사인 궤도. 궤적/본체 두 패스가 공유한다.
  double _actorY(Size size, _Actor a, double t, double loop) =>
      ((a.phase * loop + t * a.speed) % loop) - 120;

  double Function(double) _xFn(Size size, _Actor a) {
    // 호 반경 = 화면 너비의 1/3~1/2, 굽이 길이 = 화면 높이 × waveFactor.
    final amp = size.width * a.ampFrac;
    final freq = (2 * math.pi) / (size.height * a.waveFactor);
    return (double yy) =>
        size.width / 2 + amp * math.sin(yy * freq + a.swayPhase);
  }

  /// 궤적 패스 — 케이블보다 **아래**에 깔린다.
  void _paintTrailFor(Canvas canvas, Size size, _Actor a, double t, double loop) {
    final y = _actorY(size, a, t, loop);
    if (y < -60 || y > size.height - bottomSafe) return;
    _paintTrail(canvas, size, a, y, _xFn(size, a), twoTrails: a.kind == 1);
  }

  /// 라이더 본체 패스 — 케이블·캐빈보다 **위**(맨 앞).
  void _paintRiderBody(
    Canvas canvas,
    Size size,
    _Actor a,
    double t,
    double loop,
    Paint paint,
  ) {
    final y = _actorY(size, a, t, loop);
    if (y < -60 || y > size.height - bottomSafe) return;
    final xAt = _xFn(size, a);
    final x = xAt(y);
    // 좌우 기울기로 턴 프레임을 고른다(다음 지점과의 x차이 = 진행 방향).
    final lean = xAt(y + 10) - x;
    final set = a.kind == 1 ? atlas.skiers : atlas.riders;
    final frames = set[a.accent % set.length];
    final img = lean < -0.7
        ? frames.left
        : (lean > 0.7 ? frames.right : frames.mid);
    // 건물 위는 그리지 않는다(양옆에서만 지나간다).
    if (!_overLodge(x, y)) {
      _draw(canvas, img, x, y, paint, scale: _riderScale);
    }
  }

  /// 지나온 자국 — 라이더가 **실제로 지난 자리**에만, 화면 위쪽으로 갈수록
  /// 옅게. 짧은 꼬리로 끊으면 "깔아 놓은 길을 달리는" 것처럼 보인다.
  void _paintTrail(
    Canvas canvas,
    Size size,
    _Actor a,
    double y,
    double Function(double) xAt, {
    required bool twoTrails,
  }) {
    const step = 4.0; // 자국 표본 간격(논리 px) — 촘촘히 끊어 부드럽게.
    const fadeLen = 620.0; // 이 거리만큼 뒤에서 완전히 사라진다
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = kSceneDot
      ..isAntiAlias = false;
    final sides = twoTrails ? const [-1.0, 1.0] : const [0.0];

    // 표본 위치를 **월드 격자에 스냅**한다. 라이더가 매 프레임 조금씩 움직여도
    // 자국 점들은 같은 좌표에 고정돼, 비트맵이 프레임마다 떨리지(끊겨 보이지)
    // 않는다.
    final yStart = (y / step).floorToDouble() * step;

    // 산장 사각형을 통째로 **클립(차집합)** 해서, 자국이 건물을 덮지 않으면서도
    // 경계가 프레임마다 깜빡이며 끊기지 않는다(세그먼트 단위 컬링이 원인이었음).
    final cell = geo.cell;
    final bcx = (geo.cols ~/ 2) * cell;
    final half = 24 * cell + 14;
    final lodge = Rect.fromLTWH(bcx - half, -40, half * 2, 30 * cell + 40);
    canvas.save();
    canvas.clipRect(lodge, clipOp: ui.ClipOp.difference, doAntiAlias: false);

    // 알파가 변해야 하므로 구간별로 끊어 그린다.
    double yc = yStart;
    while (true) {
      final back = y - yc;
      if (back > fadeLen) break;
      final y0 = yc, y1 = yc - step;
      if (y1 < -20) break;
      final fade = 1 - back / fadeLen;
      // 꼬리로 갈수록 0까지(제곱 커브) 스며들듯 부드럽게 사라진다.
      stroke.color = SnowScene.track.withValues(alpha: 0.85 * fade * fade);
      for (final side in sides) {
        canvas.drawLine(
          Offset(xAt(y0) + side * kSceneDot, y0),
          Offset(xAt(y1) + side * kSceneDot, y1),
          stroke,
        );
      }
      yc -= step;
    }
    canvas.restore();
  }

  void _paintChairs(Canvas canvas, Size size, double t, Paint paint) {
    const spacing = 260.0; // 곤돌라 간격(논리 px)
    const speed = 30.0; // 올라가는 속도(논리 px/초)
    final count = (size.height / spacing).ceil() + 2;
    final shift = (t * speed) % spacing;
    // 지금까지 지나간 주기 수. 슬롯 인덱스 i만으로 색을 고르면 곤돌라가
    // 올라가다 슬롯이 바뀌는 순간 색이 번쩍 바뀐다. (i - cycles)로 물리적
    // 식별번호를 고정해, 한 곤돌라는 올라가는 내내 같은 색을 유지한다.
    final cycles = (t * speed / spacing).floor();
    final len = atlas.gondolas.length;

    for (int i = 0; i < count; i++) {
      // 바디 **하단에서** 생겨 위로 올라간다(시간이 갈수록 y가 줄어든다).
      final y = size.height - i * spacing + spacing - shift;
      // 하단 안전영역(풋터) 위에서만 나타나 올라오게.
      if (y < -60 || y > size.height - bottomSafe) continue;
      // 곤돌라마다 색을 번갈아(빨·노·초·파), 올라가는 동안 색 고정.
      final img = atlas.gondolas[(((i - cycles) % len) + len) % len];
      // 케이블에 **매달린다** — 가운데 정렬하면 행어 절반이 케이블 위로 솟는다.
      _draw(canvas, img, geo.cableX(y), y + img.height * kSceneDot / 2, paint);
    }
  }

  /// 스프라이트를 (cx, cy) 중심에 [kSceneDot] 배율로 찍는다. 스프라이트마다
  /// 크기가 달라 이미지 자체 크기를 쓴다(라이더 11x14, 곤돌라 9x9).
  void _draw(Canvas canvas, ui.Image img, double cx, double cy, Paint paint,
      {double scale = kSceneDot}) {
    final dw = img.width * scale, dh = img.height * scale;
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(cx - dw / 2, cy - dh / 2, dw, dh),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ActorPainter old) =>
      old.geo != geo ||
      old.atlas != atlas ||
      old.riderCount != riderCount ||
      old.bottomSafe != bottomSafe;
}
