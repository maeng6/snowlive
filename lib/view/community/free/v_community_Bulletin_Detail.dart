import 'dart:convert';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_communityList.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityBulletinList.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityCommentDetail.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityDetail.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityUpdate.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'dart:io' as io;



class CommunityBulletinDetailView extends StatelessWidget {
  CommunityBulletinDetailView({Key? key}) : super(key: key);

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final CommunityDetailViewModel _communityDetailViewModel = Get.find<CommunityDetailViewModel>();
  final CommunityCommentDetailViewModel _communityCommentDetailViewModel = Get.find<CommunityCommentDetailViewModel>();
  final CommunityUpdateViewModel _communityUpdateViewModel = Get.find<CommunityUpdateViewModel>();
  final CommunityBulletinListViewModel _communityBulletinListViewModel = Get.find<CommunityBulletinListViewModel>();

  FocusNode textFocus = FocusNode();


  @override
  Widget build(BuildContext context) {

    String _time = GetDatetime().yyyymmddFormatFromString(_communityDetailViewModel.communityDetail.uploadTime!);
    Size _size = MediaQuery.of(context).size;
    return Obx(()=> Container(
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
                  _communityDetailViewModel.textEditingController.clear();
                  Get.back();
                },
              ),
              actions: [
                (_communityDetailViewModel.communityDetail.userId != _userViewModel.user.user_id)
                    ? GestureDetector(
                  onTap: (){
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
                                    // 신고하기
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
                                                                  await _communityDetailViewModel.reportCommunity(
                                                                      userId:  _userViewModel.user.user_id,
                                                                      communityId: _communityDetailViewModel.communityDetail.communityId
                                                                  );
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
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
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                    ),
                                                  )
                                                ],
                                              ));
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                      ),
                                    ),
                                    // 숨기기
                                    GestureDetector(
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Center(
                                          child: Text(
                                            '이 회원의 모든 글 숨기기',
                                            style: SDSTextStyle.bold.copyWith(
                                                fontSize: 15,
                                                color: SDSColor.gray900
                                            ),
                                          ),
                                        ),
                                        onTap: () async {
                                          Get.dialog(AlertDialog(
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
                                                      child: Container(
                                                        child: TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            style: TextButton.styleFrom(
                                                              backgroundColor: Colors.transparent, // 배경색 투명
                                                              splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                            ),
                                                            child: Text(
                                                              '취소',
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
                                                            onPressed: () async{
                                                              await _userViewModel.block_user({
                                                                "user_id": _userViewModel.user.user_id,
                                                                "block_user_id": _communityDetailViewModel.communityDetail.communityId
                                                              });
                                                              Navigator.pop(context);
                                                              Navigator.pop(context);
                                                              Navigator.pop(context);
                                                            },
                                                            style: TextButton.styleFrom(
                                                              backgroundColor: Colors.transparent, // 배경색 투명
                                                              splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                            ),
                                                            child: Text('확인',
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
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Image.asset(
                      'assets/imgs/icons/icon_flea_appbar_more.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                    ),
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
                            child: SafeArea(
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 16,
                                ),
                                height: 144,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Wrap(
                                  children: [
                                    (_communityDetailViewModel.communityDetail.userId == _userViewModel.user.user_id)
                                    //수정하기
                                        ? GestureDetector(
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Center(
                                          child: Text(
                                            '글 수정하기',
                                            style: SDSTextStyle.bold.copyWith(
                                                fontSize: 15,
                                                color: SDSColor.gray900
                                            ),
                                          ),
                                        ),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await _communityUpdateViewModel.fetchCommunityUpdateData(
                                            textEditingController_title: _communityDetailViewModel.communityDetail.title!,
                                            selectedCategorySub:  _communityDetailViewModel.communityDetail.categorySub!,
                                            selectedCategoryMain:  _communityDetailViewModel.communityDetail.categoryMain!,
                                            description:  jsonEncode(_communityDetailViewModel.communityDetail.description!.toDelta().toJson()),
                                          );
                                          Get.toNamed(AppRoutes.bulletinDetailUpdate);
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10)),
                                      ),
                                    )
                                        : SizedBox(),
                                    //삭제하기
                                    GestureDetector(
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Center(
                                          child: Text(
                                            '글 삭제하기',
                                            style: SDSTextStyle.bold.copyWith(
                                                fontSize: 15,
                                                color: SDSColor.red
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
                                                                  await _communityDetailViewModel.deleteCommunityPost(
                                                                      _communityDetailViewModel.communityDetail.communityId!,
                                                                      _userViewModel.user.user_id
                                                                  );
                                                                  await _communityBulletinListViewModel.fetchCommunityList_total(userId: _userViewModel.user.user_id,categoryMain: '게시판');
                                                                  Navigator.pop(context);
                                                                  Navigator.pop(context);
                                                                  CustomFullScreenDialog.cancelDialog();
                                                                  Get.back();
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
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Image.asset(
                      'assets/imgs/icons/icon_flea_appbar_more.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                    ),
                  ),
                )
              ],
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0.0,
            ),
          ),
          body: Obx(()=>GestureDetector(
            onTap: (){
              textFocus.unfocus();
              FocusScope.of(context).unfocus();
            },
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: _size.height - MediaQuery.of(context).viewPadding.top - 58 - MediaQuery.of(context).viewPadding.bottom - 88,
                      child: RefreshIndicator(
                        strokeWidth: 2,
                        edgeOffset: 20,
                        backgroundColor: SDSColor.snowliveWhite,
                        color: SDSColor.snowliveBlue,
                        onRefresh: () async{
                          await _communityDetailViewModel.fetchCommunityDetail(
                              _communityDetailViewModel.communityDetail.communityId!,
                              _userViewModel.user.user_id
                          );
                        },
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: _communityDetailViewModel.scrollController,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: SDSColor.blue50,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${_communityDetailViewModel.communityDetail.categoryMain}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: SDSTextStyle.regular.copyWith(
                                              fontSize: 12,
                                              color: SDSColor.snowliveBlue),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: _size.width - 32,
                                          child: Text(
                                            '${_communityDetailViewModel.communityDetail.title}',
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: SDSTextStyle.bold.copyWith(
                                                fontSize: 18,
                                                color: SDSColor.gray900
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    //날짜, 조회수, 댓글수, 프사, 닉네임, 스키장, 크루
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('$_time',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 13,
                                                color: SDSColor.gray700,
                                              ),
                                            ),
                                            Text('  |  ',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 13,
                                                color: SDSColor.gray300,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Image.asset('assets/imgs/icons/icon_eye_rounded.png',
                                                  width: 14,
                                                  height: 14,),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 2),
                                                  child: Text('${_communityDetailViewModel.communityDetail.viewsCount}',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 13,
                                                      color: SDSColor.gray700,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Image.asset('assets/imgs/icons/icon_reply_rounded.png',
                                                  width: 14,
                                                  height: 14,),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 2),
                                                  child: Text('${_communityDetailViewModel.communityDetail.commentCount}',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 13,
                                                      color: SDSColor.gray700,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () async{
                                            textFocus.unfocus();
                                            Get.toNamed(AppRoutes.friendDetail);
                                            await _friendDetailViewModel.fetchFriendDetailInfo(
                                                userId: _userViewModel.user.user_id,
                                                friendUserId:_communityDetailViewModel.communityDetail.userId!,
                                                season: _friendDetailViewModel.seasonDate);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 16),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                if (_communityDetailViewModel.communityDetail.userInfo!.profileImageUrlUser != '')
                                                  Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: SDSColor.blue50,
                                                      borderRadius: BorderRadius.circular(50),
                                                      border: Border.all(
                                                        color: SDSColor.gray100,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: ExtendedImage.network(
                                                      '${_communityDetailViewModel.communityDetail.userInfo!.profileImageUrlUser}',
                                                      cache: true,
                                                      cacheHeight: 100,
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
                                                              cacheHeight: 100,
                                                              cache: true,
                                                              fit: BoxFit.cover,
                                                            );
                                                          default:
                                                            return null;
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                if (_communityDetailViewModel.communityDetail.userInfo!.profileImageUrlUser == '')
                                                  ExtendedImage.network(
                                                    '${profileImgUrlList[0].default_round}',
                                                    shape: BoxShape.circle,
                                                    borderRadius:
                                                    BorderRadius.circular(20),
                                                    width: 32,
                                                    height: 32,
                                                    cacheHeight: 100,
                                                    cache: true,
                                                    fit: BoxFit.cover,
                                                  ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 10),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('${_communityDetailViewModel.communityDetail.userInfo!.displayName}',
                                                        style: SDSTextStyle.regular.copyWith(
                                                            fontSize: 12,
                                                            color: SDSColor.gray900),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text('${_communityDetailViewModel.communityDetail.userInfo!.resortNickname}',
                                                            style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 12,
                                                                color: SDSColor.gray500),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: SDSColor.gray50,
                                      height: 32,
                                      thickness: 1,
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //퀼 본문
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    width: _size.width,
                                                    child: quill.QuillEditor.basic(
                                                      configurations: quill.QuillEditorConfigurations(
                                                        controller: _communityDetailViewModel.quillController,
                                                        scrollable: true,
                                                        showCursor: false,
                                                        checkBoxReadOnly: true,
                                                        padding: EdgeInsets.zero,
                                                        embedBuilders: [
                                                          CustomImageEmbedBuilder(),
                                                          ...FlutterQuillEmbeds.defaultEditorBuilders(),
                                                        ],
                                                        customStyles: quill.DefaultStyles(
                                                          h1: quill.DefaultTextBlockStyle(
                                                            TextStyle(
                                                              fontSize: 32,
                                                              height: 1.15,
                                                              fontWeight: FontWeight.w300,
                                                            ),
                                                            quill.HorizontalSpacing(0, 0),
                                                            quill.VerticalSpacing(16, 0), // 첫 번째 VerticalSpacing
                                                            quill.VerticalSpacing(0, 0), // 두 번째 VerticalSpacing
                                                            null, // BoxDecoration? - null 허용
                                                          ),
                                                          sizeSmall: TextStyle(
                                                            fontSize: 9,
                                                          ),
                                                        ),
                                                      ),
                                                      scrollController: ScrollController(),
                                                    )

                                                ),
                                                Container(
                                                  height: 20,
                                                )
                                              ],
                                            ),
                                          ]),
                                    ),
                                    Divider(
                                      color: SDSColor.gray50,
                                      height: 60,
                                      thickness: 8,
                                    ),
                                    //댓글
                                    Obx(()=> Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 20),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      '댓글',
                                                      style: SDSTextStyle.bold.copyWith(
                                                          fontSize: 14,
                                                          color: SDSColor.gray900),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              (_communityDetailViewModel.communityDetail.commentList!.length > 0)
                                                  ? Obx(()=> ListView.builder(
                                                controller: _communityDetailViewModel.scrollController_comment,
                                                shrinkWrap: true,
                                                itemCount: _communityDetailViewModel.communityDetail.commentList!.length,
                                                itemBuilder: (context, index) {
                                                  CommentModel_community comment = _communityDetailViewModel.communityDetail.commentList![index];
                                                  String _time = GetDatetime().getAgoString(comment.uploadTime!);
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 30),
                                                    child: Obx(() => Container(
                                                      color: Colors.white,
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              if (comment.userInfo!.profileImageUrlUser != "")
                                                              //댓글 프사 있는 경우
                                                                GestureDetector(
                                                                  onTap: () async{
                                                                    textFocus.unfocus();
                                                                    Get.toNamed(AppRoutes.friendDetail);
                                                                    await _friendDetailViewModel.fetchFriendDetailInfo(
                                                                        userId: _userViewModel.user.user_id,
                                                                        friendUserId:comment.userId!,
                                                                        season: _friendDetailViewModel.seasonDate);
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(bottom: 8),
                                                                    child: Container(
                                                                      width: 32,
                                                                      height: 32,
                                                                      decoration: BoxDecoration(
                                                                        color: SDSColor.blue50,
                                                                        borderRadius: BorderRadius.circular(50),
                                                                        border: Border.all(
                                                                          color: SDSColor.gray100,
                                                                          width: 1,
                                                                        ),

                                                                      ),
                                                                      child: ExtendedImage.network(
                                                                        '${comment.userInfo!.profileImageUrlUser}',
                                                                        cache: true,
                                                                        cacheHeight: 100,
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
                                                                                cacheHeight: 100,
                                                                                cache: true,
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
                                                              if (comment.userInfo!.profileImageUrlUser == "")
                                                              //댓글 프사 없는 경우
                                                                GestureDetector(
                                                                  onTap: () async{
                                                                    textFocus.unfocus();
                                                                    Get.toNamed(AppRoutes.friendDetail);
                                                                    await _friendDetailViewModel.fetchFriendDetailInfo(
                                                                        userId: _userViewModel.user.user_id,
                                                                        friendUserId:comment.userId!,
                                                                        season: _friendDetailViewModel.seasonDate);
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(bottom: 8),
                                                                    child: ExtendedImage.network(
                                                                      '${profileImgUrlList[0].default_round}',
                                                                      shape: BoxShape.circle,
                                                                      borderRadius:
                                                                      BorderRadius.circular(20),
                                                                      width: 32,
                                                                      height: 32,
                                                                      cacheHeight: 100,
                                                                      cache: true,
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              SizedBox(width: 10),
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Text(
                                                                        '${comment.userInfo!.displayName}',
                                                                        style: SDSTextStyle.bold.copyWith(
                                                                            fontSize: 13,
                                                                            color: SDSColor.gray900),
                                                                      ),
                                                                      SizedBox(
                                                                          width: 6),
                                                                      Text(
                                                                        '$_time',
                                                                        style: SDSTextStyle.regular.copyWith(
                                                                          fontSize: 12,
                                                                          color: SDSColor.gray500,
                                                                        ),
                                                                      ),
                                                                      SizedBox(width: 6),
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(4),
                                                                          color:
                                                                          (comment.userInfo!.userId == _communityDetailViewModel.communityDetail.userId)
                                                                              ? SDSColor.blue50
                                                                              : Colors.transparent,
                                                                        ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.only(top: 2, bottom: 2, left: 6, right: 6),
                                                                          child: Text(
                                                                            '글쓴이',
                                                                            style: SDSTextStyle.bold.copyWith(fontSize: 11,
                                                                                color:
                                                                                (comment.userInfo!.userId == _communityDetailViewModel.communityDetail.userId)
                                                                                    ? SDSColor.snowliveBlue
                                                                                    : Colors.transparent),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () async{
                                                                      textFocus.unfocus();
                                                                      _communityCommentDetailViewModel.fetchCommunityCommentDetailFromModel(commentModel_community: comment);
                                                                      Get.toNamed(AppRoutes.bulletinCommentDetail);
                                                                    },
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(top: 2),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            constraints:
                                                                            BoxConstraints(maxWidth: _size.width - 110),
                                                                            child:
                                                                            SelectableText(
                                                                              '${comment.content}',
                                                                              style: SDSTextStyle.regular.copyWith(
                                                                                  color: SDSColor.gray900,
                                                                                  fontSize: 14,
                                                                                  height: 1.4),
                                                                            ),
                                                                          ),
                                                                          SizedBox(height: 12),
                                                                          Text(
                                                                            (comment.replies!.length == 0)
                                                                                ? '답글 달기'
                                                                                : '답글 ${comment.replies!.length}개 보기',
                                                                            style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: SDSColor.snowliveBlack,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          (_communityDetailViewModel.communityDetail.commentList![index].userId != _userViewModel.user.user_id)
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
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
                                                                        child: Container(
                                                                          margin: EdgeInsets.only(
                                                                            left: 16,
                                                                            right: 16,
                                                                            top: 16,
                                                                          ),
                                                                          height: 144,
                                                                          padding: EdgeInsets.all(16),
                                                                          decoration: BoxDecoration(
                                                                            color: Colors.white,
                                                                            borderRadius: BorderRadius.circular(16),
                                                                          ),
                                                                          child: Wrap(
                                                                            children: [
                                                                              Column(
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
                                                                                                              child: Text(
                                                                                                                '취소',
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
                                                                                                                await _communityDetailViewModel.reportCommunity(userId: _userViewModel.user.user_id, communityId: comment.commentId);
                                                                                                                Navigator.pop(context);
                                                                                                                Navigator.pop(context);
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
                                                                                          style: SDSTextStyle.bold.copyWith(
                                                                                              fontSize: 15,
                                                                                              color: SDSColor.gray900
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
                                                                                                              onPressed: () async{
                                                                                                                await _userViewModel.block_user({
                                                                                                                  "user_id": _userViewModel.user.user_id,
                                                                                                                  "block_user_id": comment.userId
                                                                                                                });
                                                                                                                Navigator.pop(context);
                                                                                                                Navigator.pop(context);
                                                                                                                Navigator.pop(context);
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
                                                                                                              )
                                                                                                          ),
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
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });
                                                            },
                                                            child:
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 22),
                                                              child:
                                                              Icon(
                                                                Icons.more_horiz,
                                                                color: SDSColor.gray200,
                                                                size: 20,
                                                              ),
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
                                                                              Column(
                                                                                children: [
                                                                                  GestureDetector(
                                                                                    child: ListTile(
                                                                                      contentPadding: EdgeInsets.zero,
                                                                                      title: Center(
                                                                                        child: Text(
                                                                                          '삭제하기',
                                                                                          style: SDSTextStyle.bold.copyWith(
                                                                                            fontSize: 15,
                                                                                            color: SDSColor.red,
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
                                                                                                                await _communityDetailViewModel.deleteComment(comment.commentId!, _userViewModel.user.user_id);
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
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });
                                                            },
                                                            child:
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 22),
                                                              child:  Icon(
                                                                Icons.more_horiz,
                                                                color: SDSColor.gray200,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                                  );
                                                },
                                              ))
                                                  : Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(top: 10),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Image.asset(
                                                          'assets/imgs/icons/icon_friendsTalk_nodata.png',
                                                          width: 74,
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text('댓글이 없어요',
                                                          style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 14,
                                                              color: SDSColor.gray500),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )

                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: _size.width,
                        color: SDSColor.gray50,
                        height: 1,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                focusNode: textFocus,
                                key: _communityDetailViewModel.formKey,
                                textAlignVertical: TextAlignVertical.center,
                                cursorColor: SDSColor.snowliveBlue,
                                cursorHeight: 16,
                                cursorWidth: 2,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                controller: _communityDetailViewModel.textEditingController,
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 15
                                ),
                                strutStyle: StrutStyle(fontSize: 14, leading: 0),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                enableSuggestions: false,
                                autocorrect: false,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      splashColor: Colors.transparent,
                                      onPressed: () async {
                                        textFocus.unfocus();
                                        CustomFullScreenDialog.showDialog();

                                        if (_communityDetailViewModel.textEditingController.text.trim().isEmpty) {
                                          return;
                                        }
                                        await _communityDetailViewModel.createComment({
                                          "community_id": _communityDetailViewModel.communityDetail.communityId,
                                          "content": _communityDetailViewModel.textEditingController.text,
                                          "user_id": _userViewModel.user.user_id,
                                        });
                                        _communityDetailViewModel.textEditingController.clear();
                                        _communityDetailViewModel.scrollController.jumpTo(
                                          _communityDetailViewModel.scrollController.position.maxScrollExtent,
                                        );
                                        FocusScope.of(context).unfocus();
                                        CustomFullScreenDialog.cancelDialog();
                                        await _communityBulletinListViewModel.fetchAllCommunity();
                                      },
                                      icon: (_communityDetailViewModel.isCommentButtonEnabled.value == false)
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
                                    errorStyle: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.red,
                                    ),
                                    labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintText: '답글을 남겨 주세요.',
                                    contentPadding: EdgeInsets.only(
                                        top: 10, bottom: 10, left: 12, right: 12),
                                    fillColor: SDSColor.gray50,
                                    hoverColor: SDSColor.snowliveBlue,
                                    filled: true,
                                    focusColor: SDSColor.snowliveBlue,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: SDSColor.gray50),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    errorBorder:  OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: SDSColor.red,
                                          strokeAlign: BorderSide.strokeAlignInside,
                                          width: 1.5),
                                    ),
                                    focusedBorder:  OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: SDSColor.snowliveBlue,
                                          strokeAlign: BorderSide.strokeAlignInside,
                                          width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(6),
                                    )),
                                onChanged: (value) {
                                  _communityDetailViewModel.changeCommunityCommentsInputText(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
        ),
      ),
    ));
  }
}



class CustomImageEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, quill.QuillController controller, quill.Embed node, bool readOnly, bool inline, TextStyle textStyle) {
    final imageUrl = node.value.data;

    final imageProvider = imageUrl.startsWith('http') || imageUrl.startsWith('https')
        ? NetworkImage(imageUrl)
        : FileImage(io.File(imageUrl)) as ImageProvider;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: imageProvider,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: 300, // 필요에 따라 높이 조정
              color: SDSColor.gray50, // 회색 박스
              child: Center(
                child: CircularProgressIndicator(
                  color: SDSColor.gray200,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 300, // 필요에 따라 높이 조정
              color: SDSColor.gray50,
              child: const Center(
                child: Icon(Icons.error, color: Colors.red),
              ),
            );
          },
        ),
      ),
    );
  }
}
