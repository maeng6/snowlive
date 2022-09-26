import 'package:flutter/material.dart';
import 'package:snowlive3/controller/vm_loginController.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F4F6),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              iconTheme: IconThemeData(size: 26, color: Colors.black87),
              actions: [
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 13),
                    child: Image.asset(
                      'assets/imgs/icons/icon_snowLive_menu.png',
                      width: 26,
                      height: 26,
                    ),
                  ),
                  onTap: () {
                    LoginController().signOut();
                  },
                )
              ],
              centerTitle: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text('날씨'),
              ),
              backgroundColor: Color(0xFFF2F4F6),
              elevation: 0.0,
            )
          ],
        ),
      ),
      body: Container(
        color: Colors.amberAccent,
      ),
    );
  }
}
