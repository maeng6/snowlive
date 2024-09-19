import 'dart:ui';

class CrewListResponse {
  List<Crew>? results;
  CrewListResponse({
    this.results,
  });

  CrewListResponse.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(Crew.fromJson(v));
      });
    }
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
  }
}

List<Color?> crewColorList = [
  Color(0xFFFFA835),
  Color(0xFF2EB6FF),
  Color(0xFFFF54A0),
  Color(0xFF10BB88),
  Color(0xFFB173FF),
  Color(0xFFFF5F18),
  Color(0xFF326EF6),
  Color(0xFFEF0069),
  Color(0xFF019D78),
  Color(0xFF772ED3),
];
