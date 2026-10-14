import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:get/get.dart';

/// 웹 상세 라우트 진입의 **공용 스택 정책**.
///
/// - **다른 화면 → 이 상세** 진입 → **push**(`toNamed`) → 뒤로가기로 그 화면 복귀.
/// - **같은 라우트 → 같은 라우트**(상세→상세 꼬리물기, 예: 중고거래 추천상품, 프로필→
///   프로필) → **replace**(`offNamed`) → 스택에 그 라우트는 **항상 1개만** 유지한다.
///   꼬리를 물고 계속 들어가도 무한히 쌓이지 않고, 뒤로가기는 처음 진입했던 바깥
///   화면으로 한 번에 돌아간다.
///
/// 판별은 [Get.currentRoute]의 경로명(쿼리 제외)과 대상 경로명을 비교한다. 프로필
/// 미리보기 팝업 등은 라우트가 아니라 Overlay라, currentRoute는 팝업 아래의 실제
/// 페이지를 가리켜 "지금 같은 상세 위에 있는가" 판별이 정확하다.
/// **화면을 옮겼다**는 신호. 라우트명이 그대로인 교체(프로필→프로필)까지 잡히므로
/// 라우트 문자열 변화만 보는 것보다 확실하다.
///
/// 셸이 이걸 구독해 모바일 메뉴 패널을 닫는다 — 패널은 라우트가 아니라 셸의 Stack
/// 위층이라, 패널 위에서 뜬 팝업이 화면을 바꿔도 패널이 그대로 덮고 있었다.
final RxInt webRouteNavigationTick = 0.obs;

void pushWebRoute(String route) {
  final targetName = route.split('?').first;
  final currentName = Get.currentRoute.split('?').first;
  if (currentName == targetName) {
    // 같은 라우트끼리 교체 — GetPage preventDuplicates와 무관하게 확실히 교체되도록
    // 파라미터로도 false를 준다.
    Get.offNamed(route, preventDuplicates: false);
  } else {
    Get.toNamed(route);
  }
  webRouteNavigationTick.value++;
}

/// 프로필 상세 진입(모든 "프로필 보러가기"·크루멤버·랭킹 모달이 이걸 쓴다).
/// [pushWebRoute] 정책을 그대로 따른다 — 프로필→프로필은 스택에 1개만 유지.
void pushWebProfileRoute(int userId, {String? extraQuery}) {
  final base = '${WebRoutes.userProfile}?id=$userId';
  pushWebRoute(extraQuery == null ? base : '$base&$extraQuery');
}
