import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'slope_geometry.dart';
import 'polygon_session_machine.dart';

class PolygonTestScreen extends StatefulWidget {
  const PolygonTestScreen({super.key});
  @override
  State<PolygonTestScreen> createState() => _PolygonTestScreenState();
}

class _PolygonTestScreenState extends State<PolygonTestScreen> {
  static const base = 'https://snowlive-api-c617725e2b78.herokuapp.com';
  static const resortId = 13; // 휘닉스파크 (삼송1~4 포함)

  List<SlopePoly> slopes = [];
  PolygonSessionMachine? machine;
  StreamSubscription<Position>? sub;
  GeoPt? cur;
  final List<GeoPt> track = [];
  final List<String> logs = [];
  String status = '로딩...';

  // 지도 변환(확대/이동/회전)
  Matrix4 _matrix = Matrix4.identity();
  Matrix4 _startMatrix = Matrix4.identity();
  Offset _startFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  void _buildMachine() {
    machine = PolygonSessionMachine(slopes)
      ..onLog = (m) => setState(() {
            logs.insert(0, m);
            if (logs.length > 200) logs.removeLast();
          });
  }

  Future<void> _init() async {
    try {
      final r = await http.get(Uri.parse('$base/api/resort/slopes-2627/?resort=$resortId'));
      final data = json.decode(utf8.decode(r.bodyBytes));
      slopes = (data['slopes'] as List)
          .map((j) => SlopePoly.fromJson(j as Map<String, dynamic>))
          .where((s) => s.hasPolygon)
          .toList();
      _buildMachine();
      setState(() => status = '폴리곤 슬로프 ${slopes.length}개 로드됨');
      await _startGps();
    } catch (e) {
      setState(() => status = '로드 실패: $e');
    }
  }

