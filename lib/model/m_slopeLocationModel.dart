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
      LatLng(37.488379, 128.252212),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '뉴알파',
    coordinates: [
      LatLng(37.489916, 128.250191),
      LatLng(37.489888, 128.250225),
      LatLng(37.488564, 128.251780),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '뉴브',
    coordinates: [
      LatLng(37.488712, 128.250181),
      LatLng(37.488673, 128.250169),
      LatLng(37.484850, 128.249675),
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
      LatLng(37.485051, 128.246137),
      LatLng(37.484750, 128.245984),
      LatLng(37.484030, 128.245615),
      LatLng(37.482835, 128.245010),
      LatLng(37.482340, 128.244745),
      LatLng(37.485051, 128.246187),
      LatLng(37.485051, 128.246087),

    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '패밀리',
    coordinates: [
      LatLng(37.490825, 128.248507),
      LatLng(37.490788, 128.248483),
      LatLng(37.487674, 128.245553),
      LatLng(37.487059, 128.244978),
      LatLng(37.486610, 128.244563),
      LatLng(37.487700, 128.245502),
      LatLng(37.487650, 128.245600),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '챌린지',
    coordinates: [
      LatLng(37.485622, 128.248713),
      LatLng(37.485584, 128.248689),
      LatLng(37.483165, 128.246675),
      LatLng(37.482495, 128.246125),
      LatLng(37.483165, 128.246625),
      LatLng(37.483165, 128.246725),
    ],
    type: 'slope',
    resort: 9,
  ),
  LocationModel(
    name: '에코',
    coordinates: [
      LatLng(37.485401, 128.241075),
      LatLng(37.485364, 128.241090),
      LatLng(37.482065, 128.242546),
      LatLng(37.482506, 128.242340),
      LatLng(37.482065, 128.242596),
      LatLng(37.482065, 128.242496),
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
      LatLng(37.488225, 128.248725),
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
      LatLng(37.655627, 128.671579),
      LatLng(37.655045, 128.671168),
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
      LatLng(37.653750, 128.673055),
      LatLng(37.653145, 128.673057),
      LatLng(37.653750, 128.673105),
      LatLng(37.653750, 128.673155),

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
      LatLng(37.652960, 128.674040),
      LatLng(37.652675, 128.673990),
      LatLng(37.652960, 128.674090),
      LatLng(37.652960, 128.674000),
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
      LatLng(35.426215, 128.983776),
      LatLng(35.425288, 128.983636),
      LatLng(35.424015, 128.983447),
      LatLng(35.424015, 128.983497),
      LatLng(35.424015, 128.983547),
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
      LatLng(35.426015, 128.986129),
      LatLng(35.424553, 128.986959),
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
      LatLng(35.426300, 128.986185),
      LatLng(35.425252, 128.986759),
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
      LatLng(37.404547, 127.810646),
      LatLng(37.403580, 127.811287),
      LatLng(37.403580, 127.811237),
      LatLng(37.403580, 127.811337),
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
      LatLng(37.403625, 127.815955),
      LatLng(37.403250, 127.816750),
      LatLng(37.403200, 127.816750),
      LatLng(37.403300, 127.816750),
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
      LatLng(37.407630, 127.810555),
      LatLng(37.407905, 127.812825),
      LatLng(37.407955, 127.812825),
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
      LatLng(37.215470, 127.341622),
      LatLng(37.214585, 127.340740),
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
      LatLng(37.214400, 127.341938),
      LatLng(37.213590, 127.341312),
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
      LatLng(37.214735, 127.345138),
      LatLng(37.213575, 127.344786),
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
      LatLng(37.214760, 127.346895),
      LatLng(37.214010, 127.346660),
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
      LatLng(37.177715, 128.934337),
      LatLng(37.177217, 128.933085),
      LatLng(37.177167, 128.933085),
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
      LatLng(37.177458, 128.938095),
      LatLng(37.174198, 128.934370),
      LatLng(37.172175, 128.932075),
      LatLng(37.172175, 128.932025),
      LatLng(37.172135, 128.932125),
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
      LatLng(37.178835, 128.944188),
      LatLng(37.178790, 128.944175),
      LatLng(37.178740, 128.944160),
    ],
    type: 'slope',
    resort: 7,
  ),
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.175650, 128.942475),
      LatLng(37.175688, 128.942447),
      LatLng(37.174390, 128.940030),
      LatLng(37.174430, 128.940000),
      LatLng(37.174355, 128.940065),
      LatLng(37.173340, 128.937985),
      LatLng(37.173385, 128.937955),
      LatLng(37.173295, 128.938010),
      LatLng(37.171340, 128.934115),
      LatLng(37.173295, 128.938010),
      LatLng(37.171295, 128.934140),

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
      LatLng(37.173323, 128.947705),
      LatLng(37.172293, 128.947523),
      LatLng(37.172293, 128.947573),
      LatLng(37.172293, 128.947473),
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
      LatLng(37.819094, 127.586286),
      LatLng(37.819134, 127.586260),
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
      LatLng(37.818633, 127.586560),
      LatLng(37.818670, 127.586526),
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
      LatLng(37.816883, 127.585190),
      LatLng(37.816915, 127.585158),
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
      LatLng(37.815155, 127.588088),
      LatLng(37.815200, 127.588084),
      LatLng(37.815247, 127.588078),
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
      LatLng(37.206775, 128.824950),
      LatLng(37.206757, 128.825000),
      LatLng(37.206733, 128.825057),
      LatLng(37.202721, 128.823445),
      LatLng(37.202740, 128.823390),
      LatLng(37.202755, 128.823335),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '아테나',
    coordinates: [
      LatLng(37.207280, 128.825622),
      LatLng(37.207367, 128.825658),
      LatLng(37.203805, 128.824295),
      LatLng(37.203818, 128.824238),
      LatLng(37.203835, 128.824180),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: 'H1탑',
    coordinates: [
      LatLng(37.192267, 128.819316),
      LatLng(37.192277, 128.819259),
      LatLng(37.192285, 128.819199),
      LatLng(37.186430, 128.817710),
      LatLng(37.186443, 128.817655),
      LatLng(37.186455, 128.817598),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '제우스',
    coordinates: [
      LatLng(37.203965, 128.839086),
      LatLng(37.203885, 128.839018),
      LatLng(37.193537, 128.830398),
      LatLng(37.193564, 128.830342),
      LatLng(37.193590, 128.830292),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '주피터',
    coordinates: [
      LatLng(37.203962, 128.838770),
      LatLng(37.204040, 128.838837),
      LatLng(37.199805, 128.835250),
      LatLng(37.199828, 128.835203),
      LatLng(37.199853, 128.835156),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '아폴로',
    coordinates: [
      LatLng(37.197646, 128.831682),
      LatLng(37.197610, 128.831570),
      LatLng(37.195235, 128.824313),
      LatLng(37.195190, 128.824335),
      LatLng(37.195145, 128.824358),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '헤라',
    coordinates: [
      LatLng(37.190132, 128.827203),
      LatLng(37.190065, 128.827110),
      LatLng(37.187835, 128.823938),
      LatLng(37.187798, 128.823970),
      LatLng(37.187762, 128.824007),
    ],
    type: 'slope',
    resort: 11,
  ),
  LocationModel(
    name: '빅토리',
    coordinates: [
      LatLng(37.189380, 128.828356),
      LatLng(37.189285, 128.828375),
      LatLng(37.186465, 128.828746),
      LatLng(37.186470, 128.828808),
      LatLng(37.186480, 128.828872),
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
      LatLng(37.582792, 128.316935),
      LatLng(37.582500, 128.317010),
      LatLng(37.582650, 128.317010),
      //보강1
      LatLng(37.582199, 128.315484),
      LatLng(37.582289, 128.315384),
      //보강2
      LatLng(37.583006, 128.317706),
      LatLng(37.582856, 128.317806),


    ],
    type: 'slope',
    resort: 12,
  ),//스패_보강
  LocationModel(
    name: '챔피온',
    coordinates: [
      LatLng(37.577447, 128.312582),
      LatLng(37.577507, 128.312765),
      //보강1
      LatLng(37.580739, 128.313688),
      LatLng(37.580739, 128.313788),
      //보강2
      LatLng(37.579743, 128.313346),
      LatLng(37.579743, 128.313456),

      //보강3
      LatLng(37.576947, 128.312082),
      LatLng(37.576947, 128.312282),
      //보강4
      LatLng(37.578007, 128.312805),
      LatLng(37.576947, 128.312282),
      //보강5
      LatLng(37.578047, 128.312782),
      LatLng(37.577947, 128.313082),

    ],
    type: 'slope',
    resort: 12,
  ),//챔피언_보강
  LocationModel(
    name: '파노',
    coordinates: [
      LatLng(37.576205, 128.307921),
      //보강1
      LatLng(37.577496, 128.306663),
      //보강2
      LatLng(37.579989, 128.309350),
      LatLng(37.579789, 128.309470),
      LatLng(37.579589, 128.309470),
    ],
    type: 'slope',
    resort: 12,
  ),//파노_보강
  LocationModel(
    name: '환타지',
    coordinates: [
      LatLng(37.578424, 128.315549),
      LatLng(37.578304, 128.315549),
      //보강1
      LatLng(37.578587, 128.314548),
      LatLng(37.578407, 128.314608),
      //보강2
      LatLng(37.578354, 128.316249),
      LatLng(37.578504, 128.316249),

    ],
    type: 'slope',
    resort: 12,
  ),//환타지_보강
  LocationModel(
    name: '디지',
    coordinates: [
      LatLng(37.577249, 128.315976),
      LatLng(37.577049, 128.315876),
      //보강1
      LatLng(37.576554, 128.313192),
      LatLng(37.576204, 128.313192),
      LatLng(37.576304, 128.313292),
      //보강2
      LatLng(37.577779, 128.316945),
      LatLng(37.577709, 128.316945),
    ],
    type: 'slope',
    resort: 12,
  ),//디지_보강
  LocationModel(
    name: '호크1',
    coordinates: [
      LatLng(37.582952, 128.322142),
      LatLng(37.582892, 128.322142),
      LatLng(37.583360, 128.322664),
    ],
    type: 'slope',
    resort: 12,
  ),//호크1_보강
  LocationModel(
    name: '호크2',
    coordinates: [
      LatLng(37.581191, 128.318740),
      LatLng(37.581309, 128.318394),
      //보강1
      LatLng(37.582067, 128.318844),
      LatLng(37.582067, 128.318544),
      LatLng(37.582067, 128.318344),
      LatLng(37.582067, 128.318144),
    ],
    type: 'slope',
    resort: 12,
  ),//호크2_보강
  LocationModel(
    name: '펭귄',
    coordinates: [
      LatLng(37.580841, 128.322048),
      LatLng(37.580744, 128.322353),
      LatLng(37.580531, 128.322327),
      //보강1
      LatLng(37.579932, 128.320682),
      LatLng(37.579732, 128.320882),
      LatLng(37.579632, 128.320982),
      //보강2
      LatLng(37.581200, 128.323203),
      LatLng(37.581000, 128.323403),
      LatLng(37.580950, 128.323553),
    ],
    type: 'slope',
    resort: 12,
  ),//펭귄_보강
  LocationModel(
    name: '밸리',
    coordinates: [
      LatLng(37.575795, 128.316310),
      LatLng(37.575795, 128.316410),
      //보강1
      LatLng(37.573588, 128.311583),
      //보강2
      LatLng(37.574454, 128.315200),
      LatLng(37.574354, 128.315400),
    ],
    type: 'slope',
    resort: 12,
  ),//밸리_보강
  LocationModel(
    name: '마스터',
    coordinates: [
      LatLng(37.578714, 128.321666),
      LatLng(37.578755, 128.322006),
      //보강1
      LatLng(37.578194, 128.321133),
    ],
    type: 'slope',
    resort: 12,
  ),//마스터_보강
  LocationModel(
    name: '모글',
    coordinates: [
      LatLng(37.577898, 128.322576),
      LatLng(37.577822, 128.322636),
      //보강1
      LatLng(37.578222, 128.323036),
      //보강2
      LatLng(37.578822, 128.323356),
      LatLng(37.578622, 128.323556),
    ],
    type: 'slope',
    resort: 12,
  ),//모글_보강
  LocationModel(
    name: '키위',
    coordinates: [
      LatLng(37.575211, 128.322084),
      LatLng(37.575200, 128.322262),
      //보강1
      LatLng(37.576375, 128.322114),
      LatLng(37.576475, 128.322314),
      //보강2
      LatLng(37.577463, 128.321444),
      LatLng(37.577363, 128.321244),
    ],
    type: 'slope',
    resort: 12,
  ),//키위_보강
  LocationModel(
    name: '도도',
    coordinates: [
      LatLng(37.579435, 128.325868),
      LatLng(37.579035, 128.325828)
    ],
    type: 'slope',
    resort: 12,

  ),//도도_보강안함
  LocationModel(
    name: '슬스',
    coordinates: [
      LatLng(37.577446, 128.324452),
      LatLng(37.577446, 128.324282),
      //보강1
      LatLng(37.576420, 128.323870),
      LatLng(37.576420, 128.323750),
      //보강2
      LatLng(37.578344, 128.324669),
      LatLng(37.578244, 128.324869),
    ],
    type: 'slope',
    resort: 12,
  ),//슬스_보강
  LocationModel(
    name: '도브',
    coordinates: [
      LatLng(37.577617, 128.325377),
      LatLng(37.577636, 128.325822),
      LatLng(37.577636, 128.325722)
    ],
    type: 'slope',
    resort: 12,
  ),//도브_보강안함
  LocationModel(
    name: '듀크',
    coordinates: [
      LatLng(37.575225, 128.324335),
      LatLng(37.575228, 128.324750),
      LatLng(37.574958, 128.325055),
      LatLng(37.574958, 128.324605),
      LatLng(37.574998, 128.324805)
    ],
    type: 'slope',
    resort: 12,
  ),//듀크_보강안함
  LocationModel(
    name: '파라',
    coordinates: [
      LatLng(37.578302, 128.311030),
      LatLng(37.578425, 128.310755),
      //보강1
      LatLng(37.579322, 128.311258),
      LatLng(37.579322, 128.311558),
      //보강2
      LatLng(37.577242, 128.310490),
      LatLng(37.577242, 128.310750),
    ],
    type: 'slope',
    resort: 12,
  ),//파라_보강
  LocationModel(
    name: '파크',
    coordinates: [
      LatLng(37.583143, 128.320304),
      //보강1
      LatLng(37.583263, 128.320604),
    ],
    type: 'slope',
    resort: 12,
  ),//파크_보강
  LocationModel(
    name: '파이프',
    coordinates: [
      LatLng(37.582486, 128.320835),
      LatLng(37.582786, 128.321235),
    ],
    type: 'slope',
    resort: 12,
  ),//파이프_보강
  //여기까지가 슬로프

  LocationModel(
    name: '몽블랑',
    coordinates: [
      LatLng(37.574301, 128.310102),
      LatLng(37.574178, 128.310700),
      LatLng(37.573979, 128.310786),
      //보강1
      LatLng(37.574178, 128.310400),
    ],
    type: 'slopeReset',
    resort: 12,
  ),//몽블랑_보강
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.574722, 128.311445),
      LatLng(37.575722, 128.312945),
    ],
    type: 'slopeReset',
    resort: 12,
  ),//곤돌라_신설
  LocationModel(
    name: '이글리프트',
    coordinates: [
      LatLng(37.574322, 128.311445),
      LatLng(37.575122, 128.312945),
    ],
    type: 'slopeReset',
    resort: 12,
  ),//이글리프트_신설
  LocationModel(
    name: '불새',
    coordinates: [
      LatLng(37.573933, 128.322204),
      //보강1
      LatLng(37.5737833, 128.322154),
    ],
    type: 'slopeReset',
    resort: 12,
  ),//불새_보강
  LocationModel(
    name: '스패하차장',
    coordinates: [
      LatLng(37.581705, 128.312576),
      //보강1
      LatLng(37.581805, 128.312606),
    ],
    type: 'slopeReset',
    resort: 12,
  ),//스패하차장_보강
  //여기까지가 슬로프 리셋

  LocationModel(
    name: '스패로우리프트',
    coordinates: [
      LatLng(37.584573, 128.322432),
      //보강
      LatLng(37.584283, 128.322532),
      LatLng(37.584573, 128.322432),
      LatLng(37.583983, 128.322732),
    ],
    type: 'respawn',
    resort: 12,
  ),//스패로우리프트_보강
  LocationModel(
    name: '호크리프트',
    coordinates: [
      LatLng(37.583800, 128.323746),
      //보강
      LatLng(37.583783, 128.323162),
      LatLng(37.584050, 128.323946),
    ],
    type: 'respawn',
    resort: 12,
  ),//호크리프트_보강
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.582573, 128.323371),
      LatLng(37.583573, 128.324871)
    ],
    type: 'respawn',
    resort: 12,
  ),//곤돌라_보강안함
  LocationModel(
    name: '펭귄리프트',
    coordinates: [
      LatLng(37.581936, 128.325669),
      //보강
      LatLng(37.582236, 128.325069),
      LatLng(37.582036, 128.325369),
    ],
    type: 'respawn',
    resort: 12,
  ),//펭귄리프트_보강
  LocationModel(
    name: '팔콘리프트',
    coordinates: [
      LatLng(37.581653, 128.325976),
      //보강
      LatLng(37.581653, 128.326206),
      LatLng(37.581753, 128.325976),
    ],
    type: 'respawn',
    resort: 12,
  ),//팔콘리프트_보강
  LocationModel(
    name: '도도리프트',
    coordinates: [
      LatLng(37.581688, 128.326575)
    ],
    type: 'respawn',
    resort: 12,
  ),//도도리프트_보강안함
  LocationModel(
    name: '콘돌리프트',
    coordinates: [
      LatLng(37.581361, 128.313497),
      //보강
      LatLng(37.580134, 128.312883),
    ],
    type: 'respawn',
    resort: 12,
  ),//콘돌리프트_보강
  LocationModel(
    name: '이글리프트',
    coordinates: [
      LatLng(37.578830, 128.319583),
      //보강
      LatLng(37.577838, 128.317849),
    ],
    type: 'respawn',
    resort: 12,
  ),//이글리프트_보강
  LocationModel(
    name: '슬스리프트',
    coordinates: [
      LatLng(37.580415, 128.325175)
    ],
    type: 'respawn',
    resort: 12,
  ),//슬스리프트_보강안함
  LocationModel(
    name: '스키하우스',
    coordinates: [
      LatLng(37.583200, 128.325424),
      LatLng(37.584350, 128.324176),
    ],
    type: 'respawn',
    resort: 12,
  ),//스키하우스_신설
  LocationModel(
    name: '파노하단',
    coordinates: [
      LatLng(37.580805, 128.312006),
      LatLng(37.581005, 128.312006),
      LatLng(37.580705, 128.312206),
    ],
    type: 'respawn',
    resort: 12,
  ),//파노하단_신설
];




