import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/crew/v_crewHome.dart';
import 'package:com.snowlive/view/crew/v_crewMember.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_searchCrew.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CrewMainView extends StatelessWidget {

  final SearchCrewViewModel _searchCrewViewModel = Get.find<SearchCrewViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;


    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: Obx(() => AppBar(
          actions: [
            (_userViewModel.user.crew_id != null && _userViewModel.user.crew_id == _crewDetailViewModel.crewDetailInfo.crewId)
            ? IconButton(
              onPressed: () {
                _searchCrewViewModel.textEditingController.clear();
                _searchCrewViewModel.crewList.clear();
                _searchCrewViewModel.showRecentSearch.value = true;
                Get.toNamed(AppRoutes.searchCrew);
              },
              icon: Image.asset(
                'assets/imgs/icons/icon_appBar_search.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
            )
            : Container(),
            if(_userViewModel.user.crew_id == _crewDetailViewModel.crewDetailInfo.crewId)
              Padding(
                padding: EdgeInsets.only(right: 5),
                child:
                (_crewDetailViewModel.isLoading == true)
                    ? SizedBox.shrink()
                    : IconButton(
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
              _crewDetailViewModel.changeTab('홈');
              Get.back();
            },
          ),
          centerTitle: true,
          title: Text(
            '라이브크루',
            style: SDSTextStyle.extraBold.copyWith(
                color: SDSColor.gray900,
                fontSize: 18),
          ),
          backgroundColor: SDSColor.snowliveWhite,
          foregroundColor: SDSColor.snowliveWhite,
          surfaceTintColor: SDSColor.snowliveWhite,
          elevation: 0.0,
        )),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: _size.width,
                    height: 1,
                    color: SDSColor.gray100,
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      children: [
                        _buildTabButton('홈', '홈'),
                        _buildTabButton('멤버', '멤버'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
           Obx(()=> Expanded(
              child:
              (_crewDetailViewModel.isLoading == true)
                  ? Center(
                child: Container(
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: SDSColor.snowliveWhite,
                          color: SDSColor.snowliveBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  :
              Obx(
                    () {
                  if (_crewDetailViewModel.currentTab.value == '홈') {
                    return CrewHomeView();
                  } else {
                    return CrewMemberListView();
                  }
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, String tabName) {
    return Expanded(
      child: Obx(() {
        bool isSelected = _crewDetailViewModel.currentTab.value == tabName;
        return Column(
          children: [
            Container(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _crewDetailViewModel.changeTab(tabName);
                },
                child: Text(
                  title,
                  style: SDSTextStyle.bold.copyWith(
                    color: isSelected ? SDSColor.gray900 : SDSColor.gray400,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(40, 40),
                  backgroundColor: SDSColor.snowliveWhite,
                  surfaceTintColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
            Container(
              height: 3,
              width: 72,
              color: isSelected ? Color(0xFF111111) : Colors.transparent,
            ),
          ],
        );
      }),
    );
  }
}
