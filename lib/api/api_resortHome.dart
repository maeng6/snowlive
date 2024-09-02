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
}


