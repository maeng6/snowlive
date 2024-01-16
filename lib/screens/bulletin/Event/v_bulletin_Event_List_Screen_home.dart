import 'dart:math';

import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/screens/bulletin/Event/v_bulletinEventImageScreen.dart';
import 'package:com.snowlive/screens/bulletin/Event/v_bulletin_Event_List_Detail.dart';
import 'package:com.snowlive/screens/bulletin/Event/v_bulletin_Event_Upload.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/vm_allUserDocsController.dart';
import '../../../controller/vm_bulletinEventController.dart';
import '../../../controller/vm_timeStampController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
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
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
//TODO: Dependency Injection**************************************************

  var _stream;
  var _selectedValue = '카테고리';
  var _selectedValue2 = '지역';
  var _allCategories;
  bool _isVisible = false;

  var f = NumberFormat('###,###,###,###');

  ScrollController _scrollController = ScrollController();
  bool _showAddButton = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _seasonController.getBulletinEventLimit();
    _stream = newStream();

    try{
      FirebaseAnalytics.instance.logEvent(
        name: 'visit_bulletinEvent',
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

    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          _isVisible = true;
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward ||
            _scrollController.position.pixels <=
                _scrollController.position.maxScrollExtent) {
          _isVisible = false;
        }
      });
    });

    // Add a listener to the ScrollController
    _scrollController.addListener(() {
      setState(() {
        // Check if the user has scrolled down by a certain offset (e.g., 100 pixels)
        _showAddButton = _scrollController.offset <= 0;
      });
    });
  }

  Stream<QuerySnapshot> newStream() {
    int limit = _seasonController.bulletinEventLimit! > 0 ? _seasonController.bulletinEventLimit! : 1;

    return FirebaseFirestore.instance
        .collection('bulletinEvent')
        .where('category',
        isEqualTo: (_selectedValue == '카테고리') ? _allCategories : '$_selectedValue')
        .where('location', isEqualTo: (_selectedValue2 == '지역') ? _allCategories : '$_selectedValue2')
        .orderBy('timeStamp', descending: true)
        .limit(limit)
        .snapshots();
  }


  Future<void> _refreshData() async {
    await _allUserDocsController.getAllUserDocs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    _seasonController.getBulletinEventLimit();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Flexible(
                child: StreamBuilder<QuerySnapshot> (
                  stream: _stream,
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
                    return (chatDocs.length == 0)
                        ? Transform.translate(
                      offset: Offset(0, -40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/imgs/icons/icon_nodata.png',
                            scale: 4,
                            width: 73,
                            height: 73,
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text('게시판에 글이 없습니다.',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF949494)
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                            Map<String, dynamic>? data = chatDocs[index].data() as Map<String, dynamic>?;

                            // 필드가 없을 경우 기본값 설정
                            bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;
                            List viewerUid = data?.containsKey('viewerUid') == true ? data!['viewerUid'] : [];
                            String _time = _timeStampController.yyyymmddFormat(chatDocs[index].get('timeStamp'));
                            String? profileUrl = _allUserDocsController.findProfileUrl(chatDocs[index]['uid'], _allUserDocsController.allUserDocs);
                            String? displayName = _allUserDocsController.findDisplayName(chatDocs[index]['uid'], _allUserDocsController.allUserDocs);

                            return GestureDetector(
                              onTap: () async {
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
                              child: Obx(() => Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Container(
                                      color: Colors.white,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                          width: 64,
                                                          height: 64,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      if (chatDocs[index].get('itemImagesUrl').isNotEmpty)
                                                      GestureDetector(
                                                        onTap: () {
                                                          Get.to(() => BulletinEventImageScreen());
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(6),
                                                          child: ExtendedImage.network(
                                                            chatDocs[index].get('itemImagesUrl')!,
                                                            fit: BoxFit.cover,
                                                            width: 64,
                                                            height: 64,
                                                          ),
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
                                                              fontSize: 12,
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
                                                                                fontSize: 15,
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
                                ],
                              )),
                            );
                          },
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
