import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import '../../../controller/vm_liveMapController.dart';
import '../../../controller/vm_rankingTierModelController.dart';
import '../../../model/m_crewLogoModel.dart';
import '../../../widget/w_fullScreenDialog.dart';
import '../../LiveCrew/v_crewDetailPage_screen.dart';

class RankingCrewAllScreen_test extends StatefulWidget {
  RankingCrewAllScreen_test({Key? key, required this.isKusbf, required this.isDaily,
    required this.isWeekly,}) : super(key: key);

  bool isKusbf = false;
  bool isDaily = false;
  bool isWeekly = false;

  @override
  State<RankingCrewAllScreen_test> createState() => _RankingCrewAllScreen_testState();
}

class _RankingCrewAllScreen_testState extends State<RankingCrewAllScreen_test> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController =
  Get.find<LiveCrewModelController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  //TODO: Dependency Injection**************************************************

  var assetBases;

  ScrollController _scrollController = ScrollController();

  Map<String, GlobalKey> itemKeys = {};

  GlobalKey myItemKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // GlobalKey for my item (logged-in user)
    myItemKey = GlobalKey();
  }

  int? myCrewRank;
  Map? crewRankingMap;
  List? crewDocs;
  dynamic myRanking;

  void _scrollToMyRanking() {
    if(_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0) {

      if(widget.isDaily == true){
        myRanking = _rankingTierModelController.crewRankingMap_daily![_userModelController.liveCrew];
      } else if(widget.isWeekly == true){
        myRanking = _rankingTierModelController.crewRankingMap_weekly![_userModelController.liveCrew];
      } else{
      myRanking = _rankingTierModelController.crewRankingMap![_userModelController.liveCrew];
      }
    }else {
      if(widget.isDaily == true){
        myRanking = _rankingTierModelController.crewRankingMap_integrated_daily![_userModelController.liveCrew];
      } else if(widget.isWeekly == true){
      myRanking = _rankingTierModelController.crewRankingMap_integrated_weekly![_userModelController.liveCrew];
    } else {
        myRanking = _rankingTierModelController.crewRankingMap_integrated![_userModelController.liveCrew];
      }
      }

    if (myRanking != null) {
      Scrollable.ensureVisible(
        myItemKey.currentContext!,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
      print('My user ID: ${_userModelController.liveCrew}'); // 현재 로그인된 사용자 ID 출력
      print('My ranking: $myRanking');
    }
  }

  Future<void> _refreshData() async {
    if(_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0) {

      if(widget.isDaily == true){
        await _rankingTierModelController.getRankingDocs_crew_Daily(baseResort: _userModelController.favoriteResort);
      }
      else if(widget.isWeekly == true){
        await _rankingTierModelController.getRankingDocs_crew_Weekly(baseResort: _userModelController.favoriteResort);
      }else{
        await _rankingTierModelController.getRankingDocs_crew(baseResort: _userModelController.favoriteResort);
      }
    }else {

      if(widget.isDaily == true){
        await _rankingTierModelController.getRankingDocs_crew_integrated_Daily();
      }
      else if(widget.isWeekly == true){
        await _rankingTierModelController.getRankingDocs_crew_integrated_Weekly();
      }
      else{
        await _rankingTierModelController.getRankingDocs_crew_integrated();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    if(_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0) {
      if(widget.isDaily == true) {
        crewDocs = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_crew_kusbf_daily
            : _rankingTierModelController.rankingDocs_crew_daily;
        crewRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.crewRankingMap_kusbf_daily
            : _rankingTierModelController.crewRankingMap_daily;
      } else if(widget.isWeekly == true) {
        crewDocs = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_crew_kusbf_weekly
            : _rankingTierModelController.rankingDocs_crew_weekly;
        crewRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.crewRankingMap_kusbf_weekly
            : _rankingTierModelController.crewRankingMap_weekly;
      } else {
        crewDocs = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_crew_kusbf
            : _rankingTierModelController.rankingDocs_crew;
        crewRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.crewRankingMap_kusbf
            : _rankingTierModelController.crewRankingMap;
      }
    } else{
      if(widget.isDaily == true) {
        crewDocs = _rankingTierModelController.rankingDocs_crew_integrated_daily;
        crewRankingMap = _rankingTierModelController.crewRankingMap_integrated_daily;
      } else if(widget.isWeekly == true) {
        crewDocs = _rankingTierModelController.rankingDocs_crew_integrated_weekly;
        crewRankingMap = _rankingTierModelController.crewRankingMap_integrated_weekly;
      }else {
        crewDocs = _rankingTierModelController.rankingDocs_crew_integrated;
        crewRankingMap = _rankingTierModelController.crewRankingMap_integrated;
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[
          // GestureDetector(
          //   onTap: _scrollToMyRanking,
          //   child: Center(
          //     child: Padding(
          //       padding: const EdgeInsets.only(right: 16),
          //       child: Text(
          //         'My 크루',
          //         style: TextStyle(
          //           fontSize: 15,
          //           fontWeight: FontWeight.bold,
          //           color: Color(0xFF3D83ED),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          '전체 랭킹',
          style: TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: crewDocs!.length,
            itemBuilder: (context, index) {
              final document = crewDocs![index];
              final itemKey = document['crewID'] == _userModelController.liveCrew
                  ? myItemKey
                  : GlobalKey();

              String assetBases = '';
              for (var crewLogo in crewLogoList) {
                if (crewLogo.crewColor == document['crewColor']) {
                  assetBases = crewLogo.crewLogoAsset;
                  break;
                }
              }

              return Padding(
                key: itemKey,
                padding: const EdgeInsets.only(top: 6, bottom: 10),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: ()async{
                    CustomFullScreenDialog.showDialog();
                    await _userModelController.getCurrentUser_crew(_userModelController.uid);
                    await _liveCrewModelController.getCurrrentCrew(document['crewID']);
                    CustomFullScreenDialog.cancelDialog();
                    Get.to(() => CrewDetailPage_screen());
                  },
                  child: Row(
                    children: [
                      Text(
                        '${crewRankingMap!['${document['crewID']}']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF111111)),
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            color: Color(0xFFDFECFF),
                            borderRadius: BorderRadius
                                .circular(8)
                        ),
                        child: (document['profileImageUrl'].isNotEmpty)
                            ? Container(
                          width: 46,
                          height: 46,
                          child: ExtendedImage.network(
                            document['profileImageUrl'],
                            enableMemoryCache: true,
                            cacheHeight: 200,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(6),
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
                                      color: Color(document['crewColor']),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ExtendedImage.network(
                                        assetBases,
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(6),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                default:
                                  return null;
                              }
                            },
                          ),
                        )
                            : Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Color(document['crewColor']),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ExtendedImage.network(
                              assetBases,
                              enableMemoryCache: true,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(6),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  document['crewName'],
                                  style: TextStyle(
                                      fontSize: 15, color: Color(0xFF111111)),
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
                                    document['baseResortNickName'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                        color: Color(0xFF949494)
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4),
                                if (document['description'].isNotEmpty)
                                  SizedBox(
                                    width: _size.width-220,
                                    child: Text(
                                      document['description'],
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
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      Text(
                        (_userModelController.favoriteResort == 12
                            || _userModelController.favoriteResort == 2
                            || _userModelController.favoriteResort == 0)
                            ? widget.isWeekly == true ?'${document['totalScoreWeekly']}점' :'${document['totalScore']}점'
                            : widget.isWeekly == true ?'${document['totalPassCountWeekly']}회':'${document['totalPassCount']}회',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.normal,
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
      ),
    );
  }
}