import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:com.snowlive/model/m_weatherModel.dart';

class ResortModelController extends GetxController{

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxInt? _index=0.obs;
  RxInt? _instantIndex=0.obs;
  RxString _resortName=''.obs;
  RxString? _resortUrl=''.obs;
  RxString? _webcamUrl=''.obs;
  RxString? _slopeUrl=''.obs;
  RxString? _naverUrl=''.obs;
  RxDouble? _latitude=0.0.obs;
  RxDouble? _longitude=0.0.obs;
  RxInt? _nX=0.obs;
  RxInt? _nY=0.obs;
  RxString? _resortTemp=''.obs;
  RxString? _resortRain=''.obs;
  RxString? _resortWind=''.obs;
  RxString? _resortWet=''.obs;
  RxString? _resortMaxTemp=''.obs;
  RxString? _resortMinTemp=''.obs;
  RxBool isLoading = false.obs;
  RxString? _resortPty=''.obs;
  RxString? _resortSky=''.obs;
  dynamic _weatherColors;
  dynamic _weatherIcons;
  RxString? _resortLogo=''.obs;
  RxString? _busUrl=''.obs;


  Future<void> getSelectedResort(int? resortNum) async{
    isLoading.value = true;
    try {
      ResortModel resortModel = ResortModel();
      WeatherModel weatherModel = WeatherModel();
      ResortModel selectedResort = resortModel.resortModelSelection(resortNum);
      this._index!.value = selectedResort.index!;
      this._instantIndex!.value = selectedResort.index!;
      this._resortName.value = selectedResort.resortName!;
      this._resortUrl!.value = selectedResort.resortUrl!;
      this._webcamUrl!.value = selectedResort.webcamUrl!;
      this._naverUrl!.value = selectedResort.naverUrl!;
      this._slopeUrl!.value = selectedResort.slopeUrl!;
      this._busUrl!.value = selectedResort.busUrl!;
      this._latitude!.value = selectedResort.latitude!;
      this._longitude!.value = selectedResort.longitude!;
      this._nX!.value = selectedResort.nX!;
      this._nY!.value = selectedResort.nY!;
      Map weatherInfo = await weatherModel.parseWeatherData(
          _nX!.value, _nY!.value);
      this._resortTemp!.value = weatherInfo['temp'];
      this._resortRain!.value = weatherInfo['rain'];
      this._resortWind!.value = weatherInfo['wind'];
      this._resortWet!.value = weatherInfo['wet'];
      this._resortMaxTemp!.value = weatherInfo['maxTemp'];
      this._resortMinTemp!.value = weatherInfo['minTemp'];
      this._resortPty!.value = weatherInfo['pty'];
      this._resortSky!.value = weatherInfo['sky'];
      this._weatherColors = weatherModel.getWeatherColor(
          this._resortPty!.value, this._resortSky!.value);
      this._weatherIcons = weatherModel.getWeatherIcon(
          this._resortPty!.value, this._resortSky!.value);
      this._resortLogo!.value = selectedResort.resortLogo!;
    }catch(e){
    }
    isLoading.value = false;

  }

  Future<void> getFavoriteResort(int? resortNum) async{
    isLoading.value = true;
    try {
      ResortModel resortModel = ResortModel();
      ResortModel selectedResort = resortModel.resortModelSelection(resortNum);
      this._index!.value = selectedResort.index!;
      this._instantIndex!.value = selectedResort.index!;
      this._latitude!.value = selectedResort.latitude!;
      this._longitude!.value = selectedResort.longitude!;
    }catch(e){
    }
    isLoading.value = false;

  }


  int? get index => _index!.value;
  int? get instantIndex => _instantIndex!.value;
  String? get resortName => _resortName.value;
  String? get resortUrl => _resortUrl!.value;
  String? get webcamUrl => _webcamUrl!.value;
  String? get slopeUrl => _slopeUrl!.value;
  String? get naverUrl => _naverUrl!.value;
  String? get busUrl => _busUrl!.value;
  double get latitude => _latitude!.value;
  double get longitude => _longitude!.value;
  String? get resortTemp => _resortTemp!.value;
  String? get resortRain => _resortRain!.value;
  String? get resortWind => _resortWind!.value;
  String? get resortWet => _resortWet!.value;
  String? get resortMaxTemp => _resortMaxTemp!.value;
  String? get resortMinTemp => _resortMinTemp!.value;
  String? get resortPty => _resortPty!.value;
  String? get resortSky => _resortSky!.value;
  String? get resortLogo => _resortLogo!.value;
  dynamic get weatherColors => _weatherColors;
  dynamic get weatherIcons => _weatherIcons;

  String getResortName(String resortNickname) {
    switch (resortNickname) {
      case '곤지암':
        return '곤지암리조트';
      case '무주':
        return '무주덕유산리조트';
      case '비발디':
        return '비발디파크';
      case '에덴밸리':
        return '에덴밸리리조트';
      case '강촌':
        return '엘리시안강촌';
      case '오크밸리':
        return '오크밸리리조트';
      case '오투':
        return '오투리조트';
      case '용평':
        return '용평리조트';
      case '웰리힐리':
        return '웰리힐리파크';
      case '지산':
        return '지산리조트';
      case '하이원':
        return '하이원리조트';
      case '휘닉스':
        return '휘닉스파크';
      case '알펜시아':
        return '알펜시아리조트';
      default:
        return resortNickname;
    }
  }

  String getSlotName(String slotNumber) {
    switch (slotNumber) {
      case '0':
        return '00-08';
      case '1':
        return '08-10';
      case '2':
        return '10-12';
      case '3':
        return '12-14';
      case '4':
        return '14-16';
      case '5':
        return '16-18';
      case '6':
        return '18-20';
      case '7':
        return '20-22';
      case '8':
        return '22-00';
      default:
        return slotNumber;
    }
  }

  String getSlopeName(String slopeNickname) {
    switch (slopeNickname) {
      case '스패로':
        return '스패로우';
      case '파노':
        return '파노라마';
      case '슬스':
        return '슬로프스타일';
      case '파라':
        return '파라다이스';
      case '파크':
        return '익스트림파크';
      case '파이프':
        return '하프파이프';
      default:
        return slopeNickname;
    }
  }


}

