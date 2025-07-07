
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class SnowballAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/ranking';

  Future<http.Response> createSnowballRecord(Map<String, dynamic> body) async {
    print('눈송이 요청 바디: ${jsonEncode(body)}');
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-record/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    print('눈송이 Response Code: ${response.statusCode}');
    print('눈송이 Response Body: ${json.decode(utf8.decode(response.bodyBytes))}');
    return response;
  }

  Future<ApiResponse> purchaseSnowballItem(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-item-purchase/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    return response.statusCode == 201 ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  Future<ApiResponse> fetchSnowballSummary(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-summary/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    return response.statusCode == 200 ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  Future<ApiResponse> fetchSnowballHome(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-home/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    return response.statusCode == 200 ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  Future<ApiResponse> fetchSnowballBuyRecords(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-buy-record/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    return response.statusCode == 200 ? ApiResponse.success(data) : ApiResponse.error(data);
  }

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
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> fetchSnowballMissionStatus(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-mission-status/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    return response.statusCode == 200 ? ApiResponse.success(data) : ApiResponse.error(data);
  }

  Future<ApiResponse> createSnowballMissionRecord(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-mission-complete/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    return response.statusCode == 201 || response.statusCode == 200
        ? ApiResponse.success(data)
        : ApiResponse.error(data);
  }

  Future<ApiResponse> receiveSnowballBuyRecord(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/snowball-item-receive/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    return response.statusCode == 200 ? ApiResponse.success(data) : ApiResponse.error(data);
  }
}
