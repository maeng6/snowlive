class CrewMemberListResponse {
  int? totalMemberCount;
  int? liveMemberCount;
  List<CrewMember>? crewMembers;

  CrewMemberListResponse({
    this.totalMemberCount,
    this.liveMemberCount,
    this.crewMembers,
  });

  // JSON 데이터를 파싱하는 메소드
  CrewMemberListResponse.fromJson(Map<String, dynamic> json) {
    totalMemberCount = json['total_member_count'];
    liveMemberCount = json['live_member_count'];

    // crew_members 리스트를 처리
    if (json['crew_members'] != null && json['crew_members'] is List) {
      crewMembers = (json['crew_members'] as List)
          .map((item) => CrewMember.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      crewMembers = [];
    }
  }
}

class CrewMember {
  UserInfo? userInfo;
  String? status;

  CrewMember({this.userInfo, this.status});

  // JSON 데이터를 파싱하는 메소드
  CrewMember.fromJson(Map<String, dynamic> json) {
    userInfo = json['user_info'] != null
        ? UserInfo.fromJson(json['user_info'] as Map<String, dynamic>)
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

  // JSON 데이터를 파싱하는 메소드
  UserInfo.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    displayName = json['display_name'];
    profileImageUrlUser = json['profile_image_url_user'];
    favoriteResortNickname = json['favorite_resort_nickname'];
    withinBoundary = json['within_boundary'];
    revealWb = json['reveal_wb'];
  }
}
