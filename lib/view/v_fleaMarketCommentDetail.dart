import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../data/imgaUrls/Data_url_image.dart';
import '../viewmodel/vm_fleamarketCommentDetail.dart';
import '../viewmodel/vm_user.dart';

class FleamarketCommentDetailView extends StatelessWidget {

  final FleamarketCommentDetailViewModel _fleamarketCommentDetailViewModel = Get.find<FleamarketCommentDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
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
                        style: TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.bold,
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
            body: Obx(() => Container(
              margin: EdgeInsets.only(top: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  GestureDetector(
                                    onTap: () {
                                    },
                                    child:
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFDFECFF),
                                          borderRadius: BorderRadius.circular(50)
                                      ),
                                      child: ExtendedImage.network(
                                      '${_fleamarketCommentDetailViewModel.commentModel_flea.userInfo!.profileImageUrlUser}',
                                        cache: true,
                                        shape: BoxShape.circle,
                                        borderRadius:
                                        BorderRadius.circular(20),
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                        loadStateChanged: (ExtendedImageState state) {
                                          switch (state.extendedImageLoadState) {
                                            case LoadState.loading:
                                              return SizedBox.shrink();
                                            case LoadState.completed:
                                              return state.completedWidget;
                                            case LoadState.failed:
                                              return ExtendedImage.network(
                                                '${profileImgUrlList[0].default_round}',
                                                shape: BoxShape.circle,
                                                borderRadius: BorderRadius.circular(20),
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                              ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                            default:
                                              return null;
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 10),
                                Row(
                                  children: [
                                    Text(
                                      '${_fleamarketCommentDetailViewModel.commentModel_flea.userInfo!.displayName}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF111111)),
                                    ),
                                    SizedBox(width: 1),
                                    Text('· ${_fleamarketCommentDetailViewModel.time}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF949494),
                                          fontWeight: FontWeight.w300),
                                    ),
                                    SizedBox(width: 1),
                                    if (_fleamarketCommentDetailViewModel.commentModel_flea.secret!)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 7),
                                        child: Icon(Icons.lock,
                                          size: 15,
                                          color: Color(0xFF949494),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints:
                                  BoxConstraints(
                                      maxWidth:
                                      _size.width - 80),
                                  child: SelectableText(
                                    '${_fleamarketCommentDetailViewModel.commentModel_flea.content}',
                                    style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                            (_fleamarketCommentDetailViewModel.commentModel_flea.replies!.isEmpty)
                                ? Padding(
                              padding: const EdgeInsets.only(top: 24, left: 42),
                              child: Text('첫 답글을 남겨주세요!', style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF949494)
                              ),),
                            )
                                : ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  reverse: false,
                                  itemCount: _fleamarketCommentDetailViewModel.commentModel_flea.replies!.length,
                                  itemBuilder: (context, index) {
                                    String _time = GetDatetime().getAgoString(_fleamarketCommentDetailViewModel.commentModel_flea.replies![index].uploadTime!);
                                    String? profileUrl = _fleamarketCommentDetailViewModel.commentModel_flea.replies![index].userInfo!.profileImageUrlUser;
                                    String? displayName = _fleamarketCommentDetailViewModel.commentModel_flea.replies![index].userInfo!.displayName;
                                    int? user_id_reply = _fleamarketCommentDetailViewModel.commentModel_flea.replies![index].userInfo!.userId;
                                    int? user_id_comment = _fleamarketCommentDetailViewModel.commentModel_flea.userId;
                                    int? reply_id = _fleamarketCommentDetailViewModel.commentModel_flea.replies![index].replyId;
                                    bool? secret = _fleamarketCommentDetailViewModel.commentModel_flea.replies![index].secret;
                                    String? content = _fleamarketCommentDetailViewModel.commentModel_flea.replies![index].content;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 24),
                                      child: Obx(() => Container(
                                        color: Colors.white,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            if(secret! &&
                                                (_userViewModel.user.user_id != user_id_comment && _userViewModel.user.user_id != user_id_reply))
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    width: _size.width - 112,
                                                    child: Text('비밀글입니다.',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Color(0xFF111111)
                                                      ),),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if(!secret ||
                                               (secret && (_userViewModel.user.user_id == user_id_comment || _userViewModel.user.user_id == user_id_reply)))
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if (profileUrl != "")
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 4),
                                                        child: GestureDetector(
                                                          onTap: () async{
                                                          },
                                                          child: Container(
                                                            width: 26,
                                                            height: 26,
                                                            decoration: BoxDecoration(
                                                                color: Color(0xFFDFECFF),
                                                                borderRadius: BorderRadius.circular(50)
                                                            ),
                                                            child: ExtendedImage.network(
                                                              profileUrl!,
                                                              cache: true,
                                                              shape: BoxShape.circle,
                                                              borderRadius: BorderRadius.circular(20),
                                                              width: 26,
                                                              height: 26,
                                                              fit: BoxFit.cover,
                                                              loadStateChanged: (ExtendedImageState state) {
                                                                switch (state.extendedImageLoadState) {
                                                                  case LoadState.loading:
                                                                    return SizedBox.shrink();
                                                                  case LoadState.completed:
                                                                    return state.completedWidget;
                                                                  case LoadState.failed:
                                                                    return ExtendedImage.network(
                                                                      '${profileImgUrlList[0].default_round}',
                                                                      shape: BoxShape.circle,
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      width: 24,
                                                                      height: 24,
                                                                      fit: BoxFit.cover,
                                                                    ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                  default:
                                                                    return null;
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (profileUrl == "" )
                                                      Padding(
                                                        padding: EdgeInsets.only(top:4),
                                                        child: GestureDetector(
                                                          onTap: () async{

                                                          },
                                                          child: ExtendedImage.network(
                                                            '${profileImgUrlList[0].default_round}',
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
                                                              '$displayName',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 14,
                                                                  color: (displayName == '회원정보 없음')? Color(0xFFb7b7b7): Color(0xFF111111)),
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
                                                            if (secret!)
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 7),
                                                                child: Icon(Icons.lock,
                                                                  size: 15,
                                                                  color: Color(0xFF949494),
                                                                ),
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
                                                              SelectableText(
                                                                '$content',
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
                                                (user_id_reply != _userViewModel.user.user_id)
                                                    ? GestureDetector(
                                                  onTap: () => showModalBottomSheet(
                                                      enableDrag: false,
                                                      context: context,
                                                      builder: (context) {
                                                        return SafeArea(
                                                          child: Container(
                                                            height: 140,
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
                                                                                      await _fleamarketCommentDetailViewModel.reportReply({
                                                                                        "user_id": _userViewModel.user.user_id,
                                                                                        "reply_id": reply_id
                                                                                      });
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
                                                                          content:  Container(
                                                                            height: _size.width*0.17,
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  '이 회원의 게시물을 모두 숨길까요?',
                                                                                  style: TextStyle(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 15),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Text(
                                                                                  '차단해제는 [더보기 - 친구 - 설정 - 차단목록]에서\n하실 수 있습니다.',
                                                                                  style: TextStyle(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontSize: 12,
                                                                                      color: Color(0xFF555555)),
                                                                                ),
                                                                              ],
                                                                            ),
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
                                                                                      _userViewModel.block_user({
                                                                                        "user_id" : _userViewModel.user.user_id,
                                                                                        "block_user_id" : user_id_reply
                                                                                      });
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
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                  child:
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 22),
                                                    child:
                                                    Icon(
                                                      Icons.more_vert,
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
                                                          height: 130,
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
                                                                                              await _fleamarketCommentDetailViewModel.deleteFleamarketReply(
                                                                                                  replyID: reply_id,
                                                                                                  userID: _userViewModel.user.user_id.toString()
                                                                                              );
                                                                                              await _fleamarketCommentDetailViewModel.fetchFleamarketCommentDetail(
                                                                                                  commentId: _fleamarketCommentDetailViewModel.commentModel_flea.commentId!
                                                                                              );

                                                                                              print('댓글 삭제 완료');
                                                                                              Navigator.pop(context);
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
                                                    padding: const EdgeInsets.only(bottom: 22),
                                                    child: Icon(Icons.more_vert,
                                                      color: Color(0xFFdedede),
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
                                )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  _fleamarketCommentDetailViewModel.changeSecret();
                                },
                                child:Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                    (_fleamarketCommentDetailViewModel.isSecret == true)
                                        ? Color(0xFFCBE0FF)
                                        : Color(0xFFECECEC),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      (_fleamarketCommentDetailViewModel.isSecret == true)
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
                                      Text('비밀',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color:
                                            (_fleamarketCommentDetailViewModel.isSecret == true)
                                                ? Color(0xFF3D83ED)
                                                :Color(0xFF949494)
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  key: _fleamarketCommentDetailViewModel.formKey,
                                  cursorColor: Color(0xff377EEA),
                                  controller: _fleamarketCommentDetailViewModel.textEditingController,
                                  strutStyle: StrutStyle(leading: 0.3),
                                  maxLines: 1,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  textInputAction: TextInputAction.newline,
                                  decoration: InputDecoration(
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    suffixIcon: IconButton(
                                      splashColor: Colors.transparent,
                                      onPressed: () async {
                                        if (_fleamarketCommentDetailViewModel.textEditingController.text.trim().isEmpty) {
                                          return;
                                        }
                                        await _fleamarketCommentDetailViewModel.uploadFleamarketReply({
                                          "comment_id": _fleamarketCommentDetailViewModel.commentModel_flea.commentId.toString(),
                                          "content": _fleamarketCommentDetailViewModel.textEditingController.text,
                                          "user_id": _userViewModel.user.user_id.toString(),
                                          "secret": _fleamarketCommentDetailViewModel.isSecret
                                        });
                                        await _fleamarketCommentDetailViewModel.fetchFleamarketCommentDetail(
                                            commentId: _fleamarketCommentDetailViewModel.commentModel_flea.commentId!
                                        );
                                        FocusScope.of(context).unfocus();
                                        _fleamarketCommentDetailViewModel.textEditingController.clear();
                                      },
                                      icon: (_fleamarketCommentDetailViewModel.isCommentButtonEnabled.value == false)
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
                                    labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                    hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                    errorStyle: TextStyle(
                                      fontSize: 12,
                                    ),
                                    hintText: '답글을 입력하세요',
                                    contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                                    fillColor: Color(0xFFEFEFEF),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.transparent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _fleamarketCommentDetailViewModel.changeFleamarketCommentDetailInputText(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            )),
          ),
        ),
      ),
    );
  }
}
