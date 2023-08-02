import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String name;
  final List<LatLng> coordinates;
  final String type;
  final int resort;

  LocationModel({
    required this.name,
    required this.coordinates,
    required this.type,
    required this.resort,

  });
}

Map<String, List<LocationModel>> slopeLocationMap = {
  '0': konjiam,
  '1': muju,
  '2': vivaldi,
  '3': alpensia,
  '4': eden,
  '5': gangchon,
  '6': oak,
  '7': o2,
  '8': yongpyong,
  '9': welli,
  '10': jisan,
  '11': high1,
  '12': phoenix,
  // ... 필요한 만큼 이름과 위치 리스트를 추가로 매핑합니다.
};

List<LocationModel> phoenix = [
  LocationModel(
    name: '스패',
    coordinates: [
      LatLng(37.582852, 128.316915),
      LatLng(37.582767, 128.316971)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '챔피온',
    coordinates: [
      LatLng(37.577447, 128.312582),
      LatLng(37.577547, 128.312465)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '파노',
    coordinates: [
      LatLng(37.576205, 128.307921)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '환타지',
    coordinates: [
      LatLng(37.578524, 128.315549),
      LatLng(37.578326, 128.315585)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '디지',
    coordinates: [
      LatLng(37.577249, 128.315976),
      LatLng(37.576967, 128.315704)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '호크1',
    coordinates: [
      LatLng(37.582952, 128.322142),
      LatLng(37.582693, 128.322023)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '호크2',
    coordinates: [
      LatLng(37.581191, 128.318740),
      LatLng(37.581309, 128.318394)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '펭귄',
    coordinates: [
      LatLng(37.580841, 128.322048),
      LatLng(37.580744, 128.322353),
      LatLng(37.580431, 128.322327)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '밸리',
    coordinates: [
      LatLng(37.575795, 128.316310),
      LatLng(37.575775, 128.316679)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '마스터',
    coordinates: [
      LatLng(37.578714, 128.321666),
      LatLng(37.578595, 128.321876)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '모글',
    coordinates: [
      LatLng(37.577898, 128.322576),
      LatLng(37.577822, 128.322836)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '키위',
    coordinates: [
      LatLng(37.572216, 128.322321),
      LatLng(37.575255, 128.321956)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '도도',
    coordinates: [
      LatLng(37.578992, 128.326238),
      LatLng(37.579035, 128.325828)
    ],
    type: 'slope',
    resort: 12,

  ),
  LocationModel(
    name: '슬스',
    coordinates: [
      LatLng(37.577446, 128.324452),
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '도브',
    coordinates: [
      LatLng(37.577617, 128.325377),
      LatLng(37.577636, 128.325822)
    ],
    type: 'slope',
    resort: 12,
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
    resort: 12,
  ),
  LocationModel(
    name: '파라',
    coordinates: [
      LatLng(37.578302, 128.311030),
      LatLng(37.578425, 128.310755)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '파크',
    coordinates: [
      LatLng(37.583163, 128.320304)
    ],
    type: 'slope',
    resort: 12,
  ),
  LocationModel(
    name: '파이프',
    coordinates: [
      LatLng(37.582486, 128.320835)
    ],
    type: 'slope',
    resort: 12,
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
    resort: 12,
  ),
  LocationModel(
    name: '불새',
    coordinates: [
      LatLng(37.573933, 128.322244),
    ],
    type: 'slopeReset',
    resort: 12,
  ),
  //여기까지가 슬로프 리셋

  LocationModel(
    name: '스패로우리프트',
    coordinates: [
      LatLng(37.584573, 128.322432)
    ],
    type: 'respawn',
    resort: 12,
  ),
  LocationModel(
    name: '호크리프트',
    coordinates: [
      LatLng(37.583700, 128.323646)
    ],
    type: 'respawn',
    resort: 12,
  ),
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.582573, 128.323371)
    ],
    type: 'respawn',
    resort: 12,
  ),
  LocationModel(
    name: '펭귄리프트',
    coordinates: [
      LatLng(37.581936, 128.325669)
    ],
    type: 'respawn',
    resort: 12,
  ),
  LocationModel(
    name: '팔콘리프트',
    coordinates: [
      LatLng(37.581653, 128.325976)
    ],
    type: 'respawn',
    resort: 12,
  ),
  LocationModel(
    name: '도도리프트',
    coordinates: [
      LatLng(37.581688, 128.326575)
    ],
    type: 'respawn',
    resort: 12,
  ),
  LocationModel(
    name: '콘돌리프트',
    coordinates: [
      LatLng(37.581361, 128.313497)
    ],
    type: 'respawn',
    resort: 12,
  ),
  LocationModel(
    name: '이글리프트',
    coordinates: [
      LatLng(37.578830, 128.319583)
    ],
    type: 'respawn',
    resort: 12,
  ),
  LocationModel(
    name: '슬스리프트',
    coordinates: [
      LatLng(37.580415, 128.325175)
    ],
    type: 'respawn',
    resort: 12,
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
    resort: 2,
  ),
  LocationModel(
    name: '재즈',
    coordinates: [
      LatLng(37.644055, 127.689633),
      LatLng(37.643787, 127.689526)
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '레게',
    coordinates: [
      LatLng(37.641933, 127.691963),
      LatLng(37.641750, 127.691897)
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '클래식',
    coordinates: [
      LatLng(37.639034, 127.691514),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '테크노2',
    coordinates: [
      LatLng(37.637722, 127.689178),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '락',
    coordinates: [
      LatLng(37.640056, 127.689334),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '펑키',
    coordinates: [
      LatLng(37.639721, 127.685478),
      LatLng(37.639727, 127.685653),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '힙합',
    coordinates: [
      LatLng(37.639449, 127.683054),
      LatLng(37.639593, 127.683311),
      LatLng(37.639702, 127.683534),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '테크노1',
    coordinates: [
      LatLng(37.641254, 127.683886),
      LatLng(37.641303, 127.684110),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '블루스',
    coordinates: [
      LatLng(37.642749, 127.680236),
      LatLng(37.642822, 127.680065)
    ],
    type: 'slope',
    resort: 2,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '발라드하차장',
    coordinates: [
      LatLng(37.643245, 127.688299),
    ],
    type: 'slopeReset',
    resort: 2,
  ),
  LocationModel(
    name: '힙합하차장',
    coordinates: [
      LatLng(37.639453, 127.684357),
    ],
    type: 'slopeReset',
    resort: 2,
  ),
  //여기까지가 슬로프 리셋

  LocationModel(
    name: '테크노하차장',
    coordinates: [
      LatLng(37.637571, 127.689622)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '락하차장',
    coordinates: [
      LatLng(37.637812, 127.690087)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '곤돌라하차장',
    coordinates: [
      LatLng(37.637545, 127.690317)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '락승차장',
    coordinates: [
      LatLng(37.642686, 127.687468)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '재즈승차장',
    coordinates: [
      LatLng(37.645183, 127.683544)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '발라드승차장',
    coordinates: [
      LatLng(37.645007, 127.683434)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '테크노승차장',
    coordinates: [
      LatLng(37.644238, 127.683008)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '힙합승차장1',
    coordinates: [
      LatLng(37.644052, 127.682163)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '힙합승차장2',
    coordinates: [
      LatLng(37.643951, 127.682036)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '블루스승차장',
    coordinates: [
      LatLng(37.644010, 127.680712)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '곤돌라승차장',
    coordinates: [
      LatLng(37.645373, 127.682579)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '하단1',
    coordinates: [
      LatLng(37.645715, 127.683755)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '하단2',
    coordinates: [
      LatLng(37.645550, 127.683679)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '하단3',
    coordinates: [
      LatLng(37.645412, 127.683620)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '하단4',
    coordinates: [
      LatLng(37.644748, 127.683207)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '하단5',
    coordinates: [
      LatLng(37.644522, 127.683131)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '하단6',
    coordinates: [
      LatLng(37.644378, 127.683085)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '하단7',
    coordinates: [
      LatLng(37.644082, 127.682624)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '하단8',
    coordinates: [
      LatLng(37.643922, 127.681186)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '하단9',
    coordinates: [
      LatLng(37.643915, 127.681496)
    ],
    type: 'respawn',
    resort: 2,
  ),
  LocationModel(
    name: '하단10',
    coordinates: [
      LatLng(37.643933, 127.681751)
    ],
    type: 'respawn',
    resort: 2,
  ),
];

List<LocationModel> welli = [
  LocationModel(
    name: '알파',
    coordinates: [
      LatLng(37.490130, 128.250120),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '뉴알파',
    coordinates: [
      LatLng(37.489916, 128.250191),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '뉴브',
    coordinates: [
      LatLng(37.488712, 128.250181),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '델타',
    coordinates: [
      LatLng(37.490038, 128.249121),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.490565, 128.248938),
      LatLng(37.490536, 128.249033),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '패밀리',
    coordinates: [
      LatLng(37.490825, 128.248507),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '챌린지',
    coordinates: [
      LatLng(37.485622, 128.248713),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '에코',
    coordinates: [
      LatLng(37.485401, 128.241075),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '파이프',
    coordinates: [
      LatLng(37.488033, 128.248500),
      LatLng(37.488027, 128.248602),
      LatLng(37.488015, 128.248697),
    ],
    type: 'slope',
    resort: 9,
  ),
  //여기까지가 리프트승차장

  // LocationModel(
  //   name: '몽블랑',
  //   coordinates: [
  //     LatLng(37.574301, 128.310102),
  //   ],
  //   type: 'slopeReset',
  //   resort: 9,
  // ),
  //여기까지가 슬로프 리셋

  LocationModel(
    name: '알파하차장',
    coordinates: [
      LatLng(37.486983, 128.253839)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '뉴알파하차장',
    coordinates: [
      LatLng(37.4868900, 128.253751)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '뉴브라보하차장',
    coordinates: [
      LatLng(37.481186, 128.249219)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '델타하차장',
    coordinates: [
      LatLng(37.485218, 128.246968)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '파이프하단',
    coordinates: [
      LatLng(37.488814, 128.248867),
      LatLng(37.488794, 128.248961),
      LatLng(37.488784, 128.249056),
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '챌린지하차장',
    coordinates: [
      LatLng(37.480209, 128.244324)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '곤돌라하차장',
    coordinates: [
      LatLng(37.480511, 128.243767),
      LatLng(37.480505, 128.243842),
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '에코하차장',
    coordinates: [
      LatLng(37.480306, 128.243368)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '패밀리하차장',
    coordinates: [
      LatLng(37.485519, 128.243595)
    ],
    type: 'respawn',
    resort: 9,
  ),
];

List<LocationModel> yongpyong = [
  LocationModel(
    name: '레드',
    coordinates: [
      LatLng(37.644151, 128.681997),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '뉴레드',
    coordinates: [
      LatLng(37.641663, 128.681627),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '뉴골드',
    coordinates: [
      LatLng(37.638479, 128.686671),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '골드',
    coordinates: [
      LatLng(37.638563, 128.687083),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '핑크',
    coordinates: [
      LatLng(37.644304, 128.680725),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '옐로우',
    coordinates: [
      LatLng(37.644210, 128.680570),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '뉴옐로',
    coordinates: [
      LatLng(37.643792, 128.679324),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.643810, 128.678912),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '그린',
    coordinates: [
      LatLng(37.641446, 128.677364),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '뉴그린',
    coordinates: [
      LatLng(37.640839, 128.677739),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '실버',
    coordinates: [
      LatLng(37.639179, 128.678049),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '블루',
    coordinates: [
      LatLng(37.640127, 128.677962),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '레인보',
    coordinates: [
      LatLng(37.622554, 128.663075),
    ],
    type: 'slope',
    resort: 8,
  ),
  //여기까지가 리프트승차장

  // LocationModel(
  //   name: '몽블랑',
  //   coordinates: [
  //     LatLng(37.574301, 128.310102),
  //   ],
  //   type: 'slopeReset',
  //   resort: 9,
  // ),
  //여기까지가 슬로프 리셋

  LocationModel(
    name: '레드하차장',
    coordinates: [
      LatLng(37.636192, 128.683197)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '뉴레드하차장',
    coordinates: [
      LatLng(37.637168, 128.682579)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '블루하차장',
    coordinates: [
      LatLng(37.636377, 128.682618)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '브릿지하차장',
    coordinates: [
      LatLng(37.638627, 128.686437)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '뉴골드하차장',
    coordinates: [
      LatLng(37.632130, 128.685502)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '골드하차장',
    coordinates: [
      LatLng(37.623984, 128.686884)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '핑크하차장',
    coordinates: [
      LatLng(37.638653, 128.680260)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '옐로우하차장',
    coordinates: [
      LatLng(37.640023, 128.680219)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '뉴옐로우하차장',
    coordinates: [
      LatLng(37.640714, 128.679137)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '그린하차장',
    coordinates: [
      LatLng(37.637886, 128.672474)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '메가그린하차장',
    coordinates: [
      LatLng(37.636674, 128.673486)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '실버하차장',
    coordinates: [
      LatLng(37.633294, 128.675178)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '렌보하차장',
    coordinates: [
      LatLng(37.611711, 128.671434)
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '곤돌라하차장',
    coordinates: [
      LatLng(37.612185, 128.672028)
    ],
    type: 'respawn',
    resort: 8,
  ),
];


List<LocationModel> high1 = [
  LocationModel(
    name: 'M허브',
    coordinates: [
      LatLng(37.207943, 128.825580),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '아테나',
    coordinates: [
      LatLng(37.207217, 128.825625),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: 'H1탑',
    coordinates: [
      LatLng(37.194165, 128.819854),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '제우스',
    coordinates: [
      LatLng(37.204031, 128.839065),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '주피터',
    coordinates: [
      LatLng(37.203974, 128.838783),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '아폴로',
    coordinates: [
      LatLng(37.197645, 128.831793),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '헤라',
    coordinates: [
      LatLng(37.190190, 128.827309),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '빅토리',
    coordinates: [
      LatLng(37.189464, 128.828342),
    ],
    type: 'slope',
    resort: 11,
  ),
  //여기까지가 리프트승차장

  // LocationModel(
  //   name: '몽블랑',
  //   coordinates: [
  //     LatLng(37.574301, 128.310102),
  //   ],
  //   type: 'slopeReset',
  //   resort: 9,
  // ),
  //여기까지가 슬로프 리셋

  LocationModel(
    name: '마운틴허브하차장',
    coordinates: [
      LatLng(37.194551, 128.8200187)
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '아테나하차',
    coordinates: [
      LatLng(37.194323, 128.820544)
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '하이원탑하차장',
    coordinates: [
      LatLng(37.183559, 128.816910)
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '주피터하차장',
    coordinates: [
      LatLng(37.196871, 128.832831)
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '제우스하차장',
    coordinates: [
      LatLng(37.189884, 128.827249)
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '아폴로하차장',
    coordinates: [
      LatLng(37.193825, 128.820421)
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '헤라하차장',
    coordinates: [
      LatLng(37.183158, 128.817601)
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '빅토리아하차장',
    coordinates: [
      LatLng(37.197194, 128.830041)
    ],
    type: 'respawn',
    resort: 11,
  ),
];

List<LocationModel> konjiam = [
  LocationModel(
    name: 'CNP1',
    coordinates: [
      LatLng(37.329249, 127.285050),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: 'CNP2',
    coordinates: [
      LatLng(37.333965, 127.289649),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '씽큐B',
    coordinates: [
      LatLng(37.332690, 127.287610),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '씽큐1',
    coordinates: [
      LatLng(37.333530, 127.286846),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '씽큐2',
    coordinates: [
      LatLng(37.332156, 127.283934),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '그램1',
    coordinates: [
      LatLng(37.331870, 127.282620),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '그램2',
    coordinates: [
      LatLng(37.331904, 127.280677),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '휘센',
    coordinates: [
      LatLng(37.339027, 127.289665),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '와이낫',
    coordinates: [
      LatLng(37.335265, 127.287953),
      LatLng(37.335662, 127.288313),
      LatLng(37.336003, 127.288045),
    ],
    type: 'slope',
    resort: 0,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '그램리프트',
    coordinates: [
      LatLng(37.334687, 127.287264),
    ],
    type: 'respawn',
    resort: 0,
  ),
  LocationModel(
    name: '씽큐CNP리프트',
    coordinates: [
      LatLng(37.336622, 127.292270),
    ],
    type: 'respawn',
    resort: 0,
  ),
  LocationModel(
    name: '와이낫리프트',
    coordinates: [
      LatLng(37.337435, 127.291687),
    ],
    type: 'respawn',
    resort: 0,
  ),
  LocationModel(
    name: '휘센리프트',
    coordinates: [
      LatLng(37.338235, 127.292215),
    ],
    type: 'respawn',
    resort: 0,
  ),
  //여기까지가 슬로프 리스폰
];

List<LocationModel> gangchon = [
  LocationModel(
    name: 'E',
    coordinates: [
      LatLng(37.820846, 127.589319),
    ],
    type: 'slope',
    resort: 5,
  ),
  LocationModel(
    name: 'D',
    coordinates: [
      LatLng(37.820615, 127.589146),
    ],
    type: 'slope',
    resort: 5,
  ),
  LocationModel(
    name: 'C',
    coordinates: [
      LatLng(37.820247, 127.589392),
    ],
    type: 'slope',
    resort: 5,
  ),
  LocationModel(
    name: 'A1',
    coordinates: [
      LatLng(37.817737, 127.589908),
    ],
    type: 'slope',
    resort: 5,
  ),
  LocationModel(
    name: 'B',
    coordinates: [
      LatLng(37.815380, 127.591497),
    ],
    type: 'slope',
    resort: 5,
  ),
  LocationModel(
    name: 'A',
    coordinates: [
      LatLng(37.815228, 127.591499),
    ],
    type: 'slope',
    resort: 5,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: 'E하차장',
    coordinates: [
      LatLng(37.818051, 127.584697),
    ],
    type: 'respawn',
    resort: 5,
  ),
  LocationModel(
    name: 'D하차장',
    coordinates: [
      LatLng(37.815595, 127.582821),
    ],
    type: 'respawn',
    resort: 5,
  ),
  LocationModel(
    name: 'C하차장',
    coordinates: [
      LatLng(37.815060, 127.583120),
    ],
    type: 'respawn',
    resort: 5,
  ),
  LocationModel(
    name: 'A1하차장',
    coordinates: [
      LatLng(37.816202, 127.591155),
    ],
    type: 'respawn',
    resort: 5,
  ),
  LocationModel(
    name: 'B하차장',
    coordinates: [
      LatLng(37.814820, 127.583190),
    ],
    type: 'respawn',
    resort: 5,
  ),
  LocationModel(
    name: 'A하차장',
    coordinates: [
      LatLng(37.814251, 127.587756),
    ],
    type: 'respawn',
    resort: 5,
  ),
  //여기까지가 슬로프 리스폰
];
List<LocationModel> jisan = [
  LocationModel(
    name: '실버',
    coordinates: [
      LatLng(37.217588, 127.343748),
    ],
    type: 'slope',
    resort: 10,
  ),
  LocationModel(
    name: '블루',
    coordinates: [
      LatLng(37.217204, 127.344169),
    ],
    type: 'slope',
    resort: 10,
  ),
  LocationModel(
    name: '뉴오렌',
    coordinates: [
      LatLng(37.215968, 127.345562),
    ],
    type: 'slope',
    resort: 10,
  ),
  LocationModel(
    name: '오렌지',
    coordinates: [
      LatLng(37.215627, 127.346589),
    ],
    type: 'slope',
    resort: 10,
  ),
  LocationModel(
    name: '레몬',
    coordinates: [
      LatLng(37.215443, 127.347131),
    ],
    type: 'slope',
    resort: 10,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '실버하차장',
    coordinates: [
      LatLng(37.213239, 127.339353),
    ],
    type: 'respawn',
    resort: 10,
  ),
  LocationModel(
    name: '블루하차장',
    coordinates: [
      LatLng(37.211657, 127.339888),
    ],
    type: 'respawn',
    resort: 10,
  ),
  LocationModel(
    name: '뉴오렌지하차장',
    coordinates: [
      LatLng(37.209744, 127.343664),
    ],
    type: 'respawn',
    resort: 10,
  ),
  LocationModel(
    name: '오렌지하차장',
    coordinates: [
      LatLng(37.211192, 127.344927),
    ],
    type: 'respawn',
    resort: 10,
  ),
  LocationModel(
    name: '레몬하차장',
    coordinates: [
      LatLng(37.213012, 127.346390),
    ],
    type: 'respawn',
    resort: 10,
  ),
  //여기까지가 슬로프 리스폰
];
List<LocationModel> alpensia = [
  LocationModel(
    name: '리프트1',
    coordinates: [
      LatLng(37.656550, 128.672236),
    ],
    type: 'slope',
    resort: 3,
  ),
  LocationModel(
    name: '리프트2',
    coordinates: [
      LatLng(37.656239, 128.673151),
    ],
    type: 'slope',
    resort: 3,
  ),
  LocationModel(
    name: '리프트3',
    coordinates: [
      LatLng(37.656235, 128.674675),
    ],
    type: 'slope',
    resort: 3,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '리프트1하차장',
    coordinates: [
      LatLng(37.651863, 128.668973),
    ],
    type: 'respawn',
    resort: 3,
  ),
  LocationModel(
    name: '리프트2하차장',
    coordinates: [
      LatLng(37.650160, 128.673046),
    ],
    type: 'respawn',
    resort: 3,
  ),
  LocationModel(
    name: '리프트3하차장',
    coordinates: [
      LatLng(37.650174, 128.673584),
    ],
    type: 'respawn',
    resort: 3,
  ),
  //여기까지가 슬로프 리스폰
];

List<LocationModel> eden = [
  LocationModel(
    name: '아담',
    coordinates: [
      LatLng(35.428437, 128.984085),
    ],
    type: 'slope',
    resort: 4,
  ),
  LocationModel(
    name: '밸리',
    coordinates: [
      LatLng(35.428451, 128.984733),
    ],
    type: 'slope',
    resort: 4,
  ),
  LocationModel(
    name: '에덴',
    coordinates: [
      LatLng(35.428519, 128.984959),
    ],
    type: 'slope',
    resort: 4,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '아담하차장',
    coordinates: [
      LatLng(35.419692, 128.982763),
    ],
    type: 'respawn',
    resort: 4,
  ),
  LocationModel(
    name: '밸리하차장',
    coordinates: [
      LatLng(35.421745, 128.988465),
    ],
    type: 'respawn',
    resort: 4,
  ),
  LocationModel(
    name: '에덴하차장',
    coordinates: [
      LatLng(35.424148, 128.987328),
    ],
    type: 'respawn',
    resort: 4,
  ),
  //여기까지가 슬로프 리스폰
];

List<LocationModel> oak = [
  LocationModel(
    name: '버드',
    coordinates: [
      LatLng(37.406586, 127.809320),
    ],
    type: 'slope',
    resort: 6,
  ),
  LocationModel(
    name: '마운틴',
    coordinates: [
      LatLng(37.406682, 127.809582),
    ],
    type: 'slope',
    resort: 6,
  ),
  LocationModel(
    name: '플라워',
    coordinates: [
      LatLng(37.407479, 127.809351),
    ],
    type: 'slope',
    resort: 6,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '버드하차장',
    coordinates: [
      LatLng(37.402692, 127.811821),
    ],
    type: 'respawn',
    resort: 6,
  ),
  LocationModel(
    name: '마운틴하차장',
    coordinates: [
      LatLng(37.402412, 127.818439),
    ],
    type: 'respawn',
    resort: 6,
  ),
  LocationModel(
    name: '플라워하차장',
    coordinates: [
      LatLng(37.408085, 127.814495),
    ],
    type: 'respawn',
    resort: 6,
  ),
  //여기까지가 슬로프 리스폰
];

List<LocationModel> muju = [
  LocationModel(
    name: '카누',
    coordinates: [
      LatLng(35.887641, 127.729047),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '라이너',
    coordinates: [
      LatLng(35.890564, 127.735717),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '무주E',
    coordinates: [
      LatLng(35.890273, 127.736315),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '크루저',
    coordinates: [
      LatLng(35.890219, 127.737152),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '요트',
    coordinates: [
      LatLng(35.890133, 127.737260),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '보트',
    coordinates: [
      LatLng(35.890147, 127.738520),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '스쿨B',
    coordinates: [
      LatLng(35.890646, 127.742274),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '쌍쌍',
    coordinates: [
      LatLng(35.889098, 127.743703),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '곤도라',
    coordinates: [
      LatLng(35.888295, 127.744930),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '에코',
    coordinates: [
      LatLng(35.888426, 127.745131),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '코러스',
    coordinates: [
      LatLng(35.888737, 127.746238),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '하모니',
    coordinates: [
      LatLng(35.875355, 127.753191),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '멜로디',
    coordinates: [
      LatLng(35.871878, 127.751019),
    ],
    type: 'slope',
    resort: 1,
  ),

  //여기까지가 슬로프

  LocationModel(
    name: '카누도착',
    coordinates: [
      LatLng(35.882590, 127.730470),
      LatLng(35.882604, 127.730548),
      LatLng(35.882651, 127.730562),
      LatLng(35.882661, 127.730623),

    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '라이너도착',
    coordinates: [
      LatLng(35.882635, 127.730949),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '무주익스프레스도착',
    coordinates: [
      LatLng(35.876837, 127.735204),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '크루저도착',
    coordinates: [
      LatLng(35.880773, 127.735688),
      LatLng(35.880789, 127.735823),
      LatLng(35.880725, 127.735744),
      LatLng(35.880843, 127.735799),

    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '요트도착',
    coordinates: [
      LatLng(35.884168, 127.736431),
      LatLng(35.884109, 127.736419),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '쌍쌍도착',
    coordinates: [
      LatLng(35.884876, 127.737032),
      LatLng(35.884822, 127.737071),
      LatLng(35.884906, 127.736939),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '보트도착',
    coordinates: [
      LatLng(35.886974, 127.738511),
      LatLng(35.887002, 127.738444),
      LatLng(35.886962, 127.738399),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '스쿨버스도착',
    coordinates: [
      LatLng(35.888405, 127.742239),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '곤도라도착',
    coordinates: [
      LatLng(35.866091, 127.743408),
      LatLng(35.866023, 127.743406),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '하모니도착',
    coordinates: [
      LatLng(35.865440, 127.744006),
      LatLng(35.865354, 127.743935),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '멜로디도착',
    coordinates: [
      LatLng(35.864351, 127.744570),
      LatLng(35.864272, 127.744520),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '코러스도착',
    coordinates: [
      LatLng(35.875938, 127.752817),
      LatLng(35.875845, 127.752875),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '에코도착',
    coordinates: [
      LatLng(35.882206, 127.745029),
      LatLng(35.882040, 127.745048),
      LatLng(35.881952, 127.745041),
    ],
    type: 'respawn',
    resort: 1,
  ),

  //여기까지가 슬로프 리스폰


];

List<LocationModel> o2 = [
  LocationModel(
    name: '토마토',
    coordinates: [
      LatLng(37.179681, 128.939630),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '키위',
    coordinates: [
      LatLng(37.179294, 128.940281),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '오렌지',
    coordinates: [
      LatLng(37.178288, 128.946270),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.177976, 128.946820),
      LatLng(37.177903, 128.946879),
      LatLng(37.177856, 128.946933),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '체리',
    coordinates: [
      LatLng(37.177335, 128.946598),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '애플',
    coordinates: [
      LatLng(37.176494, 128.948280),
    ],
    type: 'slope',
    resort: 7,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '토마토하차장',
    coordinates: [
      LatLng(37.176416, 128.931141),
      LatLng(37.176409, 128.931074),
    ],
    type: 'respawn',
    resort: 7,
  ),
  LocationModel(
    name: '키위하차장',
    coordinates: [
      LatLng(37.168097, 128.927432),
      LatLng(37.167988, 128.927309),
    ],
    type: 'respawn',
    resort: 7,
  ),
  LocationModel(
    name: '오렌지하차장',
    coordinates: [
      LatLng(37.179465, 128.940719),
    ],
    type: 'respawn',
    resort: 7,
  ),
  LocationModel(
    name: '곤돌라하차장',
    coordinates: [
      LatLng(37.168003, 128.927626),
      LatLng(37.167936, 128.927594),
    ],
    type: 'respawn',
    resort: 7,
  ),
  LocationModel(
    name: '체리하차장',
    coordinates: [
      LatLng(37.171391, 128.939033),
    ],
    type: 'respawn',
    resort: 7,
  ),
  LocationModel(
    name: '애플하차장',
    coordinates: [
      LatLng(37.171335, 128.947355),
    ],
    type: 'respawn',
    resort: 7,
  ),
  //여기까지가 슬로프 리스폰
];
