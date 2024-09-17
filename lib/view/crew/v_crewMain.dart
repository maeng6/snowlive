import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/crew/v_crewHome.dart';
import 'package:com.snowlive/view/crew/v_crewMember.dart';
import 'package:com.snowlive/viewmodel/vm_crewMain.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_home.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_member.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_gallery.dart';
import '../../controller/user/vm_userModelController.dart';
import '../../controller/liveCrew/vm_liveCrewModelController.dart';
import '../../controller/liveCrew/vm_streamController_liveCrew.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';

class CrewMainView extends StatelessWidget {

  final CrewMainViewModel _crewMainViewModel = Get.find<CrewMainViewModel>();
  final MainHomeViewModel _mainHomeViewModel = Get.find<MainHomeViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    //TODO: Dependency Injection
    final UserModelController _userModelController = Get.find<UserModelController>();
    final LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
    final StreamController_liveCrew _streamController_liveCrew = Get.find<StreamController_liveCrew>();

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: IconButton(
                    onPressed: () {

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
        ),
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
                  _buildTabButton('갤러리', '갤러리'),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                    () {
                  if (_crewMainViewModel.currentTab.value == '홈') {
                    return CrewHomeView();
                  } else if (_crewMainViewModel.currentTab.value == '멤버') {
                    return CrewMemberListView();
                  } else {
                    return CrewHomeView();
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
