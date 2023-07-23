class SlopeScoresModel {
  final Map<String, int> slopeScores;

  SlopeScoresModel(this.slopeScores);
}

Map<String, Map<String, int>> slopeScoresMap = {
  '12': phoenix,
  '2': vivaldi,
  // ... 필요한 만큼 이름과 슬로프 점수를 추가로 매핑합니다.
};

Map<String, int> phoenix = {
  '스패로': 10,
  '챔피온': 20,
  '파노': 30,
  '환타지': 40,
  '디지': 50,
  '호크1': 20,
  '호크2': 20,
  '펭귄': 20,
  '밸리': 20,
  '마스터': 20,
  '모글': 20,
  '키위': 20,
  '도도': 20,
  '슬스': 20,
  '도브': 20,
  '듀크': 20,
  '파라': 20,
  '파크': 20,
  '파이프': 20,
};

Map<String, int> vivaldi = {
  '발라드': 10,
  '재즈': 20,
  '레게': 30,
  '클래식': 40,
  '테크노2': 50,
  '락': 20,
  '펑키': 20,
  '힙합': 20,
  '테크노1': 20,
  '블루스': 20,

};

