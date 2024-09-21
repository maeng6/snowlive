import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CrewSettingView extends StatelessWidget {

  final CrewApplyViewModel _crewApplyViewModel = Get.find<CrewApplyViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          '크루 설정',
          style: TextStyle(
              color: SDSColor.snowliveBlack,
              fontSize: 18
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 일반 섹션
          _buildSettingsSection('일반', [
            _buildSettingsItem('크루 소개글 작성/변경', onTap: () {
              Get.toNamed(AppRoutes.crewDescription);
            }),
            _buildSettingsItem('공지사항 작성', onTap: () {
              Get.toNamed(AppRoutes.crewNoticeCreate);
            }),
            _buildSettingsItem('크루 이미지 및 컬러 설정', onTap: () {
              Get.toNamed(AppRoutes.updateCrewImageAndColor);
            }),
          ]),
          SizedBox(height: 10),
          // 크루원 섹션
          _buildSettingsSection('크루원', [
            _buildSettingsItem('가입 신청 목록', onTap: () async{
              Get.toNamed(AppRoutes.crewApplicationCrew);
              await _crewApplyViewModel.fetchCrewApplyList(
                  _crewDetailViewModel.crewDetailInfo.crewId!
              );
            }),
            _buildSettingsItem('크루원 관리', onTap: () {
              Get.toNamed(AppRoutes.crewMemberSettings);
            }),
            _buildSettingsItem('운영진 권한 설정', onTap: () {
            }),
            _buildSettingsItem('크루장 위임', onTap: () {
            }),
          ]),
        ],
      ),
    );
  }

  // 설정 섹션을 생성하는 함수
  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  color: SDSColor.gray500
                )),
          ),
          ...items,
        ],
      ),
    );
  }

  // 각 설정 아이템을 생성하는 함수
  Widget _buildSettingsItem(String title, {required Function() onTap, bool isNew = false}) {
    return ListTile(
      title: Text(title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: SDSColor.snowliveBlack
      ),
      ),
      trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: SDSColor.gray500,
      ),
      onTap: onTap,
    );
  }
}
