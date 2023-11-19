import 'package:flutter/material.dart';

class Ranking_CommingSoon_Screen extends StatelessWidget {
  const Ranking_CommingSoon_Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Color(0xFF1A2634),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
              color: Color(0xFFFFFFFF),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0.0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    Center(
                      child: Image.network('https://i.esdrop.com/d/f/yytYSNBROy/kjkIX3Eg96.png',
                        width: _size.width - 40,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
