import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class ForestParkAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/forest-park';

  // 참가 여부 확인
  Future<ApiResponse> checkParticipant(String userId, int eventDate) async {
    final response = await http.get(
      Uri.parse('$baseUrl/participant/check/?user_id=$userId&event_date=$eventDate'),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 || response.statusCode == 404) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error(data);
    }
  }

  // 참가 등록
  Future<ApiResponse> registerParticipant(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/participant/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error(data);
    }
  }

  // 퀴즈 상세 가져오기
  Future<ApiResponse> fetchQuizDetail(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quiz/detail/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> submitQuizAnswer(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quiz/answer/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('🔍 상태코드: ${response.statusCode}');
    print('📥 원본 응답: ${response.body}');

    final data = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 || response.statusCode == 409 || response.statusCode == 208) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error({
        'message': '오류가 발생했습니다.',
        'result': '',
      });
    }
  }


  // 교환소 아이템 목록 조회
  Future<ApiResponse> fetchLeafItems(int eventDate) async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaf/item/list/?event_date=$eventDate'),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));
    return ApiResponse.success(data);
  }

  // 아이템 교환 시도
  Future<ApiResponse> tryBuyItem(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leaf/item/buy/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error(data);
    }
  }

  // 교환 내역 조회
  Future<ApiResponse> fetchBuyRecords(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaf/buy/list/?user_id=$userId'),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));
    return ApiResponse.success(data);
  }

  // 잔여 나뭇잎 현황 조회
  Future<ApiResponse> fetchLeafRemain(String userId, int eventDate) async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaf/remain/?user_id=$userId&event_date=$eventDate'),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));
    return ApiResponse.success(data);
  }

  // 수령 확인
  Future<ApiResponse> checkReceiveItem(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leaf/item/receive-check/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error(data);
    }
  }
}
