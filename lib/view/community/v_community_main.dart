import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/view/banner/v_banner_community.dart';
import 'package:com.snowlive/view/community/free/v_community_Bulletin_Crew.dart';
import 'package:com.snowlive/view/community/free/v_community_Bulletin_Free.dart';
import 'package:com.snowlive/view/community/free/v_community_Bulletin_Total.dart';
import 'package:com.snowlive/view/community/free/v_community_Bulletin_Room.dart';
import 'package:com.snowlive/view/community/liveTalk/v_liveTalk_main.dart';
// [이벤트·소식 탭 비활성화] import 'package:com.snowlive/view/moreTab/w_eventPageEmbedded.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityBulletinList.dart';
// [이벤트·소식 탭 비활성화] import 'package:com.snowlive/viewmodel/vm_eventAlarm.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
// [이벤트·소식 탭 비활성화] import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CommunityMainView extends StatelessWidget {

  final CommunityBulletinListViewModel _communityBulletinListViewModel = Get.find<CommunityBulletinListViewModel>();
  // [이벤트·소식 탭 비활성화] final EventAlarmViewModel _eventAlarmViewModel = Get.find<EventAlarmViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: AppBar(
            elevation: 0.0,
            titleSpacing: 16,
            centerTitle: false,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            title: Text(
              '커뮤니티',
              style: SDSTextStyle.extraBold.copyWith(
                  color: SDSColor.gray900,
                  fontSize: 18),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        body:
        SafeArea(
          child: Obx(()=>Stack(
            children: [
              Positioned(
                top: 44,
                child: Container(
                  width: _size.width,
                  height: 1,
                  color: Color(0xFFECECEC),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 라이브톡 탭
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                width: (_size.width - 48) / 2,
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '라이브톡',
                                    style: SDSTextStyle.extraBold.copyWith(
                                        color: (_communityBulletinListViewModel.tapName=='라이브톡')
                                            ? SDSColor.gray900
                                            : SDSColor.gray900.withOpacity(0.2),
                                        fontWeight: (_communityBulletinListViewModel.tapName=='라이브톡')
                                            ? FontWeight.w900
                                            : FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    _communityBulletinListViewModel.changeTap('라이브톡');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: SDSColor.snowliveWhite,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    overlayColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 78,
                              height: 3,
                              color:
                              (_communityBulletinListViewModel.tapName=='라이브톡') ? Color(0xFF111111) : Colors.transparent,
                            )
                          ],
                        ),
                        // 게시판 탭
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                width: (_size.width - 48) / 2,
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '게시판',
                                    style: SDSTextStyle.extraBold.copyWith(
                                        color: (_communityBulletinListViewModel.tapName=='게시판')
                                            ? SDSColor.gray900
                                            : SDSColor.gray900.withOpacity(0.2),
                                        fontWeight: (_communityBulletinListViewModel.tapName=='게시판')
                                            ? FontWeight.w900
                                            : FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    _communityBulletinListViewModel.changeTap('게시판');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: SDSColor.snowliveWhite,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    overlayColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 78,
                              height: 3,
                              color:
                              (_communityBulletinListViewModel.tapName=='게시판') ? Color(0xFF111111) : Colors.transparent,
                            )
                          ],
                        ),
                        // [이벤트·소식 탭 비활성화] 아래 탭 버튼 전체 주석처리
                        // Column(
                        //   children: [
                        //     Padding(
                        //       padding: EdgeInsets.only(bottom: 2),
                        //       child: Row(
                        //         children: [
                        //           Container(
                        //             width: (_size.width - 48) / 3,
                        //             height: 40,
                        //             child: ElevatedButton(
                        //               child: Row(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 children: [
                        //                   Text(
                        //                     '이벤트·소식',
                        //                     style: SDSTextStyle.extraBold.copyWith(
                        //                       color: (_communityBulletinListViewModel.tapName == '이벤트·소식')
                        //                           ? SDSColor.gray900
                        //                           : SDSColor.gray900.withOpacity(0.2),
                        //                       fontWeight: (_communityBulletinListViewModel.tapName == '이벤트·소식')
                        //                           ? FontWeight.w900
                        //                           : FontWeight.w300,
                        //                       fontSize: 16,
                        //                     ),
                        //                   ),
                        //                   if (_eventAlarmViewModel.hasNewEvent.value)
                        //                     Padding(
                        //                       padding: EdgeInsets.only(left: 4),
                        //                       child: Container(
                        //                         width: 20,
                        //                         height: 20,
                        //                         decoration: BoxDecoration(
                        //                           color: Color(0xFFD6382B),
                        //                           borderRadius: BorderRadius.circular(20),
                        //                         ),
                        //                         child: Center(
                        //                           child: Text(
                        //                             'N',
                        //                             style: SDSTextStyle.extraBold.copyWith(
                        //                               fontSize: 11,
                        //                               fontWeight: FontWeight.bold,
                        //                               color: Color(0xFFFFFFFF),
                        //                             ),
                        //                           ),
                        //                         ),
                        //                       ),
                        //                     ),
                        //                 ],
                        //               ),
                        //               onPressed: () {
                        //                 HapticFeedback.lightImpact();
                        //                 _communityBulletinListViewModel.changeTap('이벤트·소식');
                        //                 // GA 이벤트 로깅
                        //                 FirebaseAnalytics.instance.logEvent(
                        //                   name: 'tap_community_event',
                        //                   parameters: <String, Object>{
                        //                     'user_id': _userViewModel.user.user_id ?? 0,
                        //                   },
                        //                 );
                        //                 // 뉴뱃지 확인 및 데이터 로드는 EventPageEmbeddedView에서 처리
                        //               },
                        //               style: ElevatedButton.styleFrom(
                        //                 splashFactory: NoSplash.splashFactory,
                        //                 padding: EdgeInsets.only(top: 0),
                        //                 minimumSize: Size(40, 10),
                        //                 backgroundColor: SDSColor.snowliveWhite,
                        //                 shape: RoundedRectangleBorder(
                        //                   borderRadius: BorderRadius.circular(8),
                        //                 ),
                        //                 elevation: 0,
                        //                 shadowColor: Colors.transparent,
                        //                 overlayColor: Colors.transparent,
                        //                 surfaceTintColor: Colors.transparent,
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     Container(
                        //       width: 104,
                        //       height: 3,
                        //       color: (_communityBulletinListViewModel.tapName == '이벤트·소식')
                        //           ? Color(0xFF111111)
                        //           : Colors.transparent,
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  if(_communityBulletinListViewModel.tapName=='게시판')
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: _communityBulletinListViewModel.showCategoryChips ? 1.0 : 0.0),
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return ClipRect(
                          child: Align(
                            alignment: Alignment.topLeft,
                            heightFactor: value,
                            child: Transform.translate(
                              offset: Offset(0, -68 * (1 - value)),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        height: 68,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16, left: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          HapticFeedback.lightImpact();
                                          _communityBulletinListViewModel.changeChip(Community_Category_sub_bulletin.total.korean);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 16),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.total.korean)
                                                    ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                                borderRadius: BorderRadius.circular(30.0),
                                                border: Border.all(
                                                    color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.total.korean)
                                                        ? SDSColor.gray900 : SDSColor.gray100),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              height: 36,
                                              child: Text('${Community_Category_sub_bulletin.total.korean}',
                                                style: SDSTextStyle.bold.copyWith(
                                                    fontSize: 13,
                                                    fontWeight: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.total.korean) ? FontWeight.bold : FontWeight.w300,
                                                    color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.total.korean) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                                ),)
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: (){
                                          HapticFeedback.lightImpact();
                                          _communityBulletinListViewModel.changeChip(Community_Category_sub_bulletin.chat.korean);
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.chat.korean) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                              borderRadius: BorderRadius.circular(30.0),
                                              border: Border.all(
                                                  color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.chat.korean) ? SDSColor.gray900 : SDSColor.gray100),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            height: 36,
                                            child: Text('${Community_Category_sub_bulletin.chat.korean}',
                                              style: SDSTextStyle.bold.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.chat.korean) ? FontWeight.bold : FontWeight.w300,
                                                  color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.chat.korean) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                              ),)
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: (){
                                          HapticFeedback.lightImpact();
                                          _communityBulletinListViewModel.changeChip(Community_Category_sub_bulletin.room.korean);
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.room.korean) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                              borderRadius: BorderRadius.circular(30.0),
                                              border: Border.all(
                                                  color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.room.korean) ? SDSColor.gray900 : SDSColor.gray100),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            height: 36,
                                            child: Text('${Community_Category_sub_bulletin.room.korean}',
                                              style: SDSTextStyle.bold.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.room.korean) ? FontWeight.bold : FontWeight.w300,
                                                  color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.room.korean) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                              ),)
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: (){
                                          HapticFeedback.lightImpact();
                                          _communityBulletinListViewModel.changeChip(Community_Category_sub_bulletin.crew.korean);
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.crew.korean) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                              borderRadius: BorderRadius.circular(30.0),
                                              border: Border.all(
                                                  color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.crew.korean) ? SDSColor.gray900 : SDSColor.gray100),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            height: 36,
                                            child: Text('${Community_Category_sub_bulletin.crew.korean}',
                                              style: SDSTextStyle.bold.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.crew.korean) ? FontWeight.bold : FontWeight.w300,
                                                  color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.crew.korean) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                              ),)
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if(_communityBulletinListViewModel.tapName=='게시판'
                      && _communityBulletinListViewModel.chipName == Community_Category_sub_bulletin.total.korean)
                    Banner_community(),
                  if(_communityBulletinListViewModel.tapName=='게시판'
                      && _communityBulletinListViewModel.chipName == Community_Category_sub_bulletin.total.korean)
                    Expanded(child: CommunityBulletinTotalListView()),
                  if(_communityBulletinListViewModel.tapName=='게시판'
                      && _communityBulletinListViewModel.chipName == Community_Category_sub_bulletin.chat.korean)
                    Banner_community(),
                  if(_communityBulletinListViewModel.tapName=='게시판'
                      && _communityBulletinListViewModel.chipName == Community_Category_sub_bulletin.chat.korean)
                    Expanded(child: CommunityBulletinFreeListView()),
                  if(_communityBulletinListViewModel.tapName=='게시판'
                      && _communityBulletinListViewModel.chipName == Community_Category_sub_bulletin.room.korean)
                    Banner_community(),
                  if(_communityBulletinListViewModel.tapName=='게시판'
                      && _communityBulletinListViewModel.chipName == Community_Category_sub_bulletin.room.korean)
                    Expanded(child: CommunityBulletinRoomListView()),
                  if(_communityBulletinListViewModel.tapName=='게시판'
                      && _communityBulletinListViewModel.chipName == Community_Category_sub_bulletin.crew.korean)
                    Banner_community(),
                  if(_communityBulletinListViewModel.tapName=='게시판'
                      && _communityBulletinListViewModel.chipName == Community_Category_sub_bulletin.crew.korean)
                    Expanded(child: CommunityBulletinCrewListView()),
                  // [이벤트·소식 탭 비활성화]
                  // if(_communityBulletinListViewModel.tapName=='이벤트·소식')
                  //   Expanded(child: EventPageEmbeddedView()),
                  if(_communityBulletinListViewModel.tapName=='라이브톡')
                    Expanded(child: LiveTalkMainView()),
                ],
              ),
            ],
          )),
        )


    );
  }
}


