import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/ranking/v_rankingListBeta_crew.dart';
import 'package:com.snowlive/view/ranking/v_rankingListBeta_indiv.dart';
import 'package:com.snowlive/viewmodel/friend/vm_rankingIndivHistory.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList_beta.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RankingIndivHistoryView extends StatelessWidget {

  final RankingIndivHistoryViewModel _rankingIndivHistoryViewModel = Get.find<RankingIndivHistoryViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _statusBarSize = MediaQuery.of(context).padding.top;

    return Obx(()=>Container(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            (_rankingIndivHistoryViewModel.isLoadingBeta_indiv==true)
                ? Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: SDSColor.snowliveWhite,
                      color: SDSColor.snowliveBlue,
                    ),
                  ),
                ],
              ),
            )
                : SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      child: Column(
                        children: [
                          //필터
                          Container(
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 8),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Stack(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.only(
                                                        right: 12, left: 12, top: 2, bottom: 2),
                                                    side: BorderSide(
                                                      width: 1,
                                                      color: SDSColor.gray100,
                                                    ),
                                                    backgroundColor: SDSColor.snowliveWhite,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(50))),
                                                child:
                                                Text('23/24 시즌',
                                                    style: SDSTextStyle.bold.copyWith(
                                                        fontSize: 13,
                                                        color:  Color(0xFF111111)))
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                width: _size.width,
                                decoration: BoxDecoration(
                                  color: SDSColor.blue50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('이번 시즌 탄 슬로프',
                                      style: SDSTextStyle.regular.copyWith(
                                          color: SDSColor.gray900.withOpacity(0.5),
                                          fontSize: 14
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text('${_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcount!.length}',
                                        style: SDSTextStyle.extraBold.copyWith(
                                            color: SDSColor.gray900,
                                            fontSize: 30
                                        ),
                                      ),
                                    ),
                                    if(_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcount!.length != 0)
                                    //그래프처리
                                    if(_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcount!.length == 0)
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
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Container(
                                  padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                  width: _size.width,
                                  decoration: BoxDecoration(
                                    color: SDSColor.blue50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcount != 0)
                                        //그래프처리
                                      if (_rankingIndivHistoryViewModel.rankingListIndivBetaList[0].passcount == 0)
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
                                                      color: SDSColor.gray600
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
          ],
        ),
      ),
    ));
  }
}
