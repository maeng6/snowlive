import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snowlive3/controller/vm_loadingPage.dart';
class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AnimatedSplashScreen(
        curve: Curves.easeInCirc,
        splashTransition: SplashTransition.fadeTransition,
        splashIconSize: double.maxFinite,
        duration: 1500,
        //TODO: Dependency Injection********************************************
        splash: Image.asset(
                'assets/imgs/splash_screen/splash1.png',
          fit: BoxFit.fitHeight,
              ),
        nextScreen: LoadingPage()
    );
  }
}