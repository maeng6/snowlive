import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/core/api/ApiResponse.dart';

/// 크루홈 집계 API. 상단(5리스트)·중단(스키장별+4리스트)·하단(공개 크루톡)을
/// 한 번에 받아온다. 게스트(비로그인)도 호출 가능하다.
class CrewHomeAPI {
  static const String baseUrl = 'https://snowlive-api-c617725e2b78.herokuapp.com/api/crew';

  /// GET /api/crew/home/  — 파라미터 없음(게스트 허용).
  Future<ApiResponse> fetchCrewHome() async {
    final response = await http.get(Uri.parse('$baseUrl/home/'));

    final decoded = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return ApiResponse.success(decoded as Map<String, dynamic>);
    } else {
      return ApiResponse.error(decoded);
    }
  }
}
