import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/controller/vm_DialogController_resortHome.dart';
import 'package:snowlive3/controller/vm_fleaChatController.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';
import 'package:snowlive3/controller/vm_liveMapController.dart';
import 'package:snowlive3/controller/vm_replyModelController.dart';
import 'package:snowlive3/model/m_resortModel.dart';
import 'package:snowlive3/screens/comments/v_commentTile_resortHome.dart';
import 'package:snowlive3/screens/discover/v_discover_Calendar_Detail.dart';
import 'package:snowlive3/screens/discover/v_discover_Resort_Banner.dart';
import 'package:snowlive3/screens/discover/v_discover_calendar.dart';
import 'package:snowlive3/screens/more/friend/v_friendDetailPage.dart';
import 'package:snowlive3/screens/more/v_noticeListPage.dart';
import 'package:snowlive3/screens/more/v_noticeTile_resortHome.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../controller/vm_commentController.dart';
import '../comments/v_liveTalk_Screen.dart';
import '../fleaMarket/v_fleaMarket_List_Screen_home.dart';
import 'package:lottie/lottie.dart';

class ResortHome extends StatefulWidget {
  @override
  State<ResortHome> createState() => _ResortHomeState();
}

class _ResortHomeState extends State<ResortHome>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int lengthOfLivefriends = 0;
  bool isSnackbarShown = false;

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  GetDateTimeController _getDateTimeController = Get.find<GetDateTimeController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  //TODO: Dependency Injection**************************************************


  List<bool?> _isSelected = List<bool?>.filled(13, false);

  ListTile buildResortListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${resortNameList[index]}'),
      //selected: _isSelected[index]!,
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

  Future<void> _onRefresh() async {
    await _userModelController
        .updateInstantResort(_userModelController.favoriteResort);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userModelController.updateIsOnLiveOff();
  }


  @override
  Widget build(BuildContext context) {
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
    Get.put(CommentModelController(), permanent: true);
    Get.put(ReplyModelController(), permanent: true);
    Get.put(FleaModelController(), permanent: true);
    Get.put(FleaChatModelController(), permanent: true);
    DialogController _dialogController = Get.put(DialogController(), permanent: true);
    //TODO: Dependency Injection**************************************************



    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return FutureBuilder(
        future: _userModelController.getLocalSave(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          _resortModelController
              .getSelectedResort(_userModelController.instantResort!);
          return WillPopScope(
              onWillPop: () {
                return Future(() => false);
              },
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .where('whoResistMeBF',
                    arrayContains: _userModelController.uid!)
                    .where('isOnLive', isEqualTo: true)
                    .snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    final liveFriendDocs = snapshot.data!.docs;
                    lengthOfLivefriends = snapshot.data!.docs.length;
                    return Obx(()=>Scaffold(
                      endDrawer: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('user')
                            .where('whoResistMeBF',
                            arrayContains: _userModelController.uid!)
                            .where('isOnLive', isEqualTo: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            // 문서가 없는 경우 처리
                            if (liveFriendDocs.isEmpty) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: Colors.white,),
                                child: Drawer(
                                  width: 240,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView(
                                          children: <Widget>[
                                            Container(
                                              height: 72,
                                              child: DrawerHeader(
                                                child: Row(
                                                  children: [
                                                    (lengthOfLivefriends >= 1)
                                                        ? Image.asset(
                                                      'assets/imgs/logos/icon_liveFriend_dot.png',
                                                      width: 24,
                                                      height: 24,
                                                    )
                                                        : Image.asset(
                                                      'assets/imgs/logos/icon_liveFriend.png',
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),// 여기서 아이콘
                                                    Text('라이브중인 친구', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111111)),),
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            ListView.builder(
                                                shrinkWrap: true,
                                                // 사용하면 안의 ListView의 높이를 자식 위젯의 전체 높이로 설정합니다.
                                                physics: NeverScrollableScrollPhysics(),
                                                // 부모 ListView의 스크롤과 겹치지 않도록 합니다.
                                                itemCount: 1,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    contentPadding: EdgeInsets.only(top: 16, bottom: 0, right: 16, left: 16),
                                                    title: Padding(
                                                      padding: const EdgeInsets.only(bottom: 4),
                                                      child: Text('라이브중인 친구가 없습니다.', style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF111111)
                                                      ),),
                                                    ),
                                                    subtitle: Text('즐겨찾는 친구를 등록하고\n친구의 라이브 상태를 확인하세요.',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.normal,
                                                          color: Color(0xFF949494)
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.white,),
                              child: Drawer(
                                width: 240,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ListView(
                                        children: <Widget>[
                                          Container(
                                            height: 72,
                                            child: DrawerHeader(
                                              child: Row(
                                                children: [
                                                  (lengthOfLivefriends >= 1)
                                                      ? Image.asset(
                                                    'assets/imgs/logos/icon_liveFriend_dot.png',
                                                    width: 24,
                                                    height: 24,
                                                  )
                                                      : Image.asset(
                                                    'assets/imgs/logos/icon_liveFriend.png',
                                                    width: 24,
                                                    height: 24,
                                                  ),
                                                  SizedBox(
                                                    width: 6,
                                                  ),// 여기서 아이콘
                                                  Text('라이브중인 친구', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111111)),),
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              // 사용하면 안의 ListView의 높이를 자식 위젯의 전체 높이로 설정합니다.
                                              physics: NeverScrollableScrollPhysics(),
                                              // 부모 ListView의 스크롤과 겹치지 않도록 합니다.
                                              itemCount: liveFriendDocs.length,
                                              itemBuilder: (context, index) {
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                      contentPadding: EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
                                                      title: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              (liveFriendDocs[index]['profileImageUrl'] != "")
                                                                  ? GestureDetector(
                                                                onTap: (){
                                                                  Get.to(()=>FriendDetailPage(uid: liveFriendDocs[index]['uid'], favoriteResort: liveFriendDocs[index]['favoriteResort'],));
                                                                },
                                                                    child: ExtendedImage.network(
                                                                liveFriendDocs[index]
                                                                ['profileImageUrl'],
                                                                enableMemoryCache: true,
                                                                shape: BoxShape.circle,
                                                                borderRadius:
                                                                BorderRadius.circular(8),
                                                                width: 36,
                                                                height: 36,
                                                                fit: BoxFit.cover,
                                                              ),
                                                                  )
                                                                  : GestureDetector(
                                                                onTap: (){
                                                                  Get.to(()=>FriendDetailPage(uid: liveFriendDocs[index]['uid'], favoriteResort: liveFriendDocs[index]['favoriteResort'],));
                                                                },
                                                                    child: ExtendedImage.asset(
                                                                'assets/imgs/profile/img_profile_default_circle.png',
                                                                enableMemoryCache: true,
                                                                shape: BoxShape.circle,
                                                                borderRadius:
                                                                BorderRadius.circular(8),
                                                                width: 36,
                                                                height: 36,
                                                                fit: BoxFit.cover,
                                                              ),
                                                                  ),
                                                              SizedBox(width: 10),
                                                              Text(
                                                                '${liveFriendDocs[index]['displayName']}', style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.normal,
                                                                  color: Color(0xFF111111)
                                                              ),),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (index != liveFriendDocs.length - 1)  // 마지막 요소가 아니라면
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                                        child: Divider(
                                                          color: Color(0xFFECECEC),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
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
                                    await _userModelController.getCurrentUserLocationInfo(_userModelController.uid);
                                    setState(() {});
                                    CustomFullScreenDialog.cancelDialog();
                                    print('라이브 OFF');
                                  }
                                } else {
                                  if(!isSnackbarShown) {
                                  CustomFullScreenDialog.showDialog();
                                  HapticFeedback.lightImpact();
                                  await _liveMapController.startForegroundLocationService();
                                  await Future.delayed(Duration(seconds: 2)); // Wait for 1 second
                                  await _userModelController.getCurrentUserLocationInfo(_userModelController.uid);
                                  if (_userModelController.withinBoundary == true) {
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
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF111111)
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text("위치를 사용하시면 라이브 기능을 통해 랭킹 서비스를 이용할 수 있고, 친구와 라이브 상태를 공유할 수 있어요. 이 앱은 앱이 사용 중이 아닐 때도 위치 데이터를 수집하여 라이브 서비스 기능을 지원합니다.",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.normal,
                                                        color: Color(0xFF949494)
                                                    ),
                                                  ),
                                                  SizedBox(height: 24),
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

                                                  SizedBox(height: 24),
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
                                                    height: 28,
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
                                                          onPressed: _dialogController.isChecked.value
                                                              ? () async {
                                                            Get.back();
                                                            await _userModelController.updateIsOnLiveOn();
                                                            await _liveMapController.startForegroundLocationService();
                                                            await _userModelController.getCurrentUser(_userModelController.uid);
                                                            CustomFullScreenDialog.cancelDialog();
                                                            print('라이브 ON');
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


                                  } else {
                                    CustomFullScreenDialog.cancelDialog();
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
                                  }}
                                  setState(() {});
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
                                      color: Color(0xFF949494),
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
                      backgroundColor: Color(0xFFF1F1F3),
                      extendBodyBehindAppBar: true,
                      appBar: PreferredSize(
                        preferredSize: Size.fromHeight(58),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AppBar(
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: Builder(
                                    builder: (BuildContext context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: IconButton(
                                          icon: (lengthOfLivefriends >= 1)
                                              ? OverflowBox(
                                            maxHeight: 40,
                                            maxWidth: 38,
                                                child: Image.asset(
                                            'assets/imgs/logos/icon_liveFriend_dot.png',
                                          ),
                                              )
                                              : OverflowBox(
                                            maxHeight: 40,
                                            maxWidth: 38,
                                                child: Image.asset(
                                                'assets/imgs/logos/icon_liveFriend.png',
                                          ),
                                              ), // 여기서 아이콘 변경
                                          onPressed: () {
                                            Scaffold.of(context).openEndDrawer();
                                          },
                                          tooltip:
                                          MaterialLocalizations.of(context)
                                              .openAppDrawerTooltip,
                                        ),
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
                              backgroundColor: Color(0xFFF1F1F3),
                              elevation: 0.0,
                            )
                          ],
                        ),
                      ),
                      body: RefreshIndicator(
                        strokeWidth: 2,
                        edgeOffset: 40,
                        onRefresh: _onRefresh,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: _statusBarSize + 64,
                              ),
                              Container(
                                color: Color(0xFFF2F4F6),
                                child: Padding(
                                    padding:
                                    EdgeInsets.only(left: 16, right: 16),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Obx(
                                              () => Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(14),
                                                color: (_resortModelController.isLoading == true)
                                                    ? Color(0xffc8c8c8)
                                                    : _resortModelController
                                                    .weatherColors),
                                            alignment: Alignment.center,
                                            width: double.infinity,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 40,
                                                ),
                                                GestureDetector(
                                                  child: Obx(
                                                        () => Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: Text(
                                                            '${_resortModelController.resortName}',
                                                            style: TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 23),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 3,
                                                        ),
                                                        Image.asset(
                                                          'assets/imgs/icons/icon_dropdown.png',
                                                          width: 18,
                                                          height: 18,
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
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  '스키장을 선택해주세요.',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      20,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  '관심있는 스키장을 선택해 스키장과 관련된 실시간 날씨 정보와 웹캠, 슬로프 오픈 현황 등을 확인하세요.',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      14,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                      color: Color(
                                                                          0xFF666666)),
                                                                ),
                                                                Container(
                                                                  color: Colors
                                                                      .white,
                                                                  height: 30,
                                                                ),
                                                                Expanded(
                                                                  child: ListView
                                                                      .builder(
                                                                      padding: EdgeInsets
                                                                          .zero,
                                                                      itemCount:
                                                                      13,
                                                                      itemBuilder:
                                                                          (context, index) {
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
                                                  height: 36,
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 16),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      children: [
                                                        Text(
                                                          '${_getDateTimeController.date}',
                                                          style: TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontWeight:
                                                              FontWeight
                                                                  .normal,
                                                              fontSize: 14),
                                                        ),
                                                        Transform.translate(
                                                            offset:
                                                            Offset(-2, 0),
                                                            child: _resortModelController
                                                                .weatherIcons),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Obx(
                                                          () => Padding(
                                                        padding: EdgeInsets.only(right: 4, left: 12),
                                                        child: (_resortModelController
                                                            .isLoading ==
                                                            true)
                                                            ? Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 51),
                                                          child: Container(
                                                              height: 30,
                                                              width: 50,
                                                              child: Lottie
                                                                  .asset(
                                                                  'assets/json/loadings_wht_final.json')),
                                                        )
                                                            : Text('${_resortModelController.resortTemp!}',
                                                          //u00B0
                                                          style: GoogleFonts.bebasNeue(
                                                              fontSize: 110,
                                                              color: Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    Obx(
                                                          () => Padding(
                                                        padding:
                                                        const EdgeInsets.only(top: 12),
                                                        child: (_resortModelController.isLoading == true)
                                                            ? Text(' ',
                                                          style: GoogleFonts.bebasNeue(
                                                              fontSize: 60,
                                                              color: Colors.white),
                                                        )
                                                            : Text('\u00B0',
                                                          style: GoogleFonts.bebasNeue(
                                                              fontSize: 60,
                                                              color: Colors.white),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                ),
                                                //실시간 날씨
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text('바람',
                                                          style: TextStyle(
                                                              color: Colors.white60,
                                                              fontSize: 13),
                                                        ),
                                                        SizedBox(
                                                          height: 6,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Obx(
                                                                  () => Padding(
                                                                padding:
                                                                const EdgeInsets.only(
                                                                    right: 3),
                                                                child: Text(
                                                                  '${_resortModelController.resortWind}',
                                                                  style: GoogleFonts.bebasNeue(
                                                                      fontSize: 28,
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom:
                                                                  5),
                                                              child: Text(
                                                                'M/S',
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
                                                          '습도',
                                                          style: TextStyle(
                                                              color: Colors.white60,
                                                              fontSize: 13),
                                                        ),
                                                        SizedBox(
                                                          height: 6,
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
                                                                      fontSize: 28,
                                                                      color: Colors.white),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets.only(bottom:
                                                              5),
                                                              child: Text(
                                                                '%',
                                                                style: GoogleFonts
                                                                    .bebasNeue(
                                                                    fontSize:
                                                                    16,
                                                                    color: Colors
                                                                        .white),
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
                                                              fontSize: 13),
                                                        ),
                                                        SizedBox(
                                                          height: 6,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Obx(
                                                                  () => Padding(
                                                                padding: const EdgeInsets.only(right: 3),
                                                                child: Text('${_resortModelController.resortRain}',
                                                                  style: GoogleFonts.bebasNeue(
                                                                      fontSize: 28,
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
                                                              color: Colors
                                                                  .white60,
                                                              fontSize: 13),
                                                        ),
                                                        SizedBox(
                                                          height: 6,
                                                        ),
                                                        Obx(
                                                              () => Row(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                            children: [
                                                              Text(
                                                                '${_resortModelController.resortMinTemp}',
                                                                style: GoogleFonts
                                                                    .bebasNeue(
                                                                    fontSize:
                                                                    28,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom:
                                                                    5,
                                                                    left: 3,
                                                                    right:
                                                                    2),
                                                                child: Text(
                                                                  '/',
                                                                  style: GoogleFonts.bebasNeue(
                                                                      fontSize:
                                                                      16,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                              Text(
                                                                '${_resortModelController.resortMaxTemp}',
                                                                style: GoogleFonts
                                                                    .bebasNeue(
                                                                    fontSize:
                                                                    28,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 40,
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
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(14)),
                                              height: 107,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 32, left: 32, top: 22, bottom: 22),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Get.to(
                                                            Obx(() => WebPage(url: '${_resortModelController.naverUrl}',
                                                          ),
                                                        ));
                                                      },
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/imgs/icons/icon_home_naver.png',
                                                            width: 40,
                                                            height: 40,
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            '네이버 날씨',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .w400,
                                                                fontSize: 12,
                                                                color: Color(
                                                                    0xFF111111)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Get.to((_resortModelController
                                                            .webcamUrl !=
                                                            '')
                                                            ? Obx(
                                                              () => WebPage(
                                                            url:
                                                            '${_resortModelController.webcamUrl}',
                                                          ),
                                                        )
                                                            : null);
                                                      },
                                                      child: Column(
                                                        children: [
                                                          (_resortModelController
                                                              .webcamUrl !=
                                                              '')
                                                              ? Image.asset(
                                                            'assets/imgs/icons/icon_home_livecam.png',
                                                            width: 40,
                                                            height: 40,
                                                          )
                                                              : Image.asset(
                                                            'assets/imgs/icons/icon_home_livecam_off.png',
                                                            width: 40,
                                                            height: 40,
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            '실시간 웹캠',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .w400,
                                                                fontSize: 12,
                                                                color: (_resortModelController
                                                                    .webcamUrl !=
                                                                    '')
                                                                    ? Color(
                                                                    0xFF111111)
                                                                    : Color(
                                                                    0xFFC8C8C8)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Get.to((_resortModelController
                                                            .slopeUrl !=
                                                            '')
                                                            ? Obx(
                                                              () => WebPage(
                                                            url:
                                                            '${_resortModelController.slopeUrl}',
                                                          ),
                                                        )
                                                            : null);
                                                      },
                                                      child: Column(
                                                        children: [
                                                          (_resortModelController
                                                              .slopeUrl !=
                                                              '')
                                                              ? Image.asset(
                                                            'assets/imgs/icons/icon_home_slope.png',
                                                            width: 40,
                                                            height: 40,
                                                          )
                                                              : Image.asset(
                                                            'assets/imgs/icons/icon_home_slope_off.png',
                                                            width: 40,
                                                            height: 40,
                                                          ),
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            '슬로프 현황',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: 12,
                                                                color: (_resortModelController.slopeUrl != '')
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
                                              child: DiscoverScreen_ResortBanner(),
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                Get.to(()=>Discover_Calendar_Detail_Screen());
                                              },
                                                child: DiscoverScreen_Calendar()),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                Get.offAll(()=>MainHome(uid: _userModelController.uid, initialPage: 3));
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 22),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(14)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '라이브톡',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFFC8C8C8)),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      CommentTile_resortHome(),
                                                    ],
                                                  )),
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(14)),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          '스노우마켓',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFFC8C8C8)),
                                                        ),
                                                        // ElevatedButton(onPressed: (){
                                                        //   Get.to(() => FleaMarketScreen());
                                                        //
                                                        // },
                                                        //     child: Text('더보기', style:
                                                        //     TextStyle(
                                                        //         fontWeight: FontWeight.bold,
                                                        //         fontSize: 13,
                                                        //         color: Color(0xFF949494),
                                                        // ),),
                                                        //   style: ElevatedButton.styleFrom(
                                                        //     minimumSize: Size(42, 34),
                                                        //     backgroundColor: Color(0xFFF2F3F4),
                                                        //     shape: RoundedRectangleBorder(
                                                        //         borderRadius: BorderRadius.circular(8)),
                                                        //     elevation: 0,
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 16,
                                                    ),
                                                    FleaMarket_List_Screen_Home(),
                                                  ],
                                                )),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(left: 20, right: 20, top: 26, bottom: 24),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(14)),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Get.to(() => NoticeList());
                                                  },
                                                  child:
                                                  NoticeTile_resortHome(),
                                                )),
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
                                                          'Copyright by 134CreativeLab 2022.',
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
                                          ],
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
                  }
                  return Obx(()=>Scaffold(
                    endDrawer: Center(child: CircularProgressIndicator()),
                    floatingActionButton: SizedBox(
                      width: 118,
                      height: 54,
                      child: FloatingActionButton.extended(
                          onPressed: () async {
                            if (_userModelController.isOnLive == true) {
                              HapticFeedback.lightImpact();
                              _dialogController.isChecked.value = false;
                              CustomFullScreenDialog.showDialog();
                              await _userModelController.updateIsOnLiveOff();
                              await _liveMapController.stopForegroundLocationService();
                              await _liveMapController.stopBackgroundLocationService();
                              await _liveMapController.checkAndUpdatePassCountOff();
                              await _userModelController.getCurrentUserLocationInfo(_userModelController.uid);
                              setState(() {});
                              CustomFullScreenDialog.cancelDialog();
                              print('라이브 OFF');
                            } else {
                              HapticFeedback.lightImpact();
                              CustomFullScreenDialog.showDialog();
                              await _liveMapController.startForegroundLocationService();
                              await Future.delayed(Duration(seconds: 2)); // Wait for 1 second
                              await _userModelController.getCurrentUserLocationInfo(_userModelController.uid);
                              if(_userModelController.withinBoundary == true) {
                                Get.dialog(
                                  WillPopScope(
                                    onWillPop: () async => false, // Prevents dialog from closing on Android back button press
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () async{
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
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF111111)
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Text("위치를 사용하시면 라이브 기능을 통해 랭킹 서비스를 이용할 수 있고, 친구와 라이브 상태를 공유할 수 있어요. 이 앱은 앱이 사용 중이 아닐 때도 위치 데이터를 수집하여 라이브 서비스 기능을 지원합니다.",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.normal,
                                                    color: Color(0xFF949494)
                                                ),
                                              ),
                                              SizedBox(height: 24),
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

                                              SizedBox(height: 24),
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
                                                height: 28,
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
                                                      onPressed: _dialogController.isChecked.value
                                                          ? () async {
                                                        Get.back();
                                                        await _userModelController.updateIsOnLiveOn();
                                                        await _liveMapController.startForegroundLocationService();
                                                        await _userModelController.getCurrentUser(_userModelController.uid);
                                                        CustomFullScreenDialog.cancelDialog();
                                                        print('라이브 ON');
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
                              }else{
                                CustomFullScreenDialog.cancelDialog();
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
                                  Future.delayed(Duration(milliseconds: 2500), () {
                                    isSnackbarShown = false;
                                  });
                                  print('라이브 불가 지역');
                                }
                                await _liveMapController.stopForegroundLocationService();
                                await _liveMapController.stopBackgroundLocationService();
                              }
                              setState(() {});
                            }
                          },
                          icon: (_userModelController.isOnLive == true  && _userModelController.withinBoundary ==true)
                              ? Image.asset('assets/imgs/icons/icon_live_on.png', width: 50)
                              : Image.asset('assets/imgs/icons/icon_live_off.png', width: 50),
                          label: (_userModelController.isOnLive == true  && _userModelController.withinBoundary ==true)
                              ? Text(
                            'live on',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis),
                          )
                              : Text(
                            'live off',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis),
                          ),
                          backgroundColor: (_userModelController.isOnLive == true  && _userModelController.withinBoundary ==true)
                              ? Color(0xFF3D83ED)
                              : Colors.grey),

                  ),
                    floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                    backgroundColor: Color(0xFFF1F1F3),
                    extendBodyBehindAppBar: true,
                    appBar: PreferredSize(
                      preferredSize: Size.fromHeight(58),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppBar(
                            actions: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Builder(
                                  builder: (BuildContext context) {
                                    return IconButton(
                                      icon: (lengthOfLivefriends >= 1)
                                          ? Image.asset(
                                        'assets/imgs/logos/icon_liveFriend_dot.png',
                                        width: 40,
                                        height: 40,
                                      )
                                          : Image.asset(
                                        'assets/imgs/logos/icon_liveFriend.png',
                                        width: 40,
                                        height: 40,
                                      ), // 여기서 아이콘 변경
                                      onPressed: () {
                                        Scaffold.of(context).openEndDrawer();
                                      },
                                      tooltip: MaterialLocalizations.of(context)
                                          .openAppDrawerTooltip,
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
                            backgroundColor: Color(0xFFF1F1F3),
                            elevation: 0.0,
                          )
                        ],
                      ),
                    ),
                    body: RefreshIndicator(
                      strokeWidth: 2,
                      edgeOffset: 40,
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: _statusBarSize + 64,
                            ),
                            Container(
                              color: Color(0xFFF2F4F6),
                              child: Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Obx(
                                            () => Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(14),
                                              color: (_resortModelController
                                                  .isLoading ==
                                                  true)
                                                  ? Color(0xffc8c8c8)
                                                  : _resortModelController
                                                  .weatherColors),
                                          alignment: Alignment.center,
                                          width: double.infinity,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 40,
                                              ),
                                              GestureDetector(
                                                child: Obx(
                                                      () => Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(left: 10),
                                                        child: Text(
                                                          '${_resortModelController.resortName}',
                                                          style: TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              fontSize: 23),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 3,
                                                      ),
                                                      Image.asset(
                                                        'assets/imgs/icons/icon_dropdown.png',
                                                        width: 18,
                                                        height: 18,
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
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              20,
                                                              vertical: 30),
                                                          height: _size.height *
                                                              0.8,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text(
                                                                '스키장을 선택해주세요.',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                    20,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                '관심있는 스키장을 선택해 스키장과 관련된 실시간 날씨 정보와 웹캠, 슬로프 오픈 현황 등을 확인하세요.',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                    14,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                    color: Color(
                                                                        0xFF666666)),
                                                              ),
                                                              Container(
                                                                color: Colors
                                                                    .white,
                                                                height: 30,
                                                              ),
                                                              Expanded(
                                                                child: ListView
                                                                    .builder(
                                                                    padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                    itemCount:
                                                                    13,
                                                                    itemBuilder:
                                                                        (context,
                                                                        index) {
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
                                                height: 36,
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 16),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        '${_getDateTimeController.date}',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                            FontWeight
                                                                .normal,
                                                            fontSize: 14),
                                                      ),
                                                      Transform.translate(
                                                          offset: Offset(-2, 0),
                                                          child:
                                                          _resortModelController
                                                              .weatherIcons),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Obx(
                                                        () => Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 4, left: 12),
                                                      child:
                                                      (_resortModelController
                                                          .isLoading ==
                                                          true)
                                                          ? Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            vertical:
                                                            51),
                                                        child: Container(
                                                            height:
                                                            30,
                                                            width: 50,
                                                            child: Lottie
                                                                .asset(
                                                                'assets/json/loadings_wht_final.json')),
                                                      )
                                                          : Text(
                                                        '${_resortModelController.resortTemp!}',
                                                        //u00B0
                                                        style: GoogleFonts.bebasNeue(
                                                            fontSize:
                                                            110,
                                                            color: Colors
                                                                .white),
                                                      ),
                                                    ),
                                                  ),
                                                  Obx(
                                                        () => Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          top: 12),
                                                      child:
                                                      (_resortModelController
                                                          .isLoading ==
                                                          true)
                                                          ? Text(
                                                        ' ',
                                                        style: GoogleFonts.bebasNeue(
                                                            fontSize:
                                                            60,
                                                            color: Colors
                                                                .white),
                                                      )
                                                          : Text(
                                                        '\u00B0',
                                                        style: GoogleFonts.bebasNeue(
                                                            fontSize:
                                                            60,
                                                            color: Colors
                                                                .white),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              //실시간 날씨
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceEvenly,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text('바람',
                                                        style: TextStyle(
                                                            color: Colors.white60,
                                                            fontSize: 13),
                                                      ),
                                                      SizedBox(height: 6,),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Obx(
                                                                () => Padding(
                                                              padding: const EdgeInsets.only(right: 3),
                                                              child: Text(
                                                                '${_resortModelController.resortWind}',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 28,
                                                                    color: Colors.white),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets.only(bottom: 5),
                                                            child: Text(
                                                              'M/S',
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
                                                      Text('습도',
                                                        style: TextStyle(
                                                            color: Colors.white60,
                                                            fontSize: 13),
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Obx(
                                                                () => Padding(
                                                              padding: const EdgeInsets.only(right: 3),
                                                              child: Text(
                                                                '${_resortModelController.resortWet}',
                                                                style: GoogleFonts.bebasNeue(
                                                                    fontSize: 28,
                                                                    color: Colors.white),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 5),
                                                            child: Text('%',
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
                                                        '강수',
                                                        style: TextStyle(
                                                            color:
                                                            Colors.white60,
                                                            fontSize: 13),
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .end,
                                                        children: [
                                                          Obx(
                                                                () => Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 3),
                                                              child: Text(
                                                                '${_resortModelController.resortRain}',
                                                                style: GoogleFonts
                                                                    .bebasNeue(
                                                                    fontSize:
                                                                    28,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 5),
                                                            child: Text(
                                                              'MM',
                                                              style: GoogleFonts
                                                                  .bebasNeue(
                                                                  fontSize:
                                                                  16,
                                                                  color: Colors
                                                                      .white),
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
                                                            color:
                                                            Colors.white60,
                                                            fontSize: 13),
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Obx(
                                                            () => Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                          children: [
                                                            Text(
                                                              '${_resortModelController.resortMinTemp}',
                                                              style: GoogleFonts
                                                                  .bebasNeue(
                                                                  fontSize:
                                                                  28,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 5,
                                                                  left: 3,
                                                                  right: 2),
                                                              child: Text(
                                                                '/',
                                                                style: GoogleFonts
                                                                    .bebasNeue(
                                                                    fontSize:
                                                                    16,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                            Text(
                                                              '${_resortModelController.resortMaxTemp}',
                                                              style: GoogleFonts
                                                                  .bebasNeue(
                                                                  fontSize:
                                                                  28,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 40,
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
                                                color: Colors.white,
                                                borderRadius:
                                                BorderRadius.circular(14)),
                                            height: 107,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 32,
                                                  left: 32,
                                                  top: 22,
                                                  bottom: 22),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.to(Obx(
                                                            () => WebPage(
                                                          url:
                                                          '${_resortModelController.naverUrl}',
                                                        ),
                                                      ));
                                                    },
                                                    child: Column(
                                                      children: [
                                                        Image.asset(
                                                          'assets/imgs/icons/icon_home_naver.png',
                                                          width: 40,
                                                          height: 40,
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          '네이버 날씨',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF111111)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.to((_resortModelController
                                                          .webcamUrl !=
                                                          '')
                                                          ? Obx(
                                                            () => WebPage(
                                                          url:
                                                          '${_resortModelController.webcamUrl}',
                                                        ),
                                                      )
                                                          : null);
                                                    },
                                                    child: Column(
                                                      children: [
                                                        (_resortModelController
                                                            .webcamUrl !=
                                                            '')
                                                            ? Image.asset(
                                                          'assets/imgs/icons/icon_home_livecam.png',
                                                          width: 40,
                                                          height: 40,
                                                        )
                                                            : Image.asset(
                                                          'assets/imgs/icons/icon_home_livecam_off.png',
                                                          width: 40,
                                                          height: 40,
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          '실시간 웹캠',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                              fontSize: 12,
                                                              color: (_resortModelController
                                                                  .webcamUrl !=
                                                                  '')
                                                                  ? Color(
                                                                  0xFF111111)
                                                                  : Color(
                                                                  0xFFC8C8C8)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.to(
                                                          (_resortModelController
                                                              .slopeUrl !=
                                                              '')
                                                              ? Obx(
                                                                () => WebPage(
                                                              url:
                                                              '${_resortModelController.slopeUrl}',
                                                            ),
                                                          )
                                                              : null);
                                                    },
                                                    child: Column(
                                                      children: [
                                                        (_resortModelController
                                                            .slopeUrl !=
                                                            '')
                                                            ? Image.asset(
                                                          'assets/imgs/icons/icon_home_slope.png',
                                                          width: 40,
                                                          height: 40,
                                                        )
                                                            : Image.asset(
                                                          'assets/imgs/icons/icon_home_slope_off.png',
                                                          width: 40,
                                                          height: 40,
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          '슬로프 현황',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                              fontSize: 12,
                                                              color: (_resortModelController
                                                                  .slopeUrl !=
                                                                  '')
                                                                  ? Color(
                                                                  0xFF111111)
                                                                  : Color(
                                                                  0xFFC8C8C8)),
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
                                          DiscoverScreen_ResortBanner(),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                                top: 20,
                                                bottom: 5),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.only(
                                                topLeft: Radius.circular(14),
                                                topRight: Radius.circular(14),
                                                bottomLeft: Radius.zero,
                                                bottomRight: Radius.zero,
                                              ),),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '캘린더',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color:
                                                      Color(0xFFC8C8C8)),
                                                ),
                                                GestureDetector(
                                                  onTap: (){
                                                    Get.to(()=>Discover_Calendar_Detail_Screen());
                                                  },
                                                  child: Container(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(right: 10),
                                                      child: Text(
                                                        '더보기',
                                                        style: TextStyle(
                                                            color: Color(0xFF949494),
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),),
                                          DiscoverScreen_Calendar(),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          GestureDetector(
                                            onTap: (){
                                              Get.offAll(()=>MainHome(uid: _userModelController.uid, initialPage: 3));
                                            },
                                            child: Container(
                                                padding: EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 20,
                                                    bottom: 22),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        14)),
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '라이브톡',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color:
                                                          Color(0xFFC8C8C8)),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    CommentTile_resortHome(),
                                                  ],
                                                )),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                  top: 20,
                                                  bottom: 10),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      14)),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '스노우마켓',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            color: Color(
                                                                0xFFC8C8C8)),
                                                      ),
                                                      // ElevatedButton(onPressed: (){
                                                      //   Get.to(() => FleaMarketScreen());
                                                      //
                                                      // },
                                                      //     child: Text('더보기', style:
                                                      //     TextStyle(
                                                      //         fontWeight: FontWeight.bold,
                                                      //         fontSize: 13,
                                                      //         color: Color(0xFF949494),
                                                      // ),),
                                                      //   style: ElevatedButton.styleFrom(
                                                      //     minimumSize: Size(42, 34),
                                                      //     backgroundColor: Color(0xFFF2F3F4),
                                                      //     shape: RoundedRectangleBorder(
                                                      //         borderRadius: BorderRadius.circular(8)),
                                                      //     elevation: 0,
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  FleaMarket_List_Screen_Home(),
                                                ],
                                              )),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                  top: 26,
                                                  bottom: 24),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      14)),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Get.to(() => NoticeList());
                                                },
                                                child: NoticeTile_resortHome(),
                                              )),
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
                                                        fontWeight:
                                                        FontWeight.normal),
                                                  ),
                                                  TextSpan(
                                                    text: '기상청',
                                                    style: TextStyle(
                                                        decoration:
                                                        TextDecoration
                                                            .underline,
                                                        decorationThickness: 2,
                                                        fontSize: 13,
                                                        color:
                                                        Color(0xFF80B2FF),
                                                        fontWeight:
                                                        FontWeight.normal),
                                                  ),
                                                  TextSpan(
                                                    text: ' 정보입니다',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                        Color(0xFFc8c8c8),
                                                        fontWeight:
                                                        FontWeight.normal),
                                                  )
                                                ],
                                              ),
                                            ),
                                            onPressed: () {
                                              Get.dialog(AlertDialog(
                                                contentPadding: EdgeInsets.only(
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
                                                            child: ExtendedImage
                                                                .asset(
                                                              'assets/imgs/logos/weather_logo.png',
                                                              fit: BoxFit.cover,
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
                                                            FontWeight.w600,
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
                                                        Navigator.pop(context);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(
                                                            bottom: 1),
                                                        child: Text(
                                                          '확인',
                                                          style: TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
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
                                                            .only(top: 16),
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
                                                              borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
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
                                                  BorderRadius.circular(6)),
                                              elevation: 0,
                                              backgroundColor:
                                              Colors.black12.withOpacity(0),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 5),
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
                                                        'Copyright by 134CreativeLab 2022.',
                                                        style: TextStyle(
                                                          color:
                                                          Color(0xFFc8c8c8),
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                        'All right reserved.',
                                                        style: TextStyle(
                                                          color:
                                                          Color(0xFFc8c8c8),
                                                          fontWeight:
                                                          FontWeight.normal,
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
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ));
                },
              ));
        });
  }
}
