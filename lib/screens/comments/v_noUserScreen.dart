import 'package:flutter/material.dart';

class NoUserScreen extends StatelessWidget {
  const NoUserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Icon(Icons.no_accounts_outlined,
                size: 70,
                color: Color(0xFF949494),
                ),
                SizedBox(height: 10,),
                Text('이미 탈퇴한 사용자입니다')
              ],
            ),
          ],
        ),
      ),
    );
  }
}
