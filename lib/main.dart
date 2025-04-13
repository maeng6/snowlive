import 'dart:convert';
import 'dart:io';
import 'package:com.snowlive/firebase_options.dart';
import 'package:com.snowlive/util/pushNoitification.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_authcheck.dart';
import 'package:com.snowlive/viewmodel/vm_notificationController.dart';
import 'package:com.snowlive/viewmodel/vm_splashController.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/view/v_splashScreen.dart';
import 'package:intl/date_symbol_data_local.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    print("Notification Received!");
  }
}

Future<void> setupInteractedMessage() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

void _handleMessage(RemoteMessage message) {
  Future.delayed(const Duration(seconds: 1), () {
    navigatorKey.currentState!.pushNamed("/message", arguments: message);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  HttpOverrides.global = MyHttpOverrides();

  await Get.put(UserViewModel(), permanent: true);
  await Get.put(FriendDetailViewModel());
  await Get.put(NotificationController(), permanent: true);
  await Get.put(AuthCheckViewModel(), permanent: true);
  await Get.put(SplashController(), permanent: true);

  PushNotification.init();
  PushNotification.localNotiInit();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    if (message.notification != null) {
      PushNotification.showSimpleNotification(
        title: message.notification!.title!,
        body: message.notification!.body!,
        payload: payloadData,
      );
    }
  });

  setupInteractedMessage();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SplashController _splashController = Get.find<SplashController>();

  String splashUrl = '';
  bool gotoMainHome = false;
  bool fadeDone = false;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: AppRoutes.pages,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      ],
      theme: ThemeData(
        primaryColor: SDSColor.snowliveBlue,
        fontFamily: 'Pretendard',
        textTheme: TextTheme(
          displayLarge: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w800),
          displayMedium: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w300),
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(size: 30, color: Colors.black),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: FutureBuilder(
        future: _splashController.getSplashUrlandGotoMainHome(),
        builder: (context, snapshot) {
          /// 초기 에셋 → 네트워크 이미지로 페이드 전환 구간
          if (snapshot.connectionState != ConnectionState.done &&
              _splashController.isLoadingUrl == false &&
              !fadeDone) {
            splashUrl = _splashController.url;

            return Stack(
              key: const ValueKey('fadeInStack'),
              children: [
                ExtendedImage.asset(
                  'assets/imgs/splash_screen/splash_logo.png',
                  fit: BoxFit.cover,
                  enableMemoryCache: true,
                  width: double.infinity,
                  height: double.infinity,
                ),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  onEnd: () {
                    setState(() {
                      fadeDone = true;
                    });
                  },
                  child: Image.network(
                    splashUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ],
            );
          }

          /// 로딩 완료 후: 네트워크 이미지 고정 + SplashScreen → 전환 애니메이션 없음
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text('에러 발생'));
            }

            splashUrl = _splashController.url;
            gotoMainHome = _splashController.gotoMainHome;

            return Stack(
              key: const ValueKey('finalStack'),
              children: [
                Image.network(
                  splashUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                SplashScreen(gotoMainHome: gotoMainHome),
              ],
            );
          }

          /// 최초 진입 시: 에셋 이미지 고정
          return ExtendedImage.asset(
            'assets/imgs/splash_screen/splash_logo.png',
            key: const ValueKey('initialAsset'),
            fit: BoxFit.cover,
            enableMemoryCache: true,
            width: double.infinity,
            height: double.infinity,
          );
        },
      ),

    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
