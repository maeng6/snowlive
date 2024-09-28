import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:extended_image/extended_image.dart';

class CrewApplicationCrewView extends StatelessWidget {

  final CrewApplyViewModel _crewApplyViewModel = Get.find<CrewApplyViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: SDSColor.snowliveWhite,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            backgroundColor: SDSColor.snowliveWhite,
            appBar: AppBar(
              backgroundColor: SDSColor.snowliveWhite,
              surfaceTintColor: Colors.transparent,
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
              title: Text(
                '가입 신청자 목록',
                style: TextStyle(
                    color: SDSColor.snowliveBlack,
                    fontSize: 18
                ),
              ),
              elevation: 0,
              toolbarHeight: 44,
            ),
            body: Obx(() {
              return Column(
                children: [
                  (_crewApplyViewModel.crewApplyList.isNotEmpty)
                  ? Expanded(
                    child: ListView(
                      children: _crewApplyViewModel.crewApplyList.map((user) {
                        // 유저 정보 가져오기
                        if (!_friendDetailViewModel.findFriendInfo.containsKey(user.applicantUserId)) {
                          _friendDetailViewModel.findFriendDetails(
                              _userViewModel.user.user_id,
                              user.applicantUserId!,
                              _friendDetailViewModel.seasonDate
                          );
                        }

                        var userInfo = _friendDetailViewModel.findFriendInfo[user.applicantUserId!] ?? {
                          'displayName': '',
                          'profileImageUrlUser': '',
                        };

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              // 프로필 이미지
                              if (userInfo['profileImageUrlUser']!.isNotEmpty)
                                GestureDetector(
                                  onTap: () async {
                                    CustomFullScreenDialog.showDialog();
                                    await _friendDetailViewModel.fetchFriendDetailInfo(
                                      userId: _userViewModel.user.user_id,
                                      friendUserId: user.applicantUserId!,
                                      season: _friendDetailViewModel.seasonDate,
                                    );
                                    CustomFullScreenDialog.cancelDialog();
                                    Get.toNamed(AppRoutes.friendDetail);
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: ExtendedImage.network(
                                      userInfo['profileImageUrlUser']!,
                                      enableMemoryCache: true,
                                      shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(10),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: () async {
                                    CustomFullScreenDialog.showDialog();
                                    await _friendDetailViewModel.fetchFriendDetailInfo(
                                      userId: _userViewModel.user.user_id,
                                      friendUserId: user.applicantUserId!,
                                      season: _friendDetailViewModel.seasonDate,
                                    );
                                    CustomFullScreenDialog.cancelDialog();
                                    Get.toNamed(AppRoutes.friendDetail);
                                  },
                                  child: ExtendedImage.asset(
                                    'assets/imgs/profile/img_profile_default_.png',
                                    shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(8),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              SizedBox(width: 12),
                              // 유저명 및 부가 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userInfo['displayName']!,
                                      style: SDSTextStyle.regular.copyWith(
                                        fontSize: 15,
                                        color: SDSColor.gray900
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              // 승인 버튼
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
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
                                                '가입 신청을 승인하시겠어요?',
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
                                                '가입 신청을 승인하시면 승인 즉시 가입됩니다.',
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
                                                        Navigator.of(context).pop(); // 팝업 닫기
                                                      },
                                                      child: Text('돌아가기',
                                                        style: TextStyle(
                                                          color: SDSColor.gray500,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.transparent, // 배경색 투명
                                                        splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                      ),
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
                                                        Navigator.of(context).pop();
                                                        CustomFullScreenDialog.showDialog();
                                                        await _crewApplyViewModel.approveCrewApplication(
                                                            user.applicantUserId!, user.crewId!
                                                        );
                                                        _crewApplyViewModel.crewApplyList.remove(user); // 개별 항목만 삭제
                                                        CustomFullScreenDialog.cancelDialog();
                                                      },
                                                      child: Text('수락하기',
                                                        style: TextStyle(
                                                          color: SDSColor.snowliveBlack,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.transparent, // 배경색 투명
                                                        splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                  minimumSize: Size(36, 32),
                                  backgroundColor: SDSColor.snowliveWhite,
                                  side: BorderSide(
                                      color: SDSColor.gray200
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                ),
                                child: Text('수락하기',
                                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),),
                              ),
                              SizedBox(width: 5),
                              // 거절 버튼
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
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
                                                '가입 신청을 거절하시겠어요?',
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
                                                '가입신청을 거절하시면 신청자의 목록에서도 삭제됩니다.',
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
                                                        Navigator.of(context).pop(); // 팝업 닫기
                                                      },
                                                      child: Text('돌아가기',
                                                        style: TextStyle(
                                                          color: SDSColor.gray500,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.transparent, // 배경색 투명
                                                        splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                      ),
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
                                                        CustomFullScreenDialog.showDialog();
                                                        await _crewApplyViewModel.deleteCrewApplication(
                                                          user.applicantUserId!,
                                                          user.crewId!,
                                                          _userViewModel.user.user_id,
                                                        );
                                                        _crewApplyViewModel.crewApplyList.remove(user); // 개별 항목만 삭제
                                                        CustomFullScreenDialog.cancelDialog();
                                                      },
                                                      child: Text('거절하기',
                                                        style: TextStyle(
                                                          color: SDSColor.snowliveBlack,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        backgroundColor: Colors.transparent, // 배경색 투명
                                                        splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                  minimumSize: Size(36, 32),
                                  backgroundColor: SDSColor.snowliveWhite,
                                  side: BorderSide(
                                      color: SDSColor.gray200
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                ),
                                child: Text('거절',
                                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                                ),
                              ),
                            ],
                          ),
                        );


                      }).toList(),
                    ),
                  )
                  : Expanded(
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 50),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              Text('가입 신청한 사람이 없어요',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 14,
                                    color: SDSColor.gray700
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

