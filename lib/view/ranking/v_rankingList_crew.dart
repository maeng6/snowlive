import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:com.snowlive/widget/w_verticalDivider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RankingCrewView extends StatelessWidget {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();

  final RankingListViewModel _rankingListViewModel = Get.find<RankingListViewModel>();

  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();

  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Obx(()=>Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            (_rankingListViewModel.isLoadingRankingListCrewList_total==true
                && _rankingListViewModel.isLoadingRankingListCrewList_total_daily==true)
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
                :
            (_rankingListViewModel.rankingListCrewList_total!.length != 0 )
                ? RefreshIndicator(
                onRefresh: () async {
                  //리프레쉬처리
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        //마이인포 박스 - 점수와 랭킹없는경우 안보여주게함
                        if(_rankingListViewModel.rankingListCrewMy_view!.crewName != null)
                          GestureDetector(
                            onTap: () async{
                              CustomFullScreenDialog.showDialog();
                              await _crewDetailViewModel.fetchCrewDetail(
                                  _rankingListViewModel.rankingListCrewMy_view!.crewId!,
                                  _friendDetailViewModel.seasonDate
                              );
                              CustomFullScreenDialog.cancelDialog();
                              Get.toNamed(AppRoutes.crewMain);
                              await _crewMemberListViewModel.fetchCrewMembers(crewId: _rankingListViewModel.rankingListCrewMy_view!.crewId!);

                            },
                            child: Obx(() => Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      //크루로고이미지
                                      Container(
                                        height: 76,
                                        width: 76,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF0F6FF),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: EdgeInsets.all(20),
                                        child: Transform.translate(
                                          offset: Offset(0, 0),
                                          child: ExtendedImage.network(
                                            '${_rankingListViewModel.rankingListCrewMy_view!.crewLogoUrl
                                                ?? crewDefaultLogoUrl['${_rankingListViewModel.rankingListCrewMy_view!.color}']}',
                                            enableMemoryCache: true,
                                            cacheWidth: 300,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(4),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      //크루네임
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(_rankingListViewModel.rankingListCrewMy_view!.crewName??'',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: SDSTextStyle.regular.copyWith(
                                              fontSize: 14,
                                              color: Color(0xFF111111)
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF5F2F7),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 19),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                (_rankingListViewModel.resortOrTotal == '개별스키장')
                                                    ? '${_rankingListViewModel.rankingListCrewMy_view!.resortTotalScore??'-'}'
                                                    : '${_rankingListViewModel.rankingListCrewMy_view!.overallTotalScore??'-'}',
                                                style: SDSTextStyle.bold.copyWith(
                                                  color: Color(0xFF111111),
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 3),
                                                child: Text(_rankingListViewModel.myBox_score,
                                                  style: SDSTextStyle.regular.copyWith(
                                                    color: Color(0xFF111111).withOpacity(0.5),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          buildVerticalDivider_ranking_indi_Screen(),
                                          Container(
                                            child: Column(
                                              children: [
                                                Text((_rankingListViewModel.resortOrTotal == '개별스키장')
                                                    ? '${_rankingListViewModel.rankingListCrewMy_view!.resortRank??'-'}'
                                                    : '${_rankingListViewModel.rankingListCrewMy_view!.overallRank??'-'}',
                                                  style: SDSTextStyle.bold.copyWith(
                                                    color: Color(0xFF111111),
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 3),
                                                  child: Text(_rankingListViewModel.myBox_ranking,
                                                    style: SDSTextStyle.regular.copyWith(
                                                      color: Color(0xFF111111).withOpacity(0.5),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            ),
                          ),
                        //필터
                        Container(
                          height: 56,
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
                                                await _rankingListViewModel.toggleDataDayOrTotal();
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 1);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 2);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 3);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum:4);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 6);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 7);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 8);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 9);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 10);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 11);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 12);
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
                                                                        await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 13);
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
                                            top: 8,
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
                                                                      _rankingListViewModel.changeMyBoxText();
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 1);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 2);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 3);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum:4);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 6);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 7);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 8);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 9);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 10);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 11);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 12);
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
                                                                      await _rankingListViewModel.toggleDataDayOrTotal(resortNum: 13);
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
                                              child: (_rankingListViewModel.resortOrTotal != '전체스키장') ? ExtendedImage.asset(
                                                'assets/imgs/icons/icon_check_round.png',
                                                fit: BoxFit.cover,
                                                width: 16,
                                                height: 16,
                                              ) : ExtendedImage.asset(
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

                        //여기 높이 처리해야함. 지금 500으로 박혀있음. fleamarketList랑 똑같이해보려고했는데 실패
                        (_rankingListViewModel.rankingListCrewList_view!.length != 0 )
                            ? ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: _size.height, // 리스트가 하나여도 최소 높이를 설정
                            maxHeight: _size.height, // 최대 높이 설정
                          ),
                          child: RefreshIndicator(
                            onRefresh: () async{
                              //당겨서 새로고침
                            },
                            child: Scrollbar(
                              controller: _rankingListViewModel.scrollController_crew,
                              child: ListView.builder(
                                physics: AlwaysScrollableScrollPhysics(), // 하나여도 스크롤 가능
                                controller: _rankingListViewModel.scrollController_crew,
                                itemCount: _rankingListViewModel.rankingListCrewList_view!.length,
                                itemBuilder: (context, index) {
                                  final document = _rankingListViewModel.rankingListCrewList_view![index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
                                    child: GestureDetector(
                                      onTap: () async {
                                        CustomFullScreenDialog.showDialog();
                                        await _crewDetailViewModel.fetchCrewDetail(
                                            document.crewId!,
                                            _friendDetailViewModel.seasonDate
                                        );
                                        CustomFullScreenDialog.cancelDialog();
                                        Get.toNamed(AppRoutes.crewMain);
                                        await _crewMemberListViewModel.fetchCrewMembers(crewId: document.crewId!);
                                      },
                                      child: Row(
                                        children: [
                                          // 크루 랭킹 정보 표시
                                          Container(
                                            width: 24,
                                            height: 40,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                if (index == 0) ...[
                                                  Image.asset('assets/imgs/icons/icon_medal_1.png', width: 24),
                                                ] else if (index == 1) ...[
                                                  Image.asset('assets/imgs/icons/icon_medal_2.png', width: 24),
                                                ] else if (index == 2) ...[
                                                  Image.asset('assets/imgs/icons/icon_medal_3.png', width: 24),
                                                ] else ...[
                                                  Expanded(
                                                    child: Center(
                                                      child: AutoSizeText(
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
                                          // 크루 정보
                                          SizedBox(width: 8),
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  spreadRadius: 0,
                                                  blurRadius: 16,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: document.crewLogoUrl!.isNotEmpty
                                                ? ExtendedImage.network(
                                              document.crewLogoUrl!,
                                              enableMemoryCache: true,
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(10),
                                              cacheHeight: 100,
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                            )
                                                : ExtendedImage.network(
                                              '${crewDefaultLogoUrl['${document.color}']}',
                                              enableMemoryCache: true,
                                              cacheHeight: 100,
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(10),
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
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
                                                    Text(document.crewName!,
                                                      style: SDSTextStyle.regular.copyWith(
                                                          fontSize: 14,
                                                          color: Color(0xFF111111)
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 2),
                                                Container(
                                                  width: _size.width - 200,
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        document.baseResortNickname!,
                                                        style: SDSTextStyle.regular.copyWith(
                                                            fontSize: 12,
                                                            color: Color(0xFF949494)
                                                        ),
                                                      ),
                                                      Text('·',
                                                        style: SDSTextStyle.regular.copyWith(
                                                            fontSize: 12,
                                                            color: Color(0xFF949494)
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Text(
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            document.description??'',
                                                            style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 12,
                                                                color: Color(0xFF949494)
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(child: SizedBox()),
                                          Row(
                                            children: [
                                              if (_rankingListViewModel.resortOrTotal == '개별스키장' && document.resortTotalScore != null)
                                                Text('${document.resortTotalScore!.toInt()}점',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    color: Color(0xFF111111),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              if (_rankingListViewModel.resortOrTotal == '전체스키장' && document.overallTotalScore != null)
                                                Text('${document.overallTotalScore!.toInt()}점',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    color: Color(0xFF111111),
                                                    fontSize: 16,
                                                  ),
                                                )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                padding: EdgeInsets.only(bottom: _size.height * 0.45),
                              ),
                            ),
                          ),
                        )

                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 90,
                              child: ExtendedImage.asset(
                                'assets/imgs/icons/icon_nodata_rankin_all.png',
                                enableMemoryCache: true,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text('랭킹전 기록이 없어요',
                                style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal
                                ),),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text('지금 바로 랭킹전에 참여해 보세요',
                                  style: TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal
                                  ),),
                              ),
                            ),
                            SizedBox(
                              height: _size.height / 8,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )

            )
                :Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  child: ExtendedImage.asset(
                    'assets/imgs/icons/icon_nodata_rankin_all.png',
                    enableMemoryCache: true,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text('랭킹전 기록이 없어요',
                    style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 15,
                        fontWeight: FontWeight.normal
                    ),),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('지금 바로 랭킹전에 참여해 보세요',
                      style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 15,
                          fontWeight: FontWeight.normal
                      ),),
                  ),
                ),
                SizedBox(
                  height: _size.height / 8,
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
