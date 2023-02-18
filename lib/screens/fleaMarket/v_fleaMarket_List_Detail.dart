import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_fleaChatController.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Chatroom.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_ModifyPage.dart';
import 'package:snowlive3/screens/fleaMarket/v_phone_Auth_Screen.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class FleaMarket_List_Detail extends StatefulWidget {
  FleaMarket_List_Detail({Key? key}) : super(key: key);

  @override
  State<FleaMarket_List_Detail> createState() => _FleaMarket_List_DetailState();
}

class _FleaMarket_List_DetailState extends State<FleaMarket_List_Detail> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
  FleaChatModelController _fleaChatModelController =
      Get.find<FleaChatModelController>();

//TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    String _time =
        _fleaModelController.getAgoTime(_fleaModelController.timeStamp);
    Size _size = MediaQuery.of(context).size;
    bool isSoldOut = _fleaModelController.soldOut!;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
                onTap: () {
                  Get.back();
                },
              ),
              actions: [
                (_fleaModelController.uid != _userModelController.uid)
                    ? GestureDetector(
                        onTap: () => showModalBottomSheet(
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 180,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 14),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Center(
                                            child: Text(
                                              '신고하기',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          //selected: _isSelected[index]!,
                                          onTap: () async {
                                            Get.dialog(AlertDialog(
                                              contentPadding: EdgeInsets.only(
                                                  bottom: 0,
                                                  left: 20,
                                                  right: 20,
                                                  top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              buttonPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 0),
                                              content: Text(
                                                '이 회원을 신고하시겠습니까?',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                              actions: [
                                                Row(
                                                  children: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          '취소',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFF949494),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )),
                                                    TextButton(
                                                        onPressed: () async {
                                                          var repoUid =
                                                              _fleaModelController
                                                                  .uid;
                                                          await _userModelController
                                                              .repoUpdate(
                                                                  repoUid);
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          '신고',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFF3D83ED),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ))
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                )
                                              ],
                                            ));
                                          },
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                      GestureDetector(
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Center(
                                            child: Text(
                                              '이 회원의 글 모두 숨기기',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          //selected: _isSelected[index]!,
                                          onTap: () async {
                                            Get.dialog(AlertDialog(
                                              contentPadding: EdgeInsets.only(
                                                  bottom: 0,
                                                  left: 20,
                                                  right: 20,
                                                  top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                              buttonPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 0),
                                              content: Text(
                                                '이 회원의 게시물을 모두 숨길까요?\n이 동작은 취소할 수 없습니다.',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                              actions: [
                                                Row(
                                                  children: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          '취소',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFF949494),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )),
                                                    TextButton(
                                                        onPressed: () {
                                                          var repoUid =
                                                              _fleaModelController
                                                                  .uid;
                                                          _userModelController
                                                              .updateRepoUid(
                                                                  repoUid);
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          '확인',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFF3D83ED),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ))
                                                  ],
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                )
                                              ],
                                            ));
                                          },
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 1, right: 10),
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 28,
                            color: Color(0xFF111111),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => showModalBottomSheet(
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 130,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 14),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Center(
                                            child: Text(
                                              '삭제',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
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
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 20.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: 30,
                                                          ),
                                                          Text(
                                                            '삭제하시겠습니까?',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xFF111111)),
                                                          ),
                                                          SizedBox(
                                                            height: 30,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                    '취소',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  style: TextButton.styleFrom(
                                                                      splashFactory:
                                                                          InkRipple
                                                                              .splashFactory,
                                                                      elevation:
                                                                          0,
                                                                      minimumSize:
                                                                          Size(
                                                                              100,
                                                                              56),
                                                                      backgroundColor:
                                                                          Color(
                                                                              0xff555555),
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              0)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    CustomFullScreenDialog
                                                                        .showDialog();
                                                                    try {
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'fleaMarket')
                                                                          .doc(
                                                                              '${_userModelController.uid}#${_fleaModelController.fleaCount}')
                                                                          .delete();
                                                                      Navigator.pop(
                                                                          context);
                                                                    } catch (e) {}
                                                                    print(
                                                                        '댓글 삭제 완료');
                                                                    Navigator.pop(
                                                                        context);
                                                                    CustomFullScreenDialog
                                                                        .cancelDialog();
                                                                  },
                                                                  child: Text(
                                                                    '확인',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  style: TextButton.styleFrom(
                                                                      splashFactory:
                                                                          InkRipple
                                                                              .splashFactory,
                                                                      elevation:
                                                                          0,
                                                                      minimumSize:
                                                                          Size(
                                                                              100,
                                                                              56),
                                                                      backgroundColor:
                                                                          Color(
                                                                              0xff2C97FB),
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              0)),
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
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 1, right: 10),
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 28,
                            color: Color(0xFF111111),
                          ),
                        ),
                      )
              ],
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ),
          body: Column(
            children: [
              Container(
                height: _size.height - 227,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_fleaModelController.itemImagesUrls!.isEmpty)
                        Container(
                          color: Color(0xFFDEDEDE),
                          child: ExtendedImage.asset(
                            'assets/imgs/profile/img_profile_default_.png',
                            fit: BoxFit.fitHeight,
                            width: _size.width,
                            height: 280,
                          ),
                        ),
                      if (_fleaModelController.itemImagesUrls!.isNotEmpty)
                        CarouselSlider.builder(
                          options: CarouselOptions(
                            height: 280,
                            viewportFraction: 1,
                            enableInfiniteScroll: false,
                          ),
                          itemCount: _fleaModelController.itemImagesUrls!.length,
                          itemBuilder: (context, index, pageViewIndex) {
                            return Container(
                              child: StreamBuilder<Object>(
                                  stream: null,
                                  builder: (context, snapshot) {
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ExtendedImage.network(
                                          _fleaModelController.itemImagesUrls![index],
                                          fit: BoxFit.cover,
                                          width: _size.width,
                                          height: 280,
                                        ),
                                      ],
                                    );
                                  }),
                            );
                          },
                        ),
                      SizedBox(
                        height: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                            child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (_fleaModelController.profileImageUrl!.isEmpty)
                                  ExtendedImage.asset(
                                    'assets/imgs/profile/img_profile_default_circle.png',
                                    shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(20),
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                  ),
                                if (_fleaModelController.profileImageUrl!.isNotEmpty)
                                  ExtendedImage.network(
                                    '${_fleaModelController.profileImageUrl}',
                                    shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(20),
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                  ),
                                SizedBox(width: 12),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${_fleaModelController.displayName}',
                                                //chatDocs[index].get('displayName'),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Color(0xFF111111)),
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                '$_time',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF949494),
                                                    fontWeight: FontWeight.w300),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                            )
                          ],
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (_fleaModelController.soldOut == true)
                                        ? '거래완료'
                                        : '${_fleaModelController.title}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: Color(0xFFD7F4FF),
                                    ),
                                    padding: EdgeInsets.only(
                                        right: 6, left: 6, top: 2, bottom: 3),
                                    child: Text(
                                      '${_fleaModelController.category}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
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
                                    padding: EdgeInsets.only(
                                        right: 6, left: 6, top: 2, bottom: 3),
                                    child: Text(
                                      '${_fleaModelController.location}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF17AD4A)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '물품명',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFFB7B7B7)),
                                  ),
                                  Text(
                                    '${_fleaModelController.itemName}',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '금액',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFB7B7B7)),
                                      ),
                                      Container(
                                        width: _size.width / 2 - 32,
                                        child: Text(
                                          '${_fleaModelController.price} 원',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '거래방식',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFFB7B7B7)),
                                      ),
                                      Container(
                                        width: _size.width / 2 - 32,
                                        child: Text(
                                          '${_fleaModelController.method}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(
                                height: 50,
                                thickness: 0.5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '상세설명',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFFB7B7B7)),
                                  ),
                                  Container(
                                    width: _size.width,
                                    child: Text(
                                      '${_fleaModelController.description}',
                                      maxLines: 500,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                      SizedBox(
                        height: 40,
                      ),

                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 16,
                            bottom:
                            MediaQuery.of(context).viewInsets.bottom + 16,
                            right: 5),
                        child: TextButton(
                            onPressed: () async {
                              CustomFullScreenDialog.showDialog();

                              await _userModelController
                                  .getCurrentUser(_userModelController.uid);

                              if (_userModelController.phoneAuth == true) {
                                try {
                                  if (_fleaModelController.uid !=
                                      _userModelController.uid) {
                                    await _userModelController.getCurrentUser(
                                        _userModelController.uid);
                                    if (_userModelController.fleaChatUidList!
                                        .contains(_fleaModelController.uid)) {
                                      _fleaChatModelController
                                          .getCurrentFleaChat(
                                          myUid: _userModelController.uid,
                                          otherUid:
                                          _fleaModelController.uid);
                                      await _fleaChatModelController
                                          .resetMyChatCheckCount(
                                          chatRoomName:
                                          '${_fleaChatModelController.chatRoomName}');
                                      await _fleaChatModelController
                                          .setOtherChatCountUid(
                                          chatRoomName:
                                          _fleaChatModelController
                                              .chatRoomName);
                                      await _userModelController
                                          .addChatUidList(
                                          otherAddUid:
                                          _fleaModelController.uid,
                                          myAddUid:
                                          _userModelController.uid);
                                      print('기존에 존재하는 채팅방으로 이동');
                                    } else {
                                      await _userModelController
                                          .addChatUidList(
                                          otherAddUid:
                                          _fleaModelController.uid,
                                          myAddUid:
                                          _userModelController.uid);
                                      await _fleaChatModelController
                                          .createChatroom(
                                        myUid: _userModelController.uid,
                                        otherUid: _fleaModelController.uid,
                                        otherProfileImageUrl:
                                        _fleaModelController
                                            .profileImageUrl,
                                        otherResortNickname:
                                        _fleaModelController
                                            .resortNickname,
                                        otherDisplayName:
                                        _fleaModelController.displayName,
                                        myDisplayName:
                                        _userModelController.displayName,
                                        myProfileImageUrl:
                                        _userModelController
                                            .profileImageUrl,
                                        myResortNickname: _userModelController
                                            .resortNickname,
                                      );
                                    }
                                    CustomFullScreenDialog.cancelDialog();
                                    return Get.to(() => FleaChatroom());
                                  } else {
                                    CustomFullScreenDialog.cancelDialog();
                                    return Get.to(
                                            () => FleaMarket_ModifyPage());
                                  }
                                } catch (e) {
                                  print('에러');
                                }
                              } else if (_userModelController.phoneAuth ==
                                  false) {
                                CustomFullScreenDialog.cancelDialog();
                                Get.to(() => PhoneAuthScreen());
                              } else {}
                            },
                            style: TextButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                                elevation: 0,
                                splashFactory: InkRipple.splashFactory,
                                minimumSize: Size(1000, 56),
                                backgroundColor: (_fleaModelController.uid !=
                                    _userModelController.uid)
                                    ? Color(0xff3D83ED)
                                    : Color(0xFF555555)),
                            child: (_fleaModelController.uid !=
                                _userModelController.uid)
                                ? Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '메시지 보내기',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            )
                                : Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '수정하기',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            )),
                      ),
                    ),
                    (_fleaModelController.uid == _userModelController.uid)
                        ? Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 5, top: 16),
                        child: TextButton(
                            onPressed: () async {
                              CustomFullScreenDialog.showDialog();
                              await _fleaModelController
                                  .updateState(isSoldOut);
                              setState(() {});
                              CustomFullScreenDialog.cancelDialog();
                            },
                            style: TextButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(6))),
                                elevation: 0,
                                splashFactory: InkRipple.splashFactory,
                                minimumSize: Size(1000, 56),
                                backgroundColor: Color(0xff377EEA)),
                            child: (_fleaModelController.soldOut ==
                                true)
                                ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 4),
                              child: Text(
                                '거래가능으로 변경',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            )
                                : Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 4),
                              child: Text(
                                '거래완료',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            )),
                      ),
                    )
                        : SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
