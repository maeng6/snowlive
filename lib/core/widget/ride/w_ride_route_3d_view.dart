import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rideDetail.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_js/three_js.dart' as three;

/// 테마색 — 스노우라이브 블루. 리본/글로우/커튼/계기판/배속 선택 톤 통일.
const Color _kBlue = SDSColor.snowliveBlue;

/// 라이딩 궤적 3D 뷰(앱·웹 공용). PaceFace의 three_js 3D 경로 연출을 그대로 이식했다
/// — 고도 그라데이션 튜브 + 경사도 커튼(경로 아래 그라데이션 면) + 발광 마커 + 자동 회전.
///
/// 궤적 samples(lat/lng/alt)를 RoutePoint로 바꿔 [Route3DThreeJsWidget]에 넘긴다.
class RideRoute3DView extends StatelessWidget {
  final RideSamples samples;

  /// 슬로프 면(외곽 폴리곤·진행축). 있으면 바닥에 슬로프 경계+면을 함께 그린다(웹 2.5D).
  final RideSlope? slope;
  final double height;

  /// 카메라가 슬로프를 따라 내려가며 확대해 보여주는 플라이다운 모드(긴 슬로프용).
  final bool follow;

  /// 리본/커튼 기본색(PaceFace warmAccent 0xFFECFF90). 고도 그라데이션과 톤 통일.
  static const Color kRibbon = Color(0xFFECFF90);

  /// 라이딩 최종 점수. 있으면 내려가면서 0→최종으로 실시간 누적 표시.
  final double? score;

  /// 라이딩 총 거리(m). 있으면 점수 아래에 실시간 누적 거리 표시.
  final double? distance;

  const RideRoute3DView(
      {super.key,
      required this.samples,
      this.slope,
      this.height = 470,
      this.follow = false,
      this.score,
      this.distance});

  List<RoutePoint> _routePoints() {
    final n = samples.length;
    final out = <RoutePoint>[];
    for (int i = 0; i < n; i++) {
      final a = (i < samples.alt.length) ? samples.alt[i] : null;
      out.add(RoutePoint(
        latitude: samples.lat[i],
        longitude: samples.lng[i],
        altitude: (a != null && a.isFinite) ? a : null,
      ));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    // 웹·앱 공통으로 네이티브 CustomPainter 2.5D를 쓴다 — 슬로프 경계+면, 궤적 리본,
    // 발광 마커, 회전까지 양 플랫폼에서 "완전히 동일한 그림"을 보장한다. (three_js는
    // 웹에서 렌더가 불안정하고 슬로프 면도 없어 제외)
    return RideRoute25DView(
        samples: samples,
        slope: slope,
        height: height,
        follow: follow,
        score: score,
        distance: distance);
  }
}

/// 좌표 전용 라우트 포인트(PaceFace RoutePoint 호환 필드).
class RoutePoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  const RoutePoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
  });
}

/// 3D 경로 렌더링 모드
enum Route3DRenderMode { static, rotating }

// ─────────────────────────────────────────────
// 공통 헬퍼 (PaceFace route_3d_threejs_widget.dart 이식)
// ─────────────────────────────────────────────

/// GPS RoutePoint → 정규화된 3D 좌표 변환
List<three.Vector3> convertRoutePoints(List<RoutePoint> routePoints) {
  double minLat = double.infinity, maxLat = double.negativeInfinity;
  double minLng = double.infinity, maxLng = double.negativeInfinity;
  double minAlt = double.infinity, maxAlt = double.negativeInfinity;

  for (final point in routePoints) {
    minLat = math.min(minLat, point.latitude);
    maxLat = math.max(maxLat, point.latitude);
    minLng = math.min(minLng, point.longitude);
    maxLng = math.max(maxLng, point.longitude);
    if (point.altitude != null) {
      minAlt = math.min(minAlt, point.altitude!);
      maxAlt = math.max(maxAlt, point.altitude!);
    }
  }

  if (minAlt == double.infinity) {
    minAlt = 0;
    maxAlt = 0;
  }

  final latRange = maxLat - minLat;
  final lngRange = maxLng - minLng;
  final altRange = maxAlt - minAlt;

  // 실제 물리적 거리(m) 기반 고도 스케일 계산
  final midLat = (minLat + maxLat) / 2;
  final latMeters = latRange * 111320;
  final lngMeters = lngRange * 111320 * math.cos(midLat * math.pi / 180);
  final maxExtentMeters = math.max(latMeters, lngMeters);

  double yMultiplier;
  if (altRange <= 0 || maxExtentMeters <= 0) {
    yMultiplier = 0;
  } else {
    final realRatio = altRange / maxExtentMeters;
    yMultiplier = (realRatio * 2 * 3.0).clamp(0.05, 0.8);
  }

  List<three.Vector3> points = [];

  for (final point in routePoints) {
    double x = lngRange > 0 ? ((point.longitude - minLng) / lngRange) * 2 - 1 : 0;
    double z = latRange > 0 ? ((point.latitude - minLat) / latRange) * 2 - 1 : 0;
    double y = altRange > 0 && point.altitude != null
        ? ((point.altitude! - minAlt) / altRange) * yMultiplier
        : 0;
    points.add(three.Vector3(x, y, z));
  }

  // 경로 단순화 (300포인트 이하로)
  if (points.length > 300) {
    final step = points.length / 300;
    points = List.generate(300, (i) => points[(i * step).floor()]);
  }

  return points;
}

/// 커튼 mesh 생성 (경로 아래 그라데이션 면) — 경사도 커튼.
three.Mesh buildCurtainMesh(
  three.CatmullRomCurve3 curve,
  int segments,
  double minY,
  double maxY, {
  Color? color,
}) {
  final positions = <double>[];
  final alphas = <double>[];
  final indices = <int>[];

  for (int i = 0; i <= segments; i++) {
    final t = (i / segments).clamp(0.0, 1.0);
    final p = curve.getPointAt(t) as three.Vector3;

    positions.addAll([p.x, p.y, p.z]);
    alphas.add(0.25);

    positions.addAll([p.x, minY, p.z]);
    alphas.add(0.0);
  }

  for (int i = 0; i < segments; i++) {
    final tl = i * 2;
    final bl = tl + 1;
    final tr = (i + 1) * 2;
    final br = tr + 1;
    indices.addAll([tl, bl, tr, tr, bl, br]);
  }

  final geometry = three.BufferGeometry();
  geometry.setAttributeFromString(
    'position',
    three.Float32BufferAttribute.fromList(positions, 3, false),
  );
  geometry.setAttributeFromString(
    'aAlpha',
    three.Float32BufferAttribute.fromList(alphas, 1, false),
  );
  geometry.setIndex(indices);

  final c = color ?? const Color(0xFFECFF90);
  final material = three.ShaderMaterial.fromMap({
    'transparent': true,
    'side': 2,
    'depthWrite': false,
    'vertexShader': '''
      attribute float aAlpha;
      varying float vAlpha;
      void main() {
        vAlpha = aAlpha;
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }
    ''',
    'fragmentShader': '''
      uniform vec3 uColor;
      varying float vAlpha;
      void main() {
        gl_FragColor = vec4(uColor, vAlpha);
      }
    ''',
    'uniforms': {
      'uColor': {
        'value': three.Vector3(c.r.toDouble(), c.g.toDouble(), c.b.toDouble()),
      },
    },
  });

  return three.Mesh(geometry, material);
}

/// 마커 위치 업데이트 (공 + 발광 디스크)
void updateMarkerOnCurve(
  three.Mesh marker,
  three.Mesh? glowDisk,
  three.CatmullRomCurve3 curve,
  double progress,
) {
  final clamped = progress.clamp(0.0, 1.0);
  final pos = curve.getPointAt(clamped) as three.Vector3;

  marker.position.setValues(pos.x, pos.y + 0.05, pos.z);

  if (glowDisk != null) {
    glowDisk.position.setValues(pos.x, pos.y + 0.05, pos.z);
  }
}

