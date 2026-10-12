import 'dart:math' as math;

/// 유료 궤적 상세 단일 원천(백엔드 /api/payment/season/ride-detail/<id>).
/// 앱·웹 공통 위젯이 이 모델을 그린다.
class RideDetail {
  final int ridingTrackId;
  final String? season;
  final List<List<double>> track; // [[lng,lat], ...]
  final RideSamples? samples;
  final RideSlope? slope;
  final RideRecord? record;

  RideDetail({
    required this.ridingTrackId,
    this.season,
    required this.track,
    this.samples,
    this.slope,
    this.record,
  });

  factory RideDetail.fromJson(Map<String, dynamic> j) {
    return RideDetail(
      ridingTrackId: (j['riding_track_id'] as num).toInt(),
      season: j['season']?.toString(),
      track: _coordList(j['track']),
      samples: j['samples'] is Map
          ? RideSamples.fromJson(Map<String, dynamic>.from(j['samples']))
          : null,
      slope: j['slope'] is Map
          ? RideSlope.fromJson(Map<String, dynamic>.from(j['slope']))
          : null,
      record: j['record'] is Map
          ? RideRecord.fromJson(Map<String, dynamic>.from(j['record']))
          : null,
    );
  }
}

List<List<double>> _coordList(dynamic v) {
  if (v is! List) return const [];
  final out = <List<double>>[];
  for (final e in v) {
    if (e is List && e.length >= 2) {
      final a = (e[0] as num?)?.toDouble();
      final b = (e[1] as num?)?.toDouble();
      if (a != null && b != null) out.add([a, b]);
    }
  }
  return out;
}

List<double> _numList(dynamic v) {
  if (v is! List) return const [];
  return v.map((e) => (e is num) ? e.toDouble() : double.nan).toList();
}

class RideSamples {
  final List<double> t; // ms
  final List<double> lat;
  final List<double> lng;
  final List<double?> alt; // m (nullable)
  final List<double> spd; // km/h (smoothed)

  RideSamples({
    required this.t,
    required this.lat,
    required this.lng,
    required this.alt,
    required this.spd,
  });

  int get length => lat.length;
  bool get hasData => length >= 2;

  factory RideSamples.fromJson(Map<String, dynamic> j) {
    final altRaw = j['alt'];
    final alt = (altRaw is List)
        ? altRaw.map<double?>((e) => (e is num) ? e.toDouble() : null).toList()
        : <double?>[];
    return RideSamples(
      t: _numList(j['t']),
      lat: _numList(j['lat']),
      lng: _numList(j['lng']),
      alt: alt,
      spd: _numList(j['spd']),
    );
  }
}

class RideSlope {
  final String? fullname;
  final String? nickname;
  final List<List<double>> area; // 외곽 링 [[lng,lat], ...]
  final List<List<double>> axis; // 진행축(상단 entry → 하단 exit)

  RideSlope({this.fullname, this.nickname, required this.area, required this.axis});

  bool get hasPolygon => area.length >= 3 && axis.length >= 2;

  factory RideSlope.fromJson(Map<String, dynamic> j) {
    // area: Polygon.coords → [ [ [lng,lat], ... ] ] (링 리스트). 외곽 링만 사용.
    List<List<double>> ring = const [];
    final a = j['area'];
    if (a is List && a.isNotEmpty) {
      if (a.first is List && (a.first as List).isNotEmpty && (a.first as List).first is List) {
        ring = _coordList(a.first); // [ring][point][xy]
      } else {
        ring = _coordList(a); // 이미 [point][xy]
      }
    }
    return RideSlope(
      fullname: j['fullname']?.toString(),
      nickname: j['nickname']?.toString(),
      area: ring,
      axis: _coordList(j['axis']),
    );
  }
}

class RideRecord {
  final double? score;
  final double? distance;
  final double? avgSpeed;
  final double? maxSpeed;
  final double? verticalDrop;
  final double? gradient;

