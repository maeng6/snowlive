import 'package:flutter/painting.dart';

/// 슬로프크래프트 지도 정적 데이터.
///
/// 앱(`lib/mobile/view/ranking/v_slope_rush_history.dart:36-414`)에 있던 표를 그대로
/// 옮겼다 — 리조트 슬러그, 서버 슬로프명 → 이미지 키, 마커 좌표(0~1 비율). 지도는
/// `assets/imgs/imgs/slopeRush/{슬러그}/{슬러그}_default.png` 위에 선택 슬로프
/// `{슬러그}_{키}.png`를 겹쳐 그리는 방식이라 이 표가 없으면 아무것도 못 그린다.
///
/// ⚠️ 앱 화면 안의 private 필드였고 그 화면은 `dart:io` 의존이 딸린 모바일 전용이라
/// import할 수 없다 → 데이터만 이 파일로 복제했다. 슬로프가 추가되면 **양쪽을** 고쳐야 한다.

/// 지도 이미지의 가로세로 비(앱과 동일: 780×900).
const double kSlopeCraftMapAspect = 780 / 900;

/// 스키장 선택 드롭다운 목록(앱 `resortOptions`와 같은 순서·이름).
class SlopeCraftResort {
  final int id;
  final String name;

  const SlopeCraftResort({required this.id, required this.name});
}

const List<SlopeCraftResort> kSlopeCraftResorts = [
  SlopeCraftResort(id: 1, name: '곤지암리조트'),
  SlopeCraftResort(id: 2, name: '무주덕유산리조트'),
  SlopeCraftResort(id: 3, name: '비발디파크'),
  SlopeCraftResort(id: 4, name: '알펜시아'),
  SlopeCraftResort(id: 6, name: '엘리시안강촌'),
  SlopeCraftResort(id: 7, name: '오크밸리리조트'),
  SlopeCraftResort(id: 8, name: '오투리조트'),
  SlopeCraftResort(id: 9, name: '용평리조트'),
  SlopeCraftResort(id: 10, name: '웰리힐리파크'),
  SlopeCraftResort(id: 11, name: '지산리조트'),
  SlopeCraftResort(id: 12, name: '하이원리조트'),
  SlopeCraftResort(id: 13, name: '휘닉스파크'),
];

/// 리조트별 이미지 폴더 슬러그.
const Map<int, String> kSlopeCraftResortSlug = {
  1: 'gonjiam',
  2: 'muju',
  3: 'vivaldi',
  4: 'alpensia',
  6: 'gangchon',
  7: 'oakvalley',
  8: 'o2',
  9: 'yongpyong',
  10: 'wellihilli',
  11: 'jisan',
  12: 'high1',
  13: 'phoenix',
};

