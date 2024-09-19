import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:com.snowlive/view/ranking/v_rankingList_Indi.dart';
import 'package:com.snowlive/view/ranking/v_rankingList_crew.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widget/w_floatingButton_ranking.dart';
import '../../viewmodel/vm_rankingList.dart';
import '../../viewmodel/vm_user.dart';

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

    return Scaffold(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 12),
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
                              _rankingListViewModel.changeTap('개인랭킹');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.only(top: 0),
                              minimumSize: Size(40, 10),
                              backgroundColor: Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: ElevatedButton(
                            onPressed: () async {
                              _rankingListViewModel.changeTap('크루랭킹');
                            },
                            style: ElevatedButton.styleFrom(
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

                      ],
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
        floatingActionButton: Obx(()=>FloatingButtonWithOptions(
          selectedOption: _rankingListViewModel.dayOrTotal,
          onOptionSelected: (String value) {
            _rankingListViewModel.changeDayOrTotal(value);
            if(_rankingListViewModel.selectedResortNum == 99)
            _rankingListViewModel.toggleDataDayOrTotal();
            if(_rankingListViewModel.selectedResortNum != 99)
              _rankingListViewModel.toggleDataDayOrTotal(resortNum: _rankingListViewModel.selectedResortNum);

          },
        )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked);
  }
}


