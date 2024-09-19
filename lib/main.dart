import 'dart:io';
import 'package:com.snowlive/viewmodel/vm_splashController.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
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


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,  // 알림 메시지 표시
    badge: true,  // 앱 아이콘에 뱃지 표시
    sound: true,  // 알림 사운드
  );


  HttpOverrides.global = MyHttpOverrides();

  // Dependency Injection
  Get.put(UserViewModel(), permanent: true);

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

  //TODO: Dependency Injection********************************************
  SplashController _splashController = Get.put(SplashController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingSplashImgUrl = _splashController.getSplashUrl();
  }

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
          future: loadingSplashImgUrl,
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text('에러 발생: ${snapshot.error}'));
              }
              splashUrl = _splashController.url;
              return SplashScreen(imageUrl: splashUrl);
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
//z