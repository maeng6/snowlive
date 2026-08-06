/// 웹에서 새 탭으로 여는 외부 링크 모음.
///
/// 약관 URL은 모바일 뷰모델(`lib/mobile/viewmodel/auth/vm_tos.dart`)에만 하드코딩돼
/// 있었고 스토어 링크는 코드에 아예 없었다. 여러 화면에서 쓰이므로 한곳에 모은다.
library;

const String kTermsOfServiceUrl =
    'https://sites.google.com/view/snowlive-termsofservice/%ED%99%88';

const String kPrivacyPolicyUrl =
    'https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88';

const String kAppStoreUrlAndroid =
    'https://play.google.com/store/apps/details?id=com.snowlive';

const String kAppStoreUrlIos =
    'https://apps.apple.com/kr/app/%EC%8A%A4%EB%85%B8%EC%9A%B0%EB%9D%BC%EC%9D%B4%EB%B8%8C/id6444235991';

/// 가입 완료 모달에 띄울 QR 목록.
///
/// QR 하나에는 URL 하나만 들어가고, **QR을 스캔하는 기기는 화면을 띄운 기기와 다르다**
/// — 그래서 Flutter 쪽에서 UA로 분기해 하나만 띄우는 방법은 통하지 않는다
/// (아이폰으로 스캔했는데 Play 스토어가 열리던 문제). **스토어별로 QR을 따로 띄워서
/// 쓰는 사람이 고르게 한다.**
const List<({String label, String url})> kAppDownloadQrTargets = [
  (label: 'App Store', url: kAppStoreUrlIos),
  (label: 'Google Play', url: kAppStoreUrlAndroid),
];
