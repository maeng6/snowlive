import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_resortModel.dart';

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
        preferredSize: Size.fromHeight(44),
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
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
          titleSpacing: 0,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 44, left: 30, right: 30),
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
          height: 336,
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
                    style: SDSTextStyle.bold.copyWith(
                        fontSize: 22,
                        color: SDSColor.gray900),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${resortAddressList[index]}',
                      style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.gray500),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      otherShare(contents: '${naverUrlList[index]}');
                    },
                    child: Text(
                      '네이버 날씨',
                      style: SDSTextStyle.bold.copyWith(
                          color: SDSColor.snowliveBlue,
                          fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.transparent),
                        minimumSize: Size(_size.width, 44),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        backgroundColor: SDSColor.blue50,
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
                              otherShare(contents: '${webcamUrlList[index]}');

                            } else {
                              null;
                            }
                          },
                          child: Text(
                            '실시간 웹캠',
                            style: SDSTextStyle.bold.copyWith(
                                color: (webcamUrlList[index]!.isNotEmpty)
                                    ? SDSColor.gray700
                                    : SDSColor.gray200,
                                fontSize: 15,
                            ),
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
                              otherShare(contents: '${slopeUrlList[index]}');
                            } else {
                              null;
                            }
                          },
                          child: Text(
                            '슬로프 현황',
                            style: SDSTextStyle.bold.copyWith(
                                color: (slopeUrlList[index]!.isNotEmpty)
                                    ? SDSColor.gray700
                                    : SDSColor.gray200,
                                fontSize: 15,
                            ),
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
