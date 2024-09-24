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
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(44),
              child: AppBar(
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
                  style: SDSTextStyle.extraBold.copyWith(
                      color: SDSColor.gray900,
                      fontSize: 18),
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                      onFieldSubmitted: (val) async {
                                        await _friendListViewModel.searchUser(
                                            _friendListViewModel.textEditingController.text);
                                        _friendListViewModel.textEditingController.clear();
                                      },
                                      autofocus: true,
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
                          SizedBox(height: 80),
                          Obx(() {
                            // 검색된 친구 데이터가 없을 때 처리
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
                                          _friendListViewModel.searchFriend.crewName ?? '개인',
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
                                            _friendListViewModel.searchFriend.skiorboard ?? '미설정',
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
                                            CustomFullScreenDialog.showDialog();
                                            await _friendDetailViewModel.fetchFriendDetailInfo(
                                              userId: _userViewModel.user.user_id,
                                              friendUserId: _friendListViewModel.searchFriend.userId!,
                                              season: _friendDetailViewModel.seasonDate,
                                            );
                                            CustomFullScreenDialog.cancelDialog();
                                            Get.toNamed(AppRoutes.friendDetail);
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
                                                              child: Text('취소',
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color(0xFF949494),
                                                                  fontWeight: FontWeight.bold,
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
                                                                CustomFullScreenDialog.showDialog();
                                                                await _friendDetailViewModel.sendFriendRequest({
                                                                  "user_id": _userViewModel.user.user_id,    //필수 - 신청자 (나)
                                                                  "friend_user_id": _friendDetailViewModel.friendDetailModel.friendUserInfo.userId    //필수 - 신청받는사람
                                                                });
                                                                CustomFullScreenDialog.cancelDialog();
                                                              },
                                                              child: Text('보내기',
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color(0xFF3D83ED),
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              )),
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
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
