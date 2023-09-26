import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/controller/vm_fleaMarketController.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarket_Upload.dart';
import 'package:com.snowlive/screens/fleaMarket/v_phone_Auth_Screen.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class FleaMarket_List_Screen extends StatefulWidget {
  const FleaMarket_List_Screen({Key? key}) : super(key: key);

  @override
  State<FleaMarket_List_Screen> createState() => _FleaMarket_List_ScreenState();
}

class _FleaMarket_List_ScreenState extends State<FleaMarket_List_Screen> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();

//TODO: Dependency Injection**************************************************

  var _stream;
  var _selectedValue = '카테고리';
  var _selectedValue2 = '거래장소';
  var _allCategories;

  var f = NumberFormat('###,###,###,###');

  ScrollController _scrollController = ScrollController();
  bool _showAddButton = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        .collection('fleaMarket')
        .where('category',
            isEqualTo:
                (_selectedValue == '카테고리') ? _allCategories : '$_selectedValue')
        .where('location', isEqualTo: (_selectedValue2 == '거래장소') ? _allCategories : '$_selectedValue2')
        .orderBy('timeStamp', descending: true)
        .limit(500)
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
                          Navigator.pop(context);
                        },
                        child: Text('데크')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '바인딩';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('바인딩')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '부츠';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('부츠')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '의류';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('의류')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '플레이트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('플레이트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue = '기타';
                          });
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

                // CupertinoPicker(
                //   magnification: 1.1,
                //   backgroundColor: Colors.white,
                //   itemExtent: 40,
                //   children: [
                //     ..._categories.map((e) => Text(e))
                //   ],
                //   onSelectedItemChanged: (i) {
                //     setState(() {
                //       _selectedValue = _categories[i];
                //     });
                //   },
                //   scrollController: _scrollWheelController,
                // ),

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
                            _selectedValue2 = '거래장소';
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
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedValue2 = '기타지역';
                          });
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

              // CupertinoPicker(
              //   magnification: 1.1,
              //   backgroundColor: Colors.white,
              //   itemExtent: 40,
              //   children: [
              //     ..._categories.map((e) => Text(e))
              //   ],
              //   onSelectedItemChanged: (i) {
              //     setState(() {
              //       _selectedValue = _categories[i];
              //     });
              //   },
              //   scrollController: _scrollWheelController,
              // ),

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
                          : Scrollbar(
                        controller: _scrollController,
                        child: ListView.builder(
                        controller: _scrollController, // ScrollController 연결
                        itemCount: chatDocs.length,
                        itemBuilder: (context, index) {
                            String _time = _fleaModelController
                                .getAgoTime(chatDocs[index].get('timeStamp'));
                            return GestureDetector(
                              onTap: () async {
                                if (_userModelController.repoUidList!
                                    .contains(chatDocs[index].get('uid'))) {
                                  return;
                                }

                                CustomFullScreenDialog.showDialog();
                                await _fleaModelController.getCurrentFleaItem(
                                    uid: chatDocs[index].get('uid'),
                                    fleaCount:
                                        chatDocs[index].get('fleaCount'));
                                await _fleaModelController.updateViewerUid();
                                CustomFullScreenDialog.cancelDialog();
                                print(_fleaModelController.itemImagesUrls);
                                Get.to(() => FleaMarket_List_Detail());
                              },
                              child: Obx(() => Column(
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            (_userModelController.repoUidList!
                                                    .contains(chatDocs[index]
                                                        .get('uid')))
                                                ? Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 12),
                                                      child: Text(
                                                        '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xffc8c8c8)),
                                                      ),
                                                    ),
                                                  )
                                                : Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (List.from(chatDocs[
                                                                  index][
                                                              'itemImagesUrls'])
                                                          .isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 8,
                                                                  bottom: 8),
                                                          child: ExtendedImage
                                                              .network(
                                                            chatDocs[index][
                                                                'itemImagesUrls'][0],
                                                            cache: true,
                                                            shape: BoxShape
                                                                .rectangle,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                width: 0.5,
                                                                color: Color(
                                                                    0xFFdedede)),
                                                            width: 100,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      if (List.from(chatDocs[
                                                                  index][
                                                              'itemImagesUrls'])
                                                          .isEmpty)
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 8,
                                                                  bottom: 8),
                                                          child: ExtendedImage
                                                              .asset(
                                                            'assets/imgs/profile/img_profile_default_.png',
                                                            shape: BoxShape
                                                                .rectangle,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            width: 100,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      SizedBox(width: 16),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 6),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  constraints: BoxConstraints(
                                                                      maxWidth:
                                                                          _size.width -
                                                                              150),
                                                                  child: Text(
                                                                    chatDocs[
                                                                            index]
                                                                        .get(
                                                                            'title'),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        fontSize:
                                                                            15,
                                                                        color: Color(
                                                                            0xFF555555)),
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
                                                                          '${chatDocs[index]['viewerUid'].length.toString()}',
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
                                                                  constraints: BoxConstraints(
                                                                      maxWidth:
                                                                          _size.width -
                                                                              106),
                                                                  child: (chatDocs[index]
                                                                              .get('soldOut') ==
                                                                          false)
                                                                      ? Text(
                                                                          f.format(chatDocs[index].get('price')) +
                                                                              ' 원',
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              color: Color(0xFF111111),
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16),
                                                                        )
                                                                      : Text(
                                                                          '거래완료',
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              color: Color(0xFF111111),
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16),
                                                                        ),
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
                                                    ],
                                                  ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color: Color(0xFFDEDEDE),
                                        height: 24,
                                        thickness: 0.5,
                                      ),
                                    ],
                                  )),
                            );
                        },
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
