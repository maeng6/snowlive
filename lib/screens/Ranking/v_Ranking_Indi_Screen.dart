import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/resort/vm_resortModelController.dart';
import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:com.snowlive/widget/w_verticalDivider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import '../../controller/liveCrew/vm_allCrewDocsController.dart';
import '../../controller/user/vm_allUserDocsController.dart';
import '../../controller/ranking/vm_myRankingController.dart';
import '../../controller/ranking/vm_rankingTierModelController.dart';
import '../../controller/ranking/vm_streamController_ranking.dart';
import '../../data/imgaUrls/Data_url_image.dart';
import '../../model/m_rankingTierModel.dart';
import '../more/friend/v_friendDetailPage.dart';

class RankingIndiScreen extends StatefulWidget {
  RankingIndiScreen({Key? key,
    required this.isKusbf,
    required this.isDaily,
    required this.isWeekly,}) : super(key: key);

  bool isKusbf = false;
  bool isDaily = false;
  bool isWeekly = false;


  @override
  State<RankingIndiScreen> createState() => _RankingIndiScreenState();
}

class _RankingIndiScreenState extends State<RankingIndiScreen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  MyRankingController _myRankingController = Get.find<MyRankingController>();
  AllCrewDocsController _allCrewDocsController = Get.find<AllCrewDocsController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  StreamController_ranking _streamController_ranking = Get.find<StreamController_ranking>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  //TODO: Dependency Injection**************************************************

  Map? userRankingMap;
  Map? userRankingMap_all;
  List? documents;
  List? documents_all;
  int? myTotalScore;
  int? myTotalPassCount;

  List<bool> isTap = [
    true,
    false,
  ];

  var _selectedValue_resort;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedValue_resort = '${_resortModelController.getResortName(_userModelController.resortNickname!)}';
    _allCrewDocsController.startListening().then((result){
      setState(() {});
    });

  }


  _showCupertinoPicker() async {
    await showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                height: 520,
                padding: EdgeInsets.only(left: 16, right: 16),
                child: CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[0]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          '${resortFullNameList[0]}',
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[1]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[1]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[2]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[2]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[3]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[3]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[4]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[4]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[5]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[5]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[6]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[6]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[7]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[7]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[8]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[8]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[9]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[9]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[10]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[10]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[11]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[11]}')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            isTap[0] = true;
                            isTap[1] = false;
                            _selectedValue_resort = '${resortFullNameList[12]}';
                          });
                          Navigator.pop(context);
                        },
                        child: Text('${resortFullNameList[12]}')),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    child: Text('닫기'),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                  ),
                )
            ),
          );
        });
    setState(() {});
  }




  @override
  void dispose() {
    _allCrewDocsController.stopListening();
    super.dispose();
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
              onRefresh: () async {
                await _streamController_ranking.refreshData_Indi(isDaily: widget.isDaily, isWeekly: widget.isWeekly);
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: (){
                          Get.to(() => FriendDetailPage(uid: _userModelController.uid, favoriteResort: _userModelController.favoriteResort,));
                        },
                        child: Obx(() => (userRankingMap_all?['${_userModelController.uid}'] != null )
                            ? Obx(() => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF0F6FF), // 선택된 옵션의 배경을 흰색으로 설정
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.all(15),
                                child: Transform.translate(
                                  offset: Offset(0, 0),
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
                              ),
                            Expanded(child: SizedBox()),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF0F6FF), // 선택된 옵션의 배경을 흰색으로 설정
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: EdgeInsets.all(17),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        (_userModelController.favoriteResort == 12
                                            || _userModelController.favoriteResort == 2
                                            || _userModelController.favoriteResort == 0)
                                            ? '${myTotalScore}'
                                            :  '${myTotalPassCount}',
                                        style: TextStyle(
                                          color: Color(0xFF111111),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '점수',
                                        style: TextStyle(
                                          color: Color(0xFF444444),
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  buildVerticalDivider_ranking_indi_Screen(),
                                  Column(
                                    children: [
                                      Text(
                                        '${userRankingMap_all?['${_userModelController.uid}']}',
                                        style: TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '스키장 랭킹',
                                        style: TextStyle(
                                          color: Color(0xFF444444),
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  buildVerticalDivider_ranking_indi_Screen(),
                                  Column(
                                    children: [
                                      Text(
                                        '999999',
                                        style: TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '통합 랭킹',
                                        style: TextStyle(
                                          color: Color(0xFF444444),
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),


                          ],
                        ))
                            : Text(
                          '라이브를 켜고 랭킹전에 참여해 보세요',
                          style: TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 15,
                          ),),),
                      ),
                      SizedBox(height: 13,),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Container(
                              height: 56,
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            await _showCupertinoPicker();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.only(
                                                  right: 28, left: 12, top: 6, bottom: 6),
                                              backgroundColor: isTap[0] ? Color(0xFF111111) : Color(0xFFFFFFFF),
                                              side: const BorderSide(
                                                width: 1,
                                                color: Color(0xFFF5F5F5),
                                              ),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(18))),
                                          child: Text('$_selectedValue_resort',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: isTap[0] ? Color(0xFFFFFFFF) : Color(0xFF111111) ))),
                                      Positioned(
                                        top: 17,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await _showCupertinoPicker();
                                          },
                                          child: ExtendedImage.asset(
                                            'assets/imgs/icons/icon_check_round.png',
                                            fit: BoxFit.cover,
                                            width: 14,
                                            height: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () async {

                                setState(() {
                                  isTap[0] = false;
                                  isTap[1] = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                   backgroundColor: isTap[1] ? Color(0xFF111111) : Color(0xFFFFFFFF),
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFF5F5F5),
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18))),
                              child: Text('전체 스키장 랭킹',
                                 style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isTap[1] ? Color(0xFFFFFFFF) : Color(0xFF111111)))),
                        ],
                      ),
                      SizedBox(height: 13,),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
          ],
        ),
      ),
    );
  }
}
