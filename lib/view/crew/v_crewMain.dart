import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/crew/v_crewHome.dart';
import 'package:com.snowlive/view/crew/v_crewMember.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMain.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CrewMainView extends StatelessWidget {

  final CrewMainViewModel _crewMainViewModel = Get.find<CrewMainViewModel>();
  final MainHomeViewModel _mainHomeViewModel = Get.find<MainHomeViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;


    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: Obx(()=>Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              actions: [
                if(_crewMemberListViewModel.crewLeaderName == _userViewModel.user.display_name)
                Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: IconButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.crewSetting);
                    },
                    icon: Image.asset(
                      'assets/imgs/icons/icon_settings.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                    ),
                  ),
                )
              ],
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
                onTap: () async {
                  Get.until((route) => Get.currentRoute == AppRoutes.mainHome);
                  _mainHomeViewModel.changePage(4);
                },
              ),
              centerTitle: true,
              title: Text(
                '라이브크루',
                style: TextStyle(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ],
        ),)
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  _buildTabButton('홈', '홈'),
                  _buildTabButton('멤버', '멤버'),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                    () {
                  if (_crewMainViewModel.currentTab.value == '홈') {
                    return CrewHomeView();
                  } else {
                    return CrewMemberListView();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, String tabName) {
    return Expanded(
      child: Obx(() {
        bool isSelected = _crewMainViewModel.currentTab.value == tabName;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _crewMainViewModel.changeTab(tabName);
                },
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Color(0xFF111111) : Color(0xFFc8c8c8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(40, 40),
                  backgroundColor: Color(0xFFFFFFFF),
                  elevation: 0,
                ),
              ),
            ),
            Container(
              height: 3,
              color: isSelected ? Color(0xFF111111) : Colors.transparent,
            ),
          ],
        );
      }),
    );
  }
}
