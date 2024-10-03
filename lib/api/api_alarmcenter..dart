import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

class  AlarmCenterAPI {

  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/alarm-center';

// AlarmCenterAPI에서 URL을 사용한 요청 처리
  Future<ApiResponse> fetchAlarmCenterList({
    required int userId,
    int? alarminfoId,
    String? url, // URL을 받아서 처리
  }) async {
    // URL이 있으면 해당 URL을 사용, 없으면 기본 URL에 queryParameter 추가
    final uri = url != null
        ? Uri.parse(url)
        : Uri.parse('$baseUrl/').replace(
      queryParameters: {
        'user_id': userId.toString(),
        if (alarminfoId != null) 'alarminfo_id': alarminfoId.toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> deleteAlarmCenter(int alarmCenterId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$alarmCenterId/delete/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      return ApiResponse.success({"message": "AlarmCenter deleted successfully."});
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }

  Future<ApiResponse> updateAlarmCenter(int alarmCenterId, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$alarmCenterId/update/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.success(data);
    } else {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return ApiResponse.error(data);
    }
  }













}
