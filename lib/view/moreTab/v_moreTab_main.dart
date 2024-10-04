import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/view/moreTab/v_noticeListPage.dart';
import 'package:com.snowlive/view/moreTab/v_resortTab.dart';
import 'package:com.snowlive/view/moreTab/v_snowliveDetailPage.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
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
  final CrewRecordRoomViewModel _crewRecordRoomViewModel = Get.find<CrewRecordRoomViewModel>();

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
        body: Container(
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
                                    mainAxisAlignment:  _userViewModel.user.state_msg != ''
                                        ? MainAxisAlignment.center
                                        : MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userViewModel.user.display_name,
                                        style: SDSTextStyle.bold.copyWith(
                                          color: SDSColor.gray900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (_userViewModel.user.state_msg != '' && _userViewModel.user.state_msg != null)
                                        Text(
                                          _userViewModel.user.state_msg,
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
                            await _crewMemberListViewModel.fetchCrewMembers(crewId: _userViewModel.user.crew_id);
                            await _crewDetailViewModel.fetchCrewDetail(
                                _userViewModel.user.crew_id,
                                _friendDetailViewModel.seasonDate
                            );
                            await _crewRecordRoomViewModel.fetchCrewRidingRecords(
                                _userViewModel.user.crew_id,
                                '${DateTime.now().year}'
                            );
                          } else if(_userViewModel.user.crew_id == null){
                            Get.toNamed(AppRoutes.onBoardingCrewMain);
                          }
                        }
                        else{
                          Get.toNamed(AppRoutes.crewMain);
                          await _crewMemberListViewModel.fetchCrewMembers(crewId: _userViewModel.user.crew_id);
                          await _crewDetailViewModel.fetchCrewDetail(
                              _userViewModel.user.crew_id,
                              _friendDetailViewModel.seasonDate
                          );
                          await _crewRecordRoomViewModel.fetchCrewRidingRecords(
                              _userViewModel.user.crew_id,
                              '${DateTime.now().year}'
                          );


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
                  SizedBox(height: 40),




                  // Container(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Container(
                  //         width: 72,
                  //         child: Column(
                  //           children: [
                  //             GestureDetector(
                  //               onTap: () async{
                  //                 Get.toNamed(AppRoutes.friendList);
                  //                 await _friendListViewModel.fetchFriendList();
                  //                 await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
                  //                 await _friendListViewModel.fetchBlockUserList();
                  //               },
                  //               child: Column(
                  //                 children: [
                  //                   Image.asset('assets/imgs/icons/icon_moretab_friends.png', width: 40,),
                  //                   SizedBox(height: 6),
                  //                   Text('친구',
                  //                     style: SDSTextStyle.regular.copyWith(
                  //                         fontSize: 13,
                  //                         color: SDSColor.gray700,
                  //                         height: 1.2
                  //                     ),)
                  //                 ],
                  //               ),
                  //             ),
                  //             SizedBox(height: 25,),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         width: 72,
                  //         child: Column(
                  //           children: [
                  //             GestureDetector(
                  //               onTap: () async{
                  //                 if(_userViewModel.user.crew_id == null){
                  //                   Get.toNamed(AppRoutes.onBoardingCrewMain);
                  //                 }
                  //                 else{
                  //                   Get.toNamed(AppRoutes.crewMain);
                  //                   await _crewDetailViewModel.fetchCrewDetail(
                  //                       _userViewModel.user.crew_id,
                  //                       _friendDetailViewModel.seasonDate
                  //                   );
                  //                   await _crewMemberListViewModel.fetchCrewMembers(crewId: _userViewModel.user.crew_id);
                  //                   if(_userViewModel.user.crew_id == _userViewModel.user.crew_id)
                  //                     await _crewRecordRoomViewModel.fetchCrewRidingRecords(
                  //                         _userViewModel.user.crew_id,
                  //                         '${DateTime.now().year}'
                  //                     );
                  //
                  //
                  //                 }
                  //               },
                  //               child: Column(
                  //                 children: [
                  //                   Image.asset('assets/imgs/icons/icon_moretab_team.png', width: 40),
                  //                   SizedBox(height: 6),
                  //                   Text('라이브크루',
                  //                     style: SDSTextStyle.regular.copyWith(
                  //                         fontSize: 13,
                  //                         color: SDSColor.gray700,
                  //                         height: 1.2
                  //                     ),)
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         width: 72,
                  //         child: Column(
                  //           children: [
                  //             GestureDetector(
                  //               onTap: () async{
                  //                 Get.to(ResortTab());
                  //               },
                  //               child: Column(
                  //                 children: [
                  //                   Image.asset('assets/imgs/icons/icon_moretab_resort.png', width: 40,),
                  //                   SizedBox(height: 6),
                  //                   Text('스키장\n모아보기',
                  //                     style: SDSTextStyle.regular.copyWith(
                  //                         fontSize: 13,
                  //                         color: SDSColor.gray700,
                  //                         height: 1.2
                  //                     ),
                  //                     textAlign: TextAlign.center,)
                  //                 ],
                  //               ),
                  //             ),
                  //             SizedBox(height: 25,),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         width: 72,
                  //         child: Column(
                  //           children: [
                  //             GestureDetector(
                  //               onTap: () async{
                  //                 otherShare(contents: 'http://pf.kakao.com/_LxnDdG/chat');
                  //               },
                  //               child: Column(
                  //                 children: [
                  //                   Image.asset('assets/imgs/icons/icon_moretab_help.png', width: 40),
                  //                   SizedBox(height: 6),
                  //                   Text('고객 문의',
                  //                     style: SDSTextStyle.regular.copyWith(
                  //                         fontSize: 13,
                  //                         color: SDSColor.gray700,
                  //                         height: 1.2
                  //                     ),)
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Container(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Container(
                  //         width: 72,
                  //         child: Column(
                  //           children: [
                  //             GestureDetector(
                  //               onTap: () async{
                  //                 Get.to(() => SnowliveDetailPage());
                  //               },
                  //               child: Column(
                  //                 children: [
                  //                   Image.asset('assets/imgs/icons/icon_moretab_snowlive.png', width: 40,),
                  //                   SizedBox(height: 6),
                  //                   Text('스노우라이브',
                  //                     style: SDSTextStyle.regular.copyWith(
                  //                         fontSize: 13,
                  //                         color: SDSColor.gray700,
                  //                         height: 1.2
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //             SizedBox(height: 25,),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         width: 72,
                  //         child: Column(
                  //           children: [
                  //             GestureDetector(
                  //               onTap: () {
                  //                 Get.toNamed(AppRoutes.setting_moreTab);
                  //               },
                  //               child: Column(
                  //                 children: [
                  //                   Image.asset('assets/imgs/icons/icon_moretab_setting.png', width: 40),
                  //                   SizedBox(height: 6),
                  //                   Text('설정',
                  //                     style: SDSTextStyle.regular.copyWith(
                  //                         fontSize: 13,
                  //                         color: SDSColor.gray700,
                  //                         height: 1.2
                  //                     ),)
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         width: 72,
                  //       ),
                  //       Container(
                  //         width: 72,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ));
  }
}
