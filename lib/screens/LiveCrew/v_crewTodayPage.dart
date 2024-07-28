import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/liveCrew/vm_streamController_liveCrew.dart';
import '../../controller/ranking/vm_liveMapController.dart';
import '../../controller/resort/vm_resortModelController.dart';
import '../../widget/w_verticalDivider.dart';
import '../snowliveDesignStyle.dart';

class CrewTodayPage extends StatefulWidget {
  @override
  State<CrewTodayPage> createState() => _CrewTodayPageState();
}

class _CrewTodayPageState extends State<CrewTodayPage> {


  StreamController_liveCrew _streamController_liveCrew = Get.find<StreamController_liveCrew>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();




  bool isCurrentYear = true; // true: 24-25시즌, false: 23-24시즌
  int? expandedCardIndex; // 확장된 카드의 인덱스를 저장하는 변수
  bool isTodayCardExpanded = true; // 오늘 현황 카드의 확장 상태
  bool showSlopeGraph = true;


  @override
  void initState() {
    super.initState();
    // 초기화 시점에 현재 시점의 월과 일 카드가 열리도록 설정
    expandedCardIndex = DateTime.now().day - 1; // 현재 일에 맞춰 설정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SDSColor.gray50,
      appBar: AppBar(
        backgroundColor: SDSColor.gray50,
        elevation: 0.0,
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          '기록실',
          style: TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCurrentYear = true;
                    expandedCardIndex = DateTime.now().day - 1; // 현재 일에 맞춰 설정
                    isTodayCardExpanded = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 내부 여백 설정
                  decoration: BoxDecoration(
                    color: isCurrentYear ? SDSColor.snowliveBlack : SDSColor.snowliveWhite, // 배경 색상 설정
                    borderRadius: BorderRadius.circular(16), // 모서리 둥글게 설정
                    border: Border.all(
                      color: Colors.transparent, // 테두리 색상 설정
                      width: 1, // 테두리 두께 설정
                    ),
                  ),
                  child: Text(
                    '2025',
                    style: TextStyle(
                      color: isCurrentYear ? SDSColor.snowliveWhite : SDSColor.snowliveBlack, // 텍스트 색상 설정
                      fontSize: 14, // 텍스트 크기 설정
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCurrentYear = false;
                    expandedCardIndex = DateTime.now().day - 1; // 현재 일에 맞춰 설정
                    isTodayCardExpanded = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 내부 여백 설정
                  decoration: BoxDecoration(
                    color: isCurrentYear ? SDSColor.snowliveWhite : SDSColor.snowliveBlack, // 배경 색상 설정
                    borderRadius: BorderRadius.circular(16), // 모서리 둥글게 설정
                    border: Border.all(
                      color: Colors.transparent, // 테두리 색상 설정
                      width: 1, // 테두리 두께 설정
                    ),
                  ),
                  child: Text(
                    '2024',
                    style: TextStyle(
                      color: isCurrentYear ? SDSColor.snowliveBlack : SDSColor.snowliveWhite, // 텍스트 색상 설정
                      fontSize: 14, // 텍스트 크기 설정
                    ),
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 30),
          Text(
            isCurrentYear ? '2025년 1월' : '2024년 12월',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          buildTodayCard(isCurrentYear),
          ...List.generate(10, (index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                key: Key(index.toString()), // 키를 사용하여 고유하게 만듭니다.
                initiallyExpanded: expandedCardIndex == index,
                onExpansionChanged: (expanded) {
                  setState(() {
                    if (expanded) {
                      expandedCardIndex = index;
                    } else {
                      if (expandedCardIndex == index) {
                        expandedCardIndex = null;
                      }
                    }
                  });
                },
                title: Text('${14 - index}일(${['일', '월', '화', '수', '목', '금', '토'][index % 7]})'),
                children: <Widget>[
                  ListTile(title: Text('세부사항')),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildTodayCard(bool isCurrentSeason) {
    final Size _size = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: SDSColor.snowliveWhite,
      child: ExpansionTile(
        key: Key('today'), // 고유 키 설정
        initiallyExpanded: isTodayCardExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            isTodayCardExpanded = expanded;
          });
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '15일(토)',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2), // 내부 여백 조정
              decoration: BoxDecoration(
                color: SDSColor.snowliveWhite, // 배경 색상
                borderRadius: BorderRadius.circular(10), // 모서리 둥글게 설정
                border: Border.all(
                  color: SDSColor.gray500, // 테두리 색상
                  width: 1, // 테두리 두께
                ),
              ),
              child: Text(
                '오늘',
                style: TextStyle(fontSize: 10, color: Colors.black), // 텍스트 스타일 조정
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        height: 76,
                        decoration: BoxDecoration(
                          color: SDSColor.gray50, // 선택된 옵션의 배경을 흰색으로 설정
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '100',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      '점수',
                                      style: SDSTextStyle.regular.copyWith(
                                        color: Color(0xFF111111).withOpacity(0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            buildVerticalDivider_ranking_indi_Screen(),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '50',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      '라이딩 횟수',
                                      style: SDSTextStyle.regular.copyWith(
                                        color: Color(0xFF111111).withOpacity(0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            buildVerticalDivider_ranking_indi_Screen(),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '5',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      '라이딩 멤버',
                                      style: SDSTextStyle.regular.copyWith(
                                        color: Color(0xFF111111).withOpacity(0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Text(
                  '시간대별 라이딩 횟수',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                StreamBuilder(
                  stream: _streamController_liveCrew.setupStreams_liveCrew_crewDetailPage_home_currentCrew(),
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox.shrink();
                    } else if (snapshot.data!.docs.isNotEmpty) {
                      final crewDocs = snapshot.data!.docs;
                      Map<String, dynamic>? passCountData = crewDocs[0].data().containsKey('passCountData')
                          ? crewDocs[0]['passCountData'] as Map<String, dynamic>?
                          : null;
                      if (passCountData == null || passCountData.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 20),
                            child: Text(
                              '슬로프 이용기록이 없습니다',
                              style: TextStyle(fontSize: 13, color: Color(0xFF949494)),
                            ),
                          ),
                        );
                      } else {
                        Map<String, dynamic>? passCountTimeData = crewDocs[0]['passCountTimeData'] as Map<String, dynamic>?;
                        List<Map<String, dynamic>> barData = _liveMapController.calculateBarDataPassCount(passCountData);
                        List<Map<String, dynamic>> barData2 = _liveMapController.calculateBarDataSlot(passCountTimeData);

                        return Container(
                          padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                          width: MediaQuery.of(context).size.width,
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
                                  Text(
                                    '총 라이딩 횟수',
                                    style: SDSTextStyle.regular.copyWith(
                                      color: SDSColor.snowliveBlack,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                                    child: Text(
                                      '${crewDocs[0]['totalPassCount']}회',
                                      style: SDSTextStyle.extraBold.copyWith(
                                        color: SDSColor.snowliveBlack,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '라이딩 횟수',
                                    style: SDSTextStyle.regular.copyWith(
                                        color: SDSColor.snowliveBlack,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Divider(
                                    color: Color(0xFFCBE0FF), // 구분선 색상
                                    thickness: 1, // 구분선 두께
                                  ),
                                  SizedBox(height: 10,),
                                  if(showSlopeGraph == true)
                                    Container(
                                      height: 7 * 24.0,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: barData.map((data) {
                                            String slopeName = data['slopeName'];
                                            int passCount = data['passCount'];
                                            double barWidthRatio = data['barHeightRatio'];
                                            Color barColor = data['barColor'];
                                            return Padding(
                                              padding: EdgeInsets.only(bottom: 8),
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
                                                    width: (MediaQuery.of(context).size.width - 170) * barWidthRatio,
                                                    decoration: BoxDecoration(
                                                      color: barColor,
                                                      borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(4),
                                                        bottomRight: Radius.circular(4),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 6),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                        color: passCount == barData.map((d) => d['passCount']).reduce((a, b) => a > b ? a : b) ? SDSColor.gray900 : Colors.transparent,
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                      child: AutoSizeText(
                                                        passCount != 0 ? '$passCount' : '',
                                                        style: SDSTextStyle.bold.copyWith(
                                                          fontSize: 12,
                                                          fontWeight: passCount == barData.map((d) => d['passCount']).reduce((a, b) => a > b ? a : b) ? FontWeight.w900 : FontWeight.w300,
                                                          color: passCount == barData.map((d) => d['passCount']).reduce((a, b) => a > b ? a : b) ? SDSColor.snowliveWhite : SDSColor.gray900.withOpacity(0.4),
                                                        ),
                                                        maxLines: 1,
                                                        minFontSize: 6,
                                                        overflow: TextOverflow.visible,
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
                                  if(showSlopeGraph == false)
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
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
                                            width: 33,
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
                                                        topRight: Radius.circular(4),
                                                        topLeft: Radius.circular(4),
                                                      ),
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
                                    )
                                ],
                              ),
                              SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFD2DFF4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showSlopeGraph = true;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: showSlopeGraph ? SDSColor.snowliveWhite : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '슬로프별',
                                            style: SDSTextStyle.regular.copyWith(
                                              color: showSlopeGraph ? SDSColor.gray900 : SDSColor.gray600,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showSlopeGraph = false;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: !showSlopeGraph ? SDSColor.snowliveWhite : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '시간대별',
                                            style: SDSTextStyle.regular.copyWith(
                                              color: !showSlopeGraph ? SDSColor.gray900 : SDSColor.gray600,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )

                            ],
                          ),
                        );
                      }
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 20),
                        child: Text(
                          '슬로프 이용기록이 없습니다',
                          style: TextStyle(fontSize: 13, color: Color(0xFF949494)),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                Divider(thickness: 1),
                SizedBox(height: 16),
                Text(
                  '오늘의 라이딩 멤버 6명',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                ...List.generate(6, (index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage('https://example.com/profile.jpg'),
                    ),
                    title: Text('멤버 $index'),
                    trailing: Text('${(index + 1) * (isCurrentSeason ? 30 : 25)}점'),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }


}