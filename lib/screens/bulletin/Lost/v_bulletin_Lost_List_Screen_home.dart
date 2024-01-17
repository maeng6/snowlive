import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/vm_allUserDocsController.dart';
import '../../../controller/vm_bulletinLostController.dart';
import '../../../controller/vm_timeStampController.dart';
import '../../../controller/vm_userModelController.dart';

class Bulletin_Lost_List_Screen_Home extends StatefulWidget {
  const Bulletin_Lost_List_Screen_Home({Key? key}) : super(key: key);

  @override
  State<Bulletin_Lost_List_Screen_Home> createState() => _Bulletin_Lost_List_Screen_HomeState();

}

class _Bulletin_Lost_List_Screen_HomeState extends State<Bulletin_Lost_List_Screen_Home> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinLostModelController _bulletinLostModelController = Get.find<BulletinLostModelController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  //TODO: Dependency Injection**************************************************

  var _stream;
  var _stream_hot;
  var _selectedValue = '카테고리';
  var _allCategories;
  bool _isVisible = false;
  bool _orderbyLike = false;
  bool _orderbyView = false;
  var _alluser;


  var f = NumberFormat('###,###,###,###');

  ScrollController _scrollController = ScrollController();
  bool _showAddButton = true;

  List<bool> isTap = [
    true,
    false,
    false,
    false,
    false
  ];

  bool _filerTab = false;
  var _filterValue = '필터';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _seasonController.getBulletinLostLimit();
    _stream = newStream();

    try{
      FirebaseAnalytics.instance.logEvent(
        name: 'visit_bulletinLost',
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

  @override
  void dispose() {
    _allUserDocsController.stopListening();
    super.dispose();
  }

  Stream<QuerySnapshot> newStream(){
    return FirebaseFirestore.instance
        .collection('bulletinLost')
        .where('category',
        isEqualTo:
        (_selectedValue == '카테고리') ? _allCategories : '$_selectedValue')
        .orderBy('timeStamp', descending: true)
        .limit(1)
        .snapshots();
  }

  Future<void> _refreshData() async {
    await _allUserDocsController.getAllUserDocs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    _seasonController.getBulletinLostLimit();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          color: Color(0xFFFFFFFF),
          width: _size.width,
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(color: Colors.white);
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final chatDocs = snapshot.data!.docs;

                  if (chatDocs.isNotEmpty) {
                    // 첫 번째 문서의 데이터를 가져옵니다.
                    Map<String, dynamic>? data = chatDocs[0].data() as Map<String, dynamic>?;

                    // 필드가 없을 경우 기본값 설정
                    bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;

                    if (isLocked) {
                      // 차단된 게시글의 경우
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            '운영자에 의해 차단된 게시글입니다.',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                                color: Color(0xff949494)),
                          ),
                        ),
                      );
                    } else {
                      // 첫 번째 타이틀을 표시합니다.
                      return Row(
                        children: [
                          Image.asset(
                            'assets/imgs/icons/icon_lost_home.png',
                            width: 18,
                            height: 18,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              width: _size.width - 118,
                              child: Text(
                                chatDocs[0].get('title'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF111111)),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  } else {
                    return Center(child: Text('게시글이 없습니다.'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
