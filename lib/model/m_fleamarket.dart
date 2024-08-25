
class Fleamarket {
  int? user_id;
  String? uid;
  String? display_name;
  int? crew_id;
  String? profile_image_url_user;
  String? state_msg;
  String? email;
  int? favorite_resort;
  int? instant_resort;
  String? skiorboard;
  String? sex;
  bool? within_boundary;
  bool? reveal_wb;
  String? device_id;
  String? device_token;
  String? major;
  bool? hide_profile;

  Fleamarket({
    this.user_id,
    this.uid,
    this.display_name,
    this.crew_id,
    this.profile_image_url_user,
    this.state_msg,
    this.email,
    this.favorite_resort,
    this.instant_resort,
    this.skiorboard,
    this.sex,
    this.within_boundary,
    this.reveal_wb,
    this.device_id,
    this.device_token,
    this.major,
    this.hide_profile,
  });

  Fleamarket.fromJson(Map<String, dynamic> json) {
    user_id = json['user_id'];
    uid = json['uid'];
    display_name = json['display_name'];
    crew_id = json['crew_id'];
    profile_image_url_user = json['profile_image_url_user'];
    state_msg = json['state_msg'];
    email = json['email'];
    favorite_resort = json['favorite_resort'];
    instant_resort = json['instant_resort'];
    skiorboard = json['skiorboard'];
    sex = json['sex'];
    within_boundary = json['within_boundary'];
    reveal_wb = json['reveal_wb'];
    device_id = json['device_id'];
    device_token = json['device_token'];
    major = json['major'];
    hide_profile = json['hide_profile'];
  }

}
