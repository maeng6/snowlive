import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 휘팍 랜딩 배경 — 위에서 내려다본 설경.
///
/// 레퍼런스(수채 일러스트)의 절제를 픽셀로 옮긴 것: **화면 대부분이 흰 눈**이고,
/// 파란 그림자는 그라데이션이 아니라 임계값으로 자른 **면**이다. 디더링을 쓰면
/// 전체가 얼룩덜룩해져서 이 스타일이 안 나온다.
///
/// 고정 크기 비트맵을 늘리는 대신 뷰포트 크기에 맞춰 픽셀 버퍼를 생성하므로
/// 모바일·PC 어느 비율에서도 잘리거나 레터박스가 생기지 않는다. 생성한 버퍼는
/// [FilterQuality.none]으로 정수배 확대해 도트가 뭉개지지 않는다.

/// 설경 팔레트 — **하늘색 단색 계열**. 색상(hue)을 하나로 묶어 두면 채도가 꽤
/// 높아도 차분하게 읽힌다. 차분하게 만들겠다고 채도를 내리면 물 빠진 회색이
/// 되므로, 조절은 채도가 아니라 **색상 통일**로 할 것.
///
/// hue는 청록(~180)이 아니라 **하늘색(~208)**이어야 한다. 눈 그늘은 하늘을
/// 반사해서 파랗지, 초록을 띠지 않는다 — 청록으로 두면 설경이 아니라 민트색
/// 들판으로 읽힌다.
abstract final class SnowScene {
  /// 눈(거의 흰색이지만 푸른기가 돈다) — 화면의 대부분.
  static const snow = Color(0xFFF5F9FD);
  static const shade1 = Color(0xFFE6F0F8);
  static const shade2 = Color(0xFFCCDFEE);
  static const shade3 = Color(0xFFACC7DE);

  /// 침엽수 — 짙은 청록녹색. 눈밭이 파랄수록 나무는 초록기를 남겨야 구분된다.
  static const pine = Color(0xFF2C4C50);
  static const pineDark = Color(0xFF1A3337);

  /// 가지 윗면에 얹힌 눈 — 겨울로 읽히게 하는 결정적 한 겹.
  static const pineSnow = Color(0xFFE9F3FD);

  /// 슈프르(지나간 자국). 지형에는 굽지 않는다 — 라이더가 실제로 지난 자리에만
  /// SkiSlopeActors가 남긴다. 미리 구워 두면 "깔아 놓은 길을 따라 달리는" 것처럼
  /// 보인다.
  static const track = Color(0xFFD2E0EE);

  /// 산장·리프트 — 작고 어둡게.
  static const structure = Color(0xFF33506B);
  static const structureDark = Color(0xFF22374A);

  /// 창 불빛 — 온통 푸른 화면에서 유일한 따뜻한 점. 작게 쓸 것.
  static const window = Color(0xFFF0C669);

  /// 글자 외곽선·페이지 바탕에 쓰는 별칭.
  static const paper = snow;
}

/// 도트 한 칸(논리 px). 배경·라이더가 **같은 값**을 써야 격자가 안 어긋난다.
const double kSceneDot = 3.0;

/// ui.decodeImageFromPixels의 rgba8888 순서(리틀엔디언에서 바이트 R,G,B,A).
int _rgba(Color c) =>
    (0xFF << 24) |
    ((c.b * 255).round() << 16) |
    ((c.g * 255).round() << 8) |
    (c.r * 255).round();

/// 정수 해시 — 같은 크기면 항상 같은 씬이 나오도록 난수 대신 쓴다.
/// 웹(JS)에서 int는 double이라 2^53을 넘는 곱은 정밀도가 깨진다. 큰 상수를 곱하는
/// 대신 작은 소수 곱 + xorshift로 섞어 어느 플랫폼에서나 같은 값이 나오게 한다.
int _hash(int x, int y, int seed) {
  int h = (x * 73856093) ^ (y * 19349663) ^ (seed * 83492791);
  h &= 0x7FFFFFFF;
  h ^= h >> 15;
  h ^= (h << 13) & 0x7FFFFFFF;
  h ^= h >> 7;
  h ^= (h << 9) & 0x7FFFFFFF;
  h ^= h >> 11;
  return h & 0x7FFFFFFF;
}

