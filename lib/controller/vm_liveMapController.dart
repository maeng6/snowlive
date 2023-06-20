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

  Future<BitmapDescriptor> createCustomMarkerBitmap(String title, bool _isTapped) async {
    const int maxCharacters = 6; // Maximum number of characters allowed

    // Check if title length is more than maxCharacters and _isTapped is false
    if (title.length > maxCharacters && !_isTapped) {
      title = title.substring(0, maxCharacters) + "..."; // add ellipsis if more than maxCharacters
    }

    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();

    // Draw text on canvas first to get the text width and height
    TextSpan span = TextSpan(
        style: TextStyle(
          color: Colors.yellowAccent,
          fontSize: 35.0,
          fontWeight: FontWeight.bold,
        ),
        text: title
    );
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr
    );
    tp.layout();

    // Create a canvas large enough to hold the text and image
    Canvas canvas = Canvas(pictureRecorder, Rect.fromLTWH(0, 0, max(tp.width, 100.0), tp.height + 100.0));

    // Calculate the position for the text to be in the center horizontally
    final double textOffset = max(tp.width, 100.0) / 2 - tp.width / 2;

    // Position the text on the canvas
    tp.paint(canvas, Offset(textOffset, 0.0));

    // Load image
    ByteData data = await rootBundle.load('assets/imgs/icons/icon_live_map.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    ui.Image img = frameInfo.image;

    // Draw image on canvas
    Size imgSize = Size(100.0, 100.0);  // Change as needed
    canvas.drawImageRect(
        img,
        Rect.fromLTRB(
            0.0,
            0.0,
            img.width.toDouble(),
            img.height.toDouble()
        ),
        Rect.fromLTRB(
            (max(tp.width, 100.0) - imgSize.width) / 2, // center the image horizontally
            tp.height, // position the image below the text
            (max(tp.width, 100.0) - imgSize.width) / 2 + imgSize.width,
            tp.height + imgSize.height
        ),
        Paint()
    );

    final imgFinal = await pictureRecorder.endRecording().toImage(
        max(tp.width, 100.0).toInt(),
        imgSize.height.toInt() + tp.height.toInt()
    );
    final dataFinal = await imgFinal.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(dataFinal!.buffer.asUint8List());
  }

  Future<void> listenToFriendLocations() async {
    FirebaseFirestore.instance
        .collection('user')
        .where('whoResistMeBF', arrayContains: _userModelController.uid!)
        .where('isOnLive', isEqualTo: true)  // Only get data where isLiveOn is true
        .snapshots()
        .listen((QuerySnapshot querySnapshot) async {  // Add async keyword here
      await _updateMarkers(querySnapshot);
    });
  }

  Future<void> _updateMarkers(QuerySnapshot querySnapshot) async {
    Set<String> updatedFriendIds = Set<String>();
    List<Marker> newMarkers = [];

    for (var document in querySnapshot.docs) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      double? latitude = (data['latitude'] as num?)?.toDouble();
      double? longitude = (data['longitude'] as num?)?.toDouble();
      String friendId = data['displayName'];

      updatedFriendIds.add(friendId);

      if (latitude != null && longitude != null) {
        final LatLng friendLatLng = LatLng(latitude, longitude);
        bool withinBoundary = _checkPositionWithinBoundary(friendLatLng);

        if (withinBoundary) {
          _isTapped.putIfAbsent(friendId, () => false);

          final marker = Marker(
              markerId: MarkerId('friend_$friendId'),
              position: friendLatLng,
              icon: await createCustomMarkerBitmap('$friendId', _isTapped[friendId]!),
              onTap: () async {
                _isTapped[friendId] = !_isTapped[friendId]!;
                await _updateMarkers(querySnapshot);  // Force markers to update
              }
          );

          newMarkers.add(marker);
        }
      }
    }

    _markers.value = newMarkers;
  }



}
