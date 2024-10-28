class TreasureRecord {
  late int treasureRecordId;
  late int userId;
  late int slopeId;
  late String prize;
  late int treasureHuntNum;
  late DateTime passTime;
  late Coordinates coordinates;
  late bool active;
  late String treasureHuntPrize;
  late int? treasureHuntPrizeGrade;
  late bool treasureHuntAlive;

  // 기본 생성자
  TreasureRecord() {
    treasureRecordId = 0;
    userId = 0;
    slopeId = 0;
    prize = '';
    treasureHuntNum = 0;
    passTime = DateTime.now();
    coordinates = Coordinates();
    active = true;
    treasureHuntPrize = '';
    treasureHuntPrizeGrade = null;
    treasureHuntAlive = false;
  }

  // fromJson 생성자
  TreasureRecord.fromJson(Map<String, dynamic> json) {
    treasureRecordId = json['treasure_record_id'] ?? 0;
    userId = json['user_id'] ?? 0;
    slopeId = json['slope_id'] ?? 0;
    prize = json['prize'] ?? '';
    treasureHuntNum = json['treasure_hunt_num'] ?? 0;
    passTime = json['pass_time'] != null ? DateTime.parse(json['pass_time']) : DateTime.now();
    coordinates = json['coordinates'] != null ? Coordinates.fromJson(json['coordinates']) : Coordinates();
    active = json['active'] ?? true;
    treasureHuntPrize = json['treasure_hunt_prize'] ?? '';
    treasureHuntPrizeGrade = json['treasure_hunt_prize_grade'];
    treasureHuntAlive = json['treasure_hunt_alive'] ?? false;
  }
}

class Coordinates {
  late double latitude;
  late double longitude;

  // 기본 생성자
  Coordinates() {
    latitude = 0.0;
    longitude = 0.0;
  }

  // fromJson 생성자
  Coordinates.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'] ?? 0.0;
    longitude = json['longitude'] ?? 0.0;
  }
}

class TreasureRecordResponse {
  late List<TreasureRecord> treasureRecords;

  // 기본 생성자
  TreasureRecordResponse() {
    treasureRecords = [];
  }

  // fromJson 생성자
  TreasureRecordResponse.fromJson(Map<String, dynamic> json) {
    if (json['treasure_records'] != null) {
      treasureRecords = (json['treasure_records'] as List)
          .map((record) => TreasureRecord.fromJson(record))
          .toList();
    } else {
      treasureRecords = [];
    }
  }
}
