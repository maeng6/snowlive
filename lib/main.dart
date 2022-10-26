import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/v_splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  await Firebase.initializeApp();
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSansKR',
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            size: 30,
            color: Colors.black
          ),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'NotoSansKR',
            fontWeight: FontWeight.w600,
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
        home: SplashScreen()
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
