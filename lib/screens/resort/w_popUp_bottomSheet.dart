import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_urlLauncherController.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform, exit;

import '../../controller/vm_userModelController.dart';



final ref = FirebaseFirestore.instance;

//TODO: Dependency Injection************************************************
UserModelController _userModelController = Get.find<UserModelController>();
//TODO: Dependency Injection************************************************

Future<void> bottomPopUp() async {

    final addUidList = await getAddUidList();
    final minusUidList = await getMinusUidList();
    final isTotal = await getTotalboolean();
    final useAddUid = await getAddUidboolean();

    if (useAddUid==true && addUidList.contains(_userModelController.uid)) {
      Get.dialog(
        WillPopScope(
          onWillPop: () async {
            // 뒤로가기 버튼을 눌러도 팝업이 닫히지 않게 하려면 true를 반환합니다.
            return false;
          },
          child:   Stack(
              children: <Widget>[
                // 반투명 배경
                Opacity(
                  opacity: 0.6,
                  child: ModalBarrier(dismissible: true, color: Colors.black),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 300,
                      margin: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text('${_userModelController.displayName}에게만 보내는 팝업'),
                            ElevatedButton(
                                onPressed: (){
                                  Get.back();
                                },
                                child: Text('닫기')
                            )
                          ],
                        ),
                      ),
                    )),
              ])
        ),
        barrierDismissible: false, // 외부 영역 터치로 팝업 닫기 금지
      );
    } else if(isTotal == true && !minusUidList.contains(_userModelController.uid)){
      Get.dialog(
        WillPopScope(
            onWillPop: () async {
              // 뒤로가기 버튼을 눌러도 팝업이 닫히지 않게 하려면 true를 반환합니다.
              return false;
            },
            child:   Stack(
                children: <Widget>[
                  // 반투명 배경
                  Opacity(
                    opacity: 0.6,
                    child: ModalBarrier(dismissible: true, color: Colors.black),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 300,
                        margin: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text('모든이에게 보내는 팝업'),
                              ElevatedButton(
                                  onPressed: (){
                                    Get.back();
                                  },
                                  child: Text('닫기')
                              )
                            ],
                          ),
                        ),
                      )),
                ])
        ),
        barrierDismissible: false, // 외부 영역 터치로 팝업 닫기 금지
      );
    } else {}
}

Future<List> getAddUidList() async {
  DocumentReference<Map<String, dynamic>> documentReference =
  ref.collection('popUp').doc('resortHome_bottom_addUid');
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
  await documentReference.get();
  List addUidList = documentSnapshot.get('addUidList');
  return addUidList;
}

Future<List> getMinusUidList() async {
  DocumentReference<Map<String, dynamic>> documentReference =
  ref.collection('popUp').doc('resortHome_bottom_total');
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
  await documentReference.get();
  List minusUidList = documentSnapshot.get('minusUidList');
  return minusUidList;
}

Future<bool> getTotalboolean() async {
  DocumentReference<Map<String, dynamic>> documentReference =
  ref.collection('popUp').doc('resortHome_bottom_total');
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
  await documentReference.get();
  bool total = documentSnapshot.get('total');
  return total;
}

Future<bool> getAddUidboolean() async {
  DocumentReference<Map<String, dynamic>> documentReference =
  ref.collection('popUp').doc('resortHome_bottom_addUid');
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
  await documentReference.get();
  bool addUidBoolean = documentSnapshot.get('useAddUidPopUp');
  return addUidBoolean;
}