double _hash01(int x, int y, int seed) => _hash(x, y, seed) / 0x7FFFFFFF;

double _smooth(double t) => t * t * (3 - 2 * t);

double _noise(double x, double y, int seed) {
  final xi = x.floor(), yi = y.floor();
  final xf = _smooth(x - xi), yf = _smooth(y - yi);
  final a = _hash01(xi, yi, seed);
  final b = _hash01(xi + 1, yi, seed);
  final c = _hash01(xi, yi + 1, seed);
  final d = _hash01(xi + 1, yi + 1, seed);
  return (a + (b - a) * xf) * (1 - yf) + (c + (d - c) * xf) * yf;
}

double _fbm(double x, double y, int seed) =>
    _noise(x, y, seed) * 0.6 +
    _noise(x * 2.1, y * 2.1, seed + 7) * 0.3 +
    _noise(x * 4.3, y * 4.3, seed + 13) * 0.1;

// ── 슬로프 기하(두 레이어 공유) ──

/// 지형(정적 비트맵)과 라이더·리프트(애니메이션)가 **같은 곡선**을 써야 라이더가
/// 엉뚱한 데로 내려가거나 의자가 케이블에서 떨어지지 않는다.
class SlopeGeometry {
  final double cell;
  final int cols;
  final double halfBase;
  final double sway;

  const SlopeGeometry({
    required this.cell,
    required this.cols,
    required this.halfBase,
    required this.sway,
  });

  factory SlopeGeometry.of(
    double width,
    double pisteWidth, {
    double? cellSize,
  }) {
    final cell = cellSize ?? kSceneDot;
    final cols = (width / cell).ceil();
    return SlopeGeometry(
      cell: cell,
      cols: cols,
      halfBase: math.min(pisteWidth / 2 / cell, cols * 0.40),
      sway: math.min(cols * 0.03, 16.0),
    );
  }

  double _centerCells(double y) =>
      cols / 2 +
      sway * (math.sin(y * 0.0085) * 0.62 + math.sin(y * 0.0033 + 1.1) * 0.38);

  double _halfCells(double y) =>
      halfBase * (1 + 0.10 * math.sin(y * 0.0050 + 0.6));

  /// 페이지 y(논리 px)에서 슬로프 중심 x(논리 px).
  double centerPx(double y) => _centerCells(y / cell) * cell;

  /// 같은 지점의 반폭(논리 px).
  double halfPx(double y) => _halfCells(y / cell) * cell;

  /// 리프트 케이블이 지나는 x(논리 px).
  double cableX(double y) => centerPx(y) + halfPx(y) * 0.92;

  @override
  bool operator ==(Object other) =>
      other is SlopeGeometry &&
      other.cell == cell &&
      other.cols == cols &&
      other.halfBase == halfBase &&
      other.sway == sway;

  @override
  int get hashCode => Object.hash(cell, cols, halfBase, sway);
}

// ── 픽셀 버퍼 ──

class _Buf {
  final int w;
  final int h;
  final Uint32List px;
  _Buf(this.w, this.h) : px = Uint32List(w * h);

  void set(int x, int y, int argb) {
    if (x < 0 || y < 0 || x >= w || y >= h) return;
    px[y * w + x] = argb;
  }

  void span(int y, int l, int r, int argb) {
    for (int x = l; x <= r; x++) {
      set(x, y, argb);
    }
  }
}

// ── 씬 생성 ──