/// 서버 슬로프명 → 이미지 키.
const Map<int, Map<String, String>> kSlopeCraftSlopeKeys = {
  1: {
    'CNP1': 'cnp1',
    'CNP2': 'cnp2',
    '퓨리1': 'puri1',
    '퓨리3': 'puri3',
    '퓨리2': 'puri2',
    '퓨리B': 'puriB',
    '씽큐1': 'thinq1',
    '씽큐2': 'thinq2',
    '익시오': 'ixio',
    '그램': 'gram',
  },
  2: {
    '알레그로': 'allegro',
    '카덴자': 'cadenza',
    '커넥션': 'connection',
    '이스턴': 'eastern',
    '프리W': 'freeway',
    '미뉴': 'minuet',
    '파노(무)': 'panorama',
    '폴카': 'polka',
    '레이하': 'raidersdown',
    '레이상': 'raidersup',
    '루키힐': 'rookiehill',
    '실크하': 'silkdown',
    '서역': 'silkroad',
    '실크상': 'silkup',
    '스피츠': 'spitz',
    '터보': 'turbo',
    '왈츠': 'waltz',
    '웨스턴': 'western',
    '야마가': 'yamaga',
  },
  3: {
    '발라드': 'ballad',
    '락': 'rock',
    '블루스': 'blues',
    '클래식': 'classic',
    '펑키': 'funky',
    '힙합': 'hiphop',
    '재즈': 'jazz',
    '레게': 'reggae',
    '테크노1': 'techno1',
    '테크노2': 'techno2',
  },
  4: {
    '알파': 'alpha',
    '브라보': 'bravo',
    '찰리': 'charlie',
    '델타': 'delta',
    '에코': 'echo',
    '폭스트롯': 'foxtrot',
  },
  6: {
    '디어': 'deer',
    '드래곤': 'dragon',
    '재규어': 'jaguar',
    '래퍼드': 'leopard',
    '팬더': 'panda',
    '페가수': 'pegasus',
    '퓨마': 'puma',
    '래빗': 'rabbit',
    '제브라': 'zebra',
  },
  7: {
    'F': 'F',
    'G': 'G',
    'I': 'I',
  },
  8: {
    '챌1(오)': 'challenge1',
    '챌2(오)': 'challenge2',
    '챌3(오)': 'challenge3',
    '드림1': 'dream1',
    '드림2': 'dream2',
    '글로리1': 'glory1',
    '글로리2': 'glory2',
    '글로리3': 'glory3',
    '해피': 'happy',
    '헤드': 'head',
    '패션1': 'passion1',
    '패션2': 'passion2',
  },
  9: {
    '블루': 'blue',
    '파크(용)': 'dragonpark',
    '골드F': 'goldfantastic',
    '골드P': 'goldparadise',
    '골드V': 'goldvalley',
    '메가G': 'megagreen',
    '뉴골드': 'newgold',
    '뉴레드': 'newred',
    '핑크': 'pink',
    '렌보1': 'rainbow1',
    '렌보2': 'rainbow2',
    '렌보3': 'rainbow3',
    '렌보4': 'rainbow4',
    '렌보P': 'rainbowparadise',
    '레드': 'red',
    '레골브': 'redgoldbridge',
    '레드P': 'redparadise',
    '실버': 'silver',
    '실버P': 'silverparadise',
    '옐로우': 'yellow',
  },
  10: {
    '알파1': 'alpha1',
    '알파2': 'alpha2',
    '알파3': 'alpha3',
    '브라보1': 'bravo1',
    '브라보2': 'bravo2',
    '챌린지1': 'challenge1',
    '챌린지2': 'challenge2',
    '챌린지3': 'challenge3',
    '챌린지4': 'challenge4',
    '챌린지5': 'challenge5',
    '델타1': 'delta1',
    '델타플': 'deltaplus',
    '에코1': 'echo1',
    '에코2': 'echo2',
    '에코3': 'echo3',
    'S1': 'starexpress1',
    'S2': 'starexpress2',
  },
  11: {
    '1': '1',
    '1-1': '1-1',
    '2': '2',
    '5': '5',
    '6': '6',
    '7': '7',
    '뉴오렌': 'newOrange',
    '3': '3',
  },
  12: {
    '아폴로1': 'apolo1',
    '아폴로3': 'apolo3',
    '아폴로4': 'apolo4',
    '아폴로6': 'apolo6',
    '아테나2': 'athena2',
    '아테나3': 'athena3',
    '헤라1': 'hera1',
    '헤라2': 'hera2',
    '헤라3': 'hera3',
    '빅토1': 'victoria1',
    '빅토2': 'victoria2',
    '빅토3': 'victoria3',
    '제우스1': 'zeus1',
    '제우스2': 'zeus2',
    '제우스3': 'zeus3',
    '제우3-1': 'zeus3-1',
  },
  13: {
    '챔피온': 'champion',
    '디지': 'digi',
    '도도': 'dodo',
    '듀크': 'duke',
    '환타지': 'fantasy',
    '호크1': 'hawk1',
    '호크2': 'hawk2',
    '키위': 'kiwi',
    '모글': 'mogul',
    '파노(휘)': 'panorama',
    '파라': 'paradise',
    '파크(휘)': 'park',
    '펭귄': 'penguin',
    '슬스': 'slopestyle',
    '스패': 'sparrow',
    '밸리': 'valley',
  },
};

