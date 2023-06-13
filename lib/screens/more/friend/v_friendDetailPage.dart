import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:snowlive3/controller/vm_friendsCommentController.dart';

import '../../../controller/vm_commentController.dart';
import '../../../controller/vm_replyModelController.dart';
import '../../../controller/vm_timeStampController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../widget/w_fullScreenDialog.dart';

class FriendDetailPage extends StatefulWidget {
  FriendDetailPage({Key? key, required this.uid}) : super(key: key);

  String? uid;

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {

  var _stream;

  @override
  void initState() {
    _stream = newStream();
    // TODO: implement initState
    super.initState();
  }
  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('user')
        .doc('${widget.uid}')
        .collection('friendsComment')
        .snapshots();
  }

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  var _newComment = '';

  //TODO: Dependency Injection**************************************************
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  UserModelController _userModelController = Get.find<UserModelController>();
  FriendsCommentModelController _friendsCommentModelController = Get.find<FriendsCommentModelController>();

  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('user')
            .where('uid', isEqualTo: widget.uid )
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (!snapshot.hasData || snapshot.data == null) {}
      else if (snapshot.data!.docs.isNotEmpty) {
        final friendDocs = snapshot.data!.docs;
        return Scaffold(
          body: Stack(
            children: [
              AppBar(
                backgroundColor: Color(0xFF3D83ED),
                leading: GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(top: _statusBarSize - 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/imgs/icons/icon_snowLive_back.png',
                          scale: 4,
                          width: 26,
                          height: 26,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                elevation: 0.0,
                titleSpacing: 0,
                centerTitle: true,
                toolbarHeight: 200.0, // 이 부분은 AppBar의 높이를 조절합니다.
              ),
              Padding(
                padding: EdgeInsets.only(top: 200.0),
                // 이 부분은 AppBar 높이에 따라 조절해야 합니다.
                child: Container(
                  color: Colors.white,
                  // 필요한 내용을 여기에 작성하세요.
                ),
              ),
              Positioned(
                  top: _size.height/6.5,
                  //left: _size.width/ 3.2,
                  child: Container(
                    width: _size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              (friendDocs[0]['profileImageUrl'].isNotEmpty)
                                  ? GestureDetector(
                                onTap: () {},
                                child: Container(
                                    width: _size.width/5,
                                    height: _size.width/5,
                                    child: ExtendedImage.network(
                                      friendDocs[0]['profileImageUrl'],
                                      enableMemoryCache: true,
                                      shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(8),
                                      width: _size.width/5,
                                      height: _size.width/5,
                                      fit: BoxFit.cover,
                                    )),
                              )
                                  : GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  child: ExtendedImage.asset(
                                    'assets/imgs/profile/img_profile_default_circle.png',
                                    enableMemoryCache: true,
                                    shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(8),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text('${friendDocs[0]['displayName']}'),//활동명
                              Text('${friendDocs[0]['stateMsg']}'),//상태메세지
                            ],
                          ),
                        ),//프사 + 닉네임 + 상메
                        SizedBox(height: 30,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                    onPressed: (){},
                                    iconSize: _size.width/10 ,
                                    icon: Image.asset('assets/imgs/icons/icon_edit_profile.png')
                                ),
                                Text('프로필 수정')
                              ],
                            ),
                            SizedBox(
                              width: _size.width/20,
                            ),
                            Column(
                              children: [
                                IconButton(
                                    onPressed: (){},
                                    iconSize: _size.width/10 ,
                                    icon: Image.asset('assets/imgs/icons/icon_liveCrew.png')
                                ),
                                Text('라이브 크루')
                              ],
                            ),
                          ],
                        ),//프로필수정 + 라이브크루
                        SizedBox(height: 30,),
                        Divider(thickness: 1,height: 20, color: Color(0xFFEEEEEE),),
                        SizedBox(height: 10,),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('소속된 크루',
                            style: TextStyle(
                              color: Color(0xFF949494)
                            ),)), //소속된크루
                        SizedBox(height: 30,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('liveCrew')
                                  .where('member', arrayContains: widget.uid)
                                  .snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                if (!snapshot.hasData || snapshot.data == null) {
                                  return Text('소속된 크루가 없습니다.');
                                }
                                else if (snapshot.connectionState == ConnectionState.waiting) {}
                                else if (snapshot.data!.docs.isNotEmpty) {
                                  List crewDocs = snapshot.data!.docs;
                                  return Row(
                                    children: crewDocs.map((doc) {
                                      if (doc['crewProfileUrl'].isNotEmpty) {
                                        return GestureDetector(
                                          onTap: () {},
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                child: ExtendedImage.network(
                                                  doc['crewProfileUrl'],
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.circle,
                                                  borderRadius: BorderRadius.circular(8),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(doc['crewName'])
                                            ],
                                          ),
                                        );
                                      } else {
                                        return GestureDetector(
                                          onTap: () {},
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                child: ExtendedImage.asset(
                                                  'assets/imgs/profile/img_profile_default_circle.png',
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.circle,
                                                  borderRadius: BorderRadius.circular(8),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(doc['crewName'])
                                            ],
                                          ),
                                        );
                                      }
                                    }).toList(),
                                  );
                                }
                                return Center(
                                  child: Text('소속된 크루가 없습니다.'),
                                );
                              },
                            ),
                          ],
                        ), //소속된 크루 목록
                        SizedBox(height: 40,),
                        Divider(
                          thickness: 8,
                          height: 20,
                          color: Color(0xFFEEEEEE),),
                        SizedBox(height: 20,),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text('일촌평',
                              style: TextStyle(
                                  color: Color(0xFF949494)
                              ),)), //일촌평
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                StreamBuilder(
                                  stream: _stream,
                                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                    if (!snapshot.hasData || snapshot.data == null) {
                                      return Text('첫 일촌평을 남겨보세요.');
                                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    else if (snapshot.data!.docs.isNotEmpty) {
                                      List commentDocs = snapshot.data!.docs;
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: commentDocs.length,
                                        itemBuilder: (context, index) {
                                          Timestamp timestamp = commentDocs[index].get('timeStamp');
                                          String formattedDate = DateFormat('yyyy.MM.dd').format(timestamp.toDate()); // 원하는 형식으로 날짜 변환
                                          return
                                            (_userModelController.repoUidList!.contains(commentDocs[index].get('myUid')))
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
                                            :Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Text(commentDocs[index]['comment']),
                                                width: _size.width / 5,
                                              ),
                                              Text(commentDocs[index]['displayName']),
                                              Text(
                                                formattedDate,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF949494),
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              (commentDocs[index]['myUid'] != _userModelController.uid)
                                                  ? GestureDetector(
                                                onTap: () =>
                                                    showModalBottomSheet(
                                                        enableDrag: false,
                                                        context: context,
                                                        builder: (context) {
                                                          return SafeArea(
                                                            child: Container(
                                                              height: 200,
                                                              child: Padding(
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
                                                                                                    await FirebaseFirestore.instance
                                                                                                        .collection('user')
                                                                                                        .doc('${widget.uid}')
                                                                                                        .collection('friendsComment')
                                                                                                        .doc(commentDocs[index]['myUid']).delete();
                                                                                                  } catch (e) {}
                                                                                                  print('일촌평 삭제 완료');
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
                                                                                          onPressed: () async {var repoUid = commentDocs[index].get('myUid');
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
                                                                                            var repoUid = commentDocs[index].get('myUid');
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
                                                                                                  await FirebaseFirestore.instance
                                                                                                      .collection('user')
                                                                                                      .doc('${widget.uid}')
                                                                                                      .collection('friendsComment')
                                                                                                      .doc('${_userModelController.uid}').delete();
                                                                                                } catch (e) {}
                                                                                                print('일촌평 삭제 완료');
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
                                          );
                                        },
                                      );
                                    }
                                    return Text('첫 일촌평을 남겨보세요.');
                                  },
                                )
                              ],
                            ),
                          )
                        ),
                        (widget.uid != _userModelController.uid)
                        ?  TextFormField(
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
                                  if (_controller.text.trim().isEmpty) {
                                    return;
                                  }
                                  try {
                                    await _friendsCommentModelController.sendMessage(
                                        displayName: _userModelController.displayName,
                                        profileImageUrl: _userModelController.profileImageUrl,
                                        comment: _newComment,
                                        commentCount: _userModelController.commentCount,
                                        resortNickname: _userModelController.resortNickname,
                                      myUid: _userModelController.uid,
                                      friendsUid: widget.uid,
                                    );
                                    FocusScope.of(context).unfocus();
                                    _controller.clear();
                                  } catch (e) {
                                    CustomFullScreenDialog.cancelDialog();
                                  }
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
                              hintText: '일촌평 남기기',
                              contentPadding: EdgeInsets.only(
                                  top: 10, bottom: 10, left: 16, right: 16),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFDEDEDE)),
                                borderRadius: BorderRadius.circular(6),
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
                        )
                            : Text('')
                      ],
                    ),
                  ),
              ),

            ],
          ),
        );
      }
      else if (snapshot.connectionState == ConnectionState.waiting) {}
      return Center(
        child: CircularProgressIndicator(),
      );

        },
      ),
    );
  }
}

// if (!snapshot.hasData || snapshot.data == null) {}
// else if (snapshot.data!.docs.isNotEmpty) {
// Column(
// children: [
//
// ],
// );
// }
// else if (snapshot.connectionState == ConnectionState.waiting) {}
// return Center(
// child: CircularProgressIndicator(),
// );