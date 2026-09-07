import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/mobile/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FriendSettingView extends StatelessWidget {
  const FriendSettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

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
