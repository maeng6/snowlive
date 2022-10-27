import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class WebPage extends StatefulWidget {
  WebPage({this.url});

   String? url;

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {

  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {


    final double _statusBarSize = MediaQuery.of(context).padding.top;
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

    return Scaffold(backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '',
              style: GoogleFonts.notoSans(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w900,
                  fontSize: 23),
            ),
          ),
        ),
      ),

      body:Padding(
        padding:  EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16, bottom: _statusBarSize),
        child: WebView(
          initialUrl: '${widget.url}',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );

  }
}

