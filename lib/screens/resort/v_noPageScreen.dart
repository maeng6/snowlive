import 'package:flutter/material.dart';

class NoPageScreen extends StatelessWidget {
  const NoPageScreen({Key? key}) : super(key: key);

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
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  Center(
                    child: Image.asset('assets/imgs/icons/icon_nodata.png',
                      width: 72,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      '게시물이 존재하지않습니다.',
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