  RideRecord({
    this.score,
    this.distance,
    this.avgSpeed,
    this.maxSpeed,
    this.verticalDrop,
    this.gradient,
  });

  factory RideRecord.fromJson(Map<String, dynamic> j) {
    double? d(dynamic v) => (v is num) ? v.toDouble() : null;
    return RideRecord(
      score: d(j['score']),
      distance: d(j['distance']),
      avgSpeed: d(j['avg_speed']),
      maxSpeed: d(j['max_speed']),
      verticalDrop: d(j['vertical_drop']),
      gradient: d(j['gradient']),
    );
  }
}

/// 서버 _render_track_svg_slope와 동일한 좌표 변환:
/// 진행축(axis)이 화면 '위→아래'가 되도록 회전 투영한 뒤 bbox에 맞춰 스케일.
class RideProjection {
  final double kx;
  final double a0x, a0y;
  final double ux, uy, vx, vy;
  final double minsx, minsy, spanx, spany;

  RideProjection._(this.kx, this.a0x, this.a0y, this.ux, this.uy, this.vx,
      this.vy, this.minsx, this.minsy, this.spanx, this.spany);

  /// ring(외곽)·axis·track(궤적)으로 투영을 구성. 폴리곤 없으면 북쪽 위 기본.
  factory RideProjection.build({
    required List<List<double>> ring,
    required List<List<double>> axis,
    required List<List<double>> track,
  }) {
    final all = <List<double>>[...ring, ...track];
    if (all.isEmpty) {
      return RideProjection._(1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1);
    }
    final meanLat = all.map((p) => p[1]).reduce((a, b) => a + b) / all.length;
    final kx = math.cos(meanLat * math.pi / 180);
    final kxv = kx == 0 ? 1e-9 : kx;

    double px(List<double> p) => p[0] * kxv;
    double py(List<double> p) => p[1];

    double ux, uy, vx, vy, a0x, a0y;
    if (axis.length >= 2) {
      a0x = px(axis.first);
      a0y = py(axis.first);
      final a1x = px(axis.last);
      final a1y = py(axis.last);
      final dx = a1x - a0x, dy = a1y - a0y;
      final l = math.sqrt(dx * dx + dy * dy);
      final ll = l == 0 ? 1e-9 : l;
      vx = dx / ll;
      vy = dy / ll; // 진행 = 아래(+sy)
      ux = vy;
      uy = -vx; // 오른쪽(+sx)
    } else {
      a0x = px(all.first);
      a0y = py(all.first);
      ux = 1;
      uy = 0;
      vx = 0;
      vy = 1;
    }

    List<double> rot(List<double> p) {
      final rx = px(p) - a0x, ry = py(p) - a0y;
      return [rx * ux + ry * uy, rx * vx + ry * vy];
    }

    final bb = <List<double>>[...ring.map(rot), ...track.map(rot)];
    double minsx = bb.first[0], maxsx = bb.first[0];
    double minsy = bb.first[1], maxsy = bb.first[1];
    for (final s in bb) {
      if (s[0] < minsx) minsx = s[0];
      if (s[0] > maxsx) maxsx = s[0];
      if (s[1] < minsy) minsy = s[1];
      if (s[1] > maxsy) maxsy = s[1];
    }
    final spanx = (maxsx - minsx) == 0 ? 1e-9 : (maxsx - minsx);
    final spany = (maxsy - minsy) == 0 ? 1e-9 : (maxsy - minsy);
    return RideProjection._(
        kxv, a0x, a0y, ux, uy, vx, vy, minsx, minsy, spanx, spany);
  }

  /// 경위도 → 회전 투영 좌표(스케일 전).
  List<double> rot(List<double> p) {
    final rx = p[0] * kx - a0x, ry = p[1] - a0y;
    return [rx * ux + ry * uy, rx * vx + ry * vy];
  }
}