/// [geo] 기하로 [rows]행짜리 설경을 그려 rgba8888 버퍼로 돌려준다.
/// 움직이는 것(라이더·리프트 의자)은 여기 없고 SkiSlopeActors가 그린다.
Uint32List paintSlopeScene(
  SlopeGeometry geo,
  int rows, {
  double clearTop = 0,
  double clearBottom = 0,
}) {
  final cols = geo.cols;
  final buf = _Buf(cols, rows);

  // 제목이 올라앉는 가로 띠 — 모바일처럼 화면이 좁으면 양옆 숲이 글자까지
  // 밀고 들어와 안 읽힌다. 사각형으로 자르면 경계가 그대로 보이므로
  // 타원으로 잡고 가장자리에서 밀도와 키를 함께 줄여 서서히 섞는다.
  final _Clear? clear = clearBottom > clearTop
      ? _Clear(
          cy: (clearTop + clearBottom) / 2 / geo.cell,
          halfY: (clearBottom - clearTop) / 2 / geo.cell,
          cx: cols / 2,
          halfX: cols / 2,
        )
      : null;

  final snow = _rgba(SnowScene.snow);
  final sh1 = _rgba(SnowScene.shade1);
  final sh2 = _rgba(SnowScene.shade2);
  final sh3 = _rgba(SnowScene.shade3);

  // 1) 눈 — 저주파 노이즈를 임계값으로 **잘라** 수채 얼룩 같은 면을 만든다.
  //    그라데이션으로 칠하면 전체가 뿌옇게 번져서 이 스타일이 안 나온다.
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      double n = _fbm(x * 0.0055, y * 0.0045, 3);
      // 가운데는 카드가 올라앉는 자리라 밝게 비우고 그늘을 양옆으로 민다.
      final off = (x - cols / 2).abs() / (cols / 2);
      n += off * 0.16 - 0.10;
      int col = snow;
      if (n > 0.52) col = sh1;
      if (n > 0.61) col = sh2;
      // 가장 짙은 톤은 가장자리에서만 — 안쪽에 깔리면 호수처럼 보인다.
      if (n > 0.70 && off > 0.55) col = sh3;
      buf.px[y * cols + x] = col;
    }
  }

  _paintForest(buf, geo, cols, rows, clear);
  _paintShrubs(buf, cols, rows);
  _paintLift(buf, geo, rows);
  _paintLodge(buf, geo, rows);

  return buf.px;
}

/// 침엽수 한 그루 — 눈을 얹지 않은 짙은 실루엣 + 왼쪽 아래로 길게 눕는 그림자.
/// 이 긴 그림자가 레퍼런스의 가장 큰 특징이라 나무보다 먼저, 더 길게 그린다.
void _paintPine(_Buf buf, int cx, int by, int h) {
  final pine = _rgba(SnowScene.pine);
  final dark = _rgba(SnowScene.pineDark);
  final cap = _rgba(SnowScene.pineSnow);
  final sh1 = _rgba(SnowScene.shade1);
  final sh2 = _rgba(SnowScene.shade2);
  final half = math.max(1, (h * 0.30).round());

  final shadowLen = (h * 1.6).round();
  for (int k = 0; k < shadowLen; k++) {
    final t = k / shadowLen;
    final sx = cx - (k * 1.25).round() - 1;
    final sy = by + (k * 0.16).round();
    final w = math.max(0, (half * (1 - t * 0.85)).round());
    buf.span(sy, sx - w, sx + w, t < 0.45 ? sh2 : sh1);
  }

  for (int k = 0; k < h; k++) {
    final t = k / math.max(1, h - 1);
    final tier = k / 2.6;
    final step = tier - tier.floorToDouble();
    final w = (0.3 + half * t * (0.80 + 0.30 * step)).round();
    for (int d = -w; d <= w; d++) {
      buf.set(cx + d, by - h + k, d > w * 0.3 ? dark : pine);
    }
    // 눈은 가지 단이 **새로 시작하는 행의 왼쪽 윗면**에만 얹는다. 통째로
    // 덮으면 나무가 하얘져 눈밭에 묻히고, 화면도 빽빽해진다.
    if (step < 1 / 2.6 && w >= 1) {
      final capW = math.max(1, (w * 0.55).round());
      for (int d = -w; d < -w + capW; d++) {
        buf.set(cx + d, by - h + k, cap);
      }
    }
  }
  buf.set(cx, by - h, cap);
  for (int k = 0; k < math.max(1, (h * 0.10).round()); k++) {
    buf.set(cx, by - k, dark);
  }
}

