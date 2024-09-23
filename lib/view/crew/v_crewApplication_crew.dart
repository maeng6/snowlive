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
            ),
            body: Obx(() {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _crewApplyViewModel.crewApplyList.length,
                      itemBuilder: (context, index) {
                        var user = _crewApplyViewModel.crewApplyList[index];

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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              // 크루 이미지
                              if (userInfo['profileImageUrlUser']!.isNotEmpty)
                                GestureDetector(
                                  onTap: () async{
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
                                    decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          spreadRadius: 0,
                                          blurRadius: 16,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
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
                                  onTap: () async{
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
                              SizedBox(width: 16),
                              // 크루명 및 부가 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userInfo['displayName']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        title: Text('가입 신청을 승인하시겠어요?',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16
                                            ),
                                            textAlign: TextAlign.center
                                        ),
                                        content: Text('가입 신청을 승인하시면\n승인 즉시 가입됩니다',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: SDSColor.gray600
                                            ),
                                            textAlign: TextAlign.center
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              CustomFullScreenDialog.showDialog();
                                              await _crewApplyViewModel.approveCrewApplication(
                                                  user.applicantUserId!, user.crewId!
                                              );
                                              await _crewApplyViewModel.fetchCrewApplyList(user.crewId!);
                                              CustomFullScreenDialog.cancelDialog();
                                            },
                                            child: Text('신청 승인하기',
                                              style: TextStyle(
                                                  color: SDSColor.snowliveWhite,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: SDSColor.snowliveBlue, // 신청 취소 버튼 색상
                                              minimumSize: Size(double.infinity, 48), // 버튼 크기
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // 팝업 닫기
                                            },
                                            child: Text('돌아가기',
                                              style: TextStyle(
                                                  color: SDSColor.snowliveBlack,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              elevation: 0,
                                              minimumSize: Size(double.infinity, 48), // 버튼 크기
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: SDSColor.gray300, // 테두리 색상 설정
                                      width: 1.0, // 테두리 두께 설정
                                    ),
                                  ),
                                  minimumSize: Size(41, 28),
                                ),
                                child: Text('승인',
                                    style: TextStyle(
                                      color: SDSColor.snowliveBlack,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                              SizedBox(width: 5),
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        title: Text('가입 신청을 거절하시겠어요?',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16
                                            ),
                                            textAlign: TextAlign.center
                                        ),
                                        content: Text('가입신청을 거절하시면\n신청자의 목록에서도 삭제됩니다.',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: SDSColor.gray600
                                            ),
                                            textAlign: TextAlign.center
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              CustomFullScreenDialog.showDialog();
                                              await _crewApplyViewModel.deleteCrewApplication(
                                                user.applicantUserId!,
                                                user.crewId!,
                                                _userViewModel.user.user_id,
                                              );
                                              await _crewApplyViewModel.fetchCrewApplyList(user.crewId!);
                                              Navigator.of(context).pop();
                                              CustomFullScreenDialog.cancelDialog();
                                            },
                                            child: Text('신청 거절하기',
                                              style: TextStyle(
                                                  color: SDSColor.snowliveWhite,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: SDSColor.snowliveBlue, // 신청 취소 버튼 색상
                                              minimumSize: Size(double.infinity, 48), // 버튼 크기
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // 팝업 닫기
                                            },
                                            child: Text('돌아가기',
                                              style: TextStyle(
                                                  color: SDSColor.snowliveBlack,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              elevation: 0,
                                              minimumSize: Size(double.infinity, 48), // 버튼 크기
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: SDSColor.gray300, // 테두리 색상 설정
                                      width: 1.0, // 테두리 두께 설정
                                    ),
                                  ),
                                  minimumSize: Size(41, 28),
                                ),
                                child: Text('거절',
                                    style: TextStyle(
                                      color: SDSColor.snowliveBlack,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
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
