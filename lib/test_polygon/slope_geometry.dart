import 'dart:math' as math;

/// 순수 기하 유틸 — 지도/Firebase 의존 없음. 판별용 좌표 수학만.
class GeoPt {
  final double lat, lng;
  const GeoPt(this.lat, this.lng);
}

const double _earthR = 6371000.0;

double metersBetween(GeoPt a, GeoPt b) {
  final la = (a.lat + b.lat) / 2 * math.pi / 180;
  final x = (b.lng - a.lng) * math.pi / 180 * math.cos(la);
  final y = (b.lat - a.lat) * math.pi / 180;
  return math.sqrt(x * x + y * y) * _earthR;
}

class _NS {
  final double t, d;
  _NS(this.t, this.d);
}

_NS _nearestOnSeg(GeoPt p, GeoPt a, GeoPt b) {
  final kx = math.cos(p.lat * math.pi / 180);
  final ax = a.lng * kx, ay = a.lat, bx = b.lng * kx, by = b.lat, px = p.lng * kx, py = p.lat;
  final dx = bx - ax, dy = by - ay;
  final len2 = dx * dx + dy * dy;
  double t = len2 > 0 ? ((px - ax) * dx + (py - ay) * dy) / len2 : 0;
  t = t.clamp(0.0, 1.0);
  final c = GeoPt(ay + t * dy, (ax + t * dx) / kx);
  return _NS(t, metersBetween(p, c));
}

class SlopePoly {
  final int slopeId;
  final String name;
  final List<GeoPt> ring;   // 폴리곤 꼭짓점 (닫힘점 제거)
  final List<GeoPt> axis;   // 첫 점=상단(top), 끝 점=하단(bottom)
  final List<double> cum;   // 축 누적거리(m)
  final double axisLen;
  final double minLat, maxLat, minLng, maxLng;

  SlopePoly._(this.slopeId, this.name, this.ring, this.axis, this.cum, this.axisLen,
      this.minLat, this.maxLat, this.minLng, this.maxLng);

  factory SlopePoly.fromJson(Map<String, dynamic> j) {
    final ring = <GeoPt>[];
    if (j['area'] != null) {
      for (final c in (j['area']['coordinates'][0] as List)) {
        ring.add(GeoPt((c[1] as num).toDouble(), (c[0] as num).toDouble()));
      }
      if (ring.length > 1 && ring.first.lat == ring.last.lat && ring.first.lng == ring.last.lng) {
        ring.removeLast();
      }
    }
    final axis = <GeoPt>[];
    if (j['axis'] != null) {
      for (final c in (j['axis']['coordinates'] as List)) {
        axis.add(GeoPt((c[1] as num).toDouble(), (c[0] as num).toDouble()));
      }
    }
    final cum = <double>[0];
    double total = 0;
    for (int i = 1; i < axis.length; i++) {
      total += metersBetween(axis[i - 1], axis[i]);
      cum.add(total);
    }
    double mnLa = 90, mxLa = -90, mnLn = 180, mxLn = -180;
    for (final p in ring) {
      mnLa = math.min(mnLa, p.lat);
      mxLa = math.max(mxLa, p.lat);
      mnLn = math.min(mnLn, p.lng);
      mxLn = math.max(mxLn, p.lng);
    }
    return SlopePoly._(j['slope_id'] as int, (j['fullname'] ?? '') as String, ring, axis, cum, total,
        mnLa, mxLa, mnLn, mxLn);
  }

  bool get hasPolygon => ring.length >= 3 && axis.length >= 2;

  bool inBbox(GeoPt p) =>
      p.lat >= minLat - 0.0005 && p.lat <= maxLat + 0.0005 &&
      p.lng >= minLng - 0.0005 && p.lng <= maxLng + 0.0005;

  bool contains(GeoPt p) {
    if (ring.length < 3) return false;
    bool inside = false;
    for (int i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final yi = ring[i].lat, xi = ring[i].lng, yj = ring[j].lat, xj = ring[j].lng;
      if (((yi > p.lat) != (yj > p.lat)) &&
          (p.lng < (xj - xi) * (p.lat - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
    }
    return inside;
  }

  /// 축 진행률 0(상단)~1(하단). 축 없으면 -1.
  double progress(GeoPt p) {
    if (axis.length < 2 || axisLen <= 0) return -1;
    double best = double.infinity, bestAlong = 0;
    for (int i = 0; i < axis.length - 1; i++) {
      final r = _nearestOnSeg(p, axis[i], axis[i + 1]);
      final along = cum[i] + r.t * (cum[i + 1] - cum[i]);
      if (r.d < best) {
        best = r.d;
        bestAlong = along;
      }
    }
    return bestAlong / axisLen;
  }
}
