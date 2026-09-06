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
  CrewInfo? crewInfo; // crewinfo를 추가

  CrewApply({
    this.applyCrewId,
    this.title,
    this.applyDate,
    this.crewId,
    this.applicantUserId,
    this.applicantUserInfo,
    this.crewInfo, // 추가
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
    crewInfo = json['crewinfo'] != null ? CrewInfo.fromJson(json['crewinfo']) : null; // crewinfo 추가
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

class CrewInfo {
  int? crewId;
  String? crewName;
  String? crewLogoUrl;
  String? color;
  String? description;
  int? baseResortId;

  CrewInfo({
    this.crewId,
    this.crewName,
    this.crewLogoUrl,
    this.color,
    this.description,
    this.baseResortId,
  });

  CrewInfo.fromJson(Map<String, dynamic> json) {
    crewId = json['crew_id'];
    crewName = json['crew_name'];
    crewLogoUrl = json['crew_logo_url'];
    color = json['color'];
    description = json['description'];
    baseResortId = json['base_resort_id'];
  }
}
