import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/controller/ranking/vm_myCrewRankingController.dart';
import 'package:com.snowlive/controller/ranking/vm_streamController_ranking.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/liveCrew/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import '../../../controller/ranking/vm_rankingTierModelController.dart';
import '../../../controller/resort/vm_resortModelController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../model_2/m_crewLogoModel.dart';
import '../../../model_2/m_resortModel.dart';
import '../../../widget/w_fullScreenDialog.dart';
import '../../../widget/w_verticalDivider.dart';
import '../../screens/LiveCrew/v_crewDetailPage_screen.dart';
import '../../screens/snowliveDesignStyle.dart';

class RankingCrewView extends StatefulWidget {
  RankingCrewView({Key? key,
    required this.isKusbf,
    required this.isDaily,
    required this.isWeekly,}) : super(key: key);

  bool isKusbf = false;
  bool isDaily = false;
  bool isWeekly = false;

  @override
  State<RankingCrewView> createState() => _RankingCrewViewState();
}

class _RankingCrewViewState extends State<RankingCrewView> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  MyCrewRankingController _myCrewRankingController = Get.find<MyCrewRankingController>();
  StreamController_ranking _streamController_ranking = Get.find<StreamController_ranking>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  //TODO: Dependency Injection**************************************************



  var foundCrewLogo;

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

    for (var crewLogo in crewLogoList) {
      if (_liveCrewModelController.crewColor == crewLogo.crewColor) {
        foundCrewLogo = crewLogo;
        break; // 일치하는 로고를 찾았으므로 루프를 종료합니다.
      }
    }

  }

  List? crewDocs;
  Map? crewRankingMap;

  int? myCrewTotalScore;
  int? myCrewTotalPassCount;

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

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            (crewDocs!.isNotEmpty)
            ? RefreshIndicator(
              onRefresh: () async {
                await _streamController_ranking.refreshData_Crew(isDaily: widget.isDaily, isWeekly: widget.isWeekly);
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
                          Get.to(() => CrewDetailPage_screen());
                        },
                        child: Obx(() => (crewRankingMap?['${_userModelController.liveCrew}'] != null )
                            ? Obx(() => Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 8),
                              child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              for (var crewLogo in crewLogoList)
                                if (_liveCrewModelController.crewColor == crewLogo.crewColor)
                                Container(
                                  height: 76,
                                  width: 76,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF0F6FF), // 배경 색상 설정
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child:
                                  (_liveCrewModelController.profileImageUrl != "")
                                      ? Container(
                                      width: 76,
                                      height: 76,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF0F6FF), // 선택된 옵션의 배경을 흰색으로 설정
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
                                      child: Transform.translate(
                                        offset: Offset(0, 0),
                                        child: ExtendedImage.network(
                                          '${_liveCrewModelController.profileImageUrl}',
                                          enableMemoryCache: true,
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
                                                      color: Color(_liveCrewModelController.crewColor!),
                                                      borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2.0),
                                                    child: ExtendedImage.network(
                                                      crewLogo.crewLogoAsset,
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
                                      ))
                                      : Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                        color: Color(_liveCrewModelController.crewColor!),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ExtendedImage.network(
                                        crewLogo.crewLogoAsset,
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(6),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                            Container(
                              width: 10,
                            ),
                              Expanded(
                                child: Container(
                                  height: 76,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF326EF6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 19),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            (_userModelController.favoriteResort == 12
                                                || _userModelController.favoriteResort == 2
                                                || _userModelController.favoriteResort == 0)
                                                ? '${myCrewTotalScore}'
                                                :  '${myCrewTotalPassCount}',
                                            style: SDSTextStyle.bold.copyWith(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 15,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 3),
                                            child: Text(
                                              '점수',
                                              style: SDSTextStyle.regular.copyWith(
                                                color: Color(0xFFFFFFFF).withOpacity(0.5),
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
                                            '${crewRankingMap?['${_userModelController.liveCrew}']}',
                                            style: SDSTextStyle.bold.copyWith(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 15,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 3),
                                            child: Text(
                                              '스키장 랭킹',
                                              style: SDSTextStyle.regular.copyWith(
                                                color: Color(0xFFFFFFFF).withOpacity(0.5),
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
                                            '999999',
                                            style: SDSTextStyle.bold.copyWith(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 15,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 3),
                                            child: Text(
                                              '통합 랭킹',
                                              style: SDSTextStyle.regular.copyWith(
                                                color: Color(0xFFFFFFFF).withOpacity(0.5),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),


                          ],
                        ),
                            ))
                            : Container()
                        ),
                      ),
                      Container(
                        height: 56,
                        child: Padding(
                          padding: EdgeInsets.only(top: 16, bottom: 8),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Container(
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
                                                      right: 31, left: 12, top: 3, bottom: 2),
                                                  backgroundColor: isTap[0] ? Color(0xFF111111) : Color(0xFFFFFFFF),
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: isTap[0] ? Color(0xFF111111) : Color(0xFFECECEC),
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
                                            top: 8,
                                            right: 10,
                                            child: GestureDetector(
                                              onTap: () async {
                                                await _showCupertinoPicker();
                                              },
                                              child: isTap[0] ? ExtendedImage.asset(
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
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ElevatedButton(
                                    onPressed: () async {

                                      setState(() {
                                        isTap[0] = false;
                                        isTap[1] = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.only(
                                            right: 12, left: 12, top: 3, bottom: 2),
                                        backgroundColor: isTap[1] ? Color(0xFF111111) : Color(0xFFFFFFFF),
                                        side: BorderSide(
                                          width: 1,
                                          color: isTap[1] ? Color(0xFF111111) : Color(0xFFECECEC),
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18))),
                                    child: Text('전체 스키장 랭킹',
                                        style: SDSTextStyle.bold.copyWith(
                                            fontSize: 13,
                                            color: isTap[1] ? Color(0xFFFFFFFF) : Color(0xFF111111)))),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(
                                        right: 12, left: 12, top: 2, bottom: 3),
                                    backgroundColor:  Color(0xFFFFFFFF),
                                    side: BorderSide(
                                      width: 1,
                                      color: Color(0xFFECECEC),
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18))),
                                child: ExtendedImage.network(
                                  '${KusbfAssetUrlList[0].mainLogo}',
                                  enableMemoryCache: true,
                                  shape: BoxShape.rectangle,
                                  width: 40,
                                  fit: BoxFit.cover,
                                  loadStateChanged:
                                      (ExtendedImageState state) {
                                    switch (state.extendedImageLoadState) {
                                      case LoadState.loading:
                                        return SizedBox.shrink();
                                      default:
                                        return null;
                                    }
                                  },
                                ),),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
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
                                  padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
                                  child: Container(
                                    height: 40,
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
                                                        '${crewRankingMap!['${crewDocs![index]['crewID']}']}',
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
                                          Container(
                                            width: 32,
                                            height: 32,
                                            child:
                                            (crewDocs![index]['profileImageUrl'].isNotEmpty)
                                                ? Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                    color: Color(0xFFDFECFF),
                                                    borderRadius: BorderRadius.circular(8)
                                                ),
                                                child: ExtendedImage.network(
                                                  crewDocs![index]['profileImageUrl'],
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(8),
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
                                                              color: Color(crewDocs![index]['crewColor']),
                                                              borderRadius: BorderRadius.circular(8)
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(2.0),
                                                            child: ExtendedImage.network(
                                                              crewLogo.crewLogoAsset,
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
                                                ))
                                                : Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                  color: Color(crewDocs![index]['crewColor']),
                                                  borderRadius: BorderRadius
                                                      .circular(8)
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: ExtendedImage.network(
                                                  crewLogo.crewLogoAsset,
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(6),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    crewDocs![index]['crewName'],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF111111),
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
                                                    crewDocs![index]['baseResortNickName'],
                                                    style: SDSTextStyle.regular.copyWith(
                                                        fontSize: 12,
                                                        color: Color(0xFF949494)
                                                    ),
                                                  ),
                                                  if (crewDocs![index]['description'].isNotEmpty)
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
                                                        Container(
                                                          width: _size.width - 224,
                                                          child: Text(
                                                            crewDocs![index]['description'],
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: SDSTextStyle.regular.copyWith(
                                                                fontSize: 12,
                                                                color: Color(0xFF949494)
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ],
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
                                            style: SDSTextStyle.regular.copyWith(
                                              color: Color(0xFF111111),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                          },
                        ),
                      ),
                      (_userModelController.liveCrew == "")
                          ? SizedBox(height: 20)
                          : SizedBox(height: 80),
                    ],
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
    );
  }
}