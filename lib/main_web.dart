import 'package:com.snowlive/firebase_options.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_web_shell.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(UserViewModel(), permanent: true);
  // 게스트 우선 설계: initialRoute는 그대로 두고, 백그라운드에서 조용히
  // 기존 Firebase 세션 여부만 확인해 GNB의 로그인 상태 표시에 반영한다.
  Get.put(AuthCheckViewModelWeb(), permanent: true);

  runApp(const SnowliveWebApp());
}

class SnowliveWebApp extends StatelessWidget {
  const SnowliveWebApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '스노우라이브 - 중고거래',
      getPages: WebRoutes.pages,
      initialRoute: WebRoutes.fleamarketList,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      theme: ThemeData(
        primaryColor: SDSColor.snowliveBlue,
        fontFamily: 'Pretendard',
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          // WebAppShell(GNB)이 라우트 Navigator를 감싸는 구조라, GNB까지 덮는
          // 진짜 풀스크린 오버레이(이미지 뷰어 등)는 라우트 Navigator보다 상위에
          // 있는 이 Overlay를 통해서만 열 수 있다 (Overlay.of(rootOverlay: true)로 접근).
          child: Overlay(
            initialEntries: [
              OverlayEntry(builder: (_) => WebAppShell(child: child!)),
            ],
          ),
        );
      },
    );
  }
}
