import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class ThemeStoreAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/themeStore';

  /// 테마스토어 메인 데이터 조회
  Future<ApiResponse> fetchThemeStoreMain({required int userId}) async {
    final uri = Uri.parse('$baseUrl/main/').replace(
      queryParameters: {'user_id': userId.toString()},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  /// 구매 기록 생성
  Future<ApiResponse> createBuyRecord(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/buy-record/create/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  /// 구매 기록 수정
  Future<ApiResponse> updateBuyRecord(Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/buy-record/update/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  /// 구매 기록 삭제
  Future<ApiResponse> deleteBuyRecord(Map<String, dynamic> body) async {
    final request = http.Request('DELETE', Uri.parse('$baseUrl/buy-record/delete/'));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode(body);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }
}