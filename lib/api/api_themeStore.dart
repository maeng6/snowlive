import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class ThemeStoreAPI {
  static const String baseUrl =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/themeStore';

  /// 공통: utf8 디코딩 + json 파싱 (Map/List 모두 대응)
  dynamic _decodeBody(http.Response response) {
    return json.decode(utf8.decode(response.bodyBytes));
  }

  /// 테마스토어 메인 데이터 조회
  Future<ApiResponse> fetchThemeStoreMain({required int userId}) async {
    final uri = Uri.parse('$baseUrl/main/');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      // 메인은 Map 형태라고 가정되지만, 일단 그대로 전달
      return ApiResponse.success(data);
    } else {
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

    final data = _decodeBody(response);

    if (response.statusCode == 201) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error(data);
    }
  }

  /// 구매 기록 수정
  Future<ApiResponse> updateBuyRecord(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/buy-record/update/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error(data);
    }
  }

  /// 구매 기록 삭제 (POST 방식)
  Future<ApiResponse> deleteBuyRecord(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/buy-record/delete/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = _decodeBody(response);

    if (response.statusCode == 200) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error(data);
    }
  }


  /// 내 구매 기록 목록 조회
  /// ✅ 서버 응답: List 형태 ([ {...}, {...} ])
  Future<ApiResponse> fetchMyBuyRecords({required int userId}) async {
    final uri = Uri.parse('$baseUrl/buy-record/');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    final data = _decodeBody(response); // ✅ List/Map 모두 가능

    if (response.statusCode == 200) {
      return ApiResponse.success(data); // ✅ 그대로 넘김 (List)
    } else {
      return ApiResponse.error(data);
    }
  }
}
