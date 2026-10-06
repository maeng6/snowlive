import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/web_page_title.dart';
import 'package:flutter_test/flutter_test.dart';

/// 브라우저 탭 제목 — 화면별 `화면명 | 스노우라이브`.
void main() {
  test('홈은 브랜드만', () {
    expect(webPageTitle(WebRoutes.home), '스노우라이브');
  });

  test('화면명 | 브랜드, 쿼리는 무시', () {
    expect(webPageTitle(WebRoutes.fleamarketList), '중고거래 | 스노우라이브');
    expect(webPageTitle('${WebRoutes.fleamarketDetail}?id=1365'), '중고거래 상품 | 스노우라이브');
    expect(webPageTitle('${WebRoutes.userProfile}?id=1&tab=guestbook'), '프로필 | 스노우라이브');
    expect(webPageTitle('${WebRoutes.crewApplications}?id=334'), '가입 신청 목록 | 스노우라이브');
    expect(webPageTitle(WebRoutes.alarm), '알림 | 스노우라이브');
  });

  test('모르는 경로·빈 경로는 브랜드만', () {
    expect(webPageTitle('/nope'), '스노우라이브');
    expect(webPageTitle(''), '스노우라이브');
  });

  test('등록된 모든 라우트에 화면명이 있다 (새 라우트를 추가하면 여기서 걸린다)', () {
    final missing = WebRoutes.pages
        .map((p) => p.name)
        .where((name) => !kWebPageNames.containsKey(name))
        .toList();
    expect(missing, isEmpty, reason: 'web_page_title.dart의 kWebPageNames에 추가할 것');
  });
}
