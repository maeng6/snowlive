import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snowlive3/controller/vm_commentController.dart';
import 'package:snowlive3/controller/vm_replyModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/comments/v_commentScreen_liveTalk_resortHome.dart';
import 'package:snowlive3/screens/comments/v_newReply.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class ReplyScreen extends StatefulWidget {
  ReplyScreen({Key? key,
    required this.replyUid,
    required this.replyCount,
    required this.replyImage,
    required this.replyDisplayName,
    required this.replyResortNickname,
    required this.comment,
    required this.commentTime}) : super(key: key);

  var replyUid;
  var replyCount;
  var replyImage;
  var replyDisplayName;
  var replyResortNickname;
  var comment;
  var commentTime;

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  CommentModelController _commentModelController =
  Get.find<CommentModelController>();
  ReplyModelController _replyModelController =
  Get.find<ReplyModelController>();

//TODO: Dependency Injection**************************************************

  var _replyStream;
  bool _isVisible = false;


  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _updateMethod();
    // TODO: implement initState
    super.initState();
    _replyStream = replyNewStream();
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          _isVisible = true;
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward ||
            _scrollController.position.pixels <=
                _scrollController.position.maxScrollExtent) {
          _isVisible = false;
        }
      });
    });
  }

  _updateMethod() async {
    await _userModelController.updateRepoUidList();
  }

  Stream<QuerySnapshot> replyNewStream() {
    return FirebaseFirestore.instance
        .collection('liveTalk')
        .doc('${widget.replyUid}${widget.replyCount}')
        .collection('reply')
        .orderBy('timeStamp', descending: true)
        .limit(100)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Text(
                  '답글',
                  style: TextStyle(
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF111111)),
                ),
              ),
              centerTitle: true,
              titleSpacing: 0,
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
            body: Container(
              margin: EdgeInsets.only(top: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: _replyStream,
                builder: (context, snapshot2) {
                  final replyDocs = snapshot2.data!.docs;
                  String _commentTimeStamp = _commentModelController
                      .getAgoTime(widget.commentTime);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Obx(() => Expanded(
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (_userModelController.repoUidList!
                                    .contains(widget.replyUid))
                                    ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Text(
                                      '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          color: Color(0xffc8c8c8)),
                                    ),
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        if (widget.replyImage !=
                                            "")
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(() =>
                                                  ProfileImagePage(
                                                    CommentProfileUrl:
                                                    widget.replyImage,
                                                  ));
                                            },
                                            child:
                                            ExtendedImage.network(
                                              widget.replyImage,
                                              cache: true,
                                              shape: BoxShape.circle,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        if (widget.replyImage ==
                                            "")
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(() =>
                                                  ProfileImagePage(
                                                      CommentProfileUrl:
                                                      ''));
                                            },
                                            child: ExtendedImage.asset(
                                              'assets/imgs/profile/img_profile_default_circle.png',
                                              shape: BoxShape.circle,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        SizedBox(width: 10),
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  widget.replyDisplayName,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: 14,
                                                      color: Color(
                                                          0xFF111111)),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  widget.replyResortNickname,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .w300,
                                                      fontSize: 13,
                                                      color: Color(
                                                          0xFF949494)),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '$_commentTimeStamp',
                                                  style: TextStyle(
                                                      fontSize: 13,
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
                                            Container(
                                              constraints:
                                              BoxConstraints(
                                                  maxWidth:
                                                  _size.width -
                                                      98),
                                              child: Text(
                                                widget.comment,
                                                maxLines: 1000,
                                                overflow:
                                                TextOverflow
                                                    .ellipsis,
                                                style: TextStyle(
                                                    color: Color(
                                                        0xFF111111),
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    fontSize: 13),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                (replyDocs.length > 0)
                                ?Text('답글 ${replyDocs.length}개')
                                :Text('첫 댓글을 남겨주세요!'),
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    reverse: true,
                                    itemCount: replyDocs.length,
                                    itemBuilder: (context, index) {
                                      String _time = _replyModelController
                                          .getAgoTime(replyDocs[index]
                                          .get('timeStamp'));
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, top: 24),
                                        child: Obx(() => Container(
                                          color: Colors.white,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              (_userModelController
                                                  .repoUidList!
                                                  .contains(
                                                  replyDocs[index]
                                                      .get('uid')))
                                                  ? Center(
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      vertical:
                                                      12),
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
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      if (replyDocs[
                                                      index]
                                                      [
                                                      'profileImageUrl'] !=
                                                          "")
                                                        GestureDetector(
                                                          onTap: () {
                                                            Get.to(() =>
                                                                ProfileImagePage(
                                                                  CommentProfileUrl:
                                                                  replyDocs[index]['profileImageUrl'],
                                                                ));
                                                          },
                                                          child: ExtendedImage
                                                              .network(
                                                            replyDocs[
                                                            index]
                                                            [
                                                            'profileImageUrl'],
                                                            cache:
                                                            true,
                                                            shape: BoxShape
                                                                .circle,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                20),
                                                            width: 26,
                                                            height:
                                                            26,
                                                            fit: BoxFit
                                                                .cover,
                                                          ),
                                                        ),
                                                      if (replyDocs[
                                                      index]
                                                      [
                                                      'profileImageUrl'] ==
                                                          "")
                                                        GestureDetector(
                                                          onTap: () {
                                                            Get.to(() =>
                                                                ProfileImagePage(
                                                                    CommentProfileUrl: ''));
                                                          },
                                                          child: ExtendedImage
                                                              .asset(
                                                            'assets/imgs/profile/img_profile_default_circle.png',
                                                            shape: BoxShape
                                                                .circle,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                20),
                                                            width: 26,
                                                            height:
                                                            26,
                                                            fit: BoxFit
                                                                .cover,
                                                          ),
                                                        ),
                                                      SizedBox(
                                                          width: 10),
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
                                                                replyDocs[index]
                                                                    .get('displayName'),
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: Color(0xFF111111)),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                  6),
                                                              Text(
                                                                '$_time',
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Color(0xFF949494),
                                                                    fontWeight: FontWeight.w300),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                constraints:
                                                                BoxConstraints(maxWidth: _size.width - 98),
                                                                child:
                                                                Text(
                                                                  replyDocs[index].get('reply'),
                                                                  maxLines:
                                                                  1000,
                                                                  overflow:
                                                                  TextOverflow.ellipsis,
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
                                                  (replyDocs[index][
                                                  'uid'] !=
                                                      _userModelController
                                                          .uid)
                                                      ? GestureDetector(
                                                    onTap: () => showMaterialModalBottomSheet(
                                                        enableDrag: false,
                                                        context: context,
                                                        builder: (context) {
                                                          return Container(
                                                            height:
                                                            190,
                                                            child:
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
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
                                                                                      var repoUid = replyDocs[index].get('uid');
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
                                                                                      var repoUid = replyDocs[index].get('uid');
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
                                                    child:
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          bottom:
                                                          22),
                                                      child:
                                                      Icon(
                                                        Icons
                                                            .more_vert,
                                                        color: Color(
                                                            0xFFdedede),
                                                      ),
                                                    ),
                                                  )
                                                      : GestureDetector(
                                                    onTap: () => showMaterialModalBottomSheet(
                                                        enableDrag: false,
                                                        context: context,
                                                        builder: (context) {
                                                          return Container(
                                                            height:
                                                            130,
                                                            child:
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
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
                                                                                                  await _commentModelController.replyCountDelete('${widget.replyUid}${widget.replyCount}');
                                                                                                  await FirebaseFirestore.instance
                                                                                                      .collection('liveTalk')
                                                                                                      .doc('${widget.replyUid}${widget.replyCount}')
                                                                                                      .collection('reply')
                                                                                                      .doc('${_userModelController.uid}${replyDocs[index]['commentCount']}')
                                                                                                      .delete();
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
                                                    child:
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          bottom:
                                                          22),
                                                      child:
                                                      Icon(
                                                        Icons
                                                            .more_vert,
                                                        color: Color(
                                                            0xFFdedede),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                        NewReply(
                            replyLocationUid: widget.replyUid,
                            replyLocationUidCount: widget.replyCount),
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );
  }
}
