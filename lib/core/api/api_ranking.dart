import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/core/api/ApiResponse.dart';

class RankingAPI {
  static const String baseUrl = 'https://snowlive-api-c617725e2b78.herokuapp.com/api/ranking';

  Future<ApiResponse> check_wb(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-wb/'),
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

  Future<ApiResponse> participate_treasure_hunt(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/participate/'),
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
  Future<ApiResponse> liveOff(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/live-off/'),
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


  Future<http.Response> addCheckPoint(Map<String, dynamic> body) async {
    final Uri uri = Uri.parse('$baseUrl/add-check-point/');
    print('체크포인트 요청 바디: ${jsonEncode(body)}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 416) {
      print('체크포인트 요청 성공: ${json.decode(utf8.decode(response.bodyBytes))}');
    } else {
      print('체크포인트 요청 실패: ${json.decode(utf8.decode(response.bodyBytes))}');
    }

    return response;
  }


  Future<ApiResponse> respawn(Map<String, dynamic> body) async {
    print('리스폰 요청 바디: ${jsonEncode(body)}');
    final response = await http.post(
      Uri.parse('$baseUrl/respawn/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    print('리스폰 요청 응답: ${json.decode(utf8.decode(response.bodyBytes))}');
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      print('리스폰 요청 실패: ${json.decode(utf8.decode(response.bodyBytes))}');
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> reset(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset/'),
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

  Future<ApiResponse> createTreasureRecord(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/treasure-record/'),  // baseUrl을 환경에 맞게 설정
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      // 성공적인 응답 처리 (201 Created)
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      // 오류 처리
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> updateTreasureRecord(Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/update-treasure-record/'),  // baseUrl과 경로를 환경에 맞게 설정
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // 성공적인 응답 처리 (200 OK)
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      // 오류 처리
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data['error'] ?? 'An error occurred');
    }
  }

  Future<ApiResponse> fetchTreasureRecords(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/list-treasure-record/'), // baseUrl과 경로를 환경에 맞게 설정
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // JSON 데이터를 Map으로 처리
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data['error'] ?? 'An error occurred');
    }
  }




  Future<ApiResponse> fetchRankingData_indiv({
    int? userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url,
    String? federation,
    int? page,        // 웹 번호식 페이지네이션용
    int? pageSize,
    String? searchQuery,   // 통합 검색어(닉네임/상태메세지/스키장/크루명/소개글)
  }) async {
    // 웹은 게스트(비로그인) 상태에서도 랭킹을 조회할 수 있어야 하므로 userId를 옵셔널로 둔다
    // (모바일은 항상 로그인된 실제 user_id를 넘기므로 기존 동작에는 영향 없음).
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/list-indiv/').replace(
      queryParameters: {
        if (userId != null) 'user_id': userId.toString(),
        if (resortId != null) 'resort_id': resortId.toString(),
        if (daily != null) 'daily': daily.toString(),
        if (season != null) 'season': season,
        if (federation != null) 'federation': federation,
        if (page != null) 'page': page.toString(),
        if (pageSize != null) 'page_size': pageSize.toString(),
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

  /// [userId]는 게스트(비로그인)면 null이어도 된다. null이면 user_id 파라미터 자체를
  /// 빼고 호출하는데, 이때 서버는 my_ranking_info만 비우고 목록은 정상으로 돌려준다.
  /// (user_id=0 같은 더미값을 보내면 "No User matches the given query" 에러가 난다.)
  Future<ApiResponse> fetchRankingData_indiv_recordRoom({
    int? userId,
    int? resortId,
    bool? daily,
    String? selected_season,
    String? url,
    String? federation,
    int? page,        // 웹 번호식 페이지네이션용
    int? pageSize,
    String? searchQuery,   // 통합 검색어(닉네임/상태메세지/스키장/크루명/소개글)
  }) async {
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/list-recordroom-indiv/').replace(
      queryParameters: {
        if (userId != null) 'user_id': userId.toString(),
        if (resortId != null) 'resort_id': resortId.toString(),
        if (daily != null) 'daily': daily.toString(),
        if (selected_season != null) 'selected_season': selected_season,
        if (federation != null) 'federation': federation,
        if (page != null) 'page': page.toString(),
        if (pageSize != null) 'page_size': pageSize.toString(),
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

  Future<ApiResponse> fetchRankingData_indiv_beta({
    int? userId,  // 선택적으로 userId를 받을 수 있도록 변경
    String? url,
    int? page,        // 웹 번호식 페이지네이션용 (beta 응답은 total_pages가 최상위)
    int? pageSize,
    String? searchQuery,   // 통합 검색어(닉네임/상태메세지/스키장/크루명/소개글)
  }) async {
    final params = <String, String>{
      if (userId != null) 'user_id': userId.toString(),
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (searchQuery != null && searchQuery.isNotEmpty) 'search_query': searchQuery,
    };
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/list-indiv-beta/').replace(
            queryParameters: params.isEmpty ? null : params,
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


  Future<ApiResponse> fetchRankingData_crew({
    int? userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url,
    String? federation,
    int? page,        // 웹 번호식 페이지네이션용
    int? pageSize,
    String? searchQuery,   // 통합 검색어(닉네임/상태메세지/스키장/크루명/소개글)
  }) async {
    // 웹은 게스트(비로그인) 상태에서도 크루랭킹을 조회할 수 있어야 하므로 userId를
    // 옵셔널로 둔다(모바일은 항상 로그인된 실제 user_id를 넘기므로 기존 동작에 영향 없음).
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/list-crew/').replace(
      queryParameters: {
        if (userId != null) 'user_id': userId.toString(),
        if (resortId != null) 'resort_id': resortId.toString(),
        if (daily != null) 'daily': daily.toString(),
        if (season != null) 'season': season,
        if (federation != null) 'federation': federation,
        if (page != null) 'page': page.toString(),
        if (pageSize != null) 'page_size': pageSize.toString(),
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

  /// [userId]는 게스트(비로그인)면 null이어도 된다(개인 기록실과 동일).
  Future<ApiResponse> fetchRankingData_crew_recordRoom({
    int? userId,
    int? resortId,
    bool? daily,
    String? selected_season,
    String? url,
    String? federation,
    int? page,        // 웹 번호식 페이지네이션용
    int? pageSize,
    String? searchQuery,   // 통합 검색어(닉네임/상태메세지/스키장/크루명/소개글)
  }) async {
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/list-recordroom-crew/').replace(
      queryParameters: {
        if (userId != null) 'user_id': userId.toString(),
        if (resortId != null) 'resort_id': resortId.toString(),
        if (daily != null) 'daily': daily.toString(),
        if (selected_season != null) 'selected_season': selected_season,
        if (federation != null) 'federation': federation,
        if (page != null) 'page': page.toString(),
        if (pageSize != null) 'page_size': pageSize.toString(),
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

  Future<ApiResponse> fetchRankingData_crew_beta({
    int? crewId,  // 선택적으로 crewId를 받을 수 있도록 변경
    String? url,
    int? page,        // 웹 번호식 페이지네이션용 (beta 응답은 total_pages가 최상위)
    int? pageSize,
    String? searchQuery,   // 통합 검색어(닉네임/상태메세지/스키장/크루명/소개글)
  }) async {
    final params = <String, String>{
      if (crewId != null) 'crew_id': crewId.toString(),
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (searchQuery != null && searchQuery.isNotEmpty) 'search_query': searchQuery,
    };
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/list-crew-beta/').replace(
            queryParameters: params.isEmpty ? null : params,
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

  Future<ApiResponse> fetchSlopeRush(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/slope-rush/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return ApiResponse.success(decoded);
    } else {
      return ApiResponse.error(decoded);
    }
  }

  Future<ApiResponse> fetchSlopeRush_recordRoom(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/slope-rush-recordroom/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return ApiResponse.success(decoded);
    } else {
      return ApiResponse.error(decoded);
    }
  }

  Future<ApiResponse> createErrorLog(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/error-log/'),
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

  /// 위치 로그 일괄 전송
  Future<ApiResponse> createErrorLogBulk(List<Map<String, dynamic>> logs) async {
    final response = await http.post(
      Uri.parse('$baseUrl/error-log-bulk/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'logs': logs}),
    );

    if (response.statusCode == 201) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  /// 라이딩 기록 카드 조회
  Future<ApiResponse> fetchRidingRecordCard(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/riding-record-card/'),
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

  /// 시즌 기록 카드 조회
  Future<ApiResponse> fetchSeasonRidingCard(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/season-riding-card/'),
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

  /// 데일리 기록 카드 리스트 조회
  Future<ApiResponse> fetchDailyRidingCardList(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/daily-riding-card-list/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }








}

