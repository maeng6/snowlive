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
  // 목록 전용(각종소식) — 상세/생성/수정/삭제/조회수 API는 제거됨(미사용).
  // 어드민 CRUD는 웹 각종소식 어드민(news.html)에서 처리.
}
