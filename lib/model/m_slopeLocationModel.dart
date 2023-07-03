import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String name;
  final LatLng coordinates;

  LocationModel({required this.name, required this.coordinates});
}

List<LocationModel> locations = [
  LocationModel(
    name: '휘닉스평창 1',
    coordinates: LatLng(37.391105, 127.109500),
  ),
  LocationModel(
    name: '휘닉스평창 2',
    coordinates: LatLng(37.578337, 128.310873),
  ),
  // 추가적인 위치들을 여기에 추가
];
