import 'dart:ui';

class CrewListResponse {
  List<Crew>? results;

  CrewListResponse({
    this.results,
  });

  CrewListResponse.fromJson(List<dynamic> jsonList) {
    results = jsonList.map((v) => Crew.fromJson(v)).toList();
  }
}

class Crew {
  int? crewId;
  String? crewName;
  String? crewLogoUrl;
  String? color;
  int? baseResortId;
  bool? iskusbf;
  bool? revealInSearch;
  String? description;
  String? createdDate;
  int? crewLeaderUserId; // 크루 리더 필드 추가

  Crew({
    this.crewId,
    this.crewName,
    this.crewLogoUrl,
    this.color,
    this.baseResortId,
    this.iskusbf,
    this.revealInSearch,
    this.description,
    this.createdDate,
    this.crewLeaderUserId, // 크루 리더 필드 추가
  });

  Crew.fromJson(Map<String, dynamic> json) {
    crewId = json['crew_id'];
    crewName = json['crew_name'];
    crewLogoUrl = json['crew_logo_url'];
    color = json['color'];
    baseResortId = json['base_resort_id'];
    iskusbf = json['iskusbf'];
    revealInSearch = json['reveal_in_search'];
    description = json['description'];
    createdDate = json['created_date'];
    crewLeaderUserId = json['crew_leader_user_id']; // 크루 리더 필드 초기화
  }
}

List<Color?> crewColorList = [
  Color(0xFFEA4E4E),
  Color(0xFFFD6D04),
  Color(0xFFFDAF04),
  Color(0xFF37CBA8),
  Color(0xFF68A1F6),
  Color(0xFF0D4CA9),
  Color(0xFF9241F9),
  Color(0xFF5E6B7F),
];
