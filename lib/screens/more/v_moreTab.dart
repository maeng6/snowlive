import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/public/vm_loadingController.dart';
import 'package:com.snowlive/controller/ranking/vm_myCrewRankingController.dart';
import 'package:com.snowlive/controller/public/vm_urlLauncherController.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:com.snowlive/screens/more/friend/v_snowliveDetailPage.dart';
import 'package:com.snowlive/screens/more/v_eventPage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/screens/more/friend/v_friendDetailPage.dart';
import 'package:com.snowlive/screens/more/v_favoriteResort_moreTab.dart';
import 'package:com.snowlive/screens/more/friend/v_friendListPage.dart';
import 'package:com.snowlive/screens/more/v_noticeListPage.dart';
import 'package:com.snowlive/screens/more/v_resortTab.dart';
import 'package:com.snowlive/screens/more/v_setting_moreTab.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../controller/liveCrew/vm_liveCrewModelController.dart';
import '../../controller/ranking/vm_myRankingController.dart';
import '../../controller/alarm/vm_noticeController.dart';
import '../../controller/ranking/vm_rankingTierModelController.dart';
import '../../controller/user/vm_userModelController.dart';
import '../LiveCrew/CreateOnboarding/v_FirstPage_createCrew.dart';

class MoreTab extends StatefulWidget {
  MoreTab({Key? key}) : super(key: key);

  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  TextEditingController _textEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  MyRankingController _myRankingController = Get.find<MyRankingController>();
  LoadingController _loadingController = Get.find<LoadingController>();
  MyCrewRankingController _myCrewRankingController = Get.find<MyCrewRankingController>();
  //TODO: Dependency Injection**************************************************

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'visit_moreTab',
        parameters: <String, Object>{
          'user_id': _userModelController.uid!,
          'user_name': _userModelController.displayName!,
          'user_resort': _userModelController.favoriteResort!
        },
      );
    } catch (e, stackTrace) {
      print('GA 업데이트 오류: $e');
      print('Stack trace: $stackTrace');
    }
  }


  @override
  Widget build(BuildContext context) {

    //TODO: Dependency Injection************************************************
    Get.put(NoticeController(), permanent: true);
    NoticeController _noticeController = Get.find<NoticeController>();
    //TODO: Dependency Injection************************************************

    _noticeController.getIsNewNotice();

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
              Obx(
                    () => GestureDetector(
                  onTap: (){
                    (_userModelController.displayName == 'SNOWLIVE')
                        ? Get.to(()=>SnowliveDetailPage())
                        : Get.to(()=>FriendDetailPage(uid: _userModelController.uid, favoriteResort: _userModelController.favoriteResort));
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
                            Column(
                              children: [
                                (_userModelController.profileImageUrl!.isNotEmpty)
                                    ? Stack(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      child: Container(
                                          width: _size.width/5,
                                          height: _size.width/5,
                                          child: ExtendedImage.network(
                                            '${_userModelController.profileImageUrl}',
                                            enableMemoryCache: true,
                                            shape: BoxShape.circle,
                                            borderRadius: BorderRadius.circular(8),
                                            width: _size.width/5,
                                            height: _size.width/5,
                                            fit: BoxFit.cover,
                                            loadStateChanged: (ExtendedImageState state) {
                                              switch (state.extendedImageLoadState) {
                                                case LoadState.loading:
                                                  return SizedBox.shrink();
                                                case LoadState.completed:
                                                  return state.completedWidget;
                                                case LoadState.failed:
                                                  return Container(
                                                    width: 52,
                                                    height: 52,
                                                    child: Container(
                                                      width: 120,
                                                      height: 120,
                                                      child: ExtendedImage.asset(
                                                        'assets/imgs/profile/img_profile_default_circle.png',
                                                        enableMemoryCache: true,
                                                        shape: BoxShape.circle,
                                                        borderRadius: BorderRadius.circular(8),
                                                        width: 120,
                                                        height: 120,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  );// 예시로 에러 아이콘을 반환하고 있습니다.
                                                default:
                                                  return null;
                                              }
                                            },
                                          )),
                                    ),
                                  ],
                                )
                                    : Stack(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        child: ExtendedImage.asset(
                                          'assets/imgs/profile/img_profile_default_circle.png',
                                          enableMemoryCache: true,
                                          shape: BoxShape.circle,
                                          borderRadius: BorderRadius.circular(8),
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Container(
                              width: _size.width - 144,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _userModelController.displayName!,
                                        style: TextStyle(
                                            color: Color(0xFF111111),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 1,
                                  ),
                                  Text(
                                    _userModelController.userEmail!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Color(0xFF949494), fontSize: 13),
                                  ),
                                ],
                              ),
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
                          onTap: (){
                            Get.to(()=> FriendListPage());
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Image.asset('assets/imgs/icons/icon_moretab_friends.png', width: 40,),
                                  Positioned(
                                    // draw a red marble
                                      bottom: 0,
                                      right: 0,
                                      child:
                                      StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('newAlarm')
                                            .where('uid', isEqualTo: _userModelController.uid!)
                                            .snapshots(),
                                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                          if (!snapshot.hasData || snapshot.data == null) {
                                            return new Icon(Icons.brightness_1,
                                                size: 7.0,
                                                color: Colors.white);
                                          }
                                          else if (snapshot.data!.docs.isNotEmpty) {
                                            final alarmDocs = snapshot.data!.docs;
                                            return
                                              (alarmDocs[0]['newInvited_friend'] == true)
                                                  ? Container(
                                                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFD6382B),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text('NEW',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFFFFFFFF)
                                                  ),

                                                ),
                                              )
                                                  :
                                              Container();
                                            new Icon(Icons.brightness_1,
                                                size: 7.0,
                                                color: (alarmDocs[0]['newInvited_friend'] == true)
                                                    ? Color(0xFFD32F2F)
                                                    : Colors.white);
                                          }
                                          else if (snapshot.connectionState == ConnectionState.waiting) {
                                            return new Icon(Icons.brightness_1,
                                                size: 7.0,
                                                color: Colors.white);
                                          }
                                          return new Icon(Icons.brightness_1,
                                              size: 7.0,
                                              color: Colors.white);
                                        },
                                      )
                                  )
                                ],
                              ),
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
                            CustomFullScreenDialog.showDialog();
                            await _userModelController.getCurrentUser_crew(_userModelController.uid);
                            await _liveCrewModelController.deleteInvitationAlarm_crew(leaderUid: _userModelController.uid);
                            if(_userModelController.liveCrew!.isEmpty){
                              CustomFullScreenDialog.cancelDialog();
                              Get.to(()=>FirstPage_createCrew());
                            }
                            else{
                              CustomFullScreenDialog.cancelDialog();
                              Get.to(()=> CrewDetailPage_screen());
                            }
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Image.asset('assets/imgs/icons/icon_moretab_team.png', width: 40),
                                  Positioned(
                                    // draw a red marble
                                      top: 0,
                                      right: 0.0,
                                      child:
                                      StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('newAlarm')
                                            .where('uid', isEqualTo: _userModelController.uid!)
                                            .snapshots(),
                                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                          if (!snapshot.hasData || snapshot.data == null) {
                                            return new Icon(Icons.brightness_1,
                                                size: 7.0,
                                                color: Colors.white);
                                          }
                                          else if (snapshot.data!.docs.isNotEmpty) {
                                            final alarmDocs = snapshot.data!.docs;
                                            return
                                              (alarmDocs[0]['newInvited_crew'] == true)
                                                  ? Container(
                                                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFD6382B),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text('NEW',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFFFFFFFF)
                                                  ),
                                                ),
                                              )
                                                  : Container();
                                            // new Icon(Icons.brightness_1,
                                            //   size: 7.0,
                                            //   color: (alarmDocs[0]['newInvited_crew'] == true)
                                            //       ? Color(0xFFD32F2F)
                                            //       : Colors.white);
                                          }
                                          else if (snapshot.connectionState == ConnectionState.waiting) {
                                            return new Icon(Icons.brightness_1,
                                                size: 7.0,
                                                color: Colors.white);
                                          }
                                          return new Icon(Icons.brightness_1,
                                              size: 7.0,
                                              color: Colors.white);
                                        },
                                      )
                                  )
                                ],
                              ),
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
                    Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Get.to(()=>EventPage());
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              children: [
                                Image.asset('assets/imgs/icons/icon_moretab_event.png', width: 40),
                                SizedBox(height: 6),
                                Text('이벤트', style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF555555)
                                ),)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Column(
                    //   children: [
                    //     GestureDetector(
                    //       onTap: (){
                    //         Get.to(()=>FleaMarketScreen());
                    //       },
                    //       child: Column(
                    //         children: [
                    //           Image.asset('assets/imgs/icons/icon_moretab_snowmarket.png', width: 40),
                    //           SizedBox(height: 2),
                    //           Text('스노우마켓',style: TextStyle(
                    //               fontSize: 14
                    //           ),)
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
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
                  Get.to(() => FavoriteResort_moreTab());
                },
                title: Text(
                  '자주가는 스키장',
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
                  Get.to(() => ResortTab());
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
                  Get.to(() => NoticeList());
                },
                title: Row(
                  children: [
                    Text(
                      '공지사항',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF111111)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 12),
                      child: new Icon(Icons.brightness_1, size: 6.0,
                          color:
                          (_noticeController.isNewNotice == true)
                              ?Color(0xFFD32F2F):Colors.white),
                    ),
                  ],
                ),
                trailing: Image.asset(
                  'assets/imgs/icons/icon_arrow_g.png',
                  height: 24,
                  width: 24,
                ),
              ),ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                minVerticalPadding: 20,
                onTap: () {
                  _urlLauncherController.otherShare(contents: 'http://pf.kakao.com/_LxnDdG/chat');
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
