import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../routes/routes.dart';
import '../screens/snowliveDesignStyle.dart';
import '../util/util_1.dart';
import '../viewmodel/vm_friendSearch.dart';
import '../viewmodel/vm_user.dart';

class SearchFriendView extends StatelessWidget {

  final f = NumberFormat('###,###,###,###');

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FriendSearchViewModel _friendSearchViewModel = Get.find<FriendSearchViewModel>();

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;
    var friendUserInfo = _friendSearchViewModel.friendDetailModel.friendUserInfo;

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
              title: Text('친구 검색',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _friendSearchViewModel.formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextFormField(
                        onFieldSubmitted: (val) async {

                        },
                        autofocus: true,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Color(0xff949494),
                        cursorHeight: 18,
                        cursorWidth: 2,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _friendSearchViewModel.textEditingController,
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            prefixIcon: Icon(Icons.search, color: Color(0xFF666666)),
                            errorStyle: TextStyle(
                              fontSize: 12,
                            ),
                            labelStyle: TextStyle(color: Color(0xff666666), fontSize: 15),
                            hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
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
                ),
                SizedBox(height: 20),
                Column(
            children: [
              Container(
                width: 300,
                height: 500,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/imgs/profile/img_friend_profileCard.png'), // 이미지 경로
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Center(
                      child: (friendUserInfo.profileImageUrlUser != null)
                          ? Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xFFDFECFF),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ExtendedImage.network(
                              friendUserInfo.profileImageUrlUser,
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
                                    ); // 예시로 에러 아이콘을 반환하고 있습니다.
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
                    Container(
                      width: MediaQuery.of(context).size.width - 260,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            friendUserInfo.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: SDSColor.snowliveWhite,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: SDSColor.snowliveWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ALLDOMAN',
                        style: TextStyle(
                          color: SDSColor.snowliveBlack,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '주종목',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '해머라이딩',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '가입일',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '24.12.02',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SDSColor.snowliveWhite,
                          textStyle: SDSTextStyle.bold.copyWith(
                              fontSize: 15,
                              color: SDSColor.gray900
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () {
                        },
                        child: Text(
                          '프로필 보기',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
