import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_verticalDivider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RankingIndiView extends StatelessWidget {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();

  final RankingListViewModel _rankingListViewModel = Get.find<RankingListViewModel>();

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
            (_rankingListViewModel.rankingListIndivList_total!.length != 0)
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
                      //마이인포 박스 - 점수와 랭킹없는경우 널처리해야함
                      GestureDetector(
                        onTap: () async{
                          await _friendDetailViewModel.fetchFriendDetailInfo(
                              userId: _userViewModel.user.user_id,
                              friendUserId:_userViewModel.user.user_id,
                              season: _friendDetailViewModel.seasonDate);
                          Get.toNamed(AppRoutes.friendDetail);
                        },
                        child: Obx(() => Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if(_rankingListViewModel.resortOrTotal=='전체스키장' && _rankingListViewModel.dayOrTotal=='누적')
                              Container(
                                height: 76,
                                width: 76,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF0F6FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.only(top: 18, bottom: 14, left: 14, right: 14),
                                child: Transform.translate(
                                  offset: Offset(0, 0),
                                  child: ExtendedImage.network(
                                    '${_rankingListViewModel.rankingListIndivMy_view!.overallTierIconUrl
                                        ??'https://i.esdrop.com/d/f/yytYSNBROy/6rPYflzCCZ.png'}',
                                    enableMemoryCache: true,
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                                              ? '${_rankingListViewModel.rankingListIndivMy_view!.resortTotalScore??'-'}'
                                              : '${_rankingListViewModel.rankingListIndivMy_view!.overallTotalScore??'-'}',
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
                                            Text(
                                              (_rankingListViewModel.resortOrTotal == '개별스키장')
                                                  ? '${_rankingListViewModel.rankingListIndivMy_view!.resortRank??'-'}'
                                                  : '${_rankingListViewModel.rankingListIndivMy_view!.overallRank??'-'}',
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
                                      buildVerticalDivider_ranking_indi_Screen(),
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
                                                    right: 32, left: 12, top: 3, bottom: 2),
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
                                          top: 16,
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
                      (_rankingListViewModel.rankingListIndivList_view!.length != 0)
                          ? Container(
                        height: 300,
                        child: Scrollbar(
                            controller: _rankingListViewModel.scrollController_indiv,
                            child: ListView.builder(
                              controller:  _rankingListViewModel.scrollController_indiv,
                              itemCount: _rankingListViewModel.rankingListIndivList_view!.length,
                              itemBuilder: (context, index) {
                                final document = _rankingListViewModel.rankingListIndivList_view![index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
                                  child: Row(
                                    children: [
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
                                              color: Color(0xFFDFECFF),
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
                                                  return SizedBox.shrink();
                                                case LoadState.completed:
                                                  return state.completedWidget;
                                                case LoadState.failed:
                                                  return ExtendedImage.network(
                                                    '${profileImgUrlList[0].default_round}',
                                                    enableMemoryCache: true,
                                                    cacheHeight: 100,
                                                    shape: BoxShape.circle,
                                                    borderRadius: BorderRadius.circular(8),
                                                    width: 32,
                                                    height: 32,
                                                    fit: BoxFit.cover,
                                                  );
                                                default:
                                                  return null;
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
                                                      color: Color(0xFF111111)
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                      document.resortNickname!,
                                                      style: SDSTextStyle.regular.copyWith(
                                                          fontSize: 12,
                                                          color: Color(0xFF949494)
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
                                                              color: Color(0xFF949494)
                                                          ),
                                                        ),
                                                      ),
                                                      Text(document.crewName!,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: SDSTextStyle.regular.copyWith(
                                                            fontSize: 12,
                                                            color: Color(0xFF949494)
                                                        ),),
                                                    ],
                                                  )
                                              ],
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
                                                  offset: Offset(6, 1),
                                                  child: ExtendedImage.network(
                                                    '${document.overallTierIconUrl}',
                                                    enableMemoryCache: true,
                                                    fit: BoxFit.cover,
                                                    width: 32,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),

                                    ],
                                  ),

                                );
                              },
                              padding: EdgeInsets.only(bottom: 80),
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
              ),
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