/// 마커 좌표(지도 폭·높이에 대한 0~1 비율).
const Map<int, Map<String, Offset>> kSlopeCraftMarkerPos = {
  1: {
    'cnp1': const Offset(0.29, 0.22),
    'cnp2': const Offset(0.30, 0.68),
    'puri1': const Offset(0.41, 0.05),
    'puri3': const Offset(0.47, 0.62),
    'puri2': const Offset(0.46, 0.32),
    'puriB': const Offset(0.33, 0.47),
    'thinq1': const Offset(0.48, 0.16),
    'thinq2': const Offset(0.71, 0.20),
    'ixio': const Offset(0.69, 0.50),
    'gram': const Offset(0.68, 0.90),
  },
  2: {
    'allegro':const Offset(0.45, 0.15),
    'cadenza':const Offset(0.40, 0.25),
    'connection':const Offset(0.35, 0.88),
    'eastern':const Offset(0.55, 0.77),
    'freeway':const Offset(0.75, 0.45),
    'minuet':const Offset(0.27, 0.10),
    'panorama':const Offset(0.76, 0.82),
    'polka':const Offset(0.22, 0.30),
    'raidersdown':const Offset(0.57, 0.62),
    'raidersup':const Offset(0.58, 0.47),
    'rookiehill':const Offset(0.61, 0.88),
    'silkdown':const Offset(0.15, 0.55),
    'silkroad':const Offset(0.88, 0.55),
    'silkup':const Offset(0.10, 0.20),
    'spitz':const Offset(0.35, 0.65),
    'turbo':const Offset(0.90, 0.75),
    'waltz':const Offset(0.10, 0.40),
    'western':const Offset(0.85, 0.65),
    'yamaga':const Offset(0.73, 0.68),
  },
  3: {
    'ballad': const Offset(0.43, 0.72),
    'blues': const Offset(0.78, 0.82),
    'rock': const Offset(0.33, 0.30),
    'classic': const Offset(0.10, 0.22),
    'funky': const Offset(0.36, 0.53),
    'hiphop': const Offset(0.70, 0.60),
    'jazz': const Offset(0.15, 0.62),
    'reggae': const Offset(0.15, 0.42),
    'techno1': const Offset(0.60, 0.40),
    'techno2': const Offset(0.54, 0.20),
  },
  4: {
    'alpha': const Offset(0.80, 0.40),
    'bravo': const Offset(0.65, 0.05),
    'charlie': const Offset(0.47, 0.30),
    'delta': const Offset(0.40, 0.45),
    'echo': const Offset(0.23, 0.55),
    'foxtrot': const Offset(0.10, 0.40),
  },
  6: {
    'deer': const Offset(0.45, 0.33),
    'dragon': const Offset(0.15, 0.10),
    'jaguar': const Offset(0.85, 0.70),
    'leopard': const Offset(0.68, 0.45),
    'panda': const Offset(0.15, 0.82),
    'pegasus': const Offset(0.50, 0.65),
    'puma': const Offset(0.50, 0.20),
    'rabbit': const Offset(0.10, 0.67),
    'zebra': const Offset(0.50, 0.78),

  },
  7: {
    'F': const Offset(0.64, 0.40),
    'G': const Offset(0.87, 0.50),
    'I': const Offset(0.47, 0.60),
  },
  8: {
    'challenge1': const Offset(0.15, 0.70),
    'challenge2': const Offset(0.33, 0.75),
    'challenge3': const Offset(0.35, 0.60),
    'dream1': const Offset(0.60, 0.83),
    'dream2': const Offset(0.75, 0.55),
    'glory1': const Offset(0.16, 0.86),
    'glory2': const Offset(0.36, 0.87),
    'glory3': const Offset(0.55, 0.10),
    'happy': const Offset(0.55, 0.65),
    'head': const Offset(0.37, 0.22),
    'passion1': const Offset(0.58, 0.34),
    'passion2': const Offset(0.55, 0.45),
  },
  9: {
    'blue': const Offset(0.32, 0.70),
    'dragonpark': const Offset(0.53, 0.75),
    'goldfantastic': const Offset(0.05, 0.52),
    'goldparadise': const Offset(0.30, 0.35),
    'goldvalley': const Offset(0.21, 0.28),
    'megagreen': const Offset(0.68, 0.73),
    'newgold': const Offset(0.24, 0.47),
    'newred': const Offset(0.32, 0.58),
    'pink': const Offset(0.27, 0.81),
    'rainbow1': const Offset(0.65, 0.05),
    'rainbow2': const Offset(0.75, 0.25),
    'rainbow3': const Offset(0.87, 0.35),
    'rainbow4': const Offset(0.90, 0.20),
    'rainbowparadise': const Offset(0.50, 0.20),
    'red': const Offset(0.20, 0.70),
    'redgoldbridge': const Offset(0.17, 0.41),
    'redparadise': const Offset(0.16, 0.60),
    'silver': const Offset(0.60, 0.60),
    'silverparadise': const Offset(0.45, 0.58),
    'yellow': const Offset(0.36, 0.84),
  },
  10: {
    'alpha1': const Offset(0.16, 0.80),
    'alpha2': const Offset(0.17, 0.67),
    'alpha3': const Offset(0.32, 0.72),
    'bravo1': const Offset(0.26, 0.53),
    'bravo2': const Offset(0.34, 0.46),
    'challenge1': const Offset(0.32, 0.28),
    'challenge2': const Offset(0.42, 0.14),
    'challenge3': const Offset(0.47, 0.32),
    'challenge4': const Offset(0.55, 0.45),
    'challenge5': const Offset(0.60, 0.26),
    'delta1': const Offset(0.43, 0.66),
    'deltaplus': const Offset(0.57, 0.73),
    'echo1': const Offset(0.67, 0.36),
    'echo2': const Offset(0.74, 0.20),
    'echo3': const Offset(0.85, 0.27),
    'starexpress1': const Offset(0.84, 0.10),
    'starexpress2': const Offset(0.76, 0.64),
  },
  11: {
    '1': const Offset(0.19, 0.70),
    '1-1': const Offset(0.05, 0.52),
    '2': const Offset(0.14, 0.32),
    '5': const Offset(0.47, 0.30),
    '6': const Offset(0.64, 0.40),
    '7': const Offset(0.74, 0.64),
    'newOrange': const Offset(0.10, 0.10),
    '3': const Offset(0.27, 0.27),
  },
  12: {
    'apolo1': const Offset(0.74, 0.40),
    'apolo3': const Offset(0.63, 0.51),
    'apolo4': const Offset(0.49, 0.56),
    'apolo6': const Offset(0.53, 0.70),
    'athena2': const Offset(0.60, 0.85),
    'athena3': const Offset(0.40, 0.84),
    'hera1': const Offset(0.59, 0.18),
    'hera2': const Offset(0.68, 0.23),
    'hera3': const Offset(0.58, 0.34),
    'victoria1': const Offset(0.37, 0.34),
    'victoria2': const Offset(0.39, 0.20),
    'victoria3': const Offset(0.42, 0.07),
    'zeus1': const Offset(0.60, 0.05),
    'zeus2': const Offset(0.74, 0.10),
    'zeus3': const Offset(0.35, 0.50),
    'zeus3-1': const Offset(0.30, 0.73),
  },
  13: {
    'champion': const Offset(0.55, 0.22),
    'digi': const Offset(0.48, 0.34),
    'dodo': const Offset(0.11, 0.70),
    'duke': const Offset(0.06, 0.57),
    'fantasy': const Offset(0.55, 0.45),
    'hawk1': const Offset(0.52, 0.76),
    'hawk2': const Offset(0.55, 0.59),
    'kiwi': const Offset(0.12, 0.42),
    'mogul': const Offset(0.23, 0.60),
    'panorama': const Offset(0.73, 0.08),
    'paradise': const Offset(0.75, 0.31),
    'park': const Offset(0.64, 0.71),
    'penguin': const Offset(0.40, 0.70),
    'slopestyle': const Offset(0.20, 0.76),
    'sparrow': const Offset(0.78, 0.56),
    'valley': const Offset(0.34, 0.12),
  },
};

