import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String name;
  final LatLng coordinates;
  final String type; // 'slope' 또는 'respawn'

  LocationModel({required this.name, required this.coordinates, required this.type});
}

List<LocationModel> locations = [
  LocationModel(
    name: '휘1',
    coordinates: LatLng(37.576830, 128.314764),
    type: 'slope',
  ),
  LocationModel(
    name: '휘2',
    coordinates: LatLng(37.578337, 128.310873),
    type: 'slope',
  ),
  LocationModel(
    name: '휘3',
    coordinates: LatLng(37.578210, 128.305451),
    type: 'slope',
  ),
  LocationModel(
    name: '휘4',
    coordinates: LatLng(37.575273, 128.322150),
    type: 'slope',
  ),
  LocationModel(
    name: '휘5',
    coordinates: LatLng(37.583162, 128.317644),
    type: 'slope',
  ),
  LocationModel(
    name: '휘6',
    coordinates: LatLng(37.578341, 128.325714),
    type: 'slope',
  ),

  // 추가적인 위치들을 여기에 추가
  LocationModel(
    name: '리스폰 지역 1',
    coordinates: LatLng(37.583570, 128.324905),
    type: 'respawn',
  ),
];
