import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/core/api/ApiResponse.dart';

class EventAPI {
  static const String baseUrl = 'https://snowlive-api-c617725e2b78.herokuapp.com/api/event';

  /// 이벤트 목록 조회 (GET /api/event/)
  /// [category] - 카테고리 필터 (optional)
  /// [searchQuery] - 검색어 (title, description 검색) (optional)
  /// [crawlAccountId] - 특정 크롤 계정 글만 (optional, 각종소식 웹 필터)
  /// [url] - 페이지네이션 URL (optional, 다음 페이지 로드 시 사용)
  /// [page] - 번호식 페이지네이션용(웹). [url]이 주어지면 무시된다.
  Future<ApiResponse> fetchEventList({
    String? category,
    String? searchQuery,
    int? crawlAccountId,
    String? url,
    int? page,
  }) async {
    final Uri uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/').replace(
            queryParameters: {
              if (category != null && category.isNotEmpty) 'category': category,
              if (searchQuery != null && searchQuery.isNotEmpty) 'search_query': searchQuery,
              if (crawlAccountId != null) 'crawl_account_id': '$crawlAccountId',
              if (page != null) 'page': '$page',
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

  /// 크롤 계정 목록 조회 (GET /api/event/crawl-accounts/?enabled=true)
  /// 각종소식 웹 필터 드롭다운 채우기용. 응답은 계정 배열(페이지네이션 없음)이며,
  /// 혹시 dict로 오면 results를 쓴다. 실패 시 빈 목록.
  Future<List<Map<String, dynamic>>> fetchCrawlAccounts() async {
    try {
      final uri = Uri.parse('$baseUrl/crawl-accounts/?enabled=true');
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      if (decoded is Map && decoded['results'] is List) {
        return (decoded['results'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
  /// 조회수 증가 (PUT /api/event/view/{event_id}/)
  /// 제목 클릭 → landing_url 이동 시 호출한다.
  /// 로그인 유저는 유저당 5분 1회 스로틀, 게스트([userId] null)는 매 클릭 익명 기록.
  /// 응답: `{ "detail": "ok", "counted": bool, "views_count": int }`
  Future<ApiResponse> incrementViewCount({
    required int eventId,
    int? userId,
  }) async {
    final Uri uri = Uri.parse('$baseUrl/view/$eventId/');
    // 게스트면 user_id를 아예 빼서 보낸다(서버가 없으면 익명으로 처리).
    final body = <String, dynamic>{};
    if (userId != null) body['user_id'] = userId;
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error(data);
    }
  }

  // 목록·조회수 전용(각종소식) — 상세/생성/수정/삭제 API는 제거됨(미사용).
  // 어드민 CRUD는 웹 각종소식 어드민(news.html)에서 처리.
}
