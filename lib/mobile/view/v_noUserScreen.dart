import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoUserScreen extends StatelessWidget {
  const NoUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26),
            highlightColor: Colors.transparent,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  Center(
                    child: Image.asset('assets/imgs/icons/icon_friend_nouser.png',
                      width: 72,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      '이미 탈퇴한 사용자입니다',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
