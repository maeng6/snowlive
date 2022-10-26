import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/model/m_resortModel.dart';
import 'package:snowlive3/screens/comments/v_commentScreen_liveTalk_resortTab.dart';
import 'package:snowlive3/screens/v_webPage.dart';

import '../comments/v_commentTile_liveTalk_resortTab.dart';

class resortTab extends StatelessWidget {
  resortTab({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            '리조트',
            style: GoogleFonts.notoSans(
                color: Color(0xFF111111),
                fontWeight: FontWeight.w900,
                fontSize: 23),
          ),
        ),
      ),
      body: Padding(
        padding:
             EdgeInsets.only(top: _statusBarSize, left: 16, right: 16),
        child: resortListView(_size),
      ),
    );
  }

  ListView resortListView(Size _size) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 68, bottom: 40),
      itemCount: resortList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '${resortNameList[index]}',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111111)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
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
                  Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerRight,
        ),
                          onPressed: () {
                            Get.to(()=>CommentScreen_LiveTalk_resortTab(index: index,resortName: resortNameList[index],));
                          },
                          child: Text(
                            '라이브톡',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF111111)),
                          )),
                      ExtendedImage.asset('assets/imgs/icons/icon_arrow_b_s.png', width: 20, height: 20,)
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      if(webcamUrlList[index]!.isNotEmpty){
                      Get.to(
                        () => WebPage(
                          url: '${webcamUrlList[index]}',
                        ),
                      );}else{
                        null;
                      }
                    },
                    child: Text(
                      '실시간 웹캠',
                      style: TextStyle(
                          color:
                          (slopeUrlList[index]!.isNotEmpty)
                          ? Color(0xFF555555)
                          : Color(0xFFCACACA),
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                        minimumSize: Size(_size.width / 3 - 18, 40),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(6)))),
                  ),
                  SizedBox(
                    width: 11,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      if(slopeUrlList[index]!.isNotEmpty){
                      Get.to(
                        () => WebPage(
                          url: '${slopeUrlList[index]}',
                        ),
                      );}else{
                        null;
                      }
                    },
                    child: Text(
                      '슬로프 현황',
                      style: TextStyle(
                          color:
                          (slopeUrlList[index]!.isNotEmpty)
                          ? Color(0xFF555555)
                          : Color(0xFFCACACA),
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                        minimumSize: Size(_size.width / 3 - 18, 40),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(6)))),
                  ),
                  SizedBox(
                    width: 11,
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
                          color: Color(0xFF555555),
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                        minimumSize: Size(_size.width / 3 - 18, 40),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(6)))),
                  )
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 50,
          thickness: 1,
          color: Color(0xFFefefef),
        );
      },
    );
  }
}
