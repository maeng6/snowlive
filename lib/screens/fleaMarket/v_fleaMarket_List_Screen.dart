import 'package:com.snowlive/controller/public/vm_limitController.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/controller/fleaMarket/vm_fleaMarketController.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarket_Upload.dart';
import 'package:com.snowlive/screens/fleaMarket/v_phone_Auth_Screen.dart';
import '../../controller/fleaMarket/vm_streamController_fleaMarket.dart';
import '../../controller/user/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';
import '../snowliveDesignStyle.dart';

class FleaMarket_List_Screen extends StatefulWidget {
  const FleaMarket_List_Screen({Key? key}) : super(key: key);

  @override
  State<FleaMarket_List_Screen> createState() => _FleaMarket_List_ScreenState();
}

class _FleaMarket_List_ScreenState extends State<FleaMarket_List_Screen> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
  limitController _seasonController = Get.find<limitController>();
  StreamController_fleaMarket _streamController_fleaMarket = Get.find<StreamController_fleaMarket>();
//TODO: Dependency Injection**************************************************

  var _selectedValue = '카테고리';
  var _selectedValue2 = '거래장소';

  Stream<QuerySnapshot<Map<String, dynamic>>>? _fleaStream;

  var f = NumberFormat('###,###,###,###');

  ScrollController _scrollController = ScrollController();
  bool _showAddButton = true;
  bool _isVisible = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _seasonController.getFleaMarketLimit();

    setState(() {
      _streamController_fleaMarket.setSelectedValues('카테고리', _selectedValue2);
      _streamController_fleaMarket.setSelectedValues(_selectedValue, '거래장소');
      _fleaStream = _streamController_fleaMarket.fleaStream_fleaMarket_List_Screen.value;
    });

    // Add a listener to the ScrollController
    _scrollController.addListener(() {
      setState(() {
        // Check if the user has scrolled down by a certain offset (e.g., 100 pixels)
        _showAddButton = _scrollController.offset <= 0;
      });
    });

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

    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'visit_fleaMarket',
        parameters: <String, Object>{
          'user_id': _userModelController.uid!,
          'user_name': _userModelController.displayName!,
          'user_resort': _userModelController.favoriteResort!
        },
      );
    } catch (e, stackTrace) {
      print('GA 업데이트 오류: $e');
      print('Stack trace: $stackTrace');
    }


  }

  _showCupertinoPicker() async {
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
                            _selectedValue = '카테고리';
                          });
                          _streamController_fleaMarket.setSelectedValues('카테고리', _selectedValue2);
                          Navigator.pop(context);
                        },
                        child: Text(
                          '전체',
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '데크';
                          });
                          _streamController_fleaMarket.setSelectedValues('데크', _selectedValue2);
                          Navigator.pop(context);
                        },
                        child: Text('데크')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '바인딩';
                          });
                          _streamController_fleaMarket.setSelectedValues('바인딩', _selectedValue2);
                          Navigator.pop(context);
                        },
                        child: Text('바인딩')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '부츠';
                          });
                          _streamController_fleaMarket.setSelectedValues('부츠', _selectedValue2);
                          Navigator.pop(context);
                        },
                        child: Text('부츠')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '의류';
                          });
                          _streamController_fleaMarket.setSelectedValues('의류', _selectedValue2);
                          Navigator.pop(context);
                        },
                        child: Text('의류')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '플레이트';
                          });
                          _streamController_fleaMarket.setSelectedValues('플레이트', _selectedValue2);
                          Navigator.pop(context);
                        },
                        child: Text('플레이트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '기타';
                          });
                          _streamController_fleaMarket.setSelectedValues('기타', _selectedValue2);
                          Navigator.pop(context);
                        },
                        child: Text('기타')),
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
      _fleaStream = _streamController_fleaMarket.fleaStream_fleaMarket_List_Screen.value;
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
                            _selectedValue2 = '거래장소';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '거래장소');
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
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '곤지암리조트');
                          Navigator.pop(context);
                        },
                        child: Text('곤지암리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '무주덕유산리조트';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '무주덕유산리조트');
                          Navigator.pop(context);
                        },
                        child: Text('무주덕유산리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '비발디파크';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '비발디파크');
                          Navigator.pop(context);
                        },
                        child: Text('비발디파크')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '알펜시아';
                            _streamController_fleaMarket.setSelectedValues(_selectedValue, '알펜시아');
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
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '에덴벨리리조트');
                          Navigator.pop(context);
                        },
                        child: Text('에덴밸리리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '엘리시안강촌';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '엘리시안강촌');
                          Navigator.pop(context);
                        },
                        child: Text('엘리시안강촌')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '오크밸리리조트';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '오크밸리리조트');
                          Navigator.pop(context);
                        },
                        child: Text('오크밸리리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '오투리조트';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '오투리조트');
                          Navigator.pop(context);
                        },
                        child: Text('오투리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '용평리조트';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '용평리조트');
                          Navigator.pop(context);
                        },
                        child: Text('용평리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '웰리힐리파크';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '웰리힐리파크');
                          Navigator.pop(context);
                        },
                        child: Text('웰리힐리파크')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '지산리조트';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '지산리조트');
                          Navigator.pop(context);
                        },
                        child: Text('지산리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '하이원리조트';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '하이원리조트');
                          Navigator.pop(context);
                        },
                        child: Text('하이원리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '휘닉스파크';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '휘닉스파크');
                          Navigator.pop(context);
                        },
                        child: Text('휘닉스파크')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '기타지역';
                          });
                          _streamController_fleaMarket.setSelectedValues(_selectedValue, '기타지역');
                          Navigator.pop(context);
                        },
                        child: Text('기타지역')),
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
      _fleaStream = _streamController_fleaMarket.fleaStream_fleaMarket_List_Screen.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    _seasonController.getFleaMarketLimit();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          floatingActionButton: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: _size.height - 308),
                  child: Visibility(
                    visible: _isVisible,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Container(
                        width: 106,
                        child: FloatingActionButton(
                          heroTag: 'liveTalkScreen',
                          mini: true,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)
                          ),
                          backgroundColor: Color(0xFF000000).withOpacity(0.8),
                          foregroundColor: Colors.white,
                          onPressed: () {
                            _scrollController.jumpTo(0);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_upward_rounded,
                                  color: Color(0xFFffffff),
                                  size: 16),
                              Padding(
                                padding: const EdgeInsets.only(left: 2, right: 3),
                                child: Text('최신글 보기',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFffffff).withOpacity(0.8),
                                      letterSpacing: 0
                                  ),),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                child: Transform.translate(
                  offset: Offset(18, 0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: AnimatedContainer(
                      width: _showAddButton ? 104 : 52,
                      height: 52,
                      duration: Duration(milliseconds: 200),
                      child: FloatingActionButton.extended(
                        elevation: 4,
                        heroTag: 'fleaListScreen',
                        onPressed: () async {
                          await _userModelController.getCurrentUser(_userModelController.uid);
                          if (_userModelController.phoneAuth == true) {
                            Get.to(() => FleaMarket_Upload());
                          } else if (_userModelController.phoneAuth == false) {
                            Get.to(() => PhoneAuthScreen());
                          } else {}
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
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Column(
              children: [
                Row(
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
                                        backgroundColor: SDSColor.gray50,
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
                                        backgroundColor: SDSColor.gray50,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8))),
                                    child: (_selectedValue2 == null)
                                        ? Text('거래장소',
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
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _fleaStream,
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
                          : Scrollbar(
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController, // ScrollController 연결
                          itemCount: chatDocs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic>? data = chatDocs[index].data() as Map<String, dynamic>?;

                            // 필드가 없을 경우 기본값 설정
                            bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;
                            List viewerUid = data?.containsKey('viewerUid') == true ? data!['viewerUid'] : [];
                            String _time = _fleaModelController
                                .getAgoTime(chatDocs[index].get('timeStamp'));
                            return GestureDetector(
                                onTap: () async {
                                  if(isLocked == false) {
                                    if (_userModelController.repoUidList!
                                        .contains(chatDocs[index].get('uid'))) {
                                      return;
                                    }
                                    CustomFullScreenDialog.showDialog();
                                    await _fleaModelController.getCurrentFleaItem(
                                        uid: chatDocs[index].get('uid'),
                                        fleaCount:
                                        chatDocs[index].get('fleaCount'));
                                    if (data?.containsKey('lock') == false) {
                                      await chatDocs[index].reference.update({'viewerUid': []});
                                    }
                                    await   _streamController_fleaMarket.setupStreams_fleaMarket_List_Detail();
                                    await _fleaModelController.updateViewerUid();
                                    CustomFullScreenDialog.cancelDialog();
                                    print(_fleaModelController.itemImagesUrls);
                                    Get.to(() => FleaMarket_List_Detail());
                                  }else{}
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          (isLocked== true)
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
                                                                                              (isLocked== false)
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
                                                                                                      await _fleaModelController.lock('${chatDocs[index]['uid']}#${chatDocs[index]['fleaCount']}');
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
                                              : (_userModelController.repoUidList!.contains(chatDocs[index].get('uid')))
                                              ? Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                                              Stack(
                                                children: [
                                                  if (List.from(chatDocs[index]['itemImagesUrls']).isNotEmpty)
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 8, bottom: 8),
                                                      child: ExtendedImage.network(chatDocs[index]['itemImagesUrls'][0],
                                                        cache: true,
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                                        width: 100,
                                                        height: 100,
                                                        cacheHeight: 250,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  if (List.from(chatDocs[index]['itemImagesUrls']).isEmpty)
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 8, bottom: 8),
                                                      child: ExtendedImage
                                                          .asset(
                                                        'assets/imgs/profile/img_profile_default_.png',
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(8),
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),

                                                  (chatDocs[index].get('soldOut') == false)
                                                      ? Container()
                                                      : Positioned(
                                                    top: 8,
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(8),
                                                            color: Color(0xFF000000).withOpacity(0.6),
                                                          ),
                                                          width: 100,
                                                          height: 100,
                                                        ),
                                                        Positioned(
                                                          top: 40,
                                                          left: 20,
                                                          child: Text('거래 완료',
                                                            style: TextStyle(
                                                                color: Color(0xFFFFFFFF),
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16
                                                            ),),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 16),
                                              (chatDocs[index].get('soldOut') == false)
                                                  ? Padding(
                                                padding:
                                                const EdgeInsets.symmetric(vertical: 6),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          constraints: BoxConstraints(
                                                              maxWidth: _size.width - 170),
                                                          child: Text(
                                                            chatDocs[index].get('title'),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 15,
                                                                color: Color(0xFF555555)),
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
                                                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                                                          child: Column(
                                                                            children: [
                                                                              GestureDetector(
                                                                                child: ListTile(
                                                                                  contentPadding: EdgeInsets.zero,
                                                                                  title: Center(
                                                                                    child: Text(
                                                                                      (isLocked== false)
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
                                                                                                    (isLocked== false)
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
                                                                                                            await _fleaModelController.lock('${chatDocs[index]['uid']}#${chatDocs[index]['fleaCount']}');
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
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          '$_time',
                                                          style: TextStyle(
                                                              fontSize:
                                                              14,
                                                              color: Color(
                                                                  0xFF949494),
                                                              fontWeight:
                                                              FontWeight
                                                                  .normal),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 2),
                                                          child: Row(
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
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 2,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                            constraints: BoxConstraints(maxWidth: _size.width - 106),
                                                            child: Text(
                                                              f.format(chatDocs[index].get('price')) + ' 원',
                                                              maxLines:
                                                              1,
                                                              overflow:
                                                              TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  color: Color(0xFF111111),
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16),
                                                            )
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                          BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius.circular(3),
                                                            color: Color(0xFFD7F4FF),
                                                          ),
                                                          padding: EdgeInsets.only(
                                                              right: 6,
                                                              left: 6,
                                                              top: 2,
                                                              bottom: 3),
                                                          child: Text(
                                                            chatDocs[index].get('category'),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                fontSize: 12,
                                                                color: Color(0xFF458BF5)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 6,
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: Color(0xFFD5F7E0),
                                                          ),
                                                          padding: EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 3),
                                                          child: Text(
                                                            chatDocs[index].get('location'),
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                                color: Color(0xFF17AD4A)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                                  : Opacity(
                                                opacity: 0.35,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            constraints: BoxConstraints(
                                                                maxWidth: _size.width - 170),
                                                            child: Text(
                                                              chatDocs[index].get('title'),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.normal,
                                                                  fontSize: 15,
                                                                  color: Color(0xFF555555)),
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
                                                                                        (isLocked== false)
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
                                                                                                      (isLocked== false)
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
                                                                                                              await _fleaModelController.lock('${chatDocs[index]['uid']}#${chatDocs[index]['fleaCount']}');
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
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            '$_time',
                                                            style: TextStyle(
                                                                fontSize:
                                                                14,
                                                                color: Color(
                                                                    0xFF949494),
                                                                fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                          ),
                                                          SizedBox(width: 10,),
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 2),
                                                            child: Row(
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
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                              constraints: BoxConstraints(maxWidth: _size.width - 106),
                                                              child: Text(
                                                                f.format(chatDocs[index].get('price')) + ' 원',
                                                                maxLines:
                                                                1,
                                                                overflow:
                                                                TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    color: Color(0xFF111111),
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 16),
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            decoration:
                                                            BoxDecoration(
                                                              borderRadius:
                                                              BorderRadius.circular(3),
                                                              color: Color(0xFFD7F4FF),
                                                            ),
                                                            padding: EdgeInsets.only(
                                                                right: 6,
                                                                left: 6,
                                                                top: 2,
                                                                bottom: 3),
                                                            child: Text(
                                                              chatDocs[index].get('category'),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: 12,
                                                                  color: Color(0xFF458BF5)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 6,
                                                          ),
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(3),
                                                              color: Color(0xFFD5F7E0),
                                                            ),
                                                            padding: EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 3),
                                                            child: Text(
                                                              chatDocs[index].get('location'),
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12,
                                                                  color: Color(0xFF17AD4A)),
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
                                        ],
                                      ),
                                    ),
                                    if (chatDocs.length != index + 1)
                                    Divider(
                                      color: Color(0xFFDEDEDE),
                                      height: 16,
                                      thickness: 0.5,
                                    ),
                                  ],
                                )
                            );
                          },
                          padding: EdgeInsets.only(bottom: 80),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
