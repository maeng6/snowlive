import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class RankingAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/ranking';

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

  Future<ApiResponse> addCheckPoint(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add-check-point/'),
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

  Future<ApiResponse> respawn(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/respawn/'),
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

  Future<ApiResponse> fetchRankingData_indiv({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url,
  }) async {
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/list-indiv/').replace(
      queryParameters: {
        'user_id': userId.toString(),
        if (resortId != null) 'resort_id': resortId.toString(),
        if (daily != null) 'daily': daily.toString(),
        if (season != null) 'season': season,
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
    required int userId,
    String? url,
  }) async {
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/list-indiv-beta/');

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
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url,
  }) async {
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/list-crew/').replace(
      queryParameters: {
        'user_id': userId.toString(),
        if (resortId != null) 'resort_id': resortId.toString(),
        if (daily != null) 'daily': daily.toString(),
        if (season != null) 'season': season,
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
    required int userId,
    String? url,
  }) async {
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/list-crew-beta/');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }












}

