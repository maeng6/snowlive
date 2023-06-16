import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/model/m_slopeLocationModel.dart';

class LiveMapController extends GetxController {

  //TODO: Dependency Injection********************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  //TODO: Dependency Injection********************************************

  RxList<Marker> _markers = RxList<Marker>();

  List<Marker> get markers => _markers.toList();

  int passCount = 0;
  DateTime? lastPassTime;


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

  Future<void> startBackgroundLocationService() async {
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

    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) async{
      updateFirebaseWithLocation(position);
      checkAndUpdatePassCount(position);
      _updateBoundaryStatus(position);
      await _userModelController.getCurrentUser(_userModelController.uid);
    });
  }

  Future<void> _updateBoundaryStatus(Position position) async {
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

  Future<void> stopBackgroundLocationService() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  Future<void> checkAndUpdatePassCount(Position position) async {
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
        if (lastPassTime == null || now.difference(lastPassTime!).inMinutes >= 10) {
          passCount++;
          lastPassTime = now;

          if (_userModelController.uid != null) {
            DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                .collection('user')
                .doc(_userModelController.uid)
                .get();

            int storedPassCount = userSnapshot.get('passCount') ?? 0;
            DateTime storedLastPassTime = userSnapshot.get('lastPassTime')?.toDate();

            if (storedLastPassTime != null && now.difference(storedLastPassTime).inMinutes < 10) {
              // 파이어베이스에 저장된 시간과 현재 시간을 비교하여 10분 이내에 재시작한 경우에는 업데이트를 건너뜁니다.
              passCount = storedPassCount;
              lastPassTime = storedLastPassTime;
            } else {
              passCount = storedPassCount + 1;
              lastPassTime = now;
            }

            await FirebaseFirestore.instance
                .collection('user')
                .doc(_userModelController.uid)
                .update({
              'passCount': passCount,
              'lastPassTime': lastPassTime,
            })
                .catchError((error) {
              print('Firestore 업데이트 에러: $error');
            });
          }
        }
      }
    }
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

  Future<void> listenToFriendLocations() async {
    FirebaseFirestore.instance
        .collection('user')
        .where('whoResistMe', arrayContains: _userModelController.uid!)
        .where('isOnLive', isEqualTo: true)  // Only get data where isLiveOn is true
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      Set<String> updatedFriendIds = Set<String>();
      List<Marker> newMarkers = [];

      querySnapshot.docs.forEach((document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        double? latitude = (data['latitude'] as num?)?.toDouble();
        double? longitude = (data['longitude'] as num?)?.toDouble();
        String friendId = data['displayName'];

        updatedFriendIds.add(friendId);

        if (latitude != null && longitude != null) {
          final LatLng friendLatLng = LatLng(latitude, longitude);
          bool withinBoundary = _checkPositionWithinBoundary(friendLatLng);

          if (withinBoundary) {
            final marker = Marker(
              markerId: MarkerId('friend_$friendId'),
              position: friendLatLng,
              infoWindow: InfoWindow(
                title: 'Friend ID: $friendId',
              ),
              visible: true,
              icon: BitmapDescriptor.defaultMarker,
              anchor: Offset(0.5, 0.5),
            );

            newMarkers.add(marker);
          }
        }

      });

      _markers.value = newMarkers;
    });
  }



}
