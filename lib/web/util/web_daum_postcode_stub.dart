/// [web_daum_postcode_html.dart]의 **비웹 대체** — 테스트(VM)·모바일 빌드에서
/// `dart:html`이 컴파일 체인에 들어오지 않게 한다. 실제로 불리면 안 된다.
class DaumAddress {
  final String zonecode; // 우편번호
  final String address; // 도로명 주소(없으면 지번)
  const DaumAddress(this.zonecode, this.address);
}

Future<DaumAddress?> openDaumPostcode() async {
  throw UnsupportedError('다음 우편번호 검색은 웹에서만 동작해요.');
}
