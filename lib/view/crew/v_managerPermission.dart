import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManagerPermissionView extends StatelessWidget {
  final CrewDetailViewModel _crewDetailViewModel = Get.put(CrewDetailViewModel());

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
          '운영진 권한 설정',
          style: TextStyle(
              color: SDSColor.snowliveBlack,
              fontSize: 18
          ),
        ),
        elevation: 0,
      ),
      body: Obx(()=>Column(
        children: [
          // 크루 가입 신청 허가 권한
          _buildOnOffButton(
            context,
            "크루 가입 신청 승인 권한",
            "크루 가입 신청 승인 권한을 부여합니다.",
            _crewDetailViewModel.permission_join,
                (bool value) => _crewDetailViewModel.togglePermissionJoin(value),
          ),

          // 크루 소개글 변경 권한
          _buildOnOffButton(
            context,
            "크루 소개글 변경 권한",
            "크루 소개글 변경 권한을 부여합니다.",
            _crewDetailViewModel.permission_desc,
                (bool value) => _crewDetailViewModel.togglePermissionDesc(value),
          ),

          // 공지사항 추가 권한
          _buildOnOffButton(
            context,
            "공지사항 작성 권한",
            "크루 공지사항 작성 권한을 부여합니다.",
            _crewDetailViewModel.permission_notice,
                (bool value) => _crewDetailViewModel.togglePermissionNotice(value),
          ),
        ],
      ),)
    );
  }

// ON/OFF 버튼 UI 생성 함수 (텍스트 기반 + 라운드 배경)
  Widget _buildOnOffButton(
      BuildContext context,
      String title,
      String? subtitle,
      bool currentValue,
      Function(bool) onChanged,
      ) {
    return ListTile(
      title: Text(title,
      style: TextStyle(
        fontSize: 15
      ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)) : null,
      trailing: GestureDetector(
        onTap: () {
          onChanged(!currentValue); // ON/OFF 상태 변경
        },
        child: Container(
          width: 40,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: currentValue ? SDSColor.snowliveBlue.withOpacity(0.1) : SDSColor.gray700.withOpacity(0.1),  // 배경색 변경 (ON: 파란색, OFF: 회색)
            borderRadius: BorderRadius.circular(15),  // 둥근 모서리
          ),
          child: Text(
            currentValue ? "ON" : "OFF",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: currentValue ? SDSColor.snowliveBlue : SDSColor.snowliveBlack,
            ),
          ),
        ),
      ),
    );
  }

}
