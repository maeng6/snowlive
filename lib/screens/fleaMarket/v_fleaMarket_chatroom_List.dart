import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_fleaChatController.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Chatroom.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Upload.dart';
import 'package:snowlive3/screens/fleaMarket/v_phone_Auth_Screen.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class FleaMarket_Chatroom_List extends StatefulWidget {
  const FleaMarket_Chatroom_List({Key? key}) : super(key: key);

  @override
  State<FleaMarket_Chatroom_List> createState() =>
      _FleaMarket_Chatroom_ListState();
}

class _FleaMarket_Chatroom_ListState extends State<FleaMarket_Chatroom_List> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
  FleaChatModelController _fleaChatModelController =
      Get.find<FleaChatModelController>();

//TODO: Dependency Injection**************************************************

  var _stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stream = newStream();
    print(_stream);
  }

  Stream<QuerySnapshot> newStream() {
    print(_userModelController.uid);
    return FirebaseFirestore.instance
        .collection('fleaChat')
        .where('chatUidSumList',
            arrayContainsAny: ['${_userModelController.uid}'])
        .orderBy('timeStamp', descending: true)
        .limit(500)
        .snapshots();
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
            offset: Offset(12, -4),
            child: SizedBox(
              width: 112,
              height: 52,
              child: FloatingActionButton.extended(
                onPressed: () async{
                  await _userModelController.getCurrentUser(_userModelController.uid);
                  if(_userModelController.phoneAuth == true){
                    Get.to(() => FleaMarket_Upload());
                  }else if(_userModelController.phoneAuth == false){
                    Get.to(()=>PhoneAuthScreen());
                  }else{

                  }
                },
                icon: Icon(Icons.add),
                label: Text('글쓰기', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),),
                backgroundColor: Color(0xFF3D6FED),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          backgroundColor: Colors.white,
          body: Column(
            children: [
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
                      child:
                      (chatDocs.length == 0)
                          ? Transform.translate(
                        offset: Offset(0, -34),
                        child: Container(
                          width: _size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                        ),
                      )
                          : ListView.builder(
                        itemCount: chatDocs.length,
                        itemBuilder: (context, index) {
                          String _time = _fleaModelController
                              .getAgoTime(chatDocs[index].get('timeStamp'));
                          return GestureDetector(
                            onTap: () async {
                              CustomFullScreenDialog.showDialog();
                              try {
                                await _fleaChatModelController
                                    .getCurrentFleaChat(
                                        myUid: chatDocs[index].get('myUid'),
                                        otherUid:
                                            chatDocs[index].get('otherUid'));
                                if (_userModelController.uid ==
                                    _fleaChatModelController.otherUid) {
                                  await _fleaChatModelController
                                      .resetMyChatCheckCount(
                                          chatRoomName: _fleaChatModelController
                                              .chatRoomName);
                                } else {
                                  await _fleaChatModelController
                                      .resetOtherChatCheckCount(
                                          chatRoomName: _fleaChatModelController
                                              .chatRoomName);
                                }
                                CustomFullScreenDialog.cancelDialog();
                                Get.to(() => FleaChatroom());
                              } catch (e) {
                                CustomFullScreenDialog.cancelDialog();
                              }
                            },
                            child: Container(
                              color: Colors.white,
                              child: Obx(() => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                if (chatDocs[index]['myUid'] ==
                                                    _userModelController.uid)
                                                  (chatDocs[index][
                                                              'otherProfileImageUrl'] !=
                                                          '')
                                                      ? ExtendedImage.network(
                                                          chatDocs[index][
                                                              'otherProfileImageUrl'],
                                                          cache: true,
                                                          shape:
                                                              BoxShape.circle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : ExtendedImage.asset(
                                                          'assets/imgs/profile/img_profile_default_circle.png',
                                                          shape:
                                                              BoxShape.circle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.cover,
                                                        ),
                                                if (chatDocs[index]['myUid'] !=
                                                    _userModelController.uid)
                                                  (chatDocs[index][
                                                              'myProfileImageUrl'] !=
                                                          '')
                                                      ? ExtendedImage.network(
                                                          chatDocs[index][
                                                              'myProfileImageUrl'],
                                                          cache: true,
                                                          shape:
                                                              BoxShape.circle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : ExtendedImage.asset(
                                                          'assets/imgs/profile/img_profile_default_circle.png',
                                                          shape:
                                                              BoxShape.circle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.cover,
                                                        ),
                                                SizedBox(width: 12),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        (chatDocs[index]
                                                                    ['myUid'] ==
                                                                _userModelController
                                                                    .uid)
                                                            ? Text(
                                                                chatDocs[index].get(
                                                                    'otherDisplayName'),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15,
                                                                    color: Color(
                                                                        0xFF111111)),
                                                              )
                                                            : Text(
                                                                chatDocs[index].get(
                                                                    'myDisplayName'),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15,
                                                                    color: Color(
                                                                        0xFF111111)),
                                                              ),
                                                      ],
                                                    ),
                                                    Container(
                                                      width: _size.width -166,
                                                      child: Text(
                                                        '${chatDocs[index]['comment']}',
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '$_time 개설',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF949494),
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                (_userModelController.uid ==
                                                        chatDocs[index]
                                                            ['otherUid'])
                                                    ? Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    color:
                                                    (chatDocs[index]['myChatCheckCount']==0)?
                                                    Color(0xFFFFFFFF)
                                                    :Color(0xFF3D6FED),
                                                  ),
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 6,
                                                                left: 7,
                                                                bottom: 3,
                                                              top: 1
                                                            ),
                                                        child: Text(
                                                          '${chatDocs[index]['myChatCheckCount']}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 11,
                                                              color:
                                                                  Colors.white),
                                                        ))
                                                    : Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    color:
                                                    (chatDocs[index]['otherChatCheckCount']==0)?
                                                    Color(0xFFFFFFFF)
                                                    :Color(0xFF3D6FED),
                                                  ),
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 6,
                                                                left: 7,
                                                                bottom: 3,
                                                                top: 1
                                                                ),
                                                        child: Text(
                                                          '${chatDocs[index]['otherChatCheckCount']}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 11,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      )
                                    ],
                                  )),
                            ),
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
