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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
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
