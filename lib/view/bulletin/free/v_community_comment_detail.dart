
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/vm_communityCommentDetail.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../viewmodel/vm_communityDetail.dart';
import '../../../viewmodel/vm_user.dart';

class CommunityCommentDetailView extends StatelessWidget {

  final CommunityCommentDetailViewModel _communityCommentDetailViewModel = Get.find<CommunityCommentDetailViewModel>();
  final CommunityDetailViewModel _communityDetailViewModel = Get.find<CommunityDetailViewModel>();
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
                                      '${_communityCommentDetailViewModel.commentModel_community.userInfo!.profileImageUrlUser}',
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
                                      '${_communityCommentDetailViewModel.commentModel_community.userInfo!.displayName}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF111111)),
                                    ),
                                    SizedBox(width: 1),
                                    Text('· ${_communityCommentDetailViewModel.time}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF949494),
                                          fontWeight: FontWeight.w300),
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
                                    '${_communityCommentDetailViewModel.commentModel_community.content}',
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
                            (_communityCommentDetailViewModel.commentModel_community.replies!.isEmpty)
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
                                  itemCount: _communityCommentDetailViewModel.commentModel_community.replies!.length,
                                  itemBuilder: (context, index) {
                                    String _time = GetDatetime().getAgoString(_communityCommentDetailViewModel.commentModel_community.replies![index].uploadTime!);
                                    String? profileUrl = _communityCommentDetailViewModel.commentModel_community.replies![index].userInfo!.profileImageUrlUser;
                                    String? displayName = _communityCommentDetailViewModel.commentModel_community.replies![index].userInfo!.displayName;
                                    int? user_id_reply = _communityCommentDetailViewModel.commentModel_community.replies![index].userInfo!.userId;
                                    int? reply_id = _communityCommentDetailViewModel.commentModel_community.replies![index].replyId;
                                    String? content = _communityCommentDetailViewModel.commentModel_community.replies![index].content;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 24),
                                      child: Obx(() => Container(
                                        color: Colors.white,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
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
                                                                    );
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
                                                                                      await _communityCommentDetailViewModel.reportReply(
                                                                                          userId:  _userViewModel.user.user_id,
                                                                                          replyId:  reply_id!
                                                                                      );
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
                                                                                              await _communityCommentDetailViewModel.deleteCommunityReply(
                                                                                                  replyID: reply_id,
                                                                                                  userID: _userViewModel.user.user_id.toString()
                                                                                              );
                                                                                              await _communityCommentDetailViewModel.fetchCommunityCommentDetail(
                                                                                                  commentId: _communityCommentDetailViewModel.commentModel_community.commentId!
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
                              Expanded(
                                child: TextFormField(
                                  key: _communityCommentDetailViewModel.formKey,
                                  cursorColor: Color(0xff377EEA),
                                  controller: _communityCommentDetailViewModel.textEditingController,
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
                                        if (_communityCommentDetailViewModel.textEditingController.text.trim().isEmpty) {
                                          return;
                                        }
                                        await _communityCommentDetailViewModel.uploadCommunityReply({
                                          "comment_id": _communityCommentDetailViewModel.commentModel_community.commentId.toString(),
                                          "content": _communityCommentDetailViewModel.textEditingController.text,
                                          "user_id": _userViewModel.user.user_id.toString()
                                        });
                                        await _communityCommentDetailViewModel.fetchCommunityCommentDetail(
                                            commentId: _communityCommentDetailViewModel.commentModel_community.commentId!
                                        );
                                        FocusScope.of(context).unfocus();
                                        _communityCommentDetailViewModel.textEditingController.clear();
                                      },
                                      icon: (_communityCommentDetailViewModel.isCommentButtonEnabled.value == false)
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
                                    _communityCommentDetailViewModel.changeCommunityCommentDetailInputText(value);
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
