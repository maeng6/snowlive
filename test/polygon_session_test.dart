import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:com.snowlive/mobile/test_polygon/slope_geometry.dart';
import 'package:com.snowlive/mobile/test_polygon/polygon_session_machine.dart';

// ── 로컬 좌표계: 미터(x=동/lng, y=북/lat) → 위경도 ──
const double _oLat = 37.6529, _oLng = 126.8967;
GeoPt pt(double xM, double yM) {
  final lat = _oLat + yM / 111320.0;
  final lng = _oLng + xM / (111320.0 * math.cos(_oLat * math.pi / 180));
  return GeoPt(lat, lng);
}

List<double> _ll(double x, double y) {
  final p = pt(x, y);
  return [p.lng, p.lat];
}

Map<String, dynamic> slopeJson(int id, String name, List<List<double>> ringM, List<List<double>> axisM) {
  final ring = ringM.map((xy) => _ll(xy[0], xy[1])).toList();
  ring.add(ring.first);
  return {
    'slope_id': id,
    'fullname': name,
    'area': {'type': 'Polygon', 'coordinates': [ring]},
    'axis': {'type': 'LineString', 'coordinates': axisM.map((xy) => _ll(xy[0], xy[1])).toList()},
    'center': null,
  };
}

// 경유점(미터)들을 stepM 간격으로 보간
List<GeoPt> walk(List<List<double>> wpsM, {double stepM = 5}) {
  final wps = wpsM.map((xy) => pt(xy[0], xy[1])).toList();
  final out = <GeoPt>[];
  for (int i = 0; i < wps.length - 1; i++) {
    final a = wps[i], b = wps[i + 1];
    final n = math.max(1, (metersBetween(a, b) / stepM).round());
    for (int k = 0; k < n; k++) {
      final t = k / n;
      out.add(GeoPt(a.lat + (b.lat - a.lat) * t, a.lng + (b.lng - a.lng) * t));
    }
  }
  out.add(wps.last);
  return out;
}

List<CommitEvent> run(List<SlopePoly> slopes, List<GeoPt> pts) {
  final m = PolygonSessionMachine(slopes);
  var t = DateTime(2026, 1, 1, 10);
  for (final p in pts) {
    m.onPoint(p, t);
    t = t.add(const Duration(seconds: 1));
  }
  return m.commits;
}

// 단일 슬로프 A: 사각형 x[0,40] y[0,100], 축 상단(20,100)→하단(20,0)
SlopePoly slopeA() => SlopePoly.fromJson(slopeJson(
    1, 'A', [[0, 0], [40, 0], [40, 100], [0, 100]], [[20, 100], [20, 0]]));

void main() {
  group('A. 진입', () {
    test('A1 정상 하강 → 1커밋', () {
      final c = run([slopeA()], walk([[20, 120], [20, -20]]));
      expect(c.length, 1);
      expect(c.first.slopeId, 1);
    });

    test('A2 역행(위로 올라감) → 0커밋', () {
      final c = run([slopeA()], walk([[20, 20], [20, 110]]));
      expect(c.length, 0);
    });

    test('A3 정지 후 하강 → 1커밋', () {
      final c = run([slopeA()], walk([[20, 50], [20, 50], [20, -20]]));
      expect(c.length, 1);
    });
  });

  group('B. 진행 중', () {
    test('B2 중간 횡단(진행률 정체) → 세션 유지, 1커밋', () {
      final c = run([slopeA()], walk([[20, 120], [20, 60], [0, 60], [40, 60], [20, 60], [20, -20]]));
      expect(c.length, 1);
    });
  });

  group('C. 종료', () {
    test('C2 폴리곤 내부 리프트(밴드 초과 후퇴) 후 재하강 → 2커밋', () {
      // 폴리곤을 안 벗어나고 리프트 타고 올라갔다(밴드 25m 초과 후퇴) 재하강 → 세션 분리 = 2커밋
      final c = run([slopeA()], walk([[20, 120], [20, 40], [20, 95], [20, -20]]));
      expect(c.length, 2);
    });
  });

  group('D. 경계 노이즈', () {
    test('D1 한 점 밖으로 튐 후 복귀 → 1커밋(안 쪼개짐)', () {
      // 하강 중 한 점만 폴리곤 밖(동쪽 60m)으로 튀었다 복귀
      final pts = walk([[20, 120], [20, 55]]);
      pts.add(pt(80, 55)); // 밖(스파이크 1점)
      pts.addAll(walk([[20, 50], [20, -20]]));
      final c = run([slopeA()], pts);
      expect(c.length, 1);
    });
  });

  group('E. 겹침(공유하단)', () {
    // A: L자(왼쪽 상단 + 공유하단), B: L자(오른쪽 상단 + 공유하단). 하단 x[0,60] y[0,40] 공유.
    SlopePoly sharedA() => SlopePoly.fromJson(slopeJson(10, 'A',
        [[0, 0], [60, 0], [60, 40], [30, 40], [30, 100], [0, 100]], [[15, 100], [30, 0]]));
    SlopePoly sharedB() => SlopePoly.fromJson(slopeJson(11, 'B',
        [[0, 0], [60, 0], [60, 100], [30, 100], [30, 40], [0, 40]], [[45, 100], [30, 0]]));

    test('E1 A상단 시작→공유하단 → A만 1커밋(B 억제)', () {
      final c = run([sharedA(), sharedB()], walk([[15, 120], [15, 45], [30, 0], [30, -20]]));
      expect(c.length, 1);
      expect(c.first.slopeId, 10);
    });

    test('E2 B상단 시작→공유하단 → B만 1커밋(A 억제)', () {
      final c = run([sharedA(), sharedB()], walk([[45, 120], [45, 45], [30, 0], [30, -20]]));
      expect(c.length, 1);
      expect(c.first.slopeId, 11);
    });
  });

  group('E5. 연속(별개 슬로프)', () {
    test('A→B 순차 → 2커밋', () {
      final a = SlopePoly.fromJson(slopeJson(20, 'A', [[0, 70], [40, 70], [40, 160], [0, 160]], [[20, 160], [20, 70]]));
      final b = SlopePoly.fromJson(slopeJson(21, 'B', [[0, 0], [40, 0], [40, 60], [0, 60]], [[20, 60], [20, 0]]));
      final c = run([a, b], walk([[20, 175], [20, -15]]));
      expect(c.length, 2);
    });
  });

  group('F. 오판 방지', () {
    test('F1 폴리곤 위를 가로질러(횡단, 진행률 정체) → 0커밋', () {
      final c = run([slopeA()], walk([[-15, 50], [55, 50]]));
      expect(c.length, 0);
    });

    test('F2 축 따라 위로 통과(리프트 상향) → 0커밋', () {
      final c = run([slopeA()], walk([[20, -15], [20, 115]]));
      expect(c.length, 0);
    });
  });
}
