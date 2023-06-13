import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';

class LiveMapController extends GetxController {

  //TODO: Dependency Injection********************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  //TODO: Dependency Injection********************************************

  RxList<Marker> _markers = RxList<Marker>();
  List<Marker> get markers => _markers.toList();

  @override
  void onInit() {
    super.onInit();
    listenToFriendLocations();
  }


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

    Geolocator.getPositionStream().listen((Position position) {
      updateFirebaseWithLocation(position);
    });
  }

  void stopBackgroundLocationService() {
    Geolocator.getPositionStream().listen((Position position) {}).cancel();
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

  void listenToFriendLocations() {
    FirebaseFirestore.instance
        .collection('user')
        .where('whoResistMe', arrayContains: _userModelController.uid!)
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
