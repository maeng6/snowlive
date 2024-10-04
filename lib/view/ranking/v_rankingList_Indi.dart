import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_verticalDivider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

class RankingIndiView extends StatelessWidget {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();

  final RankingListViewModel _rankingListViewModel = Get.find<RankingListViewModel>();
  final ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Obx(()=>Container(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            (_rankingListViewModel.isLoadingRankingListIndiv_total==true
                && _rankingListViewModel.isLoadingRankingListIndiv_total_daily==true)
                ? Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
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
                ],
              ),
            )
                :
            (_rankingListViewModel.rankingListIndivList_total!.length != 0)
                ? RefreshIndicator(
              strokeWidth: 2,
              edgeOffset: -40,
              displacement: 40,
              backgroundColor: SDSColor.snowliveBlue,
              color: SDSColor.snowliveWhite,
              onRefresh: () async {
                await _rankingListViewModel.toggleDataDayOrTotal_refresh();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                    child: (_rankingListViewModel.rankingListIndivList_view!.length != 0)
                        ? Scrollbar(
                      controller: _rankingListViewModel.scrollController_indiv,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        controller:  _rankingListViewModel.scrollController_indiv,
                        itemCount: _rankingListViewModel.rankingListIndivList_view!.length + 2,
                        itemBuilder: (context, index) {
                          if(index == 0){
                            return Column(children: [
                              //마이인포 박스 - 점수와 랭킹없는경우 널처리해야함
                              GestureDetector(
                                onTap: () async{
                                  Get.toNamed(AppRoutes.friendDetail);
                                  await _friendDetailViewModel.fetchFriendDetailInfo(
                                      userId: _userViewModel.user.user_id,
                                      friendUserId:_userViewModel.user.user_id,
                                      season: _friendDetailViewModel.seasonDate);
                                },
                                child: Obx(() => Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 4, right: 6),
                                        child: Text(_rankingListViewModel.myBox_title,
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 14,
                                              color: SDSColor.gray900
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width:
                                            (_rankingListViewModel.rankingListIndivMy_view?.overallTotalScore != null
                                                && _rankingListViewModel.resortOrTotal == '전체스키장' && _rankingListViewModel.dayOrTotal == '누적')
                                                ? _size.width - 124
                                                :_size.width - 32,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: SDSColor.gray50,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 18),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          (_rankingListViewModel.resortOrTotal == '개별스키장')
                                                              ? '${_rankingListViewModel.rankingListIndivMy_view?.resortTotalScore ?? '-'}'
                                                              : '${_rankingListViewModel.rankingListIndivMy_view?.overallTotalScore ?? '-'}',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            color: SDSColor.gray900,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 1),
                                                          child: Text(
                                                            _rankingListViewModel.myBox_score,
                                                            style: SDSTextStyle.regular.copyWith(
                                                              color: SDSColor.gray500,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    buildVerticalDivider_ranking_indi_Screen(),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          (_rankingListViewModel.resortOrTotal == '개별스키장')
                                                              ? '${_rankingListViewModel.rankingListIndivMy_view?.resortRank ?? '-'}'
                                                              : '${_rankingListViewModel.rankingListIndivMy_view?.overallRank ?? '-'}',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            color: SDSColor.gray900,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 1),
                                                          child: Text(
                                                            _rankingListViewModel.myBox_ranking,
                                                            style: SDSTextStyle.regular.copyWith(
                                                              color: SDSColor.gray500,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if(_rankingListViewModel.rankingListIndivMy_view?.overallTotalScore != null
                                              && _rankingListViewModel.resortOrTotal == '전체스키장' && _rankingListViewModel.dayOrTotal == '누적')
                                            SizedBox(width: 12),
                                          if(_rankingListViewModel.rankingListIndivMy_view?.overallTotalScore != null
                                              && _rankingListViewModel.resortOrTotal == '전체스키장' && _rankingListViewModel.dayOrTotal == '누적')
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: SDSColor.blue50,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              padding: EdgeInsets.all(8),
                                              child: Transform.translate(
                                                offset: Offset(0, 0),
                                                child: GestureDetector(
                                                  onTap:(){
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return Dialog(
                                                          backgroundColor: Colors.transparent, // 다이얼로그 배경을 투명하게 설정
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(context).pop(); // 클릭 시 다이얼로그 닫기
                                                            },
                                                            child: Center(
                                                              child: PhotoView(
                                                                imageProvider: ExtendedNetworkImageProvider(
                                                                  _rankingListViewModel.rankingListIndivMy_view!.overallTierIconUrl!, // 이미지 URL 설정
                                                                  cache: true, // 캐싱 옵션
                                                                ),
                                                                backgroundDecoration: const BoxDecoration(
                                                                  color: Colors.transparent, // 배경을 투명으로 설정
                                                                ),
                                                                minScale: PhotoViewComputedScale.contained, // 최소 확대 비율
                                                                maxScale: PhotoViewComputedScale.covered * 7, // 최대 확대 비율

                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: ExtendedImage.network(
                                                      '${_rankingListViewModel.rankingListIndivMy_view?.overallTierIconUrl ?? '등급 없음'}',
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
                                        ],
                                      ),
                                    ],
                                  ),
                                )

                                ),
                              ),
                              //필터
                              Container(
                                height: 60,
                                child: Row(
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
                                                    onPressed: () async {
                                                      HapticFeedback.lightImpact();
                                                      _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.initial.korean}');
                                                      _rankingListViewModel.changeResortOrTotal('전체스키장');
                                                      _rankingListViewModel.changeResortNum(99);
                                                      _rankingListViewModel.changeMyBoxText();
                                                      await _rankingListViewModel.toggleDataDayOrTotal_tapFilter();
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        shadowColor: Colors.transparent,
                                                        overlayColor: Colors.transparent,
                                                        padding: EdgeInsets.only(
                                                            right: 12, left: 12, top: 2, bottom: 2),
                                                        side: BorderSide(
                                                          width: 1,
                                                          color: (_rankingListViewModel.resortOrTotal == '전체스키장') ? SDSColor.gray900 : SDSColor.gray100,
                                                        ),
                                                        backgroundColor: (_rankingListViewModel.resortOrTotal == '전체스키장') ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(50))),
                                                    child:
                                                    Text('${RankingFilter_resort.total.korean}',
                                                        style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 13,
                                                            color: (_rankingListViewModel.resortOrTotal == '전체스키장') ? Color(0xFFFFFFFF) : Color(0xFF111111)))
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 16, bottom: 8),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(right: 8),
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
                                                                          //곤지암 1
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.konjiam.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.konjiam.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(1);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 1);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //무주 2
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.muju.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.muju.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(2);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 2);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //비발디 3
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.vivaldi.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.vivaldi.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(3);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 3);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //알펜 4
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.alphen.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.alphen.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(4);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum:4);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //강촌 6
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.gangchon.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.gangchon.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(6);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 6);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //오크 7
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.oak.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.oak.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(7);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 7);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //오투 8
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.o2.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.o2.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(8);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 8);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //용평 9
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.yongpyong.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.yongpyong.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(9);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 9);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //웰팍 10
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.welli.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.welli.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(10);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 10);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //지산 11
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.jisan.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.jisan.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(11);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 11);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //하이원 12
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.high1.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.high1.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(12);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 12);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //휘닉스 13
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.phoenix.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.phoenix.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(13);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 13);
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
                                                        side: BorderSide(
                                                          width: 1,
                                                          color: (_rankingListViewModel.resortOrTotal != '전체스키장') ? SDSColor.gray900 : SDSColor.gray100,
                                                        ),
                                                        backgroundColor: (_rankingListViewModel.resortOrTotal != '전체스키장') ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(50))),
                                                    child:
                                                    Text('${_rankingListViewModel.selectedCategory_resort}',
                                                        style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 13,
                                                            color: (_rankingListViewModel.resortOrTotal != '전체스키장') ? Color(0xFFFFFFFF) : Color(0xFF111111)))
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
                                                                        //곤지암 1
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.konjiam.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.konjiam.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(1);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 1);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //무주 2
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.muju.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.muju.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(2);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 2);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //비발디 3
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.vivaldi.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.vivaldi.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(3);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 3);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //알펜 4
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.alphen.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.alphen.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(4);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum:4);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //강촌 6
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.gangchon.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.gangchon.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(6);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 6);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //오크 7
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.oak.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.oak.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(7);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 7);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //오투 8
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.o2.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.o2.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(8);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 8);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //용평 9
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.yongpyong.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.yongpyong.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(9);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 9);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //웰팍 10
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.welli.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.welli.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(10);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 10);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //지산 11
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.jisan.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.jisan.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(11);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 11);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //하이원 12
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.high1.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.high1.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(12);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 12);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //휘닉스 13
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.phoenix.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.phoenix.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(13);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 13);
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
                                                    child: (_rankingListViewModel.resortOrTotal != '전체스키장')
                                                        ? Image.asset(
                                                      'assets/imgs/icons/icon_check_round.png',
                                                      fit: BoxFit.cover,
                                                      width: 16,
                                                      height: 16,)
                                                        : Image.asset(
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
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],);
                          }else if(index == _rankingListViewModel.rankingListIndivList_view!.length + 1){
                            return Obx(() => _rankingListViewModel.isLoadingRankingListIndiv_next // 여기서 Obx 사용
                                ? Container(
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
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
                                ],
                              ),
                            )
                                : SizedBox.shrink()); // 로딩이 완료되면 빈 공간
                          }
                          else{
                            final document = _rankingListViewModel.rankingListIndivList_view![index - 1];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8, left: 2),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (index == 1) ...[
                                          Image.asset('assets/imgs/icons/icon_medal_1.png', width: 24),
                                        ] else if (index == 2) ...[
                                          Image.asset('assets/imgs/icons/icon_medal_2.png', width: 24),
                                        ] else if (index == 3) ...[
                                          Image.asset('assets/imgs/icons/icon_medal_3.png', width: 24),
                                        ] else ...[
                                          Expanded(
                                            child: Center(
                                              child:
                                              AutoSizeText(
                                                (_rankingListViewModel.resortOrTotal=='개별스키장')
                                                    ?'${document.resortRank??''}'
                                                    :'${document.overallRank??''}',
                                                style: SDSTextStyle.bold.copyWith(
                                                    fontSize: 14,
                                                    color: Color(0xFF111111)
                                                ),
                                                maxLines: 1,
                                                minFontSize: 6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () async{
                                      Get.toNamed(AppRoutes.friendDetail);
                                      await _friendDetailViewModel.fetchFriendDetailInfo(
                                        userId: _userViewModel.user.user_id,
                                        friendUserId: document.userId!,
                                        season: _friendDetailViewModel.seasonDate,
                                      );
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: SDSColor.gray100,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(50)
                                      ),
                                      child: document.profileImageUrlUser!.isNotEmpty
                                          ? ExtendedImage.network(
                                        document.profileImageUrlUser!,
                                        enableMemoryCache: true,
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(8),
                                        cacheHeight: 100,
                                        width: 32,
                                        height: 32,
                                        cacheWidth: 100,
                                        fit: BoxFit.cover,
                                        loadStateChanged: (ExtendedImageState state) {
                                          switch (state.extendedImageLoadState) {
                                            case LoadState.loading:
                                            // 로딩 중일 때 로딩 인디케이터를 표시
                                              return Shimmer.fromColors(
                                                baseColor: SDSColor.gray200!,
                                                highlightColor: SDSColor.gray50!,
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              );
                                            case LoadState.completed:
                                            // 로딩이 완료되었을 때 이미지 반환
                                              return state.completedWidget;
                                            case LoadState.failed:
                                            // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                              return Image.asset(
                                                'assets/imgs/profile/img_profile_default_circle.png',
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              );
                                          }
                                        },
                                      )
                                          : ExtendedImage.network(
                                        '${profileImgUrlList[0].default_round}',
                                        enableMemoryCache: true,
                                        cacheHeight: 100,
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(8),
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                        loadStateChanged: (ExtendedImageState state) {
                                          switch (state.extendedImageLoadState) {
                                            case LoadState.loading:
                                            // 로딩 중일 때 로딩 인디케이터를 표시
                                              return Shimmer.fromColors(
                                                baseColor: SDSColor.gray200!,
                                                highlightColor: SDSColor.gray50!,
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              );
                                            case LoadState.completed:
                                            // 로딩이 완료되었을 때 이미지 반환
                                              return state.completedWidget;
                                            case LoadState.failed:
                                            // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                              return Image.asset(
                                                'assets/imgs/profile/img_profile_default_circle.png',
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text(document.displayName!,
                                              style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 14,
                                                  color: SDSColor.gray900
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: _size.width - 200,
                                          child: Row(
                                            children: [
                                              Text(
                                                document.resortNickname!,
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 12,
                                                    color: SDSColor.gray500
                                                ),
                                              ),

                                              if(document.crewName != null)
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                                      child: Text('·',
                                                        style: SDSTextStyle.regular.copyWith(
                                                            fontSize: 12,
                                                            color: SDSColor.gray500
                                                        ),
                                                      ),
                                                    ),
                                                    Text(document.crewName!,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: SDSTextStyle.regular.copyWith(
                                                          fontSize: 12,
                                                          color: SDSColor.gray500
                                                      ),),
                                                  ],
                                                )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(child: SizedBox()),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          if(_rankingListViewModel.resortOrTotal == '개별스키장' && document.resortTotalScore != null)
                                            Text('${document.resortTotalScore!.toInt()}점',
                                              style: SDSTextStyle.regular.copyWith(
                                                color: Color(0xFF111111),
                                                fontSize: 16,
                                              ),
                                            ),
                                          if(_rankingListViewModel.resortOrTotal == '전체스키장' && document.overallTotalScore != null)
                                            Text('${document.overallTotalScore!.toInt()}점',
                                              style: SDSTextStyle.regular.copyWith(
                                                color: Color(0xFF111111),
                                                fontSize: 16,
                                              ),
                                            ),
                                          if(_rankingListViewModel.resortOrTotal=='전체스키장' && _rankingListViewModel.dayOrTotal=='누적')
                                            Transform.translate(
                                              offset: Offset(4, 1),
                                              child: ExtendedImage.network(
                                                '${document.overallTierIconUrl}',
                                                enableMemoryCache: true,
                                                fit: BoxFit.cover,
                                                width: 36,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),

                                ],
                              ),

                            );
                          }
                        },
                        padding: EdgeInsets.only(bottom: 80),
                      ),
                    )
                        : Scrollbar(
                      controller: _rankingListViewModel.scrollController_indiv,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        controller:  _rankingListViewModel.scrollController_indiv,
                        itemCount: _rankingListViewModel.rankingListIndivList_view!.length + 2,
                        itemBuilder: (context, index) {
                          if(index == 0){
                            return Column(children: [
                              //마이인포 박스 - 점수와 랭킹없는경우 널처리해야함
                              GestureDetector(
                                onTap: () async{
                                  Get.toNamed(AppRoutes.friendDetail);
                                  await _friendDetailViewModel.fetchFriendDetailInfo(
                                      userId: _userViewModel.user.user_id,
                                      friendUserId:_userViewModel.user.user_id,
                                      season: _friendDetailViewModel.seasonDate);
                                },
                                child: Obx(() => Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 4, right: 6),
                                        child: Text(_rankingListViewModel.myBox_title,
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 14,
                                              color: SDSColor.gray900
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width:
                                            (_rankingListViewModel.rankingListIndivMy_view!.overallTotalScore != null
                                                && _rankingListViewModel.resortOrTotal == '전체스키장' && _rankingListViewModel.dayOrTotal == '누적')
                                                ? _size.width - 124
                                                :_size.width - 32,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: SDSColor.gray50,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 18),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          (_rankingListViewModel.resortOrTotal == '개별스키장')
                                                              ? '${_rankingListViewModel.rankingListIndivMy_view?.resortTotalScore ?? '-'}'
                                                              : '${_rankingListViewModel.rankingListIndivMy_view?.overallTotalScore ?? '-'}',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            color: SDSColor.gray900,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 1),
                                                          child: Text(
                                                            _rankingListViewModel.myBox_score,
                                                            style: SDSTextStyle.regular.copyWith(
                                                              color: SDSColor.gray500,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    buildVerticalDivider_ranking_indi_Screen(),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          (_rankingListViewModel.resortOrTotal == '개별스키장')
                                                              ? '${_rankingListViewModel.rankingListIndivMy_view?.resortRank ?? '-'}'
                                                              : '${_rankingListViewModel.rankingListIndivMy_view?.overallRank ?? '-'}',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            color: SDSColor.gray900,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 1),
                                                          child: Text(
                                                            _rankingListViewModel.myBox_ranking,
                                                            style: SDSTextStyle.regular.copyWith(
                                                              color: SDSColor.gray500,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if(_rankingListViewModel.rankingListIndivMy_view!.overallTotalScore != null
                                              && _rankingListViewModel.resortOrTotal == '전체스키장' && _rankingListViewModel.dayOrTotal == '누적')
                                            SizedBox(width: 12),
                                          if(_rankingListViewModel.rankingListIndivMy_view!.overallTotalScore != null
                                              && _rankingListViewModel.resortOrTotal == '전체스키장' && _rankingListViewModel.dayOrTotal == '누적')
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: SDSColor.blue50,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              padding: EdgeInsets.all(8),
                                              child: Transform.translate(
                                                offset: Offset(0, 0),
                                                child: ExtendedImage.network(
                                                    '${_rankingListViewModel.rankingListIndivMy_view?.overallTierIconUrl ?? '등급 없음'}',
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
                                        ],
                                      ),
                                    ],
                                  ),
                                )

                                ),
                              ),
                              //필터
                              Container(
                                height: 60,
                                child: Row(
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
                                                    onPressed: () async {
                                                      _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.initial.korean}');
                                                      _rankingListViewModel.changeResortOrTotal('전체스키장');
                                                      _rankingListViewModel.changeResortNum(99);
                                                      _rankingListViewModel.changeMyBoxText();
                                                      await _rankingListViewModel.toggleDataDayOrTotal_tapFilter();
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        padding: EdgeInsets.only(
                                                            right: 12, left: 12, top: 2, bottom: 2),
                                                        side: BorderSide(
                                                          width: 1,
                                                          color: (_rankingListViewModel.resortOrTotal == '전체스키장') ? SDSColor.gray900 : SDSColor.gray100,
                                                        ),
                                                        backgroundColor: (_rankingListViewModel.resortOrTotal == '전체스키장') ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(50))),
                                                    child:
                                                    Text('${RankingFilter_resort.total.korean}',
                                                        style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 13,
                                                            color: (_rankingListViewModel.resortOrTotal == '전체스키장') ? Color(0xFFFFFFFF) : Color(0xFF111111)))
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 16, bottom: 8),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(right: 8),
                                            child: Stack(
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () async {
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
                                                                          //곤지암 1
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.konjiam.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.konjiam.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(1);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 1);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //무주 2
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.muju.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.muju.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(2);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 2);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //비발디 3
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.vivaldi.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.vivaldi.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(3);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 3);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //알펜 4
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.alphen.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.alphen.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(4);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum:4);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //강촌 6
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.gangchon.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.gangchon.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(6);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 6);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //오크 7
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.oak.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.oak.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(7);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 7);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //오투 8
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.o2.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.o2.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(8);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 8);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //용평 9
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.yongpyong.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.yongpyong.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(9);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 9);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //웰팍 10
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.welli.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.welli.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(10);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 10);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //지산 11
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.jisan.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.jisan.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(11);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 11);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //하이원 12
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.high1.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.high1.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(12);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 12);
                                                                            },
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(16)),
                                                                          ),
                                                                          //휘닉스 13
                                                                          ListTile(
                                                                            contentPadding: EdgeInsets.zero,
                                                                            title: Center(
                                                                              child: Text(
                                                                                '${RankingFilter_resort.phoenix.korean}',
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 15,
                                                                                    color: SDSColor.gray900
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            onTap: () async {
                                                                              Navigator.pop(context);
                                                                              _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.phoenix.korean}');
                                                                              _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                              _rankingListViewModel.changeResortNum(13);
                                                                              _rankingListViewModel.changeMyBoxText();
                                                                              await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 13);
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
                                                        padding: EdgeInsets.only(
                                                            right: 32, left: 12, top: 3, bottom: 2),
                                                        side: BorderSide(
                                                          width: 1,
                                                          color: (_rankingListViewModel.resortOrTotal != '전체스키장') ? SDSColor.gray900 : SDSColor.gray100,
                                                        ),
                                                        backgroundColor: (_rankingListViewModel.resortOrTotal != '전체스키장') ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(50))),
                                                    child:
                                                    Text('${_rankingListViewModel.selectedCategory_resort}',
                                                        style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 13,
                                                            color: (_rankingListViewModel.resortOrTotal != '전체스키장') ? Color(0xFFFFFFFF) : Color(0xFF111111)))
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
                                                                        //곤지암 1
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.konjiam.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.konjiam.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(1);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 1);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //무주 2
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.muju.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.muju.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(2);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 2);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //비발디 3
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.vivaldi.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.vivaldi.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(3);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 3);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //알펜 4
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.alphen.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.alphen.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(4);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum:4);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //강촌 6
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.gangchon.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.gangchon.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(6);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 6);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //오크 7
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.oak.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.oak.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(7);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 7);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //오투 8
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.o2.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.o2.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(8);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 8);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //용평 9
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.yongpyong.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.yongpyong.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(9);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 9);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //웰팍 10
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.welli.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.welli.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(10);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 10);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //지산 11
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.jisan.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.jisan.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(11);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 11);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //하이원 12
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.high1.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.high1.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(12);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 12);
                                                                          },
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius:
                                                                              BorderRadius.circular(16)),
                                                                        ),
                                                                        //휘닉스 13
                                                                        ListTile(
                                                                          contentPadding: EdgeInsets.zero,
                                                                          title: Center(
                                                                            child: Text(
                                                                              '${RankingFilter_resort.phoenix.korean}',
                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                  fontSize: 15,
                                                                                  color: SDSColor.gray900
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          onTap: () async {
                                                                            Navigator.pop(context);
                                                                            _rankingListViewModel.changeCategory_resort('${RankingFilter_resort.phoenix.korean}');
                                                                            _rankingListViewModel.changeResortOrTotal('개별스키장');
                                                                            _rankingListViewModel.changeResortNum(13);
                                                                            await _rankingListViewModel.toggleDataDayOrTotal_tapFilter(resortNum: 13);
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
                                                    child: (_rankingListViewModel.resortOrTotal != '전체스키장')
                                                        ? Image.asset(
                                                      'assets/imgs/icons/icon_check_round.png',
                                                      fit: BoxFit.cover,
                                                      width: 16,
                                                      height: 16,)
                                                        : Image.asset(
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
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],);
                          } else{
                            return   Container(
                              height: _size.height - 520,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 72,
                                    child: Image.asset('assets/imgs/icons/icon_nodata_rankin_all.png',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Center(
                                    child: Text('랭킹전 기록이 없어요',
                                      style: SDSTextStyle.regular.copyWith(
                                        color: SDSColor.gray500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text('지금 바로 랭킹전에 참여해 보세요',
                                      style: SDSTextStyle.regular.copyWith(
                                        color: SDSColor.gray500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        padding: EdgeInsets.only(bottom: 80),
                      ),
                    )
                ),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExtendedImage.network(
                  '${_resortHomeViewModel.rankingComingSoonUrl}',
                  cache: true,
                  enableMemoryCache: true,
                  width: _size.width -40,
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
