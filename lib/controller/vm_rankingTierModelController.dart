import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_liveMapController.dart';
import 'package:com.snowlive/controller/vm_loadingController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/model/m_rankingTierModel.dart';
import 'package:intl/intl.dart';

class RankingTierModelController extends GetxController{

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxList? _rankingDocs=[].obs;
  RxList? _rankingDocs_daily=[].obs;
  RxList? _rankingDocs_weekly=[].obs;
  RxList? _rankingDocs_integrated=[].obs;
  RxList? _rankingDocs_integrated_daily=[].obs;
  RxList? _rankingDocs_integrated_weekly=[].obs;
  RxList? _rankingDocs_kusbf=[].obs;
  RxList? _rankingDocs_kusbf_daily=[].obs;
  RxList? _rankingDocs_kusbf_weekly=[].obs;
  RxMap? _userRankingMap=<String, int>{}.obs;
  RxMap? _userRankingMap_daily=<String, int>{}.obs;
  RxMap? _userRankingMap_weekly=<String, int>{}.obs;
  RxMap? _userRankingMap_integrated=<String, int>{}.obs;
  RxMap? _userRankingMap_integrated_daily=<String, int>{}.obs;
  RxMap? _userRankingMap_integrated_weekly=<String, int>{}.obs;
  RxMap? _userRankingMap_kusbf=<String, int>{}.obs;
  RxMap? _userRankingMap_kusbf_daily=<String, int>{}.obs;
  RxMap? _userRankingMap_kusbf_weekly=<String, int>{}.obs;

  RxList? _rankingDocs_crew=[].obs;
  RxList? _rankingDocs_crew_daily=[].obs;
  RxList? _rankingDocs_crew_weekly=[].obs;
  RxList? _rankingDocs_crew_integrated=[].obs;
  RxList? _rankingDocs_crew_integrated_daily=[].obs;
  RxList? _rankingDocs_crew_integrated_weekly=[].obs;
  RxList? _rankingDocs_crewMember=[].obs;
  RxList? _rankingDocs_crewMember_integrated=[].obs;
  RxList? _rankingDocs_crew_kusbf=[].obs;
  RxList? _rankingDocs_crew_kusbf_daily=[].obs;
  RxList? _rankingDocs_crew_kusbf_weekly=[].obs;
  RxMap? _crewRankingMap =<String, int>{}.obs;
  RxMap? _crewRankingMap_daily =<String, int>{}.obs;
  RxMap? _crewRankingMap_weekly =<String, int>{}.obs;
  RxMap? _crewRankingMap_integrated =<String, int>{}.obs;
  RxMap? _crewRankingMap_integrated_daily =<String, int>{}.obs;
  RxMap? _crewRankingMap_integrated_weekly =<String, int>{}.obs;
  RxMap? _crewRankingMap_kusbf =<String, int>{}.obs;
  RxMap? _crewRankingMap_kusbf_daily =<String, int>{}.obs;
  RxMap? _crewRankingMap_kusbf_weekly =<String, int>{}.obs;

  RxList? _kusbfAllMemberUidList=[].obs;

  List? get rankingDocs => _rankingDocs;
  List? get rankingDocs_daily => _rankingDocs_daily;
  List? get rankingDocs_weekly => _rankingDocs_weekly;
  List? get rankingDocs_integrated => _rankingDocs_integrated;
  List? get rankingDocs_integrated_daily => _rankingDocs_integrated_daily;
  List? get rankingDocs_integrated_weekly => _rankingDocs_integrated_weekly;
  List? get rankingDocs_kusbf => _rankingDocs_kusbf;
  List? get rankingDocs_kusbf_daily => _rankingDocs_kusbf_daily;
  List? get rankingDocs_kusbf_weekly => _rankingDocs_kusbf_weekly;
  Map? get userRankingMap => _userRankingMap;
  Map? get userRankingMap_daily => _userRankingMap_daily;
  Map? get userRankingMap_weekly => _userRankingMap_weekly;
  Map? get userRankingMap_integrated => _userRankingMap_integrated;
  Map? get userRankingMap_integrated_daily => _userRankingMap_integrated_daily;
  Map? get userRankingMap_integrated_weekly => _userRankingMap_integrated_weekly;
  Map? get userRankingMap_kusbf => _userRankingMap_kusbf;
  Map? get userRankingMap_kusbf_daily => _userRankingMap_kusbf_daily;
  Map? get userRankingMap_kusbf_weekly => _userRankingMap_kusbf_weekly;

  List? get rankingDocs_crew => _rankingDocs_crew;
  List? get rankingDocs_crew_daily => _rankingDocs_crew_daily;
  List? get rankingDocs_crew_weekly => _rankingDocs_crew_weekly;
  List? get rankingDocs_crew_integrated => _rankingDocs_crew_integrated;
  List? get rankingDocs_crew_integrated_daily => _rankingDocs_crew_integrated_daily;
  List? get rankingDocs_crew_integrated_weekly => _rankingDocs_crew_integrated_weekly;
  List? get rankingDocs_crewMember => _rankingDocs_crewMember;
  List? get rankingDocs_crewMember_integrated => _rankingDocs_crewMember_integrated;
  List? get rankingDocs_crew_kusbf => _rankingDocs_crew_kusbf;
  List? get rankingDocs_crew_kusbf_daily => _rankingDocs_crew_kusbf_daily;
  List? get rankingDocs_crew_kusbf_weekly => _rankingDocs_crew_kusbf_weekly;
  Map? get crewRankingMap => _crewRankingMap;
  Map? get crewRankingMap_daily => _crewRankingMap_daily;
  Map? get crewRankingMap_weekly => _crewRankingMap_weekly;
  Map? get crewRankingMap_integrated => _crewRankingMap_integrated;
  Map? get crewRankingMap_integrated_daily => _crewRankingMap_integrated_daily;
  Map? get crewRankingMap_integrated_weekly => _crewRankingMap_integrated_weekly;
  Map? get crewRankingMap_kusbf => _crewRankingMap_kusbf;
  Map? get crewRankingMap_kusbf_daily => _crewRankingMap_kusbf_daily;
  Map? get crewRankingMap_kusbf_weekly => _crewRankingMap_kusbf_weekly;

