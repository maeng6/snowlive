import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../controller/vm_commentController.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class CommentTile_liveTalk_resortHome extends StatefulWidget {
  const CommentTile_liveTalk_resortHome({Key? key}) : super(key: key);

  @override
  State<CommentTile_liveTalk_resortHome> createState() =>
      _CommentTile_liveTalk_resortHomeState();
}

class _CommentTile_liveTalk_resortHomeState
    extends State<CommentTile_liveTalk_resortHome> {


  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  CommentModelController _commentModelController =
  Get.find<CommentModelController>();
//TODO: Dependency Injection**************************************************


  var _stream;
  bool _isVisible = false;


  ScrollController _scrollController = ScrollController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stream = newStream();
    _scrollController.addListener(() {
      setState(() {
        if(_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse
        ){
          _isVisible = true;
        }else if(_scrollController.position.userScrollDirection ==
            ScrollDirection.forward || _scrollController.position.pixels <=
        _scrollController.position.maxScrollExtent
        ){
          _isVisible = false;
        }
      });
    });
  }



  Stream<QuerySnapshot> newStream(){
    return FirebaseFirestore.instance
        .collection('comment')
        .doc('resort')
        .collection('${_userModelController.instantResort.toString()}')
        .orderBy('timeStamp', descending: true)
        .limit(100)
        .snapshots();
  }


  @override
      Widget build(BuildContext context) {
        Size _size = MediaQuery.of(context).size;

        return Scaffold(
          backgroundColor: Colors.white,
          body: StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  color: Colors.white,
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final chatDocs = snapshot.data!.docs;
              return Scrollbar(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    String _time = _commentModelController
                        .getAgoTime(chatDocs[index].get('timeStamp'));
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(chatDocs[index]['profileImageUrl'] != "")
                                  ExtendedImage.network(chatDocs[index]['profileImageUrl'],
                                    cache: true,
                                    shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(20),
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                  ),
                                if(chatDocs[index]['profileImageUrl'] == "")
                                  ExtendedImage.asset('assets/imgs/profile/img_profile_default_circle.png',
                                    shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(20),
                                    width: 32,
                                    height: 32,
                                    fit: BoxFit.cover,
                                  ),
                                SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          chatDocs[index].get('displayName'),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF111111)),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          '$_time',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF949494),
                                              fontWeight: FontWeight.w300),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                              maxWidth: _size.width - 78),
                                          child: Text(
                                            chatDocs[index].get('comment'),
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
                                    if (chatDocs[index].get('uid') ==
                                        _userModelController.uid)
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                          onPressed: () async {
                                            showMaterialModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    color: Colors.white,
                                                    height: 180,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 20.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            height: 30,
                                                          ),
                                                          Text(
                                                            '삭제하시겠습니까?',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                color:
                                                                    Color(0xFF111111)),
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
                                                                child: ElevatedButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                    '취소',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize: 15,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold),
                                                                  ),
                                                                  style: TextButton.styleFrom(
                                                                      splashFactory:
                                                                          InkRipple
                                                                              .splashFactory,
                                                                      elevation: 0,
                                                                      minimumSize:
                                                                          Size(100, 56),
                                                                      backgroundColor:
                                                                          Color(
                                                                              0xff555555),
                                                                      padding: EdgeInsets
                                                                          .symmetric(
                                                                              horizontal:
                                                                                  0)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                  onPressed: () async {
                                                                    CustomFullScreenDialog
                                                                        .showDialog();
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'comment')
                                                                        .doc('resort')
                                                                        .collection(
                                                                            '${_userModelController.instantResort.toString()}')
                                                                        .doc(
                                                                            _userModelController
                                                                                .uid)
                                                                        .delete();
                                                                    print('댓글 삭제 완료');
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
                                                                        fontSize: 15,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold),
                                                                  ),
                                                                  style: TextButton.styleFrom(
                                                                      splashFactory:
                                                                          InkRipple
                                                                              .splashFactory,
                                                                      elevation: 0,
                                                                      minimumSize:
                                                                          Size(100, 56),
                                                                      backgroundColor:
                                                                          Color(
                                                                              0xff2C97FB),
                                                                      padding: EdgeInsets
                                                                          .symmetric(
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
                                          child: Text(
                                            '삭제',
                                            style: TextStyle(
                                                color: Color(0xFF949494),
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal),
                                          )),
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                              color: Color(0xFFF5F5F5),
                              thickness: 1,
                              height: 40,
                            ),
                          ],
                      ),
                      ),
                    );

                  },
                ),
              );
            },
          ),
          floatingActionButton: Visibility(
            visible: _isVisible,
            child: FloatingActionButton(
              onPressed: (){
                  _scrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeIn);
              },
              child: Icon(Icons.arrow_upward_outlined),
            ),
          ),
        );
      }
        }
