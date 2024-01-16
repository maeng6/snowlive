import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import '../../../controller/vm_allCrewDocsController.dart';
import '../../../controller/vm_allUserDocsController.dart';
import '../../../controller/vm_rankingTierModelController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../model/m_rankingTierModel.dart';
import '../../more/friend/v_friendDetailPage.dart';

class RankingIndiAllScreen_test extends StatefulWidget {

  RankingIndiAllScreen_test({Key? key, required this.isKusbf,required this.isDaily,
    required this.isWeekly}) : super(key: key);

  bool isKusbf = false;
  bool isDaily = false;
  bool isWeekly = false;

  @override
  State<RankingIndiAllScreen_test> createState() => _RankingIndiAllScreen_testState();
}

class _RankingIndiAllScreen_testState extends State<RankingIndiAllScreen_test> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  AllCrewDocsController _allCrewDocsController = Get.find<AllCrewDocsController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  //TODO: Dependency Injection**************************************************


  Map<String, GlobalKey> itemKeys = {};

  GlobalKey myItemKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // GlobalKey for my item (logged-in user)
    myItemKey = GlobalKey();

    _allCrewDocsController.startListening().then((result){
      setState(() {});
    });

  }

  @override
  void dispose() {
    _allCrewDocsController.stopListening();
    super.dispose();
  }

  Map? userRankingMap;
  Map? userRankingMap_all;
  List? documents;
  List? documents_all;
  dynamic myRanking;


  void _scrollToMyRanking() {
    if(_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0) {
      if(widget.isDaily == true){
        myRanking = _rankingTierModelController.userRankingMap_daily![_userModelController.uid];
      } else if(widget.isWeekly == true){
        myRanking = _rankingTierModelController.userRankingMap_weekly![_userModelController.uid];
      } else {
        myRanking = _rankingTierModelController.userRankingMap![_userModelController.uid];
      }
    }else {
      if(widget.isDaily == true){
        myRanking = _rankingTierModelController.userRankingMap_integrated_daily![_userModelController.uid];
      } else  if(widget.isWeekly == true){
        myRanking = _rankingTierModelController.userRankingMap_integrated_weekly![_userModelController.uid];
      } else{
      myRanking = _rankingTierModelController.userRankingMap_integrated![_userModelController.uid];

      }
    }

    if (myRanking != null) {
      Scrollable.ensureVisible(myItemKey.currentContext!,
          duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
      print('My user ID: ${_userModelController.uid}'); // 현재 로그인된 사용자 ID 출력
      print('My ranking: $myRanking');
    }
  }

  Future<void> _refreshData() async {
    if(_userModelController.favoriteResort == 12
        ||_userModelController.favoriteResort == 2
        ||_userModelController.favoriteResort == 0) {

      if(widget.isDaily == true){
        await _rankingTierModelController.getRankingDocsDaily(baseResort: _userModelController.favoriteResort);
      }
      else if(widget.isWeekly == true){
        await _rankingTierModelController.getRankingDocsWeekly(baseResort: _userModelController.favoriteResort);
      }
      else{
        await _rankingTierModelController.getRankingDocs(baseResort: _userModelController.favoriteResort);
      }
    }else{

      if(widget.isDaily == true){
        await _rankingTierModelController.getRankingDocs_integrated_Daily();
      }
      else if(widget.isWeekly == true){
        await _rankingTierModelController.getRankingDocs_integrated_Weekly();
      }
      else{
        await _rankingTierModelController.getRankingDocs_integrated();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    if(_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0) {
      if(widget.isDaily == true){
        documents = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_kusbf_daily
            : _rankingTierModelController.rankingDocs_daily;
        documents_all = _rankingTierModelController.rankingDocs_daily;

        userRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.userRankingMap_kusbf_daily
            : _rankingTierModelController.userRankingMap_daily;
        userRankingMap_all = _rankingTierModelController.userRankingMap_daily;
      } else if(widget.isWeekly == true){
        documents = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_kusbf_weekly
            : _rankingTierModelController.rankingDocs_weekly;
        documents_all = _rankingTierModelController.rankingDocs_weekly;

        userRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.userRankingMap_kusbf_weekly
            : _rankingTierModelController.userRankingMap_weekly;
        userRankingMap_all = _rankingTierModelController.userRankingMap_weekly;
      } else {
        documents = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_kusbf
            : _rankingTierModelController.rankingDocs;
        documents_all = _rankingTierModelController.rankingDocs;

        userRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.userRankingMap_kusbf
            : _rankingTierModelController.userRankingMap;
        userRankingMap_all = _rankingTierModelController.userRankingMap;
      }

    }else {
      if(widget.isDaily == true){
        documents =  _rankingTierModelController.rankingDocs_integrated_daily;
        documents_all = _rankingTierModelController.rankingDocs_integrated_daily;
        userRankingMap = _rankingTierModelController.userRankingMap_integrated_daily;
        userRankingMap_all = _rankingTierModelController.userRankingMap_integrated_daily;
      } else if(widget.isWeekly == true){
        documents =  _rankingTierModelController.rankingDocs_integrated_weekly;
        documents_all = _rankingTierModelController.rankingDocs_integrated_weekly;
        userRankingMap = _rankingTierModelController.userRankingMap_integrated_weekly;
        userRankingMap_all = _rankingTierModelController.userRankingMap_integrated_weekly;
      } else{
        documents =  _rankingTierModelController.rankingDocs_integrated;
        documents_all = _rankingTierModelController.rankingDocs_integrated;
        userRankingMap = _rankingTierModelController.userRankingMap_integrated;
        userRankingMap_all = _rankingTierModelController.userRankingMap_integrated;
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
          //         'My 랭킹',
          //         style: TextStyle(
          //             fontSize: 15,
          //             fontWeight: FontWeight.bold,
          //             color: Color(0xFF3D83ED)),
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
              fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: ListView.builder(
            itemCount: documents!.length,
            itemBuilder: (context, index) {
              final document = documents![index];
              final itemKey = document['uid'] == _userModelController.uid
                  ? myItemKey
                  : GlobalKey();

              final userDoc = _allUserDocsController.allUserDocs;
              final Map<String, dynamic> userData = userDoc.isNotEmpty
                  ? userDoc.firstWhere(
                    (doc) => doc['uid'] == document['uid'],
                orElse: () => <String, dynamic>{}, // 빈 맵을 반환
              )
                  : <String, dynamic>{};

              String? crewName = _allCrewDocsController.findCrewName(
                  userData['liveCrew'], _allCrewDocsController.allCrewDocs);

              return Padding(
                key: itemKey, // Apply the key here
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: (){
                    Get.to(() =>
                        FriendDetailPage(uid: userData['uid'],
                          favoriteResort: userData['favoriteResort'],));
                  },
                  child: Row(
                    children: [
                      Text(
                        '${userRankingMap!['${userData['uid']}']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF111111)),
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color: Color(0xFFDFECFF),
                            borderRadius: BorderRadius
                                .circular(50)
                        ),
                        child: userData['profileImageUrl'].isNotEmpty
                            ? ExtendedImage.network(
                          userData['profileImageUrl'],
                          enableMemoryCache: false,
                          cacheHeight: 100,
                          shape: BoxShape.circle,
                          borderRadius: BorderRadius.circular(8),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          loadStateChanged: (
                              ExtendedImageState state) {
                            switch (state.extendedImageLoadState) {
                              case LoadState.loading:
                                return SizedBox.shrink();
                              case LoadState.completed:
                                return state.completedWidget;
                              case LoadState.failed:
                                return ExtendedImage.network(
                                  '${profileImgUrlList[0].default_round}',
                                  shape: BoxShape.circle,
                                  borderRadius: BorderRadius.circular(
                                      8),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
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
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Container(
                          width: _size.width - 227,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    userData['displayName'],
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF111111)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  (document['resortNickname'] != null && document['resortNickname'] != '')
                                      ? Row(
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
                                          document['resortNickname'] ?? '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 9,
                                              color: Color(0xFF949494)
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                    ],
                                  )
                                      : Container(),
                                  if(userData['liveCrew'].isNotEmpty)
                                    Text(crewName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF949494)
                                      ),),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      Row(
                        children: [
                          Text(
                            (_userModelController.favoriteResort == 12
                                || _userModelController.favoriteResort == 2
                                || _userModelController.favoriteResort == 0)
                                ? widget.isWeekly == true ? '${document['totalScoreWeekly']}점' :'${document['totalScore']}점'
                                : widget.isWeekly == true ? '${document['totalPassCountWeekly']}회': '${document['totalPassCount']}회',
                            style: TextStyle(
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(6, 2),
                            child: ExtendedImage.network(
                              (_userModelController.favoriteResort == 12
                                  || _userModelController.favoriteResort == 2
                                  || _userModelController.favoriteResort == 0)
                                  ?
                              _rankingTierModelController.getBadgeAsset(
                                  percent: userRankingMap_all!['${userData['uid']}']/(documents_all!.length),
                                  totalScore: document['totalScore'],
                                  rankingTierList: rankingTierList
                              )
                                  :  _rankingTierModelController.getBadgeAsset_integrated(
                                  percent: userRankingMap_all!['${userData['uid']}']/(documents_all!.length),
                                  totalPassCount: document['totalPassCount'],
                                  rankingTierList: rankingTierList
                              ),
                              enableMemoryCache: true,
                              cacheWidth: 40,
                              fit: BoxFit.cover,
                              width: 36,
                            ),
                          ),
                        ],
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
