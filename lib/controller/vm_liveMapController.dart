import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_rankingTierModelController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/model/m_slopeLocationModel.dart';
import 'package:snowlive3/model/m_slopeScoreModel.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

class LiveMapController extends GetxController {

  //TODO: Dependency Injection********************************************
  SeasonController _seasonController = Get.find<SeasonController>();
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection********************************************

  RxList<Marker> _markers = RxList<Marker>();

  List<Marker> get markers => _markers.toList();

  int passCount = 0;
  int? myRank;
  DateTime? lastPassTime;
  Map<String, bool> _isTapped = {};
  RxBool isLoading = false.obs;

  void initializeIsTapped() {
    _isTapped = {};
  }

  StreamSubscription<Position>? _positionStreamSubscription;

  // Future<void> updateFirebaseWithLocation(Position position) async {
  //   double latitude = position.latitude;
  //   double longitude = position.longitude;
  //
  //   if (_userModelController.uid != null) {
  //     await FirebaseFirestore.instance
  //         .collection('user')
  //         .doc(_userModelController.uid)
  //         .update({
  //       'latitude': latitude,
  //       'longitude': longitude,
  //     }).catchError((error) {
  //       print('Firestore 업데이트 에러: $error');
  //     });
  //   }
  // }

  Future<void> startForegroundLocationService() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    // 위치 서비스를 시작 (포그라운드)
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) async {
      try {
        // await updateFirebaseWithLocation(position);
        await _resortModelController.getFavoriteResort(_userModelController.favoriteResort);
        // Check if within boundary before updating pass count
        bool withinBoundary = await _updateBoundaryStatus(position);
        bool isOnLive = await checkLiveStatus();

        if (withinBoundary && isOnLive) {
          await checkAndUpdatePassCount(position).catchError((error) {
            print('점수 업데이트 오류: $error');
          });
        }

        if(!withinBoundary && _userModelController.uid != null){
          await FirebaseFirestore.instance
              .collection('user')
              .doc(_userModelController.uid)
              .set({
            'isOnLive': false,
          }, SetOptions(merge: true)).catchError((error) {
            print('Firestore 업데이트 에러: $error');
          });
          await stopForegroundLocationService();
          await stopBackgroundLocationService();
        }

      } catch (e, stackTrace) {
        print('위치 서비스 오류: $e');
        print('Stack trace: $stackTrace');
      }
    });

    try{
      await startBackgroundLocationService();
      print('백그라운드 시작');
    }catch(e, stackTrace){
      print('백그라운드 서비스 오류: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> startBackgroundLocationService() async {
    await bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        preventSuspend: true,
        heartbeatInterval: 5,
        stopOnStationary: false,
        distanceFilter: 0,
        isMoving: true,
        disableElasticity: true,
        stopOnTerminate: true,
        startOnBoot: false,
        stationaryRadius: 25,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        locationUpdateInterval: 5000,
        disableLocationAuthorizationAlert: true,
        showsBackgroundLocationIndicator: true
    ));

    await bg.BackgroundGeolocation.start();

    bg.BackgroundGeolocation.onLocation((bg.Location location) async {
      try {
        double latitude = location.coords.latitude;
        double longitude = location.coords.longitude;

        Position position = Position(
          latitude: latitude,
          longitude: longitude,
          accuracy: location.coords.accuracy,
          altitude: location.coords.altitude,
          heading: location.coords.heading,
          speed: location.coords.speed,
          speedAccuracy: location.coords.speedAccuracy,
          timestamp: DateTime.parse(location.timestamp),
        );

        // await updateFirebaseWithLocation(position);
        // Check if within boundary before updating pass count
        bool withinBoundary = await _updateBoundaryStatus(position);
        bool isOnLive = await checkLiveStatus();

        if (withinBoundary && isOnLive) {
          await checkAndUpdatePassCount(position).catchError((error) {
            print('점수 업데이트 오류: $error');
          });
        }

        if(!withinBoundary && _userModelController.uid != null){
          await FirebaseFirestore.instance
              .collection('user')
              .doc(_userModelController.uid)
              .set({
            'isOnLive': false,
          }, SetOptions(merge: true)).catchError((error) {
            print('Firestore 업데이트 에러: $error');
          });
          await stopForegroundLocationService();
          await stopBackgroundLocationService();
        }

      } catch (e, stackTrace) {
        print('백그라운드 위치 업데이트 오류: $e');
        print('Stack trace: $stackTrace');
      }
    });
  }

  // Future<void> checkAndUpdatePassCount(Position position) async {
  //   await _seasonController.getCurrentSeason();
  //
  //   for (LocationModel location in locations) {
  //     double distanceInMeters = Geolocator.distanceBetween(
  //       position.latitude,
  //       position.longitude,
  //       location.coordinates.latitude,
  //       location.coordinates.longitude,
  //     );
  //
  //     bool withinBoundary = distanceInMeters <= 100;
  //
  //     if (withinBoundary) {
  //       DateTime now = DateTime.now();
  //
  //       if (_userModelController.uid != null) {
  //         DocumentReference docRef = FirebaseFirestore.instance
  //             .collection('Ranking')
  //             .doc('${_seasonController.currentSeason}')
  //             .collection('${_userModelController.favoriteResort}')
  //             .doc("${_userModelController.uid}");
  //
  //         try {
  //           DocumentSnapshot userSnapshot = await docRef.get();
  //
  //           if (!userSnapshot.exists) {
  //             // Document doesn't exist. Let's create it!
  //             await docRef.set({
  //               'uid': _userModelController.uid,
  //               'passCountData': {},
  //               'lastPassTime': null,
  //               'slopeScores': {},
  //               'totalScore': 0,
  //             });
  //
  //             // Re-fetch the document after creating it
  //             userSnapshot = await docRef.get();
  //           }
  //
  //           // Now, we are sure the document exists. Let's proceed with the rest of the logic.
  //           Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
  //           Map<String, dynamic> passCountData = data['passCountData'] ?? {};
  //
  //           int storedPassCount = passCountData[location.name] ?? 0;
  //           DateTime? storedLastPassTime = data['lastPassTime'] != null
  //               ? (data['lastPassTime'] as Timestamp).toDate()
  //               : null;
  //
  //           if (storedLastPassTime == null || now.difference(storedLastPassTime).inMinutes >= 10) {
  //             storedPassCount += 1;
  //             DateTime lastPassTime = now;
  //
  //             // Update passCountData
  //             passCountData[location.name] = storedPassCount;
  //             data['passCountData'] = passCountData;
  //
  //             // Calculate slope score
  //             int slopeScore = slopeScoresModel.slopeScores[location.name] ?? 0;
  //             int updatedScore = slopeScore * storedPassCount;
  //
  //             // Update slopeScores
  //             Map<String, dynamic> slopeScores = data['slopeScores'] ?? {};
  //             slopeScores[location.name] = updatedScore;
  //             data['slopeScores'] = slopeScores;
  //
  //             // Calculate total score
  //             int totalScore = slopeScores.values.fold<int>(0, (int sum, dynamic score) => sum + (score as int? ?? 0));
  //             data['totalScore'] = totalScore;
  //
  //             data['lastPassTime'] = lastPassTime;
  //
  //             // Update document using data
  //             await docRef.set(data, SetOptions(merge: true));
  //
  //             // Update the same data to the 'crew' collection
  //             await updateCrewData(location.name, slopeScore);
  //           }
  //         } catch (error, stackTrace) {
  //           print('Firestore 업데이트 에러: $error');
  //           print('Stack trace: $stackTrace');
  //           // 여기서 추가적인 예외 처리나 로깅을 수행할 수 있습니다.
  //         }
  //       }
  //     }
  //   }
  // }

  Future<void> checkAndUpdatePassCount(Position position) async {
    await _seasonController.getCurrentSeason();

    for (LocationModel location in locations) {
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        location.coordinates.latitude,
        location.coordinates.longitude,
      );

      bool withinBoundary = distanceInMeters <= 100;

      if (withinBoundary) {
        DateTime now = DateTime.now();

        if (_userModelController.uid != null) {
          DocumentReference docRef = FirebaseFirestore.instance
              .collection('Ranking')
              .doc('${_seasonController.currentSeason}')
              .collection('${_userModelController.favoriteResort}')
              .doc("${_userModelController.uid}");

          try {
            DocumentSnapshot userSnapshot = await docRef.get();

            if (!userSnapshot.exists) {
              // Document doesn't exist. Let's create it!
              await docRef.set({
                'uid': _userModelController.uid,
                'passCountData': {},
                'totalPassCount': 0,
                'lastPassTime': null,
                'passCountTimeData': {
                  '1': 0,
                  '2': 0,
                  '3': 0,
                  '4': 0,
                  '5': 0,
                  '6': 0,
                  '7': 0,
                  '8': 0,
                  '9': 0,
                  '10': 0,
                  '11': 0,
                  '12': 0,
                },
                'slopeScores': {},
                'totalScore': 0,
                'tier': ''
              });

              // Re-fetch the document after creating it
              userSnapshot = await docRef.get();
            }

            // Now, we are sure the document exists. Let's proceed with the rest of the logic.
            Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
            Map<String, dynamic> passCountData = data['passCountData'] ?? {};
            Map<String, dynamic> passCountTimeData = data['passCountTimeData'] ?? {};
            Map<String, dynamic> slopeScores = data['slopeScores'] ?? {};
            int totalPassCount = data['totalPassCount'] ?? 0;

            int timeSlot = getTimeSlot(now);

            if (location.type == 'slope') {
              data['slopeStatus'] ??= {};
              data['slopeStatus'][location.name] = true;

              passCountTimeData["$timeSlot"] ??= 0;

              await docRef.set(data, SetOptions(merge: true));
            } else if (location.type == 'respawn') {
              try {
                Map<String, dynamic> slopeStatus = data['slopeStatus'] ?? {};

                List<String> passedSlopes = slopeStatus.entries
                    .where((entry) => entry.value == true)
                    .map((entry) => entry.key)
                    .toList();

                for (String slopeName in passedSlopes) {
                  int storedPassCount = passCountData[slopeName] ?? 0;
                  int timeSlotPassCount = passCountTimeData["$timeSlot"] ?? 0;

                  int slopeScore = slopeScoresModel.slopeScores[slopeName] ?? 0;

                  storedPassCount += 1;
                  totalPassCount += 1;
                  timeSlotPassCount += 1;
                  int updatedScore = storedPassCount * slopeScore;

                  passCountData[slopeName] = storedPassCount;
                  passCountTimeData["$timeSlot"] = timeSlotPassCount;

                  slopeScores[slopeName] = updatedScore;

                  await updateCrewData(slopeName, slopeScore, timeSlot, DateTime.now());
                }

                for (String slopeName in slopeStatus.keys) {
                  slopeStatus[slopeName] = false;
                }

                int totalScore = slopeScores.values.fold<int>(0, (sum, score) => sum + (score as int? ?? 0));
                data['totalScore'] = totalScore;
                data['totalPassCount'] = totalPassCount;

                DateTime lastPassTime = data['lastPassTime']?.toDate();
                DateTime now = DateTime.now();

                if (now.difference(lastPassTime).inMinutes >= 5) {
                  data['lastPassTime'] = Timestamp.fromDate(now);
                }

                await docRef.set(data, SetOptions(merge: true));

                await _rankingTierModelController.updateTier();
              } catch (error, stackTrace) {
                print('오류 발생: $error');
                print('스택 트레이스: $stackTrace');
                // 오류 처리 로직 추가
              }
            }
          } catch (error, stackTrace) {
            print('Firestore 업데이트 에러: $error');
            print('StackTrace: $stackTrace');
          }
        }
      }
    }
  }

  int getTimeSlot(DateTime now) {
    int hour = now.hour;

    if (hour >= 8 && hour < 10) {
      return 1;
    } else if (hour >= 10 && hour < 12) {
      return 2;
    } else if (hour >= 12 && hour < 14) {
      return 3;
    } else if (hour >= 14 && hour < 16) {
      return 4;
    } else if (hour >= 16 && hour < 18) {
      return 5;
    } else if (hour >= 18 && hour < 20) {
      return 6;
    } else if (hour >= 20 && hour < 22) {
      return 7;
    } else if (hour >= 22) {
      return 8;
    } else if (hour < 2) {
      return 9;
    } else if (hour >= 2 && hour < 4) {
      return 10;
    } else if (hour >= 4 && hour < 6) {
      return 11;
    } else if (hour >= 6 && hour < 8) {
      return 12;
    }

    return -1; // default return value in case of an error
  }

  Future<void> updateCrewData(String locationName, int slopeScore, int timeSlot, DateTime lastPassTime) async {
    String liveCrew = _userModelController.liveCrew ?? ''; // 유효하지 않은 경우 빈 문자열로 초기화

    if (liveCrew.isNotEmpty) {
      DocumentReference crewDocRef = FirebaseFirestore.instance
          .collection('liveCrew')
          .doc(liveCrew);

      try {
        DocumentSnapshot crewDocSnapshot = await crewDocRef.get();

        Map<String, dynamic> crewData;

        if (!crewDocSnapshot.exists) {
          crewData = {
            'passCountData': {},
            'passCountTimeData': {
              '1': 0,
              '2': 0,
              '3': 0,
              '4': 0,
              '5': 0,
              '6': 0,
              '7': 0,
              '8': 0,
              '9': 0,
              '10': 0,
              '11': 0,
              '12': 0,
            },
            'slopeScores': {},
            'totalPassCount': 0,
            'totalScore': 0,
            'lastPassTime': null,
          };
        } else {
          crewData = crewDocSnapshot.data() as Map<String, dynamic>;

          if (crewData['passCountTimeData'] == null) {
            crewData['passCountTimeData'] = {
              '1': 0,
              '2': 0,
              '3': 0,
              '4': 0,
              '5': 0,
              '6': 0,
              '7': 0,
              '8': 0,
              '9': 0,
              '10': 0,
              '11': 0,
              '12': 0,
            };
          }
        }

        Map<String, dynamic> crewPassCountData = crewData['passCountData'] ?? {};
        Map<String, dynamic> crewPassCountTimeData = crewData['passCountTimeData'];
        Map<String, dynamic> crewSlopeScores = crewData['slopeScores'] ?? {};
        int crewTotalPassCount = crewData['totalPassCount'] ?? 0;

        // Update the pass count
        int crewStoredPassCount = crewPassCountData[locationName] ?? 0;
        crewPassCountData[locationName] = crewStoredPassCount + 1;

        // Update the pass count for the current time slot
        int crewTimeSlotPassCount = crewPassCountTimeData["$timeSlot"] ?? 0;
        crewPassCountTimeData["$timeSlot"] = crewTimeSlotPassCount + 1;

        // Update the total pass count
        crewTotalPassCount += 1;

        // Update the score
        int crewSlopeScore = crewSlopeScores[locationName] ?? 0;
        crewSlopeScores[locationName] = crewSlopeScore + slopeScore;

        // Update the total score
        int crewTotalScore = crewSlopeScores.values.fold<int>(0, (sum, score) => sum + (score as int? ?? 0));
        crewData['totalScore'] = crewTotalScore;

        crewData['totalPassCount'] = crewTotalPassCount;

        // Update lastPassTime with current time
        crewData['lastPassTime'] = lastPassTime;

        // Update the document
        await crewDocRef.set(crewData, SetOptions(merge: true));
      } catch (error, stackTrace) {
        print('오류 발생: $error');
        print('스택 트레이스: $stackTrace');
      }
    }
  }

  Future<void> stopBackgroundLocationService() async {
    await bg.BackgroundGeolocation.stop();
    bg.BackgroundGeolocation.removeListeners();
  }

  Future<bool> checkLiveStatus() async {
    await _userModelController.getCurrentUserLocationInfo(_userModelController.uid);
    return _userModelController.isOnLive!;
  }

  Future<bool> _updateBoundaryStatus(Position position) async {
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    bool withinBoundary = _checkPositionWithinBoundary(currentLatLng);

    if (_userModelController.uid != null) {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(_userModelController.uid)
          .set({
        'withinBoundary': withinBoundary,
      }, SetOptions(merge: true)).catchError((error) {
        print('Firestore 업데이트 에러: $error');
      });
    }

    return withinBoundary;
  }

  Future<void> withinBoundaryOff() async{
    if (_userModelController.uid != null) {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(_userModelController.uid)
          .set({
        'withinBoundary': false,
      }, SetOptions(merge: true)).catchError((error) {
        print('Firestore 업데이트 에러: $error');
      });
    }
  }

  Future<void> stopForegroundLocationService() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  bool _checkPositionWithinBoundary(LatLng position) {
    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _resortModelController.latitude,
      _resortModelController.longitude,
    );

    return distanceInMeters <= 5000;
  }

  Future<Map<String, int>> calculateRank(int myScore) async {
    int totalUsers = 0;
    int myRank = 0;
    int sameScoreCount = 0;
    bool foundUser = false;

    QuerySnapshot userCollection = await FirebaseFirestore.instance
        .collection('user')
        .where('favoriteResort', isEqualTo: _userModelController.favoriteResort)
        .get();

    totalUsers = userCollection.docs.length;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${_userModelController.favoriteResort}')
        .orderBy('totalScore', descending: true)
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (int i = 0; i < documents.length; i++) {
      if (documents[i].data() != null) {
        Map<String, dynamic> data = documents[i].data() as Map<String, dynamic>;
        int currentScore = data['totalScore'] as int;

        if (documents[i].id == _userModelController.uid) {
          foundUser = true;
        }

        if (currentScore != myScore) {
          myRank += sameScoreCount + 1;
          sameScoreCount = 0;
        } else {
          if (foundUser) {
            myRank = myRank + 1;
            break;
          }
          sameScoreCount++;
        }
      }
    }

    if (foundUser) {
      return {'totalUsers': totalUsers, 'rank': myRank};
    } else {
      return {'totalUsers': totalUsers, 'rank': 0};
    }
  }

  Future<Map<String, int>> calculateRankIndiAll(int myScore, String uid) async {
    int totalUsers = 0;
    int myRank = 0;
    int sameScoreCount = 0;
    bool foundUser = false;

    QuerySnapshot userCollection = await FirebaseFirestore.instance
        .collection('user')
        .where('favoriteResort', isEqualTo: _userModelController.favoriteResort)
        .get();

    totalUsers = userCollection.docs.length;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${_userModelController.favoriteResort}')
        .orderBy('totalScore', descending: true)
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (int i = 0; i < documents.length; i++) {
      if (documents[i].data() != null) {
        Map<String, dynamic> data = documents[i].data() as Map<String, dynamic>;
        int currentScore = data['totalScore'] as int;

        if (documents[i].id == uid) {
          foundUser = true;
        }

        if (currentScore != myScore) {
          myRank += sameScoreCount + 1;
          sameScoreCount = 0;
        } else {
          if (foundUser) {
            myRank = myRank + 1;
            break;
          }
          sameScoreCount++;
        }
      }
    }

    if (foundUser) {
      return {'totalUsers': totalUsers, 'rank': myRank};
    } else {
      return {'totalUsers': totalUsers, 'rank': 0};
    }
  }
  Map<String, int> calculateRankIndiAll2({required userRankingDocs}){
    isLoading.value = true;
    Map<String, int> userRankingMap = {};

    for (int i = 0; i < userRankingDocs.length; i++) {
      if (userRankingDocs[i].data() != null) {
        if (i == 0) {
          userRankingMap['${userRankingDocs[i]['uid']}'] = i+1;
        } else if(userRankingDocs[i]['totalScore'] != userRankingDocs[i-1]['totalScore']){
          userRankingMap['${userRankingDocs[i]['uid']}'] = i+1;
        } else if(userRankingDocs[i]['totalScore'] == userRankingDocs[i-1]['totalScore']){
          userRankingMap['${userRankingDocs[i]['uid']}'] = userRankingMap['${userRankingDocs[i-1]['uid']}']!;
        }
      }
    }
    isLoading.value =false;
    return userRankingMap;
  }

  Future<Map<String, int>> calculateRankCrewAll(int crewScore, String crewID) async {
    isLoading.value = true;
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
    isLoading.value =false;

    if (foundCrew) {
      return {'totalCrews': totalCrews, 'rank': crewRank};
    } else {
      return {'totalCrews': totalCrews, 'rank': 0};
    }
  }
  Map<String, int> calculateRankCrewAll2({required crewDocs})  {
    isLoading.value = true;
    Map<String, int> crewRankingMap = {};

    for (int i = 0; i < crewDocs.length; i++) {
      if (crewDocs[i].data() != null) {
        if (i == 0) {
          crewRankingMap['${crewDocs[i]['crewID']}'] = i+1;
        } else if(crewDocs[i]['totalScore'] != crewDocs[i-1]['totalScore']){
          crewRankingMap['${crewDocs[i]['crewID']}'] = i+1;
        } else if(crewDocs[i]['totalScore'] == crewDocs[i-1]['totalScore']){
          crewRankingMap['${crewDocs[i]['crewID']}'] = crewRankingMap['${crewDocs[i-1]['crewID']}']!;
        }
      }
    }
    isLoading.value =false;
    return crewRankingMap;
  }

  String calculateMaxValue(Map<String, dynamic>? value) {
    if (value == null || value.isEmpty) {
      return ''; // 데이터가 없을 경우 빈 문자열 반환
    }

    String calculateMaxValue = value.entries.reduce((maxEntry, entry) {
      return maxEntry.value > entry.value ? maxEntry : entry;
    }).key;

    return calculateMaxValue;
  }

  List<Map<String, dynamic>> calculateBarDataSlopeScore(Map<String, dynamic>? slopeScoresData) {
    if (slopeScoresData == null || slopeScoresData.isEmpty) {
      return []; // 데이터가 없을 경우 빈 리스트 반환
    }

    List<MapEntry<String, dynamic>> sortedEntries = slopeScoresData.entries.toList()
      ..sort((a, b) {
        int scoreA = slopeScoresData[a.key] ?? 0;
        int scoreB = slopeScoresData[b.key] ?? 0;
        return scoreB.compareTo(scoreA);
      });

    int maxScore = sortedEntries.first.value; // 상위 슬로프의 점수 가져오기

    List<Map<String, dynamic>> barData = sortedEntries.map((entry) {
      String slopeName = entry.key;
      int scoreForSlope = slopeScoresData[slopeName] ?? 0;
      double barHeightRatio = scoreForSlope.toDouble() / maxScore.toDouble();
      Color barColor = scoreForSlope == maxScore ? Color(0xFFC3DBFF) : Color(0xFF093372);

      return {
        'slopeName': slopeName,
        'scoreForSlope': scoreForSlope,
        'barHeightRatio': barHeightRatio,
        'barColor': barColor,
      };
    }).toList();

    return barData;
  }

  List<Map<String, dynamic>> calculateBarDataPassCount(Map<String, dynamic>? passCountData) {
    if (passCountData == null || passCountData.isEmpty) {
      return []; // return an empty list if there is no data
    }

    List<MapEntry<String, dynamic>> sortedEntries = passCountData.entries.toList()
      ..sort((a, b) {
        return b.value.compareTo(a.value);
      });

    int maxPassCount = sortedEntries.map((entry) {
      return entry.value ?? 0;
    }).reduce((value, element) => value > element ? value : element);

    List<Map<String, dynamic>> barData = sortedEntries.map((entry) {
      String slopeName = entry.key;
      int passCount = entry.value ?? 0;
      double barHeightRatio = passCount.toDouble() / maxPassCount.toDouble();
      Color barColor = passCount == maxPassCount ? Color(0xFF05419A) : Color(0xFF3D83ED);

      return {
        'slopeName': slopeName,
        'passCount': passCount,
        'barHeightRatio': barHeightRatio,
        'barColor': barColor,
      };
    }).toList();

    return barData;
  }

  List<Map<String, dynamic>> calculateBarDataSlot(Map<String, dynamic>? passCountTimeData) {
    if (passCountTimeData == null || passCountTimeData.isEmpty) {
      return []; // 데이터가 없을 경우 빈 리스트 반환
    }

    List<MapEntry<String, dynamic>> sortedEntries = passCountTimeData.entries.toList()
      ..sort((a, b) {
        int keyA = int.tryParse(a.key) ?? 0;
        int keyB = int.tryParse(b.key) ?? 0;
        return keyA.compareTo(keyB);
      });

    int maxPassCount = sortedEntries.map((entry) {
      return entry.value ?? 0;
    }).reduce((value, element) => value > element ? value : element);

    List<Map<String, dynamic>> barData = sortedEntries.where((entry) {
      String slotName = entry.key;
      return ['1', '2', '3', '4', '5', '6', '7', '8'].contains(slotName);
    }).map((entry) {
      String slotName = entry.key;
      int passCount = entry.value ?? 0;
      double barHeightRatio = passCount.toDouble() / maxPassCount.toDouble();
      Color barColor = passCount == maxPassCount ? Color(0xFF05419A) : Color(0xFF3D83ED);

      return {
        'slotName': slotName,
        'passCount': passCount,
        'barHeightRatio': barHeightRatio,
        'barColor': barColor,
      };
    }).toList();

    return barData;
  }

  bool areAllSlotValuesZero(Map<String, dynamic>? passCountTimeData) {
    if (passCountTimeData == null) {
      return true; // 데이터가 없는 경우
    }

    for (var value in passCountTimeData.values) {
      if (value != 0) {
        return false; // 하나 이상의 값이 0이 아님
      }
    }

    return true; // 모든 값이 0임
  }
}


