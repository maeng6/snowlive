
class ResortHomeModel {
  late String instantResortName;
  late var nx;
  late var ny;
  late String urlResortHome;
  late String urlNaver;
  late String urlWebcam;
  late String urlSlope;
  late String urlBus;
  late var todayTotalScore;
  late var dailyTotalCount;
  late var timeInfo_maxCount;
  late List<SlopeCountInfo> slopeCountInfoToday;
  late Map<String, dynamic> timeCountInfoToday;

  ResortHomeModel(){
    instantResortName = '';
    nx=0;
    ny=0;
    urlResortHome = '';
    urlNaver = '';
    urlWebcam = '';
    urlSlope = '';
    urlBus = '';
    todayTotalScore = 0.0;
    dailyTotalCount = 0;
    timeInfo_maxCount = 0;
    slopeCountInfoToday = const [];
    timeCountInfoToday = {};
  }


  ResortHomeModel.fromJson(dynamic json) {
    instantResortName = json['instant_resort_info']['instant_resort_name'];
    nx = json['instant_resort_info']['nx'];
    ny = json['instant_resort_info']['ny'];
    urlResortHome = json['instant_resort_info']['url_resort_home'];
    urlNaver = json['instant_resort_info']['url_naver'];
    urlWebcam = json['instant_resort_info']['url_webcam'];
    urlSlope = json['instant_resort_info']['url_slope'];
    urlBus = json['instant_resort_info']['url_bus'];
    todayTotalScore = json['today_total_score'];
    dailyTotalCount = json['daily_total_count'];
    slopeCountInfoToday = (json['slope_count_info_today'] as List)
        .map((e) => SlopeCountInfo.fromJson(e))
        .toList();
    timeCountInfoToday = {
      "00-08": json['time_count_info_today'][0],
      "08-10": json['time_count_info_today'][1],
      "10-12": json['time_count_info_today'][2],
      "12-14": json['time_count_info_today'][3],
      "14-16": json['time_count_info_today'][4],
      "16-18": json['time_count_info_today'][5],
      "18-20": json['time_count_info_today'][6],
      "20-22": json['time_count_info_today'][7],
      "22-00": json['time_count_info_today'][8],
    };
    timeInfo_maxCount = timeInfo_maxCount = timeCountInfoToday.values.reduce((a, b) => a > b ? a : b);
  }

}

class SlopeCountInfo {
  late String slope;
  late int count;
  late double ratio;

  SlopeCountInfo.fromJson(dynamic json) {
    slope = json['slope'];
    count = json['count'];
    ratio = json['ratio'];
  }
}