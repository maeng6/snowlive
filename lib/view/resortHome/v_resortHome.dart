import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/view/banner/v_banner_resortHome.dart';
import 'package:com.snowlive/view/resortHome/v_chat_resortHome.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_alarmCenter.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_setGenderAndCategory.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:com.snowlive/widget/w_liveOn_animatedGradient.dart';
import 'package:com.snowlive/widget/w_selectResort.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';

import '../banner/v_banner_treasureHunt.dart';

class ResortHomeView extends StatefulWidget {
  @override
  State<ResortHomeView> createState() => _ResortHomeViewState();
}

class _ResortHomeViewState extends State<ResortHomeView> with
    AutomaticKeepAliveClientMixin,
    SingleTickerProviderStateMixin{

  bool get wantKeepAlive => true;
  int? selectedIndex;

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;
  late Animation<Color?> _colorAnimation3;
  late Animation<Color?> _colorAnimation4;



  //TODO: Dependency Injection**************************************************
  ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  GenderCategoryViewModel _genderCategoryViewModel = Get.find<GenderCategoryViewModel>();
  AlarmCenterViewModel _alarmCenterViewModel = Get.find<AlarmCenterViewModel>();
  //TODO: Dependency Injection**************************************************

  @override
  void initState() {
    super.initState();

    print('내 유저아이디 : ${_userViewModel.user.user_id}');
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _colorAnimation1 = ColorTween(
      begin: SDSColor.snowliveBlue,
      end: SDSColor.blue100,
    ).animate(_controller);

    _colorAnimation2 = ColorTween(
      begin: Color(0xFF0066FF),
      end: SDSColor.snowliveBlue,
    ).animate(_controller);

    _colorAnimation3 = ColorTween(
      begin: Color(0xFFEA3A2F),
      end: Color(0xFFEA3A2F),
    ).animate(_controller);

    _colorAnimation4 = ColorTween(
      begin: Color(0xFFEA3A2F),
      end: Color(0xFFEA3A2F),
    ).animate(_controller);

    // 성별과 종목 선택 팝업을 뷰모델을 통해 호출
    if(_userViewModel.user.sex == null ||
        _userViewModel.user.skiorboard == null
    ){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _genderCategoryViewModel.showGenderAndCategoryPopup();
      });
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

    return WillPopScope(
        onWillPop: () {
          return Future(() => false);
        },
        child: Obx(()=>Scaffold(
          floatingActionButton:
          (_friendDetailViewModel.isDateWithinSeason(DateTime.now()) == true)
              ?SizedBox(
            width: _size.width - 32,
            height: 56,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 3),
                      child:
                      (_userViewModel.user.within_boundary == true)
                          ? (_resortHomeViewModel.resort_info['fullname'] != null) ? AnimatedBuilder(
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
                      ) : AnimatedBuilder(
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
                          : AnimatedBuilder(
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
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 3, bottom: 5, right: 2, left: 2),
                  width: _size.width - 32,
                  decoration: BoxDecoration(
                    boxShadow: [
                      (_userViewModel.user.within_boundary == true)
                          ? BoxShadow(
                        color: SDSColor.snowliveBlack.withOpacity(0.2),
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
                  child: Obx(()=>ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: FloatingActionButton.extended(
                        onPressed: () async {
                          if (_userViewModel.user.within_boundary == true &&
                              _resortHomeViewModel.resort_info['fullname'] != null) {
                            HapticFeedback.lightImpact();
                            Get.dialog(
                              WillPopScope(
                                onWillPop: () async => false,
                                child: AlertDialog(
                                  backgroundColor: SDSColor.snowliveWhite,
                                  contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  buttonPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                                  content:
                                  Container(
                                    width: 288,
                                    height: 190,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/imgs/imgs/img_get_point_1.png',
                                          scale: 4,
                                          width: 100,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20, bottom: 6),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '오늘 ',
                                                style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
                                              ),
                                              Text(
                                                '${_resortHomeViewModel.resortHomeModel.todayTotalScore.round()}',
                                                style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.snowliveBlue),
                                              ),
                                              Text(
                                                '점을 획득했어요!',
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
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Column(
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
                                                  CustomFullScreenDialog.showDialog();
                                                  await _resortHomeViewModel.liveOff({
                                                    "user_id":_userViewModel.user.user_id
                                                  }, _userViewModel.user.user_id);
                                                  CustomFullScreenDialog.cancelDialog();
                                                  Get.back();
                                                  await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
                                                  await _resortHomeViewModel.stopForegroundLocationService();
                                                  await _resortHomeViewModel.stopBackgroundLocationService();
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
                                    ),
                                  ],
                                ),
                              ),
                              barrierDismissible: false,
                            );
                          }
                          else if (_userViewModel.user.within_boundary == true &&
                              _resortHomeViewModel.resort_info['fullname'] == null) {
                            HapticFeedback.lightImpact();
                            Get.dialog(
                              WillPopScope(
                                onWillPop: () async => false,
                                child: AlertDialog(
                                  backgroundColor: SDSColor.snowliveWhite,
                                  contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  buttonPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                                  content:
                                  Container(
                                    width: 288,
                                    height: 250,
                                    child: Container(
                                      width: 232,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 16),
                                            child: Image.asset(
                                              'assets/imgs/imgs/img_error_1.png',
                                              scale: 4,
                                              width: 140,
                                            ),
                                          ),
                                          Text('라이브를 재시작 또는 종료해 주세요',
                                            style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                            textAlign: TextAlign.center,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Text(
                                              '라이브가 켜져 있는 상태에서 앱이 강제 종료되어서, 위치 서비스가 멈췄어요! 라이브를 다시 시작하거나 종료해 주세요.',
                                              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    Container(
                                      width: _size.width,
                                      height: 48,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: SDSColor.snowliveBlue
                                      ),
                                      child: TextButton(
                                        onPressed: () async{

                                          // 위치 서비스 권한 확인(안드만 실행되게 함)
                                          if (Platform.isAndroid) {
                                            // 위치 서비스 권한 확인 (안드로이드에서만 실행)
                                            final status = await Permission.locationAlways.status;
                                            if (status != PermissionStatus.granted) {
                                              // 위치 서비스 항상 허용이 아닐 경우 팝업 표시
                                              await _resortHomeViewModel.showSettingsPopup(
                                                title: '권한 필요',
                                                message: '위치 서비스를 항상 허용으로 설정해야 라이브 기능을 사용할 수 있습니다.',
                                                action: () => openAppSettings(),
                                              );
                                              return; // 이후 코드 실행 중단
                                            }
                                          }
                                          // 배터리 절약 모드(절전 모드) 확인
                                          final isBatterySaverOn = await _resortHomeViewModel.isBatterySaverOn();
                                          if (isBatterySaverOn) {
                                            // 배터리 절약 모드가 켜져 있을 경우 팝업 표시
                                            await _resortHomeViewModel.showSettingsPopup(
                                              title: '배터리 절약 모드 감지',
                                              message: '배터리 절약 모드를 비활성화해야 라이브 기능을 사용할 수 있습니다.',
                                              action: () async {
                                                await _resortHomeViewModel.navigateToBatterySettings();
                                              },
                                            );
                                            return; // 이후 코드 실행 중단
                                          }

                                          HapticFeedback.lightImpact();
                                          CustomFullScreenDialog.showDialog();
                                          await _resortHomeViewModel.startLiveLocationService(user_id: _userViewModel.user.user_id);
                                          await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
                                          CustomFullScreenDialog.cancelDialog();
                                          Get.back();
                                          if (_userViewModel.user.crew_id != null) {
                                            await _resortHomeViewModel.checkAndShowTreasureHuntPopup(
                                              userId: _userViewModel.user.user_id!,
                                              userCrewId: _userViewModel.user.crew_id,
                                            );
                                          } else {
                                            await _resortHomeViewModel.checkAndShowTreasureHuntPopup(
                                              userId: _userViewModel.user.user_id!,
                                            );
                                          }

                                          if(_userViewModel.user.within_boundary == false){
                                            Get.snackbar(
                                              '라이브 불가 지역입니다',
                                              '스키장 내에서만 라이브가 활성화됩니다.',
                                              margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                                              snackPosition: SnackPosition.TOP,
                                              backgroundColor: SDSColor.snowliveWhite.withOpacity(0.2),
                                              colorText: SDSColor.snowliveBlack,
                                              duration: Duration(milliseconds: 3000),
                                            );
                                          }
                                        },
                                        child: Text(
                                          '라이브 재시작하기',
                                          style: SDSTextStyle.bold.copyWith(
                                            fontSize: 15,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
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
                                                CustomFullScreenDialog.showDialog();
                                                await _resortHomeViewModel.liveOff({
                                                  "user_id":_userViewModel.user.user_id
                                                }, _userViewModel.user.user_id);
                                                CustomFullScreenDialog.cancelDialog();
                                                Get.back();
                                                await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
                                                await _resortHomeViewModel.stopForegroundLocationService();
                                                await _resortHomeViewModel.stopBackgroundLocationService();
                                                print('라이브 OFF');
                                              },
                                              child: Text(
                                                '라이브 종료',
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
                          else if(_userViewModel.user.within_boundary == false) {
                            HapticFeedback.lightImpact();

                            // 위치 서비스 권한 확인(안드만 실행되게 함)
                            if (Platform.isAndroid) {
                              // 위치 서비스 권한 확인 (안드로이드에서만 실행)
                              final status = await Permission.locationAlways.status;
                              if (status != PermissionStatus.granted) {
                                // 위치 서비스 항상 허용이 아닐 경우 팝업 표시
                                await _resortHomeViewModel.showSettingsPopup(
                                  title: '권한 필요',
                                  message: '위치 서비스를 항상 허용으로 설정해야 라이브 기능을 사용할 수 있습니다.',
                                  action: () => openAppSettings(),
                                );
                                return; // 이후 코드 실행 중단
                              }
                            }
                            // 배터리 절약 모드(절전 모드) 확인
                            final isBatterySaverOn = await _resortHomeViewModel.isBatterySaverOn();
                            if (isBatterySaverOn) {
                              // 배터리 절약 모드가 켜져 있을 경우 팝업 표시
                              await _resortHomeViewModel.showSettingsPopup(
                                title: '배터리 절약 모드 감지',
                                message: '배터리 절약 모드를 비활성화해야 라이브 기능을 사용할 수 있습니다.',
                                action: () async {
                                  await _resortHomeViewModel.navigateToBatterySettings();
                                },
                              );
                              return; // 이후 코드 실행 중단
                            }

                            CustomFullScreenDialog.showDialog();
                            await _resortHomeViewModel.startLiveLocationService(user_id: _userViewModel.user.user_id);
                            await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
                            CustomFullScreenDialog.cancelDialog();
                            if (_userViewModel.user.crew_id != null) {
                              await _resortHomeViewModel.checkAndShowTreasureHuntPopup(
                                userId: _userViewModel.user.user_id!,
                                userCrewId: _userViewModel.user.crew_id,
                              );
                            } else {
                              await _resortHomeViewModel.checkAndShowTreasureHuntPopup(
                                userId: _userViewModel.user.user_id!,
                              );
                            }

                            if(_userViewModel.user.within_boundary == false){
                              Get.snackbar(
                                '라이브 불가 지역입니다',
                                '스키장 내에서만 라이브가 활성화됩니다.',
                                margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: SDSColor.snowliveWhite.withOpacity(0.2),
                                colorText: SDSColor.snowliveBlack,
                                duration: Duration(milliseconds: 3000),
                              );
                            }
                          }
                        },
                        elevation: 0,
                        icon:  (_userViewModel.user.within_boundary == true)
                            ? (_resortHomeViewModel.resort_info['fullname'] != null)
                            ? Image.asset('assets/imgs/icons/icon_live_off.png', width: 40)
                            : Container()
                            : Image.asset('assets/imgs/icons/icon_live_on.png', width: 40),
                        label: (_userViewModel.user.within_boundary == true)
                            ? Text(
                          (_resortHomeViewModel.resort_info['fullname'] != null)
                              ? '${_resortHomeViewModel.resortHomeModel.todayTotalScore.round()}점 획득'
                              : '버튼을 눌러 라이브 종료 후 다시 시작해주세요',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 16,
                            letterSpacing: -0.1,
                            color:
                            (_resortHomeViewModel.resort_info['fullname'] != null)
                                ? SDSColor.snowliveWhite
                                : Color(0xFF4C0000),
                          ),
                        )
                            : Text(
                          '라이브 시작하기',
                          style: SDSTextStyle.extraBold.copyWith(
                            fontSize: 16,
                            letterSpacing: -0.1,
                            color: SDSColor.snowliveWhite,
                          ),
                        ),
                        backgroundColor: (_userViewModel.user.within_boundary == true)
                            ? (_resortHomeViewModel.resort_info['fullname'] != null) ? SDSColor.snowliveBlue : Color(0xFFFFAAA5)
                            : SDSColor.gray800),
                  )),
                ),
              ],
            ),
          )
              :SizedBox.shrink(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: AppBar(
              actions: [
                IconButton(
                  highlightColor: Colors.transparent,
                  onPressed: () async{
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.88,
                        minChildSize: 0.4,
                        maxChildSize: 0.88,
                        builder: (BuildContext context, ScrollController scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                                color: SDSColor.snowliveWhite,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))
                            ),
                            padding: EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                Center(
                                  child: Padding(
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
                                ),
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        '스키장 오픈채팅',
                                        style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                      ),
                                      SizedBox(height: 10,),
                                      Text(
                                        '전국 스키장의 스노우라이브 유저들과',
                                        style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                                      ),
                                      Text(
                                        '익명으로 실시간 채팅을 즐겨 보세요',
                                        style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Expanded(child: ChatScreen()),
                              ],
                            ), // ChatScreen을 모달 시트로 띄움
                          );
                        },
                      ),
                    );
                  },
                  icon: Image.asset(
                    'assets/imgs/icons/icon_talk_resortHome.png',
                    width: 26,
                    height: 26,
                  ),
                ),
                IconButton(
                  highlightColor: Colors.transparent,
                  onPressed: () async{
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      isScrollControlled: true,
                      builder: (context) {
                        return Obx(() => DraggableScrollableSheet(
                          initialChildSize:
                          (_resortHomeViewModel.bestFriendList.length > 8)
                              ? 0.6
                              : (_resortHomeViewModel.bestFriendList.length > 4)
                              ? 0.56
                              : 0.4,
                          minChildSize: 0.4,
                          maxChildSize: 0.88,
                          expand: false,
                          builder: (context, scrollController) {
                            return Stack(
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                      color: SDSColor.snowliveWhite,
                                    ),
                                    padding: EdgeInsets.only(right: 16, left: 16, top: 12),
                                    child: Obx(()=>Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Padding(
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
                                        ),
                                        Stack(
                                          children: [
                                            Container(
                                              width: _size.width,
                                              height: 32,
                                              child: Center(
                                                child: Text(
                                                  '라이브중인 친구',
                                                  style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              bottom: 0,
                                              child: ElevatedButton(
                                                onPressed: () async{
                                                  await _resortHomeViewModel.fetchBestFriendList(user_id: _userViewModel.user.user_id);
                                                },
                                                child: Text('새로고침',
                                                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                                  minimumSize: Size(36, 32),
                                                  backgroundColor: SDSColor.snowliveWhite,
                                                  side: BorderSide(
                                                      color: SDSColor.gray200
                                                  ),
                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(100)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20,),
                                        (_resortHomeViewModel.isLoading_bestFriend == true)
                                            ? Container(
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
                                        )
                                            :
                                        Expanded(
                                          child: _resortHomeViewModel.bestFriendList.isEmpty
                                              ? Center(
                                            child: Container(
                                              height: 180,
                                              child: Text(
                                                '친구 관리로 이동해 즐겨찾는 친구를 등록해 주세요.\n라이브중인 친구를 바로 확인하실 수 있어요.',
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 14, color: SDSColor.gray500, height: 1.4
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                              : GridView.builder(
                                              controller: scrollController,
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4, // 4개의 열로 표시
                                                childAspectRatio: 2 / 3, // 너비와 높이 비율 조정
                                              ),
                                              itemCount: _resortHomeViewModel.bestFriendList.length,
                                              itemBuilder: (context, index) {
                                                var BFdoc = _resortHomeViewModel.bestFriendList[index];
                                                return GestureDetector(
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    Get.toNamed(AppRoutes.friendDetail);
                                                    await _friendDetailViewModel.fetchFriendDetailInfo(
                                                      userId: _userViewModel.user.user_id,
                                                      friendUserId: BFdoc.friendInfo.userId,
                                                      season: _friendDetailViewModel.seasonDate,
                                                    );
                                                  },
                                                  child: Container(
                                                    width: (_size.width - 40) / 4, // 화면 너비를 4등분
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            Container(
                                                              width: 68,
                                                              height: 68,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(100),
                                                                border: (BFdoc.friendInfo.withinBoundary == true &&
                                                                    BFdoc.friendInfo.revealWb == true)
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
                                                              child: BFdoc.friendInfo.profileImageUrlUser.isNotEmpty
                                                                  ? ExtendedImage.network(
                                                                BFdoc.friendInfo.profileImageUrlUser,
                                                                enableMemoryCache: true,
                                                                shape: BoxShape.circle,
                                                                borderRadius: BorderRadius.circular(100),
                                                                width: 68,
                                                                height: 68,
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
                                                              )
                                                                  : ClipOval(
                                                                child: Image.asset(
                                                                  'assets/imgs/profile/img_profile_default_circle.png',
                                                                  width: 68,
                                                                  height: 68,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                            if (BFdoc.friendInfo.withinBoundary == true &&
                                                                BFdoc.friendInfo.revealWb == true)
                                                              Positioned(
                                                                right: 0,
                                                                bottom: 0,
                                                                left: 0,
                                                                child: Center(
                                                                  child: Image.asset(
                                                                    'assets/imgs/icons/icon_badge_live.png',
                                                                    width: 34,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 6),
                                                        Container(
                                                          width: 72,
                                                          child: Text(
                                                            BFdoc.friendInfo.displayName,
                                                            overflow: TextOverflow.ellipsis,
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.normal,
                                                                color: SDSColor.gray900),
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              (BFdoc.lastPassSlope == null)
                                                                  ? ''
                                                                  : '${BFdoc.lastPassSlope}',
                                                              overflow: TextOverflow.ellipsis,
                                                              textAlign: TextAlign.center,
                                                              style: SDSTextStyle.regular.copyWith(
                                                                  fontSize: 11,
                                                                  color: SDSColor.gray500),
                                                            ),
                                                            Text(
                                                              (BFdoc.lastPassTime == null)
                                                                  ? ''
                                                                  : '·${GetDatetime().getAgoString(BFdoc.lastPassTime!)}',
                                                              overflow: TextOverflow.ellipsis,
                                                              textAlign: TextAlign.center,
                                                              style: SDSTextStyle.regular.copyWith(
                                                                  fontSize: 11,
                                                                  color: SDSColor.gray500),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),)
                                ),
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 0,
                                  child: SafeArea(
                                    child: Container(
                                      color: SDSColor.snowliveWhite,
                                      width: _size.width,
                                      padding: EdgeInsets.only(top: 12, bottom: 20),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          Get.toNamed(AppRoutes.friendList);
                                          await _friendListViewModel.fetchFriendList();
                                          await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
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
                                ),
                              ],
                            );
                          },
                        ));
                      },
                    );
                  },
                  icon: Image.asset(
                    'assets/imgs/icons/icon_friend_resortHome.png',
                    width: 28,
                    height: 28,
                  ),
                ),
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
                          onPressed: () async{
                            Get.toNamed(AppRoutes.alarmCenter);
                            await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                          },
                          icon: Image.asset(
                            'assets/imgs/icons/icon_alarm_resortHome.png',
                            width: 26,
                            height: 26,
                          ),
                        );
                      }

                      var data = snapshot.data!.docs[0].data() as Map<String, dynamic>?;
                      bool isNewNotification = data?['total'] ?? false; // Firestore 문서 필드

                      return Stack(
                        children: [
                          IconButton(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () async{
                              CustomFullScreenDialog.showDialog();
                              await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                              CustomFullScreenDialog.cancelDialog();
                              Get.toNamed(AppRoutes.alarmCenter);
                              await _alarmCenterViewModel.updateNotification(
                                _userViewModel.user.user_id,
                                total: false,
                              );
                            },
                            icon: Image.asset(
                              'assets/imgs/icons/icon_alarm_resortHome.png',
                            ),
                          ),
                          if (isNewNotification)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () async {
                                  CustomFullScreenDialog.showDialog();
                                  await _alarmCenterViewModel.fetchAlarmCenterList(userId: _userViewModel.user.user_id);
                                  CustomFullScreenDialog.cancelDialog();
                                  Get.toNamed(AppRoutes.alarmCenter);
                                  await _alarmCenterViewModel.updateNotification(
                                    _userViewModel.user.user_id,
                                    total: false,
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
                )
              ],
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              centerTitle: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child:  (_userViewModel.user.within_boundary == true)
                    ? (_resortHomeViewModel.resort_info['fullname'] != null) ? Image.asset(
                  'assets/imgs/logos/snowliveLogo_main_new_blue.png',
                  height: 38,
                ) : Image.asset(
                  'assets/imgs/logos/snowliveLogo_main_new.png',
                  height: 38,
                )
                    : Image.asset(
                  'assets/imgs/logos/snowliveLogo_main_new.png',
                  height: 38,
                ),
              ),
              backgroundColor: SDSColor.snowliveWhite,
              foregroundColor: SDSColor.snowliveWhite,
              surfaceTintColor: SDSColor.snowliveWhite,
              elevation: 0.0,
            ),
          ),
          body: RefreshIndicator(
            strokeWidth: 2,
            edgeOffset: 60,
            backgroundColor: SDSColor.snowliveBlue,
            color: SDSColor.snowliveWhite,
            onRefresh: _resortHomeViewModel.onRefresh_resortHome,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
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
                                borderRadius: BorderRadius.circular(16),
                                color: (_resortHomeViewModel.isLoading_weather == true)
                                    ? SDSColor.gray200
                                    : _resortHomeViewModel.weatherColors),
                            alignment: Alignment.center,
                            width: double.infinity,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 14),
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
                                                  child:
                                                  (_resortHomeViewModel.isLoading_weather == true)
                                                      ? Text(
                                                    ' ',
                                                    style: SDSTextStyle.bold.copyWith(
                                                        color: SDSColor.snowliveWhite,
                                                        fontSize: 16),
                                                  )
                                                      : Text(
                                                    '${_resortHomeViewModel.resortHomeModel.instantResortName}',
                                                    style: SDSTextStyle.bold.copyWith(
                                                        color: _resortHomeViewModel.weatherTextColors,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                (_resortHomeViewModel.isLoading_weather == true)
                                                    ? Container()
                                                    : Image.asset(
                                                  'assets/imgs/icons/icon_dropdown.png',
                                                  width: 18,
                                                  height: 18,
                                                  color: _resortHomeViewModel.weatherTextColors,
                                                )
                                              ],
                                            ),
                                            ),
                                            onTap: () async{
                                              selectedIndex = await showModalBottomSheet<int>(
                                                constraints: BoxConstraints(
                                                  maxHeight: _size.height - _statusBarSize - 44,
                                                ),
                                                backgroundColor: Colors.transparent,
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (context) => SelectResortWidget(),
                                              );
                                              if(selectedIndex != null)
                                                await _resortHomeViewModel.changeInstantResort(
                                                    {
                                                      "user_id": _userViewModel.user.user_id,    //필수 - 수정할 유저id
                                                      "instant_resort": selectedIndex!    //선택 - 프로필 비공개 설정에서만 씀
                                                    }, _userViewModel.user.user_id
                                                );

                                            },
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          SizedBox(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 24),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  (_resortHomeViewModel.isLoading_weather == true)
                                                      ? Text(' ',
                                                    style: SDSTextStyle.regular.copyWith(
                                                        color: _resortHomeViewModel.weatherTextColors,
                                                        fontSize: 13),
                                                  )
                                                      : Opacity(
                                                    opacity: 0.5,
                                                    child: Text('${GetDatetime().getDateTime()}',
                                                      style: SDSTextStyle.regular.copyWith(
                                                          color: _resortHomeViewModel.weatherTextColors,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          _resortHomeViewModel.toggleExpandWeatherInfo();
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              (_resortHomeViewModel.isLoading_weather == true)
                                                  ? Container()
                                                  : Padding(
                                                padding: const EdgeInsets.only(bottom: 2),
                                                child: Container(
                                                    width: 32,
                                                    child: _resortHomeViewModel.weatherIcons),
                                              ),
                                              SizedBox(width: 10,),
                                              Obx(() => (_resortHomeViewModel.isLoading_weather == true)
                                                  ? Padding(
                                                padding: EdgeInsets.only(right: 16),
                                                child: Container(
                                                    width: 50,
                                                    child: Lottie.asset('assets/json/loadings_wht_final.json')),
                                              )
                                                  : Container(
                                                height: 54,
                                                child: Center(
                                                  child: Text('${_resortHomeViewModel.weatherInfo['temp']??'-'}', //u00B0
                                                    style: GoogleFonts.bebasNeue(
                                                        fontSize: 44,
                                                        color: _resortHomeViewModel.weatherTextColors,
                                                        height: 1.3
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 6),
                                                child: Obx(() => (_resortHomeViewModel.isLoading_weather == true)
                                                    ? Padding(
                                                  padding: const EdgeInsets.only(bottom: 4, left: 2),
                                                  child: Text(' ',
                                                    style: GoogleFonts.bebasNeue(
                                                        fontSize: 36,
                                                        color: Colors.white),
                                                  ),
                                                )
                                                    : Padding(
                                                  padding: const EdgeInsets.only(bottom: 4, left: 2),
                                                  child: Text('\u00B0',
                                                    style: GoogleFonts.bebasNeue(
                                                        fontSize: 36,
                                                        color: _resortHomeViewModel.weatherTextColors),
                                                  ),
                                                ),
                                                ),
                                              ),
                                              Stack(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 40,
                                                    color: Colors.transparent,
                                                  ),
                                                  (_resortHomeViewModel.isWeatherInfoExpanded == false)
                                                      ? Positioned(
                                                    left: 0,
                                                    top: 10,
                                                    child: Image.asset(
                                                      'assets/imgs/icons/icon_plus_round.png',
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                  )
                                                      : Positioned(
                                                    left: 0,
                                                    top: 10,
                                                    child: Image.asset(
                                                      'assets/imgs/icons/icon_minus_round.png',
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                  )
                                                ],
                                              )

                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if(_resortHomeViewModel.isWeatherInfoExpanded == true)
                                  SizedBox(
                                    height: 14,
                                  ),
                                if(_resortHomeViewModel.isWeatherInfoExpanded == true)
                                  (_resortHomeViewModel.isLoading_weather == true)
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
                                      color: SDSColor.snowliveBlack.withOpacity(0.08),
                                      height: 1,
                                      width: _size.width,
                                    ),
                                  ),
                                SizedBox(
                                  height: 14,
                                ),
                                if(_resortHomeViewModel.isWeatherInfoExpanded == true)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Opacity(
                                            opacity: 0.5,
                                            child: Text('바람',
                                              style: SDSTextStyle.regular.copyWith(
                                                  color: _resortHomeViewModel.weatherTextColors,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Obx(() => Padding(
                                                padding:
                                                const EdgeInsets.only(right: 2),
                                                child: Text(
                                                  '${_resortHomeViewModel.weatherInfo['wind']??'-'}',
                                                  style: GoogleFonts.bebasNeue(
                                                      fontSize: 24,
                                                      color: _resortHomeViewModel.weatherTextColors),
                                                ),
                                              ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(bottom: 3),
                                                child: Text('M/S',
                                                  style: GoogleFonts.bebasNeue(
                                                      fontSize: 16,
                                                      color: _resortHomeViewModel.weatherTextColors),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Opacity(
                                            opacity: 0.5,
                                            child: Text(
                                              '습도',
                                              style: SDSTextStyle.regular.copyWith(
                                                  color: _resortHomeViewModel.weatherTextColors,
                                                  fontSize: 12),
                                            ),
                                          ),

                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Obx(
                                                    () => Padding(
                                                  padding:
                                                  const EdgeInsets.only(right: 2),
                                                  child: Text(
                                                    '${_resortHomeViewModel.weatherInfo['wet']??'-'}',
                                                    style: GoogleFonts.bebasNeue(
                                                        fontSize: 24,
                                                        color: _resortHomeViewModel.weatherTextColors),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(bottom: 3),
                                                child: Text('%',
                                                  style: GoogleFonts.bebasNeue(
                                                      fontSize: 16,
                                                      color: _resortHomeViewModel.weatherTextColors),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Opacity(
                                            opacity: 0.5,
                                            child: Text(
                                              '강수',
                                              style: SDSTextStyle.regular.copyWith(
                                                  color: _resortHomeViewModel.weatherTextColors,
                                                  fontSize: 12),
                                            ),
                                          ),

                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Obx(
                                                    () => Padding(
                                                  padding: const EdgeInsets.only(right: 2),
                                                  child: Text('${_resortHomeViewModel.weatherInfo['rain']??'-'}',
                                                    style: GoogleFonts.bebasNeue(
                                                        fontSize: 24,
                                                        color: _resortHomeViewModel.weatherTextColors),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(bottom: 3),
                                                child: Text('MM',
                                                  style: GoogleFonts.bebasNeue(
                                                      fontSize: 16,
                                                      color: _resortHomeViewModel.weatherTextColors),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Opacity(
                                            opacity: 0.5,
                                            child: Text(
                                              '최저/최고기온',
                                              style: SDSTextStyle.regular.copyWith(
                                                  color: _resortHomeViewModel.weatherTextColors,
                                                  fontSize: 12),
                                            ),
                                          ),

                                          Obx(
                                                () => Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${_resortHomeViewModel.weatherInfo['minTemp']??'-'}',
                                                  style: GoogleFonts.bebasNeue(
                                                      fontSize: 24,
                                                      color: _resortHomeViewModel.weatherTextColors),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      bottom: 3, left: 3, right: 2),
                                                  child: Text(
                                                    '/',
                                                    style: GoogleFonts.bebasNeue(
                                                        fontSize: 16,
                                                        color: _resortHomeViewModel.weatherTextColors),
                                                  ),
                                                ),
                                                Text(
                                                  '${_resortHomeViewModel.weatherInfo['maxTemp']??'-'}',
                                                  style: GoogleFonts.bebasNeue(
                                                      fontSize: 24,
                                                      color: _resortHomeViewModel.weatherTextColors),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                if(_resortHomeViewModel.isWeatherInfoExpanded == true)
                                  SizedBox(
                                    height: 14,
                                  )
                              ],
                            ),
                          ),
                        ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //TODO: url 아이콘 영역
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 28, left: 28, top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await otherShare(contents: '${_resortHomeViewModel.resortHomeModel.urlNaver}');
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
                                      onTap: () async{
                                        if (_resortHomeViewModel.resortHomeModel.urlWebcam != '') {
                                          await otherShare(contents: '${_resortHomeViewModel.resortHomeModel.urlWebcam}');
                                        }
                                      },
                                      child: Container(
                                        width: 64,
                                        child: Column(
                                          children: [
                                            (_resortHomeViewModel.resortHomeModel.urlWebcam != '')
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
                                                  (_resortHomeViewModel.resortHomeModel.urlWebcam != '')
                                                      ? SDSColor.gray800 : SDSColor.gray400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async{
                                        if (_resortHomeViewModel.resortHomeModel.urlSlope != '') {
                                          await otherShare(contents: '${_resortHomeViewModel.resortHomeModel.urlSlope}');
                                        }
                                      },
                                      child: Container(
                                        width: 64,
                                        child: Column(
                                          children: [
                                            (_resortHomeViewModel.resortHomeModel.urlSlope != '')
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
                                                  (_resortHomeViewModel.resortHomeModel.urlSlope != '')
                                                      ? SDSColor.gray800 : SDSColor.gray400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async{
                                        if (_resortHomeViewModel.resortHomeModel.urlBus != '') {
                                          await otherShare(contents: '${_resortHomeViewModel.resortHomeModel.urlBus}');
                                        }
                                      },
                                      child: Container(
                                        width: 64,
                                        child: Column(
                                          children: [
                                            (_resortHomeViewModel.resortHomeModel.urlBus != '')
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
                                                  (_resortHomeViewModel.resortHomeModel.urlBus != '')
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
                            //TODO: 배너
                            Padding(
                              padding: EdgeInsets.only(left: 16, right: 16, top: 28),
                              child: Banner_resortHome(),
                            ),
                            //TODO: 보물찾기 진입 배너
                            GestureDetector(
                              onTap: (){
                                Get.toNamed(AppRoutes.treasureHunt);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                                child: Banner_treasureHunt(),
                              ),
                            ),
                            //TODO: 구분선
                            if((_resortHomeViewModel.resortHomeModel.dailyTotalCount != 0 || _userViewModel.user.within_boundary == true))
                              Padding(
                                padding: const EdgeInsets.only(top: 20, bottom: 24),
                                child: Container(
                                  width: _size.width,
                                  height: 10,
                                  color: SDSColor.gray50,
                                ),
                              ),
                            Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //TODO: 오늘의 기록
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4, left: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if((_resortHomeViewModel.resortHomeModel.dailyTotalCount != 0 || _userViewModel.user.within_boundary == true))
                                            Text('오늘의 기록',
                                              style: SDSTextStyle.extraBold.copyWith(
                                                  fontSize: 15,
                                                  color: SDSColor.gray900
                                              ),
                                            ),
                                          if(_userViewModel.user.within_boundary == true)
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 2),
                                                  child:
                                                  (_resortHomeViewModel.resort_info['fullname'] != null)
                                                      ? Image.asset(
                                                    'assets/imgs/icons/icon_pin.png',
                                                    width: 18,
                                                    height: 18,
                                                  )
                                                      : Image.asset(
                                                    'assets/imgs/icons/icon_pin_inactive.png',
                                                    width: 18,
                                                    height: 18,
                                                  ),
                                                ),
                                                (_resortHomeViewModel.resort_info['fullname'] != null)
                                                    ? Row(
                                                  children: [
                                                    Text('지금 ',
                                                      style: SDSTextStyle.regular.copyWith(
                                                          fontSize: 13,
                                                          color: SDSColor.gray500
                                                      ),
                                                    ),
                                                    Text('${_resortHomeViewModel.resort_info['fullname']}',
                                                      style: SDSTextStyle.regular.copyWith(
                                                          fontSize: 13,
                                                          color: SDSColor.snowliveBlue
                                                      ),
                                                    ),
                                                    Text('에서 라이브온 중이에요',
                                                      style: SDSTextStyle.regular.copyWith(
                                                          fontSize: 13,
                                                          color: SDSColor.gray500
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                    :Text('라이브 지역을 확인할 수 없어요',
                                                  style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 13,
                                                      color: SDSColor.gray500
                                                  ),
                                                ),

                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    if((_resortHomeViewModel.resortHomeModel.dailyTotalCount != 0 || _userViewModel.user.within_boundary == true))
                                      Column(
                                        children: [
                                          Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 16),
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                                  width: _size.width,
                                                  decoration: BoxDecoration(
                                                    color: SDSColor.gray50,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('오늘 총 라이딩 횟수',
                                                        style: SDSTextStyle.regular.copyWith(
                                                            color: SDSColor.gray900,
                                                            fontSize: 13
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 6),
                                                        child: Text('${_resortHomeViewModel.resortHomeModel.dailyTotalCount}',
                                                          style: SDSTextStyle.extraBold.copyWith(
                                                              color: SDSColor.gray900,
                                                              fontSize: 30
                                                          ),
                                                        ),
                                                      ),
                                                      if(_resortHomeViewModel.resortHomeModel.slopeCountInfoToday.length != 0)
                                                        Column(
                                                          children: [
                                                            Container(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.map<Widget>((data)  {
                                                                    String slopeName = data.slope;
                                                                    int passCount = data.count;
                                                                    double barWidthRatio = data.ratio;
                                                                    return Padding(
                                                                      padding: (data != _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.last)
                                                                          ? EdgeInsets.only(bottom: 2, top: 4)
                                                                          : EdgeInsets.only(bottom: 0, top: 4),
                                                                      child: Row(
                                                                        children: [
                                                                          Container(
                                                                            width: 44,
                                                                            child: Text(
                                                                              slopeName,
                                                                              style: SDSTextStyle.regular.copyWith(
                                                                                fontSize: 11,
                                                                                color: SDSColor.gray600,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            height: 14,
                                                                            width: (_size.width - 166) * barWidthRatio,
                                                                            decoration: BoxDecoration(
                                                                                color:
                                                                                (data == _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.first)
                                                                                    ? SDSColor.snowliveBlue
                                                                                    : SDSColor.gray200,
                                                                                borderRadius: BorderRadius.only(
                                                                                    topRight: Radius.circular(4),
                                                                                    bottomRight: Radius.circular(4)
                                                                                )
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: (data == _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.first)
                                                                                ? EdgeInsets.only(left: 6)
                                                                                : EdgeInsets.only(left: 2),
                                                                            child: Container(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Container(
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                      color: (data == _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.first)
                                                                                          ? SDSColor.gray900
                                                                                          : Colors.transparent,
                                                                                    ),
                                                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                                                    child: Text('$passCount',
                                                                                      style: SDSTextStyle.bold.copyWith(
                                                                                        fontSize: 12,
                                                                                        fontWeight: (data == _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.first)
                                                                                            ? FontWeight.bold : FontWeight.bold,
                                                                                        color: (data == _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.first)
                                                                                            ? SDSColor.snowliveWhite : SDSColor.gray900,
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
                                                                )
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 24),
                                                              child: Container(
                                                                height: 1,
                                                                width: _size.width - 80,
                                                                color: SDSColor.snowliveBlack.withOpacity(0.05),
                                                              ),
                                                            ),
                                                            if(_resortHomeViewModel.resortHomeModel.dailyTotalCount != 0)
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text('시간대별 기록',
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                        color: SDSColor.gray900,
                                                                        fontSize: 13
                                                                    ),
                                                                  ),
                                                                  if(_resortHomeViewModel.resortHomeModel.dailyTotalCount != 0)
                                                                    Padding(
                                                                      padding: EdgeInsets.only(top: 10),
                                                                      child: Container(
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                                          children: _resortHomeViewModel.resortHomeModel.timeCountInfoToday.entries.map<Widget>((entry) {
                                                                            String slotName = entry.key;
                                                                            int passCount = entry.value;
                                                                            int maxCount = _resortHomeViewModel.resortHomeModel.timeInfo_maxCount;
                                                                            double barHeightRatio =  passCount/maxCount;
                                                                            return Container(
                                                                              width: 30,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  AutoSizeText(
                                                                                    passCount != 0 ? '$passCount' : '',
                                                                                    style: SDSTextStyle.bold.copyWith(
                                                                                      fontSize: 12,
                                                                                      color: SDSColor.gray900,
                                                                                    ),
                                                                                    minFontSize: 6,
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.visible,
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(top: 4),
                                                                                    child: Container(
                                                                                      width: 16,
                                                                                      height: 100 * barHeightRatio,
                                                                                      decoration: BoxDecoration(
                                                                                          color: SDSColor.gray200,
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
                                                                                        slotName,
                                                                                        style: SDSTextStyle.regular.copyWith(
                                                                                            fontSize: 11,
                                                                                            color: SDSColor.gray600,
                                                                                            height: 1.2
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
                                                                    ),
                                                                  if(_resortHomeViewModel.resortHomeModel.dailyTotalCount == 0)
                                                                    Center(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(bottom: 30),
                                                                        child: Column(
                                                                          children: [
                                                                            Image.asset(
                                                                              'assets/imgs/icons/icon_nodata.png',
                                                                              fit: BoxFit.cover,
                                                                              width: 72,
                                                                              height: 72,
                                                                            ),
                                                                            Text('라이딩 기록이 없어요',
                                                                              style: SDSTextStyle.regular.copyWith(
                                                                                  fontSize: 14,
                                                                                  color: SDSColor.gray600
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                ],
                                                              ),
                                                          ],
                                                        ),

                                                      if(_resortHomeViewModel.resortHomeModel.slopeCountInfoToday.length == 0)
                                                        Center(
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(bottom: 30),
                                                            child: Column(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/imgs/icons/icon_nodata.png',
                                                                  fit: BoxFit.cover,
                                                                  width: 72,
                                                                  height: 72,
                                                                ),
                                                                Text('라이딩 기록이 없어요',
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 14,
                                                                      color: SDSColor.gray600
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    if(_resortHomeViewModel.resortHomeModel.dailyTotalCount == 0 && _userViewModel.user.within_boundary == false)
                                      Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Container(
                                          height: _size.width,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF5F2F7),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Stack (
                                            children: [
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Padding(
                                                  padding: EdgeInsets.only(bottom: 12),
                                                  child: Image.asset(
                                                    'assets/imgs/imgs/img_resortHome_ranking_1.png',
                                                    fit: BoxFit.cover,
                                                    width: _size.width - 60,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 24, top: 30, right: 24),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '지금 바로 랭킹에 참여해보세요!',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 18,
                                                            color: SDSColor.gray900,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 4),
                                                          child: Text(
                                                            '친구들의 라이브 상태도 확인하고',
                                                            style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 14,
                                                              color: SDSColor.gray600,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 2),
                                                          child: Text(
                                                            '다른 유저들과 경쟁해보세요!',
                                                            style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 14,
                                                              color: SDSColor.gray600,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(top: 12),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Get.toNamed(AppRoutes.rankingGuideMain);
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                                              decoration: BoxDecoration(
                                                                  color: SDSColor.snowliveWhite,
                                                                  borderRadius: BorderRadius.circular(20),
                                                                  border: Border.all(
                                                                      color: SDSColor.gray300,
                                                                      width: 1
                                                                  )
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 6),
                                                                    child: Text(
                                                                      '필수 설정하러 가기',
                                                                      style: SDSTextStyle.extraBold.copyWith(
                                                                          color: SDSColor.snowliveBlack,
                                                                          fontSize: 14
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Image.asset(
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
                                            ],
                                          ),
                                        ),
                                      )
                                  ],
                                )
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
  }
}
