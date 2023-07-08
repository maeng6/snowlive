import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String name;
  final LatLng coordinates;
  final String type; // 'slope' 또는 'respawn'

  LocationModel({required this.name, required this.coordinates, required this.type});
}

List<LocationModel> locations = [
  LocationModel(
    name: '휘닉스평창 1',
    coordinates: LatLng(37.576830, 128.314764),
    type: 'slope',
  ),
  LocationModel(
    name: '휘닉스평창 2',
    coordinates: LatLng(37.578337, 128.310873),
    type: 'slope',
  ),
  // 추가적인 위치들을 여기에 추가
  LocationModel(
    name: '리스폰 지역 1',
    coordinates: LatLng(37.583570, 128.324905),
    type: 'respawn',
  ),
];
