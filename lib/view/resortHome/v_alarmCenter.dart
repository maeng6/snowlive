import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_alarmCenterList.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_searchCrew.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityBulletinList.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityCommentDetail.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityDetail.dart';
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
    final Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        elevation: 0.0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
          },
          child: Column(
            children: [
              Obx(() =>
                  Expanded(
                    child: ListView.builder(
                      controller: _alarmCenterViewModel.scrollController_alarm,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _alarmCenterViewModel.alarmCenterList.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (_alarmCenterViewModel.alarmCenterList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/imgs/icons/icon_nodata.png',
                                  scale: 4,
                                  width: 73,
                                  height: 73,
                                ),
                                SizedBox(height: 6),
                                Text('알림이 없습니다.',
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.gray600,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (index == _alarmCenterViewModel.alarmCenterList.length) {
                          return Obx(() => _alarmCenterViewModel.isLoadingNextList_alarm == true
                              ? Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 24),
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
                          )
                              : SizedBox.shrink());
                        }

                        AlarmCenterModel alarmDoc = _alarmCenterViewModel.alarmCenterList[index];
                        String _time = TimeStamp().getAgo(alarmDoc.date);

                        return Dismissible(
                          key: Key(alarmDoc.alarmCenterId.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            HapticFeedback.lightImpact();
                            CustomFullScreenDialog.showDialog();
                            await _alarmCenterViewModel.deleteAlarmCenter(alarmDoc.alarmCenterId);

                            // 알림 삭제 후 목록 업데이트
                            await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                          },
                          background: Container(
                            color: SDSColor.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          child: InkWell(
                            onTap: () async {
                              if(alarmDoc.alarmInfo.alarmInfoId == 1) {
                                CustomFullScreenDialog.showDialog();
                                await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
                                CustomFullScreenDialog.cancelDialog();
                                Get.toNamed(AppRoutes.invitaionFriend);
                                await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                  "active": false
                                });
                                await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                              }
                              else if(alarmDoc.alarmInfo.alarmInfoId == 2) {
                                try {
                                  Get.toNamed(AppRoutes.friendDetail);
                                  await _friendDetailViewModel.fetchFriendDetailInfo(
                                      userId: _userViewModel.user.user_id,
                                      friendUserId: _userViewModel.user.user_id,
                                      season: _friendDetailViewModel.seasonDate);
                                  await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                    "active": false
                                  });
                                  await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                } catch (e) {
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
                                              '탈퇴한 회원입니다.',
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
                                try {
                                  CustomFullScreenDialog.showDialog();
                                  await _fleamarketDetailViewModel.fetchFleamarketDetailFromAPI(fleamarketId: alarmDoc.pkFleamarket!, userId: _userViewModel.user.user_id);
                                  CustomFullScreenDialog.cancelDialog();
                                  Get.toNamed(AppRoutes.fleamarketDetail);
                                  await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                    "active": false
                                  });
                                  await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                } catch(e) {
                                  CustomFullScreenDialog.cancelDialog();
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
                                              '게시글이 없습니다.',
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
                                  await _alarmCenterViewModel.deleteAlarmCenter(alarmDoc.alarmCenterId);
                                  await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                }
                              }
                              else if(alarmDoc.alarmInfo.alarmInfoId == 5) {
                                try {
                                  CustomFullScreenDialog.showDialog();
                                  await _communityDetailViewModel.fetchCommunityDetail(alarmDoc.pkCommunity!, _userViewModel.user.user_id);
                                  CustomFullScreenDialog.cancelDialog();
                                  Get.toNamed(AppRoutes.bulletinDetail);
                                  await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                    "active": false
                                  });
                                  await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                } catch(e) {
                                  CustomFullScreenDialog.cancelDialog();
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
                                              '게시글이 없습니다.',
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
                                  await _alarmCenterViewModel.deleteAlarmCenter(alarmDoc.alarmCenterId);
                                  await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                }
                              }
                              else if(alarmDoc.alarmInfo.alarmInfoId == 6) {
                                try {
                                  if(alarmDoc.pkCommentCommunity != null) {
                                    CustomFullScreenDialog.showDialog();
                                    await _communityCommentDetailViewModel.fetchCommunityCommentDetail(commentId: alarmDoc.pkCommentCommunity!);
                                    CustomFullScreenDialog.cancelDialog();
                                    Get.toNamed(AppRoutes.bulletinCommentDetail);
                                  } else {
                                    CustomFullScreenDialog.showDialog();
                                    await _fleamarketCommentDetailViewModel.fetchFleamarketCommentDetail(commentId: alarmDoc.pkCommentFleamarket!);
                                    CustomFullScreenDialog.cancelDialog();
                                    Get.toNamed(AppRoutes.fleamarketCommentDetail);
                                  }
                                  await _alarmCenterViewModel.updateAlarmCenter(alarmDoc.alarmCenterId, {
                                    "active": false
                                  });
                                  await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                } catch(e) {
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
                                              '게시글이 없습니다.',
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
                                  await _alarmCenterViewModel.deleteAlarmCenter(alarmDoc.alarmCenterId);
                                  await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                }
                              }
                            },
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 1),
                                              child: Column(
                                                children: [
                                                  if(alarmDoc.alarmInfo.alarmInfoId == 1)
                                                    Image.asset('assets/imgs/icons/icon_moretab_friends.png', width: 26),
                                                  if(alarmDoc.alarmInfo.alarmInfoId == 2)
                                                    Image.asset('assets/imgs/icons/icon_moretab_bubble.png', width: 26),
                                                  if(alarmDoc.alarmInfo.alarmInfoId == 3)
                                                    Image.asset('assets/imgs/icons/icon_moretab_team.png', width: 26),
                                                  if(alarmDoc.alarmInfo.alarmInfoId == 4)
                                                    Image.asset('assets/imgs/icons/icon_moretab_flea.png', width: 26),
                                                  if(alarmDoc.alarmInfo.alarmInfoId == 5)
                                                    Image.asset('assets/imgs/icons/icon_moretab_comm.png', width: 26),
                                                  if(alarmDoc.alarmInfo.alarmInfoId == 6)
                                                    Image.asset('assets/imgs/icons/icon_moretab_reply.png', width: 26),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Container(
                                              width: _size.width - 112,
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
                                                  Container(
                                                    width: _size.width - 112,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          alarmDoc.otherUserInfo.displayName,
                                                          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray900),
                                                        ),
                                                        Text(
                                                          alarmDoc.alarmInfo.alarmText,
                                                          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray900),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          if(alarmDoc.textMain != '' && alarmDoc.textMain != null)
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 2),
                                                              child: Container(
                                                                width: _size.width - 112,
                                                                child: Text('${alarmDoc.textMain}',
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 14,
                                                                      color: SDSColor.gray500
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ),
                                                          if(alarmDoc.textSub != '' && alarmDoc.textSub != null)
                                                            Container(
                                                              width: _size.width - 112,
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
                                ),
                                if(alarmDoc.active == false)
                                  Positioned(
                                    top: 0,
                                    bottom:0,
                                    left:0,
                                    right:0,
                                    child: IgnorePointer(
                                      ignoring: true, // 이벤트를 무시하도록 설정
                                      child: Container(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                      padding: EdgeInsets.only(bottom: 80),
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
