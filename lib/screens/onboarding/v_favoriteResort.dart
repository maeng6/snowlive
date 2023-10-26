import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/controller/vm_resortModelController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/screens/v_MainHome.dart';
import '../../controller/vm_allUserDocsController.dart';
import '../../controller/vm_bottomTabBarController.dart';
import '../../controller/vm_loginController.dart';
import '../../controller/vm_myRankingController.dart';
import '../../controller/vm_notificationController.dart';
import '../../model/m_resortModel.dart';
import '../../widget/w_fullScreenDialog.dart';

class FavoriteResort extends StatefulWidget {
  FavoriteResort({Key? key,required this.getNickname, required this.getProfileImageUrl}) : super(key: key);

  var getNickname;
  String? getProfileImageUrl;

  @override
  State<FavoriteResort> createState() => _FavoriteResortState();
}

class _FavoriteResortState extends State<FavoriteResort> {

  //TODO: Dependency Injection********************************************
  UserModelController userModelController = Get.find<UserModelController>();
  ResortModelController resortModelController = Get.find<ResortModelController>();
  LoginController _loginController = Get.find<LoginController>();
  BottomTabBarController _bottomTabBarController = Get.find<BottomTabBarController>();
  NotificationController _notificationController = Get.find<NotificationController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  MyRankingController _myRankingController = Get.find<MyRankingController>();
  //TODO: Dependency Injection********************************************

  final FirebaseAuth auth = FirebaseAuth.instance;
  List<bool?> _isSelected = List<bool?>.filled(14, false);
  int? favoriteResort;
  final FirebaseFirestore ref = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ); // 상단 StatusBar 생성
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white, // Color for Android
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness:
            (Platform.isAndroid)
                ?Brightness.light
                :Brightness.dark //ios:dark, android:light
        ));
    bool? isSelected= _isSelected.contains(true);

    return Stack(
      children: [
        Scaffold(backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
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
              centerTitle: false,
              titleSpacing: 0,
            ),
          ),
          body: Padding(
            padding:  EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16),
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text(
                        '자주가는 스키장을\n선택해 주세요.',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3),),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    '자주가는 스키장은 1개만 선택할 수 있습니다.',
                    style: TextStyle(
                        color: Color(0xff949494),
                        fontSize: 13,
                        height: 1.5
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      shrinkWrap: true,
                        itemCount: 13,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              buildListTile(index),
                              if (index != 12)
                              Divider(
                                height: 20,
                                thickness: 0.5,
                              )
                            ],
                          );
                        }),
                  ),
                  SizedBox(
                    height: 130,
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            color: Colors.white,
            width: _size.width,
            height: 40,
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0,
          left: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(left : 16, right: 16, bottom: 16),
              child: ElevatedButton(
                  onPressed: isSelected ? () async {
                      CustomFullScreenDialog.showDialog();
                      await _loginController.createUserDoc(index: 0, token: _notificationController.deviceToken);
                      await FlutterSecureStorage()
                          .write(key: 'uid', value: auth.currentUser!.uid);
                      await userModelController
                          .updateNickname(widget.getNickname);
                      await userModelController
                          .updateProfileImageUrl(widget.getProfileImageUrl);
                      await userModelController.updateFavoriteResort(
                          favoriteResort);
                      await userModelController.updateInstantResort(
                          favoriteResort);
                      await userModelController.updateResortNickname(
                          favoriteResort);
                      print('즐겨찾는 리조트 업뎃완료');
                      await resortModelController.getSelectedResort(
                          userModelController.favoriteResort!);
                      await _allUserDocsController.getAllUserDocs();
                      _myRankingController.resetMyRankingData();
                      CustomFullScreenDialog.cancelDialog();
                      Get.offAll(() => MainHome(uid: userModelController.uid));

                  }: null,
                  child: Text(
                    '가입완료',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                      elevation: 0,
                      splashFactory: InkRipple.splashFactory,
                      minimumSize: Size(1000, 56),
                      backgroundColor: isSelected
                          ? Color(0xff377EEA)
                          : Color(0xffDEDEDE))
              ),
            ),
          ),
        ),
      ],
    );
  }

  ListTile buildListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      trailing: _isSelected[index]!
          ? Image.asset(
        'assets/imgs/icons/icon_check_filled.png', // 체크된 상태의 이미지 어셋 경로
        width: 24,
        height: 24,
      )
          : Image.asset(
        'assets/imgs/icons/icon_check_unfilled.png', // 언체크된 상태의 이미지 어셋 경로
        width: 24,
        height: 24,
      ),
      title: Text(
        '${resortNameList[index]}',
        style: TextStyle(fontSize: 16),
      ),
      selected: _isSelected[index]!,
      onTap: () {
        setState(() {
          _isSelected = List<bool?>.filled(14, false);
          _isSelected[index] = true;
          favoriteResort = index;
        });
      },
    );
  }

}


