import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/screens/comments/v_reply_Screen.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_Upload.dart';
import '../../controller/vm_commentController.dart';
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
  final _controller = TextEditingController();
  var _newComment = '';
  final _formKey = GlobalKey<FormState>();

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  CommentModelController _commentModelController =
  Get.find<CommentModelController>();

//TODO: Dependency Injection**************************************************

  var _stream;
  bool _firstPress = true;

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
        .collection('liveTalk')
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
                          String _time = _commentModelController
                              .getAgoTime(chatDocs[index].get('timeStamp'));
                          return Padding(
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap : (){
                                          print('111');
                                          Get.to(()=>FleaMarket_List_Detail());
                                        },
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                              Padding(
                                                padding: EdgeInsets.only(top: 5),
                                                child: ExtendedImage
                                                      .network(
                                                    chatDocs[index][
                                                    'profileImageUrl'],
                                                    cache: true,
                                                    shape:
                                                    BoxShape.rectangle,
                                                    borderRadius:
                                                    BorderRadius
                                                        .zero,
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
                                                    Text(
                                                      '분류',
                                                      //chatDocs[index].get('displayName'),
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Color(0xFF111111)),
                                                    ),
                                                    SizedBox(
                                                        width: 6),
                                                    Text(
                                                      '글제목',
                                                      //chatDocs[index].get('displayName'),
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
                                                        '가격',
                                                        //chatDocs[index].get('comment'),
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
                                      ),
                                      (chatDocs[index]['uid'] != _userModelController.uid)
                                          ? GestureDetector(
                                        onTap: () =>
                                            showMaterialModalBottomSheet(
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
                                                                              var repoUid = chatDocs[index].get('uid');
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
                                                                              var repoUid = chatDocs[index].get('uid');
                                                                              _userModelController.updateRepoUid(repoUid);
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
                                            showMaterialModalBottomSheet(
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
                                                                showMaterialModalBottomSheet(
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
                                                                                          await FirebaseFirestore.instance.collection('liveTalk').doc('${_userModelController.uid}${chatDocs[index]['commentCount']}').delete();
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
                                  ),
                                  SizedBox(
                                    height: 36,
                                  ),
                                ],
                              ),
                            )),
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
