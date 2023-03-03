import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/screens/bulletin/Crew/v_bulletin_Crew_Upload.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import 'package:snowlive3/screens/fleaMarket/v_phone_Auth_Screen.dart';
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
  FleaModelController _fleaModelController = Get.find<FleaModelController>();

//TODO: Dependency Injection**************************************************

  var _stream;
  var _selectedValue = '전체';
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
        .collection('fleaMarket')
        .where('category',
            isEqualTo:
                (_selectedValue == '전체') ? _allCategories : '$_selectedValue')
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
                            _selectedValue = '동호회';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('동호회')),

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
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFF3D6FED),
            onPressed: () async {
              await _userModelController
                  .getCurrentUser(_userModelController.uid);
              if (_userModelController.phoneAuth == true) {
                Get.to(() => Bulletin_Crew_Upload());
              } else if (_userModelController.phoneAuth == false) {
                Get.to(() => PhoneAuthScreen());
              } else {}
            },
            child: Icon(Icons.add),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              children: [
                Container(
                  height: 68,
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
                                      right: 36, left: 16, top: 12, bottom: 12),
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFDEDEDE),
                                  ),
                                  primary: Color(0xFFFFFFFF),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
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
                            top: 11,
                            right: 8,
                            child: GestureDetector(
                              onTap: () async {
                                await _showCupertinoPicker();
                              },
                              child: Icon(
                                Icons.arrow_drop_down_sharp,
                                size: 26,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),
                        ],
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
                                        height: 32,
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
