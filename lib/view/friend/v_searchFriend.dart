import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../routes/routes.dart';
import '../../screens/snowliveDesignStyle.dart';
import '../../viewmodel/vm_friendDetail.dart';
import '../../viewmodel/vm_friendList.dart';

class SearchFriendView extends StatelessWidget {
  final f = NumberFormat('###,###,###,###');
  final FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

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
            appBar: AppBar(
              backgroundColor: Colors.white,
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
              elevation: 0.0,
              titleSpacing: 0,
              centerTitle: true,
              title: Text(
                '친구 검색',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Form(
                    key: _friendListViewModel.formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextFormField(
                        onFieldSubmitted: (val) async {
                          await _friendListViewModel.searchUser(
                              _friendListViewModel.textEditingController.text);
                          _friendListViewModel.textEditingController.clear();
                        },
                        autofocus: true,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Color(0xff949494),
                        cursorHeight: 18,
                        cursorWidth: 2,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _friendListViewModel.textEditingController,
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            prefixIcon: Icon(Icons.search, color: Color(0xFF666666)),
                            errorStyle: TextStyle(
                              fontSize: 12,
                            ),
                            labelStyle: TextStyle(
                                color: Color(0xff666666), fontSize: 15),
                            hintStyle: TextStyle(
                                color: Color(0xffb7b7b7), fontSize: 15),
                            hintText: '친구 검색',
                            labelText: '친구 검색',
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                            fillColor: Color(0xFFEFEFEF),
                            hoverColor: Colors.transparent,
                            filled: true,
                            focusColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(6),
                            )),
                        validator: (val) {
                          if (val!.length <= 20 && val.length >= 1) {
                            return null;
                          } else if (val.length == 0) {
                            return '검색어를 입력해주세요.';
                          } else {
                            return '최대 입력 가능한 글자 수를 초과했습니다.';
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 80),
                  Obx(() {
                    // 검색된 친구 데이터가 없을 때 처리
                    if (_friendListViewModel.searchFriend.userId == null) {
                      return Center(
                        child: Text(
                          '검색 결과가 없습니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    // 검색된 친구 데이터가 있을 때 프로필 카드 및 버튼 표시
                    return Column(
                      children: [
                        Container(
                          width: 280,
                          height: 375,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/imgs/profile/img_friend_profileCard.png'), // 이미지 경로
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 40),
                              Center(
                                child: (_friendListViewModel.searchFriend.profileImageUrlUser != null &&
                                    _friendListViewModel.searchFriend.profileImageUrlUser!.isNotEmpty)
                                    ? Container(
                                  width: 80,
                                  height: 80,
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
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    loadStateChanged: (ExtendedImageState state) {
                                      switch (state.extendedImageLoadState) {
                                        case LoadState.loading:
                                          return SizedBox.shrink();
                                        case LoadState.completed:
                                          return state.completedWidget;
                                        case LoadState.failed:
                                          return ExtendedImage.asset(
                                            'assets/imgs/profile/img_profile_default_circle.png',
                                            shape: BoxShape.circle,
                                            borderRadius: BorderRadius.circular(8),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          );
                                        default:
                                          return null;
                                      }
                                    },
                                  ),
                                )
                                    : Container(
                                  width: 80,
                                  height: 80,
                                  child: ExtendedImage.asset(
                                    'assets/imgs/profile/img_profile_default_circle.png',
                                    enableMemoryCache: true,
                                    shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(8),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(_friendListViewModel.searchFriend.displayName ?? ''),
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: SDSColor.snowliveWhite,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _friendListViewModel.searchFriend.crewName ?? '',
                                  style: TextStyle(
                                      color: SDSColor.snowliveBlack,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 40),
                              Column(
                                children: [
                                  Text(
                                    '주종목',
                                    style: TextStyle(
                                        color: SDSColor.snowliveBlack,
                                        fontSize: 11),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    _friendListViewModel.searchFriend.skiorboard ?? '',
                                    style: TextStyle(
                                      color: SDSColor.snowliveBlack,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(right: 16, left: 16),
                                child: ElevatedButton(
                                  onPressed: () async {
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
                                        color: SDSColor.snowliveBlack, fontSize: 16),
                                  ),
                                  style: TextButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(6)),
                                    ),
                                    elevation: 0,
                                    splashFactory: InkRipple.splashFactory,
                                    minimumSize: Size(double.infinity, 48),
                                    backgroundColor: SDSColor.snowliveWhite,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                        SizedBox(height: 80),
                        if(_friendListViewModel.searchFriend.userId != _userViewModel.user.user_id)
                        SafeArea(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () async {
                                await _friendDetailViewModel.sendFriendRequest({
                                  "user_id": _userViewModel.user.user_id,    //필수 - 신청자 (나)
                                  "friend_user_id": _friendListViewModel.searchFriend.userId!   //필수 - 신청받는사람
                                });
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
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
