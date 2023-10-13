import 'dart:io';
import 'package:com.snowlive/controller/vm_loginController.dart';
import 'package:com.snowlive/controller/vm_splashController.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_notificationController.dart';
import 'package:com.snowlive/screens/v_splashScreen.dart';

import 'controller/vm_allUserDocsController.dart';
import 'controller/vm_bottomTabBarController.dart';
import 'controller/vm_friendsCommentController.dart';
import 'controller/vm_getDateTimeController.dart';
import 'controller/vm_liveCrewModelController.dart';
import 'controller/vm_mainHomeController.dart';
import 'controller/vm_refreshController.dart';
import 'controller/vm_resortModelController.dart';
import 'controller/vm_seasonController.dart';
import 'controller/vm_timeStampController.dart';
import 'controller/vm_urlLauncherController.dart';
import 'controller/vm_userModelController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  await Firebase.initializeApp();
  HttpOverrides.global = MyHttpOverrides();

  // Dependency Injection
  Get.put(PageControllerManager(),permanent: true);
  Get.put(BottomTabBarController(),permanent: true);
  Get.put(ResortModelController(), permanent: true);
  Get.put(UserModelController(), permanent: true);
  Get.put(GetDateTimeController(), permanent: true);
  Get.put(TimeStampController(), permanent: true);
  Get.put(FriendsCommentModelController(), permanent: true);
  Get.put(MainHomeController(), permanent: true);
  Get.put(LiveCrewModelController(), permanent: true);
  Get.put(SeasonController(), permanent: true);
  Get.put(UrlLauncherController(), permanent: true);
  Get.put(RefreshController(),permanent: true);
  Get.put(AllUserDocsController(),permanent: true);
  Get.put(LoginController(),permanent: true);



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
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  //TODO: Dependency Injection********************************************

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingSplashImgUrl = _splashController.getSplashUrl();
    _allUserDocsController.getAllUserDocs();
  }

  @override
  Widget build(BuildContext context) {



    return GetMaterialApp(
      initialBinding: BindingsBuilder.put(() => NotificationController(),permanent: true),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      ],
      theme: ThemeData(
        fontFamily: 'Spoqa Han Sans Neo',
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            size: 30,
            color: Colors.black
          ),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Spoqa Han Sans Neo',
            fontWeight: FontWeight.w800,
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