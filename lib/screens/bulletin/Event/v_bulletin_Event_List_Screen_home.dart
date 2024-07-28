import 'package:carousel_slider/carousel_slider.dart';
import 'package:com.snowlive/controller/bulletin/vm_streamController_bulletin.dart';
import 'package:com.snowlive/screens/bulletin/Event/v_bulletin_Event_List_Detail.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/bulletin/vm_bulletinEventController.dart';
import '../../../controller/user/vm_userModelController.dart';
import '../../../widget/w_fullScreenDialog.dart';

class Bulletin_Event_List_Screen_Home extends StatefulWidget {
  const Bulletin_Event_List_Screen_Home({Key? key}) : super(key: key);

  @override
  State<Bulletin_Event_List_Screen_Home> createState() => _Bulletin_Event_List_Screen_HomeState();
}

class _Bulletin_Event_List_Screen_HomeState extends State<Bulletin_Event_List_Screen_Home> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinEventModelController _bulletinEventModelController = Get.find<BulletinEventModelController>();
  StreamController_Bulletin _streamController_Bulletin = Get.find<StreamController_Bulletin>();

  //TODO: Dependency Injection**************************************************


  var f = NumberFormat('###,###,###,###');


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    try{
      FirebaseAnalytics.instance.logEvent(
        name: 'visit_bulletinEvent',
        parameters: <String, Object>{
          'user_id': _userModelController.uid!,
          'user_name': _userModelController.displayName!,
          'user_resort': _userModelController.favoriteResort!
        },
      );
    }catch(e, stackTrace){
      print('GA 업데이트 오류: $e');
      print('Stack trace: $stackTrace');
    }

  }


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;


    return StreamBuilder<QuerySnapshot> (
        stream: _streamController_Bulletin.setupStreams_bulletinEvent_home(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: Colors.white,
            );
          } else if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final chatDocs = snapshot.data!.docs;

          return Column(
            children: [
              if (chatDocs.length.isGreaterThan(0))
                CarouselSlider.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index, pageViewIndex) {
                    Map<String, dynamic>? data = chatDocs[index].data() as Map<String, dynamic>?;

                    // 필드가 없을 경우 기본값 설정
                    bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;

                    return Obx(() => GestureDetector(
                      onTap: () async{
                        if(isLocked == false) {
                          if (_userModelController.repoUidList!
                              .contains(chatDocs[index].get('uid'))) {
                            return;
                          }
                          CustomFullScreenDialog.showDialog();
                          await _bulletinEventModelController
                              .getCurrentBulletinEvent(
                              uid: chatDocs[index].get('uid'),
                              bulletinEventCount:
                              chatDocs[index].get('bulletinEventCount'));
                          if (data?.containsKey('lock') == false) {
                            await chatDocs[index].reference.update({'viewerUid': []});
                          }
                          await _bulletinEventModelController.updateViewerUid();
                          await _bulletinEventModelController
                              .getCurrentBulletinEvent(
                              uid: chatDocs[index].get('uid'),
                              bulletinEventCount:
                              chatDocs[index].get('bulletinEventCount'));
                          CustomFullScreenDialog.cancelDialog();
                          Get.to(() => Bulletin_Event_List_Detail());
                        }else{}
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (isLocked==true)
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '운영자에 의해 차단된 게시글입니다.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13,
                                            color: Color(0xff949494)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  :(_userModelController.repoUidList!.contains(chatDocs[index].get('uid')))
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24),
                                  child: Text(
                                    '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Color(0xffc8c8c8)),
                                  ),
                                ),
                              )
                                  : Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6)
                                      ),
                                      width: 64,
                                      height: 64,
                                      child:
                                      Column(
                                        children: [
                                          if (chatDocs[index].get('itemImagesUrl').isEmpty)
                                            ExtendedImage.asset('assets/imgs/profile/img_profile_default_.png',
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(6),
                                              cacheHeight: 100,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            ),
                                          if (chatDocs[index].get('itemImagesUrl').isNotEmpty)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: ExtendedImage.network(
                                                chatDocs[index].get('itemImagesUrl')!,
                                                cacheHeight: 100,
                                                fit: BoxFit.cover,
                                                width: 64,
                                                height: 64,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Container(
                                      width: _size.width - 148,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFECECEC),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              chatDocs[index].get('category'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: Color(0xFF666666)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth: _size.width - 148),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: _size.width - 148,
                                                              child: Text(
                                                                chatDocs[index].get('title'),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: Color(0xFF111111)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '${chatDocs[index].get('location')}',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF949494),
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
                  }, options: CarouselOptions(
                    height: 87,
                    initialPage: 0,
                    scrollPhysics: NeverScrollableScrollPhysics(),
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    autoPlayInterval: Duration(seconds: 4)),
                ),
              if (chatDocs.length.isGreaterThan(1))
                CarouselSlider.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index, pageViewIndex) {
                    Map<String, dynamic>? data = chatDocs[1].data() as Map<String, dynamic>?;

                    // 필드가 없을 경우 기본값 설정
                    bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;

                    return Obx(() => GestureDetector(
                      onTap: () async{
                        if(isLocked == false) {
                          if (_userModelController.repoUidList!
                              .contains(chatDocs[1].get('uid'))) {
                            return;
                          }
                          CustomFullScreenDialog.showDialog();
                          await _bulletinEventModelController
                              .getCurrentBulletinEvent(
                              uid: chatDocs[1].get('uid'),
                              bulletinEventCount:
                              chatDocs[1].get('bulletinEventCount'));
                          if (data?.containsKey('lock') == false) {
                            await chatDocs[1].reference.update({'viewerUid': []});
                          }
                          await _bulletinEventModelController.updateViewerUid();
                          await _bulletinEventModelController
                              .getCurrentBulletinEvent(
                              uid: chatDocs[1].get('uid'),
                              bulletinEventCount:
                              chatDocs[1].get('bulletinEventCount'));
                          CustomFullScreenDialog.cancelDialog();
                          Get.to(() => Bulletin_Event_List_Detail());
                        }else{}
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (isLocked==true)
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '운영자에 의해 차단된 게시글입니다.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13,
                                            color: Color(0xff949494)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  :(_userModelController.repoUidList!.contains(chatDocs[1].get('uid')))
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24),
                                  child: Text(
                                    '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Color(0xffc8c8c8)),
                                  ),
                                ),
                              )
                                  : Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6)
                                      ),
                                      width: 64,
                                      height: 64,
                                      child:
                                      Column(
                                        children: [
                                          if (chatDocs[1].get('itemImagesUrl').isEmpty)
                                            ExtendedImage.asset('assets/imgs/profile/img_profile_default_.png',
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(6),
                                              cacheHeight: 100,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            ),
                                          if (chatDocs[1].get('itemImagesUrl').isNotEmpty)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: ExtendedImage.network(
                                                chatDocs[1].get('itemImagesUrl')!,
                                                cacheHeight: 100,
                                                fit: BoxFit.cover,
                                                width: 64,
                                                height: 64,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Container(
                                      width: _size.width - 148,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFECECEC),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              chatDocs[1].get('category'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: Color(0xFF666666)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth: _size.width - 148),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: _size.width - 148,
                                                              child: Text(
                                                                chatDocs[1].get('title'),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: Color(0xFF111111)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '${chatDocs[1].get('location')}',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF949494),
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
                  }, options: CarouselOptions(
                    height: 87,
                    scrollPhysics: NeverScrollableScrollPhysics(),
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    autoPlayInterval: Duration(seconds: 4)),
                ),
              if (chatDocs.length.isGreaterThan(2))
                CarouselSlider.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index, pageViewIndex) {
                    Map<String, dynamic>? data = chatDocs[2].data() as Map<String, dynamic>?;

                    // 필드가 없을 경우 기본값 설정
                    bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;


                    return Obx(() => GestureDetector(
                      onTap: () async{
                        if(isLocked == false) {
                          if (_userModelController.repoUidList!
                              .contains(chatDocs[2].get('uid'))) {
                            return;
                          }
                          CustomFullScreenDialog.showDialog();
                          await _bulletinEventModelController
                              .getCurrentBulletinEvent(
                              uid: chatDocs[2].get('uid'),
                              bulletinEventCount:
                              chatDocs[2].get('bulletinEventCount'));
                          if (data?.containsKey('lock') == false) {
                            await chatDocs[2].reference.update({'viewerUid': []});
                          }
                          await _bulletinEventModelController.updateViewerUid();
                          await _bulletinEventModelController
                              .getCurrentBulletinEvent(
                              uid: chatDocs[2].get('uid'),
                              bulletinEventCount:
                              chatDocs[2].get('bulletinEventCount'));
                          CustomFullScreenDialog.cancelDialog();
                          Get.to(() => Bulletin_Event_List_Detail());
                        }else{}
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (isLocked==true)
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '운영자에 의해 차단된 게시글입니다.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13,
                                            color: Color(0xff949494)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  :(_userModelController.repoUidList!.contains(chatDocs[2].get('uid')))
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24),
                                  child: Text(
                                    '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Color(0xffc8c8c8)),
                                  ),
                                ),
                              )
                                  : Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6)
                                      ),
                                      width: 64,
                                      height: 64,
                                      child:
                                      Column(
                                        children: [
                                          if (chatDocs[2].get('itemImagesUrl').isEmpty)
                                            ExtendedImage.asset('assets/imgs/profile/img_profile_default_.png',
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(6),
                                              cacheHeight: 100,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            ),
                                          if (chatDocs[2].get('itemImagesUrl').isNotEmpty)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: ExtendedImage.network(
                                                chatDocs[2].get('itemImagesUrl')!,
                                                cacheHeight: 100,
                                                fit: BoxFit.cover,
                                                width: 64,
                                                height: 64,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Container(
                                      width: _size.width - 148,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFECECEC),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              chatDocs[2].get('category'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: Color(0xFF666666)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth: _size.width - 148),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: _size.width - 148,
                                                              child: Text(
                                                                chatDocs[2].get('title'),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: Color(0xFF111111)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '${chatDocs[2].get('location')}',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF949494),
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
                  }, options: CarouselOptions(
                    height: 87,
                    initialPage: 0,
                    scrollPhysics: NeverScrollableScrollPhysics(),
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    autoPlayInterval: Duration(seconds: 4)),
                ),
              if (chatDocs.length.isGreaterThan(3))
                CarouselSlider.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index, pageViewIndex) {
                    Map<String, dynamic>? data = chatDocs[3].data() as Map<String, dynamic>?;

                    // 필드가 없을 경우 기본값 설정
                    bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;

                    return Obx(() => GestureDetector(
                      onTap: () async{
                        if(isLocked == false) {
                          if (_userModelController.repoUidList!
                              .contains(chatDocs[3].get('uid'))) {
                            return;
                          }
                          CustomFullScreenDialog.showDialog();
                          await _bulletinEventModelController
                              .getCurrentBulletinEvent(
                              uid: chatDocs[3].get('uid'),
                              bulletinEventCount:
                              chatDocs[3].get('bulletinEventCount'));
                          if (data?.containsKey('lock') == false) {
                            await chatDocs[3].reference.update({'viewerUid': []});
                          }
                          await _bulletinEventModelController.updateViewerUid();
                          await _bulletinEventModelController
                              .getCurrentBulletinEvent(
                              uid: chatDocs[3].get('uid'),
                              bulletinEventCount:
                              chatDocs[3].get('bulletinEventCount'));
                          CustomFullScreenDialog.cancelDialog();
                          Get.to(() => Bulletin_Event_List_Detail());
                        }else{}
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (isLocked==true)
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '운영자에 의해 차단된 게시글입니다.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13,
                                            color: Color(0xff949494)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  :(_userModelController.repoUidList!.contains(chatDocs[3].get('uid')))
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24),
                                  child: Text(
                                    '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Color(0xffc8c8c8)),
                                  ),
                                ),
                              )
                                  : Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6)
                                      ),
                                      width: 64,
                                      height: 64,
                                      child:
                                      Column(
                                        children: [
                                          if (chatDocs[3].get('itemImagesUrl').isEmpty)
                                            ExtendedImage.asset('assets/imgs/profile/img_profile_default_.png',
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(6),
                                              cacheHeight: 100,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            ),
                                          if (chatDocs[3].get('itemImagesUrl').isNotEmpty)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: ExtendedImage.network(
                                                chatDocs[3].get('itemImagesUrl')!,
                                                cacheHeight: 100,
                                                fit: BoxFit.cover,
                                                width: 64,
                                                height: 64,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Container(
                                      width: _size.width - 148,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFECECEC),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              chatDocs[3].get('category'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: Color(0xFF666666)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth: _size.width - 148),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: _size.width - 148,
                                                              child: Text(
                                                                chatDocs[3].get('title'),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: Color(0xFF111111)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '${chatDocs[3].get('location')}',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF949494),
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
                  }, options: CarouselOptions(
                    height: 87,
                    initialPage: 0,
                    scrollPhysics: NeverScrollableScrollPhysics(),
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    autoPlayInterval: Duration(seconds: 4)),
                ),
              if (chatDocs.length.isGreaterThan(4))
                CarouselSlider.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index, pageViewIndex) {
                    Map<String, dynamic>? data = chatDocs[4].data() as Map<String, dynamic>?;

                    // 필드가 없을 경우 기본값 설정
                    bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;

                    return Obx(() => GestureDetector(
                      onTap: () async{
                        if(isLocked == false) {
                          if (_userModelController.repoUidList!
                              .contains(chatDocs[4].get('uid'))) {
                            return;
                          }
                          CustomFullScreenDialog.showDialog();
                          await _bulletinEventModelController
                              .getCurrentBulletinEvent(
                              uid: chatDocs[4].get('uid'),
                              bulletinEventCount:
                              chatDocs[4].get('bulletinEventCount'));
                          if (data?.containsKey('lock') == false) {
                            await chatDocs[4].reference.update({'viewerUid': []});
                          }
                          await _bulletinEventModelController.updateViewerUid();
                          await _bulletinEventModelController
                              .getCurrentBulletinEvent(
                              uid: chatDocs[4].get('uid'),
                              bulletinEventCount:
                              chatDocs[4].get('bulletinEventCount'));
                          CustomFullScreenDialog.cancelDialog();
                          Get.to(() => Bulletin_Event_List_Detail());
                        }else{}
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (isLocked==true)
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '운영자에 의해 차단된 게시글입니다.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13,
                                            color: Color(0xff949494)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  :(_userModelController.repoUidList!.contains(chatDocs[4].get('uid')))
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24),
                                  child: Text(
                                    '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Color(0xffc8c8c8)),
                                  ),
                                ),
                              )
                                  : Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6)
                                      ),
                                      width: 64,
                                      height: 64,
                                      child:
                                      Column(
                                        children: [
                                          if (chatDocs[4].get('itemImagesUrl').isEmpty)
                                            ExtendedImage.asset('assets/imgs/profile/img_profile_default_.png',
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(6),
                                              cacheHeight: 100,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            ),
                                          if (chatDocs[4].get('itemImagesUrl').isNotEmpty)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: ExtendedImage.network(
                                                chatDocs[4].get('itemImagesUrl')!,
                                                cacheHeight: 100,
                                                fit: BoxFit.cover,
                                                width: 64,
                                                height: 64,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Container(
                                      width: _size.width - 148,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFECECEC),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              chatDocs[4].get('category'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  color: Color(0xFF666666)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth: _size.width - 148),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: _size.width - 148,
                                                              child: Text(
                                                                chatDocs[4].get('title'),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: Color(0xFF111111)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '${chatDocs[4].get('location')}',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF949494),
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
                  }, options: CarouselOptions(
                    height: 87,
                    initialPage: 4,
                    scrollPhysics: NeverScrollableScrollPhysics(),
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    autoPlayInterval: Duration(seconds: 4)),
                ),
            ],
          );
        },
      );
  }
}
