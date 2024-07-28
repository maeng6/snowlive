import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/public/vm_refreshController.dart';
import 'package:com.snowlive/controller/home/vm_streamController_resortHome.dart';
import 'package:com.snowlive/controller/public/vm_timeStampController.dart';
import 'package:com.snowlive/screens/resort/v_alarmCenter.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:com.snowlive/widget/w_liveOn_animatedGradient.dart';
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
import 'w_shimmer_resortHome.dart';
import 'package:lottie/lottie.dart';
import '../more/friend/v_friendListPage.dart';


class ResortHome extends StatefulWidget {
  @override
  State<ResortHome> createState() => _ResortHomeState();
}

class _ResortHomeState extends State<ResortHome> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  final FirebaseAuth auth = FirebaseAuth.instance;
  bool get wantKeepAlive => true;
  int lengthOfLivefriends = 0;
  bool isSnackbarShown = false;
  List<bool?> _isSelected = List<bool?>.filled(13, false);
  bool _isWeatherInfoExpanded = false;
  List<bool> _isSelected_onlineView = [true, false];
  List<bool> _tempSelectedOnlineView = [true, false];
  bool isOnlineView = true;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _alarmStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _friendStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _bfStream;
  Stream<QuerySnapshot>? _rankingGuideUrlStream;

  Map? userRankingMap_all;

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;
  late Animation<Color?> _colorAnimation3;
  late Animation<Color?> _colorAnimation4;



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
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  //TODO: Dependency Injection**************************************************


  ListTile buildResortListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text('${resortNameList[index]}',
          style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
        ),
      ),
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
    super.initState();
    _userModelController.updateIsOnLiveOff();
    _seasonController.getSeasonOpen();
    _liveCrewModelController.getCurrrentCrew(_userModelController.liveCrew);
    _alarmStream = _streamController_ResortHome.alarmStream.value;
    _friendStream = _streamController_ResortHome.friendStream.value;
    _bfStream = _streamController_ResortHome.bfStream.value;
    _rankingGuideUrlStream = _streamController_ResortHome.rankingGuideUrlStream.value;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _colorAnimation1 = ColorTween(
      begin: SDSColor.snowliveBlue,
      end: SDSColor.blue100,
    ).animate(_controller);

    _colorAnimation2 = ColorTween(
      begin: SDSColor.blue700,
      end: SDSColor.snowliveBlue,
    ).animate(_controller);

    _colorAnimation3 = ColorTween(
      begin: SDSColor.gray300,
      end: SDSColor.gray600,
    ).animate(_controller);

    _colorAnimation4 = ColorTween(
      begin: SDSColor.gray50,
      end: SDSColor.gray300,
    ).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bottomPopUp(context);
    });

    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'visit_resortHome',
        parameters: <String, Object>{
          'user_id': _userModelController.uid!,
          'user_name': _userModelController.displayName!,
          'user_resort': _userModelController.favoriteResort!,
        },
      );
    } catch (e, stackTrace) {
      print('GA 업데이트 오류: $e');
      print('Stack trace: $stackTrace');
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                      floatingActionButton:
                      SizedBox(
                        width: _size.width - 32,
                        height: 56,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 1, bottom: 3),
                                  child:
                                  (_userModelController.isOnLive == true && _userModelController.withinBoundary ==true)
                                      ? AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: GradientBorderPainter(
                                            LinearGradient(
                                                colors: [_colorAnimation1.value!, _colorAnimation2.value!],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight
                                            )),
                                      );
                                    },
                                  )
                                      : AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: GradientBorderPainter(
                                            LinearGradient(
                                                colors: [_colorAnimation3.value!, _colorAnimation4.value!],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight
                                            )),
                                      );
                                    },
                                  )
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 3, bottom: 2, right: 2, left: 2),
                              width: _size.width - 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  (_userModelController.isOnLive == true && _userModelController.withinBoundary ==true)
                                  ? BoxShadow(
                                    color: SDSColor.snowliveBlue.withOpacity(0.5),
                                    spreadRadius: 4,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  )
                                      : BoxShadow(
                                    color: SDSColor.snowliveBlack.withOpacity(0.2),
                                    spreadRadius: 4,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: FloatingActionButton.extended(
                                  onPressed: () async {
                                    if (_userModelController.isOnLive == true) {
                                      if(!isSnackbarShown) {
                                        HapticFeedback.lightImpact();
                                        Get.dialog(
                                          WillPopScope(
                                            onWillPop: () async => false,
                                            child: AlertDialog(
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                              buttonPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                                              content:
                                              Container(
                                                width: 288,
                                                height: 80,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 8),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            '현재까지 ',
                                                            style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
                                                          ),
                                                          Text(
                                                            '56점',
                                                            style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.snowliveBlue),
                                                          ),
                                                          Text(
                                                            '을 획득했어요!',
                                                            style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      '라이브를 종료하시려면 하단에 라이브온 종료 버튼을 눌러주세요.',
                                                      style: SDSTextStyle.regular.copyWith(fontSize: 14, height: 1.4, color: SDSColor.gray600),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      width: _size.width,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: SDSColor.snowliveBlue
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          CustomFullScreenDialog.cancelDialog();
                                                          Get.back();
                                                        },
                                                        child: Text(
                                                          '계속 타기',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 16,
                                                            color: SDSColor.snowliveWhite,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Container(
                                                        width: _size.width,
                                                        height: 48,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(5),
                                                            color: SDSColor.snowliveWhite
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () async {
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
                                                            Get.back();
                                                            print('라이브 OFF');
                                                          },
                                                          child: Text(
                                                            '라이브온 종료',
                                                            style: SDSTextStyle.bold.copyWith(
                                                              fontSize: 16,
                                                              color: SDSColor.gray900,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          barrierDismissible: false,
                                        );
                                      }
                                    }
                                    else if(_userModelController.isOnLive == false) {
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
                                                                      parameters: <String, Object>{
                                                                        'user_id': _userModelController.uid!,
                                                                        'user_name': _userModelController.displayName!,
                                                                        'user_resort': _userModelController.favoriteResort!
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
                                      ? Image.asset('assets/imgs/icons/icon_live_on.png', width: 40)
                                      : Image.asset('assets/imgs/icons/icon_live_off.png', width: 40),
                                  label: (_userModelController.isOnLive == true  && _userModelController.withinBoundary ==true)
                                      ? Text(
                                        '18점',
                                        style: SDSTextStyle.extraBold.copyWith(
                                          fontSize: 16,
                                          letterSpacing: -0.1,
                                          color: SDSColor.snowliveWhite,
                                        ),
                                      )
                                      : Text(
                                        '라이브온하기',
                                        style: SDSTextStyle.extraBold.copyWith(
                                            fontSize: 16,
                                            letterSpacing: -0.1,
                                            color: SDSColor.snowliveWhite,
                                        ),
                                      ),
                                  backgroundColor: (_userModelController.isOnLive == true  && _userModelController.withinBoundary ==true) ? SDSColor.gray800  : SDSColor.gray800),
                            ),

                          ],
                        ),
                      ),
                      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                      backgroundColor: Colors.white,
                      extendBodyBehindAppBar: true,
                      appBar: PreferredSize(
                        preferredSize: Size.fromHeight(44),
                        child: AppBar(
                          actions: [
                            // (_userModelController.isOnLive == true)
                            // ? Padding(
                            //   padding: const EdgeInsets.only(top: 8, bottom: 8, right: 10),
                            //   child: GestureDetector(
                            //     onTap: () {
                            //       _tempSelectedOnlineView = List.from(_isSelected_onlineView); // 기존 선택 상태를 임시 상태에 복사
                            //       showModalBottomSheet(
                            //         context: context,
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.vertical(
                            //             top: Radius.circular(20),
                            //           ),
                            //         ),
                            //         builder: (context) {
                            //           return StatefulBuilder(
                            //             builder: (BuildContext context, StateSetter setModalState) {
                            //               return Container(
                            //                 height: 370,
                            //                 decoration: BoxDecoration(
                            //                   borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                            //                   color: SDSColor.snowliveWhite,
                            //                 ),
                            //                 padding: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
                            //                 child: Column(
                            //                   crossAxisAlignment: CrossAxisAlignment.center,
                            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //                   children: [
                            //                     Padding(
                            //                       padding: const EdgeInsets.only(bottom: 20),
                            //                       child: Container(
                            //                         height: 4,
                            //                         width: 36,
                            //                         decoration: BoxDecoration(
                            //                           borderRadius: BorderRadius.circular(10),
                            //                           color: SDSColor.gray200,
                            //                         ),
                            //                       ),
                            //                     ),
                            //                     Text(
                            //                       '온라인 상태를 선택해 주세요',
                            //                       style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                            //                     ),
                            //                     SizedBox(height: 8),
                            //                     Text(
                            //                       '라이브온 상태와 상관없이 다른 사람에게 보여지는 \n내 라이브 표시를 자유롭게 온/오프할 수 있어요',
                            //                       style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500, height: 1.4),
                            //                       textAlign: TextAlign.center,
                            //                     ),
                            //                     SizedBox(height: 24),
                            //                     Expanded(
                            //                       child: ListView(
                            //                         shrinkWrap: true,
                            //                         children: [
                            //                           ListTile(
                            //                             contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            //                             trailing: _tempSelectedOnlineView[0]
                            //                                 ? Image.asset(
                            //                               'assets/imgs/icons/icon_check_filled.png',
                            //                               width: 24,
                            //                               height: 24,
                            //                             )
                            //                                 : Image.asset(
                            //                               'assets/imgs/icons/icon_check_unfilled.png',
                            //                               width: 24,
                            //                               height: 24,
                            //                             ),
                            //                             title: Row(
                            //                               children: [
                            //                                 Container(
                            //                                   width: 8,
                            //                                   height: 8,
                            //                                   decoration: BoxDecoration(
                            //                                     borderRadius: BorderRadius.circular(20),
                            //                                     color: SDSColor.snowliveBlue,
                            //                                   ),
                            //                                 ),
                            //                                 Padding(
                            //                                   padding: const EdgeInsets.only(left: 10),
                            //                                   child: Text(
                            //                                     '온라인으로 표시',
                            //                                     style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                            //                                   ),
                            //                                 ),
                            //                               ],
                            //                             ),
                            //                             selected: _tempSelectedOnlineView[0],
                            //                             onTap: () {
                            //                               setModalState(() {
                            //                                 _tempSelectedOnlineView = [true, false];
                            //                               });
                            //                             },
                            //                           ),
                            //                           ListTile(
                            //                             contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            //                             trailing: _tempSelectedOnlineView[1]
                            //                                 ? Image.asset(
                            //                               'assets/imgs/icons/icon_check_filled.png',
                            //                               width: 24,
                            //                               height: 24,
                            //                             )
                            //                                 : Image.asset(
                            //                               'assets/imgs/icons/icon_check_unfilled.png',
                            //                               width: 24,
                            //                               height: 24,
                            //                             ),
                            //                             title: Row(
                            //                               children: [
                            //                                 Container(
                            //                                   width: 8,
                            //                                   height: 8,
                            //                                   decoration: BoxDecoration(
                            //                                     borderRadius: BorderRadius.circular(20),
                            //                                     color: SDSColor.gray500,
                            //                                   ),
                            //                                 ),
                            //                                 Padding(
                            //                                   padding: const EdgeInsets.only(left: 10),
                            //                                   child: Text(
                            //                                     '오프라인으로 표시',
                            //                                     style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                            //                                   ),
                            //                                 ),
                            //                               ],
                            //                             ),
                            //                             selected: _tempSelectedOnlineView[1],
                            //                             onTap: () {
                            //                               setModalState(() {
                            //                                 _tempSelectedOnlineView = [false, true];
                            //                               });
                            //                             },
                            //                           ),
                            //                         ],
                            //                       ),
                            //                     ),
                            //                     SafeArea(
                            //                       child: Container(
                            //                         width: _size.width,
                            //                         padding: EdgeInsets.only(top: 16),
                            //                         child: ElevatedButton(
                            //                           onPressed: () {
                            //                             setState(() {
                            //                               _isSelected_onlineView = List.from(_tempSelectedOnlineView);
                            //                               isOnlineView = _isSelected_onlineView[0];
                            //                             });
                            //                             Navigator.pop(context);
                            //                           },
                            //                           child: Text(
                            //                             '표시 상태 저장하기',
                            //                             style: SDSTextStyle.bold.copyWith(color: Colors.white, fontSize: 16),
                            //                           ),
                            //                           style: TextButton.styleFrom(
                            //                             shape: const RoundedRectangleBorder(
                            //                                 borderRadius: BorderRadius.all(
                            //                                     Radius.circular(6)
                            //                                 )
                            //                             ),
                            //                             elevation: 0,
                            //                             splashFactory: InkRipple.splashFactory,
                            //                             minimumSize: Size(double.infinity, 48),
                            //                             backgroundColor: SDSColor.snowliveBlue,
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               );
                            //             },
                            //           );
                            //         },
                            //       );
                            //     },
                            //     child: Container(
                            //       height: 24,
                            //       padding: EdgeInsets.symmetric(horizontal: 8),
                            //       decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(20),
                            //         border: Border.all(color: SDSColor.gray200),
                            //       ),
                            //       child: Row(
                            //         children: [
                            //           Container(
                            //             width: 8,
                            //             height: 8,
                            //             decoration: BoxDecoration(
                            //               borderRadius: BorderRadius.circular(20),
                            //               color: isOnlineView ? SDSColor.snowliveBlue : SDSColor.gray500,
                            //             ),
                            //           ),
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 4),
                            //             child: Text(
                            //               isOnlineView ? '온라인' : '오프라인',
                            //               style: SDSTextStyle.regular.copyWith(
                            //                 color: SDSColor.gray700,
                            //                 fontSize: 13,
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // )
                            // : Container(),
                            SizedBox(
                              width: 36,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                            stream: _friendStream,
                                            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                              if (!snapshot.hasData) {
                                                return Container(
                                                  color: Colors.white,
                                                  height: MediaQuery.of(context).size.height * 0.5,
                                                  child: Center(
                                                    child: CircularProgressIndicator(),
                                                  ),
                                                );
                                              }

                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Container(
                                                  color: Colors.white,
                                                  height: MediaQuery.of(context).size.height * 0.5,
                                                  child: Center(
                                                    child: CircularProgressIndicator(),
                                                  ),
                                                );
                                              }

                                              final bestfriendDocs = snapshot.data!.docs;

                                              double initialHeight = bestfriendDocs.length < 5
                                                  ? 0.38
                                                  : 0.525;

                                              return DraggableScrollableSheet(
                                                initialChildSize: initialHeight,
                                                minChildSize: 0.2,
                                                maxChildSize: 0.88,
                                                expand: false,
                                                builder: (context, scrollController) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                                      color: SDSColor.snowliveWhite,
                                                    ),
                                                    padding: EdgeInsets.only(right: 20, left: 20, top: 12),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 20),
                                                          child: Container(
                                                            height: 4,
                                                            width: 36,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: SDSColor.gray200,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          '라이브중인 친구',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                                        ),
                                                        SizedBox(height: 24),
                                                        Expanded(
                                                          child:
                                                          bestfriendDocs.isEmpty
                                                              ? Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(bottom: 24),
                                                              child: Text(
                                                                '친구 관리로 이동해 즐겨찾는 친구를 등록해 주세요.\n라이브중인 친구를 바로 확인하실 수 있어요.',
                                                                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500, height: 1.4),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          )
                                                          : Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                                            child: GridView.builder(
                                                              controller: scrollController,
                                                              shrinkWrap: true,
                                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount: 4,
                                                                crossAxisSpacing: 14,
                                                                mainAxisSpacing: 28,
                                                                childAspectRatio: 3 / 4,
                                                              ),
                                                              itemCount: bestfriendDocs.length,
                                                              itemBuilder: (context, index) {
                                                                var BFdoc = bestfriendDocs[index];
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    Get.to(() => FriendDetailPage(
                                                                      uid: BFdoc.get('uid'),
                                                                      favoriteResort: BFdoc.get('favoriteResort'),
                                                                    ));
                                                                  },
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Stack(
                                                                        children: [
                                                                          Container(
                                                                            width: 68,
                                                                            height: 68,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(100),
                                                                              border: (BFdoc.get('isOnLive') == true)
                                                                                  ? Border.all(
                                                                                color: SDSColor.snowliveBlue,
                                                                                width: 2,
                                                                              )
                                                                                  : Border.all(
                                                                                color: SDSColor.gray100,
                                                                                width: 1,
                                                                              ),
                                                                            ),
                                                                            alignment: Alignment.center,
                                                                            child: BFdoc.get('profileImageUrl').isNotEmpty
                                                                                ? ExtendedImage.network(
                                                                              BFdoc.get('profileImageUrl'),
                                                                              enableMemoryCache: true,
                                                                              shape: BoxShape.circle,
                                                                              borderRadius: BorderRadius.circular(100),
                                                                              width: 68,
                                                                              height: 68,
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
                                                                                      borderRadius: BorderRadius.circular(100),
                                                                                      width: 68,
                                                                                      height: 68,
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
                                                                              borderRadius: BorderRadius.circular(100),
                                                                              width: 68,
                                                                              height: 68,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                          if (BFdoc.get('isOnLive') == true)
                                                                            Positioned(
                                                                              right: 0,
                                                                              bottom: 0,
                                                                              child: Image.asset(
                                                                                'assets/imgs/icons/icon_badge_live.png',
                                                                                width: 32,
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 6),
                                                                      Container(
                                                                        width: 72,
                                                                        child: Text(
                                                                          BFdoc.get('displayName'),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          textAlign: TextAlign.center,
                                                                          style: TextStyle(
                                                                            fontSize: 12,
                                                                            fontWeight: FontWeight.normal,
                                                                            color: Color(0xFF111111),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        SafeArea(
                                                          child: Container(
                                                            width: MediaQuery.of(context).size.width,
                                                            padding: EdgeInsets.only(top: 16, bottom: 20),
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                Get.to(() => FriendListPage());
                                                              },
                                                              child: Text(
                                                                '친구 관리 바로가기',
                                                                style: SDSTextStyle.bold.copyWith(color: SDSColor.gray700, fontSize: 16),
                                                              ),
                                                              style: TextButton.styleFrom(
                                                                shape: const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                ),
                                                                elevation: 0,
                                                                splashFactory: InkRipple.splashFactory,
                                                                minimumSize: Size(double.infinity, 48),
                                                                backgroundColor: SDSColor.gray100,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                icon: Image.asset(
                                  'assets/imgs/icons/icon_friend_resortHome.png',
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 12),
                              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                stream: _alarmStream,
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                  if (!snapshot.hasData || snapshot.data == null) {
                                    return  Stack(
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
                                          icon: Image.asset(
                                            'assets/imgs/icons/icon_alarm_resortHome.png',
                                            width: 28,
                                            height: 28,
                                          ),
                                        ),
                                        Positioned(  // draw a red marble
                                          top: 10,
                                          left: 32,
                                          child: new Icon(Icons.brightness_1, size: 6.0,
                                              color:Colors.transparent),
                                        )
                                      ],
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
                                    return  Stack(
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
                                          icon: Image.asset(
                                            'assets/imgs/icons/icon_alarm_resortHome.png',
                                            width: 28,
                                            height: 28,
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
                                                : Container()
                                        )
                                      ],
                                    );
                                  }
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return  Stack(
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
                                          icon: Image.asset(
                                            'assets/imgs/icons/icon_alarm_resortHome.png',
                                            width: 28,
                                            height: 28,
                                          ),
                                        ),
                                        Positioned(  // draw a red marble
                                          top: 2,
                                          left: 0,
                                          child: new Icon(Icons.brightness_1, size: 6.0,
                                              color:Colors.white),
                                        )
                                      ],
                                    );
                                  }
                                  return  Stack(
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
                                        icon: Image.asset(
                                          'assets/imgs/icons/icon_alarm_resortHome.png',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                      Positioned(  // draw a red marble
                                        top: 0,
                                        left: 32,
                                        child: new Icon(Icons.brightness_1, size: 6.0,
                                            color:Colors.white),
                                      )
                                    ],
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
                              height: 38,
                            )
                                : Image.asset(
                              'assets/imgs/logos/snowliveLogo_main_new.png',
                              height: 38,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          elevation: 0.0,
                        ),
                      ),
                      body: RefreshIndicator(
                        strokeWidth: 2,
                        edgeOffset: 20,
                        onRefresh: _refreshController.onRefresh_resortHome,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: _statusBarSize + 56,
                              ),
                              Container(
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Obx(() => Padding(
                                      padding: EdgeInsets.only(left: 16, right: 16),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(16),
                                              color: (_resortModelController.isLoading == true)
                                                  ? SDSColor.gray200
                                                  : _resortModelController.weatherColors),
                                          alignment: Alignment.center,
                                          width: double.infinity,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 18),
                                                child: Row(
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
                                                                    style: SDSTextStyle.bold.copyWith(
                                                                        color: SDSColor.snowliveWhite,
                                                                        fontSize: 17),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Image.asset(
                                                                  'assets/imgs/icons/icon_dropdown.png',
                                                                  width: 18,
                                                                  height: 18,
                                                                  color: SDSColor.snowliveWhite,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            showModalBottomSheet(
                                                                isScrollControlled: true,
                                                                shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.vertical(
                                                                top: Radius.circular(16),
                                                                ),
                                                                ),
                                                                enableDrag: false,
                                                                context: context,
                                                                builder: (context) {
                                                                  return Container(
                                                                    height: _size.height - 110,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                                                      color: SDSColor.snowliveWhite,
                                                                    ),
                                                                    padding: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(bottom: 20),
                                                                          child: Container(
                                                                            height: 4,
                                                                            width: 36,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              color: SDSColor.gray200,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '자주가는 스키장을 선택해 주세요.',
                                                                          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                                                        ),
                                                                        SizedBox(height: 8),
                                                                        Text(
                                                                          '관심있는 스키장을 선택해 스키장과 관련된 실시간 날씨 정보와 웹캠, 슬로프 오픈 현황 등을 확인하세요.',
                                                                          style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500, height: 1.4),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                        SizedBox(height: 24),
                                                                        Expanded(
                                                                          child: ListView.builder(
                                                                              padding: EdgeInsets.zero,
                                                                              itemCount: 13,
                                                                              itemBuilder: (context, index) {
                                                                                return Builder(builder: (context) {
                                                                                  return Column(
                                                                                    children: [
                                                                                      buildResortListTile(index),
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
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                      color: SDSColor.snowliveWhite.withOpacity(0.6),
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
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        (_resortModelController.isLoading == true)
                                                        ? Container()
                                                        : Padding(
                                                          padding: const EdgeInsets.only(bottom: 2),
                                                          child: Container(
                                                              width: 32,
                                                              child: _resortModelController.weatherIcons),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Obx(() => (_resortModelController.isLoading == true)
                                                                  ? Padding(
                                                                    padding: const EdgeInsets.only(right: 16),
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
                                                          padding: const EdgeInsets.only(right: 10),
                                                          child: Obx(
                                                                () => (_resortModelController.isLoading == true)
                                                                    ? Text(' ',
                                                                  style: GoogleFonts.bebasNeue(
                                                                      fontSize: 48,
                                                                      color: Colors.white),
                                                                )
                                                                    : Padding(
                                                                      padding: const EdgeInsets.only(bottom: 4, left: 2),
                                                                      child: Text('\u00B0',
                                                                  style: GoogleFonts.bebasNeue(
                                                                        fontSize: 36,
                                                                        color: Colors.white),
                                                                ),
                                                                    ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: (){
                                                            setState(() {
                                                              if(_isWeatherInfoExpanded == false){
                                                                _isWeatherInfoExpanded = true;
                                                              } else{
                                                                _isWeatherInfoExpanded = false;
                                                              }
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(bottom: 2, right: 20),
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
                                              ),
                                              if(_isWeatherInfoExpanded == true)
                                              SizedBox(
                                                height: 16,
                                              ),
                                              if(_isWeatherInfoExpanded == true)
                                              (_resortModelController.isLoading == true)
                                              ? Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                child: Container(
                                                  color: SDSColor.gray500.withOpacity(0.1),
                                                  height: 1,
                                                  width: _size.width,
                                                ),
                                              )
                                              : Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                                child: Container(
                                                  color: SDSColor.snowliveBlack.withOpacity(0.1),
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
                                                        style: SDSTextStyle.regular.copyWith(
                                                            color: SDSColor.snowliveWhite.withOpacity(0.6),
                                                            fontSize: 12),
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Obx(() => Padding(
                                                              padding:
                                                              const EdgeInsets.only(right: 2),
                                                              child: Text(
                                                                '${_resortModelController.resortWind}',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 24,
                                                                    color: SDSColor.snowliveWhite),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets.only(bottom: 3),
                                                            child: Text('M/S',
                                                              style: GoogleFonts.bebasNeue(
                                                                  fontSize: 16,
                                                                  color: SDSColor.snowliveWhite),
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
                                                        style: SDSTextStyle.regular.copyWith(
                                                            color: SDSColor.snowliveWhite.withOpacity(0.6),
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
                                                              const EdgeInsets.only(right: 2),
                                                              child: Text(
                                                                '${_resortModelController.resortWet}',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 24,
                                                                    color: SDSColor.snowliveWhite),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets.only(bottom: 3),
                                                            child: Text('%',
                                                              style: GoogleFonts.bebasNeue(
                                                                  fontSize: 16,
                                                                  color: SDSColor.snowliveWhite),
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
                                                        style: SDSTextStyle.regular.copyWith(
                                                            color: SDSColor.snowliveWhite.withOpacity(0.6),
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
                                                              padding: const EdgeInsets.only(right: 2),
                                                              child: Text('${_resortModelController.resortRain}',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 24,
                                                                    color: SDSColor.snowliveWhite),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets.only(bottom: 3),
                                                            child: Text('MM',
                                                              style: GoogleFonts.bebasNeue(
                                                                  fontSize: 16,
                                                                  color: SDSColor.snowliveWhite),
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
                                                        style: SDSTextStyle.regular.copyWith(
                                                            color: SDSColor.snowliveWhite.withOpacity(0.6),
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
                                                                  color: SDSColor.snowliveWhite),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(
                                                                  bottom: 3, left: 3, right: 2),
                                                              child: Text(
                                                                '/',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 16,
                                                                    color: SDSColor.snowliveWhite),
                                                              ),
                                                            ),
                                                            Text(
                                                              '${_resortModelController.resortMaxTemp}',
                                                              style: GoogleFonts.bebasNeue(
                                                                  fontSize: 24,
                                                                  color: SDSColor.snowliveWhite),
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
                                                height: 16,
                                              )
                                            ],
                                          ),
                                        ),
                                    ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,),
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 28, left: 28, top: 24, bottom: 30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    _urlLauncherController.otherShare(contents: '${_resortModelController.naverUrl}');
                                                  },
                                                  child: Container(
                                                    width: 64,
                                                    child: Column(
                                                      children: [
                                                        Image.asset(
                                                          'assets/imgs/icons/icon_home_naver.png',
                                                          width: 32,
                                                          height: 32,
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          '네이버 날씨',
                                                          style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 12,
                                                              color: SDSColor.gray800),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (_resortModelController.webcamUrl != '') {
                                                      _urlLauncherController.otherShare(contents: '${_resortModelController.webcamUrl}');
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 64,
                                                    child: Column(
                                                      children: [
                                                        (_resortModelController.webcamUrl != '')
                                                            ? Image.asset(
                                                          'assets/imgs/icons/icon_home_livecam.png',
                                                          width: 32,
                                                          height: 32,
                                                        )
                                                            : Image.asset(
                                                          'assets/imgs/icons/icon_home_livecam_off.png',
                                                          width: 32,
                                                          height: 32,
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          '실시간 웹캠',
                                                          style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 12,
                                                              color:
                                                              (_resortModelController.webcamUrl != '')
                                                              ? SDSColor.gray800 : SDSColor.gray400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (_resortModelController.slopeUrl != '') {
                                                      _urlLauncherController.otherShare(contents: '${_resortModelController.slopeUrl}');
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 64,
                                                    child: Column(
                                                      children: [
                                                        (_resortModelController.slopeUrl != '')
                                                            ? Image.asset(
                                                          'assets/imgs/icons/icon_home_slope.png',
                                                          width: 32,
                                                          height: 32,
                                                        )
                                                            : Image.asset(
                                                          'assets/imgs/icons/icon_home_slope_off.png',
                                                          width: 32,
                                                          height: 32,
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          '슬로프 현황',
                                                          style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 12,
                                                              color:
                                                              (_resortModelController.slopeUrl != '')
                                                                  ? SDSColor.gray800 : SDSColor.gray400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (_resortModelController.busUrl != '') {
                                                      _urlLauncherController.otherShare(contents: '${_resortModelController.busUrl}');
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 64,
                                                    child: Column(
                                                      children: [
                                                        (_resortModelController.busUrl != '')
                                                            ? Image.asset(
                                                          'assets/imgs/icons/icon_home_bus.png',
                                                          width: 32,
                                                          height: 32,
                                                        )
                                                            : Image.asset(
                                                          'assets/imgs/icons/icon_home_bus_off.png',
                                                          width: 32,
                                                          height: 32,
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          '셔틀버스',
                                                          style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 12,
                                                              color:
                                                              (_resortModelController.busUrl != '')
                                                                  ? SDSColor.gray800 : SDSColor.gray400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 30, left: 16, right: 16),
                                          child: Banner_resortHome(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 30),
                                          child: Container(
                                            width: _size.width,
                                            height: 10,
                                            color: SDSColor.gray50,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 16, right: 16),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
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

                                                            Map<String, dynamic>? passCountData = rankingDocs[0]['passCountData'] as Map<String, dynamic>?;
                                                            Map<String, dynamic>? passCountTimeData = rankingDocs[0]['passCountTimeData'] as Map<String, dynamic>?;
                                                            List<Map<String, dynamic>> barData = _liveMapController.calculateBarDataPassCount(passCountData);
                                                            List<Map<String, dynamic>> barData2 = _liveMapController.calculateBarDataSlot(passCountTimeData);

                                                            String? lastPassTimeString;

                                                            Timestamp lastPassTime = rankingDocs[0]['lastPassTime'];
                                                            lastPassTimeString = _timeStampController.getAgoTime(lastPassTime);

                                                            return Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 4, left: 4),
                                                                  child: Text('오늘의 기록',
                                                                    style: SDSTextStyle.extraBold.copyWith(
                                                                        fontSize: 15,
                                                                        color: SDSColor.gray900
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 16),
                                                                  child: Container(
                                                                    padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                                                    width: _size.width,
                                                                    decoration: BoxDecoration(
                                                                      color: SDSColor.blue50,
                                                                      borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text('${barData[0]['slopeName']}',
                                                                        style: SDSTextStyle.regular.copyWith(
                                                                          color: SDSColor.gray900.withOpacity(0.5),
                                                                          fontSize: 14
                                                                        ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(top: 4, bottom: 20),
                                                                          child: Text('${barData[0]['passCount']}회',
                                                                            style: SDSTextStyle.extraBold.copyWith(
                                                                                color: SDSColor.gray900,
                                                                                fontSize: 24
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: barData.asMap().entries.map((entry) {
                                                                              int index = entry.key;
                                                                              Map<String, dynamic> data = entry.value;

                                                                              String slopeName = data['slopeName'];
                                                                              int passCount = data['passCount'];
                                                                              double barWidthRatio = data['barHeightRatio'];
                                                                              Color barColor = data['barColor'];
                                                                              return Padding(
                                                                                padding: (index != barData.length - 1) ? EdgeInsets.only(bottom: 8) : EdgeInsets.only(bottom: 0),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Container(
                                                                                      width: 40,
                                                                                      child: Text(
                                                                                        slopeName,
                                                                                        style: SDSTextStyle.bold.copyWith(
                                                                                            fontSize: 11,
                                                                                            color: SDSColor.gray900,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      height: 16,
                                                                                      width:  (_size.width - 148) * barWidthRatio,
                                                                                      decoration: BoxDecoration(
                                                                                          color: barColor,
                                                                                          borderRadius: BorderRadius.only(
                                                                                              topRight: Radius.circular(4),
                                                                                              bottomRight: Radius.circular(4)
                                                                                          )
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: (index == 0) ? EdgeInsets.only(left: 6) : EdgeInsets.only(left: 2),
                                                                                      child: Container(
                                                                                        width: 30,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            Container(
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(20),
                                                                                                color: (index == 0) ? SDSColor.gray900 : Colors.transparent,
                                                                                              ),
                                                                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                                                              child: Text(
                                                                                                passCount != 0 ? '$passCount' : '',
                                                                                                style: SDSTextStyle.extraBold.copyWith(
                                                                                                  fontSize: 12,
                                                                                                  fontWeight: (index == 0) ? FontWeight.w900 : FontWeight.w300,
                                                                                                  color: (index == 0) ? SDSColor.snowliveWhite : SDSColor.gray900.withOpacity(0.4),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }).toList(),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),

                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 16),
                                                                  child: Container(
                                                                    padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                                                    width: _size.width,
                                                                    decoration: BoxDecoration(
                                                                      color: SDSColor.blue50,
                                                                      borderRadius: BorderRadius.circular(16),
                                                                    ),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text('오늘 총 라이딩 횟수',
                                                                              style: SDSTextStyle.regular.copyWith(
                                                                                  color: SDSColor.gray900.withOpacity(0.5),
                                                                                  fontSize: 14
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 4, bottom: 20),
                                                                              child: Text('${rankingDocs[0]['totalPassCount']}회',
                                                                                style: SDSTextStyle.extraBold.copyWith(
                                                                                    color: SDSColor.gray900,
                                                                                    fontSize: 24
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Container(
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                                            children: barData2.map((data) {
                                                                              String slotName = data['slotName'];
                                                                              int passCount = data['passCount'];
                                                                              double barHeightRatio = data['barHeightRatio'];
                                                                              Color barColor = data['barColor'];
                                                                              int maxPassCount = barData2.map((data) => data['passCount']).reduce((a, b) => a > b ? a : b);

                                                                              return Container(
                                                                                width: 30,
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                  children: [
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(20),
                                                                                        color: passCount == maxPassCount ? SDSColor.gray900 : Colors.transparent,
                                                                                      ),
                                                                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                                                      child: AutoSizeText(
                                                                                        passCount != 0 ? '$passCount' : '',
                                                                                        style: SDSTextStyle.bold.copyWith(
                                                                                          fontSize: 12,
                                                                                          color: passCount == maxPassCount ? SDSColor.snowliveWhite : SDSColor.gray900.withOpacity(0.4),
                                                                                          fontWeight: passCount == maxPassCount ? FontWeight.w900 : FontWeight.w300,
                                                                                        ),
                                                                                        minFontSize: 6,
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.visible,
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: EdgeInsets.only(top: passCount == maxPassCount ? 6 : 0),
                                                                                      child: Container(
                                                                                        width: 16,
                                                                                        height: 140 * barHeightRatio,
                                                                                        decoration: BoxDecoration(
                                                                                            color: barColor,
                                                                                            borderRadius: BorderRadius.only(
                                                                                                topRight: Radius.circular(4), topLeft: Radius.circular(4)
                                                                                            )
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 8),
                                                                                      child: Container(
                                                                                        width: 20,
                                                                                        child: Text(
                                                                                          _resortModelController.getSlotName(slotName),
                                                                                          style: SDSTextStyle.regular.copyWith(
                                                                                            fontSize: 11,
                                                                                            color: SDSColor.gray900,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }).toList(),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),

                                                              ],
                                                            );
                                                          }
                                                          return Container();
                                                        },
                                                      );
                                                    } else {
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
                                                                    style: SDSTextStyle.bold.copyWith(
                                                                      fontSize: 18,
                                                                      color: SDSColor.gray900,
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 10),
                                                                    child: Text(
                                                                      '친구들의 라이브 상태도 확인하고',
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                        fontSize: 14,
                                                                        color: SDSColor.gray600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 4),
                                                                    child: Text(
                                                                      '다른 유저들과 경쟁해보세요!',
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                        fontSize: 14,
                                                                        color: SDSColor.gray600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 20),
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        // Add your share functionality here
                                                                      },
                                                                      child: Container(
                                                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                                                        decoration: BoxDecoration(
                                                                          color: SDSColor.snowliveWhite,
                                                                          borderRadius: BorderRadius.circular(20),
                                                                        ),
                                                                        child: Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(right: 6),
                                                                              child: Text(
                                                                                '더 알아보기',
                                                                                style: SDSTextStyle.extraBold.copyWith(
                                                                                    color: Colors.black,
                                                                                    fontSize: 13
                                                                                ),
                                                                              ),
                                                                            ),
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
                                                                style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 18,
                                                                  color: SDSColor.gray900,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 10),
                                                                child: Text(
                                                                  '친구들의 라이브 상태도 확인하고',
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                    fontSize: 14,
                                                                    color: SDSColor.gray600,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 4),
                                                                child: Text(
                                                                  '다른 유저들과 경쟁해보세요!',
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                    fontSize: 14,
                                                                    color: SDSColor.gray600,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 20),
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    // Add your share functionality here
                                                                  },
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                                                    decoration: BoxDecoration(
                                                                      color: SDSColor.snowliveWhite,
                                                                      borderRadius: BorderRadius.circular(20),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(right: 6),
                                                                          child: Text(
                                                                            '더 알아보기',
                                                                            style: SDSTextStyle.extraBold.copyWith(
                                                                                color: Colors.black,
                                                                                fontSize: 13
                                                                            ),
                                                                          ),
                                                                        ),
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
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 40, bottom: 30),
                                          child: Container(
                                            width: _size.width,
                                            height: 10,
                                            color: SDSColor.gray50,
                                          ),
                                        ),
                                        

                                      ],
                                    ),
                                    SizedBox(
                                      height: 100,
                                    ),
                                  ],
                                ),
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
