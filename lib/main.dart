import 'dart:io';
import 'package:com.snowlive/firebase_options.dart';
import 'package:com.snowlive/util/pushNoitification.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_authcheck.dart';
import 'package:com.snowlive/viewmodel/vm_notificationController.dart';
import 'package:com.snowlive/viewmodel/vm_splashController.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/service/deep_link_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/view/v_splashScreen.dart';
import 'package:intl/date_symbol_data_local.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// 반드시 main 함수 외부에 작성합니다. (= 최상위 수준 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    print("Notification Received!");
  }
}

// 푸시 알림 메시지와 상호작용을 정의합니다.
Future<void> setupInteractedMessage() async {
  // 앱이 종료된 상태에서 열릴 때 getInitialMessage 호출
  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  // 앱이 백그라운드 상태일 때, 푸시 알림을 탭할 때 RemoteMessage 처리
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

// FCM에서 전송한 data를 처리합니다. /message 페이지로 이동하면서 해당 데이터를 화면에 보여줍니다.
void _handleMessage(RemoteMessage message) {
  // live_interrupted 타입은 NotificationController에서 처리
  final type = message.data['type'];
  if (type == 'live_interrupted') {
    return;
  }

  Future.delayed(const Duration(seconds: 1), () {
    // navigatorKey가 초기화되지 않은 경우 무시
    if (navigatorKey.currentState == null) {
      print('⚠️ Navigator가 아직 초기화되지 않음');
      return;
    }
    navigatorKey.currentState!.pushNamed("/message", arguments: message);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🛡️ 메모리 누수 방지: 이미지 캐시 크기 제한
  // - maximumSize: 최대 30개 이미지
  // - maximumSizeBytes: 최대 20MB
  // (백그라운드 전환 시 메모리 경고 감소)
  PaintingBinding.instance.imageCache.maximumSize = 30;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 20 * 1024 * 1024; // 20MB

  await initializeDateFormatting('ko', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  Get.put(UserViewModel(), permanent: true);
  Get.put(DeepLinkService(), permanent: true);
  Get.put(AuthCheckViewModel(), permanent: true);

  HttpOverrides.global = MyHttpOverrides();

  // DI + splashUrl preload
  await Get.putAsync(() async {
    final controller = SplashController();
    await controller.loadLocalSplashUrl();
    return controller;
  }, permanent: true);

  Get.put(FriendDetailViewModel());

  // 푸시 알림 초기화 (순서대로 await하여 권한 요청 오버레이 충돌 방지)
  await PushNotification.init();

  // NotificationController를 먼저 초기화
  final notificationController = Get.put(NotificationController(), permanent: true);

  // 로컬 알림 초기화 (탭 콜백 연결)
  await PushNotification.localNotiInit(
    onNotificationTap: (payload) {
      notificationController.handleLocalNotificationPayload(payload);
    },
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  setupInteractedMessage();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 앱 라이프사이클 변경 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 🛡️ 백그라운드 진입 시 캐시 클리어 제거
    // iOS에서 포그라운드 복귀 시 이미지가 보라색으로 깨지는 문제 해결
    // 메모리가 필요하면 didHaveMemoryPressure에서 시스템이 알려줌
  }

  /// 시스템 메모리 경고 시 공격적인 캐시 정리 (iOS/Android 모두 호출됨)
  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    print('⚠️ 메모리 경고 - 캐시 전체 정리');
    _clearImageCaches();

    // 메모리 경고 시 캐시 크기 임시 축소
    PaintingBinding.instance.imageCache.maximumSize = 30;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 20 << 20; // 20MB
  }

  /// 이미지 캐시 정리 (공통)
  void _clearImageCaches() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    clearMemoryImageCache(); // ExtendedImage 캐시
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: AppRoutes.pages,
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const SplashScreenWrapper(),
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
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
          child: child!,
        );
      },
      home: const SplashScreenWrapper(), // ⬅️ 핵심 진입점
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

//TODO : 네이티브 Splah 생성/삭제 커맨드
//flutter pub run flutter_native_splash:create
//flutter pub run flutter_native_splash:remove
