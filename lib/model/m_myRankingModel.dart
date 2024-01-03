import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/vm_seasonController.dart';
import '../controller/vm_userModelController.dart';

class MyRankingModel {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  //TODO: Dependency Injection**************************************************

  MyRankingModel({
    this.lastPassTime,
    this.passCountData,
    this.passCountTimeData,
    this.slopeScores,
    this.tier,
    this.totalPassCount,
    this.totalScore,
    this.uid,
    this.exist,
    this.totalPassCountWeekly,
    this.totalScoreWeekly
  });

  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;
  DocumentReference? reference;

  Timestamp? lastPassTime;
  Map? passCountData;
  Map? passCountTimeData;
  Map? slopeScores;
  String? tier;
  int? totalPassCount;
  int? totalScore;
  String? uid;
  bool? exist;
  int? totalPassCountWeekly;
  int? totalScoreWeekly;

  MyRankingModel.fromJson(dynamic json, this.reference) {
    lastPassTime = json['lastPassTime'];
    passCountData = json['passCountData'];
    passCountTimeData = json['passCountTimeData'];
    slopeScores = json['slopeScores'];
    tier = json['tier'];
    totalPassCount = json['totalPassCount'];
    totalScore = json['totalScore'];
    uid = json['uid'];
    exist = true;
    totalPassCountWeekly = json['totalPassCountWeekly'];
    totalScoreWeekly = json['totalScoreWeekly'];
    print('점수 가져오기 성공');
  }

  MyRankingModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      :this.fromJson(snapshot.data(), snapshot.reference);

  Future<MyRankingModel?> getMyRankingModel(String uid) async {

    if (uid != null) {

      try {
        DocumentReference<Map<String, dynamic>> documentReference =
        ref.collection('Ranking')
            .doc('${_seasonController.currentSeason}')
            .collection('${_userModelController.favoriteResort}')
            .doc('$uid');
        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
        if (documentSnapshot.exists) {
          MyRankingModel myRankingModel = MyRankingModel.fromSnapShot(documentSnapshot);
          return myRankingModel;
        } else{
          exist = false;
        }
      }catch(e){

      }
    }
    return null;
  }

  Future<MyRankingModel?> getMyRankingModel_Daily(String uid) async {
    if (uid != null) {
      try {

        String today = DateFormat('yyyyMMdd').format(DateTime.now());

        QuerySnapshot<Map<String, dynamic>> querySnapshot = await ref
            .collection('Ranking_Daily')
            .doc('${_seasonController.currentSeason}')
            .collection('${_userModelController.favoriteResort}')
            .where('date', isEqualTo: today)
            .where('uid', isEqualTo: '${uid}')
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          MyRankingModel myRankingModel =
          MyRankingModel.fromJson(querySnapshot.docs.first.data(), null);
          return myRankingModel;
        } else {
          exist = false;
        }
      } catch (e) {
        // 오류 처리를 여기서 수행하세요.
      }
    }
    return null;
  }

  Future<MyRankingModel?> getMyRankingModel_Weekly(String uid) async {
    if (uid != null) {
      try {
        String today = DateFormat('yyyyMMdd').format(DateTime.now());

        DateTime now = DateTime.now();
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
        List<String> thisWeekDates = [];

        for (DateTime date = startOfWeek; date.isBefore(endOfWeek); date = date.add(Duration(days: 1))) {
          String formattedDate = DateFormat('yyyyMMdd').format(date);
          thisWeekDates.add(formattedDate);
        }

        QuerySnapshot<Map<String, dynamic>> querySnapshot = await ref
            .collection('Ranking_Daily')
            .doc('${_seasonController.currentSeason}')
            .collection('${_userModelController.favoriteResort}')
            .where('date', whereIn: thisWeekDates)
            .where('uid', isEqualTo: '${uid}')
            .orderBy('lastPassTime', descending: true) // date 필드를 기준으로 내림차순 정렬
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          MyRankingModel myRankingModel =
          MyRankingModel.fromJson(querySnapshot.docs.first.data(), null);
          return myRankingModel;
        } else {
          exist = false;
        }
      } catch (e) {
        // 오류 처리를 여기서 수행하세요.
      }
    }
    return null;
  }




}

