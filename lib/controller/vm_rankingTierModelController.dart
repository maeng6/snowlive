import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/model/m_rankingTierModel.dart';

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
  int? tier;

  QuerySnapshot rankingSnapshot = await FirebaseFirestore.instance
      .collection('Ranking')
      .doc('${_seasonController.currentSeason}')
      .collection('${_userModelController.favoriteResort}')
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
  totalScore = rankingDocs[0]['totalScore'];

  if(percent <= rankingTierList[4].scoreRng && totalScore! >= rankingTierList[4].totalScore){
    tier = 4;
  }else if(percent <= rankingTierList[3].scoreRng && totalScore! >= rankingTierList[3].totalScore){
    tier = 3;
  }else if(percent <= rankingTierList[2].scoreRng && totalScore! >= rankingTierList[2].totalScore){
    tier = 2;
  }else if(percent <= rankingTierList[1].scoreRng && totalScore! >= rankingTierList[1].totalScore){
    tier = 1;
  }else if(percent <= rankingTierList[0].scoreRng && totalScore! >= rankingTierList[0].totalScore){
    tier = 0;
  }

  await ref.collection('Ranking')
      .doc('${_seasonController.currentSeason}')
      .collection('${_userModelController.favoriteResort}')
      .doc(_userModelController.uid).update({
    'tier': tier,
  });

}

}

