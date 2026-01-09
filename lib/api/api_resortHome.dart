import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class ResortHomeAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/resort-home/';

  Future<ApiResponse> fetchResortHomeData(int user_id) async {
    Uri uri = Uri.parse('$baseUrl').replace(
        queryParameters: {
          'user_id': user_id.toString(),
        });

    var response = await http.get(uri);

    if(response.statusCode==200){
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.success(data);
    } else{
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> fetchResortHomeData_refresh(int user_id) async {
    final Uri uri = Uri.parse('$baseUrl').replace(
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

  /// 오픈채팅 메시지 전송
  Future<ApiResponse> createChat({
    required int uid,
    required String text,
    required String chatId,
  }) async {
    final Uri uri = Uri.parse('${baseUrl}chat/create/');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'uid': uid,
        'text': text,
        'chatId': chatId,
      }),
    );

    final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return ApiResponse.success(data);
    } else {
      return ApiResponse.error(data, statusCode: response.statusCode);
    }
  }
}


