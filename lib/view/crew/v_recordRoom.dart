import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
import 'package:com.snowlive/widget/w_verticalDivider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CrewRecordRoomView extends StatelessWidget {
  final CrewRecordRoomViewModel _crewRecordRoomViewModel = Get.find<CrewRecordRoomViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();

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
            Get.back();
            _crewRecordRoomViewModel.resetTabs();
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
      body: Obx(() {
        if (_crewRecordRoomViewModel.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // 년도 선택 탭 추가
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: buildYearSelector(),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: _buildGroupedRecords(),
              ),
            ),
          ],
        );
      }),
    );
  }

  // 년도 선택 탭을 생성하는 함수
  Widget buildYearSelector() {
    int currentYear = DateTime.now().year; // 현재 연도
    int startYear = 2023; // 시작 연도

    // 시작 연도부터 현재 연도까지의 탭을 최신순으로 생성
    List<Widget> yearTabs = [];

    for (int year = currentYear; year >= startYear; year--) {
      yearTabs.add(
        GestureDetector(
          onTap: () async {
            _crewRecordRoomViewModel.setYear(year);
            await _crewRecordRoomViewModel.fetchCrewRidingRecords(
              _crewDetailViewModel.crewDetailInfo.crewId!, year.toString(),
            );
          },
          child: Obx(() => Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _crewRecordRoomViewModel.currentYear.value == year
                  ? SDSColor.snowliveBlack
                  : SDSColor.snowliveWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.transparent, width: 1),
            ),
            child: Text(
              '$year년',
              style: TextStyle(
                color: _crewRecordRoomViewModel.currentYear.value == year
                    ? SDSColor.snowliveWhite
                    : SDSColor.snowliveBlack,
                fontSize: 14,
              ),
            ),
          )),
        ),
      );

      yearTabs.add(SizedBox(width: 8)); // 각 탭 사이에 여백 추가
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: yearTabs,
      ),
    );
  }

  // 월별로 그룹화된 기록들을 표시하는 함수
  List<Widget> _buildGroupedRecords() {
    // 기록을 월별로 그룹화
    Map<String, List<CrewRidingRecord>> groupedByMonth = _groupRecordsByMonth(_crewRecordRoomViewModel.crewRidingRecords);

    return groupedByMonth.entries.map((entry) {
      String monthKey = entry.key; // "yyyy-MM"
      List<CrewRidingRecord> records = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 월 타이틀 추가
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              _formatMonthTitle(monthKey),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          // 해당 월의 레코드들
          ...records.map((record) {
            int index = _crewRecordRoomViewModel.crewRidingRecords.indexOf(record);
            return buildExpansionTile(record, index);
          }).toList(),
        ],
      );
    }).toList();
  }

  // 레코드를 월별로 그룹화하는 함수
  Map<String, List<CrewRidingRecord>> _groupRecordsByMonth(List<CrewRidingRecord> records) {
    Map<String, List<CrewRidingRecord>> groupedByMonth = {};

    for (var record in records) {
      if (record.date != null) {
        // "yyyy-MM" 형식으로 월을 추출
        String monthKey = DateFormat('yyyy-MM').format(DateTime.parse(record.date!));
        if (!groupedByMonth.containsKey(monthKey)) {
          groupedByMonth[monthKey] = [];
        }
        groupedByMonth[monthKey]?.add(record);
      }
    }

    return groupedByMonth;
  }

  // 월 타이틀 포맷팅 함수
  String _formatMonthTitle(String monthKey) {
    DateTime parsedDate = DateFormat('yyyy-MM').parse(monthKey);
    return DateFormat('MM월').format(parsedDate);
  }

  // 기존의 buildExpansionTile 함수
  Widget buildExpansionTile(CrewRidingRecord record, int index) {
    // 날짜 포맷팅: "dd일 (E)" 형식으로 변경
    DateTime? date = record.date != null ? DateTime.parse(record.date!) : null;
    String formattedDate = date != null
        ? DateFormat('dd일 (E)', 'ko').format(date) // 'ko'를 사용하여 한글 요일 표시
        : '날짜 없음';

    // 요일에 따라 색상 지정, 모든 날짜는 볼드체로 설정
    Color dateColor;
    FontWeight dateFontWeight = FontWeight.bold; // 모든 날짜를 볼드체로 설정
    if (date != null) {
      if (date.weekday == DateTime.saturday) {
        dateColor = Colors.blue; // 토요일은 파란색
      } else if (date.weekday == DateTime.sunday) {
        dateColor = Colors.red; // 일요일은 빨간색
      } else {
        dateColor = Colors.black; // 나머지 요일은 검정색
      }
    } else {
      dateColor = Colors.black; // 날짜가 없을 경우 기본 검정색
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        key: Key('expansion_$index'),  // 각 타일에 고유한 키 설정
        initiallyExpanded: _crewRecordRoomViewModel.expandedCardIndex.value == index,
        onExpansionChanged: (expanded) {
          _crewRecordRoomViewModel.setExpandedCardIndex(expanded ? index : null);
        },
        title: Text(
          formattedDate,
          style: TextStyle(
            color: dateColor, // 요일에 따른 색상 적용
            fontWeight: dateFontWeight, // 모든 날짜는 볼드체
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildScoreCard(record),
                SizedBox(height: 32),
                buildGraphs(record),
                SizedBox(height: 16),
                Divider(thickness: 1),
                SizedBox(height: 16),
                buildRidingMembers(record),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // 점수 카드 생성
  Widget buildScoreCard(CrewRidingRecord record) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildScoreItem('${record.totalScore!.toStringAsFixed(0) ?? 0}', '점수'),  // null 값 방지
          buildVerticalDivider_ranking_indi_Screen(),
          buildScoreItem('${record.totalCount ?? 0}', '라이딩 횟수'),
          buildVerticalDivider_ranking_indi_Screen(),
          buildScoreItem('${record.memberCount ?? 0}', '라이딩 멤버'),
        ],
      ),
    );
  }
  Widget buildScoreItem(String score, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              label,
              style: SDSTextStyle.regular.copyWith(
                color: Color(0xFF111111).withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 시간대별 라이딩 횟수 그래프 생성
  Widget buildGraphs(CrewRidingRecord record) {
    // timeCountInfo가 null일 경우 기본 빈 맵 사용
    Map<String, int> timeCountInfo = record.timeCountInfo ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시간대별 라이딩 횟수',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 15),
        if (timeCountInfo.isNotEmpty)  // timeCountInfo가 비어있지 않으면 그래프 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: timeCountInfo.entries.map<Widget>((entry) {
              String slotName = entry.key;  // 시간대 이름 (ex: "00-08", "08-10")
              int passCount = entry.value;  // 시간대별 횟수
              int maxCount = timeCountInfo.values.reduce((a, b) => a > b ? a : b);  // 최대 값 계산
              double barHeightRatio = (maxCount != 0) ? passCount / maxCount : 0;  // 비율 계산

              return Container(
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 횟수가 0이 아닐 때만 표시
                    AutoSizeText(
                      passCount != 0 ? '$passCount' : '',
                      style: TextStyle(
                        fontSize: 11,
                        color: passCount == maxCount ? SDSColor.snowliveBlack : SDSColor.gray500,
                        fontWeight: passCount == maxCount ? FontWeight.bold : FontWeight.w300,  // 가장 높은 값은 볼드체
                      ),
                      minFontSize: 6,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: passCount == maxCount ? 6 : 0),
                      child: Container(
                        width: 16,
                        height: 140 * barHeightRatio,  // 막대 높이를 비율에 따라 설정
                        decoration: BoxDecoration(
                          color: passCount == maxCount ? SDSColor.blue500 : SDSColor.blue200,  // 가장 높은 값은 다른 색상
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
                          slotName,  // 시간대 텍스트
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        if (timeCountInfo.isEmpty)  // timeCountInfo가 비어있으면 메시지 표시
          Text('라이딩 기록이 없습니다.'),
      ],
    );
  }

  // 라이딩 멤버 정보 표시
  Widget buildRidingMembers(CrewRidingRecord record) {
    List<TodayMemberInfo> members = record.todayMemberInfo ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '라이딩 멤버 ${record.memberCount ?? 0}명',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 8),
        if (members.isNotEmpty)
          ...members.map((member) {
            return ListTile(
              leading: member.profileImageUrlUser != null && member.profileImageUrlUser!.isNotEmpty
                  ? Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0xFFDFECFF),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ExtendedImage.network(
                  member.profileImageUrlUser!,
                  enableMemoryCache: true,
                  shape: BoxShape.circle,
                  cacheHeight: 150,
                  borderRadius: BorderRadius.circular(8),
                  width: 32,
                  height: 32,
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
                          borderRadius: BorderRadius.circular(8),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ); // 이미지 로딩 실패 시 대체 이미지
                      default:
                        return null;
                    }
                  },
                ),
              )
                  : Container(
                width: 32,
                height: 32,
                child: ExtendedImage.asset(
                  'assets/imgs/profile/img_profile_default_circle.png',
                  enableMemoryCache: true,
                  shape: BoxShape.circle,
                  borderRadius: BorderRadius.circular(8),
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                member.displayName!,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              trailing: Text(
                '${member.totalScore!.toStringAsFixed(0)}점',
                style: TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        if (members.isEmpty) Text('멤버 기록이 없습니다.'),
      ],
    );
  }
}
