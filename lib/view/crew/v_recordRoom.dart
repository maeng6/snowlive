import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
import 'package:com.snowlive/viewmodel/crew/vm_rankingCrewHistory.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_verticalDivider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CrewRecordRoomView extends StatelessWidget {
  final CrewRecordRoomViewModel _crewRecordRoomViewModel = Get.find<CrewRecordRoomViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final RankingCrewHistoryViewModel _rankingCrewHistoryViewModel = Get.find<RankingCrewHistoryViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: SDSColor.gray50,
        appBar: AppBar(
          backgroundColor: SDSColor.gray50,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 44,
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
              //_crewRecordRoomViewModel.resetTabs();
            },
          ),
          centerTitle: true,
          title: Text(
            '기록실',
            style: SDSTextStyle.extraBold.copyWith(
                color: SDSColor.gray900,
                fontSize: 18),
          ),
        ),
        body:  Obx(()=>Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 12),
              child: buildYearSelector(),  // 년도 선택 탭은 항상 고정
            ),
            SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if(_crewRecordRoomViewModel.isLoading.value == true
                    || _rankingCrewHistoryViewModel.isLoadingBeta_Crew.value == true
                ){
                  return Container(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 100),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      backgroundColor: SDSColor.gray100,
                                      color: SDSColor.gray300.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if(_crewRecordRoomViewModel.currentYear.value == -1) {
                  return _buildBetaView(_size);  // 전체보기 탭을 선택했을 때 나타나는 화면
                }
                else {
                  // 년도별 탭을 선택했을 때 기존 화면을 보여줌
                  return RefreshIndicator(
                    strokeWidth: 2,
                    edgeOffset: -40,
                    displacement: 40,
                    backgroundColor: SDSColor.snowliveBlue,
                    color: SDSColor.snowliveWhite,
                    onRefresh: () async {
                      await _crewRecordRoomViewModel.fetchCrewRidingRecords_refresh(
                        _userViewModel.user!.crew_id,
                        '${_crewRecordRoomViewModel.currentYear.value}',
                      );
                    },
                    child: ListView(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 60),
                      children: _buildGroupedRecords(_size),
                    ),
                  );
                }
              }),
            ),
          ],
        ),)
    );
  }

  // 년도 선택 탭을 생성하는 함수
  Widget buildYearSelector() {
    int currentYear = DateTime.now().year; // 현재 연도
    int startYear = 2024; // 시작 연도

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
            print('시즌기록로드');
          },
          child: Obx(() => Container(
            decoration: BoxDecoration(
              color: _crewRecordRoomViewModel.currentYear.value == year
                  ? SDSColor.snowliveBlack
                  : SDSColor.snowliveWhite,
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.transparent, width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            height: 36,
            child: Text(
              '$year년',
              style: SDSTextStyle.bold.copyWith(
                color: _crewRecordRoomViewModel.currentYear.value == year
                    ? SDSColor.snowliveWhite
                    : SDSColor.snowliveBlack,
                fontWeight: _crewRecordRoomViewModel.currentYear.value == year
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          )),
        ),
      );
      yearTabs.add(SizedBox(width: 8)); // 각 탭 사이에 여백 추가
    }

    // 커스텀 탭 추가 (예: "전체보기" 또는 다른 기능의 탭)
    yearTabs.add(
      GestureDetector(
        onTap: () async{
          _crewRecordRoomViewModel.setYear(-1);
          await _rankingCrewHistoryViewModel.fetchRankingDataCrewBeta(
              crewId : _crewDetailViewModel.crewDetailInfo.crewId
          );
          print("전체보기 탭 눌림");
        },
        child: Container(
          decoration: BoxDecoration(
            color: _crewRecordRoomViewModel.currentYear.value == -1
                ? SDSColor.snowliveBlack
                : SDSColor.snowliveWhite, // 탭의 배경색 설정
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(color: Colors.transparent, width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          height: 36,
          child: Text(
            '23/24시즌',  // 원하는 탭 이름
            style:  SDSTextStyle.bold.copyWith(
              color: _crewRecordRoomViewModel.currentYear.value == -1
                  ? SDSColor.snowliveWhite
                  : SDSColor.snowliveBlack,
              fontWeight: _crewRecordRoomViewModel.currentYear.value == -1
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: yearTabs,
      ),
    );
  }


  // 월별로 그룹화된 기록들을 표시하는 함수
  List<Widget> _buildGroupedRecords(Size size) {
    // 기록을 월별로 그룹화
    Map<String, List<CrewRidingRecord>> groupedByMonth = _groupRecordsByMonth(_crewRecordRoomViewModel.crewRidingRecords);
    // 데이터가 없는 경우에 대한 처리
    if (groupedByMonth.isEmpty) {
      return [
        Container(
          height: size.height - 200,
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/imgs/img_resoreHome_nodata.png',
                    width: 72,
                    height: 72,
                  ),
                  Text(
                    '데이터가 없어요',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 14,
                      color: SDSColor.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ];
    }

    return groupedByMonth.entries.map((entry) {
      String monthKey = entry.key; // "yyyy-MM"
      List<CrewRidingRecord> records = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 월 타이틀 추가
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Text(
              _formatMonthTitle(monthKey),
              style: SDSTextStyle.bold.copyWith(
                fontSize: 18,
                color: SDSColor.gray900,
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
    return DateFormat('M월').format(parsedDate);
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
        dateColor = SDSColor.snowliveBlue; // 토요일은 파란색
      } else if (date.weekday == DateTime.sunday) {
        dateColor = SDSColor.red; // 일요일은 빨간색
      } else {
        dateColor = SDSColor.gray900; // 나머지 요일은 검정색
      }
    } else {
      dateColor = SDSColor.gray900; // 날짜가 없을 경우 기본 검정색
    }

    return Card(
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      color: SDSColor.snowliveWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent, // Divider를 제거하려면 추가
          splashColor: Colors.transparent, // 터치 시 나타나는 스플래시 색상 투명
          highlightColor: Colors.transparent, // 터치 시 하이라이트되는 색상 투명
        ),
        child: ExpansionTile(
          key: Key('expansion_$index'),  // 각 타일에 고유한 키 설정
          initiallyExpanded: _crewRecordRoomViewModel.expandedCardIndex.value == index,
          onExpansionChanged: (expanded) {
            _crewRecordRoomViewModel.setExpandedCardIndex(expanded ? index : null);
          },
          collapsedIconColor: SDSColor.gray900,
          iconColor: SDSColor.gray900,
          title: Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              formattedDate,
              style: SDSTextStyle.bold.copyWith(
                fontSize: 16,
                color: dateColor, // 요일에 따른 색상 적용
                fontWeight: dateFontWeight, // 모든 날짜는 볼드체
              ),
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 6),
              child: Column(
                children: [
                  buildScoreCard(record),
                  SizedBox(height: 24),
                  buildGraphs(record),
                  SizedBox(height: 16),
                  Divider(color: SDSColor.gray100, thickness: 1, height: 32,),
                  SizedBox(height: 16),
                  buildRidingMembers(record),
                ],
              ),
            ),
          ],
          collapsedBackgroundColor: Colors.transparent, // 축소 상태일 때 배경색 투명
          backgroundColor: Colors.transparent, // 확장 상태일 때 배경색 투명
        ),
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
            style: SDSTextStyle.bold.copyWith(
                fontSize: 16,
                color: SDSColor.gray900),
          ),
          Text(
            label,
            style: SDSTextStyle.regular.copyWith(
              color: SDSColor.gray500,
              fontSize: 13,
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
          style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
        ),
        SizedBox(height: 12),
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
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 12,
                        color: SDSColor.gray900,
                      ),
                      minFontSize: 6,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Container(
                        width: 16,
                        height: 140 * barHeightRatio,  // 막대 높이를 비율에 따라 설정
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
                          slotName,  // 시간대 텍스트
                          style: SDSTextStyle.regular.copyWith(
                              fontSize: 11,
                              color: SDSColor.sBlue600,
                              height: 1.2
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Image.asset(
                    'assets/imgs/imgs/img_resoreHome_nodata.png',
                    fit: BoxFit.cover,
                    width: 72,
                    height: 72,
                  ),
                  Text('라이딩 기록이 없어요',
                    style: SDSTextStyle.regular.copyWith(
                        fontSize: 14,
                        color: SDSColor.gray600
                    ),
                  ),
                ],
              ),
            ),
          )
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
          style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
        ),
        SizedBox(height: 8),
        if (members.isNotEmpty)
          ...members.map((member) {
            return Container(
              height: 42,
              child: ListTile(
                leading: member.profileImageUrlUser != null && member.profileImageUrlUser!.isNotEmpty
                    ? Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: SDSColor.gray100,
                          width: 1
                      )
                  ),
                  child: GestureDetector(
                    onTap: () async{
                      Get.toNamed(AppRoutes.friendDetail);
                      await _friendDetailViewModel.fetchFriendDetailInfo(
                          userId: _userViewModel.user.user_id,
                          friendUserId:member.userId!,
                          season: _friendDetailViewModel.seasonDate);
                    },
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
                            return ClipOval(
                              child: Image.asset(
                                'assets/imgs/profile/img_profile_default_circle.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ); // 이미지 로딩 실패 시 대체 이미지
                          default:
                            return null;
                        }
                      },
                    ),
                  ),
                )
                    : GestureDetector(
                  onTap: ()async{
                    Get.toNamed(AppRoutes.friendDetail);
                    await _friendDetailViewModel.fetchFriendDetailInfo(
                        userId: _userViewModel.user.user_id,
                        friendUserId:member.userId!,
                        season: _friendDetailViewModel.seasonDate);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/imgs/profile/img_profile_default_circle.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                title: Transform.translate(
                  offset: Offset(-6, 0),
                  child: Text(
                    member.displayName!,
                    style: SDSTextStyle.regular.copyWith(
                        fontSize: 14,
                        color: SDSColor.gray900
                    ),
                  ),
                ),
                trailing: Text(
                  '${member.totalScore!.toStringAsFixed(0)}점',
                  style: SDSTextStyle.regular.copyWith(fontSize: 16, color: SDSColor.gray900),
                ),
              ),
            );
          }).toList(),
        if (members.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Image.asset(
                    'assets/imgs/imgs/img_resoreHome_nodata.png',
                    fit: BoxFit.cover,
                    width: 72,
                    height: 72,
                  ),
                  Text('멤버 기록이 없어요',
                    style: SDSTextStyle.regular.copyWith(
                        fontSize: 14,
                        color: SDSColor.gray600
                    ),
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }

  // 23/24시즌 정보 표시
  Widget _buildBetaView(Size size) {
    if (_rankingCrewHistoryViewModel.rankingListCrewBetaList.isEmpty) {
      return Container(
        height: size.height - 200,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/imgs/imgs/img_resoreHome_nodata.png',
                  width: 72,
                  height: 72,
                ),
                Text(
                  '데이터가 없어요',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.gray600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(24),
              width: size.width,
              decoration: BoxDecoration(
                color: SDSColor.snowliveWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('지난 시즌 이용한 슬로프',
                      style: SDSTextStyle.regular.copyWith(
                          color: SDSColor.gray900.withOpacity(0.5),
                          fontSize: 14)),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 10),
                    child: Text(
                      '${_rankingCrewHistoryViewModel.rankingListCrewBetaList[0].passcount?.length ?? 0}',
                      style: SDSTextStyle.extraBold.copyWith(
                          color: SDSColor.gray900, fontSize: 30),
                    ),
                  ),
                  Column(
                    children: [
                      // 최대값 찾아서 비율 계산에 사용
                      _buildSlopeBars(_rankingCrewHistoryViewModel, size),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(24),
              width: size.width,
              decoration: BoxDecoration(
                color: SDSColor.snowliveWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('총 라이딩 횟수',
                      style: SDSTextStyle.regular.copyWith(
                          color: SDSColor.gray900.withOpacity(0.5),
                          fontSize: 14)),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 10),
                    child: Text(
                      '${_rankingCrewHistoryViewModel.rankingListCrewBetaList[0].passcountTotal}',
                      style: SDSTextStyle.extraBold.copyWith(
                          color: SDSColor.gray900, fontSize: 30),
                    ),
                  ),
                  Column(
                    children: [
                      // 최대값 찾아서 비율 계산에 사용
                      _buildTimeSlotBars(_rankingCrewHistoryViewModel, size),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
  Widget _buildSlopeBars(RankingCrewHistoryViewModel viewModel, Size size) {
    // passcount 데이터가 있는지 확인
    if (viewModel.rankingListCrewBetaList.isEmpty ||
        viewModel.rankingListCrewBetaList[0].passcount == null ||
        viewModel.rankingListCrewBetaList[0].passcount!.isEmpty) {
      return Container(
        height: size.height - 200,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 80),
            child: Column(
              children: [
                Image.asset(
                  'assets/imgs/imgs/img_resoreHome_nodata.png',
                  fit: BoxFit.cover,
                  width: 72,
                  height: 72,
                ),
                Text(
                  '데이터가 없어요',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: SDSColor.gray600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // passcount가 있는 경우에만 그래프를 그립니다.
    final passcount = viewModel.rankingListCrewBetaList[0].passcount!;

    // 최대값 찾기
    int maxPassCount = passcount.values.fold(0, (previousValue, element) => element > previousValue ? element : previousValue);

    return Column(
      children: passcount.entries.map<Widget>((entry) {
        String slopeName = entry.key;
        int slopePassCount = entry.value;
        double barWidthRatio = (slopePassCount / maxPassCount);  // 최대값 기준으로 비율 계산

        return Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 44,
                child: Text(
                  slopeName,
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 11,
                    color: SDSColor.sBlue600,
                  ),
                ),
              ),
              Container(
                height: 14,
                width: (size.width - 166) * barWidthRatio,  // 너비 비율 적용
                decoration: BoxDecoration(
                    color: SDSColor.blue200,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4)
                    )
                ),
              ),
              SizedBox(width: 6),
              Text(
                '$slopePassCount',
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 12,
                  color: SDSColor.gray900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  Widget _buildTimeSlotBars(RankingCrewHistoryViewModel viewModel, Size size) {
    final passcountTime = viewModel.rankingListCrewBetaList[0].passcountTime!;

    // 최대값 찾기
    int maxPassCount = passcountTime.values.fold(0, (previousValue, element) => element > previousValue ? element : previousValue);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: passcountTime.entries.map<Widget>((entry) {
        String timeSlot = entry.key;
        int timePassCount = entry.value;
        double barHeightRatio = (timePassCount / maxPassCount);  // 최대값을 기준으로 비율 계산

        return Container(
          width: 30,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '$timePassCount',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 12,
                    color: SDSColor.gray900,
                  ),
                ),
              ),
              Container(
                width: 16,
                height: 140 * barHeightRatio,  // 높이 비율 적용
                decoration: BoxDecoration(
                    color: SDSColor.blue200,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4), topLeft: Radius.circular(4)
                    )
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: 20,
                child: Text(
                  timeSlot,
                  style: SDSTextStyle.regular.copyWith(
                      fontSize: 11,
                      color: SDSColor.sBlue600,
                      height: 1.2
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


}
