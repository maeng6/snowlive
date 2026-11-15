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

// ── 스프라이트 ──
// 'o' 실루엣 / 'r' 옷 포인트 / 'k' 장비 / '.' 투명

/// 라이더 — 직활강. 머리(비니)·자켓·벌린 팔·다리·스키.
const _riderMid = [
  '..ooo..',
  '..ooo..',
  '.orrro.',
  'orrrrro',
  '.orrro.',
  '.orrro.',
  '.oo.oo.',
  '.o...o.',
  'kkkkkkk',
  '.......',
];

/// 좌턴 — 어깨와 스키를 왼쪽으로 민다.
const _riderLeft = [
  '.ooo...',
  '.ooo...',
  'orrro..',
  'rrrrro.',
  'orrro..',
  'orrro..',
  'oo.oo..',
  'o...o..',
  'kkkkk..',
  '...kkk.',
];

/// 우턴.
const _riderRight = [
  '...ooo.',
  '...ooo.',
  '..orrro',
  '.orrrrr',
  '..orrro',
  '..orrro',
  '..oo.oo',
  '..o...o',
  '..kkkkk',
  '.kkk...',
];

/// 리프트 의자 — 행어 + 앉은 두 사람 + 좌석. 사람은 머리와 어깨만.
const _chair = [
  '...oo..',
  '...oo..',
  '.oooooo',
  'o.o..o.',
  'orooro.',
  'oooooo.',
  'oooooo.',
  '.o..o..',
  '.k..k..',
  '.......',
];

const Map<String, Color> _baseLegend = {'o': _silhouette, 'k': _skiDark};

/// 라이더 한 명의 고정 성질 — 프레임마다 다시 뽑으면 사람이 깜빡인다.
class _Actor {
  final int accent;

  /// 페이지 세로 기준 속도(논리 px/초).
  final double speed;

  /// 루프 안에서의 출발 위치(0~1).
  final double phase;

  /// **차선** — 슬로프 반폭 대비 -1~1. 라이더마다 다른 띠를 쓴다.
  /// 세로 위치가 겹쳐도 가로로 떨어져 있어 서로 포개지지 않는다.
  final double lane;

  /// 차선 **안에서** 좌우로 써는 폭과 주기. 차선 반폭을 넘지 않게 둔다.
  final double carve;
  final double carveFreq;
  final double carvePhase;

  const _Actor({
    required this.accent,
    required this.speed,
    required this.phase,
    required this.lane,
    required this.carve,
    required this.carveFreq,
    required this.carvePhase,
  });
}

