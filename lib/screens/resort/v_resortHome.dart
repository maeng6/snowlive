import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/public/vm_refreshController.dart';
import 'package:com.snowlive/controller/home/vm_streamController_resortHome.dart';
import 'package:com.snowlive/screens/resort/v_alarmCenter.dart';
import 'package:com.snowlive/widget/w_popUp_bottomSheet.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/controller/public/vm_DialogController_resortHome.dart';
import 'package:com.snowlive/controller/fleaMarket/vm_fleaMarketController.dart';
import 'package:com.snowlive/controller/public/vm_getDateTimeController.dart';
import 'package:com.snowlive/controller/ranking/vm_liveMapController.dart';
import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:com.snowlive/screens/banner/v_banner_resortHome.dart';
import 'package:com.snowlive/screens/more/friend/v_friendDetailPage.dart';
import 'package:com.snowlive/screens/v_webPage.dart';
import 'package:com.snowlive/controller/resort/vm_resortModelController.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../controller/liveCrew/vm_liveCrewModelController.dart';
import '../../controller/public/vm_limitController.dart';
import '../../controller/public/vm_urlLauncherController.dart';
import '../../controller/ranking/vm_rankingTierModelController.dart';
import '../../widget/w_shimmer.dart';
import 'package:lottie/lottie.dart';
import '../more/friend/v_friendListPage.dart';

class ResortHome extends StatefulWidget {
  @override
  State<ResortHome> createState() => _ResortHomeState();
}

class _ResortHomeState extends State<ResortHome> with AutomaticKeepAliveClientMixin {

  final FirebaseAuth auth = FirebaseAuth.instance;
  bool get wantKeepAlive => true;
  int lengthOfLivefriends = 0;
  bool isSnackbarShown = false;
  List<bool?> _isSelected = List<bool?>.filled(13, false);
  bool _isWeatherInfoExpanded = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _alarmStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _friendStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _bfStream;
  Stream<QuerySnapshot>? _rankingGuideUrlStream;

  Map? userRankingMap_all;


  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  GetDateTimeController _getDateTimeController = Get.find<GetDateTimeController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();
  RefreshController _refreshController = Get.find<RefreshController>();
  limitController _seasonController = Get.find<limitController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  StreamController_ResortHome _streamController_ResortHome = Get.find<StreamController_ResortHome>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  //TODO: Dependency Injection**************************************************


  ListTile buildResortListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${resortNameList[index]}'),
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        _isSelected = List<bool?>.filled(13, false);
        _isSelected[index] = true;
        await _userModelController.updateInstantResort(index);
        await _resortModelController.getSelectedResort(index);
        print('${_resortModelController.webcamUrl}');
        setState(() {});
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userModelController.updateIsOnLiveOff();
    _seasonController.getSeasonOpen();
    _liveCrewModelController.getCurrrentCrew(_userModelController.liveCrew);
    _alarmStream = _streamController_ResortHome.alarmStream.value;
    _friendStream = _streamController_ResortHome.friendStream.value;
    _bfStream = _streamController_ResortHome.bfStream.value;
    _rankingGuideUrlStream = _streamController_ResortHome.rankingGuideUrlStream.value;


    WidgetsBinding.instance.addPostFrameCallback((_) {
      bottomPopUp(context);
    });

