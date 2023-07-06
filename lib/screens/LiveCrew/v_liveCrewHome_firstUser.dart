import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/screens/LiveCrew/CreateOnboarding/v_FirstPage_createCrew.dart';
import 'package:snowlive3/screens/LiveCrew/v_liveCrewHome.dart';
import 'package:snowlive3/screens/LiveCrew/v_searchCrewPage.dart';
import 'package:snowlive3/screens/LiveCrew/setting/v_setting_delegation.dart';
import 'package:snowlive3/screens/more/friend/v_friendDetailPage.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';
import '../comments/v_profileImageScreen.dart';

class LiveCrewHome_firstUser extends StatelessWidget {
  LiveCrewHome_firstUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection**************************************************
    LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
    UserModelController _userModelController = Get.find<UserModelController>();
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
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: (){
                  Get.to(()=> SearchCrewPage());
                },
                child: Text('가입하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFffffff),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(
                        color: Color(0xFFDEDEDE))
                ),),
              ElevatedButton(
                onPressed: (){
                  Get.to(()=>FirstPage_createCrew());
                },
                child: Text('만들기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFffffff),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(
                        color: Color(0xFFDEDEDE))
                ),),
              ElevatedButton(
                onPressed: (){
                  Get.to(()=>LiveCrewHome());
                },
                child: Text('둘러보기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFffffff),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(
                        color: Color(0xFFDEDEDE))
                ),),
            ],
          )
        ],
      ),
    );
  }
}
