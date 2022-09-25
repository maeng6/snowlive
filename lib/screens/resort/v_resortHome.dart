import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';
import 'package:snowlive3/model/m_resortModel.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';

class ResortHome extends StatelessWidget {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController =
      Get.find<ResortModelController>();
  GetDateTimeController _getDateTimeController =
      Get.find<GetDateTimeController>();

  //TODO: Dependency Injection**************************************************
  bool isWaiting = false;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return FutureBuilder(
        future: _userModelController.getLocalSave(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          _resortModelController
              .getSelectedResort(_userModelController.favoriteSaved!);
          return SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 10, right: 16),
                child: Container(
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
                                () => Text(
                                  '${_resortModelController.resortName}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23),
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                          child: ListView.builder(
                                              itemCount: 14,
                                              itemBuilder: (ctx, index) {
                                                return ListTile(
                                                    title: Text(
                                                        '${resortNameList[index]}'),
                                                    onTap: () async {
                                                      await _resortModelController
                                                          .getSelectedResort(
                                                              index);
                                                      Navigator.pop(ctx);
                                                    });
                                              }));
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
                                      '${_resortModelController.resortTemp!.substring(0, 2)}', //u00B0
                                      style: GoogleFonts.bebasNeue(
                                          fontSize: 110, color: Colors.white),
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '바람',
                                      style: TextStyle(
                                          color: Colors.white60, fontSize: 13),
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
                                                const EdgeInsets.only(right: 3),
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
                                    Text(
                                      '습도',
                                      style: TextStyle(
                                          color: Colors.white60, fontSize: 13),
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
                                              const EdgeInsets.only(bottom: 5),
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
                                          color: Colors.white60, fontSize: 13),
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
                                                const EdgeInsets.only(right: 3),
                                            child: Text(
                                              '${_resortModelController.resortRain}',
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
                                      '최저/최고',
                                      style: TextStyle(
                                          color: Colors.white60, fontSize: 13),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Obx(
                                      () => Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${_resortModelController.resortMinTemp}',
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 28, color: Colors.white),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5, left: 3, right: 2),
                                            child: Text(
                                              '/',
                                              style: GoogleFonts.bebasNeue(
                                                  fontSize: 16, color: Colors.white),
                                            ),
                                          ),
                                          Text(
                                            '${_resortModelController.resortMaxTemp}',
                                            style: GoogleFonts.bebasNeue(
                                                fontSize: 28, color: Colors.white),
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
                                children: [
                                  Image.asset(
                                    'assets/imgs/weather/icon_weather.png',
                                    scale: 4,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: SizedBox(
                                          width: 188,
                                          child: Text(
                                            '야간 라이딩을 즐길 시간',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          )),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: ElevatedButton(
                                      child: Text('기상청 제공'),
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                          minimumSize: Size(80, 30),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          elevation: 0,
                                          primary: Colors.black26,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          textStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                                    BorderRadius.circular(6)),
                                            elevation: 0,
                                            primary: Color(0xFFF2F3F4),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
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
                              Container(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(Obx(
                                          () => WebPage(
                                            url:
                                                '${_resortModelController.webcamUrl}',
                                          ),
                                        ));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        width: double.infinity,
                                        height: 164,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 22,
                                              left: 22,
                                              bottom: 20,
                                              right: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '실시간\n웹캠',
                                                  style: TextStyle(
                                                      height: 1.3,
                                                      fontSize: 18,
                                                      color: Color(0xFF111111),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Image.asset(
                                                    'assets/imgs/icons/icon_snowLive_link.png',
                                                    scale: 4,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(Obx(
                                          () => WebPage(
                                            url:
                                                '${_resortModelController.resortUrl}',
                                          ),
                                        ));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        width: double.infinity,
                                        height: 164,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 22,
                                              left: 22,
                                              bottom: 20,
                                              right: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '리조트\n홈페이지',
                                                  style: TextStyle(
                                                    height: 1.3,
                                                      fontSize: 18,
                                                      color: Color(0xFF111111),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Image.asset(
                                                    'assets/imgs/icons/icon_snowLive_link.png',
                                                    scale: 4,
                                                  ),
                                                ],
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
                    ],
                  ),
                )),
          );
        });
  }
}