/// 나무를 비울 타원(도트 단위). [factor]는 0이면 완전히 비우고 1이면 평소대로다.
class _Clear {
  final double cx, cy, halfX, halfY;
  const _Clear({
    required this.cx,
    required this.cy,
    required this.halfX,
    required this.halfY,
  });

  /// 타원 안쪽(d<=1)은 0, 바깥으로 [_feather]만큼 가는 동안 1로 올라온다.
  static const double _feather = 0.45;

  double factor(num px, num py) {
    final dx = (px - cx) / halfX;
    final dy = (py - cy) / halfY;
    final d = math.sqrt(dx * dx + dy * dy);
    if (d >= 1 + _feather) return 1;
    if (d <= 1) return 0;
    return (d - 1) / _feather;
  }
}

/// 숲 — 군락 중심을 먼저 찍고 그 주변에만 심는다. 격자에 고르게 뿌리면
/// "점 흩뿌림"이 되고 숲 덩어리로 안 읽힌다.
void _paintForest(
    _Buf buf, SlopeGeometry geo, int cols, int rows, _Clear? clear) {
  final clumps = <({double x, double y, double r})>[];
  final count = math.max(6, (rows / 130).round());
  for (int i = 0; i < count; i++) {
    final r1 = _hash01(i, 0, 991);
    final r2 = _hash01(i, 1, 991);
    final r3 = _hash01(i, 2, 991);
    // 가운데(콘텐츠 자리)는 비우고 양옆에 앉힌다.
    final side = i.isEven ? -1 : 1;
    clumps.add((
      x: cols / 2 + side * (cols * 0.22 + r1 * cols * 0.26),
      y: r2 * rows * 1.05,
      r: 26 + r3 * 40,
    ));
  }

  const gx = 11, gy = 10;
  for (int cy = -1; cy * gy < rows + 40; cy++) {
    for (int cxi = -1; cxi * gx < cols + 30; cxi++) {
      final px = cxi * gx + (_hash01(cxi, cy, 101) * gx).floor();
      final py = cy * gy + (_hash01(cxi, cy, 151) * gy).floor();
      double best = double.infinity;
      for (final cl in clumps) {
        final dx = px - cl.x, dy = py - cl.y;
        final d = math.sqrt(dx * dx + dy * dy) / cl.r;
        if (d < best) best = d;
      }
      if (best > 1.15) continue;
      final k = clear?.factor(px, py) ?? 1;
      if (k <= 0) continue;
      if (_hash01(cxi, cy, 211) > (1 - best / 1.15) * 0.85 * k) continue;
      // 밀도만 줄이면 경계에 큰 나무가 툭 서서 선이 보인다. 키도 같이 낮춘다.
      final h = (8 + _hash01(cxi, cy, 307) * 14) * (0.45 + 0.55 * k);
      _paintPine(buf, px, py, h.round());
    }
  }

  _paintStrayPines(buf, geo, cols, rows, clear);
}

