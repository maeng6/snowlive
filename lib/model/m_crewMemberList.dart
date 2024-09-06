class CrewMemberListResponse {
  int? totalMemberCount;
  int? liveMemberCount;
  List<CrewMember>? crewMembers;

  CrewMemberListResponse({
    this.totalMemberCount,
    this.liveMemberCount,
    this.crewMembers,
  });

  CrewMemberListResponse.fromJson(Map<String, dynamic> json) {
    totalMemberCount = json['total_member_count'];
    liveMemberCount = json['live_member_count'];
    if (json['crew_members'] != null) {
      crewMembers = (json['crew_members'] as List)
          .map((item) => CrewMember.fromJson(item))
          .toList();
    }
  }
}

class CrewMember {
  UserInfo? userInfo;
  String? status;

  CrewMember({this.userInfo, this.status});

  CrewMember.fromJson(Map<String, dynamic> json) {
    userInfo = json['user_info'] != null
        ? UserInfo.fromJson(json['user_info'])
        : null;
    status = json['status'];
  }
}

class UserInfo {
  int? userId;
  String? displayName;
  String? profileImageUrlUser;
  String? favoriteResortNickname;
  bool? withinBoundary;
  bool? revealWb;

  UserInfo({
    this.userId,
    this.displayName,
    this.profileImageUrlUser,
    this.favoriteResortNickname,
    this.withinBoundary,
    this.revealWb,
  });

  UserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    favoriteResortNickname = json['favorite_resort_nickname'];
    withinBoundary = json['within_boundary'];
    revealWb = json['reveal_wb'];
  }
}
