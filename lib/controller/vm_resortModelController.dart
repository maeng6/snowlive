import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snowlive3/model/m_resortModel.dart';
import 'package:snowlive3/model/m_weatherModel.dart';

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
  dynamic _weatherColors;
  dynamic _weatherIcons;


  Future<void> getSelectedResort(int? resortNum) async{
    isLoading.value = true;
    ResortModel resortModel = ResortModel();
    WeatherModel weatherModel = WeatherModel();
    ResortModel selectedResort = resortModel.resortModelSelection(resortNum);
    this._index!.value = selectedResort.index!;
    this._instantIndex!.value = selectedResort.index!;
    this._resortName.value = selectedResort.resortName!;
    this._resortUrl!.value = selectedResort.resortUrl!;
    this._webcamUrl!.value = selectedResort.webcamUrl!;
    this._naverUrl!.value= selectedResort.naverUrl!;
    this._slopeUrl!.value= selectedResort.slopeUrl!;
    this._latitude!.value= selectedResort.latitude!;
    this._longitude!.value = selectedResort.longitude!;
    this._nX!.value = selectedResort.nX!;
    this._nY!.value = selectedResort.nY!;
    Map weatherInfo = await weatherModel.parseWeatherData(_nX!.value,_nY!.value);
    this._resortTemp!.value= weatherInfo['temp'];
    this._resortRain!.value= weatherInfo['rain'];
    this._resortWind!.value= weatherInfo['wind'];
    this._resortWet!.value= weatherInfo['wet'];
    this._resortMaxTemp!.value= weatherInfo['maxTemp'];
    this._resortMinTemp!.value= weatherInfo['minTemp'];
    this._resortPty!.value= weatherInfo['pty'];
    this._weatherColors = weatherModel.getWeatherColor(this._resortPty!.value);
    this._weatherIcons = weatherModel.getWeatherIcon(this._resortPty!.value);

    isLoading.value = false;

  }

  int? get index => _index!.value;
  int? get instantIndex => _instantIndex!.value;
  String? get resortName => _resortName.value;
  String? get resortUrl => _resortUrl!.value;
  String? get webcamUrl => _webcamUrl!.value;
  String? get slopeUrl => _slopeUrl!.value;
  String? get naverUrl => _naverUrl!.value;
  double get latitude => _latitude!.value;
  double get longitude => _longitude!.value;
  String? get resortTemp => _resortTemp!.value;
  String? get resortRain => _resortRain!.value;
  String? get resortWind => _resortWind!.value;
  String? get resortWet => _resortWet!.value;
  String? get resortMaxTemp => _resortMaxTemp!.value;
  String? get resortMinTemp => _resortMinTemp!.value;
  String? get resortPty => _resortPty!.value;
  dynamic get weatherColors => _weatherColors;
  dynamic get weatherIcons => _weatherIcons;

}

