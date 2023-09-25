import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:com.snowlive/controller/vm_loadingPage.dart';
class SplashScreen extends StatelessWidget {
  final String imageUrl;
  SplashScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AnimatedSplashScreen(
        curve: Curves.easeInCirc,
        splashTransition: SplashTransition.fadeTransition,
        splashIconSize: double.maxFinite,
        duration: 1500,
        splash: ExtendedImage.network(
          imageUrl,
          fit: BoxFit.fill,
          enableMemoryCache: true,
              ),
        nextScreen: LoadingPage()
    );
  }
}