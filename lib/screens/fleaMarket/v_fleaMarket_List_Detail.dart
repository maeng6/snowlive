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
import 'package:snowlive3/screens/v_MainHome.dart';
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
  FleaChatModelController _fleaChatModelController = Get.find<FleaChatModelController>();
//TODO: Dependency Injection**************************************************



  @override
  Widget build(BuildContext context) {
    String _time = _fleaModelController
        .getAgoTime(_fleaModelController.timeStamp);
    Size _size = MediaQuery.of(context).size;
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
                  onTap: () =>
                      showModalBottomSheet(
                          enableDrag: false,
                          context: context,
                          builder:
                              (context) {
                            return Container(
                              height: 190,
                              child:
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 14),
                                child:
                                Column(
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
                                            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                            content: Text(
                                              '이 회원을 신고하시겠습니까?',
                                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                            ),
                                            actions: [
                                              Row(
                                                children: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        '취소',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(0xFF949494),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )),
                                                  TextButton(
                                                      onPressed: () async {
                                                        var repoUid = _fleaModelController.uid;
                                                        await _userModelController.repoUpdate(repoUid);
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        '신고',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(0xFF3D83ED),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ))
                                                ],
                                                mainAxisAlignment: MainAxisAlignment.end,
                                              )
                                            ],
                                          ));
                                        },
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                            content: Text(
                                              '이 회원의 게시물을 모두 숨길까요?\n이 동작은 취소할 수 없습니다.',
                                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                            ),
                                            actions: [
                                              Row(
                                                children: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        '취소',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(0xFF949494),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )),
                                                  TextButton(
                                                      onPressed: () {
                                                        var repoUid = _fleaModelController.uid;
                                                        _userModelController.updateRepoUid(repoUid);
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        '확인',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(0xFF3D83ED),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ))
                                                ],
                                                mainAxisAlignment: MainAxisAlignment.end,
                                              )
                                            ],
                                          ));
                                        },
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                  child: Padding(
                    padding:
                    const EdgeInsets.only(bottom: 22),
                    child: Icon(Icons.more_vert,
                      color: Color(0xFFdedede),
                    ),
                  ),
                )
                    : GestureDetector(
                  onTap: () =>
                      showModalBottomSheet(
                          enableDrag:
                          false,
                          context:
                          context,
                          builder:
                              (context) {
                            return Container(
                              height:
                              130,
                              child:
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                    20.0,
                                    vertical:
                                    14),
                                child:
                                Column(
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
                                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                          height: 30,
                                                        ),
                                                        Text(
                                                          '삭제하시겠습니까?',
                                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
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
                                                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                                                ),
                                                                style: TextButton.styleFrom(splashFactory: InkRipple.splashFactory, elevation: 0, minimumSize: Size(100, 56), backgroundColor: Color(0xff555555), padding: EdgeInsets.symmetric(horizontal: 0)),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () async {
                                                                  CustomFullScreenDialog.showDialog();
                                                                  try {
                                                                    await FirebaseFirestore.instance.collection('fleaMarket').doc('${_userModelController.uid}#${_fleaModelController.fleaCount}').delete();
                                                                    Navigator.pop(context);
                                                                  } catch (e) {}
                                                                  print('댓글 삭제 완료');
                                                                  Navigator.pop(context);
                                                                  CustomFullScreenDialog.cancelDialog();
                                                                },
                                                                child: Text(
                                                                  '확인',
                                                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                                                ),
                                                                style: TextButton.styleFrom(splashFactory: InkRipple.splashFactory, elevation: 0, minimumSize: Size(100, 56), backgroundColor: Color(0xff2C97FB), padding: EdgeInsets.symmetric(horizontal: 0)),
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
                  child: Padding(
                    padding:
                    const EdgeInsets
                        .only(
                        bottom: 22),
                    child: Icon(
                      Icons.more_vert,
                      color: Color(
                          0xFFdedede),
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
              CarouselSlider.builder(
          options: CarouselOptions(
          height: 200,
              viewportFraction: 1,
              enableInfiniteScroll: false,
             ),
          itemCount: _fleaModelController.itemImagesUrls!.length,
          itemBuilder: (context, index, pageViewIndex) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: 44,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(_fleaModelController.itemImagesUrls!.isEmpty)
                            Image.asset('assets/imgs/profile/img_profile_default_.png'),
                          Container(
                            height:200,
                            child: ExtendedImage.network(
                              _fleaModelController.itemImagesUrls![index],
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
              SizedBox(
                height: 20,
              ),
              Container(
                   child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(_fleaModelController.profileImageUrl!.isEmpty)
                          ExtendedImage.asset(
                              'assets/imgs/profile/img_profile_default_circle.png',
                              shape: BoxShape.circle,
                              borderRadius:
                              BorderRadius.circular(20),
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                            ),
                        if(_fleaModelController.profileImageUrl!.isNotEmpty)
                          ExtendedImage.network(
                            '${_fleaModelController.profileImageUrl}',
                            shape: BoxShape.circle,
                            borderRadius:
                            BorderRadius.circular(20),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        SizedBox(width: 12),
                        Column(
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
                                          fontSize: 13,
                                          color: Color(0xFF949494),
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  ListTile(
                    leading: Text('카테고리'),
                    title: Text('${_fleaModelController.category}'),
                  ),
                  ListTile(
                    leading: Text('제품명'),
                    title: Text('${_fleaModelController.itemName}'),
                  ),
                  ListTile(
                    leading: Text('가격'),
                    title: Text('${_fleaModelController.price}'),
                  ),
                  ListTile(
                    leading: Text('거래지역'),
                    title: Text('${_fleaModelController.location}'),
                  ),
                  ListTile(
                    leading: Text('거래방식'),
                    title: Text('${_fleaModelController.method}'),
                  ),
                  ListTile(
                    title: Text('상세설명'),
                    subtitle: Text('${_fleaModelController.description}'),
                  )
                ]
              ),
              SizedBox(
                height: 20,
              ),

              TextButton(
                  onPressed: () async{
                    CustomFullScreenDialog.showDialog();
                    try{
                      if(_fleaModelController.uid != _userModelController.uid){
                        if(_userModelController.fleaChatUidList!.contains(_fleaChatModelController.otherUid)){





                        } else {
                          await _fleaChatModelController.setNewChatCountUid(
                              otherUid: _fleaModelController.uid,
                              otherDispName: _fleaChatModelController
                                  .myDisplayName,
                              myDispName: _userModelController.displayName);
                          await _fleaChatModelController.createChatroom(
                            myUid: _userModelController.uid,
                            otherUid: _fleaModelController.uid,
                            otherProfileImageUrl: _fleaModelController
                                .profileImageUrl,
                            otherResortNickname: _fleaModelController
                                .resortNickname,
                            otherDisplayName: _fleaModelController.displayName,
                            myDisplayName: _userModelController.displayName,
                            myProfileImageUrl: _userModelController
                                .profileImageUrl,
                            myResortNickname: _userModelController
                                .resortNickname,
                          );
                          await _fleaChatModelController.updateChatUidSumList(
                              _fleaModelController.uid);
                        }
                        CustomFullScreenDialog.cancelDialog();
                        return Get.to(()=>FleaChatroom());
                      }else{
                        CustomFullScreenDialog.cancelDialog();
                        return Get.to(()=>FleaMarket_ModifyPage());
                      }
                    }catch(e){
                      print('에러');
                      CustomFullScreenDialog.cancelDialog();
                    }
                  },
                  child:
                  (_fleaModelController.uid != _userModelController.uid)
                  ? Text('메시지 보내기') : Text('수정하기')
              ),
          ],
          ),
        ),
      ),
    );
  }
}

