import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/ranking/v_rankingList_Indi.dart';
import 'package:com.snowlive/view/ranking/history/v_rankingList_beta.dart';
import 'package:com.snowlive/view/ranking/v_rankingList_crew.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_floatingButton_ranking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RankingHomeView extends StatelessWidget {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  final RankingListViewModel _rankingListViewModel = Get.find<RankingListViewModel>();

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상태바 투명하게
      statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 밝기
    ));

    Size _size = MediaQuery.of(context).size;

    return Obx(()=>Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
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
                              _rankingListViewModel.changeTap('크루랭킹');
                              _rankingListViewModel.changeDayOrTotal('누적');
                              _rankingListViewModel.changeResortOrTotal('전체스키장');
                              _rankingListViewModel.changeCategory_resort('스키장별 랭킹');
                              _rankingListViewModel.changeMyBoxText();
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
                                    color: (_rankingListViewModel.tapName=='크루랭킹')
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
                                  color: (_rankingListViewModel.tapName=='개인랭킹')
                                      ? Color(0xFF111111)
                                      : Color(0xFFDEDEDE),
                                  fontSize: 18),
                            ),
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              _rankingListViewModel.changeTap('개인랭킹');
                              _rankingListViewModel.changeDayOrTotal('누적');
                              _rankingListViewModel.changeResortOrTotal('전체스키장');
                              _rankingListViewModel.changeCategory_resort('스키장별 랭킹');
                              _rankingListViewModel.changeMyBoxText();
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
                    Padding(
                      padding: EdgeInsets.only(right: 14),
                      child:
                      GestureDetector(
                        onTap: (){
                          Get.toNamed(AppRoutes.rankingHistoryHome);
                        } ,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              highlightColor: Colors.transparent,
                              onPressed: () async{
                                Get.toNamed(AppRoutes.rankingHistoryHome);
                              },
                              icon: Image.asset(
                                'assets/imgs/icons/icon_data_history.png',
                                width: 26,
                                height: 26,
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(-6, 0),
                              child: Text('랭킹 기록실',
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.gray900
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_rankingListViewModel.tapName=='개인랭킹')
                Expanded(
                    child: RankingIndiView()),
              if (_rankingListViewModel.tapName=='크루랭킹')
                Expanded(
                    child: RankingCrewView()),
            ],
          ),
        )),
        floatingActionButton:
        FloatingButtonWithOptions(
          selectedOption: _rankingListViewModel.dayOrTotal,
          onOptionSelected: (String value) {
            _rankingListViewModel.changeDayOrTotal(value);
            _rankingListViewModel.changeMyBoxText();
            if(_rankingListViewModel.selectedResortNum == 99)
              _rankingListViewModel.toggleDataDayOrTotal_tapFilter();
            if(_rankingListViewModel.selectedResortNum != 99)
              _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: _rankingListViewModel.selectedResortNum);

          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked));
  }
}


