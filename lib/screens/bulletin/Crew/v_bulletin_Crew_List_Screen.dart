import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/model/m_bulletinCrewModel.dart';
import 'package:snowlive3/screens/bulletin/Crew/v_bulletin_Crew_List_Detail.dart';
import 'package:snowlive3/screens/bulletin/Crew/v_bulletin_Crew_Upload.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import 'package:snowlive3/screens/fleaMarket/v_phone_Auth_Screen.dart';
import '../../../controller/vm_bulletinCrewController.dart';
import '../../../controller/vm_timeStampController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../widget/w_fullScreenDialog.dart';

class Bulletin_Crew_List_Screen extends StatefulWidget {
  const Bulletin_Crew_List_Screen({Key? key}) : super(key: key);

  @override
  State<Bulletin_Crew_List_Screen> createState() => _Bulletin_Crew_List_ScreenState();
}

class _Bulletin_Crew_List_ScreenState extends State<Bulletin_Crew_List_Screen> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinCrewModelController _bulletinCrewModelController = Get.find<BulletinCrewModelController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
//TODO: Dependency Injection**************************************************

  var _stream;
  var _selectedValue = '전체';
  var _selectedValue2 = '전체';
  var _allCategories;

  var f = NumberFormat('###,###,###,###');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stream = newStream();
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('bulletinCrew')
        .where('category',
            isEqualTo:
                (_selectedValue == '전체') ? _allCategories : '$_selectedValue')
        .where('location', isEqualTo: (_selectedValue2 == '전체') ? _allCategories : '$_selectedValue2')
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
                height: 360,
                padding: EdgeInsets.only(left: 20, right: 20),
                child: CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue = '전체';
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          '전체',
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue = '단톡방';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('단톡방')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue = '동호회(크루)';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('동호회(크루)')),
                    CupertinoActionSheetAction(
                        onPressed: () {
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
                          setState(() {
                            _selectedValue2 = '전체';
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          '전체',
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '전국';
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          '전국',
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '곤지암리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('곤지암리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '무주덕유산리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('무주덕유산리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '비발디파크';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('비발디파크')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '알펜시아';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('알펜시아')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '에덴벨리리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('에덴벨리리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '엘리시안강촌';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('엘리시안강촌')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '오크밸리리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('오크밸리리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '오투리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('오투리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '용평리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('용평리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '웰리힐리파크';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('웰리힐리파크')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '지산리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('지산리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          setState(() {
                            _selectedValue2 = '하이원리조트';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('하이원리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFF3D6FED),
            onPressed: () async {
              await _userModelController
                  .getCurrentUser(_userModelController.uid);
              Get.to(() => Bulletin_Crew_Upload());
            },
            child: Icon(Icons.add),
          ),
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
                                        ? Text('전체',
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
                                        ? Text('전체',
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
                    return Scrollbar(
                      child: ListView.builder(
                        itemCount: chatDocs.length,
                        itemBuilder: (context, index) {
                          String _time = _timeStampController.yyyymmddFormat(chatDocs[index].get('timeStamp'));
                          return GestureDetector(
                            onTap: () async {
                              if (_userModelController.repoUidList!
                                  .contains(chatDocs[index].get('uid'))) {
                                return;
                              }
                              CustomFullScreenDialog.showDialog();
                              await _bulletinCrewModelController.getCurrentBulletinCrew(
                                  uid: chatDocs[index].get('uid'),
                                  bulletinCrewCount:
                                  chatDocs[index].get('bulletinCrewCount'));
                              CustomFullScreenDialog.cancelDialog();
                              Get.to(() => Bulletin_Crew_List_Detail());
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
                                                                      child: Text(
                                                                        chatDocs[index].get('title'),
                                                                        maxLines: 2,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 15,
                                                                            color: Color(0xFF111111)),
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
                                                                          chatDocs[index].get('bulletinCrewReplyCount').toString(),
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
                                                            Text('   $_time',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Color(0xFF949494),
                                                                  fontWeight: FontWeight.normal),
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
                      ),
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