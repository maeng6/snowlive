import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

const apiKey =
    'ssje34JxzGvclpeVqLM7zAkmQxvaBxiCRCaDT2iZsoiM9xPAeE68HdFkr7Sil8evCwXyg6qVFJ3SRaPylwy7zQ%3D%3D';

class WeatherModel {
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
  var pty;
  var sky;



  //오늘 날짜 19900418 형태로 리턴
  String getSystemTime() {
    return DateFormat("yyyyMMdd").format(_now);
  }

//어제 날짜 19900417 형태로 리턴
  String getYesterdayDate() {
    return DateFormat("yyyyMMdd")
        .format(DateTime.now().subtract(Duration(days: 1)));
  }

  Future<Map<String, dynamic>> parseWeatherData(int nX, int nY) async {
    var getWeatherJson = await getJsonData(nX, nY);

    // API 응답이 없거나 올바르지 않으면 기본값 반환
    if (getWeatherJson == null ||
        getWeatherJson['response']?['body']?['items']?['item'] == null) {
      print('날씨 API 응답 없음 - 기본값 반환');
      return _getDefaultWeatherMap();
    }

    try {
      var items = getWeatherJson['response']['body']['items']['item'] as List;
      this.temp = items.length > 3 ? items[3]['obsrValue'] : '-';
      this.rain = items.length > 2 ? items[2]['obsrValue'] : '0';
      this.wind = items.length > 7 ? items[7]['obsrValue'] : '-';
      this.wet = items.length > 1 ? items[1]['obsrValue'] : '-';
      this.pty = items.isNotEmpty ? items[0]['obsrValue'] : '0';
    } catch (e) {
      print('날씨 데이터 파싱 에러: $e');
      return _getDefaultWeatherMap();
    }

    var getMaxMinTempJson = await getMaxMinJsonData(nX, nY);

    // 최고/최저 온도 API 응답이 없으면 기본값 사용
    if (getMaxMinTempJson == null ||
        getMaxMinTempJson['response']?['body']?['items']?['item'] == null) {
      this.maxTemp = '-';
      this.minTemp = '-';
      this.sky = '1';
    } else {
      try {
        var maxMinItems = getMaxMinTempJson['response']['body']['items']['item'] as List;
        this.maxTemp = maxMinItems.length > 157 ? maxMinItems[157]['fcstValue'] : '-';
        this.minTemp = maxMinItems.length > 48 ? maxMinItems[48]['fcstValue'] : '-';
        this.sky = maxMinItems.length > 114 ? maxMinItems[114]['fcstValue'] : '1';
      } catch (e) {
        print('최고/최저 온도 파싱 에러: $e');
        this.maxTemp = '-';
        this.minTemp = '-';
        this.sky = '1';
      }
    }

    return {
      'temp': this.temp,
      'rain': this.rain,
      'wind': this.wind,
      'wet': this.wet,
      'maxTemp': this.maxTemp,
      'minTemp': this.minTemp,
      'pty': this.pty,
      'sky': this.sky
    };
  }

  Map<String, dynamic> _getDefaultWeatherMap() {
    return {
      'temp': '-',
      'rain': '0',
      'wind': '-',
      'wet': '-',
      'maxTemp': '-',
      'minTemp': '-',
      'pty': '0',
      'sky': '1'
    };
  }

  void currentWeatherDate() {
    if (_now.minute <= 40) {
      if (_now.hour == 0) {
        currentBaseDate =
            DateFormat('yyyyMMdd').format(_now.subtract(Duration(days: 1)));
        currentBaseTime = '2300';
      } else {
        currentBaseDate = DateFormat('yyyyMMdd').format(_now);
        currentBaseTime =
            DateFormat('HH00').format(_now.subtract(Duration(hours: 1)));
      }
    } else {
      currentBaseDate = DateFormat('yyyyMMdd').format(_now);
      currentBaseTime = DateFormat('HH00').format(_now);
    }
  }

  void maxminWeatherDate() {
    if (_now.hour < 2 || _now.hour == 2 && _now.minute < 10) {
      baseDate_2am = getYesterdayDate();
      baseTime_2am = "2300";
    } else {
      baseDate_2am = getSystemTime();
      baseTime_2am = "0200";
    }
  }

