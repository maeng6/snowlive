import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/core/api/ApiResponse.dart';

/// 유료 궤적 상세 조회 API. 유료 게이트는 서버에서(그 시즌 PAID 시즌권 보유).
class RideDetailAPI {
  static const String baseUrl =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/payment/season';

  Future<ApiResponse> fetchRideDetail(
      {required int userId, required int trackId}) async {
    final uri = Uri.parse('$baseUrl/ride-detail/$trackId/')
        .replace(queryParameters: {'user_id': userId.toString()});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }

  /// 내 궤적 목록(상세 진입용).
  Future<ApiResponse> fetchRideList({required int userId}) async {
    final uri = Uri.parse('$baseUrl/ride-list/')
        .replace(queryParameters: {'user_id': userId.toString()});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }
}
