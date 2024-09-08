import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/controller/public/vm_refreshController.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/screens/resort/v_chat_resortHome.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:com.snowlive/widget/w_liveOn_animatedGradient.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:com.snowlive/screens/banner/v_banner_resortHome.dart';
import 'package:lottie/lottie.dart';
import '../util/util_1.dart';
import '../viewmodel/vm_friendDetail.dart';
import '../viewmodel/vm_resortHome.dart';
import '../viewmodel/vm_user.dart';
import '../widget/w_selectResort.dart';
// 1234
class ResortHomeView extends StatefulWidget {
  @override
  State<ResortHomeView> createState() => _ResortHomeViewState();
}

class _ResortHomeViewState extends State<ResortHomeView> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

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
  //TODO: Dependency Injection**************************************************

  @override
  void initState() {
    super.initState();
    print(_userViewModel.user.user_id);
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
          SizedBox(
            width: _size.width - 32,
            height: 56,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 3),
                      child:
                      (_userViewModel.user.within_boundary == true)
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
                  padding: EdgeInsets.only(top: 3, bottom: 5, right: 2, left: 2),
                  width: _size.width - 32,
                  decoration: BoxDecoration(
                    boxShadow: [
                      (_userViewModel.user.within_boundary == true)
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
                  child: Obx(()=>ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: FloatingActionButton.extended(
                        onPressed: () async {
                          if (_userViewModel.user.within_boundary == true) {
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
                                    height: 80,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '오늘 ',
                                                style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
                                              ),
                                              Text(
                                                '${_resortHomeViewModel.resortHomeModel.todayTotalScore.toInt()}',
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
                                                  await _resortHomeViewModel.liveOff({
                                                    "user_id":_userViewModel.user.user_id
                                                  }, _userViewModel.user.user_id);
                                                  await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
                                                  await _resortHomeViewModel.stopForegroundLocationService();
                                                  await _resortHomeViewModel.stopBackgroundLocationService();
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
                                    ),
                                  ],
                                ),
                              ),
                              barrierDismissible: false,
                            );
                          }
                          else if(_userViewModel.user.within_boundary == false) {
                            HapticFeedback.lightImpact();
                            await _resortHomeViewModel.startForegroundLocationService(user_id: _userViewModel.user.user_id);
                            await _resortHomeViewModel.startBackgroundLocationService(user_id: _userViewModel.user.user_id);
                            await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
                          }
                        },
                        elevation: 0,
                        icon:   (_userViewModel.user.within_boundary == true)
                            ? Image.asset('assets/imgs/icons/icon_live_on.png', width: 40)
                            : Image.asset('assets/imgs/icons/icon_live_off.png', width: 40),
                        label: (_userViewModel.user.within_boundary == true)
                            ? Text(
                          '${_resortHomeViewModel.resortHomeModel.todayTotalScore.toInt()}점 획득',
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
                        backgroundColor:  (_userViewModel.user.within_boundary == true) ? SDSColor.gray800  : SDSColor.gray800),
                  )),
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
                IconButton(
                  onPressed: () async{
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.8,
                        minChildSize: 0.4,
                        maxChildSize: 0.9,
                        builder: (BuildContext context, ScrollController scrollController) {
                          return Container(
                            padding: EdgeInsets.all(16),
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
                                        style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray500),
                                      ),
                                      Text(
                                        '실시간으로 정보를 공유해 보세요',
                                        style: SDSTextStyle.bold.copyWith(fontSize: 12, color: SDSColor.gray500),
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
                          initialChildSize: _resortHomeViewModel.initialHeightFriend > 0.4
                              ? _resortHomeViewModel.initialHeightFriend
                              : 0.4, // Ensure this value is at least equal to minChildSize
                          minChildSize: 0.4,
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
                                  Center(
                                    child: Text(
                                      '라이브중인 친구',
                                      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Expanded(
                                    child: _resortHomeViewModel.bestFriendList.isEmpty
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
                                        : SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          spacing: 14, // 아이템 간의 가로 간격
                                          runSpacing: 28, // 아이템 간의 세로 간격
                                          children: List.generate(_resortHomeViewModel.bestFriendList.length, (index) {
                                            var BFdoc = _resortHomeViewModel.bestFriendList[index];
                                            return GestureDetector(
                                              onTap: () async {
                                                await _friendDetailViewModel.fetchFriendDetailInfo(
                                                  userId: _userViewModel.user.user_id,
                                                  friendUserId: BFdoc.friendInfo.userId,
                                                  season: _friendDetailViewModel.seasonDate,
                                                );
                                                Get.toNamed(AppRoutes.friendDetail);
                                              },
                                              child: Container(
                                                width: (MediaQuery.of(context).size.width - 14 * 5) / 4, // 화면 너비를 4등분
                                                margin: const EdgeInsets.only(bottom: 28), // 각 아이템의 아래 여백
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
                                                        if (BFdoc.friendInfo.withinBoundary == true &&
                                                            BFdoc.friendInfo.revealWb == true)
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
                                                        BFdoc.friendInfo.displayName,
                                                        overflow: TextOverflow.ellipsis,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.normal,
                                                          color: Color(0xFF111111),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            (BFdoc.friendInfo.lastPassSlope == null)
                                                                ? ''
                                                                : '${BFdoc.friendInfo.lastPassSlope}',
                                                            overflow: TextOverflow.ellipsis,
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.normal,
                                                              color: Color(0xFF111111),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 2),
                                                        Flexible(
                                                          child: Text(
                                                            (BFdoc.friendInfo.lastPassTime == null)
                                                                ? ''
                                                                : GetDatetime().getAgoString(BFdoc.friendInfo.lastPassTime!),
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
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    ),

                                  ),
                                  SafeArea(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.only(top: 16, bottom: 20),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Get.toNamed(AppRoutes.friendList);
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
                        ));
                      },
                    );
                    await _resortHomeViewModel.fetchBestFriendList(user_id: _userViewModel.user.user_id);
                  },
                  icon: Image.asset(
                    'assets/imgs/icons/icon_friend_resortHome.png',
                    width: 28,
                    height: 28,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () async{

                    },
                    icon: Image.asset(
                      'assets/imgs/icons/icon_alarm_resortHome.png',
                      width: 26,
                      height: 26,
                    ),
                  ),
                ),
              ],
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              centerTitle: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child:  (_userViewModel.user.within_boundary == true)
                    ? Image.asset(
                  'assets/imgs/logos/snowliveLogo_main_new_blue.png',
                  height: 38,
                )
                    : Image.asset(
                  'assets/imgs/logos/snowliveLogo_main_new.png',
                  height: 38,
                ),
              ),
              backgroundColor: SDSColor.snowliveWhite,
              foregroundColor: SDSColor.snowliveWhite,
              elevation: 0.0,
            ),
          ),
          body: RefreshIndicator(
            strokeWidth: 2,
            edgeOffset: 20,
            onRefresh: _resortHomeViewModel.onRefresh_resortHome,
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
                                                  child: Text(
                                                    '${_resortHomeViewModel.resortHomeModel.instantResortName}',
                                                    style: SDSTextStyle.bold.copyWith(
                                                        color: SDSColor.snowliveWhite,
                                                        fontSize: 16),
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
                                            onTap: () async{
                                              selectedIndex = await showModalBottomSheet<int>(
                                                constraints: BoxConstraints(
                                                  maxHeight: _size.height - _statusBarSize - 44,
                                                ),
                                                backgroundColor: Colors.transparent,
                                                context: context,
                                                isScrollControlled: true,
                                                enableDrag: false,
                                                isDismissible: false,
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
                                                  Text('${GetDatetime().getDateTime()}',
                                                    style: SDSTextStyle.regular.copyWith(
                                                        color: SDSColor.snowliveWhite.withOpacity(0.6),
                                                        fontSize: 13),
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
                                            padding: const EdgeInsets.only(right: 16),
                                            child: Container(
                                                height: 30,
                                                width: 50,
                                                child: Lottie.asset('assets/json/loadings_wht_final.json')),
                                          )
                                              : Container(
                                            height: 54,
                                            child: Center(
                                              child: Text('${_resortHomeViewModel.weatherInfo['temp']}', //u00B0
                                                style: GoogleFonts.bebasNeue(
                                                    fontSize: 44,
                                                    color: Colors.white,
                                                    height: 1.3
                                                ),
                                              ),
                                            ),
                                          ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Obx(
                                                  () => (_resortHomeViewModel.isLoading_weather == true)
                                                  ? Text(' ',
                                                style: GoogleFonts.bebasNeue(
                                                    fontSize: 44,
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
                                              _resortHomeViewModel.toggleExpandWeatherInfo();
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
                                      color: SDSColor.snowliveBlack.withOpacity(0.1),
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
                                          Text('바람',
                                            style: SDSTextStyle.regular.copyWith(
                                                color: SDSColor.snowliveWhite.withOpacity(0.6),
                                                fontSize: 12),
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Obx(() => Padding(
                                                padding:
                                                const EdgeInsets.only(right: 2),
                                                child: Text(
                                                  '${_resortHomeViewModel.weatherInfo['wind']}',
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

                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Obx(
                                                    () => Padding(
                                                  padding:
                                                  const EdgeInsets.only(right: 2),
                                                  child: Text(
                                                    '${_resortHomeViewModel.weatherInfo['wet']}',
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

                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Obx(
                                                    () => Padding(
                                                  padding: const EdgeInsets.only(right: 2),
                                                  child: Text('${_resortHomeViewModel.weatherInfo['rain']}',
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

                                          Obx(
                                                () => Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${_resortHomeViewModel.weatherInfo['minTemp']}',
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
                                                  '${_resortHomeViewModel.weatherInfo['maxTemp']}',
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
                                padding: const EdgeInsets.only(right: 28, left: 28, top: 24),
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
                              padding: EdgeInsets.only(bottom: 30, left: 16, right: 16),
                              child: Banner_resortHome(),
                            ),
                            //TODO: 구분선
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //TODO: 오늘의 기록
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4, left: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
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
                                                  child: Image.asset(
                                                    'assets/imgs/icons/icon_pin.png',
                                                    width: 18,
                                                    height: 18,
                                                  ),
                                                ),
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
                                            ),
                                        ],
                                      ),
                                    ),
                                    if(_resortHomeViewModel.resortHomeModel.dailyTotalCount != 0)
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
                                                    color: SDSColor.blue50,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('오늘 라이딩 슬로프 종류',
                                                        style: SDSTextStyle.regular.copyWith(
                                                            color: SDSColor.gray900.withOpacity(0.5),
                                                            fontSize: 14
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 4, bottom: 20),
                                                        child: Text('${_resortHomeViewModel.resortHomeModel.slopeCountInfoToday.length}',
                                                          style: SDSTextStyle.extraBold.copyWith(
                                                              color: SDSColor.gray900,
                                                              fontSize: 24
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.map<Widget>((data)  {
                                                              String slopeName = data.slope;
                                                              int passCount = data.count;
                                                              double barWidthRatio = data.ratio;
                                                              return Padding(
                                                                padding: (data != _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.last)
                                                                    ? EdgeInsets.only(bottom: 8)
                                                                    : EdgeInsets.only(bottom: 0),
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
                                                                      width: (_size.width - 148) * barWidthRatio,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                          (data == _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.first)
                                                                              ? SDSColor.snowliveBlue
                                                                              : SDSColor.blue200,
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
                                                                        width: 30,
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
                                                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                                              child: Text('$passCount',
                                                                                style: SDSTextStyle.extraBold.copyWith(
                                                                                  fontSize: 12,
                                                                                  fontWeight: (data == _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.first)
                                                                                      ? FontWeight.w900 : FontWeight.w300,
                                                                                  color: (data == _resortHomeViewModel.resortHomeModel.slopeCountInfoToday.first)
                                                                                      ? SDSColor.snowliveWhite : SDSColor.gray900.withOpacity(0.4),
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
                                                            child: Text('${_resortHomeViewModel.resortHomeModel.dailyTotalCount}회',
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
                                                                      color: SDSColor.gray900.withOpacity(0.4),
                                                                      fontWeight: FontWeight.w300,
                                                                    ),
                                                                    minFontSize: 6,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.visible,
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(top: passCount == maxCount ? 6 : 0),
                                                                    child: Container(
                                                                      width: 16,
                                                                      height: 140 * barHeightRatio,
                                                                      decoration: BoxDecoration(
                                                                          color: SDSColor.blue200,
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
                                          ),
                                        ],
                                      ),
                                    if(_resortHomeViewModel.resortHomeModel.dailyTotalCount == 0)
                                      Container(
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
