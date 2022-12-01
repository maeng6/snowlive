import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import '../../controller/vm_loginController.dart';
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
  //TODO: Dependency Injection********************************************

  final FirebaseAuth auth = FirebaseAuth.instance;
  List<bool?> _isChecked = List<bool?>.filled(14, false);
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
    bool? isSelected=_isChecked.contains(true);

    return Scaffold(backgroundColor: Colors.white,
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
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '',
              style: GoogleFonts.notoSans(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w900,
                  fontSize: 23),
            ),
          ),
        ),
      ),
      body: Padding(
        padding:  EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16, bottom: _statusBarSize),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    '자주가는 리조트를 \n선택해 주세요.',
                    style:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '자주가는 리조트는 1개만 선택할 수 있습니다.',
                style: TextStyle(
                  color: Color(0xff949494),
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 0),
                  shrinkWrap: true,
                    itemCount: 13,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          buildCheckboxListTile(index),

                          Divider(
                            height: 20,
                            thickness: 0.5,
                          )
                        ],
                      );
                    }),
              ),
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    width: _size.width,
                    height: 88,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if(isSelected) {
                          CustomFullScreenDialog.showDialog();
                          await _loginController.createUserDoc(0);
                          await userModelController
                              .updateNickname(widget.getNickname);
                          await userModelController
                              .updateProfileImageUrl(widget.getProfileImageUrl);
                          await userModelController.updateFavoriteResort(
                              favoriteResort);
                          await userModelController.updateInstantResort(
                              favoriteResort);
                          print('즐겨찾는 리조트 업뎃완료');
                          await resortModelController.getSelectedResort(
                              userModelController.favoriteResort!);
                          CustomFullScreenDialog.cancelDialog();
                          Get.offAll(() => MainHome());
                        }else{
                          null;
                        }
                      },
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
                          backgroundColor:
                          (isSelected)
                          ? Color(0xff377EEA)
                        : Color(0xffDEDEDE))
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  CheckboxListTile buildCheckboxListTile(int index) {
    return CheckboxListTile(
      title: Text('${resortNameList[index]}', style: TextStyle(fontSize: 16),),
      activeColor: Color(0xff377EEA),
      selected: _isSelected[index]!,
      selectedTileColor: Color(0xff377EEA),
      value: _isChecked[index],
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      onChanged: (bool? value) {
        setState(() {
          _isChecked = List<bool?>.filled(14, false);
          _isSelected = List<bool?>.filled(14, false);
          _isChecked[index] = value;
          _isSelected[index] = value;
          if (value == false) {
            favoriteResort = null;
          } else {
            favoriteResort = index;
          }
        });
      },
    );
  }


  ListTile buildListTile(int index) {
    return ListTile(
      title: Text('${resortNameList[index]}', style: TextStyle(fontSize: 16),),
      selected: _isSelected[index]!,

    );
  }
}


