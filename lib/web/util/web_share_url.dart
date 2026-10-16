/// 공유 링크용 정식(배포) 도메인. 어느 호스트(localhost/QA .web.app)에서 접속하든
/// 공유·복사 링크는 항상 이 도메인으로 고정한다 → 지저분한 QA url이 공유에 안 섞인다.
/// 프로덕션은 snowlive.kr로 직접 배포하므로 이 값과 일치한다.
const String kWebCanonicalOrigin = 'https://snowlive.kr';

/// 현재 페이지(또는 주어진 [uri])의 **오리진만** 배포 도메인으로 바꾼 공유 링크.
/// 경로·쿼리·프래그먼트(#라우트)는 그대로 보존한다.
/// 예) https://snowlive-web-qa.web.app/#/fleamarket-detail?id=7
///  → https://snowlive.kr/#/fleamarket-detail?id=7
String canonicalShareUrl([Uri? uri]) {
  final u = uri ?? Uri.base;
  final full = u.toString();
  // u.origin = scheme://host[:port]. 그 뒤(path?query#fragment)만 살려 붙인다.
  final rest = full.length >= u.origin.length ? full.substring(u.origin.length) : '';
  return '$kWebCanonicalOrigin$rest';
}

/// 해시 라우트 딥링크용. [hashRoute]는 '/community-detail?id=3' 처럼 **앞에 슬래시**가
/// 붙은 라우트+쿼리. 결과: https://snowlive.kr/#/community-detail?id=3
String canonicalHashUrl(String hashRoute) => '$kWebCanonicalOrigin/#$hashRoute';

/// 카카오 등 링크 미리보기(OG)를 위한 공유 링크 오리진.
/// 공유 링크는 항상 **배포 도메인(snowlive.kr)** 으로 노출한다 → 카톡에 붙여도 snowlive.kr로 보인다.
/// 정적 호스팅(snowlive.kr)은 게시글/유저별 OG 태그를 서버에서 못 넣으므로,
/// Firebase 호스팅이 `/share/...` 를 백엔드(app.snowlive.kr)로 302 리다이렉트하고,
/// 백엔드가 OG(크롤러용)를 서빙한 뒤 사람은 실제 게시글/프로필 페이지로 보낸다.
const String kShareLinkOrigin = kWebCanonicalOrigin;

/// 중고거래 게시글 공유 링크. 미리보기: 대표사진 + '글제목 | 스라 중고거래' + 내용.
String fleamarketShareLink(int fleaId) => '$kShareLinkOrigin/share/flea/$fleaId';

/// 유저 프로필 공유 링크. 미리보기: 프로필사진(OG 가운데) + '닉네임 | 스라 프로필' + 상태메시지.
String profileShareLink(int userId) => '$kShareLinkOrigin/share/user/$userId';

/// 커뮤니티 게시글 공유 링크. 미리보기: 대표사진 + '글제목 | 스라 커뮤니티' + 내용.
String communityShareLink(int communityId) => '$kShareLinkOrigin/share/community/$communityId';

/// 라이브톡 공유 링크. 미리보기: 첨부사진 + '닉네임님의 라이브톡 | 스라' + 내용.
String livetalkShareLink(int livetalkId) => '$kShareLinkOrigin/share/livetalk/$livetalkId';

/// 크루 홈 공유 링크. 미리보기: 크루로고(OG 가운데) + '크루명 | 스라 라이브크루' + 소개글.
String crewShareLink(int crewId) => '$kShareLinkOrigin/share/crew/$crewId';
