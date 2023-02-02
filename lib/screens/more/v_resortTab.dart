import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/model/m_resortModel.dart';
import 'package:snowlive3/screens/v_webPage.dart';

class ResortTab extends StatelessWidget {
  ResortTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Color(0xFFF1F1F3),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Get.back();
            },
          ),
          backgroundColor: Color(0xFFF1F1F3),
          elevation: 0.0,
          titleSpacing: 0,
          title: Text(
            '리조트',
            style: GoogleFonts.notoSans(
                color: Color(0xFF111111),
                fontWeight: FontWeight.w900,
                fontSize: 20),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: _statusBarSize, left: 30, right: 30),
        child: resortListView(_size),
      ),
    );
  }

  ListView resortListView(Size _size) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 68, bottom: 20),
      itemCount: resortList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          width: 330,
          height: 345,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Color(0xffFFFFFF),
          ),
          padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    '${resortLogoList[index]}',
                    scale: 4,
                    width: 200,
                    height: 68,
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Text(
                    '${resortNameList[index]}',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${resortAddressList[index]}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF949494)),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 48,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Get.to(
                            () => WebPage(
                          url: '${naverUrlList[index]}',
                        ),
                      );
                    },
                    child: Text(
                      '네이버 날씨',
                      style: TextStyle(
                          color: Color(0xFF3D83ED),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.transparent),
                        minimumSize: Size(_size.width, 44),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        backgroundColor: Color(0xFFD8E7FD),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(6)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            if (webcamUrlList[index]!.isNotEmpty) {
                              Get.to(
                                () => WebPage(
                                  url: '${webcamUrlList[index]}',
                                ),
                              );
                            } else {
                              null;
                            }
                          },
                          child: Text(
                            '실시간 웹캠',
                            style: TextStyle(
                                color: (webcamUrlList[index]!.isNotEmpty)
                                    ? Color(0xFF555555)
                                    : Color(0xFFDEDEDE),
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                              backgroundColor: (webcamUrlList[index]!.isNotEmpty)
                                  ? Colors.white
                                  : Colors.white,
                              side: BorderSide(color: Colors.transparent),
                              minimumSize: Size(_size.width / 2 - 68, 44),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)))),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Color(0xFFDEDEDE),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            if (slopeUrlList[index]!.isNotEmpty) {
                              Get.to(
                                () => WebPage(
                                  url: '${slopeUrlList[index]}',
                                ),
                              );
                            } else {
                              null;
                            }
                          },
                          child: Text(
                            '슬로프 현황',
                            style: TextStyle(
                                color: (slopeUrlList[index]!.isNotEmpty)
                                    ? Color(0xFF555555)
                                    : Color(0xFFDEDEDE),
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: (slopeUrlList[index]!.isNotEmpty)
                                  ? Colors.white
                                  : Colors.white,
                              side: BorderSide(color: Colors.transparent),
                              minimumSize: Size(_size.width / 2 - 68, 44),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)))),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 18,
        );
      },
    );
  }
}
