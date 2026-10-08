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
