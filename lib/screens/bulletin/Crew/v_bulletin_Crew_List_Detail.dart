import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/bulletin/Crew/v_bulletinCrewImageScreen.dart';
import 'package:snowlive3/screens/bulletin/Crew/v_bulletin_Crew_ModifyPage.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_bulletinCrewController.dart';

class Bulletin_Crew_List_Detail extends StatefulWidget {
  Bulletin_Crew_List_Detail({Key? key}) : super(key: key);

  @override
  State<Bulletin_Crew_List_Detail> createState() =>
      _Bulletin_Crew_List_DetailState();
}

class _Bulletin_Crew_List_DetailState extends State<Bulletin_Crew_List_Detail> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinCrewModelController _bulletinCrewModelController = Get.find<BulletinCrewModelController>();
//TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    String _time =
    _bulletinCrewModelController.getAgoTime(_bulletinCrewModelController.timeStamp);
    Size _size = MediaQuery.of(context).size;
    bool isSoldOut = _bulletinCrewModelController.soldOut!;
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
                (_bulletinCrewModelController.uid != _userModelController.uid)
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
                                                        _bulletinCrewModelController
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
                                                        _bulletinCrewModelController
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
                          height: 140,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 14),
                            child: Column(
                              children: [
                                (_bulletinCrewModelController.uid == _userModelController.uid)?
                                GestureDetector(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: Text(
                                        '수정하기',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    //selected: _isSelected[index]!,
                                    onTap: () async {
                                      CustomFullScreenDialog.showDialog();
                                      Navigator.pop(context);
                                      await _userModelController
                                          .getCurrentUser(_userModelController.uid);
                                      CustomFullScreenDialog.cancelDialog();
                                      Get.to(
                                              () => Bulletin_Crew_ModifyPage());
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                  ),
                                )
                                    :SizedBox(),
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
                                                                    'bulletinCrew')
                                                                    .doc(
                                                                    '${_userModelController.uid}#${_bulletinCrewModelController.bulletinCrewCount}')
                                                                    .delete();
                                                                try {
                                                                  await _bulletinCrewModelController.deleteBulletinCrewImage(
                                                                      uid:
                                                                      _userModelController.uid,
                                                                      bulletinCrewCount: _bulletinCrewModelController.bulletinCrewCount,
                                                                      imageCount: _bulletinCrewModelController.itemImagesUrls!.length);
                                                                } catch (e) {
                                                                  print(
                                                                      '이미지 삭제 에러');
                                                                }
                                                                ;
                                                                Navigator.pop(
                                                                    context);
                                                              } catch (e) {}
                                                              print(
                                                                  '시즌방게시글 삭제 완료');
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
                height: _size.height -
                    MediaQuery.of(context).viewPadding.top -
                    58 -
                    MediaQuery.of(context).viewPadding.bottom -
                    88,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_bulletinCrewModelController.itemImagesUrls!.isEmpty)
                        SizedBox(),
                      if (_bulletinCrewModelController.itemImagesUrls!.isNotEmpty)
                        CarouselSlider.builder(
                          options: CarouselOptions(
                            height: 280,
                            viewportFraction: 1,
                            enableInfiniteScroll: false,
                          ),
                          itemCount:
                          _bulletinCrewModelController.itemImagesUrls!.length,
                          itemBuilder: (context, index, pageViewIndex) {
                            return Container(
                              child: StreamBuilder<Object>(
                                  stream: null,
                                  builder: (context, snapshot) {
                                    return Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(
                                                    () => BulletinCrewImageScreen());
                                          },
                                          child: ExtendedImage.network(
                                            _bulletinCrewModelController
                                                .itemImagesUrls![index],
                                            fit: BoxFit.cover,
                                            width: _size.width,
                                            height: 280,
                                          ),
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
                                    if (_bulletinCrewModelController
                                        .profileImageUrl!.isEmpty)
                                      ExtendedImage.asset(
                                        'assets/imgs/profile/img_profile_default_circle.png',
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(20),
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                      ),
                                    if (_bulletinCrewModelController
                                        .profileImageUrl!.isNotEmpty)
                                      ExtendedImage.network(
                                        '${_bulletinCrewModelController.profileImageUrl}',
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
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    '${_bulletinCrewModelController.displayName}',
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
                                                        fontWeight:
                                                        FontWeight.w300),
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
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (_bulletinCrewModelController.soldOut == true)
                                        ? '거래완료'
                                        : '${_bulletinCrewModelController.title}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
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
                                      '${_bulletinCrewModelController.category}',
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
                                      '${_bulletinCrewModelController.location}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF17AD4A)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
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
                                      '${_bulletinCrewModelController.description}',
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
            ],
          ),
        ),
      ),
    );
  }
}