List<LocationModel> vivaldi = [
  LocationModel(
    name: '발라드',
    coordinates: [
      LatLng(37.643607, 127.686482),
      LatLng(37.643453, 127.686403),
      LatLng(37.643288, 127.686293),
      LatLng(37.643133, 127.686188),
      LatLng(37.643254, 127.685217),
      LatLng(37.643442, 127.685177),
      LatLng(37.643612, 127.685131),
      LatLng(37.643791, 127.685090),
      LatLng(37.643969, 127.685027),
      LatLng(37.644149, 127.684977),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '재즈',
    coordinates: [
      LatLng(37.644110, 127.689563),
      LatLng(37.643943, 127.689461),
      LatLng(37.644304, 127.687915),

      LatLng(37.644304, 127.687915),
      LatLng(37.644474, 127.687996),
      LatLng(37.644636, 127.688100),
      LatLng(37.644806, 127.688194),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '레게',
    coordinates: [
      LatLng(37.641953, 127.691843),
      LatLng(37.641753, 127.691740),
      LatLng(37.641823, 127.689754),
      LatLng(37.641996, 127.689824),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '클래식',
    coordinates: [
      LatLng(37.639030, 127.691542),
      LatLng(37.639876, 127.692492),
      LatLng(37.640454, 127.692896),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '테크노2',
    coordinates: [
      LatLng(37.637135, 127.688713),
      LatLng(37.637690, 127.687370),
      LatLng(37.637900, 127.687587),
      LatLng(37.638030, 127.686387),
      LatLng(37.638308, 127.686565),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '락',
    coordinates: [
      LatLng(37.640033, 127.689322),
      LatLng(37.640992, 127.689023),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '펑키',
    coordinates: [
      LatLng(37.639835, 127.685364),
      LatLng(37.639911, 127.685642),
      LatLng(37.642178, 127.686723),
      LatLng(37.642078, 127.687008),
      //보강
      LatLng(37.640735, 127.685364),
      LatLng(37.640635, 127.685764),
      LatLng(37.640535, 127.685564),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '힙합',
    coordinates: [
      LatLng(37.639402, 127.683084),
      LatLng(37.639572, 127.683304),
      LatLng(37.639756, 127.683534),

      LatLng(37.641260, 127.682950),
      LatLng(37.641284, 127.682566),
      LatLng(37.641264, 127.682186),
      LatLng(37.641240, 127.681822),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '테크노1',
    coordinates: [
      LatLng(37.641224, 127.683888),
      LatLng(37.641444, 127.684084),
      LatLng(37.642914, 127.683300),
      LatLng(37.642988, 127.683015),
    ],
    type: 'slope',
    resort: 2,
  ),
  LocationModel(
    name: '블루스',
    coordinates: [
      LatLng(37.642749, 127.680236),
      LatLng(37.642822, 127.680065),
      LatLng(37.642199, 127.679866),
      LatLng(37.642247, 127.679682),
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
      LatLng(37.639453, 127.684307),
      LatLng(37.641082, 127.683444),
    ],
    type: 'slopeReset',
    resort: 2,
  ),
  LocationModel(
    name: '테크노하차장',
    coordinates: [
      LatLng(37.637571, 127.689622)
    ],
    type: 'slopeReset',
    resort: 2,
  ),
  LocationModel(
    name: '락하차장',
    coordinates: [
      LatLng(37.637812, 127.690087)
    ],
    type: 'slopeReset',
    resort: 2,
  ),
  LocationModel(
    name: '곤돌라하차장',
    coordinates: [
      LatLng(37.637545, 127.690317),
      LatLng(37.637521, 127.689982),
    ],
    type: 'slopeReset',
    resort: 2,
  ),
  //여기까지가 슬로프 리셋


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
      LatLng(37.644188, 127.683064)
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
      LatLng(37.644097, 128.682026),
      LatLng(37.644144, 128.682020),
      LatLng(37.644194, 128.682012),

      LatLng(37.643890, 128.682035),
      LatLng(37.643795, 128.682061),
      LatLng(37.643702, 128.682075),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '뉴레드',
    coordinates: [
      LatLng(37.641733, 128.681636),
      LatLng(37.641690, 128.681646),
      LatLng(37.641647, 128.681655),

      LatLng(37.640107, 128.681974),
      LatLng(37.639101, 128.682165),
      LatLng(37.637539, 128.682529),

      LatLng(37.639227, 128.682124),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '뉴골드',
    coordinates: [
      LatLng(37.638484, 128.686681),
      LatLng(37.638437, 128.686673),
      LatLng(37.636914, 128.686391),
      LatLng(37.634296, 128.685912),
      LatLng(37.634296, 128.685872),
      LatLng(37.633110, 128.685687),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '골드',
    coordinates: [
      LatLng(37.638643, 128.687105),
      LatLng(37.638598, 128.687103),
      LatLng(37.638554, 128.687103),
      LatLng(37.638508, 128.687103),
      LatLng(37.634989, 128.687035),
      LatLng(37.634989, 128.687005),
      LatLng(37.634989, 128.686965),
      LatLng(37.633609, 128.687010),
      LatLng(37.632090, 128.686987),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '핑크',
    coordinates: [
      LatLng(37.644306, 128.680757),
      LatLng(37.644350, 128.680760),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '옐로우',
    coordinates: [
      LatLng(37.644343, 128.680632),
      LatLng(37.644303, 128.680632),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '뉴옐로',
    coordinates: [
      LatLng(37.643809, 128.679328),
      LatLng(37.643769, 128.679348),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '곤돌라',
    coordinates: [
      LatLng(37.641830, 128.678482),
      LatLng(37.641800, 128.678512),
      LatLng(37.641190, 128.678312),
      LatLng(37.641190, 128.678362),
      LatLng(37.641190, 128.678422),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '그린',
    coordinates: [
      LatLng(37.641367, 128.677363),
      LatLng(37.641399, 128.677405),
      LatLng(37.641431, 128.677447),
      LatLng(37.641246, 128.677192),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '메가G',
    coordinates: [
      LatLng(37.640362, 128.677716),
      LatLng(37.640329, 128.677678),
      LatLng(37.640296, 128.677637),
      LatLng(37.640264, 128.677596),
      LatLng(37.640027, 128.677340),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '실버',
    coordinates: [
      LatLng(37.639233, 128.678085),
      LatLng(37.636647, 128.676838),
      LatLng(37.634327, 128.675709),
      LatLng(37.636597, 128.676788),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '블루',
    coordinates: [
      LatLng(37.640127, 128.677967),
      LatLng(37.640094, 128.678010),
      LatLng(37.638948, 128.679422),
      LatLng(37.638908, 128.679442),
      LatLng(37.636836, 128.682057),
    ],
    type: 'slope',
    resort: 8,
  ),
  LocationModel(
    name: '레인보',
    coordinates: [
      LatLng(37.622555, 128.663173),
      LatLng(37.622595, 128.663143),
      LatLng(37.622635, 128.663111),
      LatLng(37.618165, 128.666460),
      LatLng(37.616967, 128.667382),
      LatLng(37.616967, 128.667332),
      LatLng(37.616967, 128.667432),
      LatLng(37.613507, 128.669998),
    ],
    type: 'slope',
    resort: 8,
  ),
  //여기까지가 리프트승차장


  LocationModel(
    name: '레드하차장',
    coordinates: [
      LatLng(37.636173, 128.683194),
      LatLng(37.636217, 128.683187),
      LatLng(37.636262, 128.683180),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '뉴레드하차장',
    coordinates: [
      LatLng(37.637154, 128.682610),
      LatLng(37.637104, 128.682610),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '블루하차장',
    coordinates: [
      LatLng(37.636393, 128.682604),
      LatLng(37.636343, 128.682654),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '브릿지하차장',
    coordinates: [
      LatLng(37.638612, 128.686421),
      LatLng(37.638648, 128.686453),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '뉴골드하차장',
    coordinates: [
      LatLng(37.632155, 128.685505),
      LatLng(37.632112, 128.685495),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '골드하차장',
    coordinates: [
      LatLng(37.623980, 128.686860),
      LatLng(37.623936, 128.686861),
      LatLng(37.623892, 128.686860),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '핑크하차장',
    coordinates: [
      LatLng(37.638664, 128.680253),
      LatLng(37.638620, 128.680250),
      LatLng(37.638571, 128.680248),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '옐로우하차장',
    coordinates: [
      LatLng(37.639983, 128.680252),
      LatLng(37.639940, 128.680250),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '뉴옐로우하차장',
    coordinates: [
      LatLng(37.640694, 128.679147),
      LatLng(37.640740, 128.679147),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '그린하차장',
    coordinates: [
      LatLng(37.637906, 128.672530),
      LatLng(37.637880, 128.672485),
      LatLng(37.637852, 128.672441),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '메가그린하차장',
    coordinates: [
      LatLng(37.636743, 128.673540),
      LatLng(37.636710, 128.673502),
      LatLng(37.636674, 128.673458),
      LatLng(37.636641, 128.673422),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '실버하차장',
    coordinates: [
      LatLng(37.633306, 128.675204),
      LatLng(37.633260, 128.675184),
      LatLng(37.633220, 128.675164),
    ],
    type: 'respawn',
    resort: 8,
  ),
  LocationModel(
    name: '렌보하차장',
    coordinates: [
      LatLng(37.611731, 128.671367),
      LatLng(37.611692, 128.671398),
      LatLng(37.611652, 128.671427),
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
      LatLng(37.329015, 127.283365),
      LatLng(37.329240, 127.284123),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: 'CNP2',
    coordinates: [
      LatLng(37.333535, 127.289413),
      LatLng(37.334314, 127.289978),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '씽큐B',
    coordinates: [
      LatLng(37.332714, 127.287793),
      LatLng(37.332530, 127.287125),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '씽큐1',
    coordinates: [
      LatLng(37.333198, 127.286640),
      LatLng(37.333750, 127.287075),
      LatLng(37.334100, 127.287804),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '씽큐2',
    coordinates: [
      LatLng(37.332220, 127.283939),
      LatLng(37.332485, 127.284015),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '그램1',
    coordinates: [
      LatLng(37.331335, 127.282518),
      LatLng(37.332008, 127.282668),
      LatLng(37.332690, 127.283147),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '그램2',
    coordinates: [
      LatLng(37.330630, 127.280440),
      LatLng(37.331710, 127.280618),
      LatLng(37.332635, 127.281108),
      LatLng(37.333389, 127.281985),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '휘센',
    coordinates: [
      LatLng(37.339032, 127.289568),
      LatLng(37.338711, 127.289750),
      LatLng(37.338879, 127.289899),
    ],
    type: 'slope',
    resort: 0,
  ),
  LocationModel(
    name: '와이낫',
    coordinates: [
      LatLng(37.336030, 127.287985),
      LatLng(37.335710, 127.288070),
      LatLng(37.335350, 127.288164),
      LatLng(37.335245, 127.287130),
      LatLng(37.335495, 127.287007),
      LatLng(37.335765, 127.286910),
    ],
    type: 'slope',
    resort: 0,
  ),
  //여기까지가 슬로프

  LocationModel(
    name: '그램리프트',
    coordinates: [
      LatLng(37.334605, 127.287186),
    ],
    type: 'respawn',
    resort: 0,
  ),
  LocationModel(
    name: '휘센리프트',
    coordinates: [
      LatLng(37.338290, 127.292089),
    ],
    type: 'respawn',
    resort: 0,
  ),
  LocationModel(
    name: '하단1',
    coordinates: [
      LatLng(37.337865, 127.291780),
    ],
    type: 'respawn',
    resort: 0,
  ),
  LocationModel(
    name: '와이낫리프트',
    coordinates: [
      LatLng(37.337420, 127.291590),
    ],
    type: 'respawn',
    resort: 0,
  ),
  LocationModel(
    name: '하단2',
    coordinates: [
      LatLng(37.336995, 127.291850),
    ],
    type: 'respawn',
    resort: 0,
  ),
  LocationModel(
    name: '씽큐CNP리프트',
    coordinates: [
      LatLng(37.336632, 127.292249),
    ],
    type: 'respawn',
    resort: 0,
  ),
  LocationModel(
    name: '하단3',
    coordinates: [
      LatLng(37.336195, 127.292489),
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
      LatLng(35.887625, 127.729082),
      LatLng(35.887670, 127.729065),
      LatLng(35.885297, 127.729858),
      LatLng(35.885288, 127.729802),
      LatLng(35.885282, 127.729750),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '라이너',
    coordinates: [
      LatLng(35.890518, 127.735716),
      LatLng(35.890475, 127.735690),
      LatLng(35.890433, 127.735659),
      LatLng(35.888547, 127.734437),
      LatLng(35.888532, 127.734495),
      LatLng(35.888517, 127.734555),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '무주E',
    coordinates: [
      LatLng(35.890223, 127.736333),
      LatLng(35.890175, 127.736329),
      LatLng(35.890125, 127.736325),
      LatLng(35.878807, 127.735340),
      LatLng(35.878803, 127.735398),
      LatLng(35.878800, 127.735452),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '크루저',
    coordinates: [
      LatLng(35.890243, 127.737141),
      LatLng(35.890195, 127.737137),
      LatLng(35.883135, 127.736086),
      LatLng(35.883130, 127.736144),
      LatLng(35.883127, 127.736202),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '요트',
    coordinates: [
      LatLng(35.890180, 127.737281),
      LatLng(35.890225, 127.737287),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '보트',
    coordinates: [
      LatLng(35.890167, 127.738534),
      LatLng(35.890216, 127.738535),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '스쿨B',
    coordinates: [
      LatLng(35.890657, 127.742280),
      LatLng(35.890610, 127.742284),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '쌍쌍',
    coordinates: [
      LatLng(35.889108, 127.743717),
      LatLng(35.889136, 127.743768),
      LatLng(35.889166, 127.743814),
      LatLng(35.889194, 127.743864),
      LatLng(35.886597, 127.739564),
      LatLng(35.886557, 127.739594),
      LatLng(35.886527, 127.739638),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '곤도라',
    coordinates: [
      LatLng(35.888310, 127.744945),
      LatLng(35.878230, 127.744165),
      LatLng(35.878230, 127.744227),
      LatLng(35.878228, 127.744287),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '에코',
    coordinates: [
      LatLng(35.888365, 127.745143),
      LatLng(35.888315, 127.745145),
      LatLng(35.888265, 127.745147),
      LatLng(35.885871, 127.745029),
      LatLng(35.885871, 127.745087),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '코러스',
    coordinates: [
      LatLng(35.888710, 127.746274),
      LatLng(35.888665, 127.746297),
      LatLng(35.888621, 127.746322),
      LatLng(35.883860, 127.748683),
      LatLng(35.883870, 127.748740),
      LatLng(35.883890, 127.748790),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '하모니',
    coordinates: [
      LatLng(35.875365, 127.753205),
      LatLng(35.875405, 127.753242),
      LatLng(35.875445, 127.753277),
      LatLng(35.873050, 127.751087),
      LatLng(35.873077, 127.751042),
      LatLng(35.873105, 127.750992),
    ],
    type: 'slope',
    resort: 1,
  ),
  LocationModel(
    name: '멜로디',
    coordinates: [
      LatLng(35.871848, 127.751003),
      LatLng(35.871810, 127.750965),
      LatLng(35.871770, 127.750929),
      LatLng(35.869098, 127.748508),
      LatLng(35.869068, 127.748553),
      LatLng(35.869038, 127.748600),
    ],
    type: 'slope',
    resort: 1,
  ),

  //여기까지가 슬로프

  LocationModel(
    name: '카누도착',
    coordinates: [
      LatLng(35.882661, 127.730580),
      LatLng(35.882661, 127.730675),
      LatLng(35.882690, 127.730626),
      LatLng(35.882737, 127.730617),
      LatLng(35.882785, 127.730608),

    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '라이너도착',
    coordinates: [
      LatLng(35.882638, 127.731012),
      LatLng(35.882590, 127.730984),
      LatLng(35.882548, 127.730958),
      LatLng(35.882585, 127.730924),
      LatLng(35.882551, 127.731015),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '무주익스프레스도착',
    coordinates: [
      LatLng(35.876872, 127.735268),
      LatLng(35.876823, 127.735266),
      LatLng(35.876773, 127.735264),
      LatLng(35.876798, 127.735213),
      LatLng(35.876794, 127.735314),

    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '크루저도착',
    coordinates: [
      LatLng(35.880790, 127.735780),
      LatLng(35.880788, 127.735840),
      LatLng(35.880840, 127.735840),
      LatLng(35.880890, 127.735842),

    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '요트도착',
    coordinates: [
      LatLng(35.884176, 127.736422),
      LatLng(35.884176, 127.736478),
      LatLng(35.884200, 127.736372),
      LatLng(35.884225, 127.736425),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '쌍쌍도착',
    coordinates: [
      LatLng(35.884925, 127.737032),
      LatLng(35.884915, 127.737127),
      LatLng(35.884890, 127.737072),
      LatLng(35.884960, 127.737083),
      LatLng(35.884990, 127.737133),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '보트도착',
    coordinates: [
      LatLng(35.886974, 127.738528),
      LatLng(35.886974, 127.738468),
      LatLng(35.887025, 127.738468),
      LatLng(35.887025, 127.738528),
      LatLng(35.887073, 127.738527),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '스쿨버스도착',
    coordinates: [
      LatLng(35.888383, 127.742252),
      LatLng(35.888430, 127.742250),
      LatLng(35.888480, 127.742247),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '곤도라도착',
    coordinates: [
      LatLng(35.866120, 127.743422),
      LatLng(35.866078, 127.743422),
      LatLng(35.866027, 127.743421),
      LatLng(35.865973, 127.743419),
      LatLng(35.865923, 127.743418),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '하모니도착',
    coordinates: [
      LatLng(35.865470, 127.744033),
      LatLng(35.865430, 127.743996),
      LatLng(35.865390, 127.743960),
      LatLng(35.865390, 127.743905),
      LatLng(35.865350, 127.743933),
      LatLng(35.865320, 127.743980),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '멜로디도착',
    coordinates: [
      LatLng(35.864395, 127.744630),
      LatLng(35.864350, 127.744595),
      LatLng(35.864305, 127.744560),
      LatLng(35.864265, 127.744530),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '코러스도착',
    coordinates: [
      LatLng(35.875963, 127.752820),
      LatLng(35.875915, 127.752843),
      LatLng(35.875870, 127.752870),
      LatLng(35.875822, 127.752893),
    ],
    type: 'respawn',
    resort: 1,
  ),
  LocationModel(
    name: '에코도착',
    coordinates: [
      LatLng(35.882190, 127.745054),
      LatLng(35.882140, 127.745055),
      LatLng(35.882090, 127.745057),
      LatLng(35.882040, 127.745059),
    ],
    type: 'respawn',
    resort: 1,
  ),
  //여기까지가 슬로프 리스폰
];

