class CrewApplyListResponse {
  List<CrewApply>? crewApplyList;

  CrewApplyListResponse({this.crewApplyList});

  CrewApplyListResponse.fromJson(List<dynamic> json) {
    if (json != null) {
      crewApplyList = json.map((e) => CrewApply.fromJson(e)).toList();
    }
  }
}

class CrewApply {
  int? applyCrewId;
  String? title;
  String? applyDate;
  int? crewId;
  int? applicantUserId;

  CrewApply({
    this.applyCrewId,
    this.title,
    this.applyDate,
    this.crewId,
    this.applicantUserId,
  });

  CrewApply.fromJson(Map<String, dynamic> json) {
    applyCrewId = json['apply_crew_id'];
    title = json['title'];
    applyDate = json['apply_date'];
    crewId = json['crew_id'];
    applicantUserId = json['applicant_user_id'];
  }
}
