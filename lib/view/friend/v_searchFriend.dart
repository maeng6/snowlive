import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SearchFriendView extends StatelessWidget {
  final f = NumberFormat('###,###,###,###');
  final FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  FocusNode textFocus = FocusNode();


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () {
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
                backgroundColor: SDSColor.snowliveWhite,
                foregroundColor: SDSColor.snowliveWhite,
                surfaceTintColor: SDSColor.snowliveWhite,
                leading: GestureDetector(
                  child: Image.asset(
                    'assets/imgs/icons/icon_snowLive_back.png',
                    scale: 4,
                    width: 26,
                    height: 26,
                  ),
                  onTap: () {
                    _friendListViewModel.searchFriendSuccess == false;
                    Get.back();
                  },
                ),
                elevation: 0.0,
                titleSpacing: 0,
                centerTitle: true,
                title: Text(
                  '친구 검색',
                  style: SDSTextStyle.extraBold.copyWith(
                      color: SDSColor.gray900,
                      fontSize: 18),
                ),
              ),
            ),
            body: SafeArea(
              child: Container(
                height: _size.height - _statusBarSize - 44,
                child: Obx(() => Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Form(
                                  key: _friendListViewModel.formKey,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 4, bottom: 10),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: TextFormField(
                                            focusNode: textFocus,
                                            onFieldSubmitted: (val) async {

                                              if(val.isNotEmpty){
                                                CustomFullScreenDialog.showDialog();
                                                await _friendListViewModel.searchUser(
                                                    _friendListViewModel.textEditingController.text);
                                                _friendListViewModel.textEditingController.clear();
                                                CustomFullScreenDialog.cancelDialog();
                                              }

                                            },
                                            textAlignVertical: TextAlignVertical.center,
                                            cursorColor: SDSColor.snowliveBlue,
                                            cursorHeight: 16,
                                            cursorWidth: 2,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            style: SDSTextStyle.regular.copyWith(fontSize: 14),
                                            strutStyle: StrutStyle(fontSize: 14, leading: 0),
                                            controller: _friendListViewModel.textEditingController,
                                            decoration: InputDecoration(
                                              errorMaxLines: 1,
                                              errorStyle: SDSTextStyle.regular.copyWith(fontSize: 0, color: SDSColor.red),
                                              labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                              hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                              hintText: '친구 검색',
                                              contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 36, right: 12),
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
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          bottom: 0,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Image.asset('assets/imgs/icons/icon_search.png',
                                              width: 16,),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 40),
                                Obx(() {
                                  // 처음 진입 후 검색 시도 전 처리
                                  if(_friendListViewModel.searchFriendSuccess == false) {
                                    // 검색된 친구 데이터가 없을 때 처리
                                    return Container(
                                      height: _size.height - 300,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/imgs/icons/icon_friend_search_illust.png',
                                              width: 120,
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Text('친구를 검색해 보세요',
                                              style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 14,
                                                  color: SDSColor.gray600
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ); } else {
                                    if (_friendListViewModel.searchFriend.userId == null) {
                                      return Container(
                                        height: _size.height - 300,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/imgs/icons/icon_nodata.png',
                                                scale: 4,
                                                width: 73,
                                                height: 73,
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Text('친구 검색 결과가 없습니다.',
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 14,
                                                    color: SDSColor.gray600
                                                ),
                                              ),
                                              Text('닉네임 전체를 정확히 입력해 주세요.',
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 14,
                                                    color: SDSColor.gray600
                                                ),
                                              )

                                            ],
                                          ),
                                        ),
                                      );
                                    } }
                                  // 검색된 친구 데이터가 있을 때 프로필 카드 및 버튼 표시
                                  return Container(
                                    height: _size.height - 310,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 40),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 280,
                                                height: 340,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/imgs/profile/img_friend_profileCard.png'), // 이미지 경로
                                                      fit: BoxFit.fill,
                                                    ),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                        style: BorderStyle.solid,
                                                        width: 4,
                                                        color: SDSColor.blue100
                                                    )
                                                ),
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 40),
                                                    Center(
                                                      child: (_friendListViewModel.searchFriend.profileImageUrlUser != '' &&
                                                          _friendListViewModel.searchFriend.profileImageUrlUser!.isNotEmpty)
                                                          ? Container(
                                                        width: 90,
                                                        height: 90,
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFFDFECFF),
                                                          borderRadius: BorderRadius.circular(50),
                                                        ),
                                                        child: ExtendedImage.network(
                                                          _friendListViewModel.searchFriend.profileImageUrlUser!,
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          cacheHeight: 150,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: 90,
                                                          height: 90,
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
                                                                    width: 90,
                                                                    height: 90,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                );
                                                              default:
                                                                return null;
                                                            }
                                                          },
                                                        ),
                                                      )
                                                          : Container(
                                                        width: 90,
                                                        height: 90,
                                                        child: ClipOval(
                                                          child: Image.asset(
                                                            'assets/imgs/profile/img_profile_default_circle.png',
                                                            width: 90,
                                                            height: 90,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(_friendListViewModel.searchFriend.displayName ?? '',
                                                      style: SDSTextStyle.bold.copyWith(
                                                          fontSize: 18,
                                                          color: SDSColor.gray900
                                                      ),),
                                                    Text(
                                                      _friendListViewModel.searchFriend.crewName ?? '개인',
                                                      style: SDSTextStyle.regular.copyWith(
                                                          color: SDSColor.gray900,
                                                          fontSize: 15
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Container(
                                                      width: 64,
                                                      height: 24,
                                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(40),
                                                        color: SDSColor.snowliveWhite,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _friendListViewModel.searchFriend.skiorboard ?? '미설정',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            color: SDSColor.gray900,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 50),
                                                      child: Image.asset(
                                                        'assets/imgs/logos/snowlive_logo_profile.png',
                                                        scale: 4,
                                                        width: 112,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              Container(
                                                width: 96,
                                                height: 36,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    textFocus.unfocus();
                                                    Get.toNamed(AppRoutes.friendDetail);
                                                    await _friendDetailViewModel.fetchFriendDetailInfo(
                                                      userId: _userViewModel.user.user_id,
                                                      friendUserId: _friendListViewModel.searchFriend.userId!,
                                                      season: _friendDetailViewModel.seasonDate,
                                                    );
                                                  },
                                                  child: Text(
                                                    '프로필 보기',
                                                    style: SDSTextStyle.bold.copyWith(
                                                        color: SDSColor.gray900, fontSize: 14),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    side:BorderSide(
                                                        color: SDSColor.gray200
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                                    ),
                                                    elevation: 0,
                                                    splashFactory: InkRipple.splashFactory,
                                                    minimumSize: Size(double.infinity, 48),
                                                    backgroundColor: SDSColor.snowliveWhite,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    (_friendListViewModel.searchFriend.userId != _userViewModel.user.user_id
                        && _friendListViewModel.searchFriend.userId != null
                    )
                        ? Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: SDSColor.snowliveWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            textFocus.unfocus();
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
                                          '친구등록 요청을 보내시겠습니까?',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 15,
                                              color: SDSColor.gray900),
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
                                                  onPressed: () async {
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
                                                    Navigator.pop(context);;
                                                    CustomFullScreenDialog.showDialog();
                                                    print(_userViewModel.user.user_id.toString());
                                                    print(_friendDetailViewModel.friendDetailModel.friendUserInfo.userId.toString());
                                                    await _friendDetailViewModel.sendFriendRequest({
                                                      "user_id": _userViewModel.user.user_id.toString(),    //필수 - 신청자 (나)
                                                      "friend_user_id": _friendListViewModel.searchFriend.userId.toString()    //필수 - 신청받는사람
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: Colors.transparent, // 배경색 투명
                                                    splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                  ),
                                                  child: Text('요청하기',
                                                    style: SDSTextStyle.bold.copyWith(
                                                      fontSize: 17,
                                                      color: SDSColor.snowliveBlue,
                                                    ),
                                                  )
                                              ),
                                            ),
                                          ),
                                        ],
                                        mainAxisAlignment: MainAxisAlignment.end,
                                      ),
                                    )
                                  ],
                                ));
                          },
                          child: Text(
                            '친구 요청하기',
                            style: SDSTextStyle.bold.copyWith(
                                color: SDSColor.snowliveWhite, fontSize: 16),
                          ),
                          style: TextButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                            ),
                            elevation: 0,
                            splashFactory: InkRipple.splashFactory,
                            minimumSize: Size(double.infinity, 48),
                            backgroundColor: SDSColor.snowliveBlue,
                          ),
                        ),
                      ),
                    )
                        : Container(),
                  ],
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
