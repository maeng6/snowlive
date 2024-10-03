import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/crew/v_crewHome.dart';
import 'package:com.snowlive/view/crew/v_crewMember.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_searchCrew.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_alarmCenter.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CrewMainView extends StatelessWidget {

  final SearchCrewViewModel _searchCrewViewModel = Get.find<SearchCrewViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final AlarmCenterViewModel _alarmCenterViewModel = Get.find<AlarmCenterViewModel>();
  final CrewApplyViewModel _crewApplyViewModel = Get.find<CrewApplyViewModel>();

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
                width: 25,
                height: 25,
              ),
            )
                : Container(),
            if(_userViewModel.user.crew_id == _crewDetailViewModel.crewDetailInfo.crewId)
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
            if(_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장' ||
                (_crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '운영진' &&
                    _crewDetailViewModel.permission_join== true))
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notificationCenter')
                      .where('uid', isEqualTo:  _userViewModel.user.user_id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return IconButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.alarmCenter);
                        },
                        icon: Image.asset(
                          'assets/imgs/icons/icon_alarm_resortHome.png',
                            width: 26,
                            height: 26,
                        ),
                      );
                    }

                    var data = snapshot.data!.docs[0].data() as Map<String, dynamic>?;
                    bool isNewNotification = data?['crew'] ?? false; // Firestore 문서 필드

                    return Stack(
                      children: [
                        IconButton(
                          onPressed: () async{
                            Get.toNamed(AppRoutes.crewApplicationCrew);
                            await _alarmCenterViewModel.updateNotification(
                              _userViewModel.user.user_id,
                              crew: false,
                            );
                            await _crewApplyViewModel.fetchCrewApplyList(
                                _crewDetailViewModel.crewDetailInfo.crewId!
                            );
                          },
                          icon: Image.asset(
                            'assets/imgs/icons/icon_alarm_resortHome.png',
                            width: 26,
                            height: 26,
                          ),
                        ),
                        if (isNewNotification)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () async {
                                Get.toNamed(AppRoutes.crewApplicationCrew);
                                await _alarmCenterViewModel.updateNotification(
                                  _userViewModel.user.user_id,
                                  crew: false,
                                );
                                await _crewApplyViewModel.fetchCrewApplyList(
                                    _crewDetailViewModel.crewDetailInfo.crewId!
                                );
                                },
                              child: Container(
                                width: 20,
                                height: 20,
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Color(0xFFD6382B),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'N',
                                  style: SDSTextStyle.extraBold.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
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
            ' ',
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  backgroundColor: SDSColor.gray100,
                                  color: SDSColor.gray300.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
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
