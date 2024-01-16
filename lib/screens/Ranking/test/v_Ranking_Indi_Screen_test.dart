import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/screens/Ranking/test/v_Ranking_indi_All_Screen_test.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import '../../../controller/vm_allCrewDocsController.dart';
import '../../../controller/vm_allUserDocsController.dart';
import '../../../controller/vm_myRankingController.dart';
import '../../../controller/vm_rankingTierModelController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../model/m_rankingTierModel.dart';
import '../../more/friend/v_friendDetailPage.dart';

class RankingIndiScreen_test extends StatefulWidget {
  RankingIndiScreen_test({Key? key,
    required this.isKusbf,
    required this.isDaily,
    required this.isWeekly,}) : super(key: key);

  bool isKusbf = false;
  bool isDaily = false;
  bool isWeekly = false;


  @override
  State<RankingIndiScreen_test> createState() => _RankingIndiScreen_testState();
}

class _RankingIndiScreen_testState extends State<RankingIndiScreen_test> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  MyRankingController _myRankingController = Get.find<MyRankingController>();
  AllCrewDocsController _allCrewDocsController = Get.find<AllCrewDocsController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  //TODO: Dependency Injection**************************************************

  Map? userRankingMap;
  Map? userRankingMap_all;
  List? documents;
  List? documents_all;
  int? myTotalScore;
  int? myTotalPassCount;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _allCrewDocsController.startListening().then((result){
      setState(() {});
    });

  }

  @override
  void dispose() {
    _allCrewDocsController.stopListening();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if(_userModelController.favoriteResort == 12
        ||_userModelController.favoriteResort == 2
        ||_userModelController.favoriteResort == 0) {

      if(widget.isDaily == true){
        await _rankingTierModelController.getRankingDocsDaily(baseResort: _userModelController.favoriteResort);
        await _myRankingController.getMyRankingDataDaily(_userModelController.uid);
      }
      else if(widget.isWeekly == true){
        await _rankingTierModelController.getRankingDocsWeekly(baseResort: _userModelController.favoriteResort);
        await _myRankingController.getMyRankingDataWeekly(_userModelController.uid);
      }
      else{
        await _rankingTierModelController.getRankingDocs(baseResort: _userModelController.favoriteResort);
        await _myRankingController.getMyRankingData(_userModelController.uid);
      }
    }else{

      if(widget.isDaily == true){
        await _rankingTierModelController.getRankingDocs_integrated_Daily();
        await _myRankingController.getMyRankingDataDaily(_userModelController.uid);
      }
      else if(widget.isWeekly == true){
        await _rankingTierModelController.getRankingDocs_integrated_Weekly();
        await _myRankingController.getMyRankingDataWeekly(_userModelController.uid);
      }
      else{
        await _rankingTierModelController.getRankingDocs_integrated();
        await _myRankingController.getMyRankingData(_userModelController.uid);
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
        myTotalScore = _myRankingController.totalScore_Daily;
        myTotalPassCount = _myRankingController.totalPassCount_Daily;
      } else if(widget.isWeekly == true){
        documents = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_kusbf_weekly
            : _rankingTierModelController.rankingDocs_weekly;
        documents_all = _rankingTierModelController.rankingDocs_weekly;

        userRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.userRankingMap_kusbf_weekly
            : _rankingTierModelController.userRankingMap_weekly;
        userRankingMap_all = _rankingTierModelController.userRankingMap_weekly;
        myTotalScore = _myRankingController.totalScore_Weekly;
        myTotalPassCount = _myRankingController.totalPassCount_Weekly;
      } else {
        documents = widget.isKusbf == true
            ? _rankingTierModelController.rankingDocs_kusbf
            : _rankingTierModelController.rankingDocs;
        documents_all = _rankingTierModelController.rankingDocs;

        userRankingMap = widget.isKusbf == true
            ? _rankingTierModelController.userRankingMap_kusbf
            : _rankingTierModelController.userRankingMap;
        userRankingMap_all = _rankingTierModelController.userRankingMap;
        myTotalScore = _myRankingController.totalScore;
        myTotalPassCount = _myRankingController.totalPassCount;
      }

    }else {
      if(widget.isDaily == true){
        documents =  _rankingTierModelController.rankingDocs_integrated_daily;
        documents_all = _rankingTierModelController.rankingDocs_integrated_daily;
        userRankingMap = _rankingTierModelController.userRankingMap_integrated_daily;
        userRankingMap_all = _rankingTierModelController.userRankingMap_integrated_daily;
        myTotalScore = _myRankingController.totalScore_Daily;
        myTotalPassCount = _myRankingController.totalPassCount_Daily;
      } else if(widget.isWeekly == true){
        documents =  _rankingTierModelController.rankingDocs_integrated_weekly;
        documents_all = _rankingTierModelController.rankingDocs_integrated_weekly;
        userRankingMap = _rankingTierModelController.userRankingMap_integrated_weekly;
        userRankingMap_all = _rankingTierModelController.userRankingMap_integrated_weekly;
        myTotalScore = _myRankingController.totalScore_Weekly;
        myTotalPassCount = _myRankingController.totalPassCount_Weekly;
      } else{
        documents =  _rankingTierModelController.rankingDocs_integrated;
        documents_all = _rankingTierModelController.rankingDocs_integrated;
        userRankingMap = _rankingTierModelController.userRankingMap_integrated;
        userRankingMap_all = _rankingTierModelController.userRankingMap_integrated;
        myTotalScore = _myRankingController.totalScore;
        myTotalPassCount = _myRankingController.totalPassCount;
      }
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            (documents!.isNotEmpty)
            ? RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              (_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0)
                                  ?(widget.isKusbf == false)
                                  ? '${_userModelController.resortNickname} 상위 TOP 3 유저' :'KUSBF 상위 TOP 3 유저'
                                  : '통합 상위 TOP 3 유저',
                              style: TextStyle(
                                  color: Color(0xFF949494),
                                  fontSize: 12
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                if(documents!.length > 0)
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('user')
                                        .where('uid', isEqualTo: documents![0]['uid'])
                                        .snapshots(),
                                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                      if (!snapshot.hasData || snapshot.data == null) {
                                        return  Container(
                                          height: 154,
                                          width: (_size.width - 40) / 3,
                                        );
                                      }
                                      else if (snapshot.data!.docs.isNotEmpty) {
                                        final userDoc = snapshot.data!.docs;
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                Get.to(() => FriendDetailPage(uid: userDoc[0]['uid'], favoriteResort: userDoc[0]['favoriteResort'],));
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFDBE9FF),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                height: 154,
                                                width: (_size.width - 48) / 3,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                        ? Container(
                                                      width: 58,
                                                      height: 58,
                                                      child: ExtendedImage.network(
                                                        userDoc[0]['profileImageUrl'],
                                                        enableMemoryCache: true,
                                                        shape: BoxShape.circle,
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
                                                                '${profileImgUrlList[0].default_round}',
                                                                enableMemoryCache: true,
                                                                shape: BoxShape.circle,
                                                                width: 58,
                                                                height: 58,
                                                                fit: BoxFit.cover,
                                                              ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                            default:
                                                              return null;
                                                          }
                                                        },
                                                      ),
                                                    )
                                                        : ExtendedImage.network(
                                                      '${profileImgUrlList[0].default_round}',
                                                      enableMemoryCache: true,
                                                      shape: BoxShape.circle,
                                                      width: 58,
                                                      height: 58,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    SizedBox(height: 6,),
                                                    ExtendedImage.asset(
                                                      'assets/imgs/icons/icon_crown_1.png',
                                                      width: 28,
                                                      height: 28,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            userDoc[0]['displayName'],
                                                            style: TextStyle(
                                                              color: Color(0xFF111111),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          SizedBox(height: 2),
                                                          Text(
                                                            documents![0]['resortNickname'] ?? '',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(0xFF666666)
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if(widget.isWeekly == true && _userModelController.displayName == 'SNOWLIVE')
                                            GestureDetector(
                                              onTap:(){
                                                _rankingTierModelController.updateWeeklyRankingTop(
                                                    userDoc[0]['uid'],
                                                    userDoc[0]['displayName'],
                                                    userDoc[0]['profileImageUrl'],
                                                    documents![0]['resortNickname'],
                                                    documents![0]['favoriteResort'],
                                                    documents![0]['totalScoreWeekly'],
                                                    documents![0]['totalPassCountWeekly'],
                                                    1
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: Text('서버 등록',
                                                  style: TextStyle(
                                                      color: Color(0xFF949494),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      else if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Container(
                                          height: 154,
                                          width: (_size.width - 48) / 3,
                                        );
                                      } else {
                                        return Container(
                                          height: 154,
                                          width: (_size.width - 48) / 3,
                                        );
                                      }
                                    },
                                  ),
                                SizedBox(width: 8,),
                                if(documents!.length > 1)
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('user')
                                        .where('uid', isEqualTo: documents![1]['uid'])
                                        .snapshots(),
                                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                      if (!snapshot.hasData || snapshot.data == null) {
                                        return Center();
                                      } else if (snapshot.data!.docs.isNotEmpty) {
                                        final userDoc = snapshot.data!.docs;
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                Get.to(() => FriendDetailPage(uid: userDoc[0]['uid'], favoriteResort: userDoc[0]['favoriteResort'],));
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFDBE9FF),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                height: 154,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                        ? Container(
                                                      width: 58,
                                                      height: 58,
                                                      child: ExtendedImage.network(
                                                        userDoc[0]['profileImageUrl'],
                                                        enableMemoryCache: true,
                                                        shape: BoxShape.circle,
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
                                                                '${profileImgUrlList[0].default_round}',
                                                                enableMemoryCache: true,
                                                                shape: BoxShape.circle,
                                                                width: 58,
                                                                height: 58,
                                                                fit: BoxFit.cover,
                                                              ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                            default:
                                                              return null;
                                                          }
                                                        },
                                                      ),
                                                    )
                                                        : ExtendedImage.network(
                                                      '${profileImgUrlList[0].default_round}',
                                                      enableMemoryCache: true,
                                                      shape: BoxShape.circle,
                                                      width: 58,
                                                      height: 58,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    SizedBox(height: 6),
                                                    ExtendedImage.asset(
                                                      'assets/imgs/icons/icon_crown_2.png',
                                                      width: 28,
                                                      height: 28,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            userDoc[0]['displayName'],
                                                            style: TextStyle(
                                                              color: Color(0xFF111111),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          SizedBox(height: 2),
                                                          Text(
                                                            documents![1]['resortNickname'] ?? '',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(0xFF666666)
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                width: (_size.width - 48) / 3,
                                              ),
                                            ),
                                            if(widget.isWeekly == true && _userModelController.displayName == 'SNOWLIVE')
                                              GestureDetector(
                                                onTap:(){
                                                  _rankingTierModelController.updateWeeklyRankingTop(
                                                      userDoc[0]['uid'],
                                                      userDoc[0]['displayName'],
                                                      userDoc[0]['profileImageUrl'],
                                                      documents![1]['resortNickname'],
                                                      documents![1]['favoriteResort'],
                                                      documents![1]['totalScoreWeekly'],
                                                      documents![1]['totalPassCountWeekly'],
                                                      2
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Text('서버 등록',
                                                    style: TextStyle(
                                                        color: Color(0xFF949494),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Container(
                                          height: 154,
                                          width: (_size.width - 48) / 3,
                                        );
                                      } else {
                                        return Container(
                                          height: 154,
                                          width: (_size.width - 48) / 3,
                                        );
                                      }
                                    },
                                  ),
                                SizedBox(width: 8,),
                                if(documents!.length > 2)
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('user')
                                        .where('uid', isEqualTo: documents![2]['uid'])
                                        .snapshots(),
                                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                      if (!snapshot.hasData || snapshot.data == null) {
                                        return Center();
                                      } else if (snapshot.data!.docs.isNotEmpty) {
                                        final userDoc = snapshot.data!.docs;
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                Get.to(() => FriendDetailPage(uid: userDoc[0]['uid'], favoriteResort: userDoc[0]['favoriteResort'],));
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFDBE9FF),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                height: 154,
                                                width: (_size.width - 48) / 3,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    (userDoc[0]['profileImageUrl'].isNotEmpty)
                                                        ? Container(
                                                      width: 58,
                                                      height: 58,
                                                      child: ExtendedImage.network(
                                                        userDoc[0]['profileImageUrl'],
                                                        enableMemoryCache: true,
                                                        shape: BoxShape.circle,
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
                                                                '${profileImgUrlList[0].default_round}',
                                                                enableMemoryCache: true,
                                                                shape: BoxShape.circle,
                                                                width: 58,
                                                                height: 58,
                                                                fit: BoxFit.cover,
                                                              ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                            default:
                                                              return null;
                                                          }
                                                        },
                                                      ),
                                                    )
                                                        : ExtendedImage.network(
                                                      '${profileImgUrlList[0].default_round}',
                                                      enableMemoryCache: true,
                                                      shape: BoxShape.circle,
                                                      width: 58,
                                                      height: 58,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    SizedBox(height: 6),
                                                    ExtendedImage.asset(
                                                      'assets/imgs/icons/icon_crown_3.png',
                                                      width: 28,
                                                      height: 28,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            userDoc[0]['displayName'],
                                                            style: TextStyle(
                                                              color: Color(0xFF111111),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          SizedBox(height: 2),
                                                          Text(
                                                            documents![2]['resortNickname'] ?? '',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Color(0xFF666666)
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if(widget.isWeekly == true && _userModelController.displayName == 'SNOWLIVE')
                                              GestureDetector(
                                                onTap:(){
                                                  _rankingTierModelController.updateWeeklyRankingTop(
                                                      userDoc[0]['uid'],
                                                      userDoc[0]['displayName'],
                                                      userDoc[0]['profileImageUrl'],
                                                      documents![2]['resortNickname'],
                                                      documents![2]['favoriteResort'],
                                                      documents![2]['totalScoreWeekly'],
                                                      documents![2]['totalPassCountWeekly'],
                                                      3
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Text('서버 등록',
                                                    style: TextStyle(
                                                        color: Color(0xFF949494),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Container(
                                          height: 154,
                                          width: (_size.width - 48) / 3,
                                        );
                                      } else {
                                        return Container(
                                          height: 154,
                                          width: (_size.width - 48) / 3,
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                            SizedBox(height: 40,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if(widget.isKusbf == true)
                                  Text('KUSBF 개인 랭킹 TOP 100',
                                    style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                if(widget.isKusbf == false &&
                                    (_userModelController.favoriteResort == 12 ||_userModelController.favoriteResort == 2 ||_userModelController.favoriteResort == 0)
                                )
                                  Text('${_userModelController.resortNickname} 개인 랭킹 TOP 100',
                                    style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                if(widget.isKusbf == false &&
                                    (_userModelController.favoriteResort != 12 && _userModelController.favoriteResort != 2 && _userModelController.favoriteResort != 0)
                                )
                                  Text('통합 개인 랭킹 TOP 100',
                                    style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: () async{
                                    Get.to(()=> RankingIndiAllScreen_test(isKusbf: widget.isKusbf, isDaily: widget.isDaily, isWeekly: widget.isWeekly));
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
                            SizedBox(height: 18,),
                            Container(
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: documents!.length < 100 ? documents!.length : 100,
                                itemBuilder: (context, index) {
                                  final document = documents![index];

                                  final userDoc = _allUserDocsController.allUserDocs;
                                  final Map<String, dynamic> userData = userDoc.isNotEmpty
                                      ? userDoc.firstWhere(
                                          (doc) => doc['uid'] == document['uid'],
                                      orElse: () => <String, dynamic>{} // 빈 맵을 반환
                                  )
                                      : <String, dynamic>{};

                                  String? crewName = _allCrewDocsController.findCrewName(userData['liveCrew'], _allCrewDocsController.allCrewDocs);


                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: (){
                                        Get.to(() => FriendDetailPage(uid: userData['uid'], favoriteResort: userData['favoriteResort'],));
                                      },
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${userRankingMap!['${userData['uid']}']}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Color(0xFF111111)
                                                ),
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
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.circle,
                                                  borderRadius: BorderRadius.circular(8),
                                                  cacheHeight: 100,
                                                  width: 48,
                                                  height: 48,
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
                                                          Text(userData['displayName'],
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color(0xFF111111)
                                                            ),
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
                                                          if(userData['liveCrew'] != '')
                                                            Text(crewName,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(0xFF949494)
                                                              ),),
                                                        ],
                                                      )
                                                      // StreamBuilder<QuerySnapshot>(
                                                      //   stream: FirebaseFirestore.instance
                                                      //       .collection('liveCrew')
                                                      //       .where('crewID', isEqualTo: userData['liveCrew'])
                                                      //       .snapshots(),
                                                      //   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                      //     if (snapshot.hasError) {
                                                      //       return Text("오류가 발생했습니다");
                                                      //     }
                                                      //
                                                      //     if (snapshot.connectionState == ConnectionState.waiting) {
                                                      //       return SizedBox.shrink();
                                                      //     }
                                                      //
                                                      //     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                                      //       return SizedBox.shrink();
                                                      //     }
                                                      //
                                                      //     var crewData = snapshot.data!.docs.first.data() as Map<String, dynamic>?;
                                                      //
                                                      //     // 크루명 가져오기
                                                      //     String crewName = crewData?['crewName'] ?? '';
                                                      //
                                                      //     return Text(crewName,
                                                      //       style: TextStyle(
                                                      //           fontSize: 12,
                                                      //           color: Color(0xFF949494)
                                                      //       ),
                                                      //     );
                                                      //   },
                                                      // ),
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
                                                        ? widget.isWeekly == true ?'${document['totalScoreWeekly'].toString()}점' :'${document['totalScore'].toString()}점'
                                                        : widget.isWeekly == true ?'${document['totalPassCountWeekly'].toString()}회':'${document['totalPassCount'].toString()}회',
                                                    style: TextStyle(
                                                      color: Color(0xFF111111),
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  if(widget.isDaily != true && widget.isWeekly != true)
                                                    Transform.translate(
                                                      offset: Offset(6, 2),
                                                      child: ExtendedImage.network(
                                                        (_userModelController.favoriteResort == 12
                                                            || _userModelController.favoriteResort == 2
                                                            || _userModelController.favoriteResort == 0)
                                                            ? _rankingTierModelController.getBadgeAsset(
                                                            percent: userRankingMap_all!['${userData['uid']}']/(documents_all!.length),
                                                            totalScore: document['totalScore'],
                                                            rankingTierList: rankingTierList
                                                        )
                                                            :_rankingTierModelController.getBadgeAsset_integrated(
                                                            percent: userRankingMap_all!['${userData['uid']}']/(documents_all!.length),
                                                            totalPassCount: document['totalPassCount'],
                                                            rankingTierList: rankingTierList
                                                        ),
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
                                    ),

                                  );

                                },
                              ),
                            ),
                            SizedBox(height: 90),
                          ],
                        ),
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
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: GestureDetector(
                onTap: (){
                  Get.to(() => FriendDetailPage(uid: _userModelController.uid, favoriteResort: _userModelController.favoriteResort,));
                },
                child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: Offset(0, 0), // changes position of shadow
                        ),],
                      color: Color(0xFF3D83ED),
                    ),
                    height: 80,
                    child:  Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child:
                        (userRankingMap_all?['${_userModelController.uid}'] != null )
                            ? Obx(() => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${userRankingMap_all?['${_userModelController.uid}']}',
                              style: TextStyle(
                                color: Color(0xFFffffff),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 14),
                            Container(
                              width: 48,
                              height: 48,
                              child: _userModelController.profileImageUrl!.isNotEmpty
                                  ? ExtendedImage.network(
                                _userModelController.profileImageUrl!,
                                enableMemoryCache: true,
                                shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(8),
                                width: 48,
                                height: 48,
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
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(8),
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
                                shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(8),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 14),
                            Container(
                              width: _size.width - 246,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_userModelController.displayName}',
                                    style: TextStyle(
                                      color: Color(0xFFffffff),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2,),
                                  if(_userModelController.stateMsg != '')
                                    Container(
                                      child: Text('${_userModelController.stateMsg}',
                                        style: TextStyle(
                                            color: Color(0xFFffffff).withOpacity(0.6),
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      width: _size.width - 246,
                                    )
                                ],
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Obx(()=>Row(
                              children: [
                                Text(
                                  (_userModelController.favoriteResort == 12
                                      || _userModelController.favoriteResort == 2
                                      || _userModelController.favoriteResort == 0)
                                      ? '${myTotalScore}점'
                                      :  '${myTotalPassCount}회',
                                  style: TextStyle(
                                    color: Color(0xFFffffff),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                  ),
                                ),
                                if(widget.isDaily != true && widget.isWeekly != true)
                                Transform.translate(
                                  offset: Offset(6, 2),
                                  child: ExtendedImage.network(
                                    (_userModelController.favoriteResort == 12
                                        || _userModelController.favoriteResort == 2
                                        || _userModelController.favoriteResort == 0)
                                        ? _rankingTierModelController.getBadgeAsset(
                                        percent:  userRankingMap_all?['${_userModelController.uid}'] / documents_all!.length,
                                        totalScore: myTotalScore ?? 0,
                                        rankingTierList: rankingTierList
                                    )
                                        : _rankingTierModelController.getBadgeAsset_integrated(
                                        percent:  userRankingMap_all?['${_userModelController.uid}'] / documents_all!.length,
                                        totalPassCount: myTotalPassCount ?? 0,
                                        rankingTierList: rankingTierList
                                    ),
                                    enableMemoryCache: true,
                                    fit: BoxFit.cover,
                                    width: 40,
                                  ),
                                ),
                              ],
                            ),
                            ),
                          ],
                        ))
                            : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '',
                              style: TextStyle(
                                color: Color(0xFFffffff),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 14),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => FriendDetailPage(uid: _userModelController.uid, favoriteResort: _userModelController.favoriteResort,));
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                child: _userModelController.profileImageUrl!.isNotEmpty
                                    ? ExtendedImage.network(
                                  _userModelController.profileImageUrl!,
                                  enableMemoryCache: true,
                                  shape: BoxShape.circle,
                                  borderRadius: BorderRadius.circular(8),
                                  width: 48,
                                  height: 48,
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
                                          shape: BoxShape.circle,
                                          borderRadius: BorderRadius.circular(8),
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
                                  shape: BoxShape.circle,
                                  borderRadius: BorderRadius.circular(8),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 14),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_userModelController.displayName}',
                                  style: TextStyle(
                                    color: Color(0xFFffffff),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2,),
                                if(_userModelController.stateMsg != '')
                                  Container(
                                    child: Text('${_userModelController.stateMsg}',
                                      style: TextStyle(
                                          color: Color(0xFFffffff).withOpacity(0.6),
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    width: _size.width - 246,
                                  )
                              ],
                            ),
                            Expanded(child: SizedBox()),
                            Row(
                              children: [
                                Text(
                                  '점수가 없습니다',
                                  style: TextStyle(
                                    color: Color(0xFFffffff),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        )
                    ))
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
