import 'package:get/get.dart';

/// GNB(사이드바/드로어) 항목의 활성(볼드) 상태를 반응형으로 갱신하기 위한 현재 라우트 신호.
/// GnbNavRow는 Navigator보다 상위(WebAppShell)에 고정돼 있어 라우트가 바뀌어도
/// 저절로 다시 빌드되지 않는다 — Get.currentRoute를 build()에서 직접 읽으면
/// 최초 진입 시점 라우트에 항상 멈춰 있는 문제가 있었다. main_web.dart의
/// GetMaterialApp.routingCallback에서 이 값을 갱신해주면 GnbNavRow가 Obx로
/// 구독해서 탭 이동 시 볼드 표시가 즉시 따라온다.
final RxString currentRouteWeb = Get.currentRoute.obs;
