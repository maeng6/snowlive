import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_alarmCenterList.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/crew/v_crewHome.dart';
import 'package:com.snowlive/view/crew/v_crewMember.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityBulletinList.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityCommentDetail.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_searchCrew.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_alarmCenter.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../util/util_1.dart';

class AlarmCenterView extends StatelessWidget {

  final SearchCrewViewModel _searchCrewViewModel = Get.find<SearchCrewViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final AlarmCenterViewModel _alarmCenterViewModel = Get.find<AlarmCenterViewModel>();
  final FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final FleamarketListViewModel _fleamarketListViewModel = Get.find<FleamarketListViewModel>();
  final FleamarketDetailViewModel _fleamarketDetailViewModel = Get.find<FleamarketDetailViewModel>();
  final CommunityBulletinListViewModel _communityBulletinListViewModel = Get.find<CommunityBulletinListViewModel>();
  final CommunityDetailViewModel _communityDetailViewModel = Get.find<CommunityDetailViewModel>();
  final CommunityCommentDetailViewModel _communityCommentDetailViewModel = Get.find<CommunityCommentDetailViewModel>();
  final FleamarketCommentDetailViewModel _fleamarketCommentDetailViewModel = Get.find<FleamarketCommentDetailViewModel>();



  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery
        .of(context)
        .size;
    final double _statusBarSize = MediaQuery
        .of(context)
        .padding
        .top;


    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
              actions: [],
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
                onTap: () async {
                  Get.back();
                },
              ),
              centerTitle: true,
              title: Text(
                '알림',
                style: SDSTextStyle.extraBold.copyWith(
                    color: SDSColor.gray900,
                    fontSize: 18),
              ),
              backgroundColor: SDSColor.snowliveWhite,
              foregroundColor: SDSColor.snowliveWhite,
              surfaceTintColor: SDSColor.snowliveWhite,
              elevation: 0.0,
            ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
              ],
            ),
            Expanded(
                  child:
                  (_alarmCenterViewModel.isLoading == true)
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
                      : RefreshIndicator(
                    strokeWidth: 2,
                    edgeOffset: 40,
                    backgroundColor: SDSColor.snowliveBlue,
                    color: SDSColor.snowliveWhite,
                    onRefresh: ()async{
                    await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                    },
                        child: SingleChildScrollView(
                          child: Obx(() =>
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 30),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: _size.width,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: _alarmCenterViewModel.alarmCenterList.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              AlarmCenterModel alarmDoc = _alarmCenterViewModel.alarmCenterList[index];
                                              String _time = TimeStamp().getAgo(alarmDoc.date);
                                              if (_alarmCenterViewModel.alarmCenterList.length != 0) {
                                                return InkWell(
                                                  highlightColor: Colors.transparent,
                                                  splashColor: Colors.transparent,
                                                  onTap: () async {
                                                    if(alarmDoc.alarmInfo.alarmInfoId == 1) {
                                                      CustomFullScreenDialog.showDialog();
                                                      await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
                                                      Get.toNamed(AppRoutes.invitaionFriend);
                                                      CustomFullScreenDialog.cancelDialog();
                                                      await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                                        "active": false
                                                      });
                                                      await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                                    }
                                                     else if(alarmDoc.alarmInfo.alarmInfoId == 2) {
                                                      Get.toNamed(AppRoutes.friendDetail);
                                                      await _friendDetailViewModel.fetchFriendDetailInfo(
                                                          userId: _userViewModel.user.user_id,
                                                          friendUserId: _userViewModel.user.user_id,
                                                          season: _friendDetailViewModel.seasonDate);
                                                      await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                                        "active": false
                                                      });
                                                      await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                                    }
                                                    else if(alarmDoc.alarmInfo.alarmInfoId == 3) {
                                                      if(alarmDoc.crewLeaderUserId == _userViewModel.user.user_id) {
                                                        Get.toNamed(AppRoutes.crewApplicationCrew);
                                                        await _friendDetailViewModel.fetchFriendDetailInfo(
                                                            userId: _userViewModel.user.user_id,
                                                            friendUserId: _userViewModel.user.user_id,
                                                            season: _friendDetailViewModel.seasonDate);
                                                      }else{
                                                        Get.dialog(
                                                          AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            contentPadding: EdgeInsets.all(20),
                                                            title: Center(
                                                              child: Column(
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/imgs/imgs/img_error_1.png',
                                                                    scale: 4,
                                                                    width: 100,
                                                                    height: 100,
                                                                  ),
                                                                  SizedBox(height: 20),
                                                                  Text(
                                                                    '권한이 없습니다.',
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.black87,
                                                                    ),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                                        "active": false
                                                      });
                                                      await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                                    }
                                                    else if(alarmDoc.alarmInfo.alarmInfoId == 4) {
                                                      CustomFullScreenDialog.showDialog();
                                                      await _fleamarketDetailViewModel.fetchFleamarketDetailFromAPI(fleamarketId: alarmDoc.pkCommentFleamarket!, userId: _userViewModel.user.user_id);
                                                      CustomFullScreenDialog.cancelDialog();
                                                      Get.toNamed(AppRoutes.fleamarketDetail);
                                                      await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                                        "active": false
                                                      });
                                                      await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                                    }
                                                    else if(alarmDoc.alarmInfo.alarmInfoId == 5) {
                                                      CustomFullScreenDialog.showDialog();
                                                      await _communityDetailViewModel.fetchCommunityDetail(alarmDoc.pkCommentFleamarket!, _userViewModel.user.user_id);
                                                      CustomFullScreenDialog.cancelDialog();
                                                      Get.toNamed(AppRoutes.bulletinDetail);
                                                      await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                                        "active": false
                                                      });
                                                      await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                                    }
                                                    else if(alarmDoc.alarmInfo.alarmInfoId == 6) {
                                                      if(alarmDoc.pkReplyCommunity != null){
                                                        CustomFullScreenDialog.showDialog();
                                                        await _communityCommentDetailViewModel.fetchCommunityCommentDetail(commentId: alarmDoc.pkReplyCommunity!);
                                                        Get.toNamed(AppRoutes.bulletinCommentDetail);
                                                        CustomFullScreenDialog.cancelDialog();
                                                      }else{
                                                        CustomFullScreenDialog.showDialog();
                                                        await _fleamarketCommentDetailViewModel.fetchFleamarketCommentDetail(commentId: alarmDoc.pkReplyFleamarket!);
                                                        Get.toNamed(AppRoutes.fleamarketCommentDetail);
                                                        CustomFullScreenDialog.cancelDialog();
                                                      }
                                                      await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                                        "active": false
                                                      });
                                                      await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                                    }
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                if(alarmDoc.alarmInfo.alarmInfoId == 1)
                                                                  Image.asset('assets/imgs/icons/icon_moretab_friends.png', width: 30),
                                                                if(alarmDoc.alarmInfo.alarmInfoId == 2)
                                                                  Image.asset('assets/imgs/icons/icon_moretab_bubble.png', width: 30),
                                                                if(alarmDoc.alarmInfo.alarmInfoId == 3)
                                                                  Image.asset('assets/imgs/icons/icon_moretab_team.png', width: 30),
                                                                if(alarmDoc.alarmInfo.alarmInfoId == 4)
                                                                  Image.asset('assets/imgs/icons/icon_moretab_team.png', width: 30),
                                                                if(alarmDoc.alarmInfo.alarmInfoId == 5)
                                                                  Image.asset('assets/imgs/icons/icon_moretab_comm.png', width: 30),
                                                                if(alarmDoc.alarmInfo.alarmInfoId == 6)
                                                                  Image.asset('assets/imgs/icons/icon_moretab_team.png', width: 30),
                                                                SizedBox(width: 10,),
                                                                Container(
                                                                  width: _size.width - 72,
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          Text(alarmDoc.alarmInfo.alarmInfoName,
                                                                            style: SDSTextStyle.bold.copyWith(
                                                                                fontSize: 14,
                                                                                color: SDSColor.gray900
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsets.only(left: 6),
                                                                            child: Text(_time,
                                                                              style: SDSTextStyle.regular.copyWith(
                                                                                  fontSize: 13,
                                                                                  color: SDSColor.gray500
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height: 2,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            alarmDoc.otherUserInfo.displayName,
                                                                            style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                                          ),
                                                                          Text(
                                                                            alarmDoc.alarmInfo.alarmText,
                                                                            style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              if(alarmDoc.textMain != '')
                                                                              Padding(
                                                                                padding: EdgeInsets.only(top: 2),
                                                                                child: Container(
                                                                                  width: _size.width - 72,
                                                                                  child: Text(alarmDoc.textMain,
                                                                                    style: SDSTextStyle.regular.copyWith(
                                                                                        fontSize: 14,
                                                                                        color: SDSColor.gray500
                                                                                    ),
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              if(alarmDoc.textSub != '')
                                                                                Container(
                                                                                  width: _size.width - 72,
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.only(top: 2),
                                                                                    child: Text(': ${alarmDoc.textSub}',
                                                                                      style: SDSTextStyle.regular.copyWith(
                                                                                          fontSize: 14,
                                                                                          color: SDSColor.gray900
                                                                                      ),
                                                                                      maxLines: 3,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          if (index != _alarmCenterViewModel.alarmCenterList.length - 1)
                                                            SizedBox(height: 32)
                                                        ],
                                                      ),
                                                      if(alarmDoc.active == false)
                                                      Positioned(
                                                        top: 0,
                                                        bottom:0,
                                                        left:0,
                                                        right:0,
                                                        child: Container(
                                                          color: Colors.white.withOpacity(0.7),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }
                                              else {
                                                return Container(
                                                  height: _size.height - 400,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Center(
                                                        child: Image.asset(
                                                          'assets/imgs/icons/icon_no_member.png',
                                                          width: 100,
                                                        ),
                                                      ),
                                                      SizedBox(height: 12),
                                                      Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                              .only(bottom: 50),
                                                          child: Text(
                                                            '새로운 알림이 없습니다',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Color(
                                                                    0xFF666666)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),)
                                            ),
                      ),
                ),
          ],
        ),
      ),
    );
  }
}