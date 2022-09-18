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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('SNOWLIVE',
          style: Theme.of(context).appBarTheme.titleTextStyle,),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              },
            icon: Icon(Icons.arrow_back,
            color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body:WebView(
          initialUrl: '${widget.url}',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );

  }
}
