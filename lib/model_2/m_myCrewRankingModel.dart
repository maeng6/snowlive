import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/public/vm_limitController.dart';
import '../controller/user/vm_userModelController.dart';

class MyCrewRankingModel {
  UserModelController _userModelController = Get.find<UserModelController>();
  limitController _seasonController = Get.find<limitController>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference? reference;

  Timestamp? lastPassTime;
  Map? passCountData;
  Map? passCountTimeData;
  Map? slopeScores;
  int? totalPassCount;
  int? totalScore;
  int? totalPassCountWeekly;
  int? totalScoreWeekly;
  int? baseResort;
  String? baseResortNickName;
  int? crewColor;
  String? crewID;
  String? crewLeader;
  String? crewName;
  String? date;
  String? description;
  bool? kusbf;
  String? leaderUid;
  String? profileImageUrl;

  MyCrewRankingModel({
    this.lastPassTime,
    this.passCountData,
    this.passCountTimeData,
    this.slopeScores,
    this.totalPassCount,
    this.totalScore,
    this.totalPassCountWeekly,
    this.totalScoreWeekly,
    this.baseResort,
    this.baseResortNickName,
    this.crewColor,
    this.crewID,
    this.crewLeader,
    this.crewName,
    this.date,
    this.description,
    this.kusbf,
    this.leaderUid,
    this.profileImageUrl,
  });

  MyCrewRankingModel.fromJson(dynamic json, this.reference) {
    lastPassTime = json['lastPassTime'];
    passCountData = json['passCountData'];
    passCountTimeData = json['passCountTimeData'];
    slopeScores = json['slopeScores'];
    totalPassCount = json['totalPassCount'];
    totalScore = json['totalScore'];
    totalPassCountWeekly = json['totalPassCountWeekly'];
    totalScoreWeekly = json['totalScoreWeekly'];
    baseResort = json['baseResort'];
    baseResortNickName = json['baseResortNickName'];
    crewColor = json['crewColor'];
    crewID = json['crewID'];
    crewLeader = json['crewLeader'];
    crewName = json['crewName'];
    date = json['date'];
    description = json['description'];
    kusbf = json['kusbf'];
    leaderUid = json['leaderUid'];
    profileImageUrl = json['profileImageUrl'];
    print('점수 가져오기 성공');
  }

  MyCrewRankingModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data() ?? {}, snapshot.reference);

  Future<MyCrewRankingModel?> getMyCrewRankingModel(String crewID) async {
    try {
      if (crewID != null) {
        final querySnapshot = await _firestore
            .collection('liveCrew')
            .where('crewID', isEqualTo: crewID)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final documentSnapshot = querySnapshot.docs.first;
          return MyCrewRankingModel.fromSnapshot(documentSnapshot);
        }
      }
    } catch (e) {
      // 예외 처리를 수행하세요.
      print('getMyCrewRankingModel 오류: $e');
    }
    return null;
  }

  Future<MyCrewRankingModel?> getMyCrewRankingModel_Daily(String crewID) async {
    try {
      if (crewID != null) {
        final today = DateFormat('yyyyMMdd').format(DateTime.now());

        final querySnapshot = await _firestore
            .collection('Ranking_Crew_Daily')
            .doc('1')
            .collection('${_seasonController.currentSeason}')
            .where('date', isEqualTo: today)
            .where('crewID', isEqualTo: crewID)
            .get();


        if (querySnapshot.docs.isNotEmpty) {
          final documentSnapshot = querySnapshot.docs.first;
          print('1');
          return MyCrewRankingModel.fromSnapshot(documentSnapshot);
        }
      }
    } catch (e) {
      // 예외 처리를 수행하세요.
      print('getMyCrewRankingModel_Daily 오류: $e');
    }
    return null;
  }

  Future<MyCrewRankingModel?> getMyCrewRankingModel_Weekly(String crewID) async {
    try {
      if (crewID != null) {
        final today = DateFormat('yyyyMMdd').format(DateTime.now());
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 7));
        final thisWeekDates = <String>[];

        for (DateTime date = startOfWeek; date.isBefore(endOfWeek); date = date.add(Duration(days: 1))) {
          final formattedDate = DateFormat('yyyyMMdd').format(date);
          thisWeekDates.add(formattedDate);
        }

        final querySnapshot = await _firestore
            .collection('Ranking_Crew_Daily')
            .doc('1')
            .collection('${_seasonController.currentSeason}')
            .where('date', whereIn: thisWeekDates)
            .where('crewID', isEqualTo: crewID)
            .orderBy('lastPassTime', descending: true)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final documentSnapshot = querySnapshot.docs.first;
          return MyCrewRankingModel.fromSnapshot(documentSnapshot);
        }
      }
    } catch (e) {
      // 예외 처리를 수행하세요.
      print('getMyCrewRankingModel_Weekly 오류: $e');
    }
    return null;
  }
}
