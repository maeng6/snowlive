import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/core/api/ApiResponse.dart';

/// 친구 실시간 위치 공유 API (유료 전용, 상호 수락).
class LocationShareAPI {
  static const String baseUrl =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/friend/location-share';

  Future<ApiResponse> request({required int userId, required int friendUserId}) =>
      _post('request', userId, friendUserId);
  Future<ApiResponse> accept({required int userId, required int friendUserId}) =>
      _post('accept', userId, friendUserId);
  Future<ApiResponse> revoke({required int userId, required int friendUserId}) =>
      _post('revoke', userId, friendUserId);

  Future<ApiResponse> _post(String path, int userId, int friendUserId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$path/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'friend_user_id': friendUserId}),
    );
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }

  /// 내 공유 상태(수락됨/받은신청/보낸신청).
  Future<ApiResponse> list({required int userId}) async {
    final uri = Uri.parse('$baseUrl/list/')
        .replace(queryParameters: {'user_id': userId.toString()});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }

  /// 내 실시간 좌표 publish (세션중 5초/그외 10초).
  Future<ApiResponse> publish({
    required int userId,
    required double lat,
    required double lng,
    int? slopeId,
    bool? isRiding,
  }) async {
    final body = <String, dynamic>{'user_id': userId, 'lat': lat, 'lng': lng};
    if (slopeId != null) body['slope_id'] = slopeId;
    if (isRiding != null) body['is_riding'] = isRiding;
    final response = await http.post(
      Uri.parse('$baseUrl/publish/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }

  /// 상호수락 친구들의 실시간 좌표(지도 폴링용).
  Future<ApiResponse> map({required int userId}) async {
    final uri = Uri.parse('$baseUrl/map/')
        .replace(queryParameters: {'user_id': userId.toString()});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }
}
