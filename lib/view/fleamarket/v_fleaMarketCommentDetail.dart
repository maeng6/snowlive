import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../data/imgaUrls/Data_url_image.dart';
import '../../data/snowliveDesignStyle.dart';
import '../../viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import '../../viewmodel/vm_user.dart';

class FleamarketCommentDetailView extends StatelessWidget {

  final FleamarketCommentDetailViewModel _fleamarketCommentDetailViewModel = Get.find<FleamarketCommentDetailViewModel>();
  final FleamarketDetailViewModel _fleamarketDetailViewModel = Get.find<FleamarketDetailViewModel>();
  final FleamarketListViewModel _fleamarketListViewModel = Get.find<FleamarketListViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
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
                        controller: _fleamarketCommentDetailViewModel.scrollController,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if(_fleamarketCommentDetailViewModel.commentModel_flea.userInfo!.profileImageUrlUser != '')
                                        GestureDetector(
                                        onTap: () async{
                                          textFocus.unfocus();
                                          Get.toNamed(AppRoutes.friendDetail);
                                          await _friendDetailViewModel.fetchFriendDetailInfo(
                                              userId: _userViewModel.user.user_id,
                                              friendUserId:_fleamarketCommentDetailViewModel.commentModel_flea.userInfo!.userId!,
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
                                            '${_fleamarketCommentDetailViewModel.commentModel_flea.userInfo!.profileImageUrlUser}',
                                            cache: true,
                                            enableMemoryCache: true,
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
                                                  return ClipOval(
                                                    child: Image.asset(
                                                      'assets/imgs/profile/img_profile_default_circle.png',
                                                      width: 32,
                                                      height: 32,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                  ; // 예시로 에러 아이콘을 반환하고 있습니다.
                                                default:
                                                  return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      if(_fleamarketCommentDetailViewModel.commentModel_flea.userInfo!.profileImageUrlUser == '')
                                        GestureDetector(
                                          onTap: () async{
                                            textFocus.unfocus();
                                            Get.toNamed(AppRoutes.friendDetail);
                                            await _friendDetailViewModel.fetchFriendDetailInfo(
                                                userId: _userViewModel.user.user_id,
                                                friendUserId:_fleamarketCommentDetailViewModel.commentModel_flea.userInfo!.userId!,
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
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/imgs/profile/img_profile_default_circle.png',
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              ),
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
                                                  '${_fleamarketCommentDetailViewModel.commentModel_flea.userInfo!.displayName}',
                                                  style: SDSTextStyle.bold.copyWith(
                                                    fontSize: 13,
                                                    color: SDSColor.gray900,
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Text('${_fleamarketCommentDetailViewModel.time}',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 13,
                                                    color: SDSColor.gray500,
                                                  ),
                                                ),
                                                if (_fleamarketCommentDetailViewModel.commentModel_flea.secret!)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 6),
                                                    child: Icon(Icons.lock,
                                                      size: 14,
                                                      color: SDSColor.gray300,
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
                                                    '${_fleamarketCommentDetailViewModel.commentModel_flea.content}',
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
                                  (_fleamarketCommentDetailViewModel.commentModel_flea.replies!.isEmpty)
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
                                        padding: const EdgeInsets.only(left: 44, top: 24),
                                        child: Obx(() => Container(
                                          color: Colors.white,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              if(secret! && (_userViewModel.user.user_id != user_id_comment && _userViewModel.user.user_id != user_id_reply))
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 8),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: 26,
                                                        height: 26,
                                                        decoration: BoxDecoration(
                                                          color: SDSColor.gray100,
                                                          borderRadius: BorderRadius.circular(50),
                                                        ),
                                                        child: Icon(Icons.lock,
                                                          size: 14,
                                                          color: SDSColor.gray400,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(left: 8),
                                                        child: Container(
                                                          width: _size.width - 140,
                                                          child: Text('이 글은 비밀글입니다.',
                                                            style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 14,
                                                                color: SDSColor.gray500
                                                            ),),
                                                        ),
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
                                                                      ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                    default:
                                                                      return null;
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        if (profileUrl == "" )
                                                          GestureDetector(
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
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 6),
                                                                Text(
                                                                  '$_time',
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                    fontSize: 13,
                                                                    color: SDSColor.gray500,
                                                                  ),
                                                                ),
                                                                if (secret!)
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left: 6),
                                                                    child: Icon(Icons.lock,
                                                                      size: 14,
                                                                      color: SDSColor.gray300,
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
                                                                                                        Navigator.pop(context);
                                                                                                        Navigator.pop(context);
                                                                                                        CustomFullScreenDialog.showDialog();
                                                                                                        await _fleamarketCommentDetailViewModel.reportReply({
                                                                                                          "user_id": _userViewModel.user.user_id.toString(),
                                                                                                          "reply_id": reply_id
                                                                                                        });
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
                                                                                    )
                                                                                );
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
                                                                                                child: Container(
                                                                                                  child: TextButton(
                                                                                                      onPressed: () async{
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
                                                                                                        Navigator.pop(context);
                                                                                                        Navigator.pop(context);
                                                                                                        CustomFullScreenDialog.showDialog();
                                                                                                        await _userViewModel.block_user({
                                                                                                          "user_id" : _userViewModel.user.user_id,    //필수 - 차단하는 사람(나)
                                                                                                          "block_user_id" : user_id_reply   //필수 - 내가 차단할 사람
                                                                                                        });
                                                                                                        await _fleamarketCommentDetailViewModel.fetchFleamarketCommentDetail(
                                                                                                            commentId: _fleamarketCommentDetailViewModel.commentModel_flea.commentId!
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
                                                                                '답글 삭제하기',
                                                                                style: TextStyle(
                                                                                    fontSize: 15,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Color(0xFFD63636)
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            //selected: _isSelected[index]!,
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
                                                                                                      Navigator.pop(context);
                                                                                                      Navigator.pop(context);
                                                                                                      CustomFullScreenDialog.showDialog();
                                                                                                      await _fleamarketCommentDetailViewModel.deleteFleamarketReply(
                                                                                                          replyID: reply_id,
                                                                                                          userID: _userViewModel.user.user_id.toString()
                                                                                                      );
                                                                                                      await _fleamarketCommentDetailViewModel.fetchFleamarketCommentDetail(
                                                                                                          commentId: _fleamarketCommentDetailViewModel.commentModel_flea.commentId!
                                                                                                      );
                                                                                                      CustomFullScreenDialog.cancelDialog();
                                                                                                      print('댓글 삭제 완료');
                                                                                                      _fleamarketListViewModel.fetchAllFleamarket();
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
                                                      child:
                                                      Icon(
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
                    ),
                    SafeArea(
                      child: Stack(
                        children: [
                          Container(
                            height: 72,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      _fleamarketCommentDetailViewModel.changeSecret();
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color:
                                        (_fleamarketCommentDetailViewModel.isSecret == true)
                                            ? SDSColor.blue100
                                            : SDSColor.gray50,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          (_fleamarketCommentDetailViewModel.isSecret == true)
                                              ? Icon(Icons.lock,
                                            size: 17,
                                            color: SDSColor.snowliveBlue,
                                          )
                                              :  Icon(Icons.lock,
                                            size: 17,
                                            color: SDSColor.gray400,
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      focusNode: textFocus,
                                      key: _fleamarketCommentDetailViewModel.formKey,
                                      controller: _fleamarketCommentDetailViewModel.textEditingController,
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
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        errorMaxLines: 2,
                                        errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                        labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                        hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                        suffixIcon: IconButton(
                                          splashColor: Colors.transparent,
                                          onPressed: () async {
                                            textFocus.unfocus();
                                            if (_fleamarketCommentDetailViewModel.textEditingController.text.trim().isEmpty) {
                                              return;
                                            }
                                            CustomFullScreenDialog.showDialog();
                                            await _fleamarketCommentDetailViewModel.uploadFleamarketReply({
                                              "comment_id": _fleamarketCommentDetailViewModel.commentModel_flea.commentId.toString(),
                                              "content": _fleamarketCommentDetailViewModel.textEditingController.text,
                                              "user_id": _userViewModel.user.user_id.toString(),
                                              "secret": _fleamarketCommentDetailViewModel.isSecret
                                            });
                                            FocusScope.of(context).unfocus();
                                            _fleamarketCommentDetailViewModel.textEditingController.clear();
                                            CustomFullScreenDialog.cancelDialog();
                                            await _fleamarketDetailViewModel.fetchFleamarketComments(
                                                fleaId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                userId: _userViewModel.user.user_id,
                                                isLoading_indi: true
                                            );
                                            await _fleamarketListViewModel.fetchAllFleamarket();
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
                                        _fleamarketCommentDetailViewModel.changeFleamarketCommentDetailInputText(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
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
