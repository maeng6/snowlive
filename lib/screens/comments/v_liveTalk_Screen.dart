import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import 'package:snowlive3/screens/comments/v_reply_Screen.dart';
import 'package:snowlive3/screens/more/friend/v_friendDetailPage.dart';
import '../../controller/vm_commentController.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';
import 'package:snowlive3/controller/vm_imageController.dart';


class LiveTalkScreen extends StatefulWidget {
  const LiveTalkScreen({Key? key}) : super(key: key);

  @override
  State<LiveTalkScreen> createState() =>
      _LiveTalkScreenState();
}


class _LiveTalkScreenState
    extends State<LiveTalkScreen> {
  final _controller = TextEditingController();
  var _newComment = '';
  final _formKey = GlobalKey<FormState>();
  var _firstPress = true;
  bool livetalkImage = false;
  XFile? _imageFile;


  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  CommentModelController _commentModelController = Get.find<CommentModelController>();
  //TODO: Dependency Injection**************************************************

  var _stream;
  bool _isVisible = false;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _imageFile = null;
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
    Get.put(ImageController(), permanent: true);
    ImageController _imageController = Get.find<ImageController>();

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
            body: Container(
              color: Color(0xFFF1F1F3),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _stream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                color: Colors.white,
                              );
                            }
                            else if (snapshot.connectionState == ConnectionState.waiting) {
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
                                    const EdgeInsets.only(
                                        left: 12, right: 12, bottom: 10),
                                    child: Obx(() =>
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              (_userModelController.repoUidList!.contains(chatDocs[index].get('uid')))
                                                  ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16, vertical: 14),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius
                                                        .circular(8)
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
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
                                                ),
                                              )
                                                  : Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 14),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius
                                                        .circular(8)
                                                ),
                                                width: _size.width - 24,
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                                          child: Container(
                                                            width: _size.width - 56,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    if (chatDocs[index]['profileImageUrl'] != "")
                                                                      GestureDetector(
                                                                        onTap: () async {
                                                                          QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
                                                                              .collection('user')
                                                                              .where('uid', isEqualTo: chatDocs[index]['uid'])
                                                                              .get();

                                                                          if (userQuerySnapshot.docs.isNotEmpty) {
                                                                            DocumentSnapshot userDoc = userQuerySnapshot.docs.first;
                                                                            int favoriteResort = userDoc['favoriteResort'];
                                                                            print(favoriteResort);
                                                                            print(chatDocs[index]['uid']);

                                                                            Get.to(() => FriendDetailPage(uid: chatDocs[index]['uid'], favoriteResort: favoriteResort,));
                                                                          } else {
                                                                          }
                                                                        },
                                                                        child: ExtendedImage.network(
                                                                          chatDocs[index]['profileImageUrl'],
                                                                          cache: true,
                                                                          shape: BoxShape.circle,
                                                                          borderRadius: BorderRadius.circular(20),
                                                                          width: 24,
                                                                          height: 24,
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    if (chatDocs[index]['profileImageUrl'] == "")
                                                                      GestureDetector(
                                                                        onTap: () async {
                                                                          QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
                                                                              .collection('user')
                                                                              .where('uid', isEqualTo: chatDocs[index]['uid'])
                                                                              .get();

                                                                          if (userQuerySnapshot.docs.isNotEmpty) {
                                                                            DocumentSnapshot userDoc = userQuerySnapshot.docs.first;
                                                                            int favoriteResort = userDoc['favoriteResort'];

                                                                            Get.to(() => FriendDetailPage(uid: chatDocs[index]['uid'], favoriteResort: favoriteResort,));
                                                                          } else {
                                                                            // user 문서를 찾을 수 없는 경우에 대한 처리를 여기에 추가하세요.
                                                                          }
                                                                        },
                                                                        child: ExtendedImage
                                                                            .asset(
                                                                          'assets/imgs/profile/img_profile_default_circle.png',
                                                                          shape: BoxShape.circle,
                                                                          borderRadius: BorderRadius.circular(20),
                                                                          width: 24,
                                                                          height: 24,
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    SizedBox(width: 8),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(bottom: 1),
                                                                      child: Text(
                                                                        chatDocs[index].get('displayName'),
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 12,
                                                                            color: Color(0xFF111111)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                (chatDocs[index]['uid'] != _userModelController.uid)
                                                                    ? GestureDetector(
                                                                  onTap: () =>
                                                                      showModalBottomSheet(
                                                                          enableDrag: false,
                                                                          context: context,
                                                                          builder: (context) {
                                                                            return SafeArea(
                                                                              child: Container(
                                                                                height: 140,
                                                                                child: Padding(
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
                                                                                            Get.dialog(
                                                                                                AlertDialog(
                                                                                                  contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                  elevation: 0,
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                      borderRadius: BorderRadius.circular(10.0)),
                                                                                                  buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                                                                                                              Navigator.pop(context);
                                                                                                            },
                                                                                                            child: Text('취소',
                                                                                                              style: TextStyle(
                                                                                                                fontSize: 15,
                                                                                                                color: Color(0xFF949494),
                                                                                                                fontWeight: FontWeight.bold,
                                                                                                              ),
                                                                                                            )),
                                                                                                        TextButton(
                                                                                                            onPressed: () async {var repoUid = chatDocs[index].get('uid');
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
                                                                                          shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius
                                                                                                  .circular(
                                                                                                  10)),
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
                                                                                                fontWeight: FontWeight
                                                                                                    .bold,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          //selected: _isSelected[index]!,
                                                                                          onTap: () async {
                                                                                            Get
                                                                                                .dialog(
                                                                                                AlertDialog(
                                                                                                  contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                  elevation: 0,
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                      borderRadius: BorderRadius.circular(10.0)),
                                                                                                  buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                                                                                                            child: Text('확인',
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
                                                                                          shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(10)),
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }),
                                                                  child: Icon(
                                                                    Icons.more_horiz,
                                                                    color: Color(0xFFdedede),
                                                                    size: 20,
                                                                  ),
                                                                )
                                                                    : GestureDetector(
                                                                  onTap: () =>
                                                                      showModalBottomSheet(
                                                                          enableDrag:
                                                                          false,
                                                                          context: context,
                                                                          builder: (
                                                                              context) {
                                                                            return Container(
                                                                              height: 100,
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsets
                                                                                    .symmetric(
                                                                                    horizontal: 20.0,
                                                                                    vertical: 14),
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
                                                                                              color: Color(0xFFD63636)
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
                                                                                                    padding: const EdgeInsets.symmetric(
                                                                                                        horizontal: 20.0),
                                                                                                    child: Column(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                                      children: [
                                                                                                        SizedBox(
                                                                                                          height: 30,
                                                                                                        ),
                                                                                                        Text(
                                                                                                          '삭제하시겠습니까?',
                                                                                                          style: TextStyle(
                                                                                                              fontSize: 20,
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              color: Color(0xFF111111)),
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
                                                                                                                  style: TextStyle(
                                                                                                                      color: Colors.white,
                                                                                                                      fontSize: 15,
                                                                                                                      fontWeight: FontWeight.bold),
                                                                                                                ),
                                                                                                                style: TextButton.styleFrom(
                                                                                                                    splashFactory: InkRipple.splashFactory,
                                                                                                                    elevation: 0,
                                                                                                                    minimumSize: Size(100, 56),
                                                                                                                    backgroundColor: Color(0xff555555),
                                                                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
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
                                                                                                                    await _imageController.deleteLiveTalkImage(uid: _userModelController.uid!, count: chatDocs[index]['commentCount']);

                                                                                                                  } catch (e) {}
                                                                                                                  print('라이브톡 삭제 완료');
                                                                                                                  Navigator.pop(context);
                                                                                                                  CustomFullScreenDialog.cancelDialog();
                                                                                                                },
                                                                                                                child: Text('확인',
                                                                                                                  style: TextStyle(
                                                                                                                      color: Colors.white,
                                                                                                                      fontSize: 15,
                                                                                                                      fontWeight: FontWeight.bold),
                                                                                                                ),
                                                                                                                style: TextButton.styleFrom(
                                                                                                                    splashFactory: InkRipple.splashFactory,
                                                                                                                    elevation: 0,
                                                                                                                    minimumSize: Size(100, 56),
                                                                                                                    backgroundColor: Color(0xff2C97FB),
                                                                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
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
                                                                  child: Icon(Icons.more_horiz,
                                                                    color: Color(0xFFdedede),
                                                                    size: 20,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Column(
                                                          children: [
                                                            if (chatDocs[index]['livetalkImageUrl'] != "")
                                                              Padding(
                                                                padding: EdgeInsets.only(top: 14, bottom: 6),
                                                                child: GestureDetector(
                                                                  onTap: () {Get.to(() =>
                                                                      ProfileImagePage(
                                                                        CommentProfileUrl: chatDocs[index]['livetalkImageUrl'],
                                                                      ));
                                                                  },
                                                                  child: ExtendedImage.network(
                                                                    chatDocs[index]['livetalkImageUrl'],
                                                                    cache: true,
                                                                    width: _size.width - 24,
                                                                    height: _size.width - 24,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            if (chatDocs[index]['livetalkImageUrl'] == "")
                                                              Container(
                                                                height: 0,
                                                              )
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 16),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    constraints: BoxConstraints(
                                                                        maxWidth: _size.width - 56),
                                                                    child: Text(
                                                                      chatDocs[index].get('comment'),
                                                                      maxLines: 1000,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: TextStyle(
                                                                          color: Color(0xFF111111),
                                                                          fontWeight: FontWeight.normal,
                                                                          fontSize: 14),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    chatDocs[index].get('resortNickname'),
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w300,
                                                                        fontSize: 12,
                                                                        color: Color(0xFF949494)),
                                                                  ),
                                                                  SizedBox(
                                                                      width: 1),
                                                                  Text(' $_time',
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Color(0xFF949494),
                                                                        fontWeight: FontWeight.w300),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 16,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  GestureDetector(
                                                                    child: Container(
                                                                      height: 24,
                                                                      decoration: BoxDecoration(
                                                                          color: (_userModelController.likeUidList!.contains('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}'))
                                                                              ? Color(0xFFFFCDCD)
                                                                              : Color(0xFFECECEC),
                                                                          borderRadius: BorderRadius.circular(4)
                                                                      ),
                                                                      child: Padding(
                                                                        padding: EdgeInsets.only(right: 8),
                                                                        child: Row(
                                                                          children: [
                                                                            (_userModelController.likeUidList!.contains('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}'))
                                                                                ? Padding(
                                                                              padding: const EdgeInsets.only(top: 2),
                                                                              child:
                                                                              IconButton(
                                                                                onPressed: () async {
                                                                                  var likeUid = '${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}';
                                                                                  print(likeUid);
                                                                                  HapticFeedback.lightImpact();
                                                                                  if (_firstPress) {
                                                                                    _firstPress = false;
                                                                                    await _userModelController.deleteLikeUid(likeUid);
                                                                                    await _commentModelController.likeDelete(likeUid);
                                                                                    _firstPress =
                                                                                    true;
                                                                                  }
                                                                                },
                                                                                icon: Icon(
                                                                                  Icons.favorite,
                                                                                  size: 14,
                                                                                  color: Color(0xFFD63636),
                                                                                ),
                                                                                padding: EdgeInsets.zero,
                                                                                constraints: BoxConstraints(),
                                                                              ),
                                                                            )
                                                                                : Padding(
                                                                              padding: const EdgeInsets.only(top: 2),
                                                                              child:
                                                                              IconButton(
                                                                                onPressed: () async {
                                                                                  var likeUid = '${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}';
                                                                                  print(likeUid);
                                                                                  HapticFeedback.lightImpact();
                                                                                  if (_firstPress) {
                                                                                    _firstPress = false;
                                                                                    await _userModelController.updateLikeUid(likeUid);
                                                                                    await _commentModelController.likeUpdate(likeUid);
                                                                                    _firstPress = true;
                                                                                  }
                                                                                },
                                                                                icon: Icon(Icons.favorite,
                                                                                  size: 14,
                                                                                  color: Color(0xFFC8C8C8),
                                                                                ),
                                                                                padding: EdgeInsets.zero,
                                                                                constraints: BoxConstraints(),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.only(bottom: 1),
                                                                              child: Text(
                                                                                '${chatDocs[index]['likeCount']}',
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 11,
                                                                                    color:
                                                                                    (_userModelController.likeUidList!.contains('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}'))
                                                                                        ? Color(0xFF111111)
                                                                                        : Color(0xFF666666)),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    onTap: () async{
                                                                     if (_userModelController.likeUidList!.contains('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}')){
                                                                       var likeUid = '${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}';
                                                                       print(likeUid);
                                                                       HapticFeedback.lightImpact();
                                                                       if (_firstPress) {
                                                                         _firstPress = false;
                                                                         await _userModelController.deleteLikeUid(likeUid);
                                                                         await _commentModelController.likeDelete(likeUid);
                                                                         _firstPress =
                                                                         true;
                                                                       }
                                                                     } else{
                                                                       var likeUid = '${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}';
                                                                       print(likeUid);
                                                                       HapticFeedback.lightImpact();
                                                                       if (_firstPress) {
                                                                         _firstPress = false;
                                                                         await _userModelController.updateLikeUid(likeUid);
                                                                         await _commentModelController.likeUpdate(likeUid);
                                                                         _firstPress = true;
                                                                       }
                                                                     }

                                                                    },
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: (){
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
                                                                    child: Container(
                                                                      height: 24,
                                                                      decoration: BoxDecoration(
                                                                          color: Color(0xFFECECEC),
                                                                          borderRadius: BorderRadius.circular(4)
                                                                      ),
                                                                      child: Padding(
                                                                        padding: EdgeInsets.only(right: 6),
                                                                        child: Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding:
                                                                              const EdgeInsets.only(top: 2),
                                                                              child:
                                                                              IconButton(
                                                                                onPressed: () {
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
                                                                                icon: Icon(
                                                                                  Icons.insert_comment,
                                                                                  size: 14,
                                                                                  color: Color(0xFFC8C8C8),
                                                                                ),
                                                                                padding: EdgeInsets.zero,
                                                                                constraints: BoxConstraints(),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.only(bottom: 1),
                                                                              child: Text(
                                                                                '${chatDocs[index]['replyCount']}',
                                                                                style: TextStyle(
                                                                                    color: (chatDocs[index]['replyCount'] > 0)
                                                                                        ? Color(0xFF666666)
                                                                                        : Color(0xFF666666),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 11),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
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
                        padding:
                        EdgeInsets.only(top: 12, left: 10, right: 16, bottom: 12),
                        child: Row(
                          children: [
                          Container(
                          padding: EdgeInsets.zero,
                          width: 40,
                          child:
                          (livetalkImage) //이 값이 true이면 이미지업로드가 된 상태이므로, 미리보기 띄움
                              ? IconButton(
                                icon: Icon(Icons.photo_camera,
                                  size: 28,
                                  color: Color(0xFF444444),),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        Container(
                                          height: 162,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 24.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                    Text(
                                                      '업로드 방법을 선택해주세요.',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF111111)),
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          CustomFullScreenDialog.showDialog();
                                                          try {
                                                            _imageFile = await _imageController.getSingleImage(ImageSource.camera);
                                                            CustomFullScreenDialog.cancelDialog();
                                                            livetalkImage = true;
                                                            setState(() {});
                                                          } catch (e) {
                                                            CustomFullScreenDialog.cancelDialog();
                                                            print('사진촬영 오류');
                                                          }
                                                        },
                                                        child: Text(
                                                          '사진 촬영',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        style: TextButton.styleFrom(
                                                            splashFactory:
                                                            InkRipple.splashFactory,
                                                            elevation: 0,
                                                            minimumSize: Size(
                                                                100, 56),
                                                            backgroundColor:
                                                            Color(0xff555555),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal: 0)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          CustomFullScreenDialog.showDialog();
                                                          try {
                                                            _imageFile = await _imageController.getSingleImage(ImageSource.gallery);
                                                            CustomFullScreenDialog.cancelDialog();
                                                            livetalkImage = true;
                                                            setState(() {});
                                                          } catch (e) {
                                                            CustomFullScreenDialog.cancelDialog();
                                                            print('앨범 오류');
                                                          }
                                                        },
                                                        child: Text(
                                                          '앨범에서 선택',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight
                                                                  .bold),
                                                        ),
                                                        style: TextButton.styleFrom(
                                                            splashFactory:
                                                            InkRipple.splashFactory,
                                                            elevation: 0,
                                                            minimumSize: Size(
                                                                100, 56),
                                                            backgroundColor:
                                                            Color(0xff2C97FB),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal: 0)),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              )
                                            ],
                                          ),
                                        ),
                                  );
                                },
                              )
                              : IconButton(
                                icon: Icon(Icons.photo_camera,
                                  size: 28,
                                  color: Color(0xFF444444),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        Container(
                                          height: 162,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 24.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                    Text(
                                                      '업로드 방법을 선택해주세요.',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF111111)),
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          CustomFullScreenDialog.showDialog();
                                                          try {
                                                            _imageFile = await _imageController.getSingleImage(ImageSource.camera);
                                                            CustomFullScreenDialog.cancelDialog();
                                                            livetalkImage = true;
                                                            setState(() {});
                                                          } catch (e) {
                                                            CustomFullScreenDialog.cancelDialog();
                                                          }
                                                        },
                                                        child: Text(
                                                          '사진 촬영',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        style: TextButton.styleFrom(
                                                            splashFactory:
                                                            InkRipple.splashFactory,
                                                            elevation: 0,
                                                            minimumSize: Size(100, 56),
                                                            backgroundColor:
                                                            Color(0xff555555),
                                                            padding: EdgeInsets.symmetric(horizontal: 0)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                          CustomFullScreenDialog.showDialog();
                                                          try {
                                                            _imageFile = await _imageController.getSingleImage(ImageSource.gallery);
                                                            CustomFullScreenDialog.cancelDialog();
                                                            livetalkImage = true;
                                                            setState(() {});
                                                          } catch (e) {
                                                            CustomFullScreenDialog.cancelDialog();
                                                          }
                                                        },
                                                        child: Text(
                                                          '앨범에서 선택',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        style: TextButton.styleFrom(
                                                            splashFactory:
                                                            InkRipple.splashFactory,
                                                            elevation: 0,
                                                            minimumSize: Size(100, 56),
                                                            backgroundColor:
                                                            Color(0xff2C97FB),
                                                            padding: EdgeInsets.symmetric(horizontal: 0)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              )
                                            ],
                                          ),
                                        ),
                                  );
                                },
                              ),),
                          SizedBox(
                            width: 10,
                          ),
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
                                      try{
                                        CustomFullScreenDialog.showDialog();
                                        await _userModelController.getCurrentUser(_userModelController.uid);
                                        await _userModelController.updateCommentCount(_userModelController.commentCount);
                                        await _userModelController.getCurrentUser(_userModelController.uid);
                                      if (_controller.text.trim().isEmpty) {
                                        return;
                                      }
                                      String? livetalkImageUrl = "";
                                      if (_imageFile != null) {
                                        livetalkImageUrl = await _imageController.setNewImage_livetalk(_imageFile!, _userModelController.commentCount);
                                        await _commentModelController.updateLivetalkImageUrl(livetalkImageUrl);

                                        setState(() {
                                          _imageFile = null;
                                          livetalkImage = false;
                                        });
                                      }
                                      _controller.clear();
                                      _scrollController.jumpTo(0);
                                      try {
                                        await _commentModelController.sendMessage(
                                            displayName: _userModelController.displayName,
                                            uid: _userModelController.uid,
                                            profileImageUrl: _userModelController.profileImageUrl,
                                            comment: _newComment,
                                            commentCount: _userModelController.commentCount,
                                            resortNickname: _userModelController.resortNickname,
                                            likeCount: _commentModelController.likeCount,
                                            replyCount: _commentModelController.replyCount,
                                            livetalkImageUrl: livetalkImageUrl);
                                        FocusScope.of(context).unfocus();
                                        _controller.clear();
                                        setState(() {});
                                      } catch (e) {
                                        CustomFullScreenDialog.cancelDialog();
                                      }
                                      CustomFullScreenDialog.cancelDialog();
                                      } catch(e){
                                      CustomFullScreenDialog.cancelDialog();
                                      }
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
                                  labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                  hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                  hintText: '라이브톡 남기기',
                                  contentPadding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 16, right: 16),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xFFDEDEDE)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  focusedBorder:  OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xFFDEDEDE)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xFFFF3726)),
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
                    ],
                  ),
                  (_imageFile != null)
                      ? Positioned(
                    bottom: 72,
                    child: Stack(
                      alignment: Alignment.center,
                    children: [
                      Container(
                        width: _size.width,
                        height: 112,
                        color: Color(0xFF000000).withAlpha(180),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4), // 반지름 60.0인 원형으로 자르기
                        ),
                        child: (_imageFile == null)
                            ? null
                            : Image.file(File(_imageFile!.path),
                            fit: BoxFit.cover),
                      ),
                      Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              child: ExtendedImage.asset(
                                  'assets/imgs/icons/icon_profile_delete.png',
                                  scale: 4),
                              onTap: () {
                                livetalkImage = false;
                                _imageFile = null;
                                setState(() {});
                              },
                            )),
                    ],
                  ),
                      )
                      : Container(),
                ],
              ),
            ),
            floatingActionButton: Visibility(
              visible: _isVisible,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 64),
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
                    size: 24,),
                ),
              ),
            ),
          ),)
        ,
      )
      ,
    );
  }
}
