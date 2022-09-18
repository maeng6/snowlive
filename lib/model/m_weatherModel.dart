import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

const apiKey =
    'ssje34JxzGvclpeVqLM7zAkmQxvaBxiCRCaDT2iZsoiM9xPAeE68HdFkr7Sil8evCwXyg6qVFJ3SRaPylwy7zQ%3D%3D';

class WeatherModel{

  dynamic currentBaseTime; //시간
  dynamic currentBaseDate; //날짜
  dynamic baseDate_2am;
  dynamic baseTime_2am;

  var _now = DateTime.now();
  var temp;
  var rain;
  var wind;
  var wet;
  var maxTemp;
  var minTemp;

  //오늘 날짜 19900418 형태로 리턴
  String getSystemTime(){
    return DateFormat("yyyyMMdd").format(_now);
  }

//어제 날짜 19900417 형태로 리턴
  String getYesterdayDate(){
    return DateFormat("yyyyMMdd").format(DateTime.now().subtract(Duration(days:1)));
  }

  Future<Map> parseWeatherData(int nX, int nY) async {
    var getWeatherJson = await getJsonData(nX,nY);
    var getMaxMinTempJson = await getMaxMinJsonData(nX,nY);
    this.temp = getWeatherJson['response']['body']['items']['item'][3]['obsrValue'];
    this.rain = getWeatherJson["response"]["body"]["items"]["item"][2]["obsrValue"];
    this.wind = getWeatherJson["response"]["body"]["items"]["item"][7]["obsrValue"];
    this.wet = getWeatherJson["response"]["body"]["items"]["item"][1]["obsrValue"];
    this.maxTemp = getMaxMinTempJson["response"]["body"]["items"]["item"][157]["fcstValue"];
    this.minTemp = getMaxMinTempJson["response"]["body"]["items"]["item"][48]["fcstValue"];
    Map<String, dynamic> weatherInfoMap = {
      'temp': this.temp,
      'rain': this.rain,
      'wind': this.wind,
      'wet': this.wet,
      'maxTemp': this.maxTemp,
      'minTemp': this.minTemp
    };
    return weatherInfoMap;
  }

  void currentWeatherDate() {
    if (_now.minute <= 40){
      if (_now.hour == 0) {
        currentBaseDate = DateFormat('yyyyMMdd').format(_now.subtract(Duration(days:1)));
        currentBaseTime = '2300';
      } else {
        currentBaseDate = DateFormat('yyyyMMdd').format(_now);
        currentBaseTime = DateFormat('HH00').format(_now.subtract(Duration(hours:1)));
      }
    }
    else {
      currentBaseDate = DateFormat('yyyyMMdd').format(_now);
      currentBaseTime = DateFormat('HH00').format(_now);
    }
  }
  void maxminWeatherDate() {
    if(_now.hour < 2 || _now.hour == 2 && _now.minute < 10){
      baseDate_2am = getYesterdayDate();
      baseTime_2am = "2300";
    } else {
      baseDate_2am = getSystemTime();
      baseTime_2am = "0200";
    }
  }

  Future<dynamic> getMaxMinJsonData(int nX, int nY) async{

    maxminWeatherDate();
    var date = baseDate_2am;
    var time = baseTime_2am;
    print(date);
    print(time);

    http.Response response = await http.get(
        Uri.parse('http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst'
            '?serviceKey=$apiKey'
            '&numOfRows=1000'
            '&pageNo=1'
            '&base_date=$date'
            '&base_time=$time'
            '&nx=$nX'
            '&ny=$nY'
            '&dataType=JSON'));
    if (response.statusCode == 200) {
      String jsonData = response.body;
      var parsingData = jsonDecode(jsonData);
      return parsingData;
    }
  }
  Future<dynamic> getJsonData(int nX, int nY) async{

    currentWeatherDate();
    var date = currentBaseDate;
    var time = currentBaseTime;

    http.Response response = await http.get(
        Uri.parse('https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
            '?serviceKey=$apiKey'
            '&numOfRows=1000'
            '&pageNo=1'
            '&base_date=$date'
            '&base_time=$time'
            '&nx=$nX'
            '&ny=$nY'
            '&dataType=JSON'));
    if (response.statusCode == 200) {
      String jsonData = response.body;
      var parsingData = jsonDecode(jsonData);
      return parsingData;
    }
  }

}