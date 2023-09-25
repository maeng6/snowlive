import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/controller/vm_commentController.dart';
import 'package:com.snowlive/controller/vm_replyModelController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/screens/comments/v_noUserScreen.dart';
import 'package:com.snowlive/screens/comments/v_profileImageScreen.dart';
import 'package:com.snowlive/screens/more/friend/v_friendDetailPage.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';

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
  var replyFavoriteResort;
  var comment;
  var commentTime;


  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {

  final _controller = TextEditingController();
  var _newReply = '';
  final _formKey = GlobalKey<FormState>();
  bool anony = false;

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  CommentModelController _commentModelController =
  Get.find<CommentModelController>();
  ReplyModelController _replyModelController =
  Get.find<ReplyModelController>();

//TODO: Dependency Injection**************************************************

  var _replyStream;
  bool _myReply = false;

  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    _updateMethod();
    // TODO: implement initState
    super.initState();
    _replyStream = replyNewStream();
  }

  _updateMethod() async {
    await _userModelController.updateRepoUidList();
  }

  Stream<QuerySnapshot> replyNewStream() {
    return FirebaseFirestore.instance
        .collection('liveTalk')
        .doc('${widget.replyUid}${widget.replyCount}')
        .collection('reply')
        .orderBy('timeStamp', descending: false)
        .limit(500)
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
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(58),
              child: AppBar(
                leading: GestureDetector(
                  child: Image.asset(
                    'assets/imgs/icons/icon_snowLive_back.png',
                    scale: 4,
                    width: 26,
                    height: 26,
                  ),
                  onTap: () {
                    Get.back();
                  },
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
                    children: [
                      Text(
                        '답글',
                        style: GoogleFonts.notoSans(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.w900,
                            fontSize: 20),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                titleSpacing: 0,
                backgroundColor: Colors.white,
                elevation: 0.0,
              ),
            ),
            body: Container(
              margin: EdgeInsets.only(top: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: _replyStream,
                builder: (context, snapshot2) {
                  if (!snapshot2.hasData) {
                    return Container(
                      color: Colors.white,
                    );
                  } else if (snapshot2.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (widget.replyImage != "" && widget.replyImage != 'anony')
                                          Padding(
                                            padding: EdgeInsets.only(top: 5),
                                            child: GestureDetector(
                                              onTap: () {
                                                Get.to(() =>
                                                    FriendDetailPage(uid: widget.replyUid, favoriteResort: widget.replyFavoriteResort,));
                                              },
                                              child:
                                              ExtendedImage.network(widget.replyImage,
                                                cache: true,
                                                shape: BoxShape.circle,
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        if (widget.replyImage == "")
                                          Padding(
                                            padding: EdgeInsets.only(top: 5),
                                            child: GestureDetector(
                                              onTap: () {
                                                Get.to(() =>
                                                    FriendDetailPage(uid: widget.replyUid, favoriteResort: widget.replyFavoriteResort,));
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
                                          ),
                                        if (widget.replyImage == "anony")
                                          Padding(
                                            padding: EdgeInsets.only(top: 5),
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: ExtendedImage.asset(
                                                'assets/imgs/icons/img_profile_default_anony_circle.png',
                                                shape: BoxShape.circle,
                                                borderRadius:
                                                BorderRadius.circular(
                                                    20),
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
                                                  widget.replyDisplayName,
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: 14,
                                                      color: Color(
                                                          0xFF111111)),
                                                ),
                                                if(widget.replyDisplayName == 'SNOWLIVE')
                                                  Padding(
                                                    padding: const EdgeInsets.only(left : 2.0),
                                                    child: Image.asset(
                                                      'assets/imgs/icons/icon_snowlive_operator.png',
                                                      scale: 5.5,
                                                    ),
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
                                                SizedBox(width: 1),
                                                Text(
                                                  '· $_commentTimeStamp',
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
                                                  _size.width - 80),
                                              child: Text(
                                                widget.comment,
                                                maxLines: 1000,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: Color(0xFF111111),
                                                    fontWeight: FontWeight.normal,
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
                                (replyDocs.length == 0)
                                ? Padding(
                                  padding: const EdgeInsets.only(top: 24, left: 42),
                                  child: Text('첫 답글을 남겨주세요!', style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF949494)
                                  ),),
                                )
                                :Expanded(
                                  child: Scrollbar(
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      reverse: false,
                                      itemCount: replyDocs.length,
                                      itemBuilder: (context, index) {
                                        String _time = _replyModelController
                                            .getAgoTime(replyDocs[index]
                                            .get('timeStamp'));
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 42, top: 24),
                                          child: Obx(() => Container(
                                            color: Colors.white,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                (_userModelController.repoUidList!.contains(
                                                    replyDocs[index].get('uid')))
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
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        if (replyDocs[index]['profileImageUrl'] != "" && replyDocs[index]['profileImageUrl'] != 'anony')
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 4),
                                                            child: GestureDetector(
                                                              onTap: () async{
                                                                QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
                                                                    .collection('user')
                                                                    .where('uid', isEqualTo: replyDocs[index]['uid'])
                                                                    .get();

                                                                if (userQuerySnapshot.docs.isNotEmpty) {
                                                                  DocumentSnapshot userDoc = userQuerySnapshot.docs.first;
                                                                  int favoriteResort = userDoc['favoriteResort'];

                                                                  Get.to(() => FriendDetailPage(uid: replyDocs[index]['uid'], favoriteResort: favoriteResort,));
                                                                } else {
                                                                  Get.to(()=>NoUserScreen());
                                                                }
                                                              },
                                                              child: ExtendedImage.network(
                                                                replyDocs[index]['profileImageUrl'],
                                                                cache: true,
                                                                shape: BoxShape.circle,
                                                                borderRadius: BorderRadius.circular(20),
                                                                width: 26,
                                                                height: 26,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          ),
                                                        if (replyDocs[index]['profileImageUrl'] == "")
                                                          Padding(
                                                            padding: EdgeInsets.only(top:4),
                                                            child: GestureDetector(
                                                              onTap: () async{
                                                                QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
                                                                    .collection('user')
                                                                    .where('uid', isEqualTo: replyDocs[index]['uid'])
                                                                    .get();

                                                                if (userQuerySnapshot.docs.isNotEmpty) {
                                                                  DocumentSnapshot userDoc = userQuerySnapshot.docs.first;
                                                                  int favoriteResort = userDoc['favoriteResort'];

                                                                  Get.to(() => FriendDetailPage(uid: replyDocs[index]['uid'], favoriteResort: favoriteResort,));
                                                                } else {
                                                                  Get.to(()=>NoUserScreen());
                                                                }
                                                              },
                                                              child: ExtendedImage.asset(
                                                                'assets/imgs/profile/img_profile_default_circle.png',
                                                                shape: BoxShape.circle,
                                                                borderRadius: BorderRadius.circular(20),
                                                                width: 26,
                                                                height: 26,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          ),
                                                        if (replyDocs[index]['profileImageUrl'] == "anony")
                                                          Padding(
                                                            padding: EdgeInsets.only(top:4),
                                                            child: GestureDetector(
                                                              onTap: () async{},
                                                              child: ExtendedImage.asset(
                                                                'assets/imgs/icons/img_profile_default_anony_circle.png',
                                                                shape: BoxShape.circle,
                                                                borderRadius: BorderRadius.circular(20),
                                                                width: 26,
                                                                height: 26,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          ),
                                                        SizedBox(
                                                            width: 10),
                                                        Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  replyDocs[index]['displayName'],
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 14,
                                                                      color: Color(0xFF111111)),
                                                                ),
                                                                if(replyDocs[index]['displayName'] == 'SNOWLIVE')
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left : 2.0),
                                                                    child: Image.asset(
                                                                      'assets/imgs/icons/icon_snowlive_operator.png',
                                                                      scale: 5.5,
                                                                    ),
                                                                  ),
                                                                SizedBox(
                                                                    width: 6),
                                                                Text(
                                                                  replyDocs[index]['replyResortNickname'],
                                                                  style: TextStyle(
                                                                      fontSize: 13,
                                                                      color: Color(0xFF949494),
                                                                      fontWeight: FontWeight.w300),
                                                                ),
                                                                SizedBox(
                                                                    width: 1),
                                                                Text(
                                                                  '· $_time',
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
                                                                  BoxConstraints(maxWidth: _size.width - 140),
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
                                                    (replyDocs[index]['uid'] != _userModelController.uid)
                                                        ? GestureDetector(
                                                      onTap: () => showModalBottomSheet(
                                                          enableDrag: false,
                                                          context: context,
                                                          builder: (context) {
                                                            return SafeArea(
                                                              child: Container(
                                                                height:
                                                                (replyDocs[index]['displayName'] == '익명') ? 90 : 140,
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
                                                                      if(replyDocs[index]['displayName'] != '익명')
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
                                                      onTap: () => showModalBottomSheet(
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
                                ),
                              ],
                            ),
                          ),
                        )),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          margin: EdgeInsets.only(bottom: 2),
                          padding: EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    if(anony == true){
                                      setState(() {
                                        anony = false;
                                      });
                                    }else{
                                      setState(() {
                                        anony = true;
                                      });
                                    }
                                  });
                                },
                                child:Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                    (anony == true)
                                        ? Color(0xFFCBE0FF)
                                        : Color(0xFFECECEC),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      (anony == true)
                                          ? Image.asset(
                                        'assets/imgs/icons/icon_livetalk_check.png',
                                        scale: 4,
                                        width: 10,
                                        height: 10,
                                      )
                                          :  Image.asset(
                                        'assets/imgs/icons/icon_livetalk_check_off.png',
                                        scale: 4,
                                        width: 10,
                                        height: 10,
                                      ),
                                      SizedBox(width: 2,),
                                      Text('익명',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color:
                                            (anony == true)
                                                ? Color(0xFF3D83ED)
                                                :Color(0xFF949494)
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Expanded(
                                child: TextFormField(
                                  key: _formKey,
                                  cursorColor: Color(0xff377EEA),
                                  controller: _controller,
                                  strutStyle: StrutStyle(leading: 0.3),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
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
                                          try{
                                            await _userModelController.updateCommentCount(_userModelController.commentCount);
                                            await _commentModelController.replyCountUpdate('${widget.replyUid}${widget.replyCount}');
                                            await _replyModelController.sendReply(
                                                replyResortNickname: _userModelController.resortNickname,
                                                displayName:
                                                (anony == false)
                                                ? _userModelController.displayName
                                                : '익명',
                                                uid: _userModelController.uid,
                                                replyLocationUid: widget.replyUid,
                                                profileImageUrl:
                                                (anony == false)
                                                ? _userModelController.profileImageUrl
                                                : 'anony',
                                                reply: _newReply,
                                                replyLocationUidCount: widget.replyCount,
                                                commentCount: _userModelController.commentCount);
                                            setState(() {
                                            });}catch(e){}
                                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
                                      hintStyle: TextStyle(color: Color(0xff949494), fontSize: 14),
                                      hintText: '답글 남기기',
                                      contentPadding:
                                      EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xFFFF3726)),
                                        borderRadius: BorderRadius.circular(6),
                                      )),
                                  onChanged: (value) {
                                    setState(() {
                                      _newReply = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text('운영자가 실시간으로 악성댓글을 관리합니다.', style: TextStyle(
                          fontSize: 12, color: Color(0xFFC8C8C8),
                        ),),
                        SizedBox(height: 16,),
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
