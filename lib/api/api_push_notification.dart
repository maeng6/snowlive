import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/api/ApiResponse.dart';

class PushNotificationAPI {
  static const String baseUrl = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api';

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  dynamic _decodeBody(http.Response r) {
    return json.decode(utf8.decode(r.bodyBytes));
  }

  /// FCM 푸시 알림 전송
  /// POST /push/send/
  /// body: { token, title, body }
  Future<ApiResponse> sendPushNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/push/send/'),
        headers: _headers,
        body: jsonEncode({
          'token': token,
          'title': title,
          'body': body,
        }),
      );
      final data = _decodeBody(r);
      return (r.statusCode == 200)
          ? ApiResponse.success(data)
          : ApiResponse.error(data);
    } catch (e) {
      return ApiResponse.error('Push notification failed: $e');
    }
  }

  /// 여러 사용자에게 푸시 알림 전송 (배치)
  /// tokens: FCM 토큰 리스트
  Future<List<ApiResponse>> sendPushNotificationBatch({
    required List<String> tokens,
    required String title,
    required String body,
  }) async {
    final List<ApiResponse> results = [];

    for (final token in tokens) {
      final response = await sendPushNotification(
        token: token,
        title: title,
        body: body,
      );
      results.add(response);
    }

    return results;
  }

  /// 라이브 중단 알림 전송 (앱 kill 감지 시 서버에서 호출)
  /// 사용자에게 "앱이 종료되었습니다" 알림
  Future<ApiResponse> sendLiveInterruptedNotification({
    required String token,
    String? resortName,
  }) async {
    return sendPushNotification(
      token: token,
      title: '라이브가 중단되었어요',
      body: resortName != null
          ? '$resortName에서 라이딩을 계속하려면 앱을 다시 열어주세요.'
          : '라이딩을 계속하려면 앱을 다시 열어주세요.',
    );
  }
}
