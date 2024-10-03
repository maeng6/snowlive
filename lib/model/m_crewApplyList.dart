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
  ApplicantUserInfo? applicantUserInfo;

  CrewApply({
    this.applyCrewId,
    this.title,
    this.applyDate,
    this.crewId,
    this.applicantUserId,
    this.applicantUserInfo,
  });

  CrewApply.fromJson(Map<String, dynamic> json) {
    applyCrewId = json['apply_crew_id'];
    title = json['title'];
    applyDate = json['apply_date'];
    crewId = json['crew_id'];
    applicantUserId = json['applicant_user_id'];
    applicantUserInfo = json['applicant_user_info'] != null
        ? ApplicantUserInfo.fromJson(json['applicant_user_info'])
        : null;
  }
}

class ApplicantUserInfo {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? favoriteResortNickname;

  ApplicantUserInfo({
    this.userId,
    this.displayName,
    this.profileImageUrlUser,
    this.favoriteResortNickname,
  });

  ApplicantUserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    favoriteResortNickname = json['favorite_resort_nickname'];
  }
}
