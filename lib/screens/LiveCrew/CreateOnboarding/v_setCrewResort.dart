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

    return Stack(
      children: [
        Scaffold(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '크루의 베이스 스키장을\n설정해 주세요.',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.3),
                            ),
                      SizedBox(
                        height: 4,
                      ),
                      Text('${resortNameList[baseResort!]}',
                        style: TextStyle(
                            color: widget.crewColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    '베이스 스키장을 변경하면 자주가는 스키장도 함께 바뀝니다.',
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
                              buildCheckboxListTile(index),
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
            height: 90,
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0,
          left: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                            sns: '',
                            totalScore: 0
                        );
                        await _userModelController.updateFavoriteResort(baseResort);
                        await _userModelController.updateResortNickname(baseResort);
                        await _userModelController.updateLiveCrew(crewID);
                        await _userModelController.getCurrentUser(_userModelController.uid);
                        await _liveCrewModelController.getCurrnetCrew(crewID);
                        print('크루 생성 완료');
                        CustomFullScreenDialog.cancelDialog();
                        for(int i=0; i<5; i++){
                          Get.back();
                        }
                        Get.to(()=>LiveCrewHome());
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
                    '베이스 스키장 변경',
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
                          ? widget.crewColor
                          : Color(0xffDEDEDE))
              ),
            ),
          ),
        ),
      ],
    );
  }

  ListTile buildCheckboxListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${resortNameList[index]}', style: TextStyle(fontSize: 16),),
      selected: _isSelected[index]!,
      trailing: _isChecked[index]!
          ? Image.asset(
        'assets/imgs/icons/icon_check_filled.png',
        width: 24,
        height: 24,
      )
          : Image.asset(
        'assets/imgs/icons/icon_check_unfilled.png',
        width: 24,
        height: 24,
      ),
      onTap: () {
        setState(() {
          _isChecked = List<bool?>.filled(14, false);
          _isSelected = List<bool?>.filled(14, false);
          _isChecked[index] = true;
          _isSelected[index] = true;
          baseResort = index;
        });
      },
    );
  }

}


