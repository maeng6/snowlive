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
import 'package:flutter_svg/flutter_svg.dart';

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
            child: Padding(padding: EdgeInsets.all(14), child: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26)),
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
              padding: EdgeInsets.only(right: 14),
              child:
              Container(
                decoration: BoxDecoration(
                  color: SDSColor.snowliveWhite,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: SDSColor.gray200, width: 1),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
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
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Text(
                                          '${RankingFilter_season.season2425.korean}',
                                          style: SDSTextStyle.bold.copyWith(
                                            fontSize: 15,
                                            color: SDSColor.gray900,
                                          ),
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
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
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Text(
                                          '${RankingFilter_season.season2324.korean}',
                                          style: SDSTextStyle.bold.copyWith(
                                            fontSize: 15,
                                            color: SDSColor.gray900,
                                          ),
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_rankingListViewModel_recordRoom.selectedCategory_season}',
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Image.asset(
                          'assets/imgs/icons/icon_check_round.png',
                          width: 16,
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ),
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
              Stack(
                children: [
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFececec), width: 1),
                      ),
                    ),
                  ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
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
                          child: Container(
                            width: 120,
                            height: 44,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '크루랭킹',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 15,
                                    color: _rankingListViewModel_recordRoom.tapName == '크루랭킹'
                                        ? const Color(0xFF111111)
                                        : const Color(0xFFC8C8C8),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  height: 2,
                                  width: 72,
                                  color: _rankingListViewModel_recordRoom.tapName == '크루랭킹'
                                      ? const Color(0xFF111111)
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            _rankingListViewModel_recordRoom.changeTap('개인랭킹');
                            _rankingListViewModel_recordRoom.changeDayOrTotal('누적');
                            _rankingListViewModel_recordRoom.changeResortOrTotal('전체스키장');
                            _rankingListViewModel_recordRoom.changeCategory_resort('스키장별 랭킹');
                            _rankingListViewModel_recordRoom.changeCategory_fed('리그별 랭킹');
                            _rankingListViewModel_recordRoom.changeMyBoxText();
                            await _rankingListViewModel_recordRoom.toggleDataDayOrTotal_tapFilter();
                          },
                          child: Container(
                            width: 120,
                            height: 44,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '개인랭킹',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 15,
                                    color: _rankingListViewModel_recordRoom.tapName == '개인랭킹'
                                        ? const Color(0xFF111111)
                                        : const Color(0xFFC8C8C8),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  height: 2,
                                  width: 72,
                                  color: _rankingListViewModel_recordRoom.tapName == '개인랭킹'
                                      ? const Color(0xFF111111)
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                ],
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