  Future<void> _startGps() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      setState(() => status = '위치 권한 거부됨');
      return;
    }
    // 실제 스노우라이브 앱(vm_resortHome.dart)의 위치 스트림 설정과 동일하게 맞춤
    late LocationSettings settings;
    if (Platform.isIOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else if (Platform.isAndroid) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 1),
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }
    sub = Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
      final p = GeoPt(pos.latitude, pos.longitude);
      cur = p;
      track.add(p);
      if (track.length > 1500) track.removeAt(0);
      machine?.onPoint(p, DateTime.now());
      setState(() {});
    });
  }

  void _reset() {
    setState(() {
      track.clear();
      logs.clear();
      _matrix = Matrix4.identity();
      _buildMachine();
      status = '리셋됨 — 슬로프 ${slopes.length}개';
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = machine;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('폴리곤 판별 테스트'),
        backgroundColor: const Color(0xFF3D83ED),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: '리셋', onPressed: _reset),
        ],
      ),
      body: Column(children: [
        // 지도 (핀치 확대/이동 가능)
        Expanded(
          flex: 3,
          child: Container(
            color: const Color(0xFFEAF0F3),
            child: ClipRect(
              child: LayoutBuilder(
                builder: (ctx, cons) => GestureDetector(
                  onScaleStart: (d) {
                    _startFocal = d.focalPoint;
                    _startMatrix = _matrix.clone();
                  },
                  onScaleUpdate: (d) {
                    final delta = Matrix4.identity()
                      ..translate(d.focalPoint.dx, d.focalPoint.dy)
                      ..scale(d.scale, d.scale, 1.0)
                      ..rotateZ(d.rotation)
                      ..translate(-_startFocal.dx, -_startFocal.dy);
                    setState(() => _matrix = delta * _startMatrix);
                  },
                  child: Transform(
                    transform: _matrix,
                    child: SizedBox(
                      width: cons.maxWidth,
                      height: cons.maxHeight,
                      child: CustomPaint(painter: _MapPainter(slopes, track, cur, m)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // 상태
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFF4F6F8),
          child: DefaultTextStyle(
            style: const TextStyle(color: Color(0xFF222222), fontSize: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(status),
              Text('현재: ${cur == null ? "-" : "${cur!.lat.toStringAsFixed(6)}, ${cur!.lng.toStringAsFixed(6)}"}'),
              Text('세션: ${m?.activeSummary ?? "-"}',
                  style: const TextStyle(color: Color(0xFF137333), fontWeight: FontWeight.bold)),
              Text('커밋 누적: ${m?.commits.length ?? 0}회 · 🖐 두 손가락으로 확대/이동'),
              ...slopes.where((s) => (m?.inside[s.slopeId] ?? false)).map((s) => Text(
                  '  ▣ ${s.name}  진행률 ${((m?.progress[s.slopeId] ?? 0)).toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF0B6BCB)))),
            ]),
          ),
        ),
        // 로그
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (c, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(logs[i],
                    style: TextStyle(
                        fontSize: 12,
                        color: logs[i].startsWith('✅')
                            ? const Color(0xFF137333)
                            : logs[i].startsWith('✕')
                                ? const Color(0xFFC5221F)
                                : logs[i].startsWith('▶')
                                    ? const Color(0xFFB26A00)
                                    : const Color(0xFF555555))),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MapPainter extends CustomPainter {
  final List<SlopePoly> slopes;
  final List<GeoPt> track;
  final GeoPt? cur;
  final PolygonSessionMachine? m;
  _MapPainter(this.slopes, this.track, this.cur, this.m);

  static const List<Color> _palette = [
    Color(0xFFE91E63), Color(0xFF1E88E5), Color(0xFF43A047), Color(0xFFFB8C00),
    Color(0xFF8E24AA), Color(0xFF00ACC1), Color(0xFF6D4C41), Color(0xFF5E35B1),
    Color(0xFFD81B60), Color(0xFF039BE5), Color(0xFF7CB342), Color(0xFFF4511E),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 현재 위치 3km 내 슬로프만
    final list = slopes.where((s) => cur == null ||
        metersBetween(GeoPt((s.minLat + s.maxLat) / 2, (s.minLng + s.maxLng) / 2), cur!) < 3000).toList();

    // 위경도 bbox (미터 변환 기준점용)
    double mnLa = 90, mxLa = -90, mnLn = 180, mxLn = -180;
    void extLL(GeoPt p) {
      mnLa = math.min(mnLa, p.lat); mxLa = math.max(mxLa, p.lat);
      mnLn = math.min(mnLn, p.lng); mxLn = math.max(mxLn, p.lng);
    }
    for (final s in list) { for (final p in s.ring) { extLL(p); } }
    for (final p in track) { extLL(p); }
    if (cur != null) extLL(cur!);
    if (mnLa > mxLa) return;

    // 위경도 → 로컬 미터(등거리). 단일 배율로 종횡비 유지 → 왜곡 없는 top-down(수직 하강 시점)
    final refLat = (mnLa + mxLa) / 2;
    final mPerLat = 111320.0, mPerLng = 111320.0 * math.cos(refLat * math.pi / 180);
    final refLng = (mnLn + mxLn) / 2;
    double mxOf(GeoPt p) => (p.lng - refLng) * mPerLng;
    double myOf(GeoPt p) => (p.lat - refLat) * mPerLat;

    double bnX = 1e18, bxX = -1e18, bnY = 1e18, bxY = -1e18;
    void extM(GeoPt p) {
      final x = mxOf(p), y = myOf(p);
      bnX = math.min(bnX, x); bxX = math.max(bxX, x);
      bnY = math.min(bnY, y); bxY = math.max(bxY, y);
    }
    for (final s in list) { for (final p in s.ring) { extM(p); } }
    for (final p in track) { extM(p); }
    if (cur != null) extM(cur!);

    final w = math.max(bxX - bnX, 1e-6), h = math.max(bxY - bnY, 1e-6);
    final scale = math.min(size.width / w, size.height / h) * 0.85; // 여백
    final midX = (bnX + bxX) / 2, midY = (bnY + bxY) / 2;
    Offset toXY(GeoPt p) => Offset(
          size.width / 2 + (mxOf(p) - midX) * scale,
          size.height / 2 - (myOf(p) - midY) * scale, // 북쪽이 위
        );

    for (int idx = 0; idx < list.length; idx++) {
      final s = list[idx];
      if (s.ring.length < 3) continue;
      final col = _palette[idx % _palette.length]; // 폴리곤마다 다른 색
      final active = (m?.inside[s.slopeId] ?? false);
      final path = Path()..addPolygon(s.ring.map(toXY).toList(), true);
      canvas.drawPath(path, Paint()..color = col.withOpacity(active ? 0.5 : 0.25)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = active ? 3.2 : 1.8);
      // 축 + 상단점 (폴리곤 색과 동일 계열)
      if (s.axis.length >= 2) {
        canvas.drawPath(Path()..addPolygon(s.axis.map(toXY).toList(), false),
            Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 2.6);
        canvas.drawCircle(toXY(s.axis.first), 4.5, Paint()..color = Colors.black);
      }
      // 슬로프명 (상단점 위)
      _label(canvas, toXY(s.axis.isNotEmpty ? s.axis.first : s.ring.first), s.name);
    }
    // 궤적
    if (track.length >= 2) {
      canvas.drawPath(Path()..addPolygon(track.map(toXY).toList(), false),
          Paint()..color = const Color(0xFF1565C0)..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    // 현재 위치
    if (cur != null) {
      final c = toXY(cur!);
      canvas.drawCircle(c, 2.7, Paint()..color = const Color(0xFFFFC107));
      canvas.drawCircle(c, 2.7, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 0.8);
    }
  }

  void _label(Canvas canvas, Offset at, String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Color(0xFF222222), fontSize: 5.5, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = at.dx - tp.width / 2;          // 상단점 기준 가운데 정렬
    final y = at.dy - tp.height - 6;         // 상단점 위로
    final bg = Rect.fromLTWH(x - 2, y - 1, tp.width + 4, tp.height + 2);
    canvas.drawRRect(RRect.fromRectAndRadius(bg, const Radius.circular(2)), Paint()..color = Colors.white.withOpacity(0.85));
    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => true;
}