/// 군락 사이 빈 눈밭에 **한두 그루씩** 흩어 심는다.
/// 군락만 있으면 그 사이가 통째로 비어 허전하고, 레퍼런스에도 외딴 나무가 있다.
/// 라이더가 지나는 안쪽(슬로프 중심 ±0.55)은 비워 둔다 — 거기 심으면 라이더와
/// 겹친다.
void _paintStrayPines(
    _Buf buf, SlopeGeometry geo, int cols, int rows, _Clear? clear) {
  // 격자는 성기게, 확률도 낮게 — 빈 눈밭이 이 스타일의 핵심이라 "중간중간
  // 한두 그루"를 넘으면 금방 숲이 된다.
  const gx = 40, gy = 36;
  for (int cy = 0; cy * gy < rows; cy++) {
    for (int cxi = 0; cxi * gx < cols; cxi++) {
      if (_hash01(cxi, cy, 613) > 0.26) continue;
      final px = cxi * gx + (_hash01(cxi, cy, 617) * gx).floor();
      final py = cy * gy + (_hash01(cxi, cy, 619) * gy).floor();
      if (py >= rows) continue;
      final yPx = py * geo.cell;
      final d = (px * geo.cell - geo.centerPx(yPx)).abs() / geo.halfPx(yPx);
      if (d < 0.55) continue;
      final k = clear?.factor(px, py) ?? 1;
      if (k <= 0 || _hash01(cxi, cy, 631) > k) continue;
      // 외딴 나무는 작게 — 크면 군락처럼 보여 흩어 심은 티가 안 난다.
      final hh = (7 + _hash01(cxi, cy, 623) * 8) * (0.45 + 0.55 * k);
      _paintPine(buf, px, py, hh.round());
    }
  }
}

/// 잔가지 덤불 — 크기 비교 대상이 되어 빈 눈밭이 허전하지 않다.
void _paintShrubs(_Buf buf, int cols, int rows) {
  final dark = _rgba(SnowScene.pineDark);
  final sh1 = _rgba(SnowScene.shade1);
  final n = math.max(8, (rows / 40).round());
  for (int i = 0; i < n; i++) {
    final x = (_hash01(i, 5, 771) * cols).floor();
    final y = (_hash01(i, 6, 771) * rows).floor();
    if ((x - cols / 2).abs() < cols * 0.08) continue;
    buf.set(x, y, dark);
    buf.set(x - 1, y - 1, dark);
    buf.set(x + 1, y - 1, dark);
    buf.set(x, y - 1, dark);
    buf.set(x, y - 2, dark);
    buf.set(x - 2, y, dark);
    buf.set(x + 2, y, dark);
    buf.span(y + 1, x - 4, x + 1, sh1);
  }
}

/// 리프트 — 가는 케이블 + 아주 작은 철탑. 의자는 SkiSlopeActors가 올린다.
void _paintLift(_Buf buf, SlopeGeometry geo, int rows) {
  final line = _rgba(SnowScene.structure);
  final dark = _rgba(SnowScene.structureDark);
  final sh2 = _rgba(SnowScene.shade2);
  for (int y = 0; y < rows; y++) {
    buf.set((geo.cableX(y * geo.cell) / geo.cell).round(), y, line);
  }
  // 철탑 — 가로대 한 줄과 기둥 몇 칸이면 충분하다.
  for (int y = 40; y < rows; y += 150) {
    final lx = (geo.cableX(y * geo.cell) / geo.cell).round();
    buf.span(y, lx - 3, lx + 3, dark);
    for (int k = 1; k <= 4; k++) {
      buf.set(lx, y + k, dark);
    }
    buf.span(y + 5, lx - 6, lx - 1, sh2);
  }
}

/// 정상 산장 — 작고 어두운 실루엣 + 창 불빛.
/// 레퍼런스엔 건물이 없지만 스키장임을 알리는 최소한의 사물로 남긴다.
void _paintLodge(_Buf buf, SlopeGeometry geo, int rows) {
  if (rows < 60) return;
  final body = _rgba(SnowScene.structure);
  final dark = _rgba(SnowScene.structureDark);
  final win = _rgba(SnowScene.window);
  final sh2 = _rgba(SnowScene.shade2);

  final cx = (geo.centerPx(6 * geo.cell) / geo.cell).round();
  const top = 5;
  // 그림자 먼저 — 나무와 같은 방향(왼쪽 아래)으로 눕혀야 광원이 하나로 보인다.
  for (int k = 0; k < 7; k++) {
    buf.span(top + 8 + k, cx - 14 - k, cx + 11 - k, sh2);
  }
  // 박공지붕.
  for (int k = 0; k < 5; k++) {
    buf.span(top + k, cx - 2 - k * 2, cx + 2 + k * 2, dark);
  }
  // 벽 + 창.
  for (int k = 0; k < 4; k++) {
    buf.span(top + 5 + k, cx - 10, cx + 10, body);
  }
  buf.span(top + 6, cx - 7, cx - 5, win);
  buf.span(top + 6, cx - 1, cx + 1, win);
  buf.span(top + 6, cx + 5, cx + 7, win);
  buf.span(top + 9, cx - 10, cx + 10, dark);
  for (int x = cx - 8; x <= cx + 8; x += 4) {
    buf.set(x, top + 10, dark);
    buf.set(x, top + 11, dark);
  }
}

