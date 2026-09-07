import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SlmkScreen extends StatefulWidget {
  const SlmkScreen({Key? key}) : super(key: key);

  @override
  State<SlmkScreen> createState() => _SlmkScreenState();
}

class _SlmkScreenState extends State<SlmkScreen> {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  WebViewController? _controller;
  bool _isLoading = true;
  late String targetUrl;
  bool _webViewInitialized = false;
  final ValueNotifier<bool> isOpenNotifier = ValueNotifier(false);

  // 🛡️ 메모리 누수 방지: 스트림 구독 저장
  StreamSubscription<DocumentSnapshot>? _slmkSubscription;

  @override
  void initState() {
    super.initState();
    targetUrl = 'https://m.market-snowlive.kr/?user_id=${_userViewModel.user.user_id}';

    // 🛡️ 구독 저장하여 dispose에서 해제 가능하도록
    _slmkSubscription = FirebaseFirestore.instance.collection('slmk').doc('slmk').snapshots().listen((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      final open = data?['open'] == true;
      isOpenNotifier.value = open;
    });
  }

  @override
  void dispose() {
    // 🛡️ 메모리 누수 방지: 리소스 해제
    _slmkSubscription?.cancel();
    _slmkSubscription = null;
    isOpenNotifier.dispose();
    super.dispose();
  }

  Future<void> _initWebView() async {
    await _setupCookies();
    final tempController = WebViewController();

    tempController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SaveCookies',
        onMessageReceived: (message) async {
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
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            await tempController.runJavaScript("window.SaveCookies.postMessage(document.cookie);");
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(targetUrl));

    if (mounted) {
      setState(() {
        _controller = tempController;
        _webViewInitialized = true;
        _isLoading = true;
      });
    }
  }

  Future<void> _setupCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final cookieJson = prefs.getString('shopby_cookies');
    if (cookieJson != null) {
      final cookies = Map<String, String>.from(jsonDecode(cookieJson));
      final cookieManager = WebViewCookieManager();
      for (final entry in cookies.entries) {
        await cookieManager.setCookie(
          WebViewCookie(
            name: entry.key,
            value: entry.value,
            domain: Uri.parse(targetUrl).host,
          ),
        );
      }
    }
  }

  void _resetWebView() {
    if (_webViewInitialized || _controller != null) {
      setState(() {
        _controller = null;
        _webViewInitialized = false;
        _isLoading = true;
      });
    }
  }

  Widget _buildClosedScreen(String? imageUrl, Size size) {
    return Scaffold(
        backgroundColor: const Color(0xFF2C2C2C),
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.only(left: 8),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26, colorFilter: ColorFilter.mode(SDSColor.snowliveWhite, BlendMode.srcIn)),
              highlightColor: Colors.transparent,
            ),
          ),
          backgroundColor: const Color(0xFF2C2C2C),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          titleSpacing: 0,
        ),
        body: Center(
          child: imageUrl != null
              ? ExtendedImage.network(
            imageUrl,
            width: size.width,
            fit: BoxFit.cover,
            cache: true,
            loadStateChanged: (state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return Container(
                    width: double.infinity,
                    height: size.width + 60,
                    color: Color(0xFF2c2c2c),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: Color.fromRGBO(0, 0, 0, 0.3),
                      color: Colors.white,
                    ),
                  );
                case LoadState.failed:
                  return const Text(
                    '이미지를 불러오지 못했습니다.',
                    style: TextStyle(color: Colors.white),
                  );
                case LoadState.completed:
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: ExtendedRawImage(
                      image: state.extendedImageInfo?.image,
                      fit: BoxFit.cover,
                      width: size.width,
                    ),
                  ); // 기본 이미지 위젯 출력
              }
            },
          )
              : Container()
        )
    );
  }

  Widget _buildWebView(Size size) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _isLoading ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: _controller == null
                ? const SizedBox.shrink()
                : WebViewWidget(controller: _controller!),
          ),
        ),
        if (_isLoading)
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/imgs/imgs/img_splash_slmk.png',
              width: size.width,
              fit: BoxFit.cover,
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
                onPressed: () => Navigator.pop(context, 0),
                backgroundColor: const Color(0xFF2C2C2C),
                elevation: 3,
                label: Image.asset(
                  'assets/imgs/logos/snowliveLogo_main_new_blue.png',
                  color: Colors.white,
                  width: 64,
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Color(0xFF3D83ED),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 0);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2C2C2C),
        body: ValueListenableBuilder<bool>(
          valueListenable: isOpenNotifier,
          builder: (context, isOpen, _) {
            if (!isOpen) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _resetWebView();
              });

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('slmk').doc('slmk').get(),
                builder: (context, snapshot) {
                  final imageUrl = (snapshot.data?.data() as Map<String, dynamic>?)?['imageUrl'] as String?;
                  return _buildClosedScreen(imageUrl, size);
                },
              );
            }

            if (!_webViewInitialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_webViewInitialized) {
                  _initWebView();
                }
              });
              return const SizedBox.shrink();
            }

            return _buildWebView(size);
          },
        ),
      ),
    );
  }
}