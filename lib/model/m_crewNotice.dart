class CrewNoticeListResponse {
  List<CrewNotice>? notices;

  CrewNoticeListResponse({this.notices});

  CrewNoticeListResponse.fromJson(List<dynamic> json) {
    notices = json.map((item) => CrewNotice.fromJson(item)).toList();
  }
}

class CrewNotice {
  int? noticeCrewId;
  int? crewId;
  int? authorUserId;
  String? notice;
  DateTime? uploadTime;
  DateTime? updateTime;

  CrewNotice({
    this.noticeCrewId,
    this.crewId,
    this.authorUserId,
    this.notice,
    this.uploadTime,
    this.updateTime,
  });

  CrewNotice.fromJson(Map<String, dynamic> json) {
    noticeCrewId = json['notice_crew_id'];
    crewId = json['crew_id'];
    authorUserId = json['author_user_id'];
    notice = json['notice'];
    uploadTime = DateTime.tryParse(json['upload_time']);
    updateTime = DateTime.tryParse(json['update_time']);
  }
}
