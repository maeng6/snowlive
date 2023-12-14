import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_liveMapController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/model/m_rankingTierModel.dart';

class RankingTierModelController extends GetxController{

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxList? _rankingDocs=[].obs;
  RxList? _rankingDocs_integrated=[].obs;
  RxList? _rankingDocs_kusbf=[].obs;
  RxMap? _userRankingMap=<String, int>{}.obs;
  RxMap? _userRankingMap_integrated=<String, int>{}.obs;
  RxMap? _userRankingMap_kusbf=<String, int>{}.obs;

  RxList? _rankingDocs_crew=[].obs;
  RxList? _rankingDocs_crew_integrated=[].obs;
  RxList? _rankingDocs_crewMember=[].obs;
  RxList? _rankingDocs_crewMember_integrated=[].obs;
  RxList? _rankingDocs_crew_kusbf=[].obs;
  RxMap? _crewRankingMap =<String, int>{}.obs;
  RxMap? _crewRankingMap_integrated =<String, int>{}.obs;
  RxMap? _crewRankingMap_kusbf =<String, int>{}.obs;

  RxList? _kusbfAllMemberUidList=[].obs;

  List? get rankingDocs => _rankingDocs;
  List? get rankingDocs_integrated => _rankingDocs_integrated;
  List? get rankingDocs_kusbf => _rankingDocs_kusbf;
  Map? get userRankingMap => _userRankingMap;
  Map? get userRankingMap_integrated => _userRankingMap_integrated;
  Map? get userRankingMap_kusbf => _userRankingMap_kusbf;

  List? get rankingDocs_crew => _rankingDocs_crew;
  List? get rankingDocs_crew_integrated => _rankingDocs_crew_integrated;
  List? get rankingDocs_crewMember => _rankingDocs_crewMember;
  List? get rankingDocs_crewMember_integrated => _rankingDocs_crewMember_integrated;
  List? get rankingDocs_crew_kusbf => _rankingDocs_crew_kusbf;
  Map? get crewRankingMap => _crewRankingMap;
  Map? get crewRankingMap_integrated => _crewRankingMap_integrated;
  Map? get crewRankingMap_kusbf => _crewRankingMap_kusbf;

  List? get kusbfAllMemberUidList => _kusbfAllMemberUidList;

  //TODO: Dependency Injection********************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  //TODO: Dependency Injection********************************************

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


  Future<void> getRankingDocs({required baseResort}) async{

    List<QueryDocumentSnapshot> rankingList = [];
    List<QueryDocumentSnapshot> rankingList_kusbf=[];

    QuerySnapshot rankingSnapshot = await FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${baseResort}')
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .get();
    rankingList = rankingSnapshot.docs;

    if(baseResort == 12) {
      QuerySnapshot kusbfCrewSnapshot = await FirebaseFirestore.instance
          .collection('liveCrew')
          .where('kusbf', isEqualTo: true)
          .get();
      rankingList_kusbf = rankingSnapshot.docs;

      for (var doc in kusbfCrewSnapshot.docs) {
        List<dynamic> memberUidList = doc['memberUidList'];
        this._kusbfAllMemberUidList!.addAll(memberUidList);
      }

      rankingList_kusbf = rankingSnapshot.docs.where((doc) {
        final uid = doc['uid'];
        return _kusbfAllMemberUidList!.contains(uid);
      }).toList();

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

    this._rankingDocs!.value = rankingList.map((doc) {
      // 각 문서의 데이터를 Map 형태로 변환
      return doc.data() as Map<String, dynamic>;
    }).toList();
    this._rankingDocs_kusbf!.value = rankingList_kusbf.map((doc) {
      // 각 문서의 데이터를 Map 형태로 변환
      return doc.data() as Map<String, dynamic>;
    }).toList();
    this._userRankingMap!.value = await calculateRankIndiAll2(userRankingDocs: _rankingDocs);
    this._userRankingMap_kusbf!.value = await calculateRankIndiAll2(userRankingDocs: _rankingDocs_kusbf);


    print('대학연합 랭킹참여자 : ${_rankingDocs_kusbf!.length}');
    print('일반 랭킹참여자 : ${_rankingDocs!.length}');

  }

  Future<void> getRankingDocs_crew() async{

    List<QueryDocumentSnapshot> rankingList = [];
    List<QueryDocumentSnapshot> rankingList_kusbf=[];

    QuerySnapshot rankingSnapshot_crew = await  FirebaseFirestore.instance
        .collection('liveCrew')
        .where('baseResort', isEqualTo: _userModelController.favoriteResort)
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .get();
    rankingList = rankingSnapshot_crew.docs;

    if(_userModelController.favoriteResort == 12) {
      QuerySnapshot rankingSnapshot_crew_kusbf = await FirebaseFirestore.instance
          .collection('liveCrew')
          .where('kusbf', isEqualTo: true)
          .where('baseResort', isEqualTo: _userModelController.favoriteResort)
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





  Future<void> getRankingDocs_integrated() async {
    List<QueryDocumentSnapshot> rankingList = [];

    // 0부터 12까지의 리조트 ID 중 0, 2, 12를 제외한 리스트 생성
    List<int> resortIds = List.generate(13, (i) => i)..removeWhere((id) => [0, 2, 12].contains(id));

    // 각 리조트 ID에 대해 쿼리 실행
    for (int resortId in resortIds) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Ranking')
          .doc('${_seasonController.currentSeason}')
          .collection('$resortId')
          .where('totalPassCount', isGreaterThan: 0)
          .orderBy('totalPassCount', descending: true)
          .get();
      rankingList.addAll(snapshot.docs);
    }

    Map<String, QueryDocumentSnapshot> uniqueDocs = {};
    for (var doc in rankingList) {
      var data = doc.data() as Map<String, dynamic>;
      String uid = data['uid'];
      int totalPassCount = data['totalPassCount'];

      // 이미 해당 uid에 대한 문서가 있고, 현재 문서의 totalPassCount가 더 큰 경우에만 업데이트
      if (!uniqueDocs.containsKey(uid) || (uniqueDocs[uid]!['totalPassCount'] as int) < totalPassCount) {
        uniqueDocs[uid] = doc;
      }
    }
    // 중복을 제거한 문서들로 rankingList를 업데이트
    rankingList = uniqueDocs.values.toList();

    // 결과 리스트 정렬
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

    // 결과를 Map 형태로 변환 및 저장
    this._rankingDocs_integrated!.value = rankingList.map((doc) => doc.data() as Map<String, dynamic>).toList();

    this._userRankingMap_integrated!.value = await calculateRankIndiAll2_integrated(userRankingDocs: _rankingDocs_integrated);

    print('통합랭킹 참여자 : ${_rankingDocs_integrated!.length}');
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



}

