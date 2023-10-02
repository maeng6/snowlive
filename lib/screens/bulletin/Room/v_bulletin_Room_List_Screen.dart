import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/controller/vm_fleaMarketController.dart';
import 'package:com.snowlive/screens/bulletin/Room/v_bulletin_Room_List_Detail.dart';
import 'package:com.snowlive/screens/bulletin/Room/v_bulletin_Room_Upload.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import 'package:com.snowlive/screens/fleaMarket/v_phone_Auth_Screen.dart';
import '../../../controller/vm_bulletinRoomController.dart';
import '../../../controller/vm_timeStampController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../widget/w_fullScreenDialog.dart';

class Bulletin_Room_List_Screen extends StatefulWidget {
  const Bulletin_Room_List_Screen({Key? key}) : super(key: key);

  @override
  State<Bulletin_Room_List_Screen> createState() => _Bulletin_Room_List_ScreenState();
}

class _Bulletin_Room_List_ScreenState extends State<Bulletin_Room_List_Screen> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinRoomModelController _bulletinRoomModelController = Get.find<BulletinRoomModelController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  SeasonController _seasonController = Get.find<SeasonController>();
//TODO: Dependency Injection**************************************************

  var _stream;
  var _selectedValue = '카테고리';
  var _selectedValue2 = '스키장';
  var _allCategories;

  var f = NumberFormat('###,###,###,###');

  ScrollController _scrollController = ScrollController();
  bool _showAddButton = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _seasonController.getBulletinRoomLimit();
    _stream = newStream();

    // Add a listener to the ScrollController
    _scrollController.addListener(() {
      setState(() {
        // Check if the user has scrolled down by a certain offset (e.g., 100 pixels)
        _showAddButton = _scrollController.offset <= 0;
      });
    });
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('bulletinRoom')
        .where('category',
            isEqualTo:
                (_selectedValue == '카테고리') ? _allCategories : '$_selectedValue')
        .where('location', isEqualTo: (_selectedValue2 == '스키장') ? _allCategories : '$_selectedValue2')
        .orderBy('timeStamp', descending: true)
        .limit(_seasonController.bulletinRoomLimit!)
        .snapshots();
  }

  _showCupertinoPicker() async {
    await showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                height: 400,
                padding: EdgeInsets.only(left: 16, right: 16),
                child: CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            HapticFeedback.lightImpact();
                            _selectedValue = '카테고리';
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          '전체',
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '방 임대';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('방 임대')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '주주모집';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('주주모집')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '방 구해요';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('방 구해요')),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    child: Text('닫기'),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                  ),
                )
                ),
          );
        });
    setState(() {
      _stream = newStream();
    });
  }

  _showCupertinoPicker2() async {
    await showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                height: 520,
                padding: EdgeInsets.only(left: 16, right: 16),
                child: CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '스키장';
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          '전체',
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '곤지암리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('곤지암리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '무주덕유산리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('무주덕유산리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '비발디파크';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('비발디파크')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '알펜시아';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('알펜시아')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '에덴밸리리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('에덴밸리리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '엘리시안강촌';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('엘리시안강촌')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '오크밸리리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('오크밸리리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '오투리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('오투리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '용평리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('용평리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '웰리힐리파크';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('웰리힐리파크')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '지산리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('지산리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '하이원리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('하이원리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '휘닉스평창';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('휘닉스평창')),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    child: Text('닫기'),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                  ),
                )
            ),
          );
        });
    setState(() {
      _stream = newStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    _seasonController.getBulletinRoomLimit();


    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          floatingActionButton: Transform.translate(
            offset: Offset(18, 0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: AnimatedContainer(
                width: _showAddButton ? 104 : 52,
                height: 52,
                duration: Duration(milliseconds: 200),
                child: FloatingActionButton.extended(
                  elevation: 4,
                  onPressed: () async {
                    await _userModelController.getCurrentUser(_userModelController.uid);
                            Get.to(() => Bulletin_Room_Upload());
                  },
                  icon: Transform.translate(
                      offset: Offset(6,0),
                      child: Center(child: Icon(Icons.add))),
                  label: _showAddButton
                      ? Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text('글쓰기',
                      style: TextStyle(
                          letterSpacing: 0.5,
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis),
                    ),
                  )
                      : SizedBox.shrink(), // Hide the text when _showAddButton is false
                  backgroundColor: Color(0xFF3D6FED),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4, bottom: 6),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Container(
                        height: 56,
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      await _showCupertinoPicker();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.only(
                                            right: 30, left: 14, top: 8, bottom: 8),
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        primary: Color(0xFFF5F5F5),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8))),
                                    child: (_selectedValue == null)
                                        ? Text('카테고리',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF555555)))
                                        : Text('$_selectedValue',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF555555)))),
                                Positioned(
                                  top: 12,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await _showCupertinoPicker();
                                    },
                                    child: Icon(
                                      Icons.arrow_drop_down_sharp,
                                      size: 24,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Container(
                        height: 56,
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      await _showCupertinoPicker2();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.only(
                                            right: 30, left: 14, top: 8, bottom: 8),
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFF5F5F5),
                                        ),
                                        primary: Color(0xFFF5F5F5),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8))),
                                    child: (_selectedValue2 == null)
                                        ? Text('리조트',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF555555)))
                                        : Text('$_selectedValue2',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF555555)))),
                                Positioned(
                                  top: 12,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await _showCupertinoPicker2();
                                    },
                                    child: Icon(
                                      Icons.arrow_drop_down_sharp,
                                      size: 24,
                                      color: Color(0xFF666666),
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
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
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
                      controller: _scrollController, // ScrollController 연결
                      itemCount: chatDocs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic>? data = chatDocs[index].data() as Map<String, dynamic>?;

                        // 필드가 없을 경우 기본값 설정
                        bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;
                        List viewerUid = data?.containsKey('viewerUid') == true ? data!['viewerUid'] : [];
                        String _time = _timeStampController
                            .yyyymmddFormat(chatDocs[index].get('timeStamp'));
                        return GestureDetector(
                          onTap: () async {
                            if(isLocked == false) {
                              if (_userModelController.repoUidList!
                                  .contains(chatDocs[index].get('uid'))) {
                                return;
                              }
                              CustomFullScreenDialog.showDialog();
                              await _bulletinRoomModelController
                                  .getCurrentBulletinRoom(
                                  uid: chatDocs[index].get('uid'),
                                  bulletinRoomCount:
                                  chatDocs[index].get('bulletinRoomCount'));
                              if (data?.containsKey('lock') == false) {
                                await chatDocs[index].reference.update({'viewerUid': []});
                              }
                              await _bulletinRoomModelController
                                  .updateViewerUid();
                              CustomFullScreenDialog.cancelDialog();
                              Get.to(() => Bulletin_Room_List_Detail());
                            }else{}
                          },
                          child: Obx(() => Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Container(
                                      color: Colors.white,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          (isLocked == true)
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
                                                  if(_userModelController.displayName == 'SNOWLIVE')
                                                    GestureDetector(
                                                      onTap: () =>
                                                          showModalBottomSheet(
                                                              enableDrag: false,
                                                              context: context,
                                                              builder: (context) {
                                                                return Container(
                                                                  height: 100,
                                                                  child:Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal: 20.0,
                                                                        vertical: 14),
                                                                    child: Column(
                                                                      children: [
                                                                        GestureDetector(
                                                                          child: ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                (isLocked == false)
                                                                                    ? '게시글 잠금' : '게시글 잠금 해제',
                                                                                style: TextStyle(
                                                                                    fontSize: 15,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color(0xFFD63636)
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            //selected: _isSelected[index]!,
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              showModalBottomSheet(
                                                                                  context: context,
                                                                                  builder: (context) {
                                                                                    return Container(
                                                                                      color: Colors.white,
                                                                                      height: 180,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.symmetric(
                                                                                            horizontal: 20.0),
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            SizedBox(
                                                                                              height: 30,
                                                                                            ),
                                                                                            Text(
                                                                                              (isLocked == false)
                                                                                                  ? '이 게시글을 잠그시겠습니까?' : '이 게시글의 잠금을 해제하시겠습니까?',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 20,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                  color: Color(0xFF111111)),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 30,
                                                                                            ),
                                                                                            Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                              children: [
                                                                                                Expanded(
                                                                                                  child: ElevatedButton(
                                                                                                    onPressed: () {
                                                                                                      Navigator.pop(context);
                                                                                                    },
                                                                                                    child: Text(
                                                                                                      '취소',
                                                                                                      style: TextStyle(
                                                                                                          color: Colors.white,
                                                                                                          fontSize: 15,
                                                                                                          fontWeight: FontWeight.bold),
                                                                                                    ),
                                                                                                    style: TextButton.styleFrom(
                                                                                                        splashFactory: InkRipple.splashFactory,
                                                                                                        elevation: 0,
                                                                                                        minimumSize: Size(100, 56),
                                                                                                        backgroundColor: Color(0xff555555),
                                                                                                        padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: 10,
                                                                                                ),
                                                                                                Expanded(
                                                                                                  child: ElevatedButton(
                                                                                                    onPressed: () async {
                                                                                                      if (data?.containsKey('lock') == false) {
                                                                                                        await chatDocs[index].reference.update({'lock': false});
                                                                                                      }
                                                                                                      CustomFullScreenDialog.showDialog();
                                                                                                      await _bulletinRoomModelController.lock('${chatDocs[index]['uid']}#${chatDocs[index]['bulletinRoomCount']}');
                                                                                                      Navigator.pop(context);
                                                                                                      CustomFullScreenDialog.cancelDialog();
                                                                                                    },
                                                                                                    child: Text('확인',
                                                                                                      style: TextStyle(
                                                                                                          color: Colors.white,
                                                                                                          fontSize: 15,
                                                                                                          fontWeight: FontWeight.bold),
                                                                                                    ),
                                                                                                    style: TextButton.styleFrom(
                                                                                                        splashFactory: InkRipple.splashFactory,
                                                                                                        elevation: 0,
                                                                                                        minimumSize: Size(100, 56),
                                                                                                        backgroundColor: Color(0xff2C97FB),
                                                                                                        padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  });
                                                                            },
                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                      child: Icon(Icons.more_horiz,
                                                        color: Color(0xFFEF0069),
                                                        size: 20,
                                                      ),
                                                    )
                                                ],
                                              ),
                                            ),
                                          )
                                              :
                                          (_userModelController.repoUidList!
                                                  .contains(chatDocs[index]
                                                      .get('uid')))
                                              ? Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
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
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 6),
                                                      child: Container(
                                                        width: _size.width-32,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              chatDocs[index].get('category'),
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.normal,
                                                                  fontSize: 13,
                                                                  color: Color(0xFF111111)),
                                                            ),
                                                            SizedBox(
                                                              height: 2,
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
                                                                              maxWidth: _size.width - 164),
                                                                          child: Row(
                                                                            children: [
                                                                              Container(
                                                                                width: _size.width - 100,
                                                                                child: Text(
                                                                                  chatDocs[index].get('title'),
                                                                                  maxLines: 2,
                                                                                  overflow:  TextOverflow.ellipsis,
                                                                                  style: TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 15,
                                                                                      color: Color(0xFF111111)),
                                                                                ),
                                                                              ),
                                                                              if(_userModelController.displayName == 'SNOWLIVE')
                                                                                GestureDetector(
                                                                                  onTap: () =>
                                                                                      showModalBottomSheet(
                                                                                          enableDrag: false,
                                                                                          context: context,
                                                                                          builder: (context) {
                                                                                            return Container(
                                                                                              height: 100,
                                                                                              child:Padding(
                                                                                                padding: const EdgeInsets
                                                                                                    .symmetric(
                                                                                                    horizontal: 20.0,
                                                                                                    vertical: 14),
                                                                                                child: Column(
                                                                                                  children: [
                                                                                                    GestureDetector(
                                                                                                      child: ListTile(
                                                                                                        contentPadding: EdgeInsets.zero,
                                                                                                        title: Center(
                                                                                                          child: Text(
                                                                                                            (isLocked == false)
                                                                                                                ? '게시글 잠금' : '게시글 잠금 해제',
                                                                                                            style: TextStyle(
                                                                                                                fontSize: 15,
                                                                                                                fontWeight: FontWeight.bold,
                                                                                                                color: Color(0xFFD63636)
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                        //selected: _isSelected[index]!,
                                                                                                        onTap: () async {
                                                                                                          Navigator.pop(context);
                                                                                                          showModalBottomSheet(
                                                                                                              context: context,
                                                                                                              builder: (context) {
                                                                                                                return Container(
                                                                                                                  color: Colors.white,
                                                                                                                  height: 180,
                                                                                                                  child: Padding(
                                                                                                                    padding: const EdgeInsets.symmetric(
                                                                                                                        horizontal: 20.0),
                                                                                                                    child: Column(
                                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                                                      children: [
                                                                                                                        SizedBox(
                                                                                                                          height: 30,
                                                                                                                        ),
                                                                                                                        Text(
                                                                                                                          (isLocked == false)
                                                                                                                              ? '이 게시글을 잠그시겠습니까?' : '이 게시글의 잠금을 해제하시겠습니까?',
                                                                                                                          style: TextStyle(
                                                                                                                              fontSize: 20,
                                                                                                                              fontWeight: FontWeight.bold,
                                                                                                                              color: Color(0xFF111111)),
                                                                                                                        ),
                                                                                                                        SizedBox(
                                                                                                                          height: 30,
                                                                                                                        ),
                                                                                                                        Row(
                                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                          children: [
                                                                                                                            Expanded(
                                                                                                                              child: ElevatedButton(
                                                                                                                                onPressed: () {
                                                                                                                                  Navigator.pop(context);
                                                                                                                                },
                                                                                                                                child: Text(
                                                                                                                                  '취소',
                                                                                                                                  style: TextStyle(
                                                                                                                                      color: Colors.white,
                                                                                                                                      fontSize: 15,
                                                                                                                                      fontWeight: FontWeight.bold),
                                                                                                                                ),
                                                                                                                                style: TextButton.styleFrom(
                                                                                                                                    splashFactory: InkRipple.splashFactory,
                                                                                                                                    elevation: 0,
                                                                                                                                    minimumSize: Size(100, 56),
                                                                                                                                    backgroundColor: Color(0xff555555),
                                                                                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            SizedBox(
                                                                                                                              width: 10,
                                                                                                                            ),
                                                                                                                            Expanded(
                                                                                                                              child: ElevatedButton(
                                                                                                                                onPressed: () async {
                                                                                                                                  if (data?.containsKey('lock') == false) {
                                                                                                                                    await chatDocs[index].reference.update({'lock': false});
                                                                                                                                  }
                                                                                                                                  CustomFullScreenDialog.showDialog();
                                                                                                                                  await _bulletinRoomModelController.lock('${chatDocs[index]['uid']}#${chatDocs[index]['bulletinRoomCount']}');
                                                                                                                                  Navigator.pop(context);
                                                                                                                                  CustomFullScreenDialog.cancelDialog();
                                                                                                                                },
                                                                                                                                child: Text('확인',
                                                                                                                                  style: TextStyle(
                                                                                                                                      color: Colors.white,
                                                                                                                                      fontSize: 15,
                                                                                                                                      fontWeight: FontWeight.bold),
                                                                                                                                ),
                                                                                                                                style: TextButton.styleFrom(
                                                                                                                                    splashFactory: InkRipple.splashFactory,
                                                                                                                                    elevation: 0,
                                                                                                                                    minimumSize: Size(100, 56),
                                                                                                                                    backgroundColor: Color(0xff2C97FB),
                                                                                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                );
                                                                                                              });
                                                                                                        },
                                                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          }),
                                                                                  child: Icon(Icons.more_horiz,
                                                                                    color: Color(0xFFEF0069),
                                                                                    size: 20,
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.only(left: 16),
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(50),
                                                                            color: Color(0xFFE1EDFF),
                                                                          ),
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.only(top: 2, bottom: 4, left: 8, right: 8),
                                                                            child: Text(
                                                                              chatDocs[index].get('bulletinRoomReplyCount').toString(),
                                                                              maxLines: 1,
                                                                              overflow:  TextOverflow.ellipsis,
                                                                              style: TextStyle(
                                                                                  fontWeight: FontWeight.normal,
                                                                                  fontSize: 11,
                                                                                  color: Color(0xFF3D83ED)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  chatDocs[index].get('location'),
                                                                  style: TextStyle(
                                                                      fontSize: 13,
                                                                      color: Color(0xFF949494),
                                                                      fontWeight: FontWeight.normal),
                                                                ),
                                                                Text(
                                                                  '   $_time',
                                                                  style: TextStyle(
                                                                      fontSize: 13,
                                                                      color: Color(0xFF949494),
                                                                      fontWeight: FontWeight.normal),
                                                                ),
                                                                SizedBox(width: 10,),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons.remove_red_eye_rounded,
                                                                      color: Color(0xFFc8c8c8),
                                                                      size: 15,
                                                                    ),
                                                                    SizedBox(width: 4,),
                                                                    Text(
                                                                        '${viewerUid.length.toString()}',
                                                                        style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Color(0xFF949494),
                                                                            fontWeight: FontWeight.normal)
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
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
                                  Divider(
                                    color: Color(0xFFECECEC),
                                    height: 24,
                                    thickness: 0.5,
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