  List? get kusbfAllMemberUidList => _kusbfAllMemberUidList;

  //TODO: Dependency Injection********************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LoadingController _loadingController = Get.find<LoadingController>();
  //TODO: Dependency Injection********************************************


  //TODO: 개인 랭킹독 가져오는 메소드********************************************

  Future<void> getRankingDocs({required baseResort}) async {
    // 현재 날짜를 문자열 형태로 포맷
    String today = DateFormat('yyyyMMdd').format(DateTime.now());

    // 동시에 두 개의 Firestore 쿼리 실행

    var rankingSnapshotFuture = FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('$baseResort')
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .get();

    var kusbfCrewSnapshotFuture = (baseResort == 12)
        ? FirebaseFirestore.instance
        .collection('liveCrew')
        .where('kusbf', isEqualTo: true)
        .get()
        : Future.value(null); // baseResort가 12가 아닌 경우 빈 결과 반환

    var results = await Future.wait([rankingSnapshotFuture, kusbfCrewSnapshotFuture]);

    var rankingSnapshot = results[0] as QuerySnapshot;
    var kusbfCrewSnapshot = results[1] as QuerySnapshot?;

    List<QueryDocumentSnapshot> rankingList = rankingSnapshot.docs;
    List<QueryDocumentSnapshot> rankingList_kusbf = [];

    Set<String> kusbfAllMemberUidSet = {};
    if (baseResort == 12 && kusbfCrewSnapshot != null) {
      for (var doc in kusbfCrewSnapshot.docs) {
        List<dynamic> memberUidList = doc['memberUidList'];
        kusbfAllMemberUidSet.addAll(memberUidList.cast<String>());
      }

      rankingList_kusbf = rankingList.where((doc) {
        final uid = doc['uid'];
        return kusbfAllMemberUidSet.contains(uid);
      }).toList();

      sortRankingList(rankingList_kusbf);
    }

    sortRankingList(rankingList);

    // 결과를 Map 형태로 변환 및 저장
    this._rankingDocs!.value = rankingList.map((doc) => doc.data() as Map<String, dynamic>).toList();
    this._rankingDocs_kusbf!.value = rankingList_kusbf.map((doc) => doc.data() as Map<String, dynamic>).toList();
    this._userRankingMap!.value = await calculateRankIndiAll2(userRankingDocs: _rankingDocs);
    this._userRankingMap_kusbf!.value = await calculateRankIndiAll2(userRankingDocs: _rankingDocs_kusbf);

    print('대학연합 랭킹참여자 : ${_rankingDocs_kusbf!.length}');
    print('일반 랭킹참여자 : ${_rankingDocs!.length}');
  }

  Future<void> getRankingDocsDaily({required baseResort}) async {
    String today = DateFormat('yyyyMMdd').format(DateTime.now());

    var rankingSnapshotFuture = FirebaseFirestore.instance
        .collection('Ranking_Daily')
        .doc('${_seasonController.currentSeason}')
        .collection('$baseResort')
        .where('date', isEqualTo: today)
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .get();

    var kusbfCrewSnapshotFuture = (baseResort == 12)
        ? FirebaseFirestore.instance
        .collection('liveCrew')
        .where('kusbf', isEqualTo: true)
        .get()
        : Future.value(null); // baseResort가 12가 아닌 경우 빈 결과 반환

    var results = await Future.wait([rankingSnapshotFuture, kusbfCrewSnapshotFuture]);

    var rankingSnapshot = results[0] as QuerySnapshot;
    var kusbfCrewSnapshot = results[1] as QuerySnapshot?;

    List<QueryDocumentSnapshot> rankingList = rankingSnapshot.docs;
    List<QueryDocumentSnapshot> rankingList_kusbf = [];

    Set<String> kusbfAllMemberUidSet = {};
    if (baseResort == 12 && kusbfCrewSnapshot != null) {
      for (var doc in kusbfCrewSnapshot.docs) {
        List<dynamic> memberUidList = doc['memberUidList'];
        kusbfAllMemberUidSet.addAll(memberUidList.cast<String>());
      }

      rankingList_kusbf = rankingList.where((doc) {
        final uid = doc['uid'];
        return kusbfAllMemberUidSet.contains(uid);
      }).toList();

      sortRankingList(rankingList_kusbf);
    }

    sortRankingList(rankingList);

    // 결과를 Map 형태로 변환 및 저장
    this._rankingDocs_daily!.value = rankingList.map((doc) => doc.data() as Map<String, dynamic>).toList();
    this._rankingDocs_kusbf_daily!.value = rankingList_kusbf.map((doc) => doc.data() as Map<String, dynamic>).toList();
    this._userRankingMap_daily!.value = await calculateRankIndiAll2(userRankingDocs: _rankingDocs_daily);
    this._userRankingMap_kusbf_daily!.value = await calculateRankIndiAll2(userRankingDocs: _rankingDocs_kusbf_daily);

    print('대학연합 일간랭킹 참여자 : ${_rankingDocs_kusbf_daily!.length}');
    print('일간랭킹 참여자 : ${_rankingDocs_daily!.length}');
  }

  Future<void> getRankingDocsWeekly({required baseResort}) async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
    List<String> thisWeekDates = List.generate(
      7,
          (index) => DateFormat('yyyyMMdd').format(startOfWeek.add(Duration(days: index))),
    );