// Future<BitmapDescriptor> createCustomMarkerBitmap(String title, bool _isTapped) async {
//   const int maxCharacters = 6; // Maximum number of characters allowed
//
//   // Check if title length is more than maxCharacters and _isTapped is false
//   if (title.length > maxCharacters && !_isTapped) {
//     title = title.substring(0, maxCharacters) + "..."; // add ellipsis if more than maxCharacters
//   }
//
//   ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
//
//   // Draw text on canvas first to get the text width and height
//   TextSpan span = TextSpan(
//       style: TextStyle(
//         color: Colors.yellowAccent,
//         fontSize: 35.0,
//         fontWeight: FontWeight.bold,
//       ),
//       text: title
//   );
//   TextPainter tp = TextPainter(
//       text: span,
//       textAlign: TextAlign.center,
//       textDirection: TextDirection.ltr
//   );
//   tp.layout();
//
//   // Create a canvas large enough to hold the text and image
//   Canvas canvas = Canvas(pictureRecorder, Rect.fromLTWH(0, 0, max(tp.width, 100.0), tp.height + 100.0));
//
//   // Calculate the position for the text to be in the center horizontally
//   final double textOffset = max(tp.width, 100.0) / 2 - tp.width / 2;
//
//   // Position the text on the canvas
//   tp.paint(canvas, Offset(textOffset, 0.0));
//
//   // Load image
//   ByteData data = await rootBundle.load('assets/imgs/icons/icon_live_map.png');
//   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
//   ui.FrameInfo frameInfo = await codec.getNextFrame();
//   ui.Image img = frameInfo.image;
//
//   // Draw image on canvas
//   Size imgSize = Size(100.0, 100.0);  // Change as needed
//   canvas.drawImageRect(
//       img,
//       Rect.fromLTRB(
//           0.0,
//           0.0,
//           img.width.toDouble(),
//           img.height.toDouble()
//       ),
//       Rect.fromLTRB(
//           (max(tp.width, 100.0) - imgSize.width) / 2, // center the image horizontally
//           tp.height, // position the image below the text
//           (max(tp.width, 100.0) - imgSize.width) / 2 + imgSize.width,
//           tp.height + imgSize.height
//       ),
//       Paint()
//   );
//
//   final imgFinal = await pictureRecorder.endRecording().toImage(
//       max(tp.width, 100.0).toInt(),
//       imgSize.height.toInt() + tp.height.toInt()
//   );
//   final dataFinal = await imgFinal.toByteData(format: ui.ImageByteFormat.png);
//
//   return BitmapDescriptor.fromBytes(dataFinal!.buffer.asUint8List());
// }
//
// Future<void> listenToFriendLocations() async {
//   FirebaseFirestore.instance
//       .collection('user')
//       .where('whoResistMeBF', arrayContains: _userModelController.uid!)
//       .where('isOnLive', isEqualTo: true)  // Only get data where isLiveOn is true
//       .snapshots()
//       .listen((QuerySnapshot querySnapshot) async {  // Add async keyword here
//     await _updateMarkers(querySnapshot);
//   });
// }
//
// Future<void> _updateMarkers(QuerySnapshot querySnapshot) async {
//   Set<String> updatedFriendIds = Set<String>();
//   List<Marker> newMarkers = [];
//
//   for (var document in querySnapshot.docs) {
//     Map<String, dynamic> data = document.data() as Map<String, dynamic>;
//     double? latitude = (data['latitude'] as num?)?.toDouble();
//     double? longitude = (data['longitude'] as num?)?.toDouble();
//     String friendId = data['displayName'];
//
//     updatedFriendIds.add(friendId);
//
//     if (latitude != null && longitude != null) {
//       final LatLng friendLatLng = LatLng(latitude, longitude);
//       bool withinBoundary = _checkPositionWithinBoundary(friendLatLng);
//
//       if (withinBoundary) {
//         _isTapped.putIfAbsent(friendId, () => false);
//
//         final marker = Marker(
//             markerId: MarkerId('friend_$friendId'),
//             position: friendLatLng,
//             icon: await createCustomMarkerBitmap('$friendId', _isTapped[friendId]!),
//             onTap: () async {
//               _isTapped[friendId] = !_isTapped[friendId]!;
//               await _updateMarkers(querySnapshot);  // Force markers to update
//             }
//         );
//
//         newMarkers.add(marker);
//       }
//     }
//   }
//
//   _markers.value = newMarkers;
// }


