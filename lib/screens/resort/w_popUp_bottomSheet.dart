import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_urlLauncherController.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform, exit;

import '../../controller/vm_userModelController.dart';



final ref = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

//TODO: Dependency Injection************************************************
UserModelController _userModelController = Get.find<UserModelController>();
UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();
//TODO: Dependency Injection************************************************

Future<void> bottomPopUp() async {

  List addUidList = [];
  List addUidViewer = [];
  bool addUidBoolean = false;
  String? addUidLandingUrl = '';
  String? addUidImageUrl = '';
  String? addUidbottonMsg = '';

  List minusUidList = [];
  List totalViewer = [];
  bool isTotal = false;
  String? totalLandingUrl = '';
  String? totalImageUrl = '';
  String? totalbottonMsg = '';

  Future<void> getAddUidList() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('popUp').doc('resortHome_bottom_addUid');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    addUidList = documentSnapshot.get('addUidList');
    addUidBoolean = documentSnapshot.get('useAddUidPopUp');
    addUidLandingUrl = documentSnapshot.get('landingUrl');
    addUidImageUrl = documentSnapshot.get('imageUrl');
    addUidViewer = documentSnapshot.get('viewer');
    addUidViewer = documentSnapshot.get('viewer');
    addUidbottonMsg = documentSnapshot.get('bottonMsg');
  }

  Future<void> getMinusUidList() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('popUp').doc('resortHome_bottom_total');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    minusUidList = documentSnapshot.get('minusUidList');
    isTotal = documentSnapshot.get('total');
    totalLandingUrl = documentSnapshot.get('landingUrl');
    totalImageUrl = documentSnapshot.get('imageUrl');
    totalViewer = documentSnapshot.get('viewer');
    totalbottonMsg = documentSnapshot.get('bottonMsg');
  }

  Future<void> updateTotalViewerUid() async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('popUp').doc('resortHome_bottom_total').update({
      'viewer': FieldValue.arrayUnion([userMe])
    });
  }

  Future<void> updateAddViewerUid() async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('popUp').doc('resortHome_bottom_addUid').update({
      'viewer': FieldValue.arrayUnion([userMe])
    });
  }

  await getAddUidList();
  await getMinusUidList();

    if (addUidBoolean==true &&
        addUidList.contains(_userModelController.uid) &&
        !addUidViewer.contains(_userModelController.uid)) {
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
                        padding: EdgeInsets.only(right: 15,left: 15,top: 25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                Get.back();
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: SizedBox(
                                  height: 10,
                                  child: Icon(Icons.cancel_outlined),
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              height: 350,
                              width: 350,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    ExtendedImage.network(
                                      addUidImageUrl!,
                                      cacheHeight: 500,
                                      fit: BoxFit.cover,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: ElevatedButton(
                                      onPressed: () async{
                                        _urlLauncherController.otherShare(contents: '${addUidLandingUrl}');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        elevation: 0,
                                      ),
                                      child: Text('$addUidbottonMsg',
                                        style: TextStyle(
                                            color: Colors.grey
                                        ),)
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: ElevatedButton(
                                      onPressed: () async{
                                        await updateAddViewerUid();
                                        Get.back();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 0
                                      ),
                                      child: Text('다시 보지 않기',
                                        style: TextStyle(
                                            color: Colors.grey
                                        ),)
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                ])
        ),
        barrierDismissible: false, // 외부 영역 터치로 팝업 닫기 금지
      );
    } else if(isTotal == true &&
        !minusUidList.contains(_userModelController.uid)&&
    !totalViewer.contains(_userModelController.uid)){
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
                        padding: EdgeInsets.only(right: 15,left: 15,top: 25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                Get.back();
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: SizedBox(
                                  height: 10,
                                  child: Icon(Icons.cancel_outlined),
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              height: 350,
                              width: 350,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    ExtendedImage.network(
                                        totalImageUrl!,
                                      cacheHeight: 500,
                                      fit: BoxFit.cover,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: ElevatedButton(
                                      onPressed: () async{
                                        _urlLauncherController.otherShare(contents: '${totalLandingUrl}');
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 0,
                                      ),
                                      child: Text('$totalbottonMsg',
                                        style: TextStyle(
                                            color: Colors.grey
                                        ),)
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: ElevatedButton(
                                      onPressed: () async{
                                        await updateTotalViewerUid();
                                        Get.back();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                        elevation: 0
                                      ),
                                      child: Text('다시 보지 않기',
                                        style: TextStyle(
                                            color: Colors.grey
                                        ),)
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                ])
        ),
        barrierDismissible: false, // 외부 영역 터치로 팝업 닫기 금지
      );
    } else {}
}



