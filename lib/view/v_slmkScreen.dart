import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SlmkScreen extends StatefulWidget {
  const SlmkScreen({Key? key}) : super(key: key);

  @override
  State<SlmkScreen> createState() => _SlmkScreenState();
}

class _SlmkScreenState extends State<SlmkScreen> {
  late WebViewController _controller;
  bool _isLoading = true; // ✅ 스플래시 보여줄지 여부

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 0); // 홈 탭으로 복귀
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2C2C2C),
        body: Stack(
          children: [
            /// ✅ WebView (SafeArea 내부)
            AnimatedOpacity(
              opacity: _isLoading ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child: WebView(
                  initialUrl: 'https://m.market-snowlive.kr',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (controller) => _controller = controller,
                  onPageFinished: (_) async {
                    await Future.delayed(const Duration(seconds: 1)); // ✅ 최소 1초 유지
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
              ),
            ),

            /// ✅ 로고 스플래시 (전체 화면 덮기)
            if (_isLoading)
              Container(
                color: const Color(0xFF2C2C2C),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 스노우라이브 로고 (assets에 이미지가 있어야 합니다)
                    Image.asset(
                      'assets/imgs/logos/slmkLogo_black.png',
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

            /// ✅ 'APP' 버튼 (WebView 위에 항상 위치)
            if (!_isLoading)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.76,
                right: 16,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    backgroundColor: SDSColor.snowliveBlue,
                    elevation: 0,
                    shape: const CircleBorder(),
                    child: const Text(
                      'APP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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
