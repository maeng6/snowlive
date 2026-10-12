import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/core/api/ApiResponse.dart';

/// 시즌권(유료화) 결제 API. 웹 전용 결제(멀티플랫폼 모델).
/// 백엔드: /api/payment/season/ (status/prepare/confirm/history/refund).
class SeasonPassAPI {
  static const String baseUrl =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/payment/season';

  /// 현재 구독상태 (is_paid, 시즌권 정보, 가격, 시즌 종료일 등).
  Future<ApiResponse> fetchStatus({required int userId}) async {
    final uri = Uri.parse('$baseUrl/status/')
        .replace(queryParameters: {'user_id': userId.toString()});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }

  /// 주문 생성 → 결제창용 정보(client_key, order_id, amount, order_name, customer_key) 반환.
  Future<ApiResponse> prepare({required int userId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/prepare/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }

  /// 토스 리다이렉트 후 결제 승인 확정.
  /// userId는 선택(서버는 order_id로 SeasonPass를 찾아 승인하므로 세션 미복원이어도 동작).
  Future<ApiResponse> confirm({
    int? userId,
    required String paymentKey,
    required String orderId,
    required int amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/confirm/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (userId != null) 'user_id': userId,
        'paymentKey': paymentKey,
        'orderId': orderId,
        'amount': amount,
      }),
    );
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }

  /// 구매내역 (환불 가능 여부 포함).
  Future<ApiResponse> fetchHistory({required int userId}) async {
    final uri = Uri.parse('$baseUrl/history/')
        .replace(queryParameters: {'user_id': userId.toString()});
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }

  /// 환불 신청(RefundRequest 접수 — 실제 환불은 어드민 승인 시).
  Future<ApiResponse> requestRefund({
    required int userId,
    required String orderId,
    String reason = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/refund/request/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'order_id': orderId,
        'reason': reason,
      }),
    );
    if (response.statusCode == 200) {
      return ApiResponse.success(json.decode(utf8.decode(response.bodyBytes)));
    }
    return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
  }
}
