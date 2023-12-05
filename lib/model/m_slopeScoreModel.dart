class SlopeScoresModel {
  final Map<String, int> slopeScores;

  SlopeScoresModel(this.slopeScores);
}

Map<String, Map<String, int>> slopeScoresMap = {
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
  // ... 필요한 만큼 이름과 슬로프 점수를 추가로 매핑합니다.
};

Map<String, int> konjiam = {
  'CNP1': 7,
  'CNP2': 8,
  '씽큐B': 7,
  '씽큐1': 7,
  '씽큐2': 7,
  '그램1': 8,
  '그램2': 7,
  '휘센': 5,
  '와이낫': 6,
};
Map<String, int> muju = {
  '카누': 6,
  '라이너': 7,
  '무주E': 8,
  '크루저': 7,
  '요트': 6,
  '보트': 5,
  '스쿨B': 5,
  '쌍쌍': 6,
  '곤도라': 9,
  '에코': 6,
  '코러스': 8,
  '하모니': 8,
  '멜로디': 7,
};
Map<String, int> vivaldi = {
  '발라드': 5,
  '재즈': 6,
  '레게': 6,
  '클래식': 7,
  '테크노2': 8,
  '락': 9,
  '펑키': 7,
  '힙합': 7,
  '테크노1': 7,
  '블루스': 5,
};
Map<String, int> alpensia = {
  '리프트1': 5,
  '리프트2': 7,
  '리프트3': 7,
};
Map<String, int> eden = {
  '아담': 7,
  '밸리': 6,
  '에덴': 5,
};
Map<String, int> gangchon = {
  'E': 6,
  'D': 7,
  'C': 7,
  'A1': 5,
  'B': 7,
  'A': 5,
};
Map<String, int> oak = {
  '버드': 7,
  '마운틴': 6,
  '플라워': 5,
};
Map<String, int> o2 = {
  '토마토': 5,
  '키위': 8,
  '곤돌라': 8,
  '오렌지': 5,
  '체리': 6,
  '애플': 7,
};
Map<String, int> yongpyong = {
  '레드': 8,
  '뉴레드': 8,
  '뉴골드': 7,
  '골드': 7,
  '핑크': 6,
  '옐로우': 5,
  '뉴옐로': 5,
  '그린': 6,
  '뉴그린': 6,
  '실버': 6,
  '블루': 7,
  '레인보': 8,
  '곤돌라': 10,
  '메가G' : 6,
};
Map<String, int> welli = {
  '알파': 5,
  '뉴알파': 5,
  '뉴브': 8,
  '델타': 5,
  '곤돌라': 9,
  '패밀리': 6,
  '챌린지': 6,
  '에코': 6,
  '파이프': 7,
};
Map<String, int> jisan = {
  '실버': 7,
  '블루': 8,
  '뉴오렌': 6,
  '오렌지': 6,
  '레몬': 5,
};
Map<String, int> high1 = {
  'M허브': 8,
  '아테나': 6,
  'H1탑': 8,
  '제우스': 5,
  '주피터': 5,
  '아폴로': 8,
  '헤라': 7,
  '빅토리': 7,
};
Map<String, int> phoenix = {
  '스패': 7,
  '챔피온': 8,
  '파노': 7,
  '환타지': 2,
  '디지': 9,
  '호크1': 6,
  '호크2': 6,
  '펭귄': 6,
  '밸리': 7,
  '마스터': 6,
  '모글': 9,
  '키위': 6,
  '도도': 5,
  '슬스': 7,
  '도브': 7,
  '듀크': 7,
  '파라': 8,
  '파크': 7,
  '파이프': 7,
};

















