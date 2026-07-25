import 'package:com.snowlive/web/routes/bindings_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketDetail_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketHome_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketUpdate_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketUpload_web.dart';
import 'package:com.snowlive/web/view/login/v_login_web.dart';
import 'package:com.snowlive/web/view/onboarding/v_onboarding_web.dart';
import 'package:com.snowlive/web/view/ranking/v_rankingHome_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebRoutes {
  static const fleamarketList = '/fleamarket';
  static const fleamarketSearch = '/fleamarket/search';
  static const fleamarketDetail = '/fleamarket/detail';
  static const fleamarketUpload = '/fleamarket/upload';
  static const fleamarketUpdate = '/fleamarket/update';
  static const fleamarketAlert = '/fleamarket/alert';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const ranking = '/ranking';

  static final pages = [
    GetPage(
      name: fleamarketList,
      page: () => const FleamarketHomeView(),
      binding: WebFleamarketListBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginViewWeb(),
      binding: WebLoginBinding(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingViewWeb(),
      binding: WebOnboardingBinding(),
    ),
    GetPage(
      name: fleamarketSearch,
      page: () => const _PlaceholderPage(title: '중고거래 검색'),
      binding: WebFleamarketSearchBinding(),
    ),
    GetPage(
      name: fleamarketDetail,
      page: () => const FleamarketDetailView(),
      binding: WebFleamarketDetailBinding(),
    ),
    GetPage(
      name: fleamarketUpload,
      page: () => const FleamarketUploadViewWeb(),
      binding: WebFleamarketUploadBinding(),
    ),
    GetPage(
      name: fleamarketUpdate,
      page: () => const FleamarketUpdateViewWeb(),
      binding: WebFleamarketUpdateBinding(),
    ),
    GetPage(
      name: fleamarketAlert,
      page: () => const _PlaceholderPage(title: '키워드 알림 설정'),
      binding: WebFleamarketAlertBinding(),
    ),
    GetPage(
      name: ranking,
      page: () => const RankingHomeViewWeb(),
      binding: WebRankingListBinding(),
    ),
  ];
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\n(웹 뷰 구현 예정)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