    var rankingSnapshotFuture = FirebaseFirestore.instance
        .collection('Ranking_Daily')
        .doc('${_seasonController.currentSeason}')
        .collection('$baseResort')
        .where('date', whereIn: thisWeekDates)
        .where('totalScoreWeekly', isGreaterThan: 0)
        .orderBy('totalScoreWeekly', descending: true)
        .get();

    var kusbfCrewSnapshotFuture = (baseResort == 12)
        ? FirebaseFirestore.instance
        .collection('liveCrew')
        .where('kusbf', isEqualTo: true)
        .get()
        : Future.value(null);

    var results = await Future.wait([rankingSnapshotFuture, kusbfCrewSnapshotFuture]);

    var rankingSnapshot = results[0] as QuerySnapshot;
    var kusbfCrewSnapshot = results[1] as QuerySnapshot?;

    List<QueryDocumentSnapshot> rankingList = processRankingSnapshot(rankingSnapshot);
    List<QueryDocumentSnapshot> rankingList_kusbf = [];

    if (baseResort == 12 && kusbfCrewSnapshot != null) {
      Set<String> kusbfAllMemberUidSet = kusbfCrewSnapshot.docs
          .expand((doc) => (doc.data() as Map<String, dynamic>)['memberUidList'])
          .cast<String>()
          .toSet();

      rankingList_kusbf = rankingList.where((doc) => kusbfAllMemberUidSet.contains(doc['uid'])).toList();
      sortRankingList2(rankingList_kusbf, 'totalScoreWeekly');
    }

    sortRankingList2(rankingList, 'totalScoreWeekly');

    // 결과를 Map 형태로 변환 및 저장
    this._rankingDocs_weekly!.value = rankingList.map((doc) => doc.data() as Map<String, dynamic>).toList();
    this._rankingDocs_kusbf_weekly!.value = rankingList_kusbf.map((doc) => doc.data() as Map<String, dynamic>).toList();
    this._userRankingMap_weekly!.value = await calculateRankIndiAll2(userRankingDocs: _rankingDocs_weekly);
    this._userRankingMap_kusbf_weekly!.value = await calculateRankIndiAll2(userRankingDocs: _rankingDocs_kusbf_weekly);

