/// 모바일/테스트용 무동작 stub (웹이 아닐 때).
class TossRedirectParams {
  final String? paymentKey;
  final String? orderId;
  final int? amount;
  const TossRedirectParams({this.paymentKey, this.orderId, this.amount});
  bool get isValid => paymentKey != null && orderId != null && amount != null;
}

/// 결제창 호출(리다이렉트). stub은 '웹 전용' 메시지 반환.
Future<String?> startTossPayment({
  required String clientKey,
  required String customerKey,
  required int amount,
  required String orderId,
  required String orderName,
}) async {
  return '결제는 웹에서만 가능합니다.';
}

/// 리다이렉트 복귀 시 URL에서 결제 결과 파라미터 읽기. stub은 빈 값.
TossRedirectParams readTossRedirectParams() => const TossRedirectParams();

/// 결제 실패 리다이렉트 시 code/message 읽기. stub은 null.
Map<String, String> readTossFailParams() => const {};

/// 성공/실패 복귀 라우트 기준 origin (successUrl/failUrl 생성용). stub은 빈 문자열.
String get webOrigin => '';
