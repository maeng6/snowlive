/// 웹에서 새 탭으로 여는 외부 링크 모음.
///
/// 약관 URL은 모바일 뷰모델(`lib/mobile/viewmodel/auth/vm_tos.dart`)에만 하드코딩돼
/// 있었고 스토어 링크는 코드에 아예 없었다. 여러 화면에서 쓰이므로 한곳에 모은다.
///
/// ⚠️ 화면마다 따로 적지 말 것 — 푸터가 스토어 URL을 직접 적었다가 **둘 다 404**로
/// 나간 적이 있다(앱 ID `id1602642173`, 패키지 `com.snowlive.snowlive`로 잘못 적힘).
/// 정답은 앱과 같은 `id6444235991` / `com.snowlive`.
library;

// 약관·개인정보는 자사 도메인(snowlive.kr)에 정적 페이지로 둔다 — Google OAuth
// 브랜딩 인증은 이 링크들이 '소유·인증한 도메인'에 있어야 통과되기 때문
// (구글사이트 sites.google.com은 소유 인증 불가).
const String kTermsOfServiceUrl = 'https://snowlive.kr/terms.html';

const String kPrivacyPolicyUrl = 'https://snowlive.kr/privacy.html';

const String kLocationTermsUrl =
    'https://sites.google.com/view/134creativelablocationinfo/%ED%99%88';

const String kAppStoreUrlAndroid =
    'https://play.google.com/store/apps/details?id=com.snowlive';

const String kAppStoreUrlIos =
    'https://apps.apple.com/kr/app/%EC%8A%A4%EB%85%B8%EC%9A%B0%EB%9D%BC%EC%9D%B4%EB%B8%8C/id6444235991';

/// 공식 인스타그램(앱 리조트홈 `스노우라이브 소식은 인스타그램에서!` 배너와 같은 계정).
/// ⚠️ 앱 `스노우라이브 소개` 화면의 `instagram.com/snowlive.134`는 **없는 계정**이다
/// (2026-10-11 확인: "Profile을 이용할 수 없습니다") — 그 주소를 쓰지 말 것.
const String kInstagramUrl = 'https://www.instagram.com/snowlive_official/';

/// 카카오톡 채널 1:1 채팅(앱 `스노우라이브 소개 > 카카오 채널`과 같은 링크).
const String kKakaoChannelUrl = 'https://pf.kakao.com/_LxnDdG/';

/// 가입 완료 모달에 띄울 QR 목록.
///
/// QR 하나에는 URL 하나만 들어가고, **QR을 스캔하는 기기는 화면을 띄운 기기와 다르다**
/// — 그래서 Flutter 쪽에서 UA로 분기해 하나만 띄우는 방법은 통하지 않는다
/// (아이폰으로 스캔했는데 Play 스토어가 열리던 문제). **스토어별로 QR을 따로 띄워서
/// 쓰는 사람이 고르게 한다.**
const List<({String label, String url})> kAppDownloadQrTargets = [
  (label: '앱스토어', url: kAppStoreUrlIos),
  (label: '구글플레이', url: kAppStoreUrlAndroid),
];
