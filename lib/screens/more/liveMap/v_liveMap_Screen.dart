import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snowlive3/controller/vm_liveMapController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';

class LiveMap_Screen extends StatefulWidget {
  @override
  _LiveMap_ScreenState createState() => _LiveMap_ScreenState();
}

class _LiveMap_ScreenState extends State<LiveMap_Screen> {

  //TODO: Dependency Injection********************************************
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();
  //TODO: Dependency Injection********************************************

  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    _liveMapController.startBackgroundLocationService();
    _liveMapController.listenToFriendLocations();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
      body: Obx(() => Column(
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
              markers: _liveMapController.markers.toSet(),
            ),
          ),
        ],
      ),
    ));
  }
}
