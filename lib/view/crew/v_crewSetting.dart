import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_setCrew.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CrewSettingView extends StatelessWidget {

  final CrewApplyViewModel _crewApplyViewModel = Get.find<CrewApplyViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final SetCrewViewModel _setCrewViewModel = Get.find<SetCrewViewModel>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      appBar: AppBar(
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
            Get.back();
          },
        ),
        title: Text(
          '크루 설정',
          style: TextStyle(
              color: SDSColor.snowliveBlack,
              fontSize: 18
          ),
        ),
        elevation: 0,
        toolbarHeight: 44,
      ),
      body: Obx(()=> ListView(
        children: [
          // 일반 섹션
          if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장'
              || (_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '운영진'
                  && _crewDetailViewModel.permission_desc == true) ||
              (_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '운영진'
                  && _crewDetailViewModel.permission_notice == true) ||
              (_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '운영진'
                  && _crewDetailViewModel.permission_notice == true
                  && _crewDetailViewModel.permission_desc == true)
          )

            _buildSettingsSection('세팅', [
              if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장' ||
                  (_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '운영진' &&
                      _crewDetailViewModel.permission_desc == true))
                _buildSettingsItem('크루 소개글 작성/변경', onTap: () {
                  Get.toNamed(AppRoutes.crewDescription);
                }),
              if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장' ||
                  (_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '운영진' &&
                      _crewDetailViewModel.permission_notice == true))
                _buildSettingsItem('공지사항 작성', onTap: () {
                  Get.toNamed(AppRoutes.crewNoticeCreate);
                }),
              if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장')
                _buildSettingsItem('크루 이미지 및 컬러 설정', onTap: () async{
                  CustomFullScreenDialog.showDialog();
                  await _setCrewViewModel.setCrewLogoAsCroppedFile();
                  await _setCrewViewModel.initializeColor();
                   _setCrewViewModel.initializeCrewName();
                  CustomFullScreenDialog.cancelDialog();
                  Get.toNamed(AppRoutes.updateCrewImageAndColor);
                }),
            ]),
          SizedBox(height: 10),
          // 크루원 섹션
          if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장'
              || (_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '운영진'
                  && _crewDetailViewModel.permission_join == true)
          )
            _buildSettingsSection('크루원', [
              if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장' ||
                  (_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '운영진' &&
                      _crewDetailViewModel.permission_join== true))
                _buildSettingsItem('가입 신청 목록', onTap: () async{
                  Get.toNamed(AppRoutes.crewApplicationCrew);
                  await _crewApplyViewModel.fetchCrewApplyList(
                      _crewDetailViewModel.crewDetailInfo.crewId!
                  );
                }),
              if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장')
                _buildSettingsItem('크루원 관리', onTap: () {
                  Get.toNamed(AppRoutes.crewMemberSettings);
                }),
              if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장')
                _buildSettingsItem('운영진 권한 설정', onTap: () {
                  Get.toNamed(AppRoutes.managerPermission);
                }),
            ]),
          _buildSettingsSection('일반', [
            if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) != '크루장')
            _buildSettingsItem('크루 탈퇴', onTap: () async{
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
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
                            '정말 탈퇴하시겠어요?',
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
                                    Get.back(); // 팝업 닫기
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
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                              CustomFullScreenDialog.showDialog();
                              await _crewMemberListViewModel.withdrawCrew(
                                  crewMemberUserId: _userViewModel.user.user_id
                              );
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
            if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장')
            _buildSettingsItem('크루 삭제', onTap: () async{
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
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
                            '정말 탈퇴하시겠어요?',
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
                                    Get.back(); // 팝업 닫기
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
                                  onPressed: () async{
                                    Navigator.pop(context);
                                    CustomFullScreenDialog.showDialog();
                                    await _crewDetailViewModel.deleteCrew(
                                        _crewDetailViewModel.crewDetailInfo.crewId!,
                                        _userViewModel.user.user_id.toString()
                                    );
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
            }),
          ]),


        ],
      )),
    );
  }

  // 설정 섹션을 생성하는 함수
  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Text(title,
                style: SDSTextStyle.bold.copyWith(
                    fontSize: 13,
                    color: SDSColor.gray400
                )),
          ),
          ...items,
        ],
      ),
    );
  }

  // 각 설정 아이템을 생성하는 함수
  Widget _buildSettingsItem(String title, {required Function() onTap,}) {
    return ListTile(
      contentPadding: EdgeInsets.only(right: 12, left: 16),
      title: Text(title,
        style: SDSTextStyle.bold.copyWith(
            fontSize: 15,
            color: SDSColor.gray900),
      ),
      trailing: Image.asset(
        'assets/imgs/icons/icon_arrow_g.png',
        height: 24,
        width: 24,
      ),
      onTap: onTap,
    );
  }
}
