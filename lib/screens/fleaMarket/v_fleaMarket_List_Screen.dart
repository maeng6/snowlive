import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Upload.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class FleaMarket_List_Screen extends StatefulWidget {
  const FleaMarket_List_Screen({Key? key}) : super(key: key);

  @override
  State<FleaMarket_List_Screen> createState() =>
      _FleaMarket_List_ScreenState();
}

class _FleaMarket_List_ScreenState
    extends State<FleaMarket_List_Screen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController =
  Get.find<FleaModelController>();

//TODO: Dependency Injection**************************************************

  var _stream;

  @override
  void initState() {
    _updateMethod();
    _updateMethodComment();
    // TODO: implement initState
    super.initState();
    _stream = newStream();
  }

  _updateMethod() async {
    await _userModelController.updateRepoUidList();
  }

  _updateMethodComment() async {
    await _userModelController.updateLikeUidList();
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('fleaMarket')
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(()=>FleaMarket_Upload());
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
                            onTap: (){
                              if(_userModelController.repoUidList!
                                  .contains(chatDocs[index].get('uid'))){
                                return ;
                              }
                              Get.to(()=>FleaMarket_List_Detail());
                            },
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Obx(() => Container(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    (_userModelController.repoUidList!
                                        .contains(
                                        chatDocs[index].get('uid')))
                                        ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets
                                            .symmetric(vertical: 12),
                                        child: Text(
                                          '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.normal,
                                              fontSize: 12,
                                              color:
                                              Color(0xffc8c8c8)),
                                        ),
                                      ),
                                    )
                                        : Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if(List.from(chatDocs[index]['itemImagesUrls']).isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(top: 5),
                                                child: ExtendedImage.network(
                                                  chatDocs[index]['itemImagesUrls'][0],
                                                  cache: true,
                                                  shape:
                                                  BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(5),
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            if(List.from(chatDocs[index]['itemImagesUrls']).isEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(top: 5),
                                              child: ExtendedImage.asset(
                                                'assets/imgs/profile/img_profile_default_.png',
                                                shape:
                                                BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(5),
                                                width: 100,
                                                height: 100,
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
                                                    Text(
                                                      chatDocs[index].get('category'),
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Color(0xFF111111)),
                                                    ),
                                                    SizedBox(
                                                        width: 6),
                                                    Text(
                                                      chatDocs[index].get('title'),
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Color(0xFF111111)),
                                                    ),
                                                    SizedBox(
                                                        width: 6),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
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
                                                      '· $_time',
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
                                                  height: 8,
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      constraints: BoxConstraints(
                                                          maxWidth:
                                                          _size.width - 106),
                                                      child: Text(
                                                        chatDocs[index].get('price') + ' 원',
                                                        maxLines: 1000,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            color: Color(0xFF111111),
                                                            fontWeight: FontWeight.normal,
                                                            fontSize: 13),
                                                      ),
                                                    ),
                                                  ],
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
                              )),
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
