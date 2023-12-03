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
  RxList? _rankingDocs_kusbf=[].obs;
  RxList? _kusbfAllMemberUidList=[].obs;
  RxMap? _userRankingMap=<String, int>{}.obs;
  RxMap? _userRankingMap_kusbf=<String, int>{}.obs;

  List? get rankingDocs => _rankingDocs;
  List? get kusbfAllMemberUidList => _kusbfAllMemberUidList;
  List? get rankingDocs_kusbf => _rankingDocs_kusbf;
  Map? get userRankingMap => _userRankingMap;
  Map? get userRankingMap_kusbf => _userRankingMap_kusbf;

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


  Future<void> getRankingDocs() async{

    List<QueryDocumentSnapshot> rankingList = [];
    List<QueryDocumentSnapshot> rankingList_kusbf=[];

    QuerySnapshot rankingSnapshot = await FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${_userModelController.favoriteResort}')
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .get();
    rankingList = rankingSnapshot.docs;

    if(_userModelController.favoriteResort == 12) {
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

    // ...

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

  Future<Map<String, int>> calculateRankCrewAll(int crewScore, String crewID) async {

    int totalCrews = 0;
    int crewRank = 0;
    int sameScoreCount = 0;
    bool foundCrew = false;
    List<QueryDocumentSnapshot> crewDocs;

    QuerySnapshot crewCollection = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('baseResort', isEqualTo: _userModelController.favoriteResort)
        .orderBy('totalScore', descending: true)
        .get();

    totalCrews = crewCollection.docs.length;
    crewDocs = crewCollection.docs;

    for (int i = 0; i < crewDocs.length; i++) {
      if (crewDocs[i].data() != null) {
        Map<String, dynamic> data = crewDocs[i].data() as Map<String, dynamic>;
        int currentScore = data['totalScore'] as int;

        if (crewDocs[i].id == crewID) {
          foundCrew = true;
        }

        if (currentScore != crewScore) {
          crewRank += sameScoreCount + 1;
          sameScoreCount = 0;
        } else {
          if (foundCrew) {
            crewRank = crewRank + 1;
            break;
          }
          sameScoreCount++;
        }
      }
    }

    if (foundCrew) {
      return {'totalCrews': totalCrews, 'rank': crewRank};
    } else {
      return {'totalCrews': totalCrews, 'rank': 0};
    }
  }


}

