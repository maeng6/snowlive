import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';
import 'package:snowlive3/model/m_resortModel.dart';
import 'package:snowlive3/screens/comments/v_commentTile_resortHome.dart';
import 'package:snowlive3/screens/comments/v_commentScreen_liveTalk_resortHome.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import '../../controller/vm_commentController.dart';

class ResortHome extends StatefulWidget {
  @override
  State<ResortHome> createState() => _ResortHomeState();
}

class _ResortHomeState extends State<ResortHome> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();

  ResortModelController _resortModelController =
      Get.find<ResortModelController>();

  GetDateTimeController _getDateTimeController =
      Get.find<GetDateTimeController>();

  //TODO: Dependency Injection**************************************************

  List<bool?> _isSelected = List<bool?>.filled(13, false);

  ListTile buildResortListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${resortNameList[index]}'),
      //selected: _isSelected[index]!,
      onTap: () async {
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

  void _onRefresh() async {
    await _userModelController
        .updateInstantResort(_userModelController.favoriteResort);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
            child: Scaffold(
              backgroundColor: Color(0xFFF2F4F6),
              extendBodyBehindAppBar: true,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(58),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AppBar(
                      systemOverlayStyle: SystemUiOverlayStyle.dark,
                      centerTitle: false,
                      titleSpacing: 0,
                      title: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Image.asset(
                          'assets/imgs/logos/snowliveLogo_black.png',
                          width: 112,
                          height: 38,
                        ),
                      ),
                      backgroundColor: Color(0xFFF2F4F6),
                      elevation: 0.0,
                    )
                  ],
                ),
              ),
              body: SingleChildScrollView(
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Obx(
                                () => Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color:
                                          (_resortModelController.isLoading ==
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
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(
                                                  '${_resortModelController.resortName}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 23),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 2,
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
                                          showMaterialModalBottomSheet(
                                              enableDrag: false,
                                              context: context,
                                              builder: (context) {
                                                return Container(
                                                  color: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 30),
                                                  height: _size.height * 0.8,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '리조트를 선택해주세요.',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        '관심있는 리조트를 선택해 리조트와 관련된 실시간 날씨 정보와 웹캠, 슬로프 오픈 현황 등을 확인하세요.',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Color(
                                                                0xFF666666)),
                                                      ),
                                                      Container(
                                                        color: Colors.white,
                                                        height: 30,
                                                      ),
                                                      Expanded(
                                                        child: ListView.builder(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            itemCount: 13,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return Builder(
                                                                  builder:
                                                                      (context) {
                                                                return Column(
                                                                  children: [
                                                                    buildResortListTile(
                                                                        index),
                                                                    Divider(
                                                                      height:
                                                                          20,
                                                                      thickness:
                                                                          0.5,
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
                                        height: 4,
                                      ),
                                      SizedBox(
                                        height: 30,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${_getDateTimeController.date}',
                                                style: TextStyle(
                                                    color: Colors.white54,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 14),
                                              ),
                                              Transform.translate(
                                                  offset: Offset(-2, 1),
                                                  child: _resortModelController
                                                      .weatherIcons),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 24,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Obx(
                                            () => Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4, left: 12),
                                              child: (_resortModelController
                                                          .isLoading ==
                                                      true)
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 51),
                                                      child: Container(
                                                          height: 30,
                                                          width: 30,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.3),
                                                          )),
                                                    )
                                                  : Text(
                                                      '${_resortModelController.resortTemp!}',
                                                      //u00B0
                                                      style:
                                                          GoogleFonts.bebasNeue(
                                                              fontSize: 110,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                            ),
                                          ),
                                          Obx(
                                            () => Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 14),
                                              child: (_resortModelController
                                                          .isLoading ==
                                                      true)
                                                  ? Text(
                                                      '',
                                                      style:
                                                          GoogleFonts.bebasNeue(
                                                              fontSize: 60,
                                                              color:
                                                                  Colors.white),
                                                    )
                                                  : Text(
                                                      '\u00B0',
                                                      style:
                                                          GoogleFonts.bebasNeue(
                                                              fontSize: 60,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      //실시간 날씨
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                '바람',
                                                style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 13),
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Obx(
                                                    () => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 3),
                                                      child: Text(
                                                        '${_resortModelController.resortWind}',
                                                        style: GoogleFonts
                                                            .bebasNeue(
                                                                fontSize: 28,
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: Text(
                                                      'M/S',
                                                      style:
                                                          GoogleFonts.bebasNeue(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Obx(
                                                    () => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 3),
                                                      child: Text(
                                                        '${_resortModelController.resortWet}',
                                                        style: GoogleFonts
                                                            .bebasNeue(
                                                                fontSize: 28,
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: Text(
                                                      '%',
                                                      style:
                                                          GoogleFonts.bebasNeue(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Obx(
                                                    () => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 3),
                                                      child: Text(
                                                        '${_resortModelController.resortRain}',
                                                        style: GoogleFonts
                                                            .bebasNeue(
                                                                fontSize: 28,
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: Text(
                                                      'MM',
                                                      style:
                                                          GoogleFonts.bebasNeue(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
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
                                                    fontSize: 13),
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Obx(
                                                () => Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${_resortModelController.resortMinTemp}',
                                                      style:
                                                          GoogleFonts.bebasNeue(
                                                              fontSize: 28,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 5,
                                                              left: 3,
                                                              right: 2),
                                                      child: Text(
                                                        '/',
                                                        style: GoogleFonts
                                                            .bebasNeue(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${_resortModelController.resortMaxTemp}',
                                                      style:
                                                          GoogleFonts.bebasNeue(
                                                              fontSize: 28,
                                                              color:
                                                                  Colors.white),
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
                                      padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 15,
                                          bottom: 17),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      child: CommentTile_resortHome()),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    height: 101,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 32,
                                          left: 32,
                                          top: 22,
                                          bottom: 18),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                  width: 34,
                                                  height: 34,
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '네이버 날씨',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Color(0xFF111111)),
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
                                                        width: 34,
                                                        height: 34,
                                                      )
                                                    : Image.asset(
                                                        'assets/imgs/icons/icon_home_livecam_off.png',
                                                        width: 34,
                                                        height: 34,
                                                      ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '실시간 웹캠',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: (_resortModelController
                                                                  .webcamUrl !=
                                                              '')
                                                          ? Color(0xFF111111)
                                                          : Color(0xFFC8C8C8)),
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
                                                        width: 34,
                                                        height: 34,
                                                      )
                                                    : Image.asset(
                                                        'assets/imgs/icons/icon_home_slope_off.png',
                                                        width: 34,
                                                        height: 34,
                                                      ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '슬로프 현황',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color:
                                                          (_resortModelController
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
                                    height: 8,
                                  ),
                                  ElevatedButton(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '날씨 정보는 ',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFFc8c8c8),
                                                fontWeight: FontWeight.normal),
                                          ),
                                          TextSpan(
                                            text: '기상청',
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationThickness: 2,
                                                fontSize: 12,
                                                color: Color(0xFF80B2FF),
                                                fontWeight: FontWeight.normal),
                                          ),
                                          TextSpan(
                                            text: ' 정보입니다',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFFc8c8c8),
                                                fontWeight: FontWeight.normal),
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
                                                BorderRadius.circular(10.0)),
                                        buttonPadding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 0),
                                        content: Container(
                                          height: 260,
                                          width: _size.width * 0.8,
                                          color: Colors.white,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  width: 113,
                                                  height: 50,
                                                  child: Transform.translate(
                                                    offset: Offset(-8, 0),
                                                    child: ExtendedImage.asset(
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
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 20),
                                              ),
                                              SizedBox(
                                                height: 14,
                                              ),
                                              Text(
                                                '기상청에서 제공해주는 실시간 데이터를 사용해'
                                                '각 리조트별 날씨정보를 제공하고있어요. '
                                                '추후 더 자세한 날씨 데이터를 제공하기 위해 '
                                                '업데이트 할 예정입니다.',
                                                style: TextStyle(
                                                    color: Color(0xFF666666),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w300),
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
                                                padding: const EdgeInsets.only(
                                                    bottom: 1),
                                                child: Text(
                                                  '확인',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          6))),
                                                  elevation: 0,
                                                  splashFactory:
                                                      InkRipple.splashFactory,
                                                  minimumSize: Size(1000, 50),
                                                  backgroundColor:
                                                      Color(0xff377EEA)),
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
                                                padding: const EdgeInsets.only(
                                                    top: 16),
                                                child: Text(
                                                  '기상청 홈페이지',
                                                  style: TextStyle(
                                                      color: Color(0xff949494),
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 15),
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          6))),
                                                  elevation: 0,
                                                  splashFactory:
                                                      InkRipple.splashFactory,
                                                  minimumSize: Size(1000, 50),
                                                  backgroundColor:
                                                      Color(0xffFFFFFF)),
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
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 24.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Copyright by 134CreativeLab 2022.',
                                                style: TextStyle(
                                                  color: Color(0xFFc8c8c8),
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                'All right reserved.',
                                                style: TextStyle(
                                                  color: Color(0xFFc8c8c8),
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                ),
                                              ),
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
          );
        });
  }
}
