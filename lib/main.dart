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
  Future.delayed(const Duration(seconds: 1), () {
    navigatorKey.currentState!.pushNamed("/message", arguments: message);
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  HttpOverrides.global = MyHttpOverrides();
  // Dependency Injection
  await Get.put(UserViewModel(), permanent: true);
  await Get.put(FriendDetailViewModel());
  await Get.put(NotificationController(),permanent: true);
  await Get.put(AuthCheckViewModel(), permanent: true);
  await Get.put(SplashController(),permanent: true);

  // FCM 푸시 알림 관련 초기화
  PushNotification.init();
  // flutter_local_notifications 패키지 관련 초기화
  PushNotification.localNotiInit();
  // 백그라운드 알림 수신 리스너
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 포그라운드 알림 수신 리스너
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print('Got a message in foreground');
    if (message.notification != null) {
      // flutter_local_notifications 패키지 사용
      PushNotification.showSimpleNotification(
        title: message.notification!.title!,
        body: message.notification!.body!,
        payload: payloadData,
      );
    }
  });

  // 메시지 상호작용 함수 호출
  setupInteractedMessage();



  runApp(MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void>? loadingSplashImgUrl;
  String splashUrl='';
  bool gotoMainHome = false;

  //TODO: Dependency Injection********************************************
  SplashController _splashController = Get.find<SplashController>();

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
          primaryColorLight: SDSColor.blue50,
          primaryColorDark: SDSColor.blue700,
          textTheme: TextTheme(
            displayLarge: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w800),
            displayMedium: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w300),
          ),
          fontFamily: 'Pretendard',
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
                size: 30,
                color: Colors.black
            ),
            centerTitle: true,
            titleTextStyle: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 20
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.transparent
          ),
        ),
        home: FutureBuilder(
          future: _splashController.getSplashUrlandGotoMainHome(),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text('에러 발생: ${snapshot.error}'));
              }
              splashUrl = _splashController.url;
              gotoMainHome = _splashController.gotoMainHome;
              return SplashScreen(imageUrl: splashUrl, gotoMainHome: gotoMainHome,);
            } else {
              return ExtendedImage.asset(
                'assets/imgs/splash_screen/splash_logo.png',
                fit: BoxFit.fill,
                enableMemoryCache: true,
              );
            }
          },
        )
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
