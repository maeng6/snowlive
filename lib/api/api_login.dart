import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class LoginAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/accounts';

  Future<ApiResponse> registerUser(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if(response.statusCode==201){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
    print(response.statusCode);
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }

  }

  Future<ApiResponse> compareDeviceId(Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/compare-device-id/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if(response.statusCode==200 || response.statusCode ==201){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> findUser(Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/find-user/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if(response.statusCode==200 || response.statusCode ==201 ){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> checkDisplayName(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-display-name/'),
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

  Future<ApiResponse> deleteUser(String uid) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete-user/$uid/'),
    );

    if(response.statusCode==204){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }

  }
}




