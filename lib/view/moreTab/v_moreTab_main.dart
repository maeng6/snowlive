import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/view/banner/v_banner_moreTab.dart';
import 'package:com.snowlive/view/moreTab/v_noticeListPage.dart';
import 'package:com.snowlive/view/moreTab/v_resortTab.dart';
import 'package:com.snowlive/view/moreTab/v_snowliveDetailPage.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList_recordRoom.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/viewmodel/vm_eventAlarm.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/view/moreTab/v_setting_moreTab.dart';
import 'package:shimmer/shimmer.dart';

class MoreTabMainView extends StatelessWidget {
  MoreTabMainView({Key? key}) : super(key: key);

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final EventAlarmViewModel _eventAlarmViewModel = Get.find<EventAlarmViewModel>();
  final ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();

  @override
  Widget build(BuildContext context) {


    Size _size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '',
                style: SDSTextStyle.extraBold.copyWith(
                    color: SDSColor.gray900,
                    fontSize: 18),
              ),
            ),
          ),
        ),
        body: Obx(() {
          // 배너 visible 여부 확인
          // 데이터가 null이면 아직 로딩 중이므로 배너 영역 유지 (getBanner 호출 필요)
          // 데이터가 있고 visible이 모두 false일 때만 숨김
          final bannerData = _resortHomeViewModel.bannerData_moreTab.value;
          bool hasBanner = true; // 기본값 true (로딩 중일 때 영역 유지)
          if (bannerData != null) {
            List<dynamic> visibleList = bannerData['visible'] ?? [];
            hasBanner = visibleList.any((v) => v == true);
          }

          return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: hasBanner ? 60 : 0),
              child: Container(
                color: Colors.white,
                child: ListView(
                  children: [
                    SizedBox(
                      height: 24,
                    ),
                    Obx(() => GestureDetector(
                      onTap: () async{
                        Get.toNamed(AppRoutes.friendDetail);
                        await _friendDetailViewModel.fetchFriendDetailInfo(
                          userId: _userViewModel.user.user_id,
                          friendUserId: _userViewModel.user.user_id,
                          season: _friendDetailViewModel.seasonDate,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: SDSColor.gray50,
                          ),
                          width: _size.width - 32,
                          child: Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    (_userViewModel.user.profile_image_url_user != null && _userViewModel.user.profile_image_url_user != '')
                                        ? Container(
                                      width: 56,
                                      child: ExtendedImage.network(
                                        _userViewModel.user.profile_image_url_user ?? '',
                                        shape: BoxShape.circle,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        loadStateChanged: (ExtendedImageState state) {
                                          switch (state.extendedImageLoadState) {
                                            case LoadState.loading:
                                            // 로딩 중일 때 로딩 인디케이터를 표시
                                              return Shimmer.fromColors(
                                                baseColor: SDSColor.gray200!,
                                                highlightColor: SDSColor.gray50!,
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              );
                                            case LoadState.completed:
                                            // 로딩이 완료되었을 때 이미지 반환
                                              return state.completedWidget;
                                            case LoadState.failed:
                                            // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                              return ExtendedImage.network(
                                                '${profileImgUrlList[0].default_round}', // 대체 이미지 경로
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              );
                                          }
                                        },
                                      ),
                                    )
                                        : Container(
                                      width: 56,
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/imgs/profile/img_profile_default_circle_wht.png',
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Container(
                                        width: _size.width - 160,
                                        child: Column(
                                          mainAxisAlignment:  (_userViewModel.user.state_msg != null && _userViewModel.user.state_msg != '')
                                              ? MainAxisAlignment.center
                                              : MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _userViewModel.user.display_name ?? '',
                                              style: SDSTextStyle.bold.copyWith(
                                                color: SDSColor.gray900,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (_userViewModel.user.state_msg != null && _userViewModel.user.state_msg != '')
                                              Text(
                                                _userViewModel.user.state_msg ?? '',
                                                style: SDSTextStyle.regular.copyWith(
                                                  color: SDSColor.gray500,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    ),
                    SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '소셜',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 13,
                                color: SDSColor.gray900),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 52,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            onTap: () async {
                              Get.toNamed(AppRoutes.friendList);
                              await _friendListViewModel.fetchFriendList();
                              await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
                              await _friendListViewModel.fetchBlockUserList();
                            },
                            leading: Image.asset('assets/imgs/icons/icon_moretab_friends.png', width: 30,),
                            title: Transform.translate(
                              offset: Offset(-8, 0),
                              child: Text(
                                '친구',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 15,
                                    color: SDSColor.gray900),
                              ),
                            ),
                            trailing: Image.asset(
                              'assets/imgs/icons/icon_arrow_g.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                        Container(
                          height: 52,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            onTap: () async {
                              if(_userViewModel.user.crew_id == null){
                                CustomFullScreenDialog.showDialog();
                                await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
                                CustomFullScreenDialog.cancelDialog();
                                if(_userViewModel.user.crew_id != null){
                                  Get.toNamed(AppRoutes.crewMain);
                                  // 병렬 호출로 로딩 시간 단축
                                  await Future.wait([
                                    _crewMemberListViewModel.fetchCrewMembers(crewId: _userViewModel.user.crew_id),
                                    _crewDetailViewModel.fetchCrewDetail(
                                        _userViewModel.user.crew_id,
                                        _friendDetailViewModel.seasonDate
                                    ),
                                  ]);

                                } else if(_userViewModel.user.crew_id == null){
                                  Get.toNamed(AppRoutes.onBoardingCrewMain);
                                }
                              }
                              else{
                                Get.toNamed(AppRoutes.crewMain);
                                // 병렬 호출로 로딩 시간 단축
                                await Future.wait([
                                  _crewMemberListViewModel.fetchCrewMembers(crewId: _userViewModel.user.crew_id),
                                  _crewDetailViewModel.fetchCrewDetail(
                                      _userViewModel.user.crew_id,
                                      _friendDetailViewModel.seasonDate
                                  ),
                                ]);
                                print(RankingFilter_season.values.first.dbSeason);


                              }
                            },
                            leading: Image.asset('assets/imgs/icons/icon_moretab_team.png', width: 30),
                            title: Transform.translate(
                              offset: Offset(-8, 0),
                              child: Text(
                                '라이브크루',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 15,
                                    color: SDSColor.gray900),
                              ),
                            ),
                            trailing: Image.asset(
                              'assets/imgs/icons/icon_arrow_g.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '스키장',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 13,
                                color: SDSColor.gray900),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 52,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            onTap: () {
                              Get.to(ResortTab());
                            },
                            leading: Image.asset('assets/imgs/icons/icon_moretab_resort.png', width: 30,),
                            title: Transform.translate(
                              offset: Offset(-8, 0),
                              child: Text(
                                '스키장 모아보기',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 15,
                                    color: SDSColor.gray900),
                              ),
                            ),
                            trailing: Image.asset(
                              'assets/imgs/icons/icon_arrow_g.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 52,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            onTap: () {
                              Get.toNamed(AppRoutes.rankingGuideMain);
                            },
                            leading: Image.asset('assets/imgs/icons/icon_moretab_doc.png', width: 30,),
                            title: Transform.translate(
                              offset: Offset(-8, 0),
                              child: Text(
                                '랭킹 가이드',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 15,
                                    color: SDSColor.gray900),
                              ),
                            ),
                            trailing: Image.asset(
                              'assets/imgs/icons/icon_arrow_g.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '기타',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 13,
                                color: SDSColor.gray900),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 52,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            onTap: () {
                              otherShare(contents: 'http://pf.kakao.com/_LxnDdG/chat');
                            },
                            leading: Image.asset('assets/imgs/icons/icon_moretab_help.png', width: 30),
                            title: Transform.translate(
                              offset: Offset(-8, 0),
                              child: Text(
                                '1:1 고객 문의',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 15,
                                    color: SDSColor.gray900),
                              ),
                            ),
                            trailing: Image.asset(
                              'assets/imgs/icons/icon_arrow_g.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                        Container(
                          height: 52,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            onTap: () {
                              Get.to(() => SnowliveDetailPage());
                            },
                            leading: Image.asset('assets/imgs/icons/icon_moretab_snowlive.png', width: 30,),
                            title: Transform.translate(
                              offset: Offset(-8, 0),
                              child: Text(
                                '스노우라이브',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 15,
                                    color: SDSColor.gray900),
                              ),
                            ),
                            trailing: Image.asset(
                              'assets/imgs/icons/icon_arrow_g.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                        Container(
                          height: 52,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            onTap: () {
                              Get.toNamed(AppRoutes.setting_moreTab);
                            },
                            leading: Image.asset('assets/imgs/icons/icon_moretab_setting.png', width: 30),
                            title: Transform.translate(
                              offset: Offset(-8, 0),
                              child: Text(
                                '설정',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 15,
                                    color: SDSColor.gray900),
                              ),
                            ),
                            trailing: Image.asset(
                              'assets/imgs/icons/icon_arrow_g.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
            if (hasBanner)
              Positioned(
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: Banner_moreTab()),
            // 자동 라이브온 설정 안내 툴팁 오버레이
            Obx(() => _resortHomeViewModel.shouldShowAutoLiveOnTooltip
                ? GestureDetector(
                    onTap: () {
                      _resortHomeViewModel.markAutoLiveOnTooltipShown();
                      Get.toNamed(AppRoutes.setting_moreTab);
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      child: Stack(
                        children: [
                          // 설정 버튼 위치 근처에 툴팁 표시
                          Positioned(
                            bottom: 140,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: SDSColor.snowliveWhite,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: SDSColor.snowliveBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.asset(
                                          'assets/imgs/icons/icon_moretab_setting.png',
                                          width: 24,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '여기서 자동 라이브온 설정을 할 수 있어요',
                                              style: SDSTextStyle.bold.copyWith(
                                                fontSize: 15,
                                                color: SDSColor.gray900,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '설정 > 자동 라이브온에서 켜고 끌 수 있어요',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 13,
                                                color: SDSColor.gray500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _resortHomeViewModel.markAutoLiveOnTooltipShown();
                                        Get.toNamed(AppRoutes.setting_moreTab);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: SDSColor.snowliveBlue,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        '설정으로 이동',
                                        style: SDSTextStyle.bold.copyWith(
                                          fontSize: 15,
                                          color: SDSColor.snowliveWhite,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 아래쪽 화살표 표시
                          Positioned(
                            bottom: 130,
                            left: _size.width / 2 - 10,
                            child: CustomPaint(
                              size: Size(20, 10),
                              painter: _TrianglePainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink()),
          ],
        );
        }));
  }
}

/// 화살표 삼각형 페인터
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SDSColor.snowliveWhite
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
