import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';

class LiveMap_Screen extends StatefulWidget {
  @override
  _LiveMap_ScreenState createState() => _LiveMap_ScreenState();
}

class _LiveMap_ScreenState extends State<LiveMap_Screen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  //TODO: Dependency Injection**************************************************


  late GoogleMapController mapController;
  Map<String, Marker> _markers = {};
  List<String> friendIds = [];  // Replace with actual friend IDs

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _setPosition();
    listenToFriendLocations(friendIds);
  }

  void _setPosition() {
    Geolocator.getPositionStream().listen((Position position) async {
      final marker = Marker(
        markerId: MarkerId('current_location'),
        position: LatLng(position.latitude, position.longitude),
      );

      setState(() {
        // Add or update the marker for the current location
        _markers['current_location'] = marker;
      });

      // Update the user's location in Firestore
      await FirebaseFirestore.instance.collection('user').doc(_userModelController.uid).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    });
  }

  void listenToFriendLocations(List<String> friendIds) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(_userModelController.uid)
        .collection('friendList')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        double latitude = (data['latitude'] as num).toDouble();
        double longitude = (data['longitude'] as num).toDouble();
        String friendId = data['displayName']; // Assuming that the document id is the friend's id
        final marker = Marker(
          markerId: MarkerId('friend_$friendId'),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
              title: 'Friend ID: $friendId', // Set the title of the info window to the friend's ID
            ),
          visible: true,
          icon: BitmapDescriptor.defaultMarker,
          anchor: Offset(0.5, 0.5)
        );

        setState(() {
          // Add or update the marker for the friend's location
          _markers['friend_$friendId'] = marker;
          print(marker);
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
              'Live Map',
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
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(_resortModelController.latitude, _resortModelController.longitude),  // Initial position of the map
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