import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class SnowballAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/ranking';


  //눈송이 좌표 지나가면 서버랑 파베에 등록하는 메서드
  Future<ApiResponse> createSnowballRecord(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-record/'),
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

  //랭킹탭 맨 위에 논송이 갯수 요약으로 보여주는 정보 가져오기
  Future<ApiResponse> fetchSnowballSummary(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-summary/'),
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

  //눈송이상점 홈에 필요한 모든 정보 불러오기
  Future<ApiResponse> fetchSnowballHome(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-home/'),
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

  //눈송이 아이템 구매
  Future<ApiResponse> purchaseSnowballItem(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-item-purchase/'),
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

  //내가 구매한 내역들어갈때
  Future<ApiResponse> fetchSnowballBuyRecords(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-buy-record/'),
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

  // 특정 user_id의 레코드 조회
  Future<ApiResponse> fetchUserSnowballRecords(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user-snowball-record/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }


}
