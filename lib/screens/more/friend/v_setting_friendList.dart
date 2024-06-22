import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_imageController.dart';
import 'package:com.snowlive/screens/more/friend/v_repoList.dart';
import '../../../controller/vm_userModelController.dart';

class Setting_friendList extends StatelessWidget {
  const Setting_friendList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //TODO: Dependency Injection**************************************************
    Get.put(ImageController(), permanent: true);
    //TODO: Dependency Injection**************************************************

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
      body: ListView(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            minVerticalPadding: 20,
            onTap: () {
              Get.to(()=>RepoList());
            },
            title: Text(
              '차단목록',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF111111)),
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