/// 고도 기반 그라데이션 색상 (0=white → 1=warmAccent 0xFFECFF90)
List<double> elevationColor(double t) {
  t = t.clamp(0.0, 1.0);
  return [
    1.0 - 0.0746 * t,
    1.0,
    1.0 - 0.4353 * t,
  ];
}

// ─────────────────────────────────────────────
// 프리뷰 위젯 (rotating 모드) — PaceFace 이식
// ─────────────────────────────────────────────

class Route3DThreeJsWidget extends StatefulWidget {
  final List<RoutePoint> routePoints;
  final Route3DRenderMode renderMode;
  final Color ribbonColor;
  final Color? graphColor;
  final bool showElevationGradient;
  final double size;
  final double initialRotation;
  final Duration animationDuration;

  const Route3DThreeJsWidget({
    super.key,
    required this.routePoints,
    this.renderMode = Route3DRenderMode.rotating,
    required this.ribbonColor,
    this.graphColor,
    this.showElevationGradient = false,
    this.size = 180,
    this.initialRotation = 0,
    this.animationDuration = const Duration(seconds: 10),
  });

  @override
  State<Route3DThreeJsWidget> createState() => Route3DThreeJsWidgetState();
}

class Route3DThreeJsWidgetState extends State<Route3DThreeJsWidget> {
  three.ThreeJS? _threeJs;
  three.Scene? _scene;
  three.PerspectiveCamera? _camera;
  three.Mesh? _tubeMesh;
  three.Mesh? _markerMesh;
  three.Mesh? _glowDisk;
  three.Object3D? _routeGroup;
  three.CatmullRomCurve3? _curve;

  bool _isReady = false;
  bool _disposed = false;
  double _currentRotation = 0;
  double _markerProgress = 0;
  double get markerProgress => _markerProgress;
  double _glowTime = 0;

  DateTime _lastAnimateTime = DateTime.now();
  Timer? _healthCheckTimer;
  int _consecutiveRestarts = 0;

  @override
  void initState() {
    super.initState();
    _currentRotation = widget.initialRotation;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_disposed) {
        _initThreeJs();
        setState(() {});
      }
    });
    if (widget.renderMode == Route3DRenderMode.rotating) {
      _healthCheckTimer = Timer.periodic(const Duration(seconds: 2), _checkHealth);
    }
  }

  void _initThreeJs() {
    _disposed = false;
    _isReady = false;
    _threeJs = three.ThreeJS(
      onSetupComplete: () {
        if (mounted && !_disposed) setState(() {});
      },
      setup: _setup,
      settings: three.Settings(
        alpha: true,
        clearAlpha: 0.0,
        clearColor: 0x000000,
        antialias: true,
        enableShadowMap: false,
      ),
      size: Size(widget.size, widget.size),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _healthCheckTimer?.cancel();
    _threeJs?.dispose();
    _threeJs = null;
    super.dispose();
  }

  void _checkHealth(Timer timer) {
    if (_disposed || !mounted) {
      timer.cancel();
      return;
    }
    if (!_isReady) return;
    if (_consecutiveRestarts >= 3) return;

    final elapsed = DateTime.now().difference(_lastAnimateTime);
    if (elapsed > const Duration(seconds: 2)) {
      _consecutiveRestarts++;
      _threeJs?.dispose();
      _threeJs = null;
      _isReady = false;
      _lastAnimateTime = DateTime.now();
      _initThreeJs();
      if (mounted) setState(() {});
    }
  }

  void setRotationAngle(double angle) {
    _currentRotation = angle;
    if (_routeGroup != null) _routeGroup!.rotation.y = angle;
  }

  void setMarkerProgress(double progress) {
    _markerProgress = progress;
    _updateMarker(progress);
  }

  Future<void> _setup() async {
    if (_disposed) return;

    _scene = three.Scene();
    _threeJs!.scene = _scene!;

    _camera = three.PerspectiveCamera(45, 1.0, 0.1, 100);
    _threeJs!.camera = _camera!;

    _scene!.add(three.AmbientLight(0xffffff, 0.6));
    final dirLight = three.DirectionalLight(0xffffff, 0.8);
    dirLight.position.setValues(2, 3, 2);
    _scene!.add(dirLight);
    final dirLight2 = three.DirectionalLight(0xffffff, 0.3);
    dirLight2.position.setValues(-2, 1, -1);
    _scene!.add(dirLight2);

    _buildRoute();

    if (widget.renderMode == Route3DRenderMode.rotating) {
      _threeJs!.addAnimationEvent(_animate);
    }

    _isReady = true;
  }

  void _buildRoute() {
    if (widget.routePoints.length < 2) return;

    final pathPoints = convertRoutePoints(widget.routePoints);
    if (pathPoints.length < 2) return;

    double maxRadius = 0;
    double maxY = 0;
    double minY = double.infinity;
    for (final p in pathPoints) {
      final horizontalDist = math.sqrt(p.x * p.x + p.z * p.z);
      maxRadius = math.max(maxRadius, horizontalDist);
      maxY = math.max(maxY, p.y);
      minY = math.min(minY, p.y);
    }
    if (minY == double.infinity) minY = 0;
    final sceneRadius = math.max(maxRadius, maxY + 0.1);
    final fovRad = 45 * math.pi / 180;
    final camDist = (sceneRadius / math.tan(fovRad / 2)) * 1.15;
    final camHeight = camDist * 0.4;
    final centerY = maxY * 0.4;
    _camera!.position.setValues(0, camHeight, camDist);
    _camera!.lookAt(three.Vector3(0, centerY, 0));

    _routeGroup = three.Object3D();
    _routeGroup!.rotation.y = _currentRotation;
    _scene!.add(_routeGroup!);

    _curve = three.CatmullRomCurve3(
      points: pathPoints,
      closed: false,
      curveType: 'centripetal',
      tension: 0.5,
    );

    final tubularSegments = math.max(pathPoints.length * 2, 64);
    const radialSegments = 8;
    final tubeGeometry = three.TubeGeometry(
        _curve, tubularSegments, 0.016, radialSegments, false);

    final r = widget.ribbonColor.r;
    final g = widget.ribbonColor.g;
    final b = widget.ribbonColor.b;

    final yRange = maxY - minY;
    final useGradient = widget.showElevationGradient && yRange > 0.01;

    if (useGradient) {
      try {
        final colors = <double>[];
        for (int i = 0; i <= tubularSegments; i++) {
          final t = (i / tubularSegments).clamp(0.0, 1.0);
          final point = _curve!.getPointAt(t) as three.Vector3;
          final ny = (point.y - minY) / yRange;
          final c = elevationColor(ny);
          for (int j = 0; j <= radialSegments; j++) {
            colors.addAll(c);
          }
        }
        tubeGeometry.setAttributeFromString(
          'color',
          three.Float32BufferAttribute.fromList(colors, 3, false),
        );
      } catch (_) {}
    }

    final tubeMaterial = three.MeshBasicMaterial({
      three.MaterialProperty.color:
          useGradient ? three.Color(1.0, 1.0, 1.0) : three.Color(r, g, b),
      three.MaterialProperty.vertexColors: useGradient,
    });

    _tubeMesh = three.Mesh(tubeGeometry, tubeMaterial);
    _routeGroup!.add(_tubeMesh!);

    // 경사도 커튼
    _routeGroup!.add(buildCurtainMesh(_curve!, tubularSegments, minY, maxY,
        color: widget.graphColor ?? widget.ribbonColor));

    final markerGeometry = three.SphereGeometry(0.04, 16, 12);
    final markerMaterial = three.MeshPhongMaterial({
      three.MaterialProperty.color: three.Color.fromHex32(0xFFFFFF),
      three.MaterialProperty.emissive: three.Color.fromHex32(0xFFFFFF),
      three.MaterialProperty.shininess: 0.0,
    });
    _markerMesh = three.Mesh(markerGeometry, markerMaterial);
    _routeGroup!.add(_markerMesh!);

    final glowGeometry = three.SphereGeometry(0.12, 16, 8);
    final glowMaterial = three.MeshPhongMaterial({
      three.MaterialProperty.color: three.Color.fromHex32(0xFFFFFF),
      three.MaterialProperty.emissive: three.Color.fromHex32(0xFFFFFF),
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 0.4,
    });
    _glowDisk = three.Mesh(glowGeometry, glowMaterial);
    _routeGroup!.add(_glowDisk!);

    _updateMarker(0);
  }

  void _updateMarker(double progress) {
    if (_markerMesh == null || _curve == null) return;
    updateMarkerOnCurve(_markerMesh!, _glowDisk, _curve!, progress);
  }

  void _animate(double dt) {
    _lastAnimateTime = DateTime.now();
    _consecutiveRestarts = 0;
    if (!_isReady || _routeGroup == null || _disposed) return;

    if (widget.renderMode == Route3DRenderMode.rotating) {
      final durationMs = widget.animationDuration.inMilliseconds;
      final rotSpeed = (2 * math.pi) / (durationMs / 1000.0);
      _currentRotation += rotSpeed * dt;
      _markerProgress = (_currentRotation % (2 * math.pi)) / (2 * math.pi);
    }

    _routeGroup!.rotation.y = _currentRotation;
    _updateMarker(_markerProgress);

    _glowTime += dt;
    if (_glowDisk != null) {
      final pulse = 0.35 + 0.2 * math.sin(_glowTime * 4.0);
      _glowDisk!.material!.opacity = pulse;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_threeJs == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    // ⚠️ 웹에서는 three_js가 HtmlElementView(DOM 플랫폼뷰)로 렌더된다. 플랫폼뷰를
    // AnimatedOpacity/Opacity로 감싸면 CanvasKit 합성에서 사라지거나 위치가 깨진다
    // → 투명도 래퍼 없이 그대로 붙인다. (앱은 Texture라 무관하지만 공통으로 둔다.)
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: IgnorePointer(child: _threeJs!.build()),
    );
  }
}

