import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityBulletinList.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityCommentDetail.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class CommunityCommentDetailView extends StatelessWidget {

  final CommunityCommentDetailViewModel _communityCommentDetailViewModel = Get.find<CommunityCommentDetailViewModel>();
  final CommunityDetailViewModel _communityDetailViewModel = Get.find<CommunityDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CommunityBulletinListViewModel _communityBulletinListViewModel = Get.find<CommunityBulletinListViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  FocusNode textFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: (){
        textFocus.unfocus();
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
              preferredSize: Size.fromHeight(44),
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
                        style: SDSTextStyle.extraBold.copyWith(
                            color: SDSColor.gray900,
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                titleSpacing: 0,
                backgroundColor: SDSColor.snowliveWhite,
                foregroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0.0,
              ),
            ),
            body: Obx(() => Container(
                margin: EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _communityCommentDetailViewModel.scrollController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () async{
                                        textFocus.unfocus();
                                        Get.toNamed(AppRoutes.friendDetail);
                                        await _friendDetailViewModel.fetchFriendDetailInfo(
                                            userId: _userViewModel.user.user_id,
                                            friendUserId: _communityCommentDetailViewModel.commentModel_community.userInfo!.userId!,
                                            season: _friendDetailViewModel.seasonDate);
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
                                          (_communityCommentDetailViewModel.commentModel_community.userInfo!.profileImageUrlUser!=null)
                                              ?'${_communityCommentDetailViewModel.commentModel_community.userInfo!.profileImageUrlUser}'
                                              : '${profileImgUrlList[0].default_round}',
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
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                              default:
                                                return null;
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${_communityCommentDetailViewModel.commentModel_community.userInfo!.displayName}',
                                                style: SDSTextStyle.bold.copyWith(
                                                  fontSize: 13,
                                                  color: SDSColor.gray900,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Text('${_communityCommentDetailViewModel.time}',
                                                style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 13,
                                                  color: SDSColor.gray500,
                                                ),
                                              ),
                                              Spacer(),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                constraints:
                                                BoxConstraints(
                                                    maxWidth: _size.width - 72),
                                                child: SelectableText(
                                                  '${_communityCommentDetailViewModel.commentModel_community.content}',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 14,
                                                    color: SDSColor.gray900,
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
                                (_communityCommentDetailViewModel.commentModel_community.replies!.isEmpty)
                                    ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: _size.height / 4),
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/imgs/icons/icon_nodata.png',
                                            scale: 4,
                                            width: 64,
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Text('첫 답글을 남겨주세요',
                                            style: SDSTextStyle.regular.copyWith(
                                                fontSize: 13,
                                                color: SDSColor.gray500
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                      padding: const EdgeInsets.only(left: 44, top: 24),
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
                                                      GestureDetector(
                                                        onTap: () async{
                                                          textFocus.unfocus();
                                                          Get.toNamed(AppRoutes.friendDetail);
                                                          await _friendDetailViewModel.fetchFriendDetailInfo(
                                                              userId: _userViewModel.user.user_id,
                                                              friendUserId: user_id_reply!,
                                                              season: _friendDetailViewModel.seasonDate);
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
                                                                    width: 26,
                                                                    height: 26,
                                                                    fit: BoxFit.cover,
                                                                  );
                                                                default:
                                                                  return null;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    if (profileUrl == "" )
                                                      Padding(
                                                        padding: EdgeInsets.only(top:4),
                                                        child: GestureDetector(
                                                          onTap: () async{
                                                            textFocus.unfocus();
                                                            Get.toNamed(AppRoutes.friendDetail);
                                                            await _friendDetailViewModel.fetchFriendDetailInfo(
                                                                userId: _userViewModel.user.user_id,
                                                                friendUserId: user_id_reply!,
                                                                season: _friendDetailViewModel.seasonDate);
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
                                                        width: 8
                                                    ),
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              '$displayName',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                fontSize: 13,
                                                                color: (displayName == '회원정보 없음') ? SDSColor.gray300 : SDSColor.gray900,
                                                              ),),
                                                            SizedBox(
                                                                width: 6),
                                                            Text(
                                                              '$_time',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 13,
                                                                color: SDSColor.gray500,
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
                                                                style: SDSTextStyle.regular.copyWith(
                                                                    color: SDSColor.gray900,
                                                                    fontSize: 13),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                (user_id_reply != _userViewModel.user.user_id)
                                                    ? GestureDetector(
                                                  onTap: () {
                                                    textFocus.unfocus();
                                                    showModalBottomSheet(
                                                        enableDrag: false,
                                                        isScrollControlled: true,
                                                        backgroundColor: Colors.transparent,
                                                        context: context,
                                                        builder: (context) {
                                                          return SafeArea(
                                                            child: Container(
                                                              child:
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
                                                                child: Container(
                                                                  margin: EdgeInsets.only(
                                                                    left: 16,
                                                                    right: 16,
                                                                    top: 16,
                                                                  ),
                                                                  padding: EdgeInsets.all(16),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    borderRadius: BorderRadius.circular(16),
                                                                  ),
                                                                  child: Wrap(
                                                                    children: [
                                                                      GestureDetector(
                                                                        child: ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '신고하기',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          //selected: _isSelected[index]!,
                                                                          onTap: () async {
                                                                            Get.dialog(
                                                                                AlertDialog(
                                                                                  backgroundColor: SDSColor.snowliveWhite,
                                                                                  contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                                                  elevation: 0,
                                                                                  shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(16)),
                                                                                  buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                  content: Container(
                                                                                    height: 80,
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          '이 회원을 신고하시겠습니까?',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: SDSTextStyle.bold.copyWith(
                                                                                              color: SDSColor.gray900,
                                                                                              fontSize: 16
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: 6,
                                                                                        ),
                                                                                        Text(
                                                                                          '신고가 일정 횟수 이상 누적되면 해당 게시물이 삭제 처리됩니다',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: SDSTextStyle.regular.copyWith(
                                                                                            color: SDSColor.gray500,
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  actions: [
                                                                                    Padding(
                                                                                      padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Container(
                                                                                              child: TextButton(
                                                                                                  onPressed: () {
                                                                                                    Navigator.pop(context);
                                                                                                  },
                                                                                                  style: TextButton.styleFrom(
                                                                                                    backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                    splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                  ),
                                                                                                  child: Text('취소',
                                                                                                    style: SDSTextStyle.bold.copyWith(
                                                                                                      fontSize: 17,
                                                                                                      color: SDSColor.gray500,
                                                                                                    ),
                                                                                                  )),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 10,
                                                                                          ),
                                                                                          Expanded(
                                                                                            child: Container(
                                                                                              child: TextButton(
                                                                                                  onPressed: () async {

                                                                                                    Navigator.pop(context);
                                                                                                    Navigator.pop(context);
                                                                                                    CustomFullScreenDialog.showDialog();
                                                                                                    await _communityCommentDetailViewModel.reportReply(
                                                                                                        userId:  _userViewModel.user.user_id,
                                                                                                        replyId:  reply_id!
                                                                                                    );
                                                                                                  },
                                                                                                  style: TextButton.styleFrom(
                                                                                                    backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                    splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                  ),
                                                                                                  child: Text('신고하기',
                                                                                                    style: SDSTextStyle.bold.copyWith(
                                                                                                      fontSize: 17,
                                                                                                      color: SDSColor.snowliveBlue,
                                                                                                    ),
                                                                                                  )),
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                      ),
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

                                                                            Get.dialog(
                                                                                AlertDialog(
                                                                                  backgroundColor: SDSColor.snowliveWhite,
                                                                                  contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                                                  elevation: 0,
                                                                                  shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(16)),
                                                                                  buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                  content:  Container(
                                                                                    height: 80,
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          '이 회원의 모든 글을 숨기시겠습니까?',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: SDSTextStyle.bold.copyWith(
                                                                                              color: SDSColor.gray900,
                                                                                              fontSize: 16
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: 6,
                                                                                        ),
                                                                                        Text(
                                                                                          '숨김해제는 [더보기 - 친구 - 설정 - 차단목록]에서 하실 수 있습니다.',
                                                                                          textAlign: TextAlign.center,
                                                                                          style: SDSTextStyle.regular.copyWith(
                                                                                            color: SDSColor.gray500,
                                                                                            fontSize: 14,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  actions: [
                                                                                    Padding(
                                                                                      padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: TextButton(
                                                                                                onPressed: () {
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                style: TextButton.styleFrom(
                                                                                                  backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                ),
                                                                                                child: Text('취소',
                                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                                    fontSize: 17,
                                                                                                    color: SDSColor.gray500,
                                                                                                  ),
                                                                                                )
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 10,
                                                                                          ),
                                                                                          Expanded(
                                                                                            child: Container(
                                                                                              child: TextButton(
                                                                                                  onPressed: () async{
                                                                                                    Navigator.pop(context);
                                                                                                    Navigator.pop(context);
                                                                                                    CustomFullScreenDialog.showDialog();
                                                                                                    await _userViewModel.block_user({
                                                                                                      "user_id" : _userViewModel.user.user_id.toString(),
                                                                                                      "block_user_id" : user_id_reply.toString()
                                                                                                    });
                                                                                                  },
                                                                                                  style: TextButton.styleFrom(
                                                                                                    backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                    splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                  ),
                                                                                                  child: Text('숨기기',
                                                                                                    style: SDSTextStyle.bold.copyWith(
                                                                                                      fontSize: 17,
                                                                                                      color: SDSColor.snowliveBlue,
                                                                                                    ),
                                                                                                  )),
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                      ),
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
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  child:Icon(
                                                    Icons.more_horiz,
                                                    color: SDSColor.gray200,
                                                    size: 20,
                                                  ),
                                                )
                                                    : GestureDetector(
                                                  onTap: () {
                                                    textFocus.unfocus();
                                                    showModalBottomSheet(
                                                        enableDrag: false,
                                                        isScrollControlled: true,
                                                        backgroundColor: Colors.transparent,
                                                        context: context,
                                                        builder: (context) {
                                                          return SafeArea(
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
                                                              child: Container(
                                                                margin: EdgeInsets.only(
                                                                  left: 16,
                                                                  right: 16,
                                                                  top: 16,
                                                                ),
                                                                padding: EdgeInsets.all(16),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(16),
                                                                ),
                                                                child: Wrap(
                                                                  children: [
                                                                    GestureDetector(
                                                                      child: ListTile(
                                                                        contentPadding: EdgeInsets.zero,
                                                                        title: Center(
                                                                          child: Text(
                                                                            '답글 삭제하기',
                                                                            style: TextStyle(
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Color(0xFFD63636)
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onTap: () async {
                                                                          Get.dialog(
                                                                              AlertDialog(
                                                                                contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                                                elevation: 0,
                                                                                backgroundColor: SDSColor.snowliveWhite,
                                                                                shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(16)),
                                                                                buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                content: Container(
                                                                                  height: 40,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        '이 글을 삭제하시겠어요?',
                                                                                        textAlign: TextAlign.center,
                                                                                        style: SDSTextStyle.bold.copyWith(
                                                                                            color: SDSColor.gray900,
                                                                                            fontSize: 16
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                actions: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Expanded(
                                                                                          child: Container(
                                                                                            child: TextButton(
                                                                                                onPressed: () {
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                style: TextButton.styleFrom(
                                                                                                  backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                ),
                                                                                                child: Text('취소',
                                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                                    fontSize: 17,
                                                                                                    color: SDSColor.gray500,
                                                                                                  ),
                                                                                                )
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: 10,
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Container(
                                                                                            child: TextButton(
                                                                                                onPressed: () async {
                                                                                                  CustomFullScreenDialog.showDialog();
                                                                                                  Navigator.pop(context);
                                                                                                  Navigator.pop(context);
                                                                                                  await _communityCommentDetailViewModel.deleteCommunityReply(
                                                                                                      replyID: reply_id,
                                                                                                      userID: _userViewModel.user.user_id.toString()
                                                                                                  );
                                                                                                  await _communityCommentDetailViewModel.fetchCommunityCommentDetail(
                                                                                                      commentId: _communityCommentDetailViewModel.commentModel_community.commentId!
                                                                                                  );
                                                                                                  print('댓글 삭제 완료');
                                                                                                  Navigator.pop(context);
                                                                                                  CustomFullScreenDialog.cancelDialog();
                                                                                                },
                                                                                                style: TextButton.styleFrom(
                                                                                                  backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                ),
                                                                                                child: Text('삭제하기',
                                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                                    fontSize: 17,
                                                                                                    color: SDSColor.red,
                                                                                                  ),
                                                                                                )),
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              )
                                                                          );
                                                                        },
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  child: Icon(
                                                    Icons.more_horiz,
                                                    color: SDSColor.gray200,
                                                    size: 20,
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
                                SizedBox(
                                  height: 40,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12),
                              child: Obx(()=>Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      focusNode: textFocus,
                                      key: _communityCommentDetailViewModel.formKey,
                                      controller: _communityCommentDetailViewModel.textEditingController,
                                      cursorColor: SDSColor.snowliveBlue,
                                      cursorHeight: 16,
                                      cursorWidth: 2,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      style: SDSTextStyle.regular.copyWith(fontSize: 15),
                                      strutStyle: StrutStyle(fontSize: 14, leading: 0),
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      textInputAction: TextInputAction.newline,
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          splashColor: Colors.transparent,
                                          onPressed: () async {
                                            textFocus.unfocus();
                                            if (_communityCommentDetailViewModel.textEditingController.text.trim().isEmpty) {
                                              return;
                                            }
                                            CustomFullScreenDialog.showDialog();
                                            await _communityCommentDetailViewModel.uploadCommunityReply({
                                              "comment_id": _communityCommentDetailViewModel.commentModel_community.commentId.toString(),
                                              "content": _communityCommentDetailViewModel.textEditingController.text,
                                              "user_id": _userViewModel.user.user_id.toString()
                                            });
                                            _communityCommentDetailViewModel.textEditingController.clear();
                                            _communityCommentDetailViewModel.scrollController.jumpTo(
                                              _communityCommentDetailViewModel.scrollController.position.maxScrollExtent,
                                            );
                                            CustomFullScreenDialog.cancelDialog();
                                            await _communityDetailViewModel.fetchCommunityComments(
                                                communityId: _communityCommentDetailViewModel.commentModel_community.communityId!,
                                                userId: _userViewModel.user.user_id,
                                                isLoading_indi: true);
                                            await _communityBulletinListViewModel.fetchAllCommunity();
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
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        errorMaxLines: 2,
                                        errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                        labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                        hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                        hintText: '답글을 입력하세요',
                                        contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 50),
                                        fillColor: SDSColor.gray50,
                                        hoverColor: SDSColor.snowliveBlue,
                                        filled: true,
                                        focusColor: SDSColor.snowliveBlue,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: SDSColor.gray50),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
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
                              )),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            left: 0,
                            bottom: 71,
                            child: Container(
                              height: 1,
                              color: SDSColor.gray50,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
            )),
          ),
        ),
      ),
    );
  }
}
