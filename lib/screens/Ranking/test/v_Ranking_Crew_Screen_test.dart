import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_myCrewRankingController.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/screens/Ranking/test/v_Ranking_Crew_All_Screen_test.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/screens/Ranking/v_Ranking_Crew_All_Screen.dart';
import '../../../controller/vm_liveMapController.dart';
import '../../../controller/vm_rankingTierModelController.dart';
import '../../../controller/vm_resortModelController.dart';
import '../../../model/m_crewLogoModel.dart';
import '../../../widget/w_fullScreenDialog.dart';
import '../../LiveCrew/v_crewDetailPage_screen.dart';

class RankingCrewScreen_test extends StatefulWidget {
  RankingCrewScreen_test({Key? key,
    required this.isKusbf,
    required this.isDaily,
    required this.isWeekly,}) : super(key: key);

  bool isKusbf = false;
  bool isDaily = false;
  bool isWeekly = false;

  @override
  State<RankingCrewScreen_test> createState() => _RankingCrewScreen_testState();
}

class _RankingCrewScreen_testState extends State<RankingCrewScreen_test> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  MyCrewRankingController _myCrewRankingController = Get.find<MyCrewRankingController>();
  //TODO: Dependency Injection**************************************************



  var foundCrewLogo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (var crewLogo in crewLogoList) {
      if (_liveCrewModelController.crewColor == crewLogo.crewColor) {
        foundCrewLogo = crewLogo;
        break; // 일치하는 로고를 찾았으므로 루프를 종료합니다.
      }
    }

  }

  int? myCrewRank;
  var assetTop1;
  var assetTop2;
  var assetTop3;
  List? crewDocs;
  Map? crewRankingMap;

  int? myCrewTotalScore;
  int? myCrewTotalPassCount;

  Future<void> _refreshData() async {
    if(_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0) {

      if(widget.isDaily == true){
        await _rankingTierModelController.getRankingDocs_crew_Daily(baseResort: _userModelController.favoriteResort);
        await _myCrewRankingController.getMyCrewRankingDataDaily(_userModelController.liveCrew);
      }
      else if(widget.isWeekly == true){
        await _rankingTierModelController.getRankingDocs_crew_Weekly(baseResort: _userModelController.favoriteResort);
        await _myCrewRankingController.getMyCrewRankingDataWeekly(_userModelController.liveCrew);
      }else{
        await _rankingTierModelController.getRankingDocs_crew(baseResort: _userModelController.favoriteResort);
        await _myCrewRankingController.getMyCrewRankingData(_userModelController.liveCrew);
      }
    }else {

      if(widget.isDaily == true){
        await _rankingTierModelController.getRankingDocs_crew_integrated_Daily();
        await _myCrewRankingController.getMyCrewRankingDataDaily(_userModelController.liveCrew);
      }
      else if(widget.isWeekly == true){
        await _rankingTierModelController.getRankingDocs_crew_integrated_Weekly();
        await _myCrewRankingController.getMyCrewRankingDataWeekly(_userModelController.liveCrew);
      }
      else{
        await _rankingTierModelController.getRankingDocs_crew_integrated();
        await _myCrewRankingController.getMyCrewRankingData(_userModelController.liveCrew);
      }
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    _userModelController.getCurrentUser_crew(_userModelController.uid);
    _userModelController.getCurrentUser_kusbf(_userModelController.uid);

    if(_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0) {
      if(widget.isDaily == true) {
        crewDocs = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_crew_kusbf_daily
            : _rankingTierModelController.rankingDocs_crew_daily;
        crewRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.crewRankingMap_kusbf_daily
            : _rankingTierModelController.crewRankingMap_daily;
        myCrewTotalScore = _myCrewRankingController.totalScore_Daily;
        myCrewTotalPassCount = _myCrewRankingController.totalPassCount_Daily;
      } else if(widget.isWeekly == true) {
        crewDocs = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_crew_kusbf_weekly
            : _rankingTierModelController.rankingDocs_crew_weekly;
        crewRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.crewRankingMap_kusbf_weekly
            : _rankingTierModelController.crewRankingMap_weekly;
        myCrewTotalScore = _myCrewRankingController.totalScore_Weekly;
        myCrewTotalPassCount = _myCrewRankingController.totalPassCount_Weekly;
      } else {
        crewDocs = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_crew_kusbf
            : _rankingTierModelController.rankingDocs_crew;
        crewRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.crewRankingMap_kusbf
            : _rankingTierModelController.crewRankingMap;
        myCrewTotalScore = _myCrewRankingController.totalScore;
        myCrewTotalPassCount = _myCrewRankingController.totalPassCount;
      }
    } else{
      if(widget.isDaily == true) {
        crewDocs = _rankingTierModelController.rankingDocs_crew_integrated_daily;
        crewRankingMap = _rankingTierModelController.crewRankingMap_integrated_daily;
        myCrewTotalScore = _myCrewRankingController.totalScore_Daily;
        myCrewTotalPassCount = _myCrewRankingController.totalPassCount_Daily;
      } else if(widget.isWeekly == true) {
        crewDocs = _rankingTierModelController.rankingDocs_crew_integrated_weekly;
        crewRankingMap = _rankingTierModelController.crewRankingMap_integrated_weekly;
        myCrewTotalScore = _myCrewRankingController.totalScore_Weekly;
        myCrewTotalPassCount = _myCrewRankingController.totalPassCount_Weekly;
      }else {
        crewDocs = _rankingTierModelController.rankingDocs_crew_integrated;
        crewRankingMap = _rankingTierModelController.crewRankingMap_integrated;
        myCrewTotalScore = _myCrewRankingController.totalScore;
        myCrewTotalPassCount = _myCrewRankingController.totalPassCount;
      }
    }
    if (crewDocs!.isNotEmpty) {
      for (var crewLogo in crewLogoList) {
        if (crewLogo.crewColor == crewDocs![0]['crewColor']) {
          assetTop1 = crewLogo.crewLogoAsset;
          break;
        }
      }
    }

    if (crewDocs!.length > 1) {
      for (var crewLogo in crewLogoList) {
        if (crewLogo.crewColor == crewDocs![1]['crewColor']) {
          assetTop2 = crewLogo.crewLogoAsset;
          break;
        }
      }
    }

    if (crewDocs!.length > 2) {
      for (var crewLogo in crewLogoList) {
        if (crewLogo.crewColor == crewDocs![2]['crewColor']) {
          assetTop3 = crewLogo.crewLogoAsset;
          break;
        }
      }
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0)
                                  ?(widget.isKusbf == false)
                                  ? '${_userModelController.resortNickname} 상위 TOP 3 크루' :'KUSBF 상위 TOP 3 크루'
                                  : '통합 상위 TOP 3 크루',
                              style: TextStyle(
                                  color: Color(0xFF949494),
                                  fontSize: 12
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                if(crewDocs!.length > 0)
                                  GestureDetector(
                                    onTap: () async {
                                      CustomFullScreenDialog.showDialog();
                                      await _userModelController.getCurrentUser_crew(_userModelController.uid);
                                      await _liveCrewModelController.getCurrrentCrew(crewDocs![0]['crewID']);
                                      CustomFullScreenDialog.cancelDialog();
                                      Get.to(() =>
                                          CrewDetailPage_screen());
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(
                                            crewDocs![0]['crewColor']),
                                        borderRadius: BorderRadius
                                            .circular(8),
                                      ),
                                      height: 154,
                                      width: (_size.width - 48) / 3,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          (crewDocs![0]['profileImageUrl']
                                              .isNotEmpty)
                                              ? Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors
                                                      .black12,
                                                  spreadRadius: 0,
                                                  blurRadius: 8,
                                                  offset: Offset(0,
                                                      4), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            width: 58,
                                            height: 58,
                                            child: ExtendedImage.network(
                                              crewDocs![0]['profileImageUrl'],
                                              enableMemoryCache: true,
                                              shape: BoxShape
                                                  .rectangle,
                                              borderRadius: BorderRadius
                                                  .circular(7),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              loadStateChanged: (ExtendedImageState state) {
                                                switch (state.extendedImageLoadState) {
                                                  case LoadState.loading:
                                                    return SizedBox.shrink();
                                                  case LoadState.completed:
                                                    return state.completedWidget;
                                                  case LoadState.failed:
                                                    return ExtendedImage.network(
                                                      assetTop1,
                                                      shape: BoxShape.circle,
                                                      borderRadius: BorderRadius.circular(20),
                                                      width: 24,
                                                      height: 24,
                                                      fit: BoxFit.cover,
                                                    ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                  default:
                                                    return null;
                                                }
                                              },
                                            ),
                                          )
                                              : Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors
                                                      .black12,
                                                  spreadRadius: 0,
                                                  blurRadius: 8,
                                                  offset: Offset(0,
                                                      4), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: ExtendedImage.network(
                                              assetTop1,
                                              enableMemoryCache: true,
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(7),
                                              width: 58,
                                              height: 58,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(height: 14,),
                                          ExtendedImage.asset(
                                            'assets/imgs/icons/icon_crown_1.png',
                                            width: 28,
                                            height: 28,
                                            fit: BoxFit.cover,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text(
                                              crewDocs![0]['crewName'],
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 8),
                                if(crewDocs!.length > 1)
                                  GestureDetector(
                                    onTap: () async {
                                      CustomFullScreenDialog.showDialog();
                                      await _userModelController.getCurrentUser_crew(_userModelController.uid);
                                      await _liveCrewModelController.getCurrrentCrew(crewDocs![1]['crewID']);
                                      CustomFullScreenDialog.cancelDialog();
                                      Get.to(() => CrewDetailPage_screen());
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(
                                            crewDocs![1]['crewColor']),
                                        borderRadius: BorderRadius
                                            .circular(8),
                                      ),
                                      height: 154,
                                      width: (_size.width - 48) / 3,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          (crewDocs![1]['profileImageUrl']
                                              .isNotEmpty)
                                              ? Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors
                                                      .black12,
                                                  spreadRadius: 0,
                                                  blurRadius: 8,
                                                  offset: Offset(0,
                                                      4), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            width: 58,
                                            height: 58,
                                            child: ExtendedImage
                                                .network(
                                              crewDocs![1]['profileImageUrl'],
                                              enableMemoryCache: true,
                                              shape: BoxShape
                                                  .rectangle,
                                              borderRadius: BorderRadius
                                                  .circular(7),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              loadStateChanged: (ExtendedImageState state) {
                                                switch (state.extendedImageLoadState) {
                                                  case LoadState.loading:
                                                    return SizedBox.shrink();
                                                  case LoadState.completed:
                                                    return state.completedWidget;
                                                  case LoadState.failed:
                                                    return ExtendedImage.network(
                                                      assetTop2,
                                                      shape: BoxShape.circle,
                                                      borderRadius: BorderRadius.circular(20),
                                                      width: 24,
                                                      height: 24,
                                                      fit: BoxFit.cover,
                                                    ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                  default:
                                                    return null;
                                                }
                                              },
                                            ),
                                          )
                                              : Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors
                                                      .black12,
                                                  spreadRadius: 0,
                                                  blurRadius: 8,
                                                  offset: Offset(0,
                                                      4), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: ExtendedImage
                                                .network(
                                              assetTop2,
                                              enableMemoryCache: true,
                                              shape: BoxShape
                                                  .rectangle,
                                              borderRadius: BorderRadius
                                                  .circular(7),
                                              width: 58,
                                              height: 58,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(height: 14,),
                                          ExtendedImage.asset(
                                            'assets/imgs/icons/icon_crown_2.png',
                                            width: 28,
                                            height: 28,
                                            fit: BoxFit.cover,
                                          ),
                                          Padding(
                                            padding: EdgeInsets
                                                .symmetric(
                                                horizontal: 16),
                                            child: Text(
                                              crewDocs![1]['crewName'],
                                              style: TextStyle(
                                                color: Color(
                                                    0xFFFFFFFF),
                                                fontWeight: FontWeight
                                                    .bold,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 8),
                                if(crewDocs!.length > 2)
                                  GestureDetector(
                                    onTap: () async {
                                      CustomFullScreenDialog.showDialog();
                                      await _userModelController.getCurrentUser_crew(_userModelController.uid);
                                      await _liveCrewModelController.getCurrrentCrew(crewDocs![2]['crewID']);
                                      CustomFullScreenDialog.cancelDialog();
                                      Get.to(() => CrewDetailPage_screen());
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(
                                            crewDocs![2]['crewColor']),
                                        borderRadius: BorderRadius
                                            .circular(8),
                                      ),
                                      height: 154,
                                      width: (_size.width - 48) / 3,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          (crewDocs![2]['profileImageUrl']
                                              .isNotEmpty)
                                              ? Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors
                                                      .black12,
                                                  spreadRadius: 0,
                                                  blurRadius: 8,
                                                  offset: Offset(0,
                                                      4), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            width: 58,
                                            height: 58,
                                            child: ExtendedImage
                                                .network(
                                              crewDocs![2]['profileImageUrl'],
                                              enableMemoryCache: true,
                                              shape: BoxShape
                                                  .rectangle,
                                              borderRadius: BorderRadius
                                                  .circular(7),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              loadStateChanged: (ExtendedImageState state) {
                                                switch (state.extendedImageLoadState) {
                                                  case LoadState.loading:
                                                    return SizedBox.shrink();
                                                  case LoadState.completed:
                                                    return state.completedWidget;
                                                  case LoadState.failed:
                                                    return ExtendedImage.network(
                                                      assetTop3,
                                                      shape: BoxShape.circle,
                                                      borderRadius: BorderRadius.circular(20),
                                                      width: 24,
                                                      height: 24,
                                                      fit: BoxFit.cover,
                                                    ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                  default:
                                                    return null;
                                                }
                                              },
                                            ),
                                          )
                                              : Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors
                                                      .black12,
                                                  spreadRadius: 0,
                                                  blurRadius: 8,
                                                  offset: Offset(0,
                                                      4), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: ExtendedImage
                                                .network(
                                              assetTop3,
                                              enableMemoryCache: true,
                                              shape: BoxShape
                                                  .rectangle,
                                              borderRadius: BorderRadius
                                                  .circular(7),
                                              width: 58,
                                              height: 58,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(height: 14,),
                                          ExtendedImage.asset(
                                            'assets/imgs/icons/icon_crown_3.png',
                                            width: 28,
                                            height: 28,
                                            fit: BoxFit.cover,
                                          ),
                                          Padding(
                                            padding: EdgeInsets
                                                .symmetric(
                                                horizontal: 16),
                                            child: Text(
                                              crewDocs![2]['crewName'],
                                              style: TextStyle(
                                                color: Color(
                                                    0xFFFFFFFF),
                                                fontWeight: FontWeight
                                                    .bold,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 40,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if(widget.isKusbf == true)
                                  Text('KUSBF 크루 랭킹 TOP 20',
                                    style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                if(widget.isKusbf == false &&
                                    (_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0)
                                )
                                  Text('${_userModelController.resortNickname} 크루 랭킹 TOP 20',
                                    style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                if(widget.isKusbf == false &&
                                    (_userModelController.favoriteResort != 12 && _userModelController.favoriteResort != 2 && _userModelController.favoriteResort != 0)
                                )
                                  Text('통합 크루 랭킹 TOP 20',
                                    style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: () async{
                                    Get.to(() => RankingCrewAllScreen_test(
                                      isKusbf: widget.isKusbf,
                                      isDaily: widget.isDaily,
                                      isWeekly: widget.isWeekly,

                                    ));
                                  },
                                  child: Text('전체 보기',
                                    style: TextStyle(
                                        color: Color(0xFF949494),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            Container(
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: crewDocs!.length < 20
                                    ? crewDocs!.length
                                    : 20,
                                itemBuilder: (context, index) {
                                  for (var crewLogo in crewLogoList)
                                    if (crewDocs![index]['crewColor'] == crewLogo.crewColor)
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 12),
                                        child: InkWell(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () async {
                                            CustomFullScreenDialog.showDialog();
                                            await _userModelController.getCurrentUser_crew(_userModelController.uid);
                                            await _liveCrewModelController.getCurrrentCrew(crewDocs![index]['crewID']);
                                            CustomFullScreenDialog.cancelDialog();
                                            Get.to(() => CrewDetailPage_screen());
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                '${crewRankingMap!['${crewDocs![index]['crewID']}']}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Color(0xFF111111)
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Container(
                                                width: 46,
                                                height: 46,
                                                child:
                                                (crewDocs![index]['profileImageUrl']
                                                    .isNotEmpty)
                                                    ? Container(
                                                    width: 46,
                                                    height: 46,
                                                    decoration: BoxDecoration(
                                                        color: Color(0xFFDFECFF),
                                                        borderRadius: BorderRadius
                                                            .circular(8)
                                                    ),
                                                    child: ExtendedImage
                                                        .network(
                                                      crewDocs![index]['profileImageUrl'],
                                                      enableMemoryCache: true,
                                                      shape: BoxShape
                                                          .rectangle,
                                                      borderRadius: BorderRadius
                                                          .circular(6),
                                                      fit: BoxFit.cover,
                                                      loadStateChanged: (ExtendedImageState state) {
                                                        switch (state.extendedImageLoadState) {
                                                          case LoadState.loading:
                                                            return SizedBox.shrink();
                                                          case LoadState.completed:
                                                            return state.completedWidget;
                                                          case LoadState.failed:
                                                            return Container(
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      crewDocs![index]['crewColor']),
                                                                  borderRadius: BorderRadius
                                                                      .circular(8)
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .all(2.0),
                                                                child: ExtendedImage
                                                                    .network(
                                                                  crewLogo.crewLogoAsset,
                                                                  enableMemoryCache: true,
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                  borderRadius: BorderRadius
                                                                      .circular(6),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                          default:
                                                            return null;
                                                        }
                                                      },
                                                    ))
                                                    : Container(
                                                  width: 46,
                                                  height: 46,
                                                  decoration: BoxDecoration(
                                                      color: Color(
                                                          crewDocs![index]['crewColor']),
                                                      borderRadius: BorderRadius
                                                          .circular(8)
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .all(2.0),
                                                    child: ExtendedImage
                                                        .network(
                                                      crewLogo.crewLogoAsset,
                                                      enableMemoryCache: true,
                                                      shape: BoxShape
                                                          .rectangle,
                                                      borderRadius: BorderRadius
                                                          .circular(6),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Padding(
                                                  padding: const EdgeInsets
                                                      .only(bottom: 3),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            crewDocs![index]['crewName'],
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(0xFF111111),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 4,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(4),
                                                                border: Border.all(
                                                                    color: Color(0xFFDEDEDE)
                                                                )
                                                            ),
                                                            child: Text(
                                                              crewDocs![index]['baseResortNickName'],
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 9,
                                                                  color: Color(0xFF949494)
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 4),
                                                          if (crewDocs![index]['description'].isNotEmpty)
                                                            SizedBox(
                                                              width: _size.width-220,
                                                              child: Text(
                                                                crewDocs![index]['description'],
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Color(0xFF949494)
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                              ),
                                              Expanded(child: SizedBox()),

                                              Text(
                                                (_userModelController.favoriteResort == 12
                                                    || _userModelController.favoriteResort == 2
                                                    || _userModelController.favoriteResort == 0)
                                                    ? widget.isWeekly == true
                                                    ?'${crewDocs![index]['totalScoreWeekly'].toString()}점'
                                                    :'${crewDocs![index]['totalScore'].toString()}점'
                                                    : widget.isWeekly == true
                                                    ?'${crewDocs![index]['totalPassCountWeekly'].toString()}회'
                                                    :'${crewDocs![index]['totalPassCount'].toString()}회',
                                                style: TextStyle(
                                                  color: Color(0xFF111111),
                                                  fontWeight: FontWeight
                                                      .normal,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                },
                              ),
                            ),
                            (_userModelController.liveCrew == "")
                                ? SizedBox(height: 20)
                                : SizedBox(height: 90)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if(_userModelController.favoriteResort == _liveCrewModelController.baseResort)
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('liveCrew')
                      .where('crewID', isEqualTo: _userModelController.liveCrew)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<
                      QuerySnapshot> snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return SizedBox.shrink();
                    }
                    else if (snapshot.data!.docs.isNotEmpty && _userModelController.favoriteResort ==snapshot.data!.docs[0]['baseResort'] ) {
                      final myCrewDocs = snapshot.data!.docs;
                      for (var crewLogo in crewLogoList)
                        if (myCrewDocs[0]['crewColor'] == crewLogo.crewColor)
                          return GestureDetector(
                            onTap: ()async{
                              CustomFullScreenDialog.showDialog();
                              await _userModelController.getCurrentUser_crew(_userModelController.uid);
                              await _liveCrewModelController.getCurrrentCrew(myCrewDocs[0]['crewID']);
                              CustomFullScreenDialog.cancelDialog();
                              Get.to(() => CrewDetailPage_screen());
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    spreadRadius: 0,
                                    blurRadius: 6,
                                    offset: Offset(
                                        0, 0), // changes position of shadow
                                  ),
                                ],
                                color: Color(myCrewDocs[0]['crewColor']),
                              ),
                              height: 80,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child:
                                (crewRankingMap?['${_userModelController.liveCrew}'] != null )
                                    ? Obx(() => Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${crewRankingMap!['${_userModelController.liveCrew}']}',
                                      style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    (myCrewDocs[0]['profileImageUrl']
                                        .isNotEmpty)
                                        ? Container(
                                        width: 48,
                                        height: 48,
                                        // decoration: BoxDecoration(
                                        //     color: Color(
                                        //         myCrewDocs[0]['crewColor']),
                                        //     borderRadius: BorderRadius
                                        //         .circular(8)
                                        // ),
                                        child: ExtendedImage.network(
                                          myCrewDocs[0]['profileImageUrl'],
                                          enableMemoryCache: true,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius
                                              .circular(6),
                                          fit: BoxFit.cover,
                                          loadStateChanged: (ExtendedImageState state) {
                                            switch (state.extendedImageLoadState) {
                                              case LoadState.loading:
                                                return SizedBox.shrink();
                                              case LoadState.completed:
                                                return state.completedWidget;
                                              case LoadState.failed:
                                                return ExtendedImage.asset(
                                                  crewLogo.crewLogoAsset,
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius
                                                      .circular(6),
                                                  fit: BoxFit.cover,
                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                              default:
                                                return null;
                                            }
                                          },
                                        ))
                                        : Container(
                                      width: 48,
                                      height: 48,
                                      // decoration: BoxDecoration(
                                      //     color: Color(
                                      //         myCrewDocs[0]['crewColor']),
                                      //     borderRadius: BorderRadius
                                      //         .circular(8)
                                      // ),
                                      child: ExtendedImage.network(
                                        crewLogo.crewLogoAsset,
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius
                                            .circular(6),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 3),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            '${myCrewDocs[0]['crewName']}',
                                            style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 2,),
                                          if (myCrewDocs[0]['description'].isNotEmpty)
                                            SizedBox(
                                              width: 200,
                                              child: Text(
                                                '${myCrewDocs[0]['description']}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFFFFFFFF),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Expanded(child: SizedBox()),
                                    Text(
                                      (_userModelController.favoriteResort == 12
                                          || _userModelController.favoriteResort == 2
                                          || _userModelController.favoriteResort == 0)
                                          ? '${myCrewTotalScore}점'
                                          : '${myCrewTotalPassCount}회',
                                      style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ))
                                    : Row(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '',
                                      style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    (myCrewDocs[0]['profileImageUrl']
                                        .isNotEmpty)
                                        ? Container(
                                        width: 48,
                                        height: 48,
                                        // decoration: BoxDecoration(
                                        //     color: Color(
                                        //         myCrewDocs[0]['crewColor']),
                                        //     borderRadius: BorderRadius
                                        //         .circular(8)
                                        // ),
                                        child: ExtendedImage.network(
                                          myCrewDocs[0]['profileImageUrl'],
                                          enableMemoryCache: true,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius
                                              .circular(6),
                                          fit: BoxFit.cover,
                                          loadStateChanged: (ExtendedImageState state) {
                                            switch (state.extendedImageLoadState) {
                                              case LoadState.loading:
                                                return SizedBox.shrink();
                                              case LoadState.completed:
                                                return state.completedWidget;
                                              case LoadState.failed:
                                                return ExtendedImage.asset(
                                                  crewLogo.crewLogoAsset,
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius
                                                      .circular(6),
                                                  fit: BoxFit.cover,
                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                              default:
                                                return null;
                                            }
                                          },
                                        ))
                                        : Container(
                                      width: 48,
                                      height: 48,
                                      // decoration: BoxDecoration(
                                      //     color: Color(
                                      //         myCrewDocs[0]['crewColor']),
                                      //     borderRadius: BorderRadius
                                      //         .circular(8)
                                      // ),
                                      child: ExtendedImage.network(
                                        crewLogo.crewLogoAsset,
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius
                                            .circular(6),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 3),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            '${myCrewDocs[0]['crewName']}',
                                            style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 2,),
                                          if (myCrewDocs[0]['description'].isNotEmpty)
                                            SizedBox(
                                              width: _size.width - 200,
                                              child: Text(
                                                '${myCrewDocs[0]['description']}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFFFFFFFF),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Expanded(child: SizedBox()),
                                    Text(
                                      (_userModelController.favoriteResort == 12
                                          || _userModelController.favoriteResort == 2
                                          || _userModelController.favoriteResort == 0)
                                          ? '${myCrewTotalScore}점'
                                          : '${myCrewTotalPassCount}회',
                                      style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                    }
                    else if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(),);
                    }
                    else if (snapshot.hasError) {
                      return SizedBox.shrink();
                    }
                    return Center();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}