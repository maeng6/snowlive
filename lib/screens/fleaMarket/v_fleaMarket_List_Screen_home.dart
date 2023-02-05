import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Upload.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class FleaMarket_List_Screen_Home extends StatefulWidget {
  const FleaMarket_List_Screen_Home({Key? key}) : super(key: key);

  @override
  State<FleaMarket_List_Screen_Home> createState() => _FleaMarket_List_ScreenState_Home();
}

class _FleaMarket_List_ScreenState_Home extends State<FleaMarket_List_Screen_Home> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();

//TODO: Dependency Injection**************************************************

  var _stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stream = newStream();
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('fleaMarket')
        .orderBy('timeStamp', descending: true)
        .limit(5)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      width: _size.width - 32,
      height: 502,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
             StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    color: Colors.white,
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return  Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final chatDocs = snapshot.data!.docs;
                return  Stack(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: chatDocs.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () async {
                              if (_userModelController.repoUidList!
                                  .contains(chatDocs[index].get('uid'))) {
                                return;
                              }
                              CustomFullScreenDialog.showDialog();
                              await _fleaModelController.getCurrentFleaItem(
                                  uid: chatDocs[index].get('uid'),
                                  fleaCount: chatDocs[index].get('fleaCount'));
                              CustomFullScreenDialog.cancelDialog();
                              Get.to(() => FleaMarket_List_Detail());
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Obx(() => Container(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    (_userModelController.repoUidList!
                                        .contains(
                                        chatDocs[index].get('uid')))
                                        ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 36),
                                        child: Text(
                                          '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.normal,
                                              fontSize: 12,
                                              color: Color(0xffc8c8c8)),
                                        ),
                                      ),
                                    )
                                        : Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (List.from(chatDocs[index]['itemImagesUrls']).isNotEmpty)
                                          ExtendedImage.network(
                                            chatDocs[index]['itemImagesUrls'][0],
                                            cache: true,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(5),
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                          ),
                                        if (List.from(chatDocs[index]['itemImagesUrls']).isEmpty)
                                          ExtendedImage.asset(
                                            'assets/imgs/profile/img_profile_default_.png',
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(5),
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                          ),
                                        SizedBox(width: 16),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: _size.width - 132,
                                              ),
                                              child: Text(
                                                chatDocs[index].get('title'),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Color(0xFF111111)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  chatDocs[index].get('resortNickname'),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 13,
                                                      color: Color(0xFF949494)),
                                                ),
                                                SizedBox(width: 1),
                                                Text(
                                                  '·',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF949494),
                                                      fontWeight: FontWeight.normal),
                                                ),
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: _size.width - 150,
                                                  ),
                                                  child: Text(
                                                    chatDocs[index].get(
                                                        'price').toString()+' 원',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Color(0xFF949494),
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 13),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Container(
                                      width: _size.width,
                                      color: Color(0xFFF5F5F5),
                                      height: 1,
                                    )
                                  ],
                                ),
                              ),)
                            ));

                      },
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: _size.width,
                        color: Colors.white,
                        height: 4,
                      ),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
