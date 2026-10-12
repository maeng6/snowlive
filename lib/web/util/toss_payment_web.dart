import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// 전역 TossPayments(clientKey) 생성자 함수 바인딩 (index.html의 v1/payment SDK).
@JS('TossPayments')
external _TossPaymentsApi _tossPayments(String clientKey);

extension type _TossPaymentsApi._(JSObject _) implements JSObject {
  external JSPromise requestPayment(String method, JSAny options);
}

class TossRedirectParams {
  final String? paymentKey;
  final String? orderId;
  final int? amount;
  const TossRedirectParams({this.paymentKey, this.orderId, this.amount});
  bool get isValid => paymentKey != null && orderId != null && amount != null;
}

String get webOrigin => web.window.location.origin;

/// 결제창 호출(표준 Payment SDK, 카드 리다이렉트).
/// 성공 시 successUrl로, 실패/취소 시 failUrl로 토스가 리다이렉트한다.
/// 리다이렉트 전에 취소/에러가 나면 메시지를 반환, 그 외엔 null(리다이렉트됨).
Future<String?> startTossPayment({
  required String clientKey,
  required String customerKey,
  required int amount,
  required String orderId,
  required String orderName,
}) async {
  try {
    final origin = web.window.location.origin;
    final toss = _tossPayments(clientKey);
    final opts = <String, dynamic>{
      'amount': amount,
      'orderId': orderId,
      'orderName': orderName,
      'customerKey': customerKey,
      'successUrl': '$origin/#/season-pass-success',
      'failUrl': '$origin/#/season-pass-fail',
    }.jsify() as JSAny;
    await toss.requestPayment('카드', opts).toDart;
    return null;
  } catch (e) {
    final name = e is web.DOMException ? e.name : '';
    if (name == 'AbortError') return '결제를 취소했습니다.';
    return '결제를 진행할 수 없습니다. ($e)';
  }
}

String _queryString() {
  final loc = web.window.location;
  final search = loc.search;
  if (search.isNotEmpty && search.contains('=')) return search;
  // 해시 라우팅: '#/season-pass-success?paymentKey=...'
  final hash = loc.hash;
  final qi = hash.indexOf('?');
  if (qi >= 0) return hash.substring(qi);
  return '';
}

Map<String, String> _params() {
  final q = _queryString();
  if (q.isEmpty) return const {};
  return Uri.splitQueryString(q.startsWith('?') ? q.substring(1) : q);
}

TossRedirectParams readTossRedirectParams() {
  final p = _params();
  final amt = p['amount'];
  return TossRedirectParams(
    paymentKey: p['paymentKey'],
    orderId: p['orderId'],
    amount: amt != null ? int.tryParse(amt) : null,
  );
}

Map<String, String> readTossFailParams() => _params();
