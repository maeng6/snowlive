import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';
import 'package:snowlive3/model/m_resortModel.dart';
import 'package:snowlive3/screens/comments/v_commentTile_resortHome.dart';
import 'package:snowlive3/screens/comments/v_commentScreen_liveTalk_resortHome.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import '../../controller/vm_commentController.dart';
import '../../widget/w_fullScreenDialog.dart';
import '../comments/v_newComment.dart';

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
  bool _ifWeatherError = false;

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  ListTile buildResortListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${resortNameList[index]}'),
      //selected: _isSelected[index]!,
      onTap: () async {
        Navigator.pop(context);
        CustomFullScreenDialog.showDialog();
        _isSelected = List<bool?>.filled(13, false);
        _isSelected[index] = true;
        await _userModelController.updateInstantResort(index);
        try {
          await _resortModelController.getSelectedResort(index);
          print('${_resortModelController.webcamUrl}');
          setState(() { });
          CustomFullScreenDialog.cancelDialog();
        } catch (e) {
          CustomFullScreenDialog.cancelDialog();
          Get.snackbar('현재 날씨를 확인하기 어려워요.', '잠시후에 다시 시도해주세요.',
              snackPosition: SnackPosition.BOTTOM,
              margin: EdgeInsets.only(
                  right: 20, left: 20, bottom: 12),
              backgroundColor: Colors.black87,
              colorText: Colors.white,
              duration: Duration(milliseconds: 3000));
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    CustomFullScreenDialog.showDialog();
    await _userModelController.updateInstantResort(_userModelController.favoriteResort);
    if (mounted) setState(() {
    });
    try {
      _refreshController.refreshCompleted();
      CustomFullScreenDialog.cancelDialog();
    } catch (e) {
      CustomFullScreenDialog.cancelDialog();
    }
  }

  @override
  Widget build(BuildContext context) {

    //TODO: Dependency Injection**************************************************
    Get.put(CommentModelController(), permanent: true);
    CommentModelController _commentModelController =
    Get.find<CommentModelController>();
    //TODO: Dependency Injection**************************************************

    final Size _size = MediaQuery.of(context).size;
    _ifWeatherError = false;
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: FutureBuilder(
            future: _userModelController.getLocalSave(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              _resortModelController
                  .getSelectedResort(_userModelController.instantResort!);
              return Scaffold(
                backgroundColor: Color(0xFFF2F4F6),
                extendBodyBehindAppBar: true,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(58),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AppBar(
                        iconTheme: IconThemeData(size: 26, color: Colors.black87),
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
                body: SmartRefresher(
                  enablePullDown: true,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    child: Container(
                      color: Color(0xFFF2F4F6),
                      child: Padding(
                          padding:
                              const EdgeInsets.only(left: 16, top: 68, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: Color(0xff32314D)),
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
                                            Text(
                                              '${_resortModelController.resortName}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 23),
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
                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                                height: _size.height * 0.8,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '리조트를 선택해주세요.',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
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
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Builder(
                                                                builder: (context) {
                                                              return Column(
                                                                children: [
                                                                  buildResortListTile(
                                                                      index),
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
                                      height: 4,
                                    ),
                                    SizedBox(
                                      height: 18,
                                      child: Text(
                                        '${_getDateTimeController.date}',
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 26,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Obx(
                                          () => Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4, left: 20),
                                            child: Text(
                                              '${_resortModelController.resortTemp!}', //u00B0
                                              style: GoogleFonts.bebasNeue(
                                                  fontSize: 110,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 14),
                                          child: Text(
                                            '\u00B0',
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 60, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 24,
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
                                                    padding: const EdgeInsets.only(
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
                                                  padding: const EdgeInsets.only(
                                                      bottom: 5),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Obx(
                                                  () => Padding(
                                                    padding: const EdgeInsets.only(
                                                        right: 3),
                                                    child: Text(
                                                      '${_resortModelController.resortWet}',
                                                      style: GoogleFonts.bebasNeue(
                                                          fontSize: 28,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Text(
                                                    '%',
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
                                                    padding: const EdgeInsets.only(
                                                        right: 3),
                                                    child: Text(
                                                      '${_resortModelController.resortRain}',
                                                      style: GoogleFonts.bebasNeue(
                                                          fontSize: 28,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Text(
                                                    'MM',
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
                                                    style: GoogleFonts.bebasNeue(
                                                        fontSize: 28,
                                                        color: Colors.white),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        bottom: 5,
                                                        left: 3,
                                                        right: 2),
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
                                                        fontSize: 28,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Divider(
                                      thickness: 1,
                                      color: Colors.black12,
                                      height: 0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, top: 8, bottom: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/imgs/weather/icon_weather.png',
                                                width: 40,
                                                height: 40,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(left: 6),
                                                child: SizedBox(
                                                    width: 188,
                                                    child: Text(
                                                      '야간 라이딩을 즐길 시간',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13),
                                                    )),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 16),
                                            child: ElevatedButton(
                                              child: Text('기상청 제공'),
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
                                                  buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                  content: Container(
                                                    height: 230,
                                                    width: _size.width * 0.8,
                                                    color: Colors.white,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                            width: 113,
                                                            height: 50,
                                                            child: ExtendedImage
                                                                .asset(
                                                              'assets/imgs/logos/weather_logo.png',
                                                              fit: BoxFit.cover,
                                                            )),
                                                        SizedBox(
                                                          height: 14,
                                                        ),
                                                        Text(
                                                          '날씨 데이터는 기상청에서 제공하는 '
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
                                                          '각 리조트별 날씨정보를 제공하고있어요. '
                                                          '추후 더 자세한 날씨 데이터를 제공하기 위해 '
                                                          '업데이트 할 예정이니, 많은 이용 부탁드려요.',
                                                          style: TextStyle(
                                                              color:
                                                                  Color(0xFF666666),
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
                                                              .only(
                                                              top: 16),
                                                          child: Text(
                                                            '기상청 홈페이지',
                                                            style: TextStyle(
                                                                color:
                                                                Color(0xff949494),
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
                                                  minimumSize: Size(80, 30),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(6)),
                                                  elevation: 0,
                                                  backgroundColor: Colors.black26,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10, vertical: 5),
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '네이버 날씨',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Color(0xFF111111),
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              ElevatedButton(
                                                child: Text(
                                                  '보러가기',
                                                  style: TextStyle(
                                                      color: Color(0xFF666666)),
                                                ),
                                                onPressed: () {
                                                  Get.to(Obx(
                                                    () => WebPage(
                                                      url:
                                                          '${_resortModelController.naverUrl}',
                                                    ),
                                                  ));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    minimumSize: Size(72, 30),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                6)),
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Color(0xFFF2F3F4),
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    textStyle: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      (_resortModelController.webcamUrl != '')
                                      ?Column(
                                        children: [
                                          SizedBox(height: 12,),
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(14)),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 12),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '실시간 웹캠',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Color(0xFF111111),
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    child: Text(
                                                      '보러가기',
                                                      style: TextStyle(
                                                          color: Color(0xFF666666)),
                                                    ),
                                                    onPressed: () {
                                                      Get.to(Obx(
                                                        () => WebPage(
                                                          url:
                                                              '${_resortModelController.webcamUrl}',
                                                        ),
                                                      ));
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        minimumSize: Size(72, 30),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    6)),
                                                        elevation: 0,
                                                        backgroundColor:
                                                            Color(0xFFF2F3F4),
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 5),
                                                        textStyle: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.bold,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                        ],
                                      )
                                      :SizedBox(height: 12,),
                                      (_resortModelController.slopeUrl != '')
                                      ?Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(14)),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 12),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '슬로프 현황',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Color(0xFF111111),
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    child: Text(
                                                      '보러가기',
                                                      style: TextStyle(
                                                          color: Color(0xFF666666)),
                                                    ),
                                                    onPressed: () {
                                                      Get.to(Obx(
                                                        () => WebPage(
                                                          url:
                                                              '${_resortModelController.slopeUrl}',
                                                        ),
                                                      ));
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        minimumSize: Size(72, 30),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    6)),
                                                        elevation: 0,
                                                        backgroundColor:
                                                            Color(0xFFF2F3F4),
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 5),
                                                        textStyle: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.bold,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                          :SizedBox(height: 0,),
                                      (_resortModelController.webcamUrl != '' && _resortModelController.slopeUrl !='')
                                      ?SizedBox(height: 12,)
                                      :SizedBox(height: 0,),
                                      Container(
                                        width: double.infinity,
                                        height: 522,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(14)),
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 22, vertical: 22),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('라이브 톡',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      child: Text(
                                                        '더보기',
                                                        style: TextStyle(
                                                            color: Color(0xFF666666)),
                                                      ),
                                                      onPressed: () {
                                                      Get.to(()=> CommentScreen_LiveTalk_resortHome());
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          minimumSize: Size(72, 30),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  6)),
                                                          elevation: 0,
                                                          backgroundColor:
                                                          Color(0xFFF2F3F4),
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                          textStyle: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                    child: CommentTile_resortHome()
                                                )
                                              ],
                                            )
                                        )
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
