import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendSettingView extends StatelessWidget {
  const FriendSettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

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
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        toolbarHeight: 44,

      ),
      body: ListView(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            minVerticalPadding: 20,
            onTap: () async{
              await
              Get.toNamed(AppRoutes.friendBlockList);
            },
            title: Text(
              '차단목록',
              style: SDSTextStyle.bold.copyWith(
                  fontSize: 15,
                  color: SDSColor.gray900),
            ),
            trailing: Image.asset(
              'assets/imgs/icons/icon_arrow_g.png',
              height: 24,
              width: 24,
            ),
          ),
        ],
      ),
    );
  }
}
