import 'dart:io';
import 'package:com.snowlive/controller/alarm/vm_alarmCenterController.dart';
import 'package:com.snowlive/controller/bulletin/vm_bulletinLostController.dart';
import 'package:com.snowlive/controller/login/vm_loginController.dart';
import 'package:com.snowlive/controller/ranking/vm_myCrewRankingController.dart';
import 'package:com.snowlive/controller/splash/vm_splashController.dart';
import 'package:com.snowlive/controller/alarm/vm_streamController_alarmCenter.dart';
import 'package:com.snowlive/controller/banner/vm_streamController_banner.dart';
import 'package:com.snowlive/controller/fleaMarket/vm_streamController_fleaMarket.dart';
import 'package:com.snowlive/controller/liveCrew/vm_streamController_liveCrew.dart';
import 'package:com.snowlive/controller/moreTab/vm_streamController_moreTab.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_authcheck.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/login/vm_notificationController.dart';
import 'package:com.snowlive/screens/v_splashScreen.dart';
import 'controller/liveCrew/vm_allCrewDocsController.dart';
import 'controller/user/vm_allUserDocsController.dart';
import 'controller/public/vm_bottomTabBarController.dart';
import 'controller/bulletin/vm_bulletinCrewController.dart';
import 'controller/bulletin/vm_bulletinEventController.dart';
import 'controller/bulletin/vm_bulletinFreeController.dart';
import 'controller/bulletin/vm_bulletinRoomController.dart';
import 'controller/fleaMarket/vm_fleaMarketController.dart';
import 'controller/friends/vm_friendsCommentController.dart';
import 'controller/public/vm_getDateTimeController.dart';
import 'controller/liveCrew/vm_liveCrewModelController.dart';
import 'controller/ranking/vm_liveMapController.dart';
import 'controller/public/vm_loadingController.dart';
import 'controller/ranking/vm_myRankingController.dart';
import 'controller/ranking/vm_rankingTierModelController.dart';
import 'controller/public/vm_refreshController.dart';
import 'controller/resort/vm_resortModelController.dart';
import 'controller/public/vm_limitController.dart';
import 'controller/bulletin/vm_streamController_bulletin.dart';
import 'controller/friends/vm_streamController_friend.dart';
import 'controller/ranking/vm_streamController_ranking.dart';
import 'controller/home/vm_streamController_resortHome.dart';
import 'controller/public/vm_timeStampController.dart';
import 'controller/public/vm_urlLauncherController.dart';
import 'controller/user/vm_userModelController.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  await Firebase.initializeApp();
  HttpOverrides.global = MyHttpOverrides();

  // Dependency Injection
  Get.put(UserViewModel(), permanent: true);

  Get.put(AuthCheckViewModel());
  Get.put(PageControllerManager(),permanent: true);
  Get.put(NotificationController(),permanent: true);
  Get.put(limitController(), permanent: true);
  Get.put(UserModelController(), permanent: true);
  Get.put(ResortModelController(), permanent: true);
  Get.put(GetDateTimeController(), permanent: true);
  Get.put(TimeStampController(), permanent: true);
  Get.put(FriendsCommentModelController(), permanent: true);
  Get.put(LoadingController(),permanent: true);
  Get.put(RankingTierModelController(), permanent: true);
  Get.put(LiveCrewModelController(), permanent: true);
  Get.put(LiveMapController(), permanent: true);
  Get.put(UrlLauncherController(), permanent: true);
  Get.put(MyRankingController(),permanent: true);
  Get.put(MyCrewRankingController(), permanent: true);
  Get.put(RefreshController(),permanent: true);
  Get.put(AllUserDocsController(),permanent: true);
  Get.put(AllCrewDocsController(),permanent: true);
  Get.put(LoginController(),permanent: true);
  Get.put(AlarmCenterController(),permanent: true);
  Get.put(BulletinRoomModelController(), permanent: true);
  Get.put(BulletinCrewModelController(), permanent: true);
  Get.put(BulletinFreeModelController(), permanent: true);
  Get.put(BulletinEventModelController(), permanent: true);
  Get.put(BulletinLostModelController(), permanent: true);
  Get.put(FleaModelController(), permanent: true);
  Get.put(StreamController_ResortHome(), permanent: true);
  Get.put(StreamController_AlarmCenter(), permanent: true);
  Get.put(StreamController_fleaMarket(), permanent: true);
  Get.put(StreamController_ranking(), permanent: true);
  Get.put(StreamController_Banner(), permanent: true);
  Get.put(StreamController_Friend(), permanent: true);
  Get.put(StreamController_Bulletin(), permanent: true);
  Get.put(StreamController_MoreTab(), permanent: true);
  Get.put(StreamController_liveCrew(), permanent: true);
  Get.put(BottomTabBarController(),permanent: true);


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
  AllCrewDocsController _allCrewDocsController = Get.find<AllCrewDocsController>();
  //TODO: Dependency Injection********************************************

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadingSplashImgUrl = _splashController.getSplashUrl();
    _allUserDocsController.getAllUserDocs();
    _allCrewDocsController.getAllCrewDocs();
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