import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/core/api/ApiResponse.dart';

class EventAPI {
  static const String baseUrl = 'https://snowlive-api-c617725e2b78.herokuapp.com/api/event';

  /// 이벤트 목록 조회 (GET /api/event/)
  /// [category] - 카테고리 필터 (optional)
  /// [searchQuery] - 검색어 (title, description 검색) (optional)
  /// [url] - 페이지네이션 URL (optional, 다음 페이지 로드 시 사용)
  Future<ApiResponse> fetchEventList({
    String? category,
    String? searchQuery,
    String? url,
  }) async {
    final Uri uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/').replace(
            queryParameters: {
              if (category != null && category.isNotEmpty) 'category': category,
              if (searchQuery != null && searchQuery.isNotEmpty) 'search_query': searchQuery,
            },
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

  /// 이벤트 상세 조회 (GET /api/event/{event_id}/)
  /// [eventId] - 이벤트 ID
  /// [userId] - 조회한 사용자 ID (optional, views에 추가됨)
  Future<ApiResponse> fetchEventDetail({
    required int eventId,
    int? userId,
  }) async {
    final Uri uri = Uri.parse('$baseUrl/$eventId/').replace(
      queryParameters: {
        if (userId != null) 'user_id': userId.toString(),
      },
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

  /// 이벤트 생성 (POST /api/event/)
  Future<ApiResponse> createEvent(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/'),
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

  /// 이벤트 수정 (PUT /api/event/{event_id}/)
  Future<ApiResponse> updateEvent({
    required int eventId,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$eventId/'),
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

  /// 이벤트 삭제 (DELETE /api/event/{event_id}/)
  Future<ApiResponse> deleteEvent({
    required int eventId,
    required int userId,
  }) async {
    final Uri uri = Uri.parse('$baseUrl/$eventId/').replace(
      queryParameters: {
        'user_id': userId.toString(),
      },
    );

    final response = await http.delete(uri);

    if (response.statusCode == 204) {
      return ApiResponse.success({'message': 'Event deleted successfully'});
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  /// 이벤트 조회수 증가 (PUT /api/event/view/{event_id}/)
  Future<ApiResponse> incrementViewCount({
    required int eventId,
    required int userId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/view/$eventId/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }
}
