import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  //TODO: Dependency Injection********************************************

  RxList<Marker> _markers = RxList<Marker>();

  List<Marker> get markers => _markers.toList();

  int passCount = 0;
  DateTime? lastPassTime;
  Map<String, bool> _isTapped = {};

  void initializeIsTapped() {
    _isTapped = {};
  }



  StreamSubscription<Position>? _positionStreamSubscription;


  Future<void> updateFirebaseWithLocation(Position position) async {
    double latitude = position.latitude;
    double longitude = position.longitude;

    if (_userModelController.uid != null) {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(_userModelController.uid)
          .update({
        'latitude': latitude,
        'longitude': longitude,
      }).catchError((error) {
        print('Firestore 업데이트 에러: $error');
      });
    }
  }

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
        await updateFirebaseWithLocation(position);
        await _resortModelController.getFavoriteResort(_userModelController.favoriteResort);
        // Check if within boundary before updating pass count
        bool withinBoundary = await _updateBoundaryStatus(position);
        bool isOnLive = await checkLiveStatus();

        if (withinBoundary && isOnLive) {
          await checkAndUpdatePassCount(position).catchError((error) {
            print('점수 업데이트 오류: $error');
          });
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
      stopOnTerminate: false,
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

        await updateFirebaseWithLocation(position);
        // Check if within boundary before updating pass count
        bool withinBoundary = await _updateBoundaryStatus(position);
        bool isOnLive = await checkLiveStatus();

        if (withinBoundary && isOnLive) {
          await checkAndUpdatePassCount(position).catchError((error) {
            print('점수 업데이트 오류: $error');
          });
        }
      } catch (e, stackTrace) {
        print('백그라운드 위치 업데이트 오류: $e');
        print('Stack trace: $stackTrace');
      }
    });
  }

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
                'lastPassTime': null,
                'slopeScores': {},
                'totalScore': 0,
              });

              // Re-fetch the document after creating it
              userSnapshot = await docRef.get();
            }

            // Now, we are sure the document exists. Let's proceed with the rest of the logic.
            Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
            Map<String, dynamic> passCountData = data['passCountData'] ?? {};

            int storedPassCount = passCountData[location.name] ?? 0;
            DateTime? storedLastPassTime = data['lastPassTime'] != null
                ? (data['lastPassTime'] as Timestamp).toDate()
                : null;

            if (storedLastPassTime == null || now.difference(storedLastPassTime).inMinutes >= 10) {
              storedPassCount += 1;
              DateTime lastPassTime = now;

              // Update passCountData
              passCountData[location.name] = storedPassCount;
              data['passCountData'] = passCountData;

              // Calculate slope score
              int slopeScore = slopeScoresModel.slopeScores[location.name] ?? 0;
              int updatedScore = slopeScore * storedPassCount;

              // Update slopeScores
              Map<String, dynamic> slopeScores = data['slopeScores'] ?? {};
              slopeScores[location.name] = updatedScore;
              data['slopeScores'] = slopeScores;

              // Calculate total score
              int totalScore = slopeScores.values.fold<int>(0, (int sum, dynamic score) => sum + (score as int? ?? 0));
              data['totalScore'] = totalScore;

              data['lastPassTime'] = lastPassTime;

              // Update document using data
              await docRef.set(data, SetOptions(merge: true));

              // Update the same data to the 'crew' collection
              await updateCrewData(location.name, slopeScore);
            }
          } catch (error, stackTrace) {
            print('Firestore 업데이트 에러: $error');
            print('Stack trace: $stackTrace');
            // 여기서 추가적인 예외 처리나 로깅을 수행할 수 있습니다.
          }
        }
      }
    }
  }

  Future<void> updateCrewData(String locationName, int slopeScore) async {
    DocumentReference crewDocRef = FirebaseFirestore.instance
        .collection('liveCrew')
        .doc('${_userModelController.liveCrew}');

    try {
      DocumentSnapshot crewDocSnapshot = await crewDocRef.get();

      Map<String, dynamic> crewData = crewDocSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> crewPassCountData = crewData['passCountData'] ?? {};
      Map<String, dynamic> crewSlopeScores = crewData['slopeScores'] ?? {};

      // Update the pass count
      int crewStoredPassCount = crewPassCountData[locationName] ?? 0;
      crewPassCountData[locationName] = crewStoredPassCount + 1;

      // Update the slope scores
      int crewStoredSlopeScore = crewSlopeScores[locationName] ?? 0;
      crewSlopeScores[locationName] = crewStoredSlopeScore + slopeScore;

      // Update the total score
      int crewTotalScore = crewData['totalScore'] ?? 0;
      crewData['totalScore'] = crewTotalScore + slopeScore;

      // Assign updated pass count and slope scores back to crew data
      crewData['passCountData'] = crewPassCountData;
      crewData['slopeScores'] = crewSlopeScores;

      await crewDocRef.set(crewData, SetOptions(merge: true));
    } catch (error, stackTrace) {
      print('Firestore crew 업데이트 에러: $error');
      print('Stack trace: $stackTrace');
      // 여기서 추가적인 예외 처리나 로깅을 수행할 수 있습니다.
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



}
