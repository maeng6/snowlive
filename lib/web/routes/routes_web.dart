import 'package:com.snowlive/web/routes/bindings_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketHome_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebRoutes {
  static const fleamarketList = '/fleamarket';
  static const fleamarketSearch = '/fleamarket/search';
  static const fleamarketDetail = '/fleamarket/detail';
  static const fleamarketUpload = '/fleamarket/upload';
  static const fleamarketUpdate = '/fleamarket/update';
  static const fleamarketAlert = '/fleamarket/alert';

  static final pages = [
    GetPage(
      name: fleamarketList,
      page: () => const FleamarketHomeView(),
      binding: WebFleamarketListBinding(),
    ),
    GetPage(
      name: fleamarketSearch,
      page: () => const _PlaceholderPage(title: '중고거래 검색'),
      binding: WebFleamarketSearchBinding(),
    ),
    GetPage(
      name: fleamarketDetail,
      page: () => const _PlaceholderPage(title: '중고거래 상세'),
      binding: WebFleamarketDetailBinding(),
    ),
    GetPage(
      name: fleamarketUpload,
      page: () => const _PlaceholderPage(title: '중고거래 등록'),
      binding: WebFleamarketUploadBinding(),
    ),
    GetPage(
      name: fleamarketUpdate,
      page: () => const _PlaceholderPage(title: '중고거래 수정'),
      binding: WebFleamarketUpdateBinding(),
    ),
    GetPage(
      name: fleamarketAlert,
      page: () => const _PlaceholderPage(title: '키워드 알림 설정'),
      binding: WebFleamarketAlertBinding(),
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