/// 지도 기본 이미지. 슬러그가 없는 리조트는 지도를 그릴 수 없다(null).
String? slopeCraftDefaultAsset(int resortId) {
  final slug = kSlopeCraftResortSlug[resortId];
  if (slug == null) return null;
  return 'assets/imgs/imgs/slopeRush/$slug/${slug}_default.png';
}

/// 선택한 슬로프를 강조하는 겹침 이미지.
String? slopeCraftSlopeAsset(int resortId, String slopeKey) {
  final slug = kSlopeCraftResortSlug[resortId];
  if (slug == null) return null;
  return 'assets/imgs/imgs/slopeRush/$slug/${slug}_$slopeKey.png';
}

/// 서버가 준 슬로프명(별명 우선)으로 이미지 키를 찾는다.
String? slopeCraftSlopeKey(int resortId, String slopeName) =>
    kSlopeCraftSlopeKeys[resortId]?[slopeName];

/// 이미지 키 → 서버 슬로프명(마커 라벨에 쓴다).
String? slopeCraftSlopeName(int resortId, String slopeKey) {
  final table = kSlopeCraftSlopeKeys[resortId];
  if (table == null) return null;
  for (final entry in table.entries) {
    if (entry.value == slopeKey) return entry.key;
  }
  return null;
}
