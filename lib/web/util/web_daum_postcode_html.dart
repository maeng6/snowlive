import 'dart:async';
import 'dart:html' as html;

/// 다음(카카오) 우편번호 검색 결과.
class DaumAddress {
  final String zonecode; // 우편번호
  final String address; // 도로명 주소(없으면 지번)
  const DaumAddress(this.zonecode, this.address);
}

/// 다음 우편번호 검색을 **팝업 창**(`/daum_postcode.html`)으로 열고, 선택 결과를
/// postMessage로 받아 반환한다. dart:html만 써서 js_interop 버전 이슈를 피한다.
/// 팝업을 그냥 닫으면 null.
Future<DaumAddress?> openDaumPostcode() async {
  final completer = Completer<DaumAddress?>();
  final popup = html.window.open(
    '/daum_postcode.html', 'daum_addr', 'width=500,height=600,resizable=yes,scrollbars=yes');

  StreamSubscription<html.MessageEvent>? sub;
  Timer? poll;
  void finish(DaumAddress? v) {
    if (completer.isCompleted) return;
    sub?.cancel();
    poll?.cancel();
    completer.complete(v);
  }

  sub = html.window.onMessage.listen((event) {
    final data = event.data;
    if (data is Map && data['type'] == 'daum_addr') {
      finish(DaumAddress(
        (data['zonecode'] ?? '').toString(),
        (data['address'] ?? '').toString(),
      ));
    }
  });

  // 선택 없이 팝업을 닫으면 null로 마무리.
  poll = Timer.periodic(const Duration(milliseconds: 500), (t) {
    if (popup.closed ?? true) finish(null);
  });

  return completer.future;
}
