import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_mainHomeController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import '../../../model/m_resortModel.dart';
import '../../../widget/w_fullScreenDialog.dart';
import '../v_liveCrewHome.dart';

class CrewFavoriteResort extends StatefulWidget {
  CrewFavoriteResort({Key? key,required this.crewName, required this.CrewImageUrl, required this.crewColor}) : super(key: key);

  var crewName;
  var crewColor;
  String? CrewImageUrl;

  @override
  State<CrewFavoriteResort> createState() => _CrewFavoriteResortState();
}

class _CrewFavoriteResortState extends State<CrewFavoriteResort> {


  //TODO: Dependency Injection********************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController resortModelController = Get.find<ResortModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  MainHomeController _mainHomeController = Get.find<MainHomeController>();
  //TODO: Dependency Injection********************************************

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    baseResort = _userModelController.favoriteResort!;
    _isChecked[_userModelController.favoriteResort!] = true;
    _isSelected[_userModelController.favoriteResort!] = true;
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  List<bool?> _isChecked = List<bool?>.filled(14, false);
  List<bool?> _isSelected = List<bool?>.filled(14, false);
  int? baseResort;
  String? crewID;
  final FirebaseFirestore ref = FirebaseFirestore.instance;

  String getResortName(String resortNickname) {
    switch (resortNickname) {
      case '곤지암':
        return '곤지암리조트';
      case '무주':
        return '무주덕유산리조트';
      case '비발디':
        return '비발디파크';
      case '에덴벨리':
        return '에덴벨리리조트';
      case '강촌':
        return '엘리시안강촌';
      case '오크밸리':
        return '오크밸리리조트';
      case '오투':
        return '오투리조트';
      case '용평':
        return '용평리조트';
      case '웰리힐리':
        return '웰리힐리파크';
      case '지산':
        return '지산리조트';
      case '하이원':
        return '하이원리조트';
      case '휘닉스':
        return '휘닉스평창';
      case '알펜시아':
        return '알펜시아리조트';
      default:
        return resortNickname;
    }
  }



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

    return Scaffold(
      backgroundColor: Colors.white,
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
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Image.asset(
                'assets/imgs/icons/icon_onb_indicator4.png',
                scale: 4,
                width: 56,
                height: 8,
              ),
            ),
          ],
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
                    '크루의 베이스 리조트는\n${resortNameList[baseResort!]}(으)로 설정됩니다.',
                    style:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '베이스 리조트를 바꾸면 자주가는 리조트도 함께 변경됩니다.',
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
                            if(_userModelController.liveCrew!.isEmpty || _userModelController.liveCrew == ''){
                            CustomFullScreenDialog.showDialog();
                            Timestamp resistDate = Timestamp.now();
                            DateTime dateTime = resistDate.toDate();
                            String dateTimeStr = '${dateTime.year}${dateTime.month}${dateTime.day}${dateTime.hour}${dateTime.minute}${dateTime.second}';
                            crewID = widget.crewName + dateTimeStr.toString();
                            await _liveCrewModelController.createCrewDoc(
                                crewLeader: _userModelController.displayName,
                                crewColor: widget.crewColor,
                                resortNum: baseResort,
                                crewImageUrl: widget.CrewImageUrl,
                                crewName: widget.crewName,
                                crewID: crewID,
                                sns: ''
                            );
                            await _userModelController.updateFavoriteResort(baseResort);
                            await _userModelController.updateResortNickname(baseResort);
                            await _userModelController.updateLiveCrew(crewID);
                            await _userModelController.getCurrentUser(_userModelController.uid);
                            print('크루 생성 완료');
                            CustomFullScreenDialog.cancelDialog();
                            Get.offAll(()=>LiveCrewHome());
                            } else{}
                          }else{
                            null;
                          }
                        },
                        child:
                        (_userModelController.favoriteResort! == baseResort)
                        ? Text(
                          '크루 만들기',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )
                        : Text(
                    '베이스 리조트를 변경하여 크루 만들기',
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
            baseResort = null;
          } else {
            baseResort = index;
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


