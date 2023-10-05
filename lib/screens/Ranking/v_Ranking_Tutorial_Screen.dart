import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/vm_timeStampController.dart';
import '../../controller/vm_urlLauncherController.dart';
import '../v_webPage.dart';

class RankingTutorialPage extends StatefulWidget {
  const RankingTutorialPage({Key? key}) : super(key: key);

  @override
  State<RankingTutorialPage> createState() => _RankingTutorialPageState();
}

class _RankingTutorialPageState extends State<RankingTutorialPage> {

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          title: Text('랭킹 소개',
            style: TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
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
          elevation: 0.0,
          centerTitle: true,
          titleSpacing: 0,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child:
          Image.asset('assets/imgs/imgs/img_ranking_tutorial.png',
            scale: 4,
            width: _size.width,
          )
        ),
      )



    );
  }
}
