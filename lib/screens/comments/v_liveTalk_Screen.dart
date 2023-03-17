import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/screens/comments/v_reply_Screen.dart';
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
  final _controller = TextEditingController();
  var _newComment = '';
  final _formKey = GlobalKey<FormState>();
  var _firstPress = true;

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
    _updateMethod();
    _updateMethodComment();
    // TODO: implement initState
    super.initState();
    _stream = newStream();
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
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(58),
              child: AppBar(
                centerTitle: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '라이브톡',
                    style: TextStyle(
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.w700,
                        fontSize: 20),
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
              ),
            ),
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
                          controller: _scrollController,
                          reverse: true,
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
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if (chatDocs[index][
                                                              'profileImageUrl'] != "")
                                                        Padding(
                                                          padding: EdgeInsets.only(top: 5),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Get.to(() =>
                                                                  ProfileImagePage(
                                                                    CommentProfileUrl: chatDocs[index]['profileImageUrl'],
                                                                  ));
                                                            },
                                                            child: ExtendedImage.network(
                                                              chatDocs[index]['profileImageUrl'],
                                                              cache: true,
                                                              shape: BoxShape.circle,
                                                              borderRadius: BorderRadius.circular(20),
                                                              width: 32,
                                                              height: 32,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      if (chatDocs[index]['profileImageUrl'] == "")
                                                        Padding(
                                                          padding: EdgeInsets.only(top: 5),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Get.to(() => ProfileImagePage(
                                                                      CommentProfileUrl: ''));
                                                            },
                                                            child: ExtendedImage.asset(
                                                              'assets/imgs/profile/img_profile_default_circle.png',
                                                              shape: BoxShape.circle,
                                                              borderRadius: BorderRadius.circular(20),
                                                              width: 32,
                                                              height: 32,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
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
                                                              SizedBox(
                                                                  width: 6),
                                                              Text(
                                                                chatDocs[index].get('resortNickname'),
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w300,
                                                                    fontSize: 13,
                                                                    color: Color(0xFF949494)),
                                                              ),
                                                              SizedBox(
                                                                  width: 1),
                                                              Text('· $_time',
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
                                                                constraints: BoxConstraints(
                                                                    maxWidth: _size.width - 106),
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
                                                          Row(
                                                            children: [
                                                              (_userModelController.likeUidList!.contains('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}'))
                                                                  ? Padding(
                                                                      padding: const EdgeInsets.only(top: 2),
                                                                      child:
                                                                          IconButton(
                                                                        onPressed:
                                                                            () async {
                                                                          var likeUid = '${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}';
                                                                          print(likeUid);
                                                                          HapticFeedback.vibrate();
                                                                          if (_firstPress) {
                                                                            _firstPress = false;
                                                                            await _userModelController.deleteLikeUid(likeUid);
                                                                            await _commentModelController.likeDelete(likeUid);
                                                                            _firstPress = true;
                                                                          }
                                                                        },
                                                                        icon:
                                                                            Icon(Icons.favorite,
                                                                          size: 16,
                                                                          color: Colors.red,
                                                                        ),
                                                                        padding: EdgeInsets.zero,
                                                                        constraints: BoxConstraints(),
                                                                      ),
                                                                    )
                                                                  : Padding(
                                                                      padding: const EdgeInsets.only(top: 2),
                                                                      child:
                                                                          IconButton(
                                                                        onPressed:
                                                                            () async {
                                                                          var likeUid = '${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}';
                                                                          print(likeUid);
                                                                          HapticFeedback.vibrate();
                                                                          if (_firstPress) {
                                                                            _firstPress = false;
                                                                            await _userModelController.updateLikeUid(likeUid);
                                                                            await _commentModelController.likeUpdate(likeUid);
                                                                            _firstPress = true;
                                                                          }
                                                                        },
                                                                        icon: Icon(Icons.favorite_border,
                                                                          size: 16,
                                                                          color: Color(0xFF949494),
                                                                        ),
                                                                        padding: EdgeInsets.zero,
                                                                        constraints: BoxConstraints(),
                                                                      ),
                                                                    ),
                                                              Text(
                                                                '${chatDocs[index]['likeCount']}',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.normal,
                                                                    fontSize: 13,
                                                                    color: Color(0xFF949494)),
                                                              ),
                                                              SizedBox(
                                                                width: 16,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(top: 2),
                                                                child:
                                                                    IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    Get.to(() =>
                                                                        ReplyScreen(
                                                                          replyUid: chatDocs[index]['uid'],
                                                                          replyCount: chatDocs[index]['commentCount'],
                                                                          replyImage: chatDocs[index]['profileImageUrl'],
                                                                          replyDisplayName: chatDocs[index]['displayName'],
                                                                          replyResortNickname: chatDocs[index]['resortNickname'],
                                                                          comment: chatDocs[index]['comment'],
                                                                          commentTime: chatDocs[index]['timeStamp'],
                                                                        ));
                                                                  },
                                                                  icon: Icon(Icons.insert_comment_outlined,
                                                                    size: 16,
                                                                    color: Color(
                                                                        0xFF949494),
                                                                  ),
                                                                  padding: EdgeInsets.zero,
                                                                  constraints: BoxConstraints(),
                                                                ),
                                                              ),
                                                              // Text(
                                                              //   '${chatDocs[index]['replyCount']}',
                                                              //   style: TextStyle(
                                                              //       fontWeight:
                                                              //           FontWeight
                                                              //               .bold,
                                                              //       fontSize: 13,
                                                              //       color: Color(
                                                              //           0xFF949494)),
                                                              // ),
                                                            ],
                                                          ),
                                                          (chatDocs[index]['replyCount'] > 0)
                                                              ? Padding(
                                                            padding: EdgeInsets.only(top: 16),
                                                                child: GestureDetector(
                                                                    child: Text(
                                                                      '답글 ${chatDocs[index]['replyCount']}개',
                                                                      style: TextStyle(
                                                                          color: Color(0xFF377EEA),
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                      fontSize: 13),
                                                                    ),
                                                                    onTap: () {
                                                                      Get.to(() =>
                                                                          ReplyScreen(
                                                                            replyUid: chatDocs[index]['uid'],
                                                                            replyCount: chatDocs[index]['commentCount'],
                                                                            replyImage: chatDocs[index]['profileImageUrl'],
                                                                            replyDisplayName: chatDocs[index]['displayName'],
                                                                            replyResortNickname: chatDocs[index]['resortNickname'],
                                                                            comment: chatDocs[index]['comment'],
                                                                            commentTime: chatDocs[index]['timeStamp'],
                                                                          ));
                                                                    },
                                                                  ),
                                                              )
                                                              : Container(),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  (chatDocs[index]['uid'] != _userModelController.uid)
                                                      ? GestureDetector(
                                                          onTap: () =>
                                                              showModalBottomSheet(
                                                                  enableDrag: false,
                                                                  context: context,
                                                                  builder:
                                                                      (context) {
                                                                    return SafeArea(
                                                                      child: Container(
                                                                        height: 140,
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.only(bottom: 2),
                  padding:
                      EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: _formKey,
                          cursorColor: Color(0xff377EEA),
                          controller: _controller,
                          strutStyle: StrutStyle(leading: 0.3),
                          maxLines: 1,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                splashColor: Colors.transparent,
                                onPressed: () async {
                                  if(_controller.text.trim().isEmpty)
                                  {return ;}
                                  FocusScope.of(context).unfocus();
                                  _controller.clear();
                                  CustomFullScreenDialog.showDialog();
                                  _scrollController.jumpTo(0);
                                  try {
                                    await _userModelController.updateCommentCount(_userModelController.commentCount);
                                    await _commentModelController.sendMessage(
                                        displayName: _userModelController.displayName,
                                        uid: _userModelController.uid,
                                        profileImageUrl: _userModelController.profileImageUrl,
                                        comment: _newComment,
                                        commentCount: _userModelController.commentCount,
                                        resortNickname: _userModelController.resortNickname,
                                        likeCount: _commentModelController.likeCount,
                                        replyCount: _commentModelController.replyCount);
                                    setState(() {});
                                  } catch (e) {}
                                  CustomFullScreenDialog.cancelDialog();
                                },
                                icon: (_controller.text.trim().isEmpty)
                                    ? Image.asset(
                                        'assets/imgs/icons/icon_livetalk_send_g.png',
                                        width: 27,
                                        height: 27,
                                      )
                                    : Image.asset(
                                        'assets/imgs/icons/icon_livetalk_send.png',
                                        width: 27,
                                        height: 27,
                                      ),
                              ),
                              errorStyle: TextStyle(
                                fontSize: 12,
                              ),
                              hintStyle: TextStyle(
                                  color: Color(0xff949494), fontSize: 14),
                              hintText: '라이브톡 남기기',
                              contentPadding: EdgeInsets.only(
                                  top: 10, bottom: 10, left: 16, right: 16),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFFDEDEDE)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFFDEDEDE)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFFFF3726)),
                                borderRadius: BorderRadius.circular(6),
                              )),
                          onChanged: (value) {
                            setState(() {
                              _newComment = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '운영자가 실시간으로 악성댓글을 관리합니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC8C8C8),
                  ),
                ),
                SizedBox(
                  height: 16,
                )
              ],
            ),
            floatingActionButton: Visibility(
              visible: _isVisible,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: FloatingActionButton(
                  mini: true,
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero
                  ),
                  backgroundColor: Color(0xFF111111),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _scrollController.jumpTo(0);
                  },
                  child: Icon(Icons.arrow_downward,
                  size: 22,),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
