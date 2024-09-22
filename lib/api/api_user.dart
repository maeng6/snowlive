import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class UserAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/accounts';

  Future<ApiResponse> getUserInfo(int user_id) async {
    final Uri uri = Uri.parse('$baseUrl/get-user-info/').replace(
      queryParameters: {
        'user_id': user_id.toString(),
      });

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
      Uri.parse('https://snowlive-api-0eab29705c9f.herokuapp.com/api/friend-detail-page/update-user/'),
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
      Uri.parse('https://snowlive-api-0eab29705c9f.herokuapp.com/api/community/block/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if(response.statusCode==201){
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
      Uri.parse('https://snowlive-api-0eab29705c9f.herokuapp.com/api/community/block-user/'),
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

