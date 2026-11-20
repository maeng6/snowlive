import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/core/api/ApiResponse.dart';

/// 인앱 평점/피드백(2단계) 백엔드 연동.
/// - eligibility: 지금 요청해도 되는지 서버가 판정(가입14일↑ AND 세션3회↑, 쿨다운60일, 좋아요이력 영구제외)
/// - prompt: 1단계 다이얼로그 노출 시 1건 생성 → review_prompt_id
/// - respond: 응답/피드백/별점 기록
class ReviewAPI {
  static const String baseUrl =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/review';

  Future<ApiResponse> eligibility(int userId) async {
    final uri = Uri.parse('$baseUrl/eligibility/')
        .replace(queryParameters: {'user_id': userId.toString()});
    try {
      final response = await http.get(uri);
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) return ApiResponse.success(data);
      return ApiResponse.error(data);
    } catch (e) {
      return ApiResponse.error({'eligible': false, 'reason': 'network_error'});
    }
  }

  /// 1단계 노출 기록. 성공 시 data['review_prompt_id'] 반환.
  Future<ApiResponse> prompt(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/prompt/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) return ApiResponse.success(data);
      return ApiResponse.error(data);
    } catch (e) {
      return ApiResponse.error({'ok': false, 'error': 'network_error'});
    }
  }

  /// 응답 기록(좋아요/아쉬워요/닫음, 스토어호출여부, 피드백, 별점).
  Future<ApiResponse> respond(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/respond/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 200) return ApiResponse.success(data);
      return ApiResponse.error(data);
    } catch (e) {
      return ApiResponse.error({'ok': false, 'error': 'network_error'});
    }
  }
}