List<_Actor> _buildActors(int count) {
  final out = <_Actor>[];
  // 슬로프를 count개 차선으로 나눠 한 명씩 배정한다. 속도를 다르게 두면
  // 세로로는 서로 추월하지만, 차선이 다르니 절대 포개지지 않는다.
  final laneHalf = 1.0 / count;
  for (int i = 0; i < count; i++) {
    // 고정 난수 대신 인덱스에서 흩뜨린다 — 새로고침해도 같은 무리가 나온다.
    final r1 = ((i * 37) % 17) / 17.0;
    final r2 = ((i * 53) % 23) / 23.0;
    final r3 = ((i * 71) % 13) / 13.0;
    // 차선 순서를 섞어 색이 좌우로 줄 서지 않게 한다.
    final slot = (i * 2 + (i ~/ 2)) % count;
    out.add(
      _Actor(
        accent: (i * 3) % _accents.length,
        speed: 34 + r1 * 40,
        phase: i / count + r3 * 0.05,
        lane: (-1 + 2 * (slot + 0.5) / count) * 0.80,
        // 차선 반폭의 55%까지만 썬다. 이웃 차선과 최소 간격이 스프라이트
        // 폭(7도트)보다 넓게 남아야 실제로 안 겹친다.
        carve: laneHalf * 0.55 * (0.6 + r2 * 0.4),
        carveFreq: 0.007 + r1 * 0.006,
        carvePhase: r2 * math.pi * 2,
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

class _Atlas {
  final List<_Frames> riders;
  final ui.Image chair;
  final int w;
  final int h;
  const _Atlas(this.riders, this.chair, this.w, this.h);

  void dispose() {
    for (final f in riders) {
      f.dispose();
    }
    chair.dispose();
  }
}

Future<_Atlas> _bakeAtlas() async {
  final riders = <_Frames>[];
  for (final accent in _accents) {
    final lg = {..._baseLegend, 'r': accent};
    riders.add(
      _Frames(
        await _bake(_riderLeft, lg),
        await _bake(_riderMid, lg),
        await _bake(_riderRight, lg),
      ),
    );
  }
  final chair = await _bake(_chair, {..._baseLegend, 'r': _accents[1]});
  return _Atlas(riders, chair, _riderMid[0].length, _riderMid.length);
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

  const SkiSlopeActors({
    super.key,
    this.pisteWidth = 1440,
    this.cellSize,
    this.ridersPer1000 = 1.6,
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

  final List<_Actor> _actors;

  _ActorPainter({
    required this.clock,
    required this.geo,
    required this.atlas,
    required this.riderCount,
  }) : _actors = _buildActors(riderCount),
       super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    final loop = size.height + 240; // 위아래로 여유를 두고 순환.
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;

    _paintChairs(canvas, size, t, paint);
    for (int i = 0; i < _actors.length; i++) {
      _paintRider(canvas, size, _actors[i], t, loop, paint);
    }
  }

  void _paintRider(
    Canvas canvas,
    Size size,
    _Actor a,
    double t,
    double loop,
    Paint paint,
  ) {
    final y = ((a.phase * loop + t * a.speed) % loop) - 120;
    if (y < -60 || y > size.height + 60) return;

    double xAt(double yy) =>
        geo.centerPx(yy) +
        geo.halfPx(yy) *
            (a.lane + a.carve * math.sin(yy * a.carveFreq + a.carvePhase));

    final x = xAt(y);
    // 좌우 기울기로 턴 프레임을 고른다(다음 지점과의 x차이 = 진행 방향).
    final lean = xAt(y + 10) - x;
    final frames = atlas.riders[a.accent % atlas.riders.length];
    final img = lean < -0.7
        ? frames.left
        : (lean > 0.7 ? frames.right : frames.mid);

    _paintTrail(canvas, a, y, xAt);
    _draw(canvas, img, x, y, paint);
  }

  /// 지나온 자국 — 라이더가 **실제로 지난 자리**에만, 화면 위쪽으로 갈수록
  /// 옅게. 짧은 꼬리로 끊으면 "깔아 놓은 길을 달리는" 것처럼 보인다.
  void _paintTrail(
    Canvas canvas,
    _Actor a,
    double y,
    double Function(double) xAt,
  ) {
    const step = 7.0; // 자국 표본 간격(논리 px)
    const fadeLen = 520.0; // 이 거리만큼 뒤에서 완전히 사라진다
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = kSceneDot
      ..isAntiAlias = false;

    // 알파가 변해야 하므로 구간별로 끊어 그린다.
    double back = 0;
    while (back < fadeLen) {
      final y0 = y - back, y1 = y - back - step;
      if (y1 < -20) break;
      final fade = 1 - back / fadeLen;
      stroke.color = SnowScene.track.withValues(alpha: 0.30 + 0.70 * fade);
      for (final side in const [-1.0, 1.0]) {
        canvas.drawLine(
          Offset(xAt(y0) + side * kSceneDot, y0),
          Offset(xAt(y1) + side * kSceneDot, y1),
          stroke,
        );
      }
      back += step;
    }
  }

  void _paintChairs(Canvas canvas, Size size, double t, Paint paint) {
    const spacing = 260.0; // 의자 간격(논리 px)
    const speed = 30.0; // 올라가는 속도(논리 px/초)
    final count = (size.height / spacing).ceil() + 2;
    final shift = (t * speed) % spacing;

    for (int i = 0; i < count; i++) {
      // 아래에서 위로 — 그래서 시간이 갈수록 y가 줄어든다.
      final y = size.height + spacing - i * spacing - shift;
      if (y < -60 || y > size.height + 60) continue;
      // 의자는 케이블에 **매달린다** — 가운데 정렬하면 행어 절반이 케이블 위로
      // 솟아 떠 있는 것처럼 보인다.
      _draw(
        canvas,
        atlas.chair,
        geo.cableX(y),
        y + atlas.h * kSceneDot / 2,
        paint,
      );
    }
  }

  /// 스프라이트를 (cx, cy) 중심에 [kSceneDot] 배율로 찍는다.
  void _draw(Canvas canvas, ui.Image img, double cx, double cy, Paint paint) {
    final dw = atlas.w * kSceneDot, dh = atlas.h * kSceneDot;
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, atlas.w.toDouble(), atlas.h.toDouble()),
      Rect.fromLTWH(cx - dw / 2, cy - dh / 2, dw, dh),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ActorPainter old) =>
      old.geo != geo || old.atlas != atlas || old.riderCount != riderCount;
}
