import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/mobile/routes/routes.dart';
import 'package:com.snowlive/mobile/view/friend/v_profilePageCalendar.dart';
import 'package:com.snowlive/mobile/view/friend/v_profilePageCalendar_recordRoom.dart';
import 'package:com.snowlive/core/viewmodel/friend/vm_friendDetail_recordRoom.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingIndivHistory.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RankingIndivHistoryView extends StatelessWidget {

  final RankingIndivHistoryViewModel _rankingIndivHistoryViewModel = Get.find<RankingIndivHistoryViewModel>();
  FriendDetailViewModel_recordRoom _friendDetailViewModel_recordRoom = Get.find<FriendDetailViewModel_recordRoom>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _statusBarHeight = MediaQuery.of(context).padding.top;

    return Obx(() => Container(
      color: Colors.white,
      child: SafeArea(
        child: (_rankingIndivHistoryViewModel.isLoadingBeta_indiv.value)
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    backgroundColor: SDSColor.gray100,
                    color: SDSColor.gray300.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
              child: Column(
                children: [
                  Obx(() => Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 6, left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 시즌 선택 버튼
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();
                                      await showModalBottomSheet(
                                        enableDrag: false,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) => _buildSeasonModal(context),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shadowColor: Colors.transparent,
                                      overlayColor: Colors.transparent,
                                      padding: EdgeInsets.only(right: 32, left: 12, top: 3, bottom: 2),
                                      backgroundColor: SDSColor.snowliveWhite,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: Text(
                                      '${_rankingIndivHistoryViewModel.selectedCategory_season}',
                                      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: Color(0xFF111111)),
                                    ),
                                  ),
                                  Positioned(
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await showModalBottomSheet(
                                          enableDrag: false,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) => _buildSeasonModal(context),
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/imgs/icons/icon_check_round.png',
                                        fit: BoxFit.cover,
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _friendDetailViewModel_recordRoom.changeRidingStaticTab(0);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _friendDetailViewModel_recordRoom.ridingStatisticsTabName == FriendDetailViewModel_recordRoom.ridingStatisticsTabNameListConst[0]
                                          ? SDSColor.gray900
                                          : SDSColor.snowliveWhite,
                                      borderRadius: BorderRadius.circular(30.0),
                                      border: Border.all(
                                        color: _friendDetailViewModel_recordRoom.ridingStatisticsTabName == FriendDetailViewModel_recordRoom.ridingStatisticsTabNameListConst[0]
                                            ? SDSColor.gray900
                                            : SDSColor.gray200,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    height: 32,
                                    child: Text(
                                      FriendDetailViewModel_recordRoom.ridingStatisticsTabNameListConst[0],
                                      style: SDSTextStyle.bold.copyWith(
                                        fontSize: 12,
                                        color: _friendDetailViewModel_recordRoom.ridingStatisticsTabName == FriendDetailViewModel_recordRoom.ridingStatisticsTabNameListConst[0]
                                            ? SDSColor.snowliveWhite
                                            : SDSColor.gray900,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _friendDetailViewModel_recordRoom.changeRidingStaticTab(1);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _friendDetailViewModel_recordRoom.ridingStatisticsTabName == FriendDetailViewModel_recordRoom.ridingStatisticsTabNameListConst[1]
                                          ? SDSColor.gray900
                                          : SDSColor.snowliveWhite,
                                      borderRadius: BorderRadius.circular(30.0),
                                      border: Border.all(
                                        color: _friendDetailViewModel_recordRoom.ridingStatisticsTabName == FriendDetailViewModel_recordRoom.ridingStatisticsTabNameListConst[1]
                                            ? SDSColor.gray900
                                            : SDSColor.gray200,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    height: 32,
                                    child: Text(
                                      FriendDetailViewModel_recordRoom.ridingStatisticsTabNameListConst[1],
                                      style: SDSTextStyle.bold.copyWith(
                                        fontSize: 12,
                                        color: _friendDetailViewModel_recordRoom.ridingStatisticsTabName == FriendDetailViewModel_recordRoom.ridingStatisticsTabNameListConst[1]
                                            ? SDSColor.snowliveWhite
                                            : SDSColor.gray900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
                  (_rankingIndivHistoryViewModel.selectedCategory_season=='23/24시즌')
                      ?ranking_indiv_history_beta(_size, _statusBarHeight)
                            :(_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.overallTotalCount != 0)
                    ? Column(
                      children: [
                        SizedBox(height: 4),
                        // 시즌 정보 상단박스 디자인
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Container(
                            height: 92,
                            padding: const EdgeInsets.only(left: 30),
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                  'FF' + _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.primaryColor,
                                  radix: 16,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: _size.width / 3 - 30,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2),
                                            child: Text(
                                              '총 점수',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 13,
                                                color: SDSColor.snowliveWhite.withOpacity(0.7),
                                              ),
                                            ),
                                          ),
                                          Text('${_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.overallTotalScore.toInt()}점',
                                            style: SDSTextStyle.bold.copyWith(
                                              color: SDSColor.snowliveWhite,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Container(
                                      width: _size.width / 3 - 30,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2),
                                            child: Text(
                                              '통합 랭킹',
                                              style: SDSTextStyle.regular.copyWith(
                                                fontSize: 13,
                                                color: SDSColor.snowliveWhite.withOpacity(0.7),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.overallRank}등',
                                            style: SDSTextStyle.bold.copyWith(
                                              color: SDSColor.snowliveWhite,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 1,
                                      height: 92,
                                      color: Colors.black12,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                                      ),
                                      width: 102,
                                      height: 92,
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 2),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 66,
                                                height: 66,
                                                child: Transform.translate(
                                                  offset: Offset(0, 0),
                                                  child: GestureDetector(
                                                    onTap:(){
                                                      showDialog(
                                                        barrierColor: Colors.black.withOpacity(0.85),
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return Dialog(
                                                            backgroundColor: Colors.transparent, // 다이얼로그 배경을 투명하게 설정
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(context).pop(); // 클릭 시 다이얼로그 닫기
                                                              },
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Container(
                                                                    width: _size.width - 72,
                                                                    child: ExtendedImage.network(
                                                                      _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.overallTierIconUrl, // 이미지 URL 설정
                                                                      cache: true,
                                                                    ),
                                                                  ),
                                                                  Transform.translate(
                                                                    offset: Offset(0, -40),
                                                                    child: Column(
                                                                      children: [
                                                                        Text('${_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.tierNameEng}',
                                                                          style: GoogleFonts.bebasNeue(
                                                                            color: SDSColor.snowliveWhite,
                                                                            fontSize: 36,
                                                                          ),
                                                                        ),
                                                                        Text('${_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.tierNameKor}',
                                                                          style: SDSTextStyle.bold.copyWith(
                                                                            color: SDSColor.snowliveWhite.withOpacity(0.5),
                                                                            fontSize: 16,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),

                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: ExtendedImage.network(
                                                        '${_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.overallTierIconUrl ?? '등급 없음'}',
                                                        enableMemoryCache: true,
                                                        fit: BoxFit.cover,
                                                        loadStateChanged: (ExtendedImageState state) {
                                                          switch (state.extendedImageLoadState) {
                                                            case LoadState.loading:
                                                            // 로딩 중일 때 로딩 인디케이터를 표시
                                                              return Center(
                                                                child: Container(
                                                                  width: 24,
                                                                  height: 24,
                                                                  child: CircularProgressIndicator(
                                                                    strokeWidth: 4,
                                                                    backgroundColor: SDSColor.gray100,
                                                                    color: SDSColor.gray300.withOpacity(0.6),
                                                                  ),
                                                                ),
                                                              );
                                                            case LoadState.completed:
                                                            // 로딩이 완료되었을 때 이미지 반환
                                                              return state.completedWidget;
                                                            case LoadState.failed:
                                                            // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                                              return Padding(
                                                                padding: EdgeInsets.symmetric(horizontal: 2),
                                                                child: Image.asset(
                                                                  'assets/imgs/logos/snowlive_logo_new.png', // 대체 이미지 경로
                                                                  width: 24,
                                                                  color: SDSColor.blue200,
                                                                ),
                                                              );
                                                          }
                                                        }
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Transform.translate(
                                                offset: Offset(0, -6),
                                                child: Text('${_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.tierNameKor}',
                                                  style: SDSTextStyle.bold.copyWith(
                                                      fontSize: 13,
                                                      color: SDSColor.snowliveBlack.withOpacity(0.4)
                                                  ),),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // 누적통계
                        if(_friendDetailViewModel_recordRoom.ridingStatisticsTabName == FriendDetailViewModel_recordRoom.ridingStatisticsTabNameListConst[0])
                          Padding(
                            padding: EdgeInsets.only(left: 16, right: 16, top: 6),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                  width: _size.width,
                                  decoration: BoxDecoration(
                                    color: SDSColor.gray50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('총 라이딩 횟수',
                                            style: SDSTextStyle.regular.copyWith(
                                                color: SDSColor.gray900,
                                                fontSize: 13
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Text('${_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.overallTotalCount}',
                                              style: SDSTextStyle.extraBold.copyWith(
                                                  color: SDSColor.gray900,
                                                  fontSize: 30
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if(_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.countInfo.length != 0)
                                        Column(
                                          children: [
                                            Container(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.countInfo.map<Widget>((data) {
                                                    String slopeName = data.slope;
                                                    int passCount = data.count;
                                                    double barWidthRatio = data.ratio;
                                                    return Padding(
                                                      padding: (data != _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.countInfo.last)
                                                          ? EdgeInsets.only(bottom: 2, top: 4)
                                                          : EdgeInsets.only(bottom: 0, top: 4),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            width: 44,
                                                            child: Text(
                                                              slopeName,
                                                              style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 11,
                                                                color: SDSColor.gray600,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 14,
                                                            width: (_size.width - 160) * barWidthRatio,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                (data == _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.countInfo.first)
                                                                    ? SDSColor.snowliveBlue
                                                                    : SDSColor.gray200,
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius.circular(4),
                                                                    bottomRight: Radius.circular(4)
                                                                )
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: (data == _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.countInfo.first)
                                                                ? EdgeInsets.only(left: 6)
                                                                : EdgeInsets.only(left: 2),
                                                            child: Container(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      color: (data == _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.countInfo.first)
                                                                          ? SDSColor.gray900
                                                                          : Colors.transparent,
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                                    child: Text('$passCount',
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                        fontSize: 12,
                                                                        fontWeight: (data == _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.countInfo.first)
                                                                            ? FontWeight.bold : FontWeight.bold,
                                                                        color: (data == _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.countInfo.first)
                                                                            ? SDSColor.snowliveWhite : SDSColor.gray900,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                )
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(vertical: 24),
                                              child: Container(
                                                height: 1,
                                                width: _size.width - 80,
                                                color: SDSColor.snowliveBlack.withOpacity(0.05),
                                              ),
                                            ),
                                            if (_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.overallTotalCount != 0)
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('시간대별 기록',
                                                    style: SDSTextStyle.regular.copyWith(
                                                        color: SDSColor.gray900,
                                                        fontSize: 13
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 10),
                                                    child: Container(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.timeInfo.entries.map<Widget>((entry) {
                                                          String slotName = entry.key;
                                                          int passCount = entry.value;
                                                          int maxCount = _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.timeInfo_maxCount;
                                                          double barHeightRatio =  passCount/maxCount;
                                                          return Container(
                                                            width: 30,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: [
                                                                AutoSizeText(
                                                                  passCount != 0 ? '$passCount' : '',
                                                                  style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 12,
                                                                    color: SDSColor.gray900,
                                                                  ),
                                                                  minFontSize: 6,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.visible,
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsets.only(top: 4),
                                                                  child:
                                                                  Container(
                                                                    width: 16,
                                                                    height: 100 * barHeightRatio,
                                                                    decoration: BoxDecoration(
                                                                        color: SDSColor.gray200,
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
                                                                      slotName,
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                          fontSize: 11,
                                                                          color: SDSColor.gray600,
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
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      if(_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.seasonRankingInfo.countInfo.length == 0)
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        //일간통계
                        if(_friendDetailViewModel_recordRoom.ridingStatisticsTabName == FriendDetailViewModel_recordRoom.ridingStatisticsTabNameListConst[1])
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                ProfilePageCalendar_recordRoom(
                                  key: ValueKey(_rankingIndivHistoryViewModel.selectedCategory_season),
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Container(
                                        padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                        width: _size.width,
                                        decoration: BoxDecoration(
                                          color: SDSColor.gray50,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('라이딩 횟수',
                                                  style: SDSTextStyle.regular.copyWith(
                                                      color: SDSColor.gray900,
                                                      fontSize: 13
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 6),
                                                  child: Text(
                                                    (_friendDetailViewModel_recordRoom.selectedDailyIndex != -1 &&
                                                        _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo.length > _friendDetailViewModel_recordRoom.selectedDailyIndex)
                                                        ? '${_friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo[_friendDetailViewModel_recordRoom.selectedDailyIndex].daily_total_count}'
                                                        : '0',
                                                    style: SDSTextStyle.extraBold.copyWith(
                                                        color: SDSColor.gray900,
                                                        fontSize: 30
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            (_friendDetailViewModel_recordRoom.selectedDailyIndex != -1 &&
                                                _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo.length > _friendDetailViewModel_recordRoom.selectedDailyIndex)
                                                ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo[_friendDetailViewModel_recordRoom.selectedDailyIndex].dailyInfo.map<Widget>((data) {
                                                    String slopeName = data.slope;
                                                    int passCount = data.count;
                                                    double barWidthRatio = data.ratio;
                                                    return Padding(
                                                      padding: (data != _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo[_friendDetailViewModel_recordRoom.selectedDailyIndex].dailyInfo.last)
                                                          ? EdgeInsets.only(bottom: 2, top: 4)
                                                          : EdgeInsets.only(bottom: 0, top: 4),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 44,
                                                            child: Text(
                                                              slopeName,
                                                              style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 11,
                                                                color: SDSColor.gray600,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 14,
                                                            width: (_size.width - 166) * barWidthRatio,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                (data == _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo[_friendDetailViewModel_recordRoom.selectedDailyIndex].dailyInfo.first)
                                                                    ? SDSColor.snowliveBlue : SDSColor.gray200,
                                                                borderRadius: BorderRadius.only(
                                                                    topRight: Radius.circular(4),
                                                                    bottomRight: Radius.circular(4)
                                                                )
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: (data == _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo[_friendDetailViewModel_recordRoom.selectedDailyIndex].dailyInfo.first)
                                                                ? EdgeInsets.only(left: 6)
                                                                : EdgeInsets.only(left: 2),
                                                            child: Container(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      color: (data == _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo[_friendDetailViewModel_recordRoom.selectedDailyIndex].dailyInfo.first)
                                                                          ? SDSColor.gray900
                                                                          : Colors.transparent,
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                                    child: Text('$passCount',
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                        fontSize: 12,
                                                                        fontWeight: (data == _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo[_friendDetailViewModel_recordRoom.selectedDailyIndex].dailyInfo.first)
                                                                            ? FontWeight.bold : FontWeight.bold,
                                                                        color: (data == _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo[_friendDetailViewModel_recordRoom.selectedDailyIndex].dailyInfo.first)
                                                                            ? SDSColor.snowliveWhite : SDSColor.gray900,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 24),
                                                  child: Container(
                                                    height: 1,
                                                    width: _size.width - 80,
                                                    color: SDSColor.snowliveBlack.withOpacity(0.05),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 10),
                                                  child: Text('시간대별 기록',
                                                    style: SDSTextStyle.regular.copyWith(
                                                        color: SDSColor.gray900,
                                                        fontSize: 13
                                                    ),
                                                  ),
                                                ),
                                                if (_friendDetailViewModel_recordRoom.selectedDailyIndex != -1 &&
                                                    _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo.length > _friendDetailViewModel_recordRoom.selectedDailyIndex)
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo[_friendDetailViewModel_recordRoom.selectedDailyIndex].timeInfo.entries.map<Widget>((entry) {
                                                      String slotName = entry.key;
                                                      int passCount = entry.value;
                                                      int maxCount = _friendDetailViewModel_recordRoom.friendDetailModel_recordRoom.calendarInfo[_friendDetailViewModel_recordRoom.selectedDailyIndex].timeInfo_maxCount;
                                                      double barHeightRatio = passCount / maxCount;
                                                      return Container(
                                                        width: 30,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            AutoSizeText(
                                                              passCount != 0 ? '$passCount' : '',
                                                              style: SDSTextStyle.bold.copyWith(
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
                                                                height: 100 * barHeightRatio,
                                                                decoration: BoxDecoration(
                                                                    color: SDSColor.gray200,
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
                                                                  slotName,
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 11,
                                                                      color: SDSColor.gray600,
                                                                      height: 1.2
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  )
                                              ],
                                            )
                                                : Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(bottom: 30),
                                                child: Column(
                                                  children: [
                                                    Image.asset(
                                                      'assets/imgs/icons/icon_nodata.png',
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 40,
                        )
                      ],)
                            :Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      height: _size.height - 570,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/imgs/icons/icon_nodata.png',
                              width: 74,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text('라이딩 기록이 없어요.',
                              style: SDSTextStyle.regular.copyWith(
                                  fontSize: 14,
                                  color: SDSColor.gray500),),

                          ],
                        ),
                      ),
                    ),
                            ),
                ],
              ),
            ),
          ),
          ),
        );
  }


  Widget _buildSeasonModal(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Wrap(
                children: [
                  ListTile(
                    title: Center(
                      child: Text(
                        '${RankingFilter_season.season2526.korean}',
                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      CustomFullScreenDialog.showDialog();
                      try {
                        _friendDetailViewModel_recordRoom.updateSelectedDailyIndex(-1);
                        await _friendDetailViewModel_recordRoom.getCurrentSeason(season: RankingFilter_season.season2526.korean);
                        await _friendDetailViewModel_recordRoom.fetchFriendDetailInfo_recordRoom(
                          userId: _userViewModel.user.user_id,
                          friendUserId: _userViewModel.user.user_id,
                          selected_season: RankingFilter_season.season2526.dbSeason,
                          isFromRefresh: true,
                        );
                        _rankingIndivHistoryViewModel.changeCategory_season(RankingFilter_season.season2526.korean);
                      } finally {
                        CustomFullScreenDialog.cancelDialog();
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  ListTile(
                    title: Center(
                      child: Text(
                        '${RankingFilter_season.season2425.korean}',
                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      CustomFullScreenDialog.showDialog();
                      try {
                        _friendDetailViewModel_recordRoom.updateSelectedDailyIndex(-1);
                        await _friendDetailViewModel_recordRoom.getCurrentSeason(season: RankingFilter_season.season2425.korean);
                        await _friendDetailViewModel_recordRoom.fetchFriendDetailInfo_recordRoom(
                          userId: _userViewModel.user.user_id,
                          friendUserId: _userViewModel.user.user_id,
                          selected_season: RankingFilter_season.season2425.dbSeason,
                          isFromRefresh: true,
                        );
                        _rankingIndivHistoryViewModel.changeCategory_season(RankingFilter_season.season2425.korean);
                      } finally {
                        CustomFullScreenDialog.cancelDialog();
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  ListTile(
                    title: Center(
                      child: Text(
                        '${RankingFilter_season.season2324.korean}',
                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      _friendDetailViewModel_recordRoom.updateSelectedDailyIndex(-1);
                      await _friendDetailViewModel_recordRoom.getCurrentSeason(season: RankingFilter_season.season2324.korean);
                      _rankingIndivHistoryViewModel.changeCategory_season(RankingFilter_season.season2324.korean);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }




  Column ranking_indiv_history_beta(Size _size, double _statusBarHeight) {
    return Column(
                children: [
                    Column(
                      children: [
                        if (_rankingIndivHistoryViewModel.rankingListIndivBetaList.isNotEmpty)
                        // 이번 시즌 탄 슬로프
                        Container(
                          padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                          width: _size.width,
                          decoration: BoxDecoration(
                            color: SDSColor.gray50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('지난 시즌 이용한 슬로프',
                                style: SDSTextStyle.regular.copyWith(
                                    color: SDSColor.gray900.withOpacity(0.5),
                                    fontSize: 14
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcount?.length ?? 0}',
                                  style: SDSTextStyle.extraBold.copyWith(
                                      color: SDSColor.gray900, fontSize: 30),
                                ),
                              ),

                              // 슬로프 정보 및 그래프
                              if (_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcount != null &&
                                  _rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcount!.isNotEmpty)
                                Column(
                                  children: [
                                    // 최대값 찾아서 비율 계산에 사용
                                    _buildSlopeBars(_rankingIndivHistoryViewModel, _size),
                                  ],
                                ),

                              if (_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcount!.isEmpty)
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
                                                color: SDSColor.gray600)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // 총 라이딩 횟수 및 시간별 그래프
                        if (_rankingIndivHistoryViewModel.rankingListIndivBetaList.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: EdgeInsets.all(24),
                              width: _size.width,
                              decoration: BoxDecoration(
                                color: SDSColor.gray50,
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
                                      '${_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcountTotal ?? 0}',
                                      style: SDSTextStyle.extraBold.copyWith(
                                          color: SDSColor.gray900, fontSize: 30),
                                    ),
                                  ),

                                  if (_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcountTime != null &&
                                      _rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcountTime!.isNotEmpty)
                                    Column(
                                      children: [
                                        _buildTimeSlotBars(_rankingIndivHistoryViewModel, _size),
                                      ],
                                    ),

                                  if (_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcountTime!.isEmpty)
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
                                                    color: SDSColor.gray600)),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                        if (_rankingIndivHistoryViewModel.rankingListIndivBetaList.isEmpty)
                          Container(
                            height: _size.height - _statusBarHeight - 44 - 300,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/imgs/icons/icon_nodata.png',
                                    scale: 4,
                                    width: 73,
                                    height: 73,
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text('지난 시즌 기록이 없어요',
                                    style: SDSTextStyle.regular.copyWith(
                                        fontSize: 14,
                                        color: SDSColor.gray700
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )


                ],
              );
  }

  // 슬로프 그래프 빌드 함수
  Widget _buildSlopeBars(RankingIndivHistoryViewModel viewModel, Size size) {
    final passcount = viewModel.rankingListIndivBetaList[0].passcount!;

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
                    color: SDSColor.blue500,
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

  // 시간 구간 그래프 빌드 함수
  Widget _buildTimeSlotBars(RankingIndivHistoryViewModel viewModel, Size size) {
    final passcountTime = viewModel.rankingListIndivBetaList[0].passcountTime!;

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
              AutoSizeText(
                '$timePassCount',
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 12,
                  color: SDSColor.gray900,
                ),
                minFontSize: 6,
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
              Container(
                width: 16,
                height: 140 * barHeightRatio,  // 높이 비율 적용
                decoration: BoxDecoration(
                    color: SDSColor.blue500,
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
