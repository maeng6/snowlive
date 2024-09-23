import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/view/moreTab/v_noticeListPage.dart';
import 'package:com.snowlive/view/moreTab/v_resortTab.dart';
import 'package:com.snowlive/view/moreTab/v_snowliveDetailPage.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/view/moreTab/v_setting_moreTab.dart';

class MoreTabMainView extends StatelessWidget {
  MoreTabMainView({Key? key}) : super(key: key);

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();

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
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 23),
              ),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: ListView(
            children: [
              SizedBox(
                height: 24,
              ),
              Obx(() => GestureDetector(
                onTap: () async{
                  CustomFullScreenDialog.showDialog();
                  await _friendDetailViewModel.fetchFriendDetailInfo(
                    userId: _userViewModel.user.user_id,
                    friendUserId: _userViewModel.user.user_id,
                    season: _friendDetailViewModel.seasonDate,
                  );
                  CustomFullScreenDialog.cancelDialog();
                  Get.toNamed(AppRoutes.friendDetail);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Color(0xFFF1F1F3),
                    ),
                    width: _size.width - 32,
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              (_userViewModel.user.profile_image_url_user != '')
                                  ? Container(
                                width: 56,
                                child: ExtendedImage.network(
                                  _userViewModel.user.profile_image_url_user,
                                  shape: BoxShape.circle,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Container(
                                width: 56,
                                child: ExtendedImage.asset(
                                  'assets/imgs/profile/img_profile_default_circle.png',
                                  shape: BoxShape.circle,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Container(
                                  width: _size.width - 160,
                                  child: Column(
                                    mainAxisAlignment:  _userViewModel.user.state_msg != ''
                                        ? MainAxisAlignment.center
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userViewModel.user.display_name,
                                        style: TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (_userViewModel.user.state_msg != '' && _userViewModel.user.state_msg != null)
                                        Text(
                                          _userViewModel.user.state_msg,
                                          style: TextStyle(
                                            color: Color(0xFF949494),
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
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async{
                            Get.toNamed(AppRoutes.friendList);
                            await _friendListViewModel.fetchFriendList();
                            await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
                            await _friendListViewModel.fetchBlockUserList();
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/imgs/icons/icon_moretab_friends.png', width: 40,),
                              SizedBox(height: 6),
                              Text('친구',style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555555)
                              ),)
                            ],
                          ),
                        ),
                        SizedBox(height: 25,),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async{
                            if(_userViewModel.user.crew_id == null){
                              Get.toNamed(AppRoutes.onBoardingCrewMain);
                            }
                            else{
                              CustomFullScreenDialog.showDialog();
                              await _crewDetailViewModel.fetchCrewDetail(
                                  _userViewModel.user.crew_id,
                                  _friendDetailViewModel.seasonDate
                              );
                              await _crewMemberListViewModel.fetchCrewMembers(crewId: _userViewModel.user.crew_id);
                              CustomFullScreenDialog.cancelDialog();
                              Get.toNamed(AppRoutes.crewMain);

                            }
                          },
                          child: Column(
                            children: [
                              Image.asset('assets/imgs/icons/icon_moretab_team.png', width: 40),
                              SizedBox(height: 6),
                              Text('라이브크루',style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555555)
                              ),)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Container(height: 1,color: Color(0xFFECECEC),),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '스키장',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D83ED)),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(ResortTab());
                },
                title: Text(
                  '스키장 모아보기',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '고객센터',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D83ED)),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  otherShare(contents: 'http://pf.kakao.com/_LxnDdG/chat');
                },
                title: Stack(
                  children: [
                    Text(
                      '1:1 고객 문의',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF111111)),
                    ),
                  ],
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '설정',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D83ED)),
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => SnowliveDetailPage());
                },
                title: Text(
                  'SNOWLIVE',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  Get.to(() => setting_moreTab());
                },
                title: Text(
                  '설정',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF111111)),
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),
              SizedBox(height: 36),
            ],
          ),
        ));
  }
}
