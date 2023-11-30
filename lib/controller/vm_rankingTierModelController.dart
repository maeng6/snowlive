import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/model/m_rankingTierModel.dart';

class RankingTierModelController extends GetxController{

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  //TODO: Dependency Injection********************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
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
  

  if(percent <= rankingTierList[0].scoreRng){
    tier = 'S';
  }else if(percent <= rankingTierList[1].scoreRng ){
    tier = 'A';
  }else if(percent <= rankingTierList[2].scoreRng ){
    tier = 'B';
  }else if(percent <= rankingTierList[3].scoreRng ){
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

  String getBadgeAsset(double userScore, List rankingTierList) {
    for (var tier in rankingTierList) {
      if (userScore <= tier.scoreRng) {
        return tier.badgeAsset;
      }
    }
    return rankingTierList.last.badgeAsset; // 가장 낮은 순위의 뱃지
  }


}

