import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/friend/vm_rankingIndivHistory.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RankingIndivHistoryView extends StatelessWidget {

  final RankingIndivHistoryViewModel _rankingIndivHistoryViewModel = Get.find<RankingIndivHistoryViewModel>();

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
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // 필터
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          side: BorderSide(
                            width: 1,
                            color: SDSColor.gray100,
                          ),
                          backgroundColor: SDSColor.snowliveWhite,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        child: Text('23/24 시즌',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 13, color: SDSColor.gray900)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // 이번 시즌 탄 슬로프
                if (_rankingIndivHistoryViewModel.rankingListIndivBetaList.isNotEmpty)
                  Column(
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
                                      ExtendedImage.asset(
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
                    ],
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
                                    ExtendedImage.asset(
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
            ),
          ),
        ),
      ),
    ));
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
