import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class UserAPI {
  static const String baseUrl = 'https://snowlive-api-c617725e2b78.herokuapp.com/api/accounts';

  Future<ApiResponse> getUserInfo(int user_id, {String? fcm_token}) async {
    final Map<String, String> queryParams = {
      'user_id': user_id.toString(),
    };
    if (fcm_token != null && fcm_token.isNotEmpty) {
      queryParams['fcm_token'] = fcm_token;
    }
    final Uri uri = Uri.parse('$baseUrl/get-user-info/').replace(
      queryParameters: queryParams,
    );

  print('📡 getUserInfo URL: $uri');
  print('📡 fcm_token 전달: ${fcm_token != null && fcm_token.isNotEmpty}');

  final response = await http.get(uri);

    if(response.statusCode==200){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> updateUserInfo(Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('https://snowlive-api-c617725e2b78.herokuapp.com/api/friend-detail-page/update-user/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if(response.statusCode==200){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }

  }

  Future<ApiResponse> blockUser(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('https://snowlive-api-c617725e2b78.herokuapp.com/api/community/block/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if(response.statusCode==201 || response.statusCode==400){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  // 사용자 차단 해제
  Future<ApiResponse<Map<String, dynamic>>> unblockUser(String userId,
      String blockUserId) async {
    final response = await http.delete(
      Uri.parse('https://snowlive-api-c617725e2b78.herokuapp.com/api/community/block-user/'),
      body: json.encode({'user_id': userId, 'block_user_id': blockUserId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(response.body));
    } else {
      return ApiResponse.error(json.decode(response.body));
    }
  }

}

