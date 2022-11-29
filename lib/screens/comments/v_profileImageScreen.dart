import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileImagePage extends StatefulWidget {
  ProfileImagePage({Key? key, required this.CommentProfileUrl}) : super(key: key);

  var CommentProfileUrl;

  @override
  State<ProfileImagePage> createState() => _ProfileImagePageState();
}

class _ProfileImagePageState extends State<ProfileImagePage> {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ); // 상단 StatusBar 생성
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white, // Color for Android
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness:
            (Platform.isAndroid)
                ?Brightness.light
                :Brightness.dark //ios:dark, android:light
        ));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.close,
            color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0.0,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(widget.CommentProfileUrl != '')
          ExtendedImage.network(widget.CommentProfileUrl),
          if(widget.CommentProfileUrl == '')
            ExtendedImage.asset(
              'assets/imgs/profile/img_profile_default.png',
            ),
        ],
      ),
    );
  }
}
