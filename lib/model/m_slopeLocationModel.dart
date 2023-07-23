import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String name;
  final List<LatLng> coordinates;
  final String type;

  LocationModel({required this.name, required this.coordinates, required this.type});
}

Map<String, List<LocationModel>> slopeLocationMap = {
  '12': phoenix,
  '2': vivaldi
  // ... 필요한 만큼 이름과 위치 리스트를 추가로 매핑합니다.
};

List<LocationModel> phoenix = [
  LocationModel(
    name: '스패로',
    coordinates: [
      LatLng(37.582852, 128.316915),
      LatLng(37.582767, 128.316971)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '챔피온',
    coordinates: [
      LatLng(37.577447, 128.312582),
      LatLng(37.577547, 128.312465)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '파노',
    coordinates: [
      LatLng(37.576205, 128.307921)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '환타지',
    coordinates: [
      LatLng(37.578524, 128.315549),
      LatLng(37.578326, 128.315585)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '디지',
    coordinates: [
      LatLng(37.577249, 128.315976),
      LatLng(37.576967, 128.315704)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '호크1',
    coordinates: [
      LatLng(37.582952, 128.322142),
      LatLng(37.582693, 128.322023)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '호크2',
    coordinates: [
      LatLng(37.581191, 128.318740),
      LatLng(37.581309, 128.318394)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '펭귄',
    coordinates: [
      LatLng(37.580841, 128.322048),
      LatLng(37.580744, 128.322353),
      LatLng(37.580431, 128.322327)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '밸리',
    coordinates: [
      LatLng(37.575795, 128.316310),
      LatLng(37.575775, 128.316679)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '마스터',
    coordinates: [
      LatLng(37.578714, 128.321666),
      LatLng(37.578595, 128.321876)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '모글',
    coordinates: [
      LatLng(37.577898, 128.322576),
      LatLng(37.577822, 128.322836)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '키위',
    coordinates: [
      LatLng(37.572216, 128.322321),
      LatLng(37.575255, 128.321956)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '도도',
    coordinates: [
      LatLng(37.578992, 128.326238),
      LatLng(37.579035, 128.325828)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '슬스',
    coordinates: [
      LatLng(37.577446, 128.324452),
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '도브',
    coordinates: [
      LatLng(37.577617, 128.325377),
      LatLng(37.577636, 128.325822)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '듀크',
    coordinates: [
      LatLng(37.575125, 128.324335),
      LatLng(37.575228, 128.324750),
      LatLng(37.574958, 128.325055),
      LatLng(37.574843, 128.325315)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '파라',
    coordinates: [
      LatLng(37.578302, 128.311030),
      LatLng(37.578425, 128.310755)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '파크',
    coordinates: [
      LatLng(37.583163, 128.320304)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '파이프',
    coordinates: [
      LatLng(37.582486, 128.320835)
    ],
    type: 'slope',
  ),



  //여기까지가 슬로프

  LocationModel(
    name: '몽블랑',
    coordinates: [
      LatLng(37.574301, 128.310102),
      LatLng(37.574178, 128.310700),
      LatLng(37.573979, 128.310786)
    ],
    type: 'slopeReset',
  ),
  LocationModel(
    name: '불새',
    coordinates: [
      LatLng(37.573933, 128.322244),
    ],
    type: 'slopeReset',
  ),

  //여기까지가 슬로프 리셋

  LocationModel(
    name: '스패로우리프트',
    coordinates: [
      LatLng(37.584573, 128.322432)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '호크리프트',
    coordinates: [
      LatLng(37.583700, 128.323646)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.582573, 128.323371)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '펭귄리프트',
    coordinates: [
      LatLng(37.581936, 128.325669)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '팔콘리프트',
    coordinates: [
      LatLng(37.581653, 128.325976)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '도도리프트',
    coordinates: [
      LatLng(37.581688, 128.326575)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '콘돌리프트',
    coordinates: [
      LatLng(37.581361, 128.313497)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '이글리프트',
    coordinates: [
      LatLng(37.578830, 128.319583)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '슬스리프트',
    coordinates: [
      LatLng(37.580415, 128.325175)
    ],
    type: 'respawn',
  ),
];


List<LocationModel> vivaldi = [
  LocationModel(
    name: '발라드',
    coordinates: [
      LatLng(37.643660, 127.686459),
      LatLng(37.643503, 127.686410),
      LatLng(37.643343, 127.686348),
      LatLng(37.643514, 127.686241),
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '재즈',
    coordinates: [
      LatLng(37.644055, 127.689633),
      LatLng(37.643787, 127.689526)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '레게',
    coordinates: [
      LatLng(37.641933, 127.691963),
      LatLng(37.641750, 127.691897)
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '클래식',
    coordinates: [
      LatLng(37.639034, 127.691514),
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '테크노2',
    coordinates: [
      LatLng(37.637722, 127.689178),
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '락',
    coordinates: [
      LatLng(37.640056, 127.689334),
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '펑키',
    coordinates: [
      LatLng(37.639721, 127.685478),
      LatLng(37.639727, 127.685653),
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '힙합',
    coordinates: [
      LatLng(37.639449, 127.683054),
      LatLng(37.639593, 127.683311),
      LatLng(37.639702, 127.683534),
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '테크노1',
    coordinates: [
      LatLng(37.641254, 127.683886),
      LatLng(37.641303, 127.684110),
    ],
    type: 'slope',
  ),
  LocationModel(
    name: '블루스',
    coordinates: [
      LatLng(37.642749, 127.680236),
      LatLng(37.642822, 127.680065)
    ],
    type: 'slope',
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '발라드하차장',
    coordinates: [
      LatLng(37.643245, 127.688299),
    ],
    type: 'slopeReset',
  ),
  LocationModel(
    name: '힙합하차장',
    coordinates: [
      LatLng(37.639453, 127.684357),
    ],
    type: 'slopeReset',
  ),
  //여기까지가 슬로프 리셋

  LocationModel(
    name: '테크노하차장',
    coordinates: [
      LatLng(37.637571, 127.689622)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '락하차장',
    coordinates: [
      LatLng(37.637812, 127.690087)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '곤돌라하차장',
    coordinates: [
      LatLng(37.637545, 127.690317)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '락승차장',
    coordinates: [
      LatLng(37.642686, 127.687468)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '재즈승차장',
    coordinates: [
      LatLng(37.645183, 127.683544)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '발라드승차장',
    coordinates: [
      LatLng(37.645007, 127.683434)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '테크노승차장',
    coordinates: [
      LatLng(37.644238, 127.683008)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '힙합승차장1',
    coordinates: [
      LatLng(37.644052, 127.682163)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '힙합승차장2',
    coordinates: [
      LatLng(37.643951, 127.682036)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '블루스승차장',
    coordinates: [
      LatLng(37.644010, 127.680712)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '곤돌라승차장',
    coordinates: [
      LatLng(37.645373, 127.682579)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '하단1',
    coordinates: [
      LatLng(37.645715, 127.683755)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '하단2',
    coordinates: [
      LatLng(37.645550, 127.683679)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '하단3',
    coordinates: [
      LatLng(37.645412, 127.683620)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '하단4',
    coordinates: [
      LatLng(37.644748, 127.683207)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '하단5',
    coordinates: [
      LatLng(37.644522, 127.683131)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '하단6',
    coordinates: [
      LatLng(37.644378, 127.683085)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '하단7',
    coordinates: [
      LatLng(37.644082, 127.682624)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '하단8',
    coordinates: [
      LatLng(37.643922, 127.681186)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '하단9',
    coordinates: [
      LatLng(37.643915, 127.681496)
    ],
    type: 'respawn',
  ),
  LocationModel(
    name: '하단10',
    coordinates: [
      LatLng(37.643933, 127.681751)
    ],
    type: 'respawn',
  ),
];