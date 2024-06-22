import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_urlLauncherController.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform, exit;

import '../controller/vm_userModelController.dart';



final ref = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

//TODO: Dependency Injection************************************************
UserModelController _userModelController = Get.find<UserModelController>();
UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();
//TODO: Dependency Injection************************************************

Future<void> bottomPopUp(BuildContext context) async {

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

  Size _size = MediaQuery.of(context).size;

  await getAddUidList();
  await getMinusUidList();

    if (addUidBoolean==true &&
        addUidList.contains(_userModelController.uid) &&
        !addUidViewer.contains(_userModelController.uid)) {

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 여기에 모달의 내용을 추가
                  // 예를 들어, 팝업 내용
                  Stack(
                    children: [
                      Container(
                        height: _size.width,
                        width: _size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              ExtendedImage.network(
                                addUidImageUrl!,
                                cacheHeight: 500,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: ExtendedImage.asset(
                              'assets/imgs/icons/icon_profile_delete.png',
                              fit: BoxFit.cover,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: _size.width / 2,
                        height: 58,
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
                                  color: Color(0xFF949494),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16
                              ),)
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Color(0xFFDEDEDE),
                      ),
                      SizedBox(
                        width: _size.width / 2 - 1,
                        height: 58,
                        child: ElevatedButton(
                            onPressed: () async{

                              try{
                                await FirebaseAnalytics.instance.logEvent(
                                  name: 'tap_resortHome_bottom_addUid',
                                  parameters: <String, dynamic>{
                                    'user_id': _userModelController.uid,
                                    'user_name': _userModelController.displayName,
                                    'user_resort': _userModelController.favoriteResort
                                  },
                                );
                              }catch(e, stackTrace){
                                print('GA 업데이트 오류: $e');
                                print('Stack trace: $stackTrace');
                              }

                              _urlLauncherController.otherShare(contents: '${addUidLandingUrl}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: Text('$addUidbottonMsg',
                              style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),)
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      );

    } else if(isTotal == true &&
        !minusUidList.contains(_userModelController.uid)&&
    !totalViewer.contains(_userModelController.uid)){


      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 여기에 모달의 내용을 추가
                  // 예를 들어, 팝업 내용
                  Stack(
                    children: [
                      Container(
                        height: _size.width,
                        width: _size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              ExtendedImage.network(
                                totalImageUrl!,
                                cacheHeight: 500,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: ExtendedImage.asset(
                              'assets/imgs/icons/icon_profile_delete.png',
                              fit: BoxFit.cover,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: _size.width / 2,
                        height: 58,
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
                                  color: Color(0xFF949494),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16
                              ),)
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Color(0xFFDEDEDE),
                      ),
                      SizedBox(
                        width: _size.width / 2 - 1,
                        height: 58,
                        child: ElevatedButton(
                            onPressed: () async{

                              try{
                                await FirebaseAnalytics.instance.logEvent(
                                  name: 'tap_resortHome_bottom_total',
                                  parameters: <String, dynamic>{
                                    'user_id': _userModelController.uid,
                                    'user_name': _userModelController.displayName,
                                    'user_resort': _userModelController.favoriteResort
                                  },
                                );
                              }catch(e, stackTrace){
                                print('GA 업데이트 오류: $e');
                                print('Stack trace: $stackTrace');
                              }

                              _urlLauncherController.otherShare(contents: '${totalLandingUrl}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: Text('$totalbottonMsg',
                              style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),)
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      );



    } else {}
}



  // Get.dialog(
  //   WillPopScope(
  //       onWillPop: () async {
  //         // 뒤로가기 버튼을 눌러도 팝업이 닫히지 않게 하려면 true를 반환합니다.
  //         return false;
  //       },
  //       child: Scaffold(
  //         backgroundColor: Colors.transparent,
  //         extendBodyBehindAppBar: true,
  //         body: Stack(
  //             children: <Widget>[
  //               // 반투명 배경
  //               ModalBarrier(dismissible: true, color: Colors.transparent),
  //               Positioned(
  //                   bottom: 0,
  //                   left: 0,
  //                   right: 0,
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.only(
  //                         topLeft: Radius.circular(12),
  //                         topRight: Radius.circular(12),
  //                       ),
  //                     ),
  //                     child: Column(
  //                       children: [
  //                         Stack(
  //                           children: [
  //                             Container(
  //                               height: _size.width,
  //                               width: _size.width,
  //                               decoration: BoxDecoration(
  //                                 color: Colors.white,
  //                                 borderRadius: BorderRadius.circular(12),
  //                               ),
  //                               child: Center(
  //                                 child: Column(
  //                                   children: [
  //                                     ExtendedImage.network(
  //                                       addUidImageUrl!,
  //                                       cacheHeight: 500,
  //                                       fit: BoxFit.cover,
  //                                     )
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                             Positioned(
  //                               top: 14,
  //                               right: 14,
  //                               child: GestureDetector(
  //                                 onTap: (){
  //                                   Get.back();
  //                                 },
  //                                 child: Align(
  //                                   alignment: Alignment.topRight,
  //                                   child: ExtendedImage.asset('assets/imgs/icons/icon_profile_delete.png',
  //                                     fit: BoxFit.cover,
  //                                     width: 24,
  //                                     height: 24,
  //                                   ),
  //                                 ),
  //                               ),),
  //                           ],
  //                         ),
  //                         SizedBox(height: 4),
  //                         Row(
  //                           crossAxisAlignment: CrossAxisAlignment.center,
  //                           children: [
  //                             SizedBox(
  //                               width: _size.width / 2,
  //                               height: 58,
  //                               child: ElevatedButton(
  //                                   onPressed: () async{
  //                                     await updateAddViewerUid();
  //                                     Get.back();
  //                                   },
  //                                   style: ElevatedButton.styleFrom(
  //                                       backgroundColor: Colors.white,
  //                                       elevation: 0
  //                                   ),
  //                                   child: Text('다시 보지 않기',
  //                                     style: TextStyle(
  //                                         color: Color(0xFF949494),
  //                                         fontWeight: FontWeight.normal,
  //                                         fontSize: 16
  //                                     ),)
  //                               ),
  //                             ),
  //                             Container(
  //                               height: 40,
  //                               width: 1,
  //                               color: Color(0xFFDEDEDE),
  //                             ),
  //                             SizedBox(
  //                               width: _size.width / 2 - 1,
  //                               height: 58,
  //                               child: ElevatedButton(
  //                                   onPressed: () async{
  //                                     _urlLauncherController.otherShare(contents: '${addUidLandingUrl}');
  //                                   },
  //                                   style: ElevatedButton.styleFrom(
  //                                     backgroundColor: Colors.white,
  //                                     elevation: 0,
  //                                   ),
  //                                   child: Text('$addUidbottonMsg',
  //                                     style: TextStyle(
  //                                         color: Color(0xFF111111),
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 16
  //                                     ),)
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         SizedBox(height: 4),
  //                       ],
  //                     ),
  //                   )),
  //             ]),
  //       )
  //   ),
  //   barrierDismissible: true, // 외부 영역 터치로 팝업 닫기 금지
  // );