    try{
      FirebaseAnalytics.instance.logEvent(
        name: 'visit_resortHome',
        parameters: <String, dynamic>{
          'user_id': _userModelController.uid,
          'user_name': _userModelController.displayName,
          'user_resort': _userModelController.favoriteResort
        },
      );
    }catch(e, stackTrace){
      print('GA 업데이트 오류: $e');
      print('Stack trace: $stackTrace');
    }

  }

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    super.build(context);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ); // 상단 StatusBar 생성
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: (Platform.isAndroid)
            ? Brightness.light
            : Brightness.dark //ios:dark, android:light
    ));

    //TODO: Dependency Injection**************************************************
    Get.put(FleaModelController(), permanent: true);
    DialogController _dialogController = Get.put(DialogController(), permanent: true);
    //TODO: Dependency Injection**************************************************

    return FutureBuilder(
        future: _userModelController.getLocalSave(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          _resortModelController.getSelectedResort(_userModelController.instantResort!);
          return WillPopScope(
              onWillPop: () {
                return Future(() => false);
              },
              child: Obx(()=>Scaffold(
                      floatingActionButton: SizedBox(
                        width: 112,
                        height: 54,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF000000).withOpacity(0.1),
                                spreadRadius: 4,
                                blurRadius: 16,
                                offset: Offset(0, 6), // changes position of shadow
                              ),
                            ],
                          ),
                          child: FloatingActionButton.extended(
                              onPressed: () async {
                                if (_userModelController.isOnLive == true) {
                                  if(!isSnackbarShown) {
                                    HapticFeedback.lightImpact();
                                    _dialogController.isChecked.value = false;
                                    CustomFullScreenDialog.showDialog();
                                    await _userModelController.updateIsOnLiveOff();
                                    await _liveMapController.stopForegroundLocationService();
                                    await _liveMapController.stopBackgroundLocationService();
                                    await _liveMapController.checkAndUpdatePassCountOff();
                                    await _liveMapController.checkAndUpdatePassCountOffDaily();
                                    await _userModelController.getCurrentUserLocationInfo(_userModelController.uid);
                                    setState(() {});
                                    CustomFullScreenDialog.cancelDialog();
                                    print('라이브 OFF');
                                  }
                                } else if(_userModelController.isOnLive == false){
                                  if(!isSnackbarShown) {
                                    HapticFeedback.lightImpact();
                                    Get.dialog(
                                      WillPopScope(
                                        onWillPop: () async => false, // Prevents dialog from closing on Android back button press
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () async {
                                            _dialogController.isChecked.value = false; // Reset checkbox when dialog is closed
                                            await _liveMapController.stopForegroundLocationService();
                                            await _liveMapController.stopBackgroundLocationService();
                                            Get.back();
                                            CustomFullScreenDialog.cancelDialog();
                                            print('라이브 OFF');
                                          },
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: AlertDialog(
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                              content: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("스노우라이브 랭킹전에 참여해 보세요",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF111111)
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text("위치를 사용하시면 라이브 기능을 통해 랭킹 서비스를 이용할 수 있고, 친구와 라이브 상태를 공유할 수 있어요.",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.normal,
                                                        color: Color(0xFF666666)
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  Text("랭킹전 유의사항",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        height: 1.4,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF3D83ED)
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text("1. 와이파이 끄고 데이터 사용\n2. 위치 추적 항상 허용으로 설정",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        height: 1.4,
                                                        fontWeight: FontWeight.normal,
                                                        color: Color(0xFF111111)
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  StreamBuilder(
                                                      stream: _rankingGuideUrlStream,
                                                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                                        if (!snapshot.hasData || snapshot.data == null) {}
                                                        else if (snapshot.data!.docs.isNotEmpty) {
                                                          final ranking_guideUrlDoc = snapshot.data!.docs;
                                                          return Padding(
                                                            padding: EdgeInsets.only(right: 8),
                                                            child: GestureDetector(
                                                              onTap: (){
                                                                Platform.isIOS
                                                                    ? _urlLauncherController.otherShare(contents: '${ranking_guideUrlDoc[0]['url_iOS']}')
                                                                    : _urlLauncherController.otherShare(contents: '${ranking_guideUrlDoc[0]['url_android']}');
                                                              },
                                                              child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(bottom: 2),
                                                                      child: Container(
                                                                        padding: EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 10), // 텍스트와 테두리 간의 패딩
                                                                        decoration: BoxDecoration(
                                                                          color: Color(0xFFCBE0FF),
                                                                          borderRadius: BorderRadius.circular(4), // 테두리 모서리 둥글게
                                                                        ),
                                                                        child: Text(
                                                                          '휴대폰 설정방법 보러가기',
                                                                          style: TextStyle(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Color(0xFF3D83ED)
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ]
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        else if (snapshot.connectionState == ConnectionState.waiting) {}
                                                        return SizedBox.shrink();
                                                      }),
                                                  SizedBox(height: 30),
                                                  Obx(() => GestureDetector(
                                                    onTap: () {
                                                      _dialogController.isChecked.value = !_dialogController.isChecked.value;
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Image.asset(
                                                          _dialogController.isChecked.value
                                                              ? 'assets/imgs/icons/icon_check_filled.png'
                                                              : 'assets/imgs/icons/icon_check_unfilled.png',
                                                          width: 24,
                                                          height: 24,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          '위치정보 사용 및 이용약관 동의',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),

                                                  SizedBox(height: 20),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Get.to(()=>WebPage(url: 'https://sites.google.com/view/134creativelablocationinfo/%ED%99%88'));
                                                    },
                                                    child: Center(
                                                      child: Text('약관보기',
                                                        style: TextStyle(
                                                            decoration: TextDecoration.underline,
                                                            fontSize: 14,
                                                            color: Color(0xFF949494)
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 24,
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: ElevatedButton(onPressed: () async {
                                                          _dialogController.isChecked.value = false; // Reset checkbox when dialog is closed
                                                          await _liveMapController.stopForegroundLocationService();
                                                          await _liveMapController.stopBackgroundLocationService();
                                                          Get.back();
                                                          CustomFullScreenDialog.cancelDialog();
                                                          print('라이브 OFF');
                                                        },
                                                          child: Text(
                                                            '취소',
                                                            style: TextStyle(
                                                                color: Color(0xff3D83ED),
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          style: TextButton.styleFrom(
                                                            splashFactory: InkRipple.splashFactory,
                                                            elevation: 0,
                                                            minimumSize: Size(100, 48),
                                                            backgroundColor: Color(0xFF3D83ED).withOpacity(0.2),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8,),
                                                      Obx(() => Expanded(
                                                        child: ElevatedButton(
                                                          onPressed: _dialogController.isChecked.value ? () async {
                                                            Navigator.pop(context);
                                                            print('이 프린트 지우면안됨');
                                                            CustomFullScreenDialog.showDialog();
                                                            await _liveMapController.startForegroundLocationService();
                                                            await _liveMapController.startBackgroundLocationService();
                                                            await _userModelController.getCurrentUserLocationInfo(_userModelController.uid);
                                                            _dialogController.isChecked.value = false;
                                                            CustomFullScreenDialog.cancelDialog();
                                                            if (_userModelController.withinBoundary == true) {
                                                              await _userModelController.updateIsOnLiveOn();
                                                              try{
                                                                await FirebaseAnalytics.instance.logEvent(
                                                                  name: 'live_on_button_pressed_Success',
                                                                  parameters: <String, dynamic>{
                                                                    'user_id': _userModelController.uid,
                                                                    'user_name': _userModelController.displayName,
                                                                    'user_resort': _userModelController.favoriteResort
                                                                  },
                                                                );
                                                              }catch(e, stackTrace){
                                                                print('GA 업데이트 오류: $e');
                                                                print('Stack trace: $stackTrace');
                                                              }
                                                              await _userModelController.getCurrentUser(_userModelController.uid);
                                                              print('라이브 ON');
                                                            }
                                                            else {
                                                              if(!isSnackbarShown){
                                                                isSnackbarShown = true;
                                                                Get.snackbar(
                                                                  '라이브 불가 지역입니다',
                                                                  '자주가는 스키장에서만 라이브가 활성화됩니다.',
                                                                  margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                                                                  snackPosition: SnackPosition.BOTTOM,
                                                                  backgroundColor: Colors.black87,
                                                                  colorText: Colors.white,
                                                                  duration: Duration(milliseconds: 3000),
                                                                );
                                                                Future.delayed(Duration(milliseconds: 4500), () {
                                                                  isSnackbarShown = false;
                                                                });
                                                                print('라이브 불가 지역');
                                                              }
                                                              await _liveMapController.stopForegroundLocationService();
                                                              await _liveMapController.stopBackgroundLocationService();
                                                            }
                                                            setState(() {});

                                                          }
                                                              : null,
                                                          child: Text(
                                                            '동의',
                                                            style: TextStyle(
                                                                color: Color(0xffffffff),
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                          style: TextButton.styleFrom(
                                                              splashFactory: InkRipple.splashFactory,
                                                              elevation: 0,
                                                              minimumSize: Size(100, 48),
                                                              backgroundColor: _dialogController.isChecked.value
                                                                  ? Color(0xFF3D83ED)
                                                                  : Color(0xFFDEDEDE)
                                                          ),
                                                        ),
                                                      ),),
                                                    ],
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      barrierDismissible: true,
                                    );
                                    // await Future.delayed(Duration(seconds: 2)); // Wait for 1 second
                                  }
                                }
                                if(_userModelController.isOnLive == false && _seasonController.open == false && !_seasonController.open_uidList!.contains(_userModelController.uid)){
                                  Get.dialog(
                                    AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      actionsPadding: EdgeInsets.only(top: 0, right: 20, left: 20, bottom: 20),
                                      content: Container(
                                        height: 290,
                                        child: Column(
                                          children: [
                                            ExtendedImage.asset(
                                              'assets/imgs/imgs/img_app_season.png',
                                              scale: 4,
                                              fit: BoxFit.fitHeight,
                                              width: MediaQuery.of(Get.context!).size.width,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 20,
                                                right: 20,
                                                left: 20,
                                                bottom: 24,
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: 240,
                                                        child: Text(
                                                          '라이브 서비스 준비중입니다',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF111111),
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        Container(
                                          width: MediaQuery.of(Get.context!).size.width,
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              '확인',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFFffffff),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFF3D83ED),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              elevation: 0,
                              icon:  (_userModelController.isOnLive == true && _userModelController.withinBoundary ==true)
                                  ? Transform.translate(
                                  offset: Offset(4,0),
                                  child: Image.asset('assets/imgs/icons/icon_live_on.png', width: 50))
                                  : Transform.translate(
                                  offset: Offset(4,0),
                                  child: Image.asset('assets/imgs/icons/icon_live_off.png', width: 50)),
                              label: (_userModelController.isOnLive == true  && _userModelController.withinBoundary ==true)
                                  ? Transform.translate(
                                offset: Offset(0,-0.5),
                                child: Text(
                                  'ON',
                                  style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: -0.1,
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w900,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              )
                                  : Transform.translate(
                                offset: Offset(0,-0.5),
                                child: Text(
                                  'OFF',
                                  style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: -0.1,
                                      color: Color(0xFF444444),
                                      fontWeight: FontWeight.w900,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              backgroundColor:
                              (_userModelController.isOnLive == true  && _userModelController.withinBoundary ==true)
                                  ? Color(0xFF3D6FED)
                                  : Color(0xFFFFFFFF)),
                        ),
                      ),
                      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                                  padding: const EdgeInsets.only(right: 8),
                                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                    stream: _alarmStream,
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                      if (!snapshot.hasData || snapshot.data == null) {
                                        return  Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Stack(
                                            children: [
                                              IconButton(
                                                onPressed: () async{
                                                  CustomFullScreenDialog.showDialog();
                                                  try {
                                                    await _userModelController.deleteInvitationAlarm_friend(uid: _userModelController.uid);
                                                    await _userModelController.deleteAlarmCenterNoti(uid: _userModelController.uid);
                                                  }catch(e){}

                                                  CustomFullScreenDialog.cancelDialog();
                                                  Get.to(()=>AlarmCenter());
                                                },
                                                icon: OverflowBox(
                                                  maxHeight: 42,
                                                  maxWidth: 42,
                                                  child: Image.asset(
                                                    'assets/imgs/icons/icon_alarm.png',
                                                  ),
                                                ),
                                              ),
                                              Positioned(  // draw a red marble
                                                top: 10,
                                                left: 32,
                                                child: new Icon(Icons.brightness_1, size: 6.0,
                                                    color:Colors.transparent),
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                      if (snapshot.data!.docs.isNotEmpty) {
                                        final alarmDocs = snapshot.data!.docs;
                                        bool alarmIsActive;
                                        try {
                                          alarmIsActive = (alarmDocs[0]['alarmCenter'] ?? false) == true;
                                        }catch(e){
                                          alarmIsActive = false;
                                        }
                                        return  Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Stack(
                                            children: [
                                              IconButton(
                                                onPressed: () async{
                                                  CustomFullScreenDialog.showDialog();
                                                  try {
                                                    await _userModelController.deleteAlarmCenterNoti(uid: _userModelController.uid);
                                                  }catch(e){}
                                                  CustomFullScreenDialog.cancelDialog();
                                                  Get.to(()=>AlarmCenter());
                                                },
                                                icon: OverflowBox(
                                                  maxHeight: 42,
                                                  maxWidth: 42,
                                                  child: Image.asset(
                                                    'assets/imgs/icons/icon_alarm.png',
                                                  ),
                                                ),
                                              ),
                                              Positioned(  // draw a red marble
                                                  top: 2,
                                                  right: 0,
                                                  child:
                                                  (alarmIsActive)
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
                                                  Container()
                                                // new Icon(Icons.brightness_1, size: 6.0,
                                                //     color:
                                                //     (alarmDocs[0]['newInvited_friend'] == true)
                                                //         ?Color(0xFFD32F2F):Colors.white),
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return  Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Stack(
                                            children: [
                                              IconButton(
                                                onPressed: () async{
                                                  CustomFullScreenDialog.showDialog();
                                                  try {
                                                    await _userModelController.deleteInvitationAlarm_friend(uid: _userModelController.uid);
                                                    await _userModelController.deleteAlarmCenterNoti(uid: _userModelController.uid);
                                                  }catch(e){}
                                                  CustomFullScreenDialog.cancelDialog();
                                                  Get.to(()=>AlarmCenter());
                                                },
                                                icon: OverflowBox(
                                                  maxHeight: 42,
                                                  maxWidth: 42,
                                                  child: Image.asset(
                                                    'assets/imgs/icons/icon_alarm.png',
                                                  ),
                                                ),
                                              ),
                                              Positioned(  // draw a red marble
                                                top: 2,
                                                left: 0,
                                                child: new Icon(Icons.brightness_1, size: 6.0,
                                                    color:Colors.white),
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                      return  Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Stack(
                                          children: [
                                            IconButton(
                                              onPressed: () async{
                                                CustomFullScreenDialog.showDialog();
                                                try {
                                                  await _userModelController.deleteInvitationAlarm_friend(uid: _userModelController.uid);
                                                  await _userModelController.deleteAlarmCenterNoti(uid: _userModelController.uid);
                                                }catch(e){}
                                                CustomFullScreenDialog.cancelDialog();
                                                Get.to(()=>AlarmCenter());
                                              },
                                              icon: OverflowBox(
                                                maxHeight: 40,
                                                maxWidth: 40,
                                                child: Image.asset(
                                                  'assets/imgs/icons/icon_alarm.png',
                                                ),
                                              ),
                                            ),
                                            Positioned(  // draw a red marble
                                              top: 0,
                                              left: 32,
                                              child: new Icon(Icons.brightness_1, size: 6.0,
                                                  color:Colors.white),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              systemOverlayStyle: SystemUiOverlayStyle.dark,
                              centerTitle: false,
                              titleSpacing: 0,
                              title: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: (_userModelController.isOnLive == true)
                                    ? Image.asset(
                                  'assets/imgs/logos/snowliveLogo_main_new_blue.png',
                                  width: 177,
                                  height: 28,
                                )
                                    : Image.asset(
                                  'assets/imgs/logos/snowliveLogo_main_new.png',
                                  width: 177,
                                  height: 28,
                                ),
                              ),
                              backgroundColor: Colors.white,
                              elevation: 0.0,
                            )
                          ],
                        ),
                      ),
                      body: RefreshIndicator(
                        strokeWidth: 2,
                        edgeOffset: 40,
                        onRefresh: _refreshController.onRefresh_resortHome,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: _statusBarSize + 64,
                              ),
                              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                stream: _friendStream,
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container(
                                      color: Colors.white,
                                    );
                                  }
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final bestfriendDocs = snapshot.data!.docs;
                                  print(bestfriendDocs);

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: (bestfriendDocs.isEmpty) ? 0 : 100,
                                        color: Color(0xFFF1F1F3),
                                        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                          stream: _bfStream,
                                          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>snapshot) {
                                            try {
                                              if (!snapshot.hasData || snapshot.data == null) {
                                                return SizedBox.shrink();
                                              }
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return SizedBox.shrink();
                                              }
                                              if (snapshot.data!.docs.isNotEmpty) {
                                                final bestfriendDocs = snapshot.data!.docs;
                                                return ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: bestfriendDocs.isNotEmpty ? bestfriendDocs.length + 1 : 1,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      if (index < bestfriendDocs.length) {
                                                        var BFdoc = bestfriendDocs[index];
                                                        return Padding(
                                                          padding: index == 0 ? EdgeInsets.only(left: 10) : EdgeInsets.zero,
                                                          child: Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Get.to(() => FriendDetailPage(uid: BFdoc.get('uid'), favoriteResort: BFdoc.get('favoriteResort'),));
                                                                },
                                                                child: Container(
                                                                  width: 70,
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Stack(
                                                                        fit: StackFit.loose,
                                                                        children: [
                                                                          Container(
                                                                            alignment: Alignment.center,
                                                                            child: BFdoc.get('profileImageUrl').isNotEmpty
                                                                                ? ExtendedImage.network(
                                                                              BFdoc.get('profileImageUrl'),
                                                                              enableMemoryCache: true,
                                                                              shape: BoxShape.circle,
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              width: 56,
                                                                              height: 56,
                                                                              fit: BoxFit.cover,
                                                                              loadStateChanged: (ExtendedImageState state) {
                                                                                switch (state.extendedImageLoadState) {
                                                                                  case LoadState.loading:
                                                                                    return SizedBox.shrink();
                                                                                  case LoadState.completed:
                                                                                    return state.completedWidget;
                                                                                  case LoadState.failed:
                                                                                    return ExtendedImage.asset(
                                                                                      'assets/imgs/profile/img_profile_default_circle.png',
                                                                                      shape: BoxShape.circle,
                                                                                      borderRadius: BorderRadius.circular(8),
                                                                                      width: 56,
                                                                                      height: 56,
                                                                                      fit: BoxFit.cover,
                                                                                    );
                                                                                  default:
                                                                                    return null;
                                                                                }
                                                                              },
                                                                            )
                                                                                : ExtendedImage.asset(
                                                                              'assets/imgs/profile/img_profile_default_circle.png',
                                                                              enableMemoryCache: true,
                                                                              shape: BoxShape.circle,
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              width: 56,
                                                                              height: 56,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                          BFdoc.get('isOnLive') == true
                                                                              ? Positioned(
                                                                            right: 0,
                                                                            bottom: 0,
                                                                            child: Image.asset(
                                                                              'assets/imgs/icons/icon_badge_live.png',
                                                                              width: 32,
                                                                            ),
                                                                          )
                                                                              : Container()
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 6),
                                                                      Container(
                                                                        width: 70,
                                                                        child: Text(
                                                                          BFdoc.get('displayName'),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          textAlign: TextAlign.center,
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.normal,
                                                                              color: Color(0xFF111111)
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        return Column(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                Get.to(() => FriendListPage());
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.only(left: 6, right: 16),
                                                                child: DottedBorder(
                                                                  borderType: BorderType.RRect,
                                                                  radius: Radius.circular(50),
                                                                  color: Color(0xFFDEDEDE),
                                                                  strokeWidth: 1,
                                                                  dashPattern: [6, 5],
                                                                  child: Container(
                                                                    width: 52,
                                                                    height: 52,
                                                                    child: Icon(Icons.add),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                    }
                                                );
                                              }
                                              return SizedBox.shrink();
                                            } catch (e) {
                                              SizedBox.shrink();
                                            }
                                            return SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              Container(
                                color: Colors.white,
                                child: Padding(
                                    padding:
                                    EdgeInsets.only(left: 16, right: 16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Obx(() => Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(14),
                                                color: (_resortModelController.isLoading == true)
                                                    ? Color(0xffc8c8c8)
                                                    : _resortModelController.weatherColors),
                                            alignment: Alignment.center,
                                            width: double.infinity,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 24,
                                                ),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        GestureDetector(
                                                          child: Obx(() => Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 24),
                                                                  child: Text(
                                                                    '${_resortModelController.resortName}',
                                                                    style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 22),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(bottom: 3),
                                                                  child: Image.asset(
                                                                    'assets/imgs/icons/icon_dropdown.png',
                                                                    width: 18,
                                                                    height: 18,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            showModalBottomSheet(
                                                                enableDrag: false,
                                                                context: context,
                                                                builder: (context) {
                                                                  return Container(
                                                                    color: Colors.white,
                                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                                                    height:
                                                                    _size.height * 0.8,
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          '스키장을 선택해주세요.',
                                                                          style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        SizedBox(
                                                                          height: 10,
                                                                        ),
                                                                        Text(
                                                                          '관심있는 스키장을 선택해 스키장과 관련된 실시간 날씨 정보와 웹캠, 슬로프 오픈 현황 등을 확인하세요.',
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w300,
                                                                              color: Color(0xFF666666)),
                                                                        ),
                                                                        Container(
                                                                          color: Colors.white,
                                                                          height: 30,
                                                                        ),
                                                                        Expanded(
                                                                          child: ListView.builder(
                                                                              padding: EdgeInsets.zero,
                                                                              itemCount: 13,
                                                                              itemBuilder: (context, index) {
                                                                                return Builder(builder:
                                                                                    (context) {
                                                                                  return Column(
                                                                                    children: [
                                                                                      buildResortListTile(index),
                                                                                      Divider(
                                                                                        height: 20,
                                                                                        thickness: 0.5,
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                });
                                                                              }),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                });
                                                          },
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        SizedBox(
                                                          height: 26,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 24),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Text('${_getDateTimeController.date}',
                                                                  style: TextStyle(
                                                                      color:
                                                                      Color(0xFFFFFFFF).withOpacity(0.6),
                                                                      fontWeight: FontWeight.normal,
                                                                      fontSize: 14),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Transform.translate(
                                                            offset: Offset(0, 6),
                                                            child: _resortModelController.weatherIcons),
                                                        SizedBox(width: 10,),
                                                        Obx(() => (_resortModelController.isLoading == true)
                                                                  ? Padding(
                                                                padding: const EdgeInsets.only(top: 10),
                                                                child: Container(
                                                                    height: 30,
                                                                    width: 50,
                                                                    child: Lottie.asset('assets/json/loadings_wht_final.json')),
                                                              )
                                                                  : Text('${_resortModelController.resortTemp!}',
                                                                //u00B0
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 48,
                                                                    color: Colors.white),
                                                              ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: 24),
                                                          child: Obx(
                                                                () => (_resortModelController.isLoading == true)
                                                                    ? Text(' ',
                                                                  style: GoogleFonts.bebasNeue(
                                                                      fontSize: 48,
                                                                      color: Colors.white),
                                                                )
                                                                    : Text('\u00B0',
                                                                  style: GoogleFonts.bebasNeue(
                                                                      fontSize: 48,
                                                                      color: Colors.white),
                                                                ),
                                                          ),
                                                        ),
                                                        Transform.translate(
                                                            offset: Offset(-15, 19),
                                                            child: GestureDetector(
                                                              onTap: (){
                                                                setState(() {
                                                                  if(_isWeatherInfoExpanded == false){
                                                                    _isWeatherInfoExpanded = true;
                                                                  } else{
                                                                    _isWeatherInfoExpanded = false;
                                                                  }
                                                                });
                                                              },
                                                              child: ExtendedImage.asset(
                                                                'assets/imgs/icons/icon_plus_round.png',
                                                                fit: BoxFit.cover,
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                            ),
                                                        ),

                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                if(_isWeatherInfoExpanded == true)
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                if(_isWeatherInfoExpanded == true)
                                                (_resortModelController.isLoading == true)
                                                ? Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                                  child: Container(
                                                    color: Color(0xFF949494).withOpacity(0.3),
                                                    height: 1,
                                                    width: _size.width,
                                                  ),
                                                )
                                                : Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                                  child: Container(
                                                    color: Color(0xFF000000).withOpacity(0.1),
                                                    height: 1,
                                                    width: _size.width,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                if(_isWeatherInfoExpanded == true)
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text('바람',
                                                          style: TextStyle(
                                                              color: Colors.white60,
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Obx(
                                                                  () => Padding(
                                                                padding:
                                                                const EdgeInsets.only(right: 3),
                                                                child: Text(
                                                                  '${_resortModelController.resortWind}',
                                                                  style: GoogleFonts.bebasNeue(
                                                                      fontSize: 24,
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(bottom: 4),
                                                              child: Text('M/S',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 15,
                                                                    color: Colors.white),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          '습도',
                                                          style: TextStyle(
                                                              color: Colors.white60,
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Obx(
                                                                  () => Padding(
                                                                padding:
                                                                const EdgeInsets.only(right: 3),
                                                                child: Text(
                                                                  '${_resortModelController.resortWet}',
                                                                  style: GoogleFonts.bebasNeue(
                                                                      fontSize: 24,
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(bottom: 5),
                                                              child: Text('%',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 15,
                                                                    color: Colors.white),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          '강수',
                                                          style: TextStyle(
                                                              color: Colors.white60,
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Obx(
                                                                  () => Padding(
                                                                padding: const EdgeInsets.only(right: 3),
                                                                child: Text('${_resortModelController.resortRain}',
                                                                  style: GoogleFonts.bebasNeue(
                                                                      fontSize: 24,
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(bottom: 5),
                                                              child: Text('MM',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 16,
                                                                    color: Colors.white),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          '최저/최고기온',
                                                          style: TextStyle(
                                                              color: Colors.white60,
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Obx(
                                                              () => Row(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Text(
                                                                '${_resortModelController.resortMinTemp}',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 24,
                                                                    color: Colors.white),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets.only(
                                                                    bottom: 5,
                                                                    left: 3, right: 2),
                                                                child: Text(
                                                                  '/',
                                                                  style: GoogleFonts.bebasNeue(
                                                                      fontSize: 16,
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                              Text(
                                                                '${_resortModelController.resortMaxTemp}',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 24,
                                                                    color: Colors.white),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                if(_isWeatherInfoExpanded == true)
                                                SizedBox(
                                                  height: 20,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,),
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 20, left: 16, top: 16, bottom: 20),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        _urlLauncherController.otherShare(contents: '${_resortModelController.naverUrl}');
                                                      },
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/imgs/icons/icon_home_naver.png',
                                                            width: 36,
                                                            height: 36,
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            '네이버 날씨',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 12,
                                                                color: Color(0xFF111111)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (_resortModelController.webcamUrl != '') {
                                                          _urlLauncherController.otherShare(contents: '${_resortModelController.webcamUrl}');
                                                        }
                                                      },
                                                      child: Column(
                                                        children: [
                                                          (_resortModelController.webcamUrl != '')
                                                              ? Image.asset(
                                                            'assets/imgs/icons/icon_home_livecam.png',
                                                            width: 36,
                                                            height: 36,
                                                          )
                                                              : Image.asset(
                                                            'assets/imgs/icons/icon_home_livecam_off.png',
                                                            width: 36,
                                                            height: 36,
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            '실시간 웹캠',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 12,
                                                                color: (_resortModelController.webcamUrl != '')
                                                                    ? Color(0xFF111111)
                                                                    : Color(0xFFC8C8C8)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (_resortModelController.slopeUrl != '') {
                                                          _urlLauncherController.otherShare(contents: '${_resortModelController.slopeUrl}');
                                                        }
                                                      },
                                                      child: Column(
                                                        children: [
                                                          (_resortModelController.slopeUrl != '')
                                                              ? Image.asset(
                                                            'assets/imgs/icons/icon_home_slope.png',
                                                            width: 36,
                                                            height: 36,
                                                          )
                                                              : Image.asset(
                                                            'assets/imgs/icons/icon_home_slope_off.png',
                                                            width: 36,
                                                            height: 36,
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            '슬로프 현황',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 12,
                                                                color: (_resortModelController.slopeUrl != '')
                                                                    ? Color(0xFF111111)
                                                                    : Color(0xFFC8C8C8)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (_resortModelController.busUrl != '') {
                                                          _urlLauncherController.otherShare(contents: '${_resortModelController.busUrl}');
                                                        }
                                                      },
                                                      child: Column(
                                                        children: [
                                                          (_resortModelController.busUrl != '')
                                                              ? Image.asset(
                                                            'assets/imgs/icons/icon_home_bus.png',
                                                            width: 36,
                                                            height: 36,
                                                          )
                                                              : Image.asset(
                                                            'assets/imgs/icons/icon_home_bus_off.png',
                                                            width: 36,
                                                            height: 36,
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            '셔틀버스',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 12,
                                                                color: (_resortModelController.busUrl != '')
                                                                    ? Color(0xFF111111)
                                                                    : Color(0xFFC8C8C8)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.zero,
                                              child: Banner_resortHome(),
                                            ),
                                            SizedBox(
                                              height: 32,
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('내 시즌 정보',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF111111)
                                                ),
                                                ),
                                                SizedBox(height: 15,),

                                                StreamBuilder<QuerySnapshot>(
                                                  stream: _streamController_ResortHome.setupStreams_resortHome_myScore(_userModelController.favoriteResort!, _userModelController.uid!),
                                                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                    final containerHeight = MediaQuery.of(context).size.height / 8;

                                                    if (!snapshot.hasData || snapshot.data == null || snapshot.connectionState == ConnectionState.waiting) {
                                                      return loading_resortHome_scoreBox(containerHeight);
                                                    } else if (snapshot.hasError) {
                                                      return Text('오류: ${snapshot.error}');
                                                    } else if (snapshot.data!.docs.isNotEmpty) {
                                                      final rankingDocs = snapshot.data!.docs;

                                                      if (rankingDocs[0]['totalScore'] != 0) {
                                                        return StreamBuilder<QuerySnapshot>(
                                                          stream: _streamController_ResortHome.setupStreams_resortHome_myRank(_userModelController.favoriteResort!),
                                                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                            if (!snapshot.hasData || snapshot.data == null || snapshot.connectionState == ConnectionState.waiting) {
                                                              return loading_resortHome_scoreBox(containerHeight);
                                                            } else if (snapshot.hasError) {
                                                              return Text('오류: ${snapshot.error}');
                                                            } else if (snapshot.data!.docs.isNotEmpty) {
                                                              final rankingDocs_total = snapshot.data!.docs;

                                                              if (_userModelController.favoriteResort == 12 || _userModelController.favoriteResort == 2 || _userModelController.favoriteResort == 0) {
                                                                userRankingMap_all = _rankingTierModelController.calculateRankIndiAll2(userRankingDocs: rankingDocs_total);
                                                              } else {
                                                                userRankingMap_all = _rankingTierModelController.calculateRankIndiAll2_integrated(userRankingDocs: rankingDocs_total);
                                                              }

                                                              return Container(
                                                                height: containerHeight, // Set fixed height for the data container
                                                                decoration: BoxDecoration(
                                                                  color: Color(0xFFF5F2F7),
                                                                  borderRadius: BorderRadius.circular(10),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 20, top: 25),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            children: [
                                                                              Container(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        ExtendedImage.asset(
                                                                                          'assets/imgs/icons/icon_circle_black.png',
                                                                                          fit: BoxFit.cover,
                                                                                          width: 15,
                                                                                          height: 15,
                                                                                        ),
                                                                                        SizedBox(width: 5,),
                                                                                        Text(
                                                                                          '누적 점수',
                                                                                          style: TextStyle(
                                                                                            fontWeight: FontWeight.normal,
                                                                                            fontSize: 13,
                                                                                            color: Color(0xFF111111).withOpacity(0.6),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 10,),
                                                                                    Text(
                                                                                      (_userModelController.favoriteResort == 12 || _userModelController.favoriteResort == 2 || _userModelController.favoriteResort == 0)
                                                                                          ? '${rankingDocs[0]['totalScore']}점'
                                                                                          : '${rankingDocs[0]['totalPassCount']}회',
                                                                                      style: TextStyle(
                                                                                        color: Color(0xFF111111),
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 16,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 30,),
                                                                              Container(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        ExtendedImage.asset(
                                                                                          'assets/imgs/icons/icon_circle_black.png',
                                                                                          fit: BoxFit.cover,
                                                                                          width: 15,
                                                                                          height: 15,
                                                                                        ),
                                                                                        SizedBox(width: 5,),
                                                                                        Text(
                                                                                          '통합 랭킹',
                                                                                          style: TextStyle(
                                                                                            fontWeight: FontWeight.normal,
                                                                                            fontSize: 13,
                                                                                            color: Color(0xFF111111).withOpacity(0.6),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 10,),
                                                                                    Text(
                                                                                      '${userRankingMap_all!['${_userModelController.uid}']}등',
                                                                                      style: TextStyle(
                                                                                        fontSize: 16,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        color: Color(0xFF111111),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 30,),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(top: 7),
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    // Add your share functionality here
                                                                                  },
                                                                                  child: Container(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.white,
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          '공유하기',
                                                                                          style: TextStyle(
                                                                                            color: Colors.black,
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(width: 10,),
                                                                                        ExtendedImage.asset(
                                                                                          'assets/imgs/icons/icon_arrow_round_black.png',
                                                                                          fit: BoxFit.cover,
                                                                                          width: 18,
                                                                                          height: 18,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                            return Container();
                                                          },
                                                        );
                                                      } else {
                                                        return Container(
                                                          height: containerHeight, // Set fixed height for the data container
                                                          decoration: BoxDecoration(
                                                            color: Color(0xFFF5F2F7),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 20, top: 25),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        Container(
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  SizedBox(width: 5,),
                                                                                  Text(
                                                                                    '랭킹 정보가 없습니다',
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.normal,
                                                                                      fontSize: 13,
                                                                                      color: Color(0xFF111111).withOpacity(0.6),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                    }

                                                    return Container(
                                                      height: 185, // Set fixed height for the data container
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFF5F2F7),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 20, top: 25),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                SizedBox(height: 5,),
                                                                Text(
                                                                  '지금 바로 랭킹에 참여해보세요!',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 16,
                                                                    color: Color(0xFF111111),
                                                                  ),
                                                                ),
                                                                SizedBox(height: 15,),
                                                                Text(
                                                                  '친구들의 라이브 상태도 확인하고',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.normal,
                                                                    fontSize: 13,
                                                                    color: Color(0xFF111111),
                                                                  ),
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Text(
                                                                  '다른 유저들과 경쟁해보세요!',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.normal,
                                                                    fontSize: 13,
                                                                    color: Color(0xFF111111),
                                                                  ),
                                                                ),
                                                                SizedBox(height: 10,),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 7),
                                                                  child: GestureDetector(
                                                                    onTap: () {
                                                                      // Add your share functionality here
                                                                    },
                                                                    child: Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        borderRadius: BorderRadius.circular(20),
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          Text(
                                                                            '더 알아보기',
                                                                            style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 10,),
                                                                          ExtendedImage.asset(
                                                                            'assets/imgs/icons/icon_arrow_round_black.png',
                                                                            fit: BoxFit.cover,
                                                                            width: 18,
                                                                            height: 18,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),


                                            SizedBox(
                                              height: 20,
                                            ),
                                            ElevatedButton(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: '날씨 정보는 ',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                          Color(0xFFc8c8c8),
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    TextSpan(
                                                      text: '기상청',
                                                      style: TextStyle(
                                                          decoration:
                                                          TextDecoration
                                                              .underline,
                                                          decorationThickness:
                                                          2,
                                                          fontSize: 13,
                                                          color:
                                                          Color(0xFF80B2FF),
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    TextSpan(
                                                      text: ' 정보입니다',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                          Color(0xFFc8c8c8),
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              onPressed: () {
                                                Get.dialog(AlertDialog(
                                                  contentPadding:
                                                  EdgeInsets.only(
                                                      bottom: 0,
                                                      left: 20,
                                                      right: 20,
                                                      top: 30),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
                                                  buttonPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 0),
                                                  content: Container(
                                                    height: 260,
                                                    width: _size.width * 0.8,
                                                    color: Colors.white,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Container(
                                                            width: 113,
                                                            height: 50,
                                                            child: Transform
                                                                .translate(
                                                              offset:
                                                              Offset(-8, 0),
                                                              child:
                                                              ExtendedImage
                                                                  .asset(
                                                                'assets/imgs/logos/weather_logo.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )),
                                                        SizedBox(
                                                          height: 14,
                                                        ),
                                                        Text(
                                                          '날씨는 기상청에서 제공하는 '
                                                              '데이터를 사용하고 있어요.',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                              fontSize: 20),
                                                        ),
                                                        SizedBox(
                                                          height: 14,
                                                        ),
                                                        Text(
                                                          '기상청에서 제공해주는 실시간 데이터를 사용해'
                                                              '각 스키장별 날씨정보를 제공하고있어요. '
                                                              '추후 더 자세한 날씨 데이터를 제공하기 위해 '
                                                              '업데이트 할 예정입니다.',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF666666),
                                                              fontSize: 14,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w300),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    Center(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              bottom: 1),
                                                          child: Text(
                                                            '확인',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                fontSize: 15),
                                                          ),
                                                        ),
                                                        style: TextButton.styleFrom(
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                    .circular(
                                                                    6))),
                                                            elevation: 0,
                                                            splashFactory:
                                                            InkRipple
                                                                .splashFactory,
                                                            minimumSize:
                                                            Size(1000, 50),
                                                            backgroundColor:
                                                            Color(
                                                                0xff377EEA)),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Get.to(
                                                                () => WebPage(
                                                              url:
                                                              'https://www.weather.go.kr/w/index.do',
                                                            ),
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              top: 16),
                                                          child: Text(
                                                            '기상청 홈페이지',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff949494),
                                                                fontWeight:
                                                                FontWeight
                                                                    .w300,
                                                                fontSize: 15),
                                                          ),
                                                        ),
                                                        style: TextButton.styleFrom(
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                    .circular(
                                                                    6))),
                                                            elevation: 0,
                                                            splashFactory:
                                                            InkRipple
                                                                .splashFactory,
                                                            minimumSize:
                                                            Size(1000, 50),
                                                            backgroundColor:
                                                            Color(
                                                                0xffFFFFFF)),
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(160, 40),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        6)),
                                                elevation: 0,
                                                backgroundColor: Colors.black12
                                                    .withOpacity(0),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 5),
                                              ),
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        bottom: 24.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Copyright by 134CreativeLab 2023.',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFFc8c8c8),
                                                            fontWeight:
                                                            FontWeight
                                                                .normal,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          'All right reserved.',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFFc8c8c8),
                                                            fontWeight:
                                                            FontWeight
                                                                .normal,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 16,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))

              );
        });
  }
}