    print('대학연합 주간랭킹 참여자 : ${_rankingDocs_kusbf_weekly!.length}');
    print('주간랭킹 참여자 : ${_rankingDocs_weekly!.length}');
  }

  Future<void> getRankingDocs_integrated() async {
    List<int> resortIds = List.generate(13, (i) => i)..removeWhere((id) => [0, 2, 12].contains(id));
    List<Future<QuerySnapshot>> futures = [];

    for (int resortId in resortIds) {
      futures.add(FirebaseFirestore.instance
          .collection('Ranking')
          .doc('${_seasonController.currentSeason}')
          .collection('$resortId')
          .where('totalPassCount', isGreaterThan: 0)
          .orderBy('totalPassCount', descending: true)
          .get());
    }

    List<QueryDocumentSnapshot> rankingList = (await Future.wait(futures))
        .expand((snapshot) => snapshot.docs)
        .toList();

    // 중복 제거
    Map<String, QueryDocumentSnapshot> uniqueDocs = {};
    for (var doc in rankingList) {
      String uid = doc['uid'];
      if (!uniqueDocs.containsKey(uid) || uniqueDocs[uid]!['totalPassCount'] < doc['totalPassCount']) {
        uniqueDocs[uid] = doc;
      }
    }

    rankingList = uniqueDocs.values.toList();
    _sortRankingList(rankingList);

    _rankingDocs_integrated!.value = rankingList.map((doc) => doc.data() as Map<String, dynamic>).toList();
    _userRankingMap_integrated!.value = await calculateRankIndiAll2_integrated(userRankingDocs: _rankingDocs_integrated);
    print('통합랭킹 참여자 : ${_rankingDocs_integrated!.length}');
  }

  Future<void> getRankingDocs_integrated_Daily() async {
    List<int> resortIds = List.generate(13, (i) => i)..removeWhere((id) => [0, 2, 12].contains(id));
    List<Future<QuerySnapshot>> futures = [];
    String today = DateFormat('yyyyMMdd').format(DateTime.now());

    for (int resortId in resortIds) {
      futures.add(FirebaseFirestore.instance
          .collection('Ranking_Daily')
          .doc('${_seasonController.currentSeason}')
          .collection('$resortId')
          .where('date', isEqualTo: today)
          .where('totalPassCount', isGreaterThan: 0)
          .orderBy('totalPassCount', descending: true)
          .get());
    }

    List<QueryDocumentSnapshot> rankingList = (await Future.wait(futures))
        .expand((snapshot) => snapshot.docs)
        .toList();

    Map<String, QueryDocumentSnapshot> uniqueDocs = {};
    for (var doc in rankingList) {
      String uid = doc['uid'];
      if (!uniqueDocs.containsKey(uid) || uniqueDocs[uid]!['totalPassCount'] < doc['totalPassCount']) {
        uniqueDocs[uid] = doc;
      }
    }

    rankingList = uniqueDocs.values.toList();
    _sortRankingList(rankingList);

    _rankingDocs_integrated_daily!.value = rankingList.map((doc) => doc.data() as Map<String, dynamic>).toList();
    _userRankingMap_integrated_daily!.value = await calculateRankIndiAll2_integrated(userRankingDocs: _rankingDocs_integrated_daily);
    print('일간 통합랭킹 참여자 : ${_rankingDocs_integrated_daily!.length}');
  }

  Future<void> getRankingDocs_integrated_Weekly() async {
    List<int> resortIds = List.generate(13, (i) => i)..removeWhere((id) => [0, 2, 12].contains(id));
    List<Future<QuerySnapshot>> futures = [];

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    List<String> thisWeekDates = [
      for (DateTime date = startOfWeek; date.isBefore(endOfWeek); date = date.add(Duration(days: 1)))
        DateFormat('yyyyMMdd').format(date)
    ];

    for (int resortId in resortIds) {
      futures.add(FirebaseFirestore.instance
          .collection('Ranking_Daily')
          .doc('${_seasonController.currentSeason}')
          .collection('$resortId')
          .where('date', whereIn: thisWeekDates)
          .where('totalPassCount', isGreaterThan: 0)
          .orderBy('totalPassCount', descending: true)
          .get());
    }

    List<QueryDocumentSnapshot> rankingList = (await Future.wait(futures))
        .expand((snapshot) => snapshot.docs)
        .toList();

    Map<String, QueryDocumentSnapshot> uniqueDocs = {};
    for (var doc in rankingList) {
      String uid = doc['uid'];
      if (!uniqueDocs.containsKey(uid) || uniqueDocs[uid]!['totalPassCount'] < doc['totalPassCount']) {
        uniqueDocs[uid] = doc;
      }
    }

    rankingList = uniqueDocs.values.toList();
    _sortRankingList(rankingList);

    _rankingDocs_integrated_weekly!.value = rankingList.map((doc) => doc.data() as Map<String, dynamic>).toList();
    _userRankingMap_integrated_weekly!.value = await calculateRankIndiAll2_integrated(userRankingDocs: _rankingDocs_integrated_weekly);
    print('주간 통합랭킹 참여자 : ${_rankingDocs_integrated_weekly!.length}');
  }

  void sortRankingList2(List<QueryDocumentSnapshot> rankingList, String scoreField) {
    rankingList.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aTotalScore = aData[scoreField] as int;
      final bTotalScore = bData[scoreField] as int;
      final aLastPassTime = aData['lastPassTime'] as Timestamp?;
      final bLastPassTime = bData['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore && aLastPassTime != null && bLastPassTime != null) {
        return bLastPassTime.compareTo(aLastPassTime);
      }
      return bTotalScore.compareTo(aTotalScore);
    });
  }

  void sortRankingList(List<QueryDocumentSnapshot> rankingList) {
    rankingList.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aTotalScore = aData['totalScore'] as int;
      final bTotalScore = bData['totalScore'] as int;
      final aLastPassTime = aData['lastPassTime'] as Timestamp?;
      final bLastPassTime = bData['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore && aLastPassTime != null && bLastPassTime != null) {
        return bLastPassTime.compareTo(aLastPassTime);
      }
      return bTotalScore.compareTo(aTotalScore);
    });
  }

  void _sortRankingList(List<QueryDocumentSnapshot> rankingList) {
    rankingList.sort((a, b) {
      final aTotalScore = a['totalPassCount'] as int;
      final bTotalScore = b['totalPassCount'] as int;
      final aLastPassTime = a['lastPassTime'] as Timestamp?;
      final bLastPassTime = b['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore && aLastPassTime != null && bLastPassTime != null) {
        return bLastPassTime.compareTo(aLastPassTime);
      }
      return bTotalScore.compareTo(aTotalScore);
    });
  }

  List<QueryDocumentSnapshot> processRankingSnapshot(QuerySnapshot snapshot) {
    Map<String, List<DocumentSnapshot>> groupedData = {};

    for (var doc in snapshot.docs) {
      final uid = doc['uid'] as String;
      if (!groupedData.containsKey(uid)) {
        groupedData[uid] = [];
      }
      groupedData[uid]?.add(doc);
    }

    return groupedData.entries.map((entry) {
      entry.value.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      return entry.value[0] as QueryDocumentSnapshot;
    }).toList();
  }

  //TODO: 개인 랭킹독 가져오는 메소드********************************************



  //TODO: 크루 랭킹독 가져오는 메소드********************************************

  Future<void> getRankingDocs_crew({required baseResort}) async{

    List<QueryDocumentSnapshot> rankingList = [];
    List<QueryDocumentSnapshot> rankingList_kusbf=[];

    QuerySnapshot rankingSnapshot_crew = await  FirebaseFirestore.instance
        .collection('liveCrew')
        .where('baseResort', isEqualTo: baseResort)
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .get();
    rankingList = rankingSnapshot_crew.docs;

    if(baseResort == 12) {
      QuerySnapshot rankingSnapshot_crew_kusbf = await FirebaseFirestore.instance
          .collection('liveCrew')
          .where('kusbf', isEqualTo: true)
          .where('baseResort', isEqualTo: baseResort)
          .where('totalScore', isGreaterThan: 0)
          .orderBy('totalScore', descending: true)
          .get();
      rankingList_kusbf = rankingSnapshot_crew_kusbf.docs;

      rankingList_kusbf.sort((a, b) {
        final aTotalScore = a['totalScore'] as int;
        final bTotalScore = b['totalScore'] as int;
        final aLastPassTime = a['lastPassTime'] as Timestamp?;
        final bLastPassTime = b['lastPassTime'] as Timestamp?;

        if (aTotalScore == bTotalScore) {
          if (aLastPassTime != null && bLastPassTime != null) {
            return bLastPassTime.compareTo(aLastPassTime);
          }
        }

        return bTotalScore.compareTo(aTotalScore);
      });

    }else{}

    rankingList.sort((a, b) {
      final aTotalScore = a['totalScore'] as int;
      final bTotalScore = b['totalScore'] as int;
      final aLastPassTime = a['lastPassTime'] as Timestamp?;
      final bLastPassTime = b['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore) {
        if (aLastPassTime != null && bLastPassTime != null) {
          return bLastPassTime.compareTo(aLastPassTime);
        }
      }

      return bTotalScore.compareTo(aTotalScore);
    });

    this._rankingDocs_crew!.value = rankingList.map((doc) {
      // 각 문서의 데이터를 Map 형태로 변환
      return doc.data() as Map<String, dynamic>;
    }).toList();
    this._rankingDocs_crew_kusbf!.value = rankingList_kusbf.map((doc) {
      // 각 문서의 데이터를 Map 형태로 변환
      return doc.data() as Map<String, dynamic>;
    }).toList();
    this._crewRankingMap!.value = await calculateRankCrewAll2(crewDocs: _rankingDocs_crew);
    this._crewRankingMap_kusbf!.value = await calculateRankCrewAll2(crewDocs: _rankingDocs_crew_kusbf);


    print('대학연합 랭킹참여 크루 : ${_rankingDocs_kusbf!.length}');
    print('일반 랭킹참여 크루 : ${_rankingDocs!.length}');

  }

  Future<void> getRankingDocs_crew_Daily({required baseResort}) async{

    List<QueryDocumentSnapshot> rankingList = [];
    List<QueryDocumentSnapshot> rankingList_kusbf=[];

    String today = DateFormat('yyyyMMdd').format(DateTime.now());

    QuerySnapshot rankingSnapshot_crew = await  FirebaseFirestore.instance
        .collection('Ranking_Crew_Daily')
        .doc('1')
        .collection('${_seasonController.currentSeason}')
        .where('baseResort', isEqualTo: baseResort)
        .where('date', isEqualTo: today)
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .get();
    rankingList = rankingSnapshot_crew.docs;

    if(baseResort == 12) {
      QuerySnapshot rankingSnapshot_crew_kusbf = await FirebaseFirestore.instance
          .collection('Ranking_Crew_Daily')
          .doc('1')
          .collection('${_seasonController.currentSeason}')
          .where('kusbf', isEqualTo: true)
          .where('baseResort', isEqualTo: baseResort)
          .where('totalScore', isGreaterThan: 0)
          .orderBy('totalScore', descending: true)
          .get();
      rankingList_kusbf = rankingSnapshot_crew_kusbf.docs;

      rankingList_kusbf.sort((a, b) {
        final aTotalScore = a['totalScore'] as int;
        final bTotalScore = b['totalScore'] as int;
        final aLastPassTime = a['lastPassTime'] as Timestamp?;
        final bLastPassTime = b['lastPassTime'] as Timestamp?;

        if (aTotalScore == bTotalScore) {
          if (aLastPassTime != null && bLastPassTime != null) {
            return bLastPassTime.compareTo(aLastPassTime);
          }
        }

        return bTotalScore.compareTo(aTotalScore);
      });

    }else{}

    rankingList.sort((a, b) {
      final aTotalScore = a['totalScore'] as int;
      final bTotalScore = b['totalScore'] as int;
      final aLastPassTime = a['lastPassTime'] as Timestamp?;
      final bLastPassTime = b['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore) {
        if (aLastPassTime != null && bLastPassTime != null) {
          return bLastPassTime.compareTo(aLastPassTime);
        }
      }

      return bTotalScore.compareTo(aTotalScore);
    });

    this._rankingDocs_crew_daily!.value = rankingList.map((doc) {
      // 각 문서의 데이터를 Map 형태로 변환
      return doc.data() as Map<String, dynamic>;
    }).toList();
    this._rankingDocs_crew_kusbf_daily!.value = rankingList_kusbf.map((doc) {
      // 각 문서의 데이터를 Map 형태로 변환
      return doc.data() as Map<String, dynamic>;
    }).toList();
    this._crewRankingMap_daily!.value = await calculateRankCrewAll2(crewDocs: _rankingDocs_crew_daily);
    this._crewRankingMap_kusbf_daily!.value = await calculateRankCrewAll2(crewDocs: _rankingDocs_crew_kusbf_daily);


    print('대학연합 일간 랭킹참여 크루 : ${_rankingDocs_crew_kusbf_daily!.length}');
    print('일간 랭킹참여 크루 : ${_rankingDocs_crew_daily!.length}');

  }

  Future<void> getRankingDocs_crew_Weekly({required baseResort}) async{

    List<QueryDocumentSnapshot> rankingList = [];
    List<QueryDocumentSnapshot> rankingList_kusbf=[];

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
    List<String> thisWeekDates = [];

    for (DateTime date = startOfWeek; date.isBefore(endOfWeek); date = date.add(Duration(days: 1))) {
      String formattedDate = DateFormat('yyyyMMdd').format(date);
      thisWeekDates.add(formattedDate);
    }
    print(thisWeekDates);

    QuerySnapshot rankingSnapshot_crew = await  FirebaseFirestore.instance
        .collection('Ranking_Crew_Daily')
        .doc('1')
        .collection('${_seasonController.currentSeason}')
        .where('date', whereIn: thisWeekDates)
        .where('baseResort', isEqualTo: baseResort)
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .get();

    Map<String, List<DocumentSnapshot>> groupedData = {};

    for (var doc in rankingSnapshot_crew.docs) {
      final crewID = doc['crewID'] as String;
      if (!groupedData.containsKey(crewID)) {
        groupedData[crewID] = [];
      }
      groupedData[crewID]?.add(doc);
    }

    // 각 그룹 내에서 date 필드를 기준으로 소팅하여 최신 데이터를 선택합니다.
    List<DocumentSnapshot> finalRankingList = [];

    groupedData.forEach((uid, documents) {
      documents.sort((a, b) {
        final aDate = a['date'] as String;
        final bDate = b['date'] as String;
        return bDate.compareTo(aDate);
      });
      finalRankingList.add(documents[0]); // 최신 데이터를 선택하여 결과 목록에 추가합니다.
    });

    rankingList = finalRankingList.cast<QueryDocumentSnapshot<Object?>>();


    if(baseResort == 12) {
      QuerySnapshot rankingSnapshot_crew_kusbf = await FirebaseFirestore.instance
          .collection('Ranking_Crew_Daily')
          .doc('1')
          .collection('${_seasonController.currentSeason}')
          .where('date', whereIn: thisWeekDates)
          .where('kusbf', isEqualTo: true)
          .where('baseResort', isEqualTo: baseResort)
          .where('totalScore', isGreaterThan: 0)
          .orderBy('totalScore', descending: true)
          .get();
      rankingList_kusbf = rankingSnapshot_crew_kusbf.docs;

      rankingList_kusbf.sort((a, b) {
        final aTotalScore = a['totalScore'] as int;
        final bTotalScore = b['totalScore'] as int;
        final aLastPassTime = a['lastPassTime'] as Timestamp?;
        final bLastPassTime = b['lastPassTime'] as Timestamp?;

        if (aTotalScore == bTotalScore) {
          if (aLastPassTime != null && bLastPassTime != null) {
            return bLastPassTime.compareTo(aLastPassTime);
          }
        }

        return bTotalScore.compareTo(aTotalScore);
      });

    }else{}

    rankingList.sort((a, b) {
      final aTotalScore = a['totalScore'] as int;
      final bTotalScore = b['totalScore'] as int;
      final aLastPassTime = a['lastPassTime'] as Timestamp?;
      final bLastPassTime = b['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore) {
        if (aLastPassTime != null && bLastPassTime != null) {
          return bLastPassTime.compareTo(aLastPassTime);
        }
      }

      return bTotalScore.compareTo(aTotalScore);
    });

    this._rankingDocs_crew_weekly!.value = rankingList.map((doc) {
      // 각 문서의 데이터를 Map 형태로 변환
      return doc.data() as Map<String, dynamic>;
    }).toList();
    this._rankingDocs_crew_kusbf_weekly!.value = rankingList_kusbf.map((doc) {
      // 각 문서의 데이터를 Map 형태로 변환
      return doc.data() as Map<String, dynamic>;
    }).toList();
    this._crewRankingMap_weekly!.value = await calculateRankCrewAll2(crewDocs: _rankingDocs_crew_weekly);
    this._crewRankingMap_kusbf_weekly!.value = await calculateRankCrewAll2(crewDocs: _rankingDocs_crew_kusbf_weekly);


    print('대학연합 주간 랭킹참여 크루 : ${_rankingDocs_crew_kusbf_weekly!.length}');
    print('주간 랭킹참여 크루 : ${_rankingDocs_crew_weekly!.length}');

  }

  Future<void> getRankingDocs_crew_integrated() async {
    List<QueryDocumentSnapshot> rankingList = [];

    QuerySnapshot rankingSnapshot_crew = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('totalPassCount', isGreaterThan: 0)
        .orderBy('totalPassCount', descending: true)
        .get();

    // favoriteResort가 0, 2, 12가 아닌 문서만 필터링
    rankingList = rankingSnapshot_crew.docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      var baseResort = data['baseResort'];
      return ![0, 2, 12].contains(baseResort);
    }).toList();

    // 정렬 로직은 동일하게 유지
    rankingList.sort((a, b) {
      final aTotalScore = a['totalPassCount'] as int;
      final bTotalScore = b['totalPassCount'] as int;
      final aLastPassTime = a['lastPassTime'] as Timestamp?;
      final bLastPassTime = b['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore) {
        if (aLastPassTime != null && bLastPassTime != null) {
          return bLastPassTime.compareTo(aLastPassTime);
        }
      }

      return bTotalScore.compareTo(aTotalScore);
    });

    this._rankingDocs_crew_integrated!.value = rankingList.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    this._crewRankingMap_integrated!.value = await calculateRankCrewAll2_integrated(crewDocs: _rankingDocs_crew_integrated);

    print('통합랭킹 참여 크루 : ${_rankingDocs_crew_integrated!.length}');
  }

  Future<void> getRankingDocs_crew_integrated_Daily() async {
    List<QueryDocumentSnapshot> rankingList = [];

    QuerySnapshot rankingSnapshot_crew = await FirebaseFirestore.instance
        .collection('Ranking_Crew_Daily')
        .doc('1')
        .collection('${_seasonController.currentSeason}')
        .where('totalPassCount', isGreaterThan: 0)
        .orderBy('totalPassCount', descending: true)
        .get();

    // favoriteResort가 0, 2, 12가 아닌 문서만 필터링
    rankingList = rankingSnapshot_crew.docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      var baseResort = data['baseResort'];
      return ![0, 2, 12].contains(baseResort);
    }).toList();

    // 정렬 로직은 동일하게 유지
    rankingList.sort((a, b) {
      final aTotalScore = a['totalPassCount'] as int;
      final bTotalScore = b['totalPassCount'] as int;
      final aLastPassTime = a['lastPassTime'] as Timestamp?;
      final bLastPassTime = b['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore) {
        if (aLastPassTime != null && bLastPassTime != null) {
          return bLastPassTime.compareTo(aLastPassTime);
        }
      }

      return bTotalScore.compareTo(aTotalScore);
    });

    this._rankingDocs_crew_integrated_weekly!.value = rankingList.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    this._crewRankingMap_integrated_weekly!.value = await calculateRankCrewAll2_integrated(crewDocs: _rankingDocs_crew_integrated_weekly);

    print('통합랭킹 참여 크루 : ${_rankingDocs_crew_integrated_weekly!.length}');
  }

  Future<void> getRankingDocs_crew_integrated_Weekly() async {
    List<QueryDocumentSnapshot> rankingList = [];

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
    List<String> thisWeekDates = [];

    for (DateTime date = startOfWeek; date.isBefore(endOfWeek); date = date.add(Duration(days: 1))) {
      String formattedDate = DateFormat('yyyyMMdd').format(date);
      thisWeekDates.add(formattedDate);
    }
    print(thisWeekDates);

    QuerySnapshot rankingSnapshot_crew = await FirebaseFirestore.instance
        .collection('Ranking_Crew_Daily')
        .doc('1')
        .collection('${_seasonController.currentSeason}')
        .where('date', whereIn: thisWeekDates)
        .where('totalPassCount', isGreaterThan: 0)
        .orderBy('totalPassCount', descending: true)
        .get();

    Map<String, List<DocumentSnapshot>> groupedData = {};

    for (var doc in rankingSnapshot_crew.docs) {
      final crewID = doc['crewID'] as String;
      if (!groupedData.containsKey(crewID)) {
        groupedData[crewID] = [];
      }
      groupedData[crewID]?.add(doc);
    }

    // 각 그룹 내에서 date 필드를 기준으로 소팅하여 최신 데이터를 선택합니다.
    List<DocumentSnapshot> finalRankingList = [];

    groupedData.forEach((uid, documents) {
      documents.sort((a, b) {
        final aDate = a['date'] as String;
        final bDate = b['date'] as String;
        return bDate.compareTo(aDate);
      });
      finalRankingList.add(documents[0]); // 최신 데이터를 선택하여 결과 목록에 추가합니다.
    });

    rankingList = finalRankingList.cast<QueryDocumentSnapshot<Object?>>();

    // favoriteResort가 0, 2, 12가 아닌 문서만 필터링
    rankingList = rankingSnapshot_crew.docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;
      var baseResort = data['baseResort'];
      return ![0, 2, 12].contains(baseResort);
    }).toList();

    // 정렬 로직은 동일하게 유지
    rankingList.sort((a, b) {
      final aTotalScore = a['totalPassCount'] as int;
      final bTotalScore = b['totalPassCount'] as int;
      final aLastPassTime = a['lastPassTime'] as Timestamp?;
      final bLastPassTime = b['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore) {
        if (aLastPassTime != null && bLastPassTime != null) {
          return bLastPassTime.compareTo(aLastPassTime);
        }
      }

      return bTotalScore.compareTo(aTotalScore);
    });

    this._rankingDocs_crew_integrated_weekly!.value = rankingList.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    this._crewRankingMap_integrated_weekly!.value = await calculateRankCrewAll2_integrated(crewDocs: _rankingDocs_crew_integrated_weekly);

    print('통합랭킹 참여 크루 : ${_rankingDocs_crew_integrated_weekly!.length}');
  }

  Future<void> getRankingDocs_crewMember_integrated({required crewID, required crewBase}) async{

    List<Map<String, dynamic>> rankingList = [];

    QuerySnapshot rankingSnapshot_crewMember = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewID', isEqualTo: crewID)
        .get();

    List<dynamic> memberList = [];
    for (var doc in rankingSnapshot_crewMember.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('memberUidList')) {
        List<dynamic> members = data['memberUidList'];
        memberList.addAll(members);
      }
    }

    final AllUserScoreDocs = _rankingDocs_integrated;

    List<Map<String, dynamic>> allUserScoreData = AllUserScoreDocs!.map((doc) {
      return doc as Map<String, dynamic>;
    }).toList();

    rankingList = allUserScoreData.where((doc) =>
        memberList.contains(doc['uid'])).toList();
    // 동점자인 경우 lastPassTime을 기준으로 최신 순으로 정렬
    rankingList.sort((a, b) {
      final aTotalScore = a['totalPassCount'] as int;
      final bTotalScore = b['totalPassCount'] as int;
      final aLastPassTime = a['lastPassTime'] as Timestamp?;
      final bLastPassTime = b['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore) {
        if (aLastPassTime != null && bLastPassTime != null) {
          return bLastPassTime.compareTo(aLastPassTime);
        }
      }

      return bTotalScore.compareTo(aTotalScore);
    });

    this._rankingDocs_crewMember_integrated!.value = rankingList.map((doc) {
      // 각 문서의 데이터를 Map 형태로 변환
      return doc ;
    }).toList();

    print('크루 랭킹인원 : ${_rankingDocs_crewMember_integrated!.length}');

  }

  Future<void> getRankingDocs_crewMember({required crewID, required crewBase}) async{

    List<Map<String, dynamic>> rankingList = [];

    QuerySnapshot rankingSnapshot_crewMember = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewID', isEqualTo: crewID)
        .get();

    List<dynamic> memberList = [];
    for (var doc in rankingSnapshot_crewMember.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('memberUidList')) {
        List<dynamic> members = data['memberUidList'];
        memberList.addAll(members);
      }
    }

    QuerySnapshot rankingSnapshot = await  FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${crewBase}')
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .get();

    final AllUserScoreDocs = rankingSnapshot.docs;

    List<Map<String, dynamic>> allUserScoreData = AllUserScoreDocs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();


    rankingList = allUserScoreData.where((doc) =>
        memberList.contains(doc['uid'])).toList();
    // 동점자인 경우 lastPassTime을 기준으로 최신 순으로 정렬
    rankingList.sort((a, b) {
      final aTotalScore = a['totalScore'] as int;
      final bTotalScore = b['totalScore'] as int;
      final aLastPassTime = a['lastPassTime'] as Timestamp?;
      final bLastPassTime = b['lastPassTime'] as Timestamp?;

      if (aTotalScore == bTotalScore) {
        if (aLastPassTime != null && bLastPassTime != null) {
          return bLastPassTime.compareTo(aLastPassTime);
        }
      }

      return bTotalScore.compareTo(aTotalScore);
    });

    this._rankingDocs_crewMember!.value = rankingList.map((doc) {
      // 각 문서의 데이터를 Map 형태로 변환
      return doc as Map<String, dynamic>;
    }).toList();

    print('크루 랭킹인원 : ${_rankingDocs_crewMember!.length}');

  }

  //TODO: 크루 랭킹독 가져오는 메소드********************************************



  //TODO: 티어 뱃지 가져오는 메소드********************************************

  Future<void> updateTier()async{

    double? percent;
    int? totalScore;
    String? tier;

    QuerySnapshot rankingSnapshot = await FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${_userModelController.favoriteResort}')
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .get();

    final rankingDocs = rankingSnapshot.docs;

    // 내 UID와 일치하는 데이터 찾기
    var myData;
    for (var doc in rankingDocs) {
      if (doc.id == _userModelController.uid) {
        myData = doc;
        break;
      }
    }
    // 내 순위 찾기
    int myRank = rankingDocs.indexOf(myData) + 1;
    int totalRankCount = rankingDocs.length;

    percent = myRank/totalRankCount;
    totalScore = myData['totalScore'];
    print('등수 : $myRank');
    print('퍼센트 : $percent');
    print('스코어 : $totalScore');


    if(percent <= rankingTierList[0].scoreRng && totalScore! >= rankingTierList[0].totalScore ){
      tier = 'S';
    }else if(percent <= rankingTierList[1].scoreRng && totalScore! >= rankingTierList[1].totalScore ){
      tier = 'A';
    }else if(percent <= rankingTierList[2].scoreRng && totalScore! >= rankingTierList[2].totalScore ){
      tier = 'B';
    }else if(percent <= rankingTierList[3].scoreRng && totalScore! >= rankingTierList[3].totalScore ){
      tier = 'C';
    }else {
      tier = 'D';
    }

    print('티어 : $tier');

    await ref.collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${_userModelController.favoriteResort}')
        .doc(_userModelController.uid).update({
      'tier': tier,
    },);

  }

  String getBadgeAsset({required double percent,required int totalScore,required List rankingTierList}) {
    for (var tier in rankingTierList) {
      if (percent <= tier.scoreRng && totalScore >= tier.totalScore) {
        return tier.badgeAsset;
      }
    }
    return rankingTierList.last.badgeAsset; // 가장 낮은 순위의 뱃지
  }

  String getBadgeAsset_integrated({required double percent,required int totalPassCount,required List rankingTierList}) {
    for (var tier in rankingTierList_integrated) {
      if (percent <= tier.scoreRng && totalPassCount >= tier.totalScore) {
        return tier.badgeAsset;
      }
    }
    return rankingTierList.last.badgeAsset; // 가장 낮은 순위의 뱃지
  }

  //TODO: 티어 뱃지 가져오는 메소드********************************************


  //TODO: 랭킹 계산하는 메소드********************************************

  Map<String, int> calculateRankIndiAll2({required userRankingDocs}){

    Map<String, int> userRankingMap = {};

    for (int i = 0; i < userRankingDocs.length; i++) {
      if (userRankingDocs[i] != null) {
        if (i == 0) {
          userRankingMap['${userRankingDocs[i]['uid']}'] = i+1;
        } else if(userRankingDocs[i]['totalScore'] != userRankingDocs[i-1]['totalScore']){
          userRankingMap['${userRankingDocs[i]['uid']}'] = i+1;
        } else if(userRankingDocs[i]['totalScore'] == userRankingDocs[i-1]['totalScore']){
          userRankingMap['${userRankingDocs[i]['uid']}'] = userRankingMap['${userRankingDocs[i-1]['uid']}']!;
        }
      }
    }
    return userRankingMap;
  }

  Map<String, int> calculateRankCrewAll2({required crewDocs})  {

    Map<String, int> crewRankingMap = {};

    for (int i = 0; i < crewDocs.length; i++) {
      if (crewDocs[i] != null) {
        if (i == 0) {
          crewRankingMap['${crewDocs[i]['crewID']}'] = i+1;
        } else if(crewDocs[i]['totalScore'] != crewDocs[i-1]['totalScore']){
          crewRankingMap['${crewDocs[i]['crewID']}'] = i+1;
        } else if(crewDocs[i]['totalScore'] == crewDocs[i-1]['totalScore']){
          crewRankingMap['${crewDocs[i]['crewID']}'] = crewRankingMap['${crewDocs[i-1]['crewID']}']!;
        }
      }
    }

    return crewRankingMap;
  }

  Map<String, int> calculateRankIndiAll2_integrated({required userRankingDocs}){

    Map<String, int> userRankingMap = {};

    for (int i = 0; i < userRankingDocs.length; i++) {
      if (userRankingDocs[i] != null) {
        if (i == 0) {
          userRankingMap['${userRankingDocs[i]['uid']}'] = i+1;
        } else if(userRankingDocs[i]['totalPassCount'] != userRankingDocs[i-1]['totalPassCount']){
          userRankingMap['${userRankingDocs[i]['uid']}'] = i+1;
        } else if(userRankingDocs[i]['totalPassCount'] == userRankingDocs[i-1]['totalPassCount']){
          userRankingMap['${userRankingDocs[i]['uid']}'] = userRankingMap['${userRankingDocs[i-1]['uid']}']!;
        }
      }
    }
    return userRankingMap;
  }

  Map<String, int> calculateRankCrewAll2_integrated({required crewDocs})  {

    Map<String, int> crewRankingMap = {};

    for (int i = 0; i < crewDocs.length; i++) {
      if (crewDocs[i] != null) {
        if (i == 0) {
          crewRankingMap['${crewDocs[i]['crewID']}'] = i+1;
        } else if(crewDocs[i]['totalPassCount'] != crewDocs[i-1]['totalPassCount']){
          crewRankingMap['${crewDocs[i]['crewID']}'] = i+1;
        } else if(crewDocs[i]['totalPassCount'] == crewDocs[i-1]['totalPassCount']){
          crewRankingMap['${crewDocs[i]['crewID']}'] = crewRankingMap['${crewDocs[i-1]['crewID']}']!;
        }
      }
    }

    return crewRankingMap;
  }

  //TODO: 랭킹 계산하는 메소드********************************************


}

