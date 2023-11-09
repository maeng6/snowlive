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

List<LocationModel> welli = [
  LocationModel(
    name: '알파',
    coordinates: [
      LatLng(37.490130, 128.250120),
      LatLng(37.490096, 128.250166),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '뉴알파',
    coordinates: [
      LatLng(37.489916, 128.250191),
      LatLng(37.489888, 128.250225),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '뉴브',
    coordinates: [
      LatLng(37.488712, 128.250181),
      LatLng(37.488673, 128.250169),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '델타',
    coordinates: [
      LatLng(37.490038, 128.249121),
      LatLng(37.489996, 128.249101),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.490630, 128.248932),
      LatLng(37.490612, 128.249009),
      LatLng(37.490575, 128.249100),
      LatLng(37.490554, 128.248929),
      LatLng(37.490515, 128.249035),
      LatLng(37.490720, 128.248990),
      LatLng(37.490695, 128.249070),
      LatLng(37.490670, 128.249145),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '패밀리',
    coordinates: [
      LatLng(37.490825, 128.248507),
      LatLng(37.490788, 128.248483),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '챌린지',
    coordinates: [
      LatLng(37.485622, 128.248713),
      LatLng(37.485584, 128.248689),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '에코',
    coordinates: [
      LatLng(37.485401, 128.241075),
      LatLng(37.485364, 128.241090),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '파이프',
    coordinates: [
      LatLng(37.487715, 128.248340),
      LatLng(37.487700, 128.248400),
      LatLng(37.487685, 128.248455),
      LatLng(37.487670, 128.248505),
      LatLng(37.487660, 128.248563),
      LatLng(37.487635, 128.248290),
      LatLng(37.487620, 128.248345),
      LatLng(37.487605, 128.248395),
      LatLng(37.487590, 128.248455),
      LatLng(37.487575, 128.248515),
    ],
    type: 'slope',
    resort: 9,
  ),
  //여기까지가 리프트승차장


  LocationModel(
    name: '알파하차장',
    coordinates: [
      LatLng(37.487035, 128.253795),
      LatLng(37.487000, 128.253837),
      LatLng(37.486960, 128.253875)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '뉴알파하차장',
    coordinates: [
      LatLng(37.486965, 128.253680),
      LatLng(37.486935, 128.253723),
      LatLng(37.486895, 128.253763)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '뉴브라보하차장',
    coordinates: [
      LatLng(37.481235, 128.249210),
      LatLng(37.481180, 128.249200),
      LatLng(37.481132, 128.249199)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '델타하차장',
    coordinates: [
      LatLng(37.485280, 128.246985),
      LatLng(37.485215, 128.246959),
      LatLng(37.485155, 128.246930)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '파이프하단',
    coordinates: [
      LatLng(37.488835, 128.248863),
      LatLng(37.488818, 128.248918),
      LatLng(37.488805, 128.248975),
      LatLng(37.488790, 128.249030),
      LatLng(37.488775, 128.249088),
      LatLng(37.488725, 128.248813),
      LatLng(37.488710, 128.248865),
      LatLng(37.488695, 128.248925),
      LatLng(37.488678, 128.248982),
      LatLng(37.488660, 128.249040),
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '챌린지하차장',
    coordinates: [
      LatLng(37.480250, 128.244333),
      LatLng(37.480209, 128.244298),
      LatLng(37.480170, 128.244260)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '곤돌라하차장',
    coordinates: [
      LatLng(37.480575, 128.243735),
      LatLng(37.480550, 128.243815),
      LatLng(37.480525, 128.243885),
      LatLng(37.480520, 128.243715),
      LatLng(37.480495, 128.243785),
      LatLng(37.480470, 128.243855),
      LatLng(37.480265, 128.243570),
      LatLng(37.480240, 128.243650),
      LatLng(37.480220, 128.243720),


    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '에코하차장',
    coordinates: [
      LatLng(37.480378, 128.243326),
      LatLng(37.480315, 128.243348),
      LatLng(37.480250, 128.243375)
    ],
    type: 'respawn',
    resort: 9,
  ),
  LocationModel(
    name: '패밀리하차장',
    coordinates: [
      LatLng(37.485570, 128.243608),
      LatLng(37.485525, 128.243570),
      LatLng(37.485485, 128.243530)
    ],
    type: 'respawn',
    resort: 9,
  ),
];

List<LocationModel> alpensia = [
  LocationModel(
    name: '리프트1',
    coordinates: [
      LatLng(37.656490, 128.672209),
      LatLng(37.656447, 128.672181),
      LatLng(37.656407, 128.672149),
    ],
    type: 'slope',
    resort: 3,
  ),
  LocationModel(
    name: '리프트2',
    coordinates: [
      LatLng(37.656178, 128.673159),
      LatLng(37.656130, 128.673159),
      LatLng(37.656082, 128.673160),

    ],
    type: 'slope',
    resort: 3,
  ),
  LocationModel(
    name: '리프트3',
    coordinates: [
      LatLng(37.656224, 128.674666),
      LatLng(37.656179, 128.674658),
      LatLng(37.656130, 128.674650),
    ],
    type: 'slope',
    resort: 3,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '리프트1하차장',
    coordinates: [
      LatLng(37.651842, 128.668980),
      LatLng(37.651795, 128.668955),
      LatLng(37.651755, 128.668920),
    ],
    type: 'respawn',
    resort: 3,
  ),
  LocationModel(
    name: '리프트2하차장',
    coordinates: [
      LatLng(37.650110, 128.673032),
      LatLng(37.650155, 128.673035),
      LatLng(37.650210, 128.673032),
    ],
    type: 'respawn',
    resort: 3,
  ),
  LocationModel(
    name: '리프트3하차장',
    coordinates: [
      LatLng(37.650225, 128.673585),
      LatLng(37.650173, 128.673582),
      LatLng(37.650120, 128.673570),
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
      LatLng(35.428193, 128.984103),
      LatLng(35.428240, 128.984112),
      LatLng(35.428287, 128.984120),
    ],
    type: 'slope',
    resort: 4,
  ),
  LocationModel(
    name: '밸리',
    coordinates: [
      LatLng(35.428290, 128.984862),
      LatLng(35.428335, 128.984836),
      LatLng(35.428380, 128.984808),
    ],
    type: 'slope',
    resort: 4,
  ),
  LocationModel(
    name: '에덴',
    coordinates: [
      LatLng(35.428450, 128.985036),
      LatLng(35.428405, 128.985061),
      LatLng(35.428361, 128.985087),
    ],
    type: 'slope',
    resort: 4,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '아담하차장',
    coordinates: [
      LatLng(35.419550, 128.982816),
      LatLng(35.419595, 128.982825),
      LatLng(35.419640, 128.982831),
    ],
    type: 'respawn',
    resort: 4,
  ),
  LocationModel(
    name: '밸리하차장',
    coordinates: [
      LatLng(35.421632, 128.988640),
      LatLng(35.421675, 128.988615),
      LatLng(35.421720, 128.988589),
    ],
    type: 'respawn',
    resort: 4,
  ),
  LocationModel(
    name: '에덴하차장',
    coordinates: [
      LatLng(35.424013, 128.987456),
      LatLng(35.424055, 128.987435),
      LatLng(35.424100, 128.987412),
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
      LatLng(37.406586, 127.809365),
      LatLng(37.406541, 127.809393),
      LatLng(37.406500, 127.809421),
    ],
    type: 'slope',
    resort: 6,
  ),
  LocationModel(
    name: '마운틴',
    coordinates: [
      LatLng(37.406620, 127.809814),
      LatLng(37.406649, 127.809753),
      LatLng(37.406672, 127.809699),
    ],
    type: 'slope',
    resort: 6,
  ),
  LocationModel(
    name: '플라워',
    coordinates: [
      LatLng(37.407460, 127.809405),
      LatLng(37.407467, 127.809468),
      LatLng(37.407475, 127.809530),
    ],
    type: 'slope',
    resort: 6,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '버드하차장',
    coordinates: [
      LatLng(37.402692, 127.811902),
      LatLng(37.402649, 127.811930),
      LatLng(37.402606, 127.811958),
    ],
    type: 'respawn',
    resort: 6,
  ),
  LocationModel(
    name: '마운틴하차장',
    coordinates: [
      LatLng(37.402415, 127.818596),
      LatLng(37.402388, 127.818652),
      LatLng(37.402359, 127.818705),
    ],
    type: 'respawn',
    resort: 6,
  ),
  LocationModel(
    name: '플라워하차장',
    coordinates: [
      LatLng(37.408150, 127.814560),
      LatLng(37.408159, 127.814623),
      LatLng(37.408167, 127.814682),
    ],
    type: 'respawn',
    resort: 6,
  ),
  //여기까지가 슬로프 리스폰
];

List<LocationModel> jisan = [
  LocationModel(
    name: '실버',
    coordinates: [
      LatLng(37.217570, 127.343691),
      LatLng(37.217533, 127.343653),
      LatLng(37.217495, 127.343615),
    ],
    type: 'slope',
    resort: 10,
  ),
  LocationModel(
    name: '블루',
    coordinates: [
      LatLng(37.217202, 127.344140),
      LatLng(37.217163, 127.344107),
      LatLng(37.217122, 127.344072),
    ],
    type: 'slope',
    resort: 10,
  ),
  LocationModel(
    name: '뉴오렌',
    coordinates: [
      LatLng(37.215937, 127.345540),
      LatLng(37.215890, 127.345525),
      LatLng(37.215843, 127.345510),
    ],
    type: 'slope',
    resort: 10,
  ),
  LocationModel(
    name: '오렌지',
    coordinates: [
      LatLng(37.215620, 127.346574),
      LatLng(37.215575, 127.346555),
      LatLng(37.215528, 127.346538),
    ],
    type: 'slope',
    resort: 10,
  ),
  LocationModel(
    name: '레몬',
    coordinates: [
      LatLng(37.215458, 127.347143),
      LatLng(37.215412, 127.347126),
      LatLng(37.215365, 127.347107),
    ],
    type: 'slope',
    resort: 10,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '실버하차장',
    coordinates: [
      LatLng(37.213202, 127.339352),
      LatLng(37.213165, 127.339314),
      LatLng(37.213125, 127.339277),
    ],
    type: 'respawn',
    resort: 10,
  ),
  LocationModel(
    name: '블루하차장',
    coordinates: [
      LatLng(37.211689, 127.339859),
      LatLng(37.211647, 127.339829),
      LatLng(37.211601, 127.339794),
    ],
    type: 'respawn',
    resort: 10,
  ),
  LocationModel(
    name: '뉴오렌지하차장',
    coordinates: [
      LatLng(37.209700, 127.343643),
      LatLng(37.209652, 127.343629),
      LatLng(37.209602, 127.343610),
    ],
    type: 'respawn',
    resort: 10,
  ),
  LocationModel(
    name: '오렌지하차장',
    coordinates: [
      LatLng(37.211180, 127.344903),
      LatLng(37.211136, 127.344886),
      LatLng(37.211091, 127.344868),
    ],
    type: 'respawn',
    resort: 10,
  ),
  LocationModel(
    name: '레몬하차장',
    coordinates: [
      LatLng(37.213090, 127.346388),
      LatLng(37.213039, 127.346371),
      LatLng(37.212990, 127.346359),
    ],
    type: 'respawn',
    resort: 10,
  ),
  //여기까지가 슬로프 리스폰
];

List<LocationModel> o2 = [
  LocationModel(
    name: '토마토',
    coordinates: [
      LatLng(37.179691, 128.939590),
      LatLng(37.179670, 128.939535),
      LatLng(37.179652, 128.939479),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '키위',
    coordinates: [
      LatLng(37.179285, 128.940243),
      LatLng(37.179248, 128.940202),
      LatLng(37.179213, 128.940153),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '오렌지',
    coordinates: [
      LatLng(37.178293, 128.946208),
      LatLng(37.178305, 128.946148),
      LatLng(37.178323, 128.946084),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.178025, 128.946879),
      LatLng(37.177986, 128.946910),
      LatLng(37.177940, 128.946950),
      LatLng(37.177900, 128.946983),
      LatLng(37.177862, 128.947019),
      LatLng(37.177903, 128.947109),
      LatLng(37.177940, 128.947075),
      LatLng(37.177981, 128.947040),
      LatLng(37.178029, 128.946996),
      LatLng(37.178070, 128.946962),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '체리',
    coordinates: [
      LatLng(37.177290, 128.946478),
      LatLng(37.177255, 128.946435),
      LatLng(37.177225, 128.946389),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '애플',
    coordinates: [
      LatLng(37.176423, 128.948234),
      LatLng(37.176375, 128.948224),
      LatLng(37.176323, 128.948212),
    ],
    type: 'slope',
    resort: 7,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '토마토하차장',
    coordinates: [
      LatLng(37.176400, 128.931050),
      LatLng(37.176378, 128.930990),
      LatLng(37.176355, 128.930938),
    ],
    type: 'respawn',
    resort: 7,
  ),
  LocationModel(
    name: '키위하차장',
    coordinates: [
      LatLng(37.168078, 128.927450),
      LatLng(37.168040, 128.927405),
      LatLng(37.168003, 128.927361),
    ],
    type: 'respawn',
    resort: 7,
  ),
  LocationModel(
    name: '오렌지하차장',
    coordinates: [
      LatLng(37.179564, 128.940740),
      LatLng(37.179577, 128.940680),
      LatLng(37.179590, 128.940620),
    ],
    type: 'respawn',
    resort: 7,
  ),
  LocationModel(
    name: '곤돌라하차장',
    coordinates: [
      LatLng(37.167905, 128.927400),
      LatLng(37.167863, 128.927435),
      LatLng(37.167823, 128.927467),

      LatLng(37.167856, 128.927536),
      LatLng(37.167900, 128.927504),
      LatLng(37.167940, 128.927480),
    ],
    type: 'respawn',
    resort: 7,
  ),
  LocationModel(
    name: '체리하차장',
    coordinates: [
      LatLng(37.171410, 128.939060),
      LatLng(37.171410, 128.939060),
      LatLng(37.171410, 128.939060),
    ],
    type: 'respawn',
    resort: 7,
  ),
  LocationModel(
    name: '애플하차장',
    coordinates: [
      LatLng(37.171265, 128.947340),
      LatLng(37.171217, 128.947331),
      LatLng(37.171168, 128.947325),
    ],
    type: 'respawn',
    resort: 7,
  ),
  //여기까지가 슬로프 리스폰
];

List<LocationModel> gangchon = [
  LocationModel(
    name: 'E',
    coordinates: [
      LatLng(37.820866, 127.589272),
      LatLng(37.820839, 127.589222),
      LatLng(37.820814, 127.589172),
    ],
    type: 'slope',
    resort: 5,
  ),
  LocationModel(
    name: 'D',
    coordinates: [
      LatLng(37.820612, 127.589090),
      LatLng(37.820575, 127.589042),
      LatLng(37.820536, 127.588995),
    ],
    type: 'slope',
    resort: 5,
  ),
  LocationModel(
    name: 'C',
    coordinates: [
      LatLng(37.820253, 127.589300),
      LatLng(37.820215, 127.589255),
      LatLng(37.820177, 127.589211),
    ],
    type: 'slope',
    resort: 5,
  ),
  LocationModel(
    name: 'A1',
    coordinates: [
      LatLng(37.817789, 127.589880),
      LatLng(37.817750, 127.589910),
      LatLng(37.817706, 127.589944),
    ],
    type: 'slope',
    resort: 5,
  ),
  LocationModel(
    name: 'B',
    coordinates: [
      LatLng(37.815413, 127.591440),
      LatLng(37.815410, 127.591376),
      LatLng(37.815405, 127.591311),
    ],
    type: 'slope',
    resort: 5,
  ),
  LocationModel(
    name: 'A',
    coordinates: [
      LatLng(37.815236, 127.591468),
      LatLng(37.815220, 127.591408),
      LatLng(37.815204, 127.591346),
    ],
    type: 'slope',
    resort: 5,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: 'E하차장',
    coordinates: [
      LatLng(37.818094, 127.584645),
      LatLng(37.818125, 127.584696),
      LatLng(37.818150, 127.584745),
    ],
    type: 'respawn',
    resort: 5,
  ),
  LocationModel(
    name: 'D하차장',
    coordinates: [
      LatLng(37.815620, 127.582760),
      LatLng(37.815588, 127.582713),
      LatLng(37.815551, 127.582667),
    ],
    type: 'respawn',
    resort: 5,
  ),
  LocationModel(
    name: 'C하차장',
    coordinates: [
      LatLng(37.815088, 127.583048),
      LatLng(37.815051, 127.583004),
      LatLng(37.815014, 127.582958),
    ],
    type: 'respawn',
    resort: 5,
  ),
  LocationModel(
    name: 'A1하차장',
    coordinates: [
      LatLng(37.816225, 127.591160),
      LatLng(37.816180, 127.591195),
      LatLng(37.816135, 127.591227),
    ],
    type: 'respawn',
    resort: 5,
  ),
  LocationModel(
    name: 'B하차장',
    coordinates: [
      LatLng(37.814883, 127.583113),
      LatLng(37.814883, 127.583050),
      LatLng(37.814882, 127.582985),
    ],
    type: 'respawn',
    resort: 5,
  ),
  LocationModel(
    name: 'A하차장',
    coordinates: [
      LatLng(37.814295, 127.587698),
      LatLng(37.814281, 127.587638),
      LatLng(37.814265, 127.587578),
    ],
    type: 'respawn',
    resort: 5,
  ),
  //여기까지가 슬로프 리스폰
];

List<LocationModel> high1 = [
  LocationModel(
    name: 'M허브',
    coordinates: [
      LatLng(37.207987, 128.825614),
      LatLng(37.207997, 128.825557),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '아테나',
    coordinates: [
      LatLng(37.207280, 128.825622),
      LatLng(37.207367, 128.825658),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: 'H1탑',
    coordinates: [
      LatLng(37.194163, 128.819808),
      LatLng(37.194252, 128.819845),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '제우스',
    coordinates: [
      LatLng(37.203965, 128.839086),
      LatLng(37.203885, 128.839018),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '주피터',
    coordinates: [
      LatLng(37.203962, 128.838770),
      LatLng(37.204040, 128.838837),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '아폴로',
    coordinates: [
      LatLng(37.197646, 128.831682),
      LatLng(37.197610, 128.831570),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '헤라',
    coordinates: [
      LatLng(37.190132, 128.827203),
      LatLng(37.190065, 128.827110),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '빅토리',
    coordinates: [
      LatLng(37.189380, 128.828356),
      LatLng(37.189285, 128.828375),
    ],
    type: 'slope',
    resort: 11,
  ),
  //여기까지가 리프트승차장


  LocationModel(
    name: '마운틴허브하차장',
    coordinates: [
      LatLng(37.194562, 128.819976),
      LatLng(37.194650, 128.820013),

    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '아테나하차',
    coordinates: [
      LatLng(37.194257, 128.820485),
      LatLng(37.194167, 128.820450)
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '아폴로하차장',
    coordinates: [
      LatLng(37.193810, 128.820322),
      LatLng(37.193769, 128.820210)
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '하이원탑하차장',
    coordinates: [
      LatLng(37.183530, 128.816870),
      LatLng(37.183436, 128.816844),
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '헤라하차장',
    coordinates: [
      LatLng(37.183082, 128.817635),
      LatLng(37.183025, 128.817546),
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '주피터하차장',
    coordinates: [
      LatLng(37.196830, 128.832770),
      LatLng(37.196750, 128.832700),
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '제우스하차장',
    coordinates: [
      LatLng(37.189805, 128.827214),
      LatLng(37.189723, 128.827150),
    ],
    type: 'respawn',
    resort: 11,
  ),
  LocationModel(
    name: '빅토리아하차장',
    coordinates: [
      LatLng(37.179165, 128.830065),
      LatLng(37.179075, 128.830080),
    ],
    type: 'respawn',
    resort: 11,
  ),
];


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
      LatLng(37.575211, 128.322084),
      LatLng(37.575200, 128.322262)
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

