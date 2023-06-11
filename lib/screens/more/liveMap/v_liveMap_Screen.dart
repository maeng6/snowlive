import 'dart:math';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';

class LiveMap_Screen extends StatefulWidget {
  @override
  _LiveMap_ScreenState createState() => _LiveMap_ScreenState();
}

class _LiveMap_ScreenState extends State<LiveMap_Screen> {
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  late GoogleMapController mapController;
  Map<String, Marker> _markers = {};
  List<String> friendIds = [];

  @override
  void initState() {
    super.initState();
    checkPermission();
    _setPosition();
    startTracking();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    listenToFriendLocations(friendIds);
  }

  void _setPosition() {
    Geolocator.getPositionStream().listen((Position position) async {
      bool withinBoundary = _checkPositionWithinRadius(position, _resortModelController.latitude, _resortModelController.longitude, 5000);

      if (withinBoundary) {
        final marker = Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
        );

        setState(() {
          _markers['current_location'] = marker;
        });

        await FirebaseFirestore.instance.collection('user').doc(_userModelController.uid).update({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      } else {
        if (_markers.containsKey('current_location')) {
          setState(() {
            _markers.remove('current_location');
          });
        }
      }
    });
  }

  void startTracking() {
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[location] - $location');
    });

    bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0,
      stopOnTerminate: false,
      startOnBoot: true,
      debug: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
    )).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });
    print('백그라운드 추적 시작');
  }

  void checkPermission() async {
    PermissionStatus permission = await Permission.locationWhenInUse.status;

    if (permission != PermissionStatus.granted) {
      await Permission.locationWhenInUse.request();
    }
    print('권한체크');
  }

  bool _checkPositionWithinRadius(Position position, double centerLat, double centerLng, double maxDistanceInMeters) {
    const double earthRadiusInKm = 6371.0;

    double dLat = _degreesToRadians(position.latitude - centerLat);
    double dLng = _degreesToRadians(position.longitude - centerLng);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(centerLat)) * cos(_degreesToRadians(position.latitude)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distanceInMeters = earthRadiusInKm * c * 1000;

    return distanceInMeters <= maxDistanceInMeters;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void listenToFriendLocations(List<String> friendIds) {
    FirebaseFirestore.instance
        .collection('user')
        .where('whoResistMe', arrayContains: _userModelController.uid!)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      Set<String> updatedFriendIds = Set<String>();
      querySnapshot.docs.forEach((document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        double latitude = (data['latitude'] as num).toDouble();
        double longitude = (data['longitude'] as num).toDouble();
        String friendId = data['displayName'];

        updatedFriendIds.add(friendId);

        bool withinBoundary = _checkPositionWithinRadius(
          Position(
            latitude: latitude,
            longitude: longitude,
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            timestamp: DateTime.now(),
          ),
          _resortModelController.latitude,
          _resortModelController.longitude,
          3000,
        );

        if (withinBoundary) {
          final marker = Marker(
            markerId: MarkerId('friend_$friendId'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: 'Friend ID: $friendId',
            ),
            visible: true,
            icon: BitmapDescriptor.defaultMarker,
            anchor: Offset(0.5, 0.5),
          );

          setState(() {
            _markers['friend_$friendId'] = marker;
          });
        } else {
          if (_markers.containsKey('friend_$friendId')) {
            setState(() {
              _markers.remove('friend_$friendId');
            });
          }
        }
      });

      _markers.keys
          .where((markerId) => markerId.startsWith('friend_') && !updatedFriendIds.contains(markerId.substring(7)))
          .toList()
          .forEach((markerId) {
        setState(() {
          _markers.remove(markerId);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          centerTitle: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '라이브맵',
              style: TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapType: MapType.satellite,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(_resortModelController.latitude, _resortModelController.longitude),
                zoom: 14.0,
              ),
              markers: _markers.values.toSet(),
            ),
          ),
        ],
      ),
    );
  }
}