  Future<dynamic> getMaxMinJsonData(int nX, int nY) async {
    maxminWeatherDate();

    var date = baseDate_2am;
    var time = baseTime_2am;
    try {
      http.Response response = await http.get(Uri.parse(
          'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst'
              '?serviceKey=$apiKey'
              '&numOfRows=1000'
              '&pageNo=1'
              '&base_date=$date'
              '&base_time=$time'
              '&nx=$nX'
              '&ny=$nY'
              '&dataType=JSON')).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var parsingData = jsonDecode(jsonData);
        return parsingData;
      }
    } catch (e) {
      print('getMaxMinJsonData error: $e');
    }
    return null;
  }

  Future<dynamic> getJsonData(int nX, int nY) async {
    currentWeatherDate();
    var date = currentBaseDate;
    var time = currentBaseTime;
    try {
      http.Response response = await http.get(Uri.parse(
          'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
              '?serviceKey=$apiKey'
              '&numOfRows=1000'
              '&pageNo=1'
              '&base_date=$date'
              '&base_time=$time'
              '&nx=$nX'
              '&ny=$nY'
              '&dataType=JSON')).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var parsingData = jsonDecode(jsonData);
        return parsingData;
      }
    } catch (e) {
      print('getJsonData error: $e');
    }
    return null;
  }

  Color? getWeatherColor(String pty, String sky) {
    String _timeString = DateFormat('HH').format(_now);
    int _timeInt = int.parse(_timeString);
    if (pty == '0' ) {
      if (_timeInt < 7 || _timeInt > 17) {
        return Color(0xFF32314D);
      }else {
        if( sky == '4' ){
          return Color(0xFF707C87);
        } else{
          return Color(0xFFDCEAFF);
        }
      }
    } else if (pty == '1') {
      return Color(0xFF3F668A);
    } else if (pty == '2') {
      return Color(0xFF3F668A);
    } else if (pty == '3') {
      return Color(0xFF9BBFE1);
    } else if (pty == '5') {
      return Color(0xFF3F668A);
    } else if (pty == '6') {
      return Color(0xFF9BBFE1);
    } else if (pty == '7') {
      return Color(0xFF9BBFE1);
    }
  }

  Widget? getWeatherIcon(String pty, String sky) {
    String _timeString = DateFormat('HH').format(_now);
    int _timeInt = int.parse(_timeString);
    if (pty == '0'){
      if(_timeInt < 7 || _timeInt > 17){
        return Image.asset(
          'assets/imgs/weather/icon_weather.png',
          width: 40,
          height: 40,
        );
      }else{
        if(sky == '4' ){
          return Image.asset(
            'assets/imgs/weather/icon_weather_cloud.png',
            width: 40,
            height: 40,
          );
        } else{
          return Image.asset(
            'assets/imgs/weather/icon_weather_sun.png',
            width: 40,
            height: 40,
          );
        }

      }
    } else if(pty == '1'){
      return Image.asset(
        'assets/imgs/weather/icon_weather_rain.png',
        width: 40,
        height: 40,
      );
    } else if (pty == '2') {
      return Image.asset(
        'assets/imgs/weather/icon_weather_rain.png',
        width: 40,
        height: 40,
      );
    } else if (pty == '3') {
      return Image.asset(
        'assets/imgs/weather/icon_weather_snow.png',
        width: 40,
        height: 40,
      );
    } else if (pty == '5') {
      return Image.asset(
        'assets/imgs/weather/icon_weather_rain.png',
        width: 40,
        height: 40,
      );
    } else if (pty == '6') {
      return Image.asset(
        'assets/imgs/weather/icon_weather_rain.png',
        width: 40,
        height: 40,
      );
    } else if (pty == '7') {
      return Image.asset(
        'assets/imgs/weather/icon_weather_snow.png',
        width: 40,
        height: 40,
      );
    }
  }


  Color? getWeatherTextColor(String pty, String sky) {
    String _timeString = DateFormat('HH').format(_now);
    int _timeInt = int.parse(_timeString);
    if (pty == '0' ) {
      if (_timeInt < 7 || _timeInt > 17) {
        return Color(0xFFFFFFFF);
      }else {
        if( sky == '4' ){
          return Color(0xFFFFFFFF);
        } else{
          return Color(0xFF111111);
        }
      }
    } else if (pty == '1') {
      return Color(0xFFFFFFFF);
    } else if (pty == '2') {
      return Color(0xFFFFFFFF);
    } else if (pty == '3') {
      return Color(0xFFFFFFFF);
    } else if (pty == '5') {
      return Color(0xFFFFFFFF);
    } else if (pty == '6') {
      return Color(0xFFFFFFFF);
    } else if (pty == '7') {
      return Color(0xFFFFFFFF);
    }


  }


}