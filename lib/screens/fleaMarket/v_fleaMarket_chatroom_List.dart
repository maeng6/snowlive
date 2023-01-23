import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snowlive3/controller/vm_fleaChatController.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Chatroom.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Upload.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class FleaMarket_Chatroom_List extends StatefulWidget {
  const FleaMarket_Chatroom_List({Key? key}) : super(key: key);

  @override
  State<FleaMarket_Chatroom_List> createState() => _FleaMarket_Chatroom_ListState();
}

class _FleaMarket_Chatroom_ListState extends State<FleaMarket_Chatroom_List> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
  FleaChatModelController _fleaChatModelController = Get.find<FleaChatModelController>();
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
    return FirebaseFirestore.instance
        .collection('fleaChat')
        .where('chatUidSumList', arrayContainsAny: ['${_userModelController.uid}'])
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(() => FleaMarket_Upload());
            },
            child: Icon(Icons.add),
          ),
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
                      child: ListView.builder(
                        itemCount: chatDocs.length,
                        itemBuilder: (context, index) {
                          String _time = _fleaModelController
                              .getAgoTime(chatDocs[index].get('timeStamp'));
                          return GestureDetector(
                            onTap: () async {
                              CustomFullScreenDialog.showDialog();

                              try{
                                  await _fleaChatModelController.getCurrentFleaChat(
                                      uid: chatDocs[index].get('uid'),
                                      otherUid: chatDocs[index].get('otherUid'));
                                  CustomFullScreenDialog.cancelDialog();
                                  Get.to(()=>FleaChatroom());

                              }catch(e){
                                CustomFullScreenDialog.cancelDialog();
                              }



                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                       if(chatDocs[index]['uid'] == _userModelController.uid)
                                          Padding(
                                            padding: EdgeInsets.only(top: 5),
                                            child:
                                            (chatDocs[index]['otherProfileImageUrl'] != '')
                                            ? ExtendedImage.network(
                                              chatDocs[index]['otherProfileImageUrl'],
                                              cache: true,
                                              shape:
                                              BoxShape.circle,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  20),
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            )
                                            : ExtendedImage.asset(
                                              'assets/imgs/profile/img_profile_default_circle.png',
                                              shape:
                                              BoxShape.circle,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  20),
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            ),
                                          ),

                                        if(chatDocs[index]['uid'] != _userModelController.uid)
                                          Padding(
                                            padding: EdgeInsets.only(top: 5),
                                            child:
                                            (chatDocs[index]['profileImageUrl'] != '')
                                            ? ExtendedImage.network(
                                              chatDocs[index]['profileImageUrl'],
                                              cache: true,
                                              shape:
                                              BoxShape.circle,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  20),
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            )
                                            : ExtendedImage.asset(
                                              'assets/imgs/profile/img_profile_default_circle.png',
                                              shape:
                                              BoxShape.circle,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  20),
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            ),
                                          ),

                                        SizedBox(width: 10),
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Row(
                                              children: [
                                                (chatDocs[index]['uid'] == _userModelController.uid)
                                                ? Text(
                                                  chatDocs[index].get('otherDisplayName'),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFF111111)),
                                                )
                                                : Text(
                                                  chatDocs[index].get('displayName'),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFF111111)),
                                                ),
                                                SizedBox(
                                                    width: 6),
                                                (chatDocs[index]['uid'] != _userModelController.uid)
                                                ? Text(
                                                  chatDocs[index].get(
                                                      'otherResortNickname'),
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w300,
                                                      fontSize:
                                                      13,
                                                      color: Color(
                                                          0xFF949494)),
                                                )
                                                : Text(
                                                  chatDocs[index].get(
                                                      'resortNickname'),
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w300,
                                                      fontSize:
                                                      13,
                                                      color: Color(
                                                          0xFF949494)),
                                                ),
                                                SizedBox(
                                                    width: 1),
                                                Text(
                                                  '· $_time 개설',
                                                  style: TextStyle(
                                                      fontSize:
                                                      13,
                                                      color: Color(
                                                          0xFF949494),
                                                      fontWeight:
                                                      FontWeight
                                                          .w300),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            (chatDocs[index]['uid'] == _userModelController.uid)
                                            ? Text('구매톡',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13
                                            ),
                                            )
                                            : Text('판매톡',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 36,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 16,
              )
            ],
          ),
        ),
      ),
    );
  }
}