// ─────────────────────────────────────────────
// 웹 전용 2.5D (CustomPainter) — WebGL 없이 확실히 렌더/재생된다.
// 경위도→정규화 + 실제거리 고도스케일(PaceFace 동일) + Y축 회전 + 아이소메트릭 투영.
// 고도 그라데이션 리본 + 경사 커튼 + 발광 마커(아크길이 균일 이동으로 부드럽게).
// ─────────────────────────────────────────────

class RideRoute25DView extends StatefulWidget {
  final RideSamples samples;
  final RideSlope? slope;
  final double height;
  final bool follow; // 카메라 추적(플라이다운) 모드
  final double? score; // 최종 점수(있으면 내려가며 실시간 누적 표시)
  final double? distance; // 총 거리(m)
  const RideRoute25DView(
      {super.key,
      required this.samples,
      this.slope,
      this.height = 470,
      this.follow = false,
      this.score,
      this.distance});

  @override
  State<RideRoute25DView> createState() => _RideRoute25DViewState();
}

class _P25 {
  final double x, y, z, t; // t = 고도 정규화(0~1)
  const _P25(this.x, this.y, this.z, this.t);
}

class _RideRoute25DViewState extends State<RideRoute25DView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  List<_P25> _pts = const []; // 라이딩 궤적(아크길이 균일 리샘플)
  List<_P25> _ring = const []; // 슬로프 면(외곽 폴리곤, 진행축으로 기울임)
  double _maxR = 1, _maxY = 0;
  double _aux = 1, _auz = 0; // 진행축 단위벡터(플라이다운 카메라가 쓴다)
  List<double> _spd = const []; // _pts와 1:1 정렬된 지점별 속도(km/h)
  double _maxSpd = 1; // 계기판 최대 눈금
  // 뷰 조작 상태: 줌(2D 스케일)·팬(px)·3D 회전(라디안).
  double _vScale = 1.0;
  Offset _vPan = Offset.zero;
  double _manualRot = 0.0; // 사용자 수동 3D 회전
  bool _userRotated = false; // 상호작용 시작하면 자동회전 정지
  // 제스처 시작 스냅샷
  double _s0 = 1.0, _r0 = 0.0;
  Offset _p0 = Offset.zero, _f0 = Offset.zero;
  // 두 손가락 제스처 모드: 0=미정, 1=회전전용, 2=줌전용(회전·줌 동시 금지).
  int _twoMode = 0;

  bool _showScore = true; // 실시간 누적 점수 표시
  bool _showDist = true; // 실시간 누적 거리 표시

  // 재생 속도 배율. 1배속 = 실제 라이딩 경과시간. 컨트롤러 duration = 실제시간 / 배율.
  double _speed = 4.0; // 기본 4배(실측 주행은 수 분이라 너무 느리지 않게). 1x=실제시간.
  static const List<double> _speedOptions = [1.0, 2.0, 4.0, 8.0, 16.0];
  // 1배속 기준시간 = 실제 라이딩 경과시간(샘플 t, ms). (최소 3초, 최대 15분)
  int get _baseMs {
    final t = widget.samples.t;
    if (t.length >= 2) {
      final ms = (t.last - t.first).round();
      if (ms > 500) return ms.clamp(3000, 900000);
    }
    return (widget.follow ? 9 : 42) * 1000;
  }

  @override
  void initState() {
    super.initState();
    _build();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_baseMs / _speed).round()),
    )..repeat();
  }

  void _setSpeed(double sp) {
    if (sp == _speed) return;
    setState(() => _speed = sp);
    // 현재 진행 위치를 유지한 채 속도만 바꾼다.
    _ctrl.duration = Duration(milliseconds: (_baseMs / sp).round());
    _ctrl.repeat(min: 0.0, max: 1.0);
  }

  Size _vpSize() {
    final box = context.findRenderObject();
    return box is RenderBox ? box.size : const Size(300, 300);
  }

  // 중앙 정렬 스케일 기준 팬 범위 클램프(빈칸 방지).
  Offset _clampPan(Offset p) {
    final sz = _vpSize();
    final mx = (_vScale - 1) * sz.width / 2, my = (_vScale - 1) * sz.height / 2;
    return Offset(p.dx.clamp(-mx, mx), p.dy.clamp(-my, my));
  }

  /// alt + 휠일 때만 포인터 위치 기준으로 줌. alt 없는 휠은 다이얼로그 스크롤로 통과.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!HardwareKeyboard.instance.isAltPressed) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (e) {
      final s = e as PointerScrollEvent;
      _applyZoom(s.scrollDelta.dy < 0 ? 1.15 : (1 / 1.15), s.localPosition);
    });
  }

  void _applyZoom(double factor, Offset focal) {
    final sz = _vpSize();
    final center = Offset(sz.width / 2, sz.height / 2);
    final old = _vScale;
    final ns = (old * factor).clamp(1.0, 8.0);
    if ((ns - old).abs() < 1e-3) return;
    final k = ns / old;
    final pan = (focal - center) * (1 - k) + _vPan * k;
    setState(() {
      _vScale = ns;
      _vPan = _clampPan(pan);
    });
  }

  void _onScaleStart(ScaleStartDetails d) {
    // 처음 상호작용하면 자동회전을 현재 각도에서 '멈춘다'(점프 없이).
    if (!_userRotated) _manualRot = (_ctrl.value - 0.5) * (math.pi / 2);
    _userRotated = true;
    _s0 = _vScale;
    _p0 = _vPan;
    _r0 = _manualRot;
    _f0 = d.focalPoint;
    _twoMode = 0; // 이번 제스처 모드 미정으로 초기화
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final altDrag = kIsWeb &&
        d.pointerCount <= 1 &&
        HardwareKeyboard.instance.isAltPressed;
    setState(() {
      if (d.pointerCount >= 2) {
        // 두 손가락: 회전과 줌 중 "먼저 임계를 넘은 쪽" 하나만 적용(동시 금지).
        if (_twoMode == 0) {
          final rotR = d.rotation.abs() / 0.12; // 약 7°
          final zoomR = (d.scale - 1).abs() / 0.08; // 약 8%
          if (rotR > 1 || zoomR > 1) _twoMode = rotR >= zoomR ? 1 : 2;
        }
        if (_twoMode == 1) {
          // 회전 전용: 손가락 비트는 방향과 같게(화면 기준). 줌은 건드리지 않음.
          _manualRot = _r0 - d.rotation;
        } else if (_twoMode == 2) {
          // 줌 전용: 회전은 건드리지 않음.
          _vScale = (_s0 * d.scale).clamp(1.0, 8.0);
        }
        // 팬(이동)은 두 모드 모두에서 허용.
        _vPan = _clampPan(_p0 + (d.focalPoint - _f0));
      } else if (altDrag) {
        // 웹 alt+드래그: 가로 이동량으로 3D 회전.
        _manualRot = _r0 + (d.focalPoint - _f0).dx * 0.01;
      } else {
        // 한 손가락/드래그: 팬(이동).
        _vPan = _clampPan(_p0 + (d.focalPoint - _f0));
      }
    });
  }

  void _resetView() {
    setState(() {
      _vScale = 1.0;
      _vPan = Offset.zero;
      _manualRot = 0.0;
      _userRotated = false;
    });
  }

  /// 도움말 버튼 — 탭하면 조작법 말풍선.
  Widget _helpButton() => Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        preferBelow: true,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xF20B1220),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBlue.withValues(alpha: 0.5)),
        ),
        textStyle: const TextStyle(
            color: Colors.white, fontSize: 12, height: 1.5),
        message: 'alt+휠 = 줌인아웃\nalt+드래그 = 회전 (앱: 두 손가락 비틀기)\n더블클릭 = 원위치',
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xCC0B1220),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: const Icon(Icons.info_outline,
              size: 15, color: Colors.white),
        ),
      );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _build() {
    final s = widget.samples;
    final n = s.length;
    if (n < 2) return;
    final ring = (widget.slope?.hasPolygon ?? false) ? widget.slope!.area : const <List<double>>[];
    final axis = (widget.slope?.hasPolygon ?? false) ? widget.slope!.axis : const <List<double>>[];

    // 궤적 + 슬로프 외곽을 모두 담는 공통 경위도 bbox(같은 좌표계로 정규화해야 겹쳐 그린다).
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;
    double minAlt = double.infinity, maxAlt = -double.infinity;
    void acc(double lng, double lat) {
      minLat = math.min(minLat, lat); maxLat = math.max(maxLat, lat);
      minLng = math.min(minLng, lng); maxLng = math.max(maxLng, lng);
    }
    for (int i = 0; i < n; i++) {
      acc(s.lng[i], s.lat[i]);
      final a = (i < s.alt.length) ? s.alt[i] : null;
      if (a != null && a.isFinite) { minAlt = math.min(minAlt, a); maxAlt = math.max(maxAlt, a); }
    }
    for (final p in ring) acc(p[0], p[1]);
    if (minAlt == double.infinity) { minAlt = 0; maxAlt = 0; }
    final latR = maxLat - minLat, lngR = maxLng - minLng, altR = maxAlt - minAlt;
    final midLat = (minLat + maxLat) / 2;
    final midLng = (minLng + maxLng) / 2;
    final cosLat = math.cos(midLat * math.pi / 180);
    final latM = latR * 111320, lngM = lngR * 111320 * cosLat;
    final ext = math.max(latM, lngM);
    final yMult = (altR <= 0 || ext <= 0) ? 0.0 : (altR / ext * 2 * 3.0).clamp(0.08, 0.8);

    // ⚠️ 경도/위도를 각각 꽉 채워 정규화하면 가로세로가 뭉개져 폴리곤 모양·면적이
    // 틀어진다. 경도에 cos(위도) 보정을 주고 **x·z를 같은(공통) 스케일**로 정규화해
    // 실제 비율을 보존한다(2D 궤적 이미지와 동일한 기하 → 등록된 경계·면적 그대로).
    final halfX = (lngR / 2) * cosLat;
    final halfZ = latR / 2;
    final half = math.max(halfX, halfZ);
    final norm = half <= 0 ? 1.0 : 1.0 / half;
    double nx(double lng) => (lng - midLng) * cosLat * norm;
    double nz(double lat) => (lat - midLat) * norm;

    // ── 라이딩 궤적: 정규화 → 3D 아크길이 균일 리샘플 (게인 적용 전 좌표) ──
    final raw = <List<double>>[];
    for (int i = 0; i < n; i++) {
      final a = (i < s.alt.length) ? s.alt[i] : null;
      final y = (altR > 0 && a != null && a.isFinite) ? ((a - minAlt) / altR) * yMult : 0.0;
      raw.add([nx(s.lng[i]), y, nz(s.lat[i])]);
    }
    final cum = <double>[0];
    for (int i = 1; i < raw.length; i++) {
      final dx = raw[i][0]-raw[i-1][0], dy = raw[i][1]-raw[i-1][1], dz = raw[i][2]-raw[i-1][2];
      cum.add(cum[i-1] + math.sqrt(dx*dx+dy*dy+dz*dz));
    }
    // 지점별 속도(km/h) — 원본 샘플에서 가져와 리샘플 때 함께 보간한다(계기판용).
    final rawSpd = <double>[
      for (int i = 0; i < n; i++)
        (i < s.spd.length && s.spd[i].isFinite) ? s.spd[i] : 0.0
    ];
    final total = cum.last;
    // 희소한(1초) 샘플을 직선보간하면 S자가 각진다 → Catmull-Rom 스플라인으로
    // 부드럽게, 출력도 촘촘히(500점).
    final rawN = raw.length;
    double crc(double p0, double p1, double p2, double p3, double t) {
      final t2 = t * t, t3 = t2 * t;
      return 0.5 *
          ((2 * p1) +
              (-p0 + p2) * t +
              (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
              (-p0 + 3 * p1 - 3 * p2 + p3) * t3);
    }
    double crAt(int idx, int comp, double t) {
      final i0 = (idx - 1).clamp(0, rawN - 1);
      final i1 = idx.clamp(0, rawN - 1);
      final i2 = (idx + 1).clamp(0, rawN - 1);
      final i3 = (idx + 2).clamp(0, rawN - 1);
      return crc(raw[i0][comp], raw[i1][comp], raw[i2][comp], raw[i3][comp], t);
    }
    const outN = 500;
    final out = <_P25>[];
    final outSpd = <double>[];
    int seg = 0;
    for (int k = 0; k < outN; k++) {
      final d = total * k / (outN - 1);
      while (seg < raw.length - 2 && cum[seg + 1] < d) seg++;
      final segLen = (cum[seg + 1] - cum[seg]);
      final f = segLen <= 0 ? 0.0 : ((d - cum[seg]) / segLen).clamp(0.0, 1.0);
      final x = crAt(seg, 0, f);
      final y = crAt(seg, 1, f);
      final z = crAt(seg, 2, f);
      final t = yMult <= 0 ? 0.5 : (y / yMult).clamp(0.0, 1.0);
      out.add(_P25(x, y, z, t));
      outSpd.add(rawSpd[seg] + (rawSpd[seg + 1] - rawSpd[seg]) * f);
    }
    _spd = outSpd;
    // 계기판 눈금 범위는 0~120 고정.
    _maxSpd = 120.0;

    // ── 슬로프 면: 외곽 폴리곤을 진행축 기준으로 기울인다(입구=높음, 출구=낮음) ──
    double ex = 0, ez = 0, avx = 1, avz = 0, len2 = 1;
    if (axis.length >= 2) {
      ex = nx(axis.first[0]); ez = nz(axis.first[1]);
      final xx = nx(axis.last[0]), xz = nz(axis.last[1]);
      avx = xx - ex; avz = xz - ez;
      len2 = (avx * avx + avz * avz);
      if (len2 <= 0) len2 = 1;
    }
    final rp = <_P25>[];
    if (ring.length >= 3) {
      for (final p in ring) {
        final x = nx(p[0]), z = nz(p[1]);
        final u = axis.length >= 2
            ? (((x - ex) * avx + (z - ez) * avz) / len2).clamp(0.0, 1.0)
            : 0.0;
        rp.add(_P25(x, (1 - u) * yMult, z, 0)); // 입구(u=0) 높음 → 출구(u=1) 낮음
      }
    }

    // ── 궤적을 '슬로프 면 위'에 올린다 ──
    // 슬로프 면은 진행축 기준 선형 기울기로 y를 주는데, 궤적은 실제 고도로 y를 줘서
    // 2.5D 투영상 리본이 면보다 떠(경계 밖처럼) 보인다. 각 궤적점의 진행축 투영 u로
    // 면의 y=(1-u)*yMult를 구해 궤적 y를 '면 위'로 맞춘다. 고도는 리본 색(t)으로 유지.
    if (axis.length >= 2 && yMult > 0) {
      for (int i = 0; i < out.length; i++) {
        final p = out[i];
        final u = (((p.x - ex) * avx + (p.z - ez) * avz) / len2).clamp(0.0, 1.0);
        out[i] = _P25(p.x, (1 - u) * yMult, p.z, p.t);
      }
    }

    // ── 가로폭(cross) 게인: 좁고 긴 슬로프의 **가로너비를 화면에서 일정 비율 이상**으로
    //    키운다(레인보우파라다이스처럼 폭이 좁아 궤적·면이 다 겹치는 문제 해결). 진행축
    //    (aux,auz) 기준으로 along은 그대로 두고 cross만 확대 → 궤적 진폭도 같이 커져
    //    슬로프 폭 안에 유지되고, **모델 좌표에 반영**돼 회전해도 왜곡이 없다.
    double aux = 1, auz = 0;
    if (axis.length >= 2 && len2 > 1e-9) {
      final l = math.sqrt(len2); aux = avx / l; auz = avz / l;
    } else if (out.length >= 2) {
      final dx = out.last.x - out.first.x, dz = out.last.z - out.first.z;
      final l = math.sqrt(dx * dx + dz * dz);
      if (l > 1e-9) { aux = dx / l; auz = dz / l; }
    }
    double cMax = 1e-9, aMax = 1e-9;
    void measure(double x, double z) {
      final al = (x * aux + z * auz).abs();
      final cr = (-x * auz + z * aux).abs();
      if (al > aMax) aMax = al;
      if (cr > cMax) cMax = cr;
    }
    for (final p in out) measure(p.x, p.z);
    for (final p in rp) measure(p.x, p.z);
    // 가로폭 반경이 세로(진행) 반경의 최소 0.6배가 되도록(좁으면 확대, 넓으면 그대로, 최대 8배).
    final gain = (0.6 * aMax / cMax).clamp(1.0, 8.0);

    _aux = aux;
    _auz = auz;

    _P25 widen(_P25 p) {
      final al = p.x * aux + p.z * auz;
      final cr = (-p.x * auz + p.z * aux) * gain;
      return _P25(al * aux - cr * auz, p.y, al * auz + cr * aux, p.t);
    }

    double maxR = 0, maxY = 0;
    _pts = [for (final p in out) widen(p)];
    _ring = [for (final p in rp) widen(p)];
    for (final p in _pts) {
      maxR = math.max(maxR, math.sqrt(p.x * p.x + p.z * p.z));
      maxY = math.max(maxY, p.y);
    }
    for (final p in _ring) {
      maxR = math.max(maxR, math.sqrt(p.x * p.x + p.z * p.z));
    }

    _maxR = maxR <= 0 ? 1 : maxR;
    _maxY = maxY;
  }

  @override
  Widget build(BuildContext context) {
    if (_pts.length < 2) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: widget.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1220), Color(0xFF162133)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              // 줌: alt+휠(웹) / 두 손가락 핀치(앱). 회전: alt+드래그(웹) / 두 손가락 비틀기(앱).
              // 팬: 한 손가락·클릭 드래그. 더블탭: 원위치. alt 없는 휠은 다이얼로그 스크롤로 통과.
              child: Listener(
                onPointerSignal: _onPointerSignal,
                child: GestureDetector(
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onDoubleTap: _resetView,
                  child: ClipRect(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translate(_vPan.dx, _vPan.dy)
                        ..scale(_vScale),
                      child: AnimatedBuilder(
                        animation: _ctrl,
                        builder: (_, __) => CustomPaint(
                          size: Size.infinite,
                          painter: widget.follow
                              ? _RideFollowPainter(
                                  pts: _pts,
                                  ring: _ring,
                                  aux: _aux,
                                  auz: _auz,
                                  progress: _ctrl.value,
                                  maxY: _maxY,
                                )
                              : _Ride25DPainter(
                                  pts: _pts,
                                  ring: _ring,
                                  // 자동 90° 스윕(상호작용 전) 또는 수동 회전(상호작용 후).
                                  rotation: math.atan2(-_aux, _auz) +
                                      (_userRotated
                                          ? _manualRot
                                          : (_ctrl.value - 0.5) *
                                              (math.pi / 2)),
                                  markerProgress: _ctrl.value,
                                  maxR: _maxR,
                                  maxY: _maxY,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ── 고정 HUD(줌/팬에 안 따라감): 속도계 + 실시간 누적점수/거리 ──
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => CustomPaint(
                    size: Size.infinite,
                    painter: _HudPainter(
                      spd: _spd,
                      maxSpd: _maxSpd,
                      progress: _ctrl.value,
                      finalScore: widget.score ?? 0,
                      finalDistance: widget.distance ?? 0,
                      showScore: _showScore,
                      showDist: _showDist,
                    ),
                  ),
                ),
              ),
            ),
            // 재생 속도 조절 + 도움말(i) (좌상단).
            Positioned(
              top: 8,
              left: 8,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _speedControl(),
                const SizedBox(width: 6),
                _helpButton(),
              ]),
            ),
            // 슬로프명(우상단).
            if ((widget.slope?.fullname ?? '').isNotEmpty)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0B1220),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: _kBlue.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    widget.slope!.fullname!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            // 실시간 누적 점수/거리 표시 토글(좌하단).
            Positioned(
              bottom: 8,
              left: 8,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _toggle('점수', _showScore,
                    (v) => setState(() => _showScore = v)),
                const SizedBox(width: 6),
                _toggle('거리', _showDist,
                    (v) => setState(() => _showDist = v)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggle(String label, bool on, ValueChanged<bool> onChanged) =>
      GestureDetector(
        onTap: () => onChanged(!on),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xCC0B1220),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(on ? Icons.check_box : Icons.check_box_outline_blank,
                size: 15, color: on ? _kBlue : Colors.white54),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  Widget _speedControl() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xCC0B1220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final sp in _speedOptions)
            GestureDetector(
              onTap: () => _setSpeed(sp),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _speed == sp ? _kBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  sp == sp.roundToDouble()
                      ? '${sp.toInt()}x'
                      : '${sp.toStringAsFixed(1)}x',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _speed == sp
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Ride25DPainter extends CustomPainter {
  final List<_P25> pts;
  final List<_P25> ring; // 슬로프 면(외곽 폴리곤)
  final double rotation, markerProgress, maxR, maxY;
  _Ride25DPainter({
    required this.pts,
    required this.ring,
    required this.rotation,
    required this.markerProgress,
    required this.maxR,
    required this.maxY,
  });

  static const double _depthK = 0.55;
  static const double _yScale = 1.15;
  static const Color _accent = _kBlue;

  // 고도 그라데이션: 0=흰색 → 1=accent
  Color _elev(double t) => Color.lerp(Colors.white, _accent, t.clamp(0.0, 1.0))!;

  @override
  void paint(Canvas canvas, Size size) {
    final n = pts.length;
    final cos = math.cos(rotation), sin = math.sin(rotation);
    const pad = 8.0;
    // 전체 스케일을 키워 박스를 꽉 채운다. 가로로 넓은 박스에서 360° 회전 원을
    // 높이 기준으로만 맞추면 좌우 여백이 많이 남으므로 kFill로 확대한다(얇은 리본이라
    // 회전 극단에서 끝부분이 약간 잘려도 체감이 적다).
    const double kFill = 1.4;
    final halfW = maxR;
    final halfH = maxR * _depthK + maxY * _yScale;
    final s = kFill *
        math.min((size.width / 2 - pad) / (halfW <= 0 ? 1 : halfW),
            (size.height / 2 - pad) / (halfH <= 0 ? 1 : halfH));
    final cx = size.width / 2;
    final cy = size.height / 2 + maxY * _yScale * s * 0.5;

    Offset proj(double x, double y, double z) {
      final rx = x * cos + z * sin;
      final rz = -x * sin + z * cos;
      return Offset(cx + rx * s, cy + (rz * _depthK - y * _yScale) * s);
    }

    final top = List<Offset>.generate(n, (i) => proj(pts[i].x, pts[i].y, pts[i].z));

    // 1) 슬로프 면 — 외곽 폴리곤(진행축으로 기울임)을 반투명 면 + 경계선으로 그린다.
    if (ring.length >= 3) {
      final rp = List<Offset>.generate(ring.length, (i) => proj(ring[i].x, ring[i].y, ring[i].z));
      // 1-a) 눈 커튼 — 슬로프 경계(폴리곤 라인) 아래로 바닥까지 떨어지는 흰색 그라데이션
      //      벽(눈 슬로프 느낌). 면/궤적보다 먼저 그려 뒤에 깔리게 한다.
      final rfloor = List<Offset>.generate(
          ring.length, (i) => proj(ring[i].x, 0, ring[i].z));
      // 스무딩된 폴리곤 라인에 맞춰 커튼 윗변도 매끄럽게: top·floor를 같은 방식으로
      // 리샘플해 대응 인덱스끼리 벽을 세운다(각진 커튼 방지).
      final sTop = _smoothClosedPoints(rp);
      final sFloor = _smoothClosedPoints(rfloor);
      final m = sTop.length;
      for (int i = 1; i <= m; i++) {
        final a = i - 1, b = i % m;
        final path = Path()
          ..moveTo(sTop[a].dx, sTop[a].dy)
          ..lineTo(sTop[b].dx, sTop[b].dy)
          ..lineTo(sFloor[b].dx, sFloor[b].dy)
          ..lineTo(sFloor[a].dx, sFloor[a].dy)
          ..close();
        canvas.drawPath(
            path,
            Paint()
              ..shader = ui.Gradient.linear(sTop[b], sFloor[b], [
                Colors.white.withValues(alpha: 0.20),
                Colors.white.withValues(alpha: 0.0),
              ]));
      }
      final surf = _smoothClosedPath(rp); // 각진 경계를 부드럽게
      // 면: 은은한 청백색 채움(눈 슬로프 느낌).
      canvas.drawPath(surf, Paint()..color = const Color(0xFF9DB8FF).withValues(alpha: 0.10));
      // 경계: 또렷한 외곽선.
      canvas.drawPath(surf, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFBFD0FF).withValues(alpha: 0.55));
    }

    // 2) 궤적 — 라이딩 진행(markerProgress)에 따라 "현재 지점까지만" 그린다.
    //    (미리 전체 경로를 그려두지 않고, 타는 만큼 그려지도록 점열을 현재 위치에서 끊는다.)
    final mi = (markerProgress * (n - 1)).clamp(0, n - 1).toDouble();
    final i0 = mi.floor(), i1 = math.min(i0 + 1, n - 1);
    final f = mi - i0;
    final mPos = Offset.lerp(top[i0], top[i1], f)!;
    final floor = List<Offset>.generate(n, (i) => proj(pts[i].x, 0, pts[i].z));
    final mFloor = Offset.lerp(floor[i0], floor[i1], f)!;
    // 현재 지점까지의 점열(마지막 원소는 보간된 마커 위치).
    final dTop = <Offset>[...top.sublist(0, i0 + 1), mPos];
    final dFloor = <Offset>[...floor.sublist(0, i0 + 1), mFloor];
    final dn = dTop.length;
    final dElev = <double>[
      for (int i = 0; i <= i0; i++) pts[i].t,
      pts[i0].t + (pts[i1].t - pts[i0].t) * f,
    ];

    // 2-a) 커튼월(PaceFace) — 궤적 리본에서 바닥(y=0)까지 떨어지는 반투명 그라데이션 벽.
    //      위=accent 진함(0.26) → 아래=투명(0)으로 고도 프로파일을 보여준다.
    const cs = 4;
    for (int i = cs; i < dn + cs - 1; i += cs) {
      final a = i - cs, b = math.min(i, dn - 1);
      if (a >= b) break;
      final path = Path()
        ..moveTo(dTop[a].dx, dTop[a].dy)
        ..lineTo(dTop[b].dx, dTop[b].dy)
        ..lineTo(dFloor[b].dx, dFloor[b].dy)
        ..lineTo(dFloor[a].dx, dFloor[a].dy)
        ..close();
      final shader = ui.Gradient.linear(
        dTop[b], dFloor[b],
        [_accent.withValues(alpha: 0.26), _accent.withValues(alpha: 0.0)],
      );
      canvas.drawPath(path, Paint()..shader = shader);
    }

    // 2-b) 리본 — 글로우(블러) + 본선(고도 그라데이션)
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..color = _accent.withValues(alpha: 0.18);
    final glowPath = Path()..moveTo(dTop.first.dx, dTop.first.dy);
    for (int i = 1; i < dn; i++) glowPath.lineTo(dTop[i].dx, dTop[i].dy);
    canvas.drawPath(glowPath, glow);

    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    for (int i = 1; i < dn; i++) {
      core.color = _elev((dElev[i - 1] + dElev[i]) / 2);
      canvas.drawLine(dTop[i - 1], dTop[i], core);
    }

    // 3) 마커 — 현재 지점. 글로우 펄스 + 바닥 수직선.
    canvas.drawLine(mPos, mFloor, Paint()
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.18));
    final pulse = 0.5 + 0.5 * math.sin(markerProgress * 2 * math.pi * 3);
    canvas.drawCircle(mPos, 12 + pulse * 3, Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawCircle(mPos, 5.5, Paint()..color = Colors.white);
    // 속도계·점수는 고정 HUD(_HudPainter)에서 따로 그린다(줌/팬 영향 없음).
  }

  @override
  bool shouldRepaint(covariant _Ride25DPainter old) =>
      old.rotation != rotation || old.markerProgress != markerProgress || old.pts != pts;
}

// ─────────────────────────────────────────────
// 플라이다운(카메라 추적) — 진행축을 세로로 세우고, 현재 위치를 확대해 따라 내려간다.
// 긴 슬로프를 전체 압축 없이 점진적으로 보여준다(마커를 화면에 고정, 월드가 스크롤).
// ─────────────────────────────────────────────
class _RideFollowPainter extends CustomPainter {
  final List<_P25> pts;
  final List<_P25> ring;
  final double aux, auz, progress, maxY;
  _RideFollowPainter({
    required this.pts,
    required this.ring,
    required this.aux,
    required this.auz,
    required this.progress,
    required this.maxY,
  });

  static const Color _accent = _kBlue;
  static const double _dK = 1.0; // along → 세로(깊이)
  static const double _yS = 0.5; // 고도 들어올림
  static const double _ob = 0.22; // 3/4 사선 기울기

  Color _elev(double t) => Color.lerp(Colors.white, _accent, t.clamp(0.0, 1.0))!;

  @override
  void paint(Canvas canvas, Size size) {
    final n = pts.length;
    if (n < 2) return;
    double along(_P25 p) => p.x * aux + p.z * auz;
    double cross(_P25 p) => -p.x * auz + p.z * aux;

    double aMin = double.infinity, aMax = -double.infinity;
    double ringCHalf = 0, trajCHalf = 1e-6;
    for (final p in pts) {
      final a = along(p);
      if (a < aMin) aMin = a;
      if (a > aMax) aMax = a;
      final c = cross(p).abs();
      if (c > trajCHalf) trajCHalf = c;
    }
    for (final p in ring) {
      final c = cross(p).abs();
      if (c > ringCHalf) ringCHalf = c;
    }
    final aMid = (aMin + aMax) / 2;
    // 플라이다운 확대: 슬로프 전체 폭(2*ringCHalf)이 카드 가로의 kZoom배를 차지하도록
    // 전체 스케일을 키운다. s는 along·cross·y에 모두 곱해져 전체가 같은 배율로 확대된다.
    // (카메라가 마커를 따라가므로 넘치는 길이는 스크롤되며 지나간다. 숫자만 바꿔 조절.)
    const double kZoom = 0.85; // 카드 폭 대비 슬로프 폭 비율(1/3=0.33 → 0.85로 확대)
    final baseC = ringCHalf > 1e-6 ? ringCHalf : trajCHalf;
    final s = (size.width * kZoom) / (2 * baseC);

    Offset proj(_P25 p) {
      final a = along(p) - aMid;
      final c = cross(p);
      return Offset(c * s + a * s * _ob, a * s * _dK - p.y * s * _yS);
    }

    // 마커(진행 progress) — 화면 고정 앵커로 두고 월드를 스크롤한다.
    final mi = (progress * (n - 1)).clamp(0, n - 1).toDouble();
    final i0 = mi.floor(), i1 = math.min(i0 + 1, n - 1);
    final f = mi - i0;
    final mp = _P25(
      pts[i0].x + (pts[i1].x - pts[i0].x) * f,
      pts[i0].y + (pts[i1].y - pts[i0].y) * f,
      pts[i0].z + (pts[i1].z - pts[i0].z) * f,
      0,
    );
    final mWorld = proj(mp);
    canvas.save();
    canvas.translate(
        size.width * 0.5 - mWorld.dx, size.height * 0.56 - mWorld.dy);

    final top = List<Offset>.generate(n, (i) => proj(pts[i]));
    final floor =
        List<Offset>.generate(n, (i) => proj(_P25(pts[i].x, 0, pts[i].z, 0)));

    // 슬로프 면
    if (ring.length >= 3) {
      final rp = List<Offset>.generate(ring.length, (i) => proj(ring[i]));
      // 눈 커튼 — 슬로프 경계(폴리곤 라인) 아래로 바닥까지 떨어지는 흰색 그라데이션.
      final rfloor = List<Offset>.generate(
          ring.length, (i) => proj(_P25(ring[i].x, 0, ring[i].z, 0)));
      // 스무딩된 폴리곤 라인에 맞춰 커튼 윗변도 매끄럽게 리샘플.
      final sTop = _smoothClosedPoints(rp);
      final sFloor = _smoothClosedPoints(rfloor);
      final m = sTop.length;
      for (int i = 1; i <= m; i++) {
        final a = i - 1, b = i % m;
        final path = Path()
          ..moveTo(sTop[a].dx, sTop[a].dy)
          ..lineTo(sTop[b].dx, sTop[b].dy)
          ..lineTo(sFloor[b].dx, sFloor[b].dy)
          ..lineTo(sFloor[a].dx, sFloor[a].dy)
          ..close();
        canvas.drawPath(
            path,
            Paint()
              ..shader = ui.Gradient.linear(sTop[b], sFloor[b], [
                Colors.white.withValues(alpha: 0.20),
                Colors.white.withValues(alpha: 0.0),
              ]));
      }
      final surf = _smoothClosedPath(rp); // 각진 경계를 부드럽게
      canvas.drawPath(surf,
          Paint()..color = const Color(0xFF9DB8FF).withValues(alpha: 0.10));
      canvas.drawPath(
          surf,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..strokeJoin = StrokeJoin.round
            ..color = const Color(0xFFBFD0FF).withValues(alpha: 0.55));
    }
    // 궤적 — 라이딩 진행(progress)에 따라 "현재 지점까지만" 그린다(미리 그려두지 않음).
    final mFloor = proj(_P25(mp.x, 0, mp.z, 0));
    final dTop = <Offset>[...top.sublist(0, i0 + 1), mWorld];
    final dFloor = <Offset>[...floor.sublist(0, i0 + 1), mFloor];
    final dn = dTop.length;
    final dElev = <double>[
      for (int i = 0; i <= i0; i++) pts[i].t,
      pts[i0].t + (pts[i1].t - pts[i0].t) * f,
    ];
    // 커튼월 — 성능 위해 세그먼트를 묶어 그라데이션 쿼드 수를 줄인다.
    const cs = 4;
    for (int i = cs; i < dn + cs - 1; i += cs) {
      final a = i - cs, b = math.min(i, dn - 1);
      if (a >= b) break;
      final path = Path()
        ..moveTo(dTop[a].dx, dTop[a].dy)
        ..lineTo(dTop[b].dx, dTop[b].dy)
        ..lineTo(dFloor[b].dx, dFloor[b].dy)
        ..lineTo(dFloor[a].dx, dFloor[a].dy)
        ..close();
      canvas.drawPath(
          path,
          Paint()
            ..shader = ui.Gradient.linear(dTop[b], dFloor[b], [
              _accent.withValues(alpha: 0.26),
              _accent.withValues(alpha: 0.0),
            ]));
    }
    // 리본
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)
      ..color = _accent.withValues(alpha: 0.18);
    final gp = Path()..moveTo(dTop.first.dx, dTop.first.dy);
    for (int i = 1; i < dn; i++) gp.lineTo(dTop[i].dx, dTop[i].dy);
    canvas.drawPath(gp, glow);
    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    for (int i = 1; i < dn; i++) {
      core.color = _elev((dElev[i - 1] + dElev[i]) / 2);
      canvas.drawLine(dTop[i - 1], dTop[i], core);
    }
    // 마커(앵커 위치)
    final pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi * 6);
    canvas.drawCircle(
        mWorld,
        14 + pulse * 3,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(mWorld, 6, Paint()..color = Colors.white);
    canvas.restore();
    // 속도계·점수는 고정 HUD(_HudPainter)에서 따로 그린다.
  }

  @override
  bool shouldRepaint(covariant _RideFollowPainter old) =>
      old.progress != progress || old.pts != pts;
}

/// 줌/팬에 영향받지 않는 고정 HUD — 속도계(최고속도 빨간선 포함) + 실시간
/// 누적점수/거리를 우하단에 그린다.
class _HudPainter extends CustomPainter {
  final List<double> spd; // _pts와 1:1 지점별 속도(km/h)
  final double maxSpd; // 계기판 최대 눈금
  final double progress; // 0~1
  final double finalScore;
  final double finalDistance; // m
  final bool showScore;
  final bool showDist;
  _HudPainter({
    required this.spd,
    required this.maxSpd,
    required this.progress,
    required this.finalScore,
    required this.finalDistance,
    required this.showScore,
    required this.showDist,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (spd.isEmpty) return;
    final n = spd.length;
    final mi = (progress * (n - 1)).clamp(0, n - 1).toDouble();
    final i0 = mi.floor(), i1 = math.min(i0 + 1, n - 1);
    final f = mi - i0;
    final curSpd = spd[i0] + (spd[i1] - spd[i0]) * f;
    double peak = 0;
    for (final v in spd) if (v > peak) peak = v;
    _drawSpeedometer(canvas, size, curSpd, maxSpd, finalScore * progress,
        finalScore, finalDistance * progress, peak, showScore, showDist);
  }

  @override
  bool shouldRepaint(covariant _HudPainter old) =>
      old.progress != progress ||
      old.spd != spd ||
      old.showScore != showScore ||
      old.showDist != showDist;
}

/// 폴리곤 경계를 '부드럽게' 그린다 — 각 변의 중점을 잇고 꼭짓점을 제어점으로 하는
/// 2차 베지어(코너 라운딩). Catmull-Rom과 달리 **오버슈트/자기교차가 없어** 곡선이
/// 꼬이지 않는다. 점이 3개 미만이면 직선 폴백.
Path _smoothClosedPath(List<Offset> p) {
  final n = p.length;
  final path = Path();
  if (n == 0) return path;
  if (n < 3) {
    path.moveTo(p.first.dx, p.first.dy);
    for (int i = 1; i < n; i++) path.lineTo(p[i].dx, p[i].dy);
    return path;
  }
  Offset mid(Offset a, Offset b) =>
      Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
  final start = mid(p[n - 1], p[0]);
  path.moveTo(start.dx, start.dy);
  for (int i = 0; i < n; i++) {
    final cur = p[i];
    final nxt = p[(i + 1) % n];
    final m = mid(cur, nxt);
    path.quadraticBezierTo(cur.dx, cur.dy, m.dx, m.dy);
  }
  path.close();
  return path;
}

/// `_smoothClosedPath`와 똑같은 중점-2차베지어 닫힌곡선을 "점열"로 리샘플한다.
/// 커튼(폴리곤 라인 아래 벽)의 윗변/바닥변을 스무딩된 면 경계에 정확히 맞추기 위해 사용.
/// top·floor를 같은 perSeg로 리샘플하면 대응 인덱스끼리 매끄러운 벽을 세울 수 있다.
List<Offset> _smoothClosedPoints(List<Offset> p, {int perSeg = 6}) {
  final n = p.length;
  if (n < 3) return List<Offset>.from(p);
  Offset mid(Offset a, Offset b) =>
      Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
  final out = <Offset>[];
  Offset prevM = mid(p[n - 1], p[0]); // 곡선 시작점(마지막↔첫 변의 중점)
  for (int i = 0; i < n; i++) {
    final c = p[i]; // 제어점(원본 꼭짓점)
    final m = mid(p[i], p[(i + 1) % n]); // 세그먼트 끝점(중점)
    for (int s = 0; s < perSeg; s++) {
      final t = s / perSeg, u = 1 - t;
      out.add(Offset(
        u * u * prevM.dx + 2 * u * t * c.dx + t * t * m.dx,
        u * u * prevM.dy + 2 * u * t * c.dy + t * t * m.dy,
      ));
    }
    prevM = m;
  }
  return out; // 닫힌 루프(out.last → out.first로 자연스럽게 이어짐)
}

/// 자동차 계기판형 속도계를 우하단에 그리고, 그 아래에 실시간 누적점수(현재/획득)를 쓴다.
/// 빠를수록 바늘이 더 돌아가고(0→270°), 색은 블루 테마. (3D·플라이다운 공용)
void _drawSpeedometer(Canvas canvas, Size size, double spd, double maxSpd,
    double curScore, double finalScore,
    [double curDist = 0,
    double peakSpd = 0,
    bool drawScore = true,
    bool drawDist = true]) {
  final r = (math.min(size.width, size.height) * 0.16).clamp(30.0, 48.0);
  final cx = size.width - r - 14;
  // 점수·거리 줄(아래 2줄, 각 ~20px)이 잘리지 않게 계기판을 충분히 위로 올린다.
  final cy = size.height - r - 62;
  final center = Offset(cx, cy);
  final ratio = (spd / (maxSpd <= 0 ? 1 : maxSpd)).clamp(0.0, 1.0);
  const start = 0.75 * math.pi; // 7시 30분 위치
  const sweep = 1.5 * math.pi; // 270°(아래가 열린 계기판)
  // 블루 테마: 느림=연한 하늘색 → 빠름=스노우라이브 블루.
  final fillColor = Color.lerp(const Color(0xFF9FD2FF), _kBlue, ratio)!;

  // 배경 원판
  canvas.drawCircle(center, r + 6, Paint()..color = const Color(0xCC0B1220));
  canvas.drawCircle(
      center,
      r + 6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.12));

  final rect = Rect.fromCircle(center: center, radius: r);
  // 트랙 아크(회색)
  canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.18));
  // 속도 비율만큼 채운 아크
  canvas.drawArc(
      rect,
      start,
      sweep * ratio,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = fillColor);

  // 눈금 11개
  final tickPaint = Paint()
    ..strokeWidth = 1.4
    ..color = Colors.white.withValues(alpha: 0.35);
  for (int i = 0; i <= 10; i++) {
    final a = start + sweep * (i / 10);
    final dir = Offset(math.cos(a), math.sin(a));
    canvas.drawLine(center + dir * (r - 2), center + dir * (r - 7), tickPaint);
  }

  // 최고속도 표시(빨간 선) — 눈금 바깥에 또렷하게.
  if (peakSpd > 0) {
    final pr = (peakSpd / (maxSpd <= 0 ? 1 : maxSpd)).clamp(0.0, 1.0);
    final pa = start + sweep * pr;
    final dir = Offset(math.cos(pa), math.sin(pa));
    canvas.drawLine(
        center + dir * (r - 8),
        center + dir * (r + 3),
        Paint()
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFF4D4D));
  }

  // 바늘
  final na = start + sweep * ratio;
  final needleEnd = center + Offset(math.cos(na), math.sin(na)) * (r - 6);
  canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = fillColor);
  canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);

  // 숫자(km/h)
  final tp = TextPainter(
    text: TextSpan(children: [
      TextSpan(
          text: spd.round().toString(),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1.0)),
      const TextSpan(
          text: ' km/h',
          style: TextStyle(
              color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w600)),
    ]),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  )..layout();
  tp.paint(canvas, Offset(cx - tp.width / 2, cy + r * 0.26));

  // 계기판 아래: 체크된 것만 위에서부터 쌓는다(점수 → 거리).
  double ly = cy + r + 8;

  // 실시간 누적점수 — "현재점수 / 획득점수"(소수 1자리).
  if (drawScore && finalScore > 0) {
    final sp = TextPainter(
      text: TextSpan(children: [
        TextSpan(
            text: curScore.toStringAsFixed(1),
            style: const TextStyle(
                color: _kBlue, fontSize: 13, fontWeight: FontWeight.w900)),
        TextSpan(
            text: ' / ${finalScore.toStringAsFixed(1)}',
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ]),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    final boxW = sp.width + 14;
    final boxRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - boxW / 2, ly, boxW, 20),
        const Radius.circular(10));
    canvas.drawRRect(boxRect, Paint()..color = const Color(0xCC0B1220));
    canvas.drawRRect(
        boxRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = _kBlue.withValues(alpha: 0.5));
    sp.paint(canvas, Offset(cx - sp.width / 2, ly + 4));
    ly += 24;
  }

  // 실시간 누적 거리(1000m 미만 m, 이상 km).
  if (drawDist) {
    final distStr = curDist < 1000
        ? '${curDist.round()}m'
        : '${(curDist / 1000).toStringAsFixed(2)}km';
    final dp = TextPainter(
      text: TextSpan(children: [
        const TextSpan(
            text: '거리 ',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w600)),
        TextSpan(
            text: distStr,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800)),
      ]),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    final dBoxW = dp.width + 14;
    final dRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - dBoxW / 2, ly, dBoxW, 18),
        const Radius.circular(9));
    canvas.drawRRect(dRect, Paint()..color = const Color(0xCC0B1220));
    dp.paint(canvas, Offset(cx - dp.width / 2, ly + 3));
  }
}
