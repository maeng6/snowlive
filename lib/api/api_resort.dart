import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class ResortAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api';

  /// 활성화된 리조트 목록 조회 (Geofencing용)
  /// GET /resort/active/
  Future<ApiResponse> getActiveResorts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resort/active/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List;
        return ApiResponse.success(data);
      } else {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return ApiResponse.error(data);
      }
    } catch (e) {
      return ApiResponse.error('Failed to fetch active resorts: $e');
    }
  }
}

/// 리조트 Geofence 정보 모델
class ResortGeofence {
  final int resortId;
  final String fullname;
  final double latitude;
  final double longitude;
  final double radius; // 미터 단위

  ResortGeofence({
    required this.resortId,
    required this.fullname,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  /// SRID=4326;POINT (longitude latitude) 형식 파싱
  factory ResortGeofence.fromJson(Map<String, dynamic> json, {double defaultRadius = 1500}) {
    final coordinates = json['coordinates_geofencing'] as String;
    final parsed = _parseCoordinates(coordinates);

    double radius = (json['radius_geofencing'] as num?)?.toDouble() ?? 0.0;
    if (radius <= 0) {
      radius = defaultRadius; // 기본값 1.5km
    }

    return ResortGeofence(
      resortId: json['resort_id'] as int,
      fullname: json['fullname'] as String,
      latitude: parsed['latitude']!,
      longitude: parsed['longitude']!,
      radius: radius,
    );
  }

  /// SRID=4326;POINT (longitude latitude) 파싱
  static Map<String, double> _parseCoordinates(String coordinates) {
    // "SRID=4326;POINT (128.6723207 37.6529436)" 형식
    final regex = RegExp(r'POINT\s*\(\s*([\d.-]+)\s+([\d.-]+)\s*\)');
    final match = regex.firstMatch(coordinates);

    if (match != null) {
      return {
        'longitude': double.parse(match.group(1)!),
        'latitude': double.parse(match.group(2)!),
      };
    }

    return {'latitude': 0.0, 'longitude': 0.0};
  }

  /// Geofence identifier (플러그인에서 사용)
  String get identifier => 'resort_$resortId';

  @override
  String toString() => 'ResortGeofence($resortId: $fullname, $latitude, $longitude, ${radius}m)';
}