// ── 위젯 ──

class _SceneCache {
  final int cols;
  final int rows;
  final ui.Image image;
  _SceneCache(this.cols, this.rows, this.image);
}

/// 페이지 뒤에 까는 설경 배경.
class SkiSlopeBackground extends StatefulWidget {
  /// 도트 한 칸 크기(논리 px). 주지 않으면 [kSceneDot].
  final double? cellSize;

  /// 라이더가 내려오는 길의 폭(논리 px). 지형에 띠를 그리지는 않고, 숲을 비우고
  /// 라이더·리프트 경로를 정하는 데 쓴다.
  final double pisteWidth;

  /// 제목이 올라앉는 가로 띠(논리 px, 이 위젯 기준). 이 안쪽은 나무를 비워
  /// 글자가 읽히게 한다. 같으면(기본) 비우지 않는다.
  final double clearTop;
  final double clearBottom;

  const SkiSlopeBackground({
    super.key,
    this.cellSize,
    this.pisteWidth = 1440,
    this.clearTop = 0,
    this.clearBottom = 0,
  });

  @override
  State<SkiSlopeBackground> createState() => _SkiSlopeBackgroundState();
}

class _SkiSlopeBackgroundState extends State<SkiSlopeBackground> {
  _SceneCache? _cache;
  SlopeGeometry? _pendingGeo;
  int _pendingRows = -1;
  double _pendingClear = double.nan;
  double _builtClear = double.nan;

  @override
  void dispose() {
    _cache?.image.dispose();
    super.dispose();
  }

  Future<void> _build(SlopeGeometry geo, int rows) async {
    final clearKey = widget.clearBottom - widget.clearTop;
    if (_pendingGeo == geo &&
        _pendingRows == rows &&
        _pendingClear == clearKey) {
      return;
    }
    _pendingGeo = geo;
    _pendingRows = rows;
    _pendingClear = clearKey;

    final pixels = paintSlopeScene(
      geo,
      rows,
      clearTop: widget.clearTop,
      clearBottom: widget.clearBottom,
    );
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels.buffer.asUint8List(),
      geo.cols,
      rows,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final image = await completer.future;
    if (!mounted ||
        _pendingGeo != geo ||
        _pendingRows != rows ||
        _pendingClear != clearKey) {
      image.dispose();
      return;
    }
    setState(() {
      _cache?.image.dispose();
      _cache = _SceneCache(geo.cols, rows, image);
      _builtClear = clearKey;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        final rows = (h / geo.cell).ceil();

        // 레이아웃 중에 setState를 부를 수 없으니 프레임 뒤로 미룬다.
        if (_cache == null ||
            _cache!.cols != geo.cols ||
            _cache!.rows != rows ||
            _builtClear != widget.clearBottom - widget.clearTop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _build(geo, rows);
          });
        }

        return RepaintBoundary(
          child: CustomPaint(
            size: Size(w, h),
            painter: _ScenePainter(_cache?.image),
          ),
        );
      },
    );
  }
}

class _ScenePainter extends CustomPainter {
  final ui.Image? image;
  _ScenePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final img = image;
    if (img == null) {
      // 아직 씬이 안 만들어졌으면 눈색 단색 — 흰 화면이 번쩍이지 않게.
      canvas.drawRect(Offset.zero & size, Paint()..color = SnowScene.snow);
      return;
    }
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Offset.zero & size,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => old.image != image;
}
