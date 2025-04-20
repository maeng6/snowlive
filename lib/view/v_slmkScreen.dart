import 'dart:convert';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SlmkScreen extends StatefulWidget {
  const SlmkScreen({Key? key}) : super(key: key);

  @override
  State<SlmkScreen> createState() => _SlmkScreenState();
}

class _SlmkScreenState extends State<SlmkScreen> {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  WebViewController? _controller; // ✅ nullable
  bool _isLoading = true;
  late String targetUrl; // ✅ 여기 late로 변경

  @override
  void initState() {
    super.initState();
    print('[SlmkScreen] initState 호출됨');
    targetUrl = 'https://m.market-snowlive.kr/?user_id=${_userViewModel.user.user_id}';
    _initWebView();
  }

  Future<void> _initWebView() async {
    await _setupCookies();

    final tempController = WebViewController();

    tempController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SaveCookies',
        onMessageReceived: (JavaScriptMessage message) async {
          print('[쿠키저장] document.cookie 수신됨: ${message.message}');
          final raw = message.message;
          final cookieMap = <String, String>{};
          for (var cookie in raw.split(';')) {
            var parts = cookie.trim().split('=');
            if (parts.length == 2) {
              cookieMap[parts[0]] = parts[1];
            }
          }
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('shopby_cookies', jsonEncode(cookieMap));
          print('[쿠키저장] 저장 완료: $cookieMap');
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            print('[WebView] 페이지 로딩 완료: $url');
            await tempController.runJavaScript(
                "window.SaveCookies.postMessage(document.cookie);"
            );
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              print('[WebView] 스플래시 숨김');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(targetUrl));

    if (mounted) {
      setState(() {
        _controller = tempController; // ✅ 여기서 안전하게 할당
      });
    }
  }

  Future<void> _setupCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final cookieJson = prefs.getString('shopby_cookies');
    if (cookieJson != null) {
      print('[쿠키복원] 저장된 쿠키 있음. 적용 시작');
      final cookies = Map<String, String>.from(jsonDecode(cookieJson));
      final cookieManager = WebViewCookieManager();
      for (final entry in cookies.entries) {
        print('[쿠키복원] ${entry.key} = ${entry.value}');
        await cookieManager.setCookie(
          WebViewCookie(
            name: entry.key,
            value: entry.value,
            domain: Uri.parse(targetUrl).host,
          ),
        );
      }
      print('[쿠키복원] 쿠키 적용 완료');
    } else {
      print('[쿠키복원] 저장된 쿠키 없음');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        print('[뒤로가기] SlmkScreen 닫힘');
        Navigator.pop(context, 0);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2C2C2C),
        body: Stack(
          children: [
            AnimatedOpacity(
              opacity: _isLoading ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child: _controller == null
                    ? const SizedBox.shrink()
                    : WebViewWidget(controller: _controller!), // ✅ null 체크
              ),
            ),
            if (_isLoading)
              Container(
                alignment: Alignment.center,
                child: ClipRect(
                  child: Image.asset(
                    'assets/imgs/imgs/img_splash_slmk.png',
                    width: _size.width,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (!_isLoading)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 54,
                child: SizedBox(
                  width: 82,
                  height: 26,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      print('[버튼] APP 버튼 눌림 - SlmkScreen 닫기');
                      Navigator.pop(context, 0);
                    },
                    backgroundColor: Color(0xFF2C2C2C),
                    elevation: 3,
                    label: Image.asset(
                      'assets/imgs/logos/snowliveLogo_main_new_blue.png',
                      color: Colors.white,
                      width: 64,
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // ✅ BorderRadius
                      side: BorderSide(
                        color: Color(0xFF3D83ED),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
