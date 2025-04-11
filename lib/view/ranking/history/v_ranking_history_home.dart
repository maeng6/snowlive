import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/ranking/history/v_rankingList_Indi_recordRoom.dart';
import 'package:com.snowlive/view/ranking/history/v_rankingList_beta.dart';
import 'package:com.snowlive/view/ranking/history/v_rankingList_crew_recordRoom.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList_recordRoom.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RankingHistoryHomeView extends StatelessWidget {

  final RankingListViewModel_recordRoom _rankingListViewModel_recordRoom = Get.find<RankingListViewModel_recordRoom>();

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상태바 투명하게
      statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 밝기
    ));

    Size _size = MediaQuery.of(context).size;

    return Scaffold(

      backgroundColor: Colors.white,
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
          title: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              children: [
                Text(
                  '랭킹 기록실',
                  style: SDSTextStyle.extraBold.copyWith(
                      color: SDSColor.gray900,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          actions: [
            Obx(()=>Padding(
              padding: EdgeInsets.only(top: 12, bottom: 8),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Stack(
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              showModalBottomSheet(
                                  enableDrag: false,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 16,
                                          ),
                                          height: MediaQuery.of(context).size.height * 0.6,
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Scrollbar(
                                            child: SingleChildScrollView(
                                              child: Wrap(
                                                children: [
                                                  //  24/25시즌
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '${RankingFilter_season.season2425.korean}',
                                                        style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 15,
                                                            color: SDSColor.gray900
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _rankingListViewModel_recordRoom.changeMyBoxText();
                                                      _rankingListViewModel_recordRoom.changeTap('크루랭킹');
                                                      _rankingListViewModel_recordRoom.changeDayOrTotal('누적');
                                                      _rankingListViewModel_recordRoom.changeResortOrTotal('전체스키장');
                                                      _rankingListViewModel_recordRoom.changeCategory_resort('스키장별 랭킹');
                                                      _rankingListViewModel_recordRoom.changeCategory_fed('리그별 랭킹');
                                                      _rankingListViewModel_recordRoom.changeResortNum(99);
                                                      _rankingListViewModel_recordRoom.changeCategory_resort('${RankingFilter_resort.initial.korean}');
                                                      _rankingListViewModel_recordRoom.changeCategory_season('${RankingFilter_season.season2425.korean}');
                                                      _rankingListViewModel_recordRoom.changeMyBoxText();
                                                      await _rankingListViewModel_recordRoom.toggleDataDayOrTotal_tapFilter();
                                                    },
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(16)),
                                                  ),
                                                  //  23/24시즌
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '${RankingFilter_season.season2324.korean}',
                                                        style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 15,
                                                            color: SDSColor.gray900
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _rankingListViewModel_recordRoom.changeMyBoxText();
                                                      _rankingListViewModel_recordRoom.changeTap('크루랭킹');
                                                      _rankingListViewModel_recordRoom.changeDayOrTotal('누적');
                                                      _rankingListViewModel_recordRoom.changeResortOrTotal('전체스키장');
                                                      _rankingListViewModel_recordRoom.changeCategory_resort('스키장별 랭킹');
                                                      _rankingListViewModel_recordRoom.changeCategory_fed('리그별 랭킹');
                                                      _rankingListViewModel_recordRoom.changeResortNum(99);
                                                      _rankingListViewModel_recordRoom.changeCategory_resort('${RankingFilter_resort.initial.korean}');
                                                      _rankingListViewModel_recordRoom.changeCategory_season('${RankingFilter_season.season2324.korean}');
                                                      _rankingListViewModel_recordRoom.changeMyBoxText();
                                                      await _rankingListViewModel_recordRoom.toggleDataDayOrTotal_tapFilter();
                                                    },
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(16)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                overlayColor: Colors.transparent,
                                padding: EdgeInsets.only(
                                    right: 32, left: 12, top: 3, bottom: 2),
                                backgroundColor: SDSColor.snowliveWhite,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                            child:
                            Text('${_rankingListViewModel_recordRoom.selectedCategory_season}',
                                style: SDSTextStyle.bold.copyWith(
                                    fontSize: 13,
                                    color: Color(0xFF111111)))
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () async {
                              showModalBottomSheet(
                                  enableDrag: false,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: 16,
                                          ),
                                          height: MediaQuery.of(context).size.height * 0.5,
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: SingleChildScrollView(
                                            child: Wrap(
                                              children: [
                                                //  24/25시즌
                                                ListTile(
                                                  contentPadding: EdgeInsets.zero,
                                                  title: Center(
                                                    child: Text(
                                                      '${RankingFilter_season.season2425.korean}',
                                                      style: SDSTextStyle.bold.copyWith(
                                                          fontSize: 15,
                                                          color: SDSColor.gray900
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    _rankingListViewModel_recordRoom.changeMyBoxText();
                                                    _rankingListViewModel_recordRoom.changeTap('크루랭킹');
                                                    _rankingListViewModel_recordRoom.changeDayOrTotal('누적');
                                                    _rankingListViewModel_recordRoom.changeResortOrTotal('전체스키장');
                                                    _rankingListViewModel_recordRoom.changeCategory_resort('스키장별 랭킹');
                                                    _rankingListViewModel_recordRoom.changeCategory_fed('리그별 랭킹');
                                                    _rankingListViewModel_recordRoom.changeResortNum(99);
                                                    _rankingListViewModel_recordRoom.changeCategory_resort('${RankingFilter_resort.initial.korean}');
                                                    _rankingListViewModel_recordRoom.changeCategory_season('${RankingFilter_season.season2425.korean}');
                                                    _rankingListViewModel_recordRoom.changeMyBoxText();
                                                    await _rankingListViewModel_recordRoom.toggleDataDayOrTotal_tapFilter();
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(16)),
                                                ),
                                                //  23/24시즌
                                                ListTile(
                                                  contentPadding: EdgeInsets.zero,
                                                  title: Center(
                                                    child: Text(
                                                      '${RankingFilter_season.season2324.korean}',
                                                      style: SDSTextStyle.bold.copyWith(
                                                          fontSize: 15,
                                                          color: SDSColor.gray900
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    _rankingListViewModel_recordRoom.changeMyBoxText();
                                                    _rankingListViewModel_recordRoom.changeTap('크루랭킹');
                                                    _rankingListViewModel_recordRoom.changeDayOrTotal('누적');
                                                    _rankingListViewModel_recordRoom.changeResortOrTotal('전체스키장');
                                                    _rankingListViewModel_recordRoom.changeCategory_resort('스키장별 랭킹');
                                                    _rankingListViewModel_recordRoom.changeCategory_fed('리그별 랭킹');
                                                    _rankingListViewModel_recordRoom.changeResortNum(99);
                                                    _rankingListViewModel_recordRoom.changeCategory_resort('${RankingFilter_resort.initial.korean}');
                                                    _rankingListViewModel_recordRoom.changeCategory_season('${RankingFilter_season.season2324.korean}');
                                                    _rankingListViewModel_recordRoom.changeMyBoxText();
                                                    await _rankingListViewModel_recordRoom.toggleDataDayOrTotal_tapFilter();
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(16)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: (_rankingListViewModel_recordRoom.resortOrTotal != '전체스키장') ? Image.asset(
                              'assets/imgs/icons/icon_check_round.png',
                              fit: BoxFit.cover,
                              width: 16,
                              height: 16,
                            ) : Image.asset(
                              'assets/imgs/icons/icon_check_round_black.png',
                              fit: BoxFit.cover,
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
          centerTitle: true,
          titleSpacing: 0,
          backgroundColor: SDSColor.snowliveWhite,
          foregroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
        body: Obx(()=>SafeArea(
          child: Column(
            children: [
              Container(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 12),
                          child: ElevatedButton(
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              _rankingListViewModel_recordRoom.changeMyBoxText();
                              _rankingListViewModel_recordRoom.changeTap('크루랭킹');
                              _rankingListViewModel_recordRoom.changeDayOrTotal('누적');
                              _rankingListViewModel_recordRoom.changeResortOrTotal('전체스키장');
                              _rankingListViewModel_recordRoom.changeCategory_resort('스키장별 랭킹');
                              _rankingListViewModel_recordRoom.changeCategory_fed('리그별 랭킹');
                              _rankingListViewModel_recordRoom.changeResortNum(99);
                              _rankingListViewModel_recordRoom.changeCategory_resort('${RankingFilter_resort.initial.korean}');
                              _rankingListViewModel_recordRoom.changeMyBoxText();
                              await _rankingListViewModel_recordRoom.toggleDataDayOrTotal_tapFilter();
                            },
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              overlayColor: Colors.transparent,
                              padding: EdgeInsets.only(top: 0),
                              minimumSize: Size(40, 10),
                              backgroundColor: Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: Container(
                              child: Text(
                                '크루랭킹',
                                style: SDSTextStyle.extraBold.copyWith(
                                    color: (_rankingListViewModel_recordRoom.tapName=='크루랭킹')
                                        ? Color(0xFF111111)
                                        : Color(0xFFC8C8C8),
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: ElevatedButton(
                            child: Text(
                              '개인랭킹',
                              style: SDSTextStyle.extraBold.copyWith(
                                  color: (_rankingListViewModel_recordRoom.tapName=='개인랭킹')
                                      ? Color(0xFF111111)
                                      : Color(0xFFDEDEDE),
                                  fontSize: 18),
                            ),
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              _rankingListViewModel_recordRoom.changeTap('개인랭킹');
                              _rankingListViewModel_recordRoom.changeDayOrTotal('누적');
                              _rankingListViewModel_recordRoom.changeResortOrTotal('전체스키장');
                              _rankingListViewModel_recordRoom.changeCategory_resort('스키장별 랭킹');
                              _rankingListViewModel_recordRoom.changeCategory_fed('리그별 랭킹');
                              _rankingListViewModel_recordRoom.changeMyBoxText();
                              await _rankingListViewModel_recordRoom.toggleDataDayOrTotal_tapFilter();
                            },
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              overlayColor: Colors.transparent,
                              padding: EdgeInsets.only(top: 0),
                              minimumSize: Size(40, 10),
                              backgroundColor: Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_rankingListViewModel_recordRoom.tapName=='개인랭킹' && _rankingListViewModel_recordRoom.selectedCategory_season!='23/24시즌')
                Expanded(
                    child: RankingIndiView_recordRoom()),
              if (_rankingListViewModel_recordRoom.tapName=='크루랭킹'&& _rankingListViewModel_recordRoom.selectedCategory_season!='23/24시즌')
                Expanded(
                    child: RankingCrewView_recordRoom()),
              if (_rankingListViewModel_recordRoom.selectedCategory_season=='23/24시즌')
                Expanded(
                    child: RankingBetaView()),
            ],
          ),
    )),
    );
  }
}


