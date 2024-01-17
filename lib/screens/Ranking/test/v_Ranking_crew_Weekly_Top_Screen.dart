import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import '../../../controller/vm_resortModelController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../widget/w_fullScreenDialog.dart';


class RankingCrewWeeklyTopScreen extends StatefulWidget {
  RankingCrewWeeklyTopScreen({Key? key}) : super(key: key);


  @override
  State<RankingCrewWeeklyTopScreen> createState() =>
      _RankingCrewWeeklyTopScreenState();
}

class _RankingCrewWeeklyTopScreenState
    extends State<RankingCrewWeeklyTopScreen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************

  var _selectedSeason;
  var _selectedResort;
  var _selectedResortName;

  List<bool> isTapStats = [
    true,
    false,
  ];


  final StreamController<Map<String, List<DocumentSnapshot>>>
  _groupedDataController = StreamController<Map<String, List<DocumentSnapshot>>>();

  Stream<Map<String, List<DocumentSnapshot>>> get groupedDataStream =>
      _groupedDataController.stream;


  Future<void> getRankingDocsWeeklyTop() async {

    if(_selectedResort == 12 || _selectedResort == 2 || _selectedResort == 0){
      QuerySnapshot rankingSnapshot = await FirebaseFirestore.instance
          .collection('Ranking_Weekly_Top_Crew')
          .doc('1')
          .collection('${_selectedSeason}')
          .where('baseResort', isEqualTo: _selectedResort)
          .get();

      Map<String, List<DocumentSnapshot>> groupedData_WeeklyTop_Crew = {};

      rankingSnapshot.docs.forEach((doc) {
        String date = doc['date'];
        groupedData_WeeklyTop_Crew.putIfAbsent(date, () => []).add(doc);
      });

      List<MapEntry<String, List<DocumentSnapshot>>> sortedEntries =
      groupedData_WeeklyTop_Crew.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      Map<String, List<DocumentSnapshot>> sortedData =
      Map.fromEntries(sortedEntries);

      _groupedDataController.add(sortedData);

    } else {

      List<QueryDocumentSnapshot> rankingList = [];

      QuerySnapshot rankingSnapshot = await FirebaseFirestore.instance
          .collection('Ranking_Weekly_Top_Crew')
          .doc('1')
          .collection('${_selectedSeason}')
          .get();

      rankingList = rankingSnapshot.docs.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        var baseResort = data['baseResort'];
        return ![0, 2, 12].contains(baseResort);
      }).toList();

      Map<String, List<DocumentSnapshot>> groupedData_WeeklyTop_Crew = {};

      rankingList.forEach((doc) {
        String date = doc['date']; // date 필드의 값 가져오기
        groupedData_WeeklyTop_Crew.putIfAbsent(date, () => []).add(doc);
      });

      List<MapEntry<String, List<DocumentSnapshot>>> sortedEntries =
      groupedData_WeeklyTop_Crew.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      Map<String, List<DocumentSnapshot>> sortedData =
      Map.fromEntries(sortedEntries);

      _groupedDataController.add(sortedData);
    }
  }


  _showCupertinoPicker_Season() async {

    await showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 100,
              maxHeight: 600,
            ),
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // 전체를 보여주기 위해 날짜 목록을 초기화합니다.
                      setState(() {
                        _selectedSeason = _seasonController.seasonList!.isNotEmpty ? _seasonController.currentSeason : '데이터 없음';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('선택'),
                  ),
                  for (String season in _seasonController.seasonList!)
                    CupertinoActionSheetAction(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        // 선택한 시즌에 따라 필터링된 데이터를 업데이트합니다.
                        setState(() {
                          _selectedSeason = season;
                          isTapStats[0] = true;
                          isTapStats[1] = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(season), // 각 시즌 항목을 별도의 타일로 표시합니다.
                    ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text('닫기'),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    setState(() {
      getRankingDocsWeeklyTop();
    });
  }

  _showCupertinoPicker_Resort() async {
    await showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedResortName = '통합';
                            _selectedResort = 13;
                            isTapStats[0] = false;
                            isTapStats[1] = true;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          '통합',
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedResort = 0;
                            _selectedResortName = '곤지암리조트';
                            isTapStats[0] = false;
                            isTapStats[1] = true;
                          });
                          Navigator.pop(context);
                        },
                        child: Text('곤지암리조트')),
                    if(_selectedSeason != '2324')
                      CupertinoActionSheetAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedResort = 1;
                              _selectedResortName = '무주덕유산리조트';
                              isTapStats[0] = false;
                              isTapStats[1] = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('무주덕유산리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedResort = 2;
                            _selectedResortName = '비발디파크';
                            isTapStats[0] = false;
                            isTapStats[1] = true;
                          });
                          Navigator.pop(context);
                        },
                        child: Text('비발디파크')),
                    if(_selectedSeason != '2324')
                      CupertinoActionSheetAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedResort = 3;
                              _selectedResortName = '알펜시아';
                              isTapStats[0] = false;
                              isTapStats[1] = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('알펜시아')),
                    if(_selectedSeason != '2324')
                      CupertinoActionSheetAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedResort = 4;
                              _selectedResortName = '에덴밸리리조트';
                              isTapStats[0] = false;
                              isTapStats[1] = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('에덴밸리리조트')),
                    if(_selectedSeason != '2324')
                      CupertinoActionSheetAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedResort = 5;
                              _selectedResortName = '엘리시안강촌';
                              isTapStats[0] = false;
                              isTapStats[1] = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('엘리시안강촌')),
                    if(_selectedSeason != '2324')
                      CupertinoActionSheetAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedResort = 6;
                              _selectedResortName = '오크밸리리조트';
                              isTapStats[0] = false;
                              isTapStats[1] = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('오크밸리리조트')),
                    if(_selectedSeason != '2324')
                      CupertinoActionSheetAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedResort = 7;
                              _selectedResortName = '오투리조트';
                              isTapStats[0] = false;
                              isTapStats[1] = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('오투리조트')),
                    if(_selectedSeason != '2324')
                      CupertinoActionSheetAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedResort = 8;
                              _selectedResortName = '용평리조트';
                              isTapStats[0] = false;
                              isTapStats[1] = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('용평리조트')),
                    if(_selectedSeason != '2324')
                      CupertinoActionSheetAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedResort = 9;
                              _selectedResortName = '웰리힐리파크';
                              isTapStats[0] = false;
                              isTapStats[1] = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('웰리힐리파크')),
                    if(_selectedSeason != '2324')
                      CupertinoActionSheetAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedResort = 10;
                              _selectedResortName = '지산리조트';
                              isTapStats[0] = false;
                              isTapStats[1] = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('지산리조트')),
                    if(_selectedSeason != '2324')
                      CupertinoActionSheetAction(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedResort = 11;
                              _selectedResortName = '하이원리조트';
                              isTapStats[0] = false;
                              isTapStats[1] = true;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('하이원리조트')),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedResort = 12;
                            _selectedResortName = '휘닉스파크';
                            isTapStats[0] = false;
                            isTapStats[1] = true;
                          });
                          Navigator.pop(context);
                        },
                        child: Text('휘닉스파크')),
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
    setState(() {
      getRankingDocsWeeklyTop();
    });
  }




  @override
  void initState() {
    super.initState();
    _selectedSeason = _seasonController.currentSeason;
    _selectedResort = _userModelController.favoriteResort;
    _selectedResortName =
    _userModelController.favoriteResort == 12
        || _userModelController.favoriteResort == 2
        || _userModelController.favoriteResort == 0
        ? _resortModelController.getResortName(_userModelController.resortNickname!) : '통합';
    getRankingDocsWeeklyTop();

  }

  void dispose() {
    _groupedDataController.close();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async{
                  await _showCupertinoPicker_Season();
                },
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Container(
                        decoration: BoxDecoration(
                          color: (isTapStats[0] == true) ? Color(0xFFFFFFFF) : Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: (isTapStats[0] == true) ? Color(0xFFDEDEDE) : Color(0xFFDEDEDE)),
                        ),
                        padding: EdgeInsets.only(right: 4, left: 8, top: 8, bottom: 8),
                        height: 32,
                        child:(_selectedSeason != null)
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${_selectedSeason}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: (isTapStats[0] == true) ? Color(0xFF777777) : Color(0xFF777777))),
                            Container(
                              height: 18,
                              width: 18,
                              child: Icon(
                                Icons.arrow_drop_down_sharp,
                                size: 16,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        )
                            : Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child:  ExtendedImage.network(
                                '${IconAssetUrlList[0].filter}',
                                enableMemoryCache: true,
                                shape: BoxShape.rectangle,
                                width: 12,
                                loadStateChanged: (ExtendedImageState state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return SizedBox.shrink();
                                    default:
                                      return null;
                                  }
                                },
                              ),
                            ),
                            Text('시즌',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF777777)))
                          ],
                        )

                    ),
                  ),
                ),

              ),
              GestureDetector(
                onTap: () async{
                  await _showCupertinoPicker_Resort();
                },
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                        decoration: BoxDecoration(
                          color: (isTapStats[1] == true) ? Color(0xFFFFFFFF) : Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: (isTapStats[1] == true) ? Color(0xFFDEDEDE) : Color(0xFFDEDEDE)),
                        ),
                        padding: EdgeInsets.only(right: 4, left: 10, top: 8, bottom: 8),
                        height: 32,
                        child:(_selectedResort != null)
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${_selectedResortName}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: (isTapStats[1] == true) ? Color(0xFF777777) : Color(0xFF777777))),
                            Container(
                              height: 18,
                              width: 18,
                              child: Icon(
                                Icons.arrow_drop_down_sharp,
                                size: 16,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        )
                            : Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child:  ExtendedImage.network(
                                '${IconAssetUrlList[0].filter}',
                                enableMemoryCache: true,
                                shape: BoxShape.rectangle,
                                width: 12,
                                loadStateChanged: (ExtendedImageState state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return SizedBox.shrink();
                                    default:
                                      return null;
                                  }
                                },
                              ),
                            ),
                            Text('스키장',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF777777)))
                          ],
                        )

                    ),
                  ),
                ),

              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 42),
              ExtendedImage.asset(
                'assets/imgs/icons/icon_crown_1_ns.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 70),
              ExtendedImage.asset(
                'assets/imgs/icons/icon_crown_2_ns.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 70),
              ExtendedImage.asset(
                'assets/imgs/icons/icon_crown_3_ns.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              height: 0.5,
              color: Color(0xFFDEDEDE),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: SafeArea(
            top: false,
            bottom: true,
            child: StreamBuilder<Map<String, List<DocumentSnapshot>>>(
              stream: groupedDataStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // 스트림에서 데이터를 가져와 리스트 뷰를 생성
                  Map<String, List<DocumentSnapshot>> groupedData = snapshot.data!;
                  String? prevMonth; // 이전 월을 저장하기 위한 변수

                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: groupedData.length,
                    itemBuilder: (context, index) {
                      List<DocumentSnapshot> docs = groupedData.values.elementAt(index);
                      List<DocumentSnapshot> top3Docs = [];

                      // rank 필드를 기준으로 정렬
                      docs.sort((a, b) => (a['rank'] as int).compareTo(b['rank'] as int));

                      // 1등, 2등, 3등의 DocumentSnapshot 가져오기
                      for (var i = 0; i < docs.length && top3Docs.length < 3; i++) {
                        if (docs[i]['rank'] == top3Docs.length + 1) {
                          top3Docs.add(docs[i]);
                        }
                      }

                      String month = docs[0]['month'].toString(); // 월 정보 가져오기

                      // 이전 월과 현재 월을 비교하여 타이틀 표시 여부 결정
                      bool showTitle = prevMonth != month;
                      prevMonth = month; // 현재 월을 이전 월로 설정

                      print('이거 $month');

                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showTitle) // 월이 변경될 때만 타이틀 표시
                              Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$month월',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 14, bottom: 10),
                                      child: Container(
                                        height: 0.5,
                                        color: Color(0xFFDEDEDE),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3, top: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    child: Text(
                                      '${docs[0]['week']}주차',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal
                                      ),
                                    ),
                                  ),
                                  for (var i = 0; i < top3Docs.length; i++)
                                    GestureDetector(
                                      onTap: () async{
                                        CustomFullScreenDialog.showDialog();
                                        await _userModelController.getCurrentUser_crew(_userModelController.uid);
                                        await _liveCrewModelController.getCurrrentCrew(top3Docs[i]['crewID']);
                                        CustomFullScreenDialog.cancelDialog();
                                        Get.to(()=>CrewDetailPage_screen());
                                      },
                                      child: Container(
                                        width: _size.width - 274,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 4),
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFDFECFF),
                                                  borderRadius: BorderRadius.circular(50),
                                                  border: Border.all(color: Color(0xFFECECEC))
                                                ),
                                                child: ClipOval(
                                                  child: top3Docs[i]['profileImageUrl'].isNotEmpty
                                                      ? ExtendedImage.network(
                                                    top3Docs[i]['profileImageUrl'],
                                                    enableMemoryCache: true,
                                                    cacheHeight: 100,
                                                    width: 32,
                                                    height: 32,
                                                    fit: BoxFit.cover,
                                                    loadStateChanged: (ExtendedImageState state) {
                                                      switch (state.extendedImageLoadState) {
                                                        case LoadState.loading:
                                                          return CircularProgressIndicator();
                                                        case LoadState.completed:
                                                          return state.completedWidget;
                                                        case LoadState.failed:
                                                          return Icon(Icons.error);
                                                        default:
                                                          return null;
                                                      }
                                                    },
                                                  )
                                                      : Image.network(
                                                    '${profileImgUrlList[0].default_round}',
                                                    width: 32,
                                                    height: 32,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: _size.width - 314,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${top3Docs[i]['crewName']}',
                                                    style: TextStyle(fontSize: 11,
                                                    fontWeight: FontWeight.bold),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  Text(
                                                    _selectedResort == 12 ||
                                                        _selectedResort == 2 ||
                                                        _selectedResort == 0
                                                        ? '${top3Docs[i]['score']}점'
                                                        : '${top3Docs[i]['passCount']}회',
                                                    style: TextStyle(fontSize: 11),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
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
                            ),
                            if (docs.length != index + 1)
                              Divider(
                                color: Color(0xFFDEDEDE),
                                height: 20,
                                thickness: 0.5,
                              ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('에러 발생: ${snapshot.error}');
                } else {
                  return SizedBox.shrink(); // 데이터 로딩 중
                }
              },
            ),
          ),
        ),


      ],
    );
  }
}

