import 'dart:async';
import 'dart:convert';
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

  Future<void> _init() async {
    try {
      final r = await http.get(Uri.parse('$base/api/resort/slopes-2627/?resort=$resortId'));
      final data = json.decode(utf8.decode(r.bodyBytes));
      slopes = (data['slopes'] as List)
          .map((j) => SlopePoly.fromJson(j as Map<String, dynamic>))
          .where((s) => s.hasPolygon)
          .toList();
      machine = PolygonSessionMachine(slopes)
        ..onLog = (m) => setState(() {
              logs.insert(0, m);
              if (logs.length > 200) logs.removeLast();
            });
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
    const settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 3);
    sub = Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
      final p = GeoPt(pos.latitude, pos.longitude);
      cur = p;
      track.add(p);
      if (track.length > 1500) track.removeAt(0);
      machine?.onPoint(p, DateTime.now());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = machine;
    return Scaffold(
      appBar: AppBar(title: const Text('폴리곤 판별 테스트'), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: Column(children: [
        Expanded(
          flex: 3,
          child: Container(
            color: const Color(0xFF10202A),
            child: CustomPaint(size: Size.infinite, painter: _MapPainter(slopes, track, cur, m)),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.black,
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white, fontSize: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(status),
              Text('현재: ${cur == null ? "-" : "${cur!.lat.toStringAsFixed(6)}, ${cur!.lng.toStringAsFixed(6)}"}'),
              Text('세션: ${m?.activeSummary ?? "-"}',
                  style: const TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold)),
              Text('커밋 누적: ${m?.commits.length ?? 0}회'),
              const SizedBox(height: 4),
              ...slopes.where((s) => (m?.inside[s.slopeId] ?? false)).map((s) => Text(
                  '  ▣ ${s.name}  진행률 ${((m?.progress[s.slopeId] ?? 0)).toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.cyanAccent))),
            ]),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFF181818),
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (c, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(logs[i],
                    style: TextStyle(
                        fontSize: 12,
                        color: logs[i].startsWith('✅')
                            ? Colors.greenAccent
                            : logs[i].startsWith('✕')
                                ? Colors.redAccent
                                : logs[i].startsWith('▶')
                                    ? Colors.yellowAccent
                                    : Colors.white70)),
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

  @override
  void paint(Canvas canvas, Size size) {
    // 현재 위치 근처(3km) 슬로프만 그림 (멀리 있는 리조트 슬로프 제외 → 지도 축소 방지)
    final list = cur == null
        ? slopes
        : slopes
            .where((s) => metersBetween(GeoPt((s.minLat + s.maxLat) / 2, (s.minLng + s.maxLng) / 2), cur!) < 3000)
            .toList();

    double mnLa = 90, mxLa = -90, mnLn = 180, mxLn = -180;
    void ext(GeoPt p) {
      mnLa = math.min(mnLa, p.lat);
      mxLa = math.max(mxLa, p.lat);
      mnLn = math.min(mnLn, p.lng);
      mxLn = math.max(mxLn, p.lng);
    }

    for (final s in list) {
      for (final p in s.ring) { ext(p); }
    }
    for (final p in track) { ext(p); }
    if (cur != null) ext(cur!);
    if (mnLa > mxLa) return;

    final padLa = (mxLa - mnLa) * 0.15 + 1e-5, padLn = (mxLn - mnLn) * 0.15 + 1e-5;
    mnLa -= padLa;
    mxLa += padLa;
    mnLn -= padLn;
    mxLn += padLn;

    Offset toXY(GeoPt p) => Offset(
          (p.lng - mnLn) / (mxLn - mnLn) * size.width,
          (1 - (p.lat - mnLa) / (mxLa - mnLa)) * size.height,
        );

    for (final s in list) {
      if (s.ring.length < 3) continue;
      final active = (m?.inside[s.slopeId] ?? false);
      final path = Path()..addPolygon(s.ring.map(toXY).toList(), true);
      canvas.drawPath(path,
          Paint()..color = Colors.pinkAccent.withOpacity(active ? 0.40 : 0.15)..style = PaintingStyle.fill);
      canvas.drawPath(path,
          Paint()..color = Colors.pinkAccent..style = PaintingStyle.stroke..strokeWidth = active ? 2.5 : 1.5);
      if (s.axis.length >= 2) {
        canvas.drawPath(Path()..addPolygon(s.axis.map(toXY).toList(), false),
            Paint()..color = Colors.redAccent..style = PaintingStyle.stroke..strokeWidth = 2);
        canvas.drawCircle(toXY(s.axis.first), 4, Paint()..color = Colors.black); // 상단
      }
    }
    if (track.length >= 2) {
      canvas.drawPath(Path()..addPolygon(track.map(toXY).toList(), false),
          Paint()..color = Colors.lightBlueAccent..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    if (cur != null) {
      canvas.drawCircle(toXY(cur!), 6, Paint()..color = Colors.yellow);
      canvas.drawCircle(toXY(cur!), 6, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => true;
}
