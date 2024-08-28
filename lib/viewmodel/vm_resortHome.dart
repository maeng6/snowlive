import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/model/m_weatherModel.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_resortHome.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';

import '../api/ApiResponse.dart';
import '../api/api_friend.dart';
import '../api/api_ranking.dart';
import '../api/api_resortHome.dart';
import '../api/api_user.dart';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import '../model/m_bestFriendListModel.dart';

class ResortHomeViewModel extends GetxController {
  var _resortHomeModel = ResortHomeModel().obs;
  var isLoading = true.obs;
  var isLoading_weather = true.obs;
  RxString _rankingGuideUrl_ios = ''.obs;
  RxString _rankingGuideUrl_aos = ''.obs;
  RxDouble _latitude = 0.0.obs;
  RxDouble _longitude = 0.0.obs;
  RxDouble _initialHeightFriend = 0.0.obs;
  RxMap _resort_info = {}.obs;
  RxMap _weatherInfo = {}.obs;
  RxList<Map<String, dynamic>> _slope_info = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> _reset_point = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> _respawn_point = <Map<String, dynamic>>[].obs;
  RxList<BestFriendListModel> _bestFriendList = <BestFriendListModel>[].obs;
  RxBool _isSnackbarShown = false.obs;
  RxBool _isWeatherInfoExpanded = false.obs;

  dynamic weatherColors;
  dynamic weatherIcons;

  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> _rankingGuideUrl = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();

  StreamSubscription<Position>? _positionStreamSubscription;

  dynamic get resortHomeModel => _resortHomeModel.value;
  double get latitude => _latitude.value;
  double get longitude => _longitude.value;
  double get initialHeightFriend => _initialHeightFriend.value;
  Map get resort_info => _resort_info;
  Map get weatherInfo => _weatherInfo;
  bool get isSnackbarShown => _isSnackbarShown.value;
  bool get isWeatherInfoExpanded => _isWeatherInfoExpanded.value;
  List<Map<String, dynamic>> get slope_info => _slope_info;
  List<Map<String, dynamic>> get reset_point => _reset_point;
  List<Map<String, dynamic>> get respawn_point => _respawn_point;
  List<BestFriendListModel> get bestFriendList => _bestFriendList;

  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  void onInit() async{
    super.onInit();
    final UserViewModel _userViewModel = Get.find<UserViewModel>();
    await getRankingGuideUrl();
    await fetchResortHome(_userViewModel.user.user_id!);
    await fetchWeatherModel();
  }

  Future<void> fetchResortHome(int userId) async {
      isLoading(true);
      ApiResponse response = await ResortHomeAPI().fetchResortHomeData(userId);
      if(response.success)
      _resortHomeModel.value = ResortHomeModel.fromJson(response.data);
      if(!response.success)
      Get.snackbar('Error', '데이터 로딩 실패');
      isLoading(false);
  }

  Future<void> fetchWeatherModel() async {
    isLoading_weather(true);
    try {
      _weatherInfo.value = await WeatherModel().parseWeatherData(
          _resortHomeModel.value.nx, _resortHomeModel.value.ny);
      print('파스웨더 끝');
      weatherColors = WeatherModel().getWeatherColor(_weatherInfo['pty'], _weatherInfo['sky']);
      weatherIcons = WeatherModel().getWeatherIcon(_weatherInfo['pty'], _weatherInfo['sky']);
    }catch(e) {
      print(e);
      Get.snackbar('Error', '날씨 불러오기 실패');
    }
    isLoading_weather(false);
  }


  Future<void> fetchBestFriendList({required int user_id}) async {
    isLoading(true);
    ApiResponse response = await FriendAPI().fetchFriendList(user_id, true);

    if (response.success) {
      try {
        // JSON 데이터를 List<Map<String, dynamic>>로 변환
        List<dynamic> dataList = response.data as List<dynamic>;

        // List<Map<String, dynamic>>를 List<BestFriendListModel>로 변환
        List<BestFriendListModel> friendList = dataList
            .map((e) => BestFriendListModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // _bestFriendList를 업데이트
        _bestFriendList.value = friendList;

        // 초기 높이 설정
        if (_bestFriendList.length < 5) {
          _initialHeightFriend.value = 0.38;
        } else {
          _initialHeightFriend.value = 0.525;
        }

      } catch (e) {
        print('Error parsing friend list: $e');
      }
    } else {
      print('친구없는놈');
    }

    isLoading(false);
  }




  Future<void> onRefresh_resortHome() async {
    await fetchResortHome(_userViewModel.user.user_id);
    await fetchWeatherModel();
  }


  Future<void> changeInstantResort(Map<String, dynamic> body, user_id) async {

    isLoading(true);
    ApiResponse response_updateUser = await UserAPI().updateUserInfo(body);
    if(response_updateUser.success) {
      ApiResponse response_fetchResortHome = await ResortHomeAPI().fetchResortHomeData(user_id);
      if (response_fetchResortHome.success)
        _resortHomeModel.value = ResortHomeModel.fromJson(response_fetchResortHome.data);
      await fetchWeatherModel();
    } else {
      Get.snackbar('Error', '데이터 로딩 실패');
      isLoading(false);
    }
  }

  void toggleExpandWeatherInfo() async {
    _isWeatherInfoExpanded.value = !_isWeatherInfoExpanded.value;
  }

  Future<void> getRankingGuideUrl() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Ranking_guideUrl')
        .get();
     _rankingGuideUrl_aos.value = snapshot.docs[0]['url_android'];
     _rankingGuideUrl_ios.value = snapshot.docs[0]['url_iOS'];
     print('가이드 url 불러오기 완료');
  }

  Future<void> liveOff(Map<String, dynamic> body,user_id) async {

    isLoading(true);
    ApiResponse response_off = await RankingAPI().liveOff(body);
    if(response_off.success) {
      ApiResponse response_fetchResortHome = await ResortHomeAPI().fetchResortHomeData(user_id);
      if (response_fetchResortHome.success)
        _resortHomeModel.value = ResortHomeModel.fromJson(response_fetchResortHome.data);
    print('liveOff 완료');
    }
    else {
      Get.snackbar('Error', '라이브off 실패');
    }
    isLoading(false);
  }

  Future<ApiResponse> liveOn(Map<String, dynamic> body) async {
    isLoading(true);
    ApiResponse response = await RankingAPI().check_wb(body);
    if (response.success) {
      _resort_info.value = response.data['resort_info'];
      _slope_info.value = List<Map<String, dynamic>>.from(response.data['slope_info']);
      _reset_point.value = List<Map<String, dynamic>>.from(response.data['reset_point']);
      _respawn_point.value = List<Map<String, dynamic>>.from(response.data['respawn_point']);
      return response;
    } else {
      isLoading(false);
      return response;
    }
  }

  Future<void> stopForegroundLocationService() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    print('stopForegroundLocationService 완료');
  }

  Future<void> stopBackgroundLocationService() async {
    await bg.BackgroundGeolocation.stop();
    bg.BackgroundGeolocation.removeListeners();
    print('stopBackgroundLocationService 완료');
  }

  Future<void> startForegroundLocationService({required user_id}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    // 일회성으로 현재 위치 정보를 가져옴
      Position currentPosition = await Geolocator.getCurrentPosition();
      _latitude.value = currentPosition.latitude;
      _longitude.value = currentPosition.longitude;
      ApiResponse response = await liveOn({
               "user_id": user_id,
               "coordinates": "POINT (${_longitude.value} ${_latitude.value})"
             });

      if (response.success){
        _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) async {
          try {
            bool withinBoundary = _checkPositionWithinBoundary(
                position.latitude,
                position.longitude,
                _resort_info['coordinates']['latitude'],
                _resort_info['coordinates']['longitude'],
                _resort_info['radius']
            );
            if (withinBoundary) {
              Map<String, dynamic>? passPointInfo = checkPositionInAreas(position, slope_info, reset_point, respawn_point );

              if(passPointInfo != null && passPointInfo['type']=='slope_info')
                await RankingAPI().addCheckPoint(
                    {
                      "user_id": user_id,
                      "slope_id": passPointInfo['id'],
                      "coordinates": "${position.latitude}, ${position.longitude}"
                    }
                );

              if(passPointInfo != null && passPointInfo['type']=='reset_point')
                await RankingAPI().reset({"user_id": user_id});
              if(passPointInfo != null && passPointInfo['type']=='respawn_point')
                await RankingAPI().respawn({"user_id": user_id});

            } else{
              await stopForegroundLocationService();
              await stopBackgroundLocationService();
              await liveOff({"user_id":user_id},user_id );
            }
          } catch (e, stackTrace) {
            print('위치 서비스 오류: $e');
            print('Stack trace: $stackTrace');
          }
        });
      } else{
        await stopForegroundLocationService();
        await stopBackgroundLocationService();
          _isSnackbarShown.value = true;
          Get.snackbar(
            '라이브 불가 지역입니다',
            '스키장 내에서만 라이브가 활성화됩니다.',
            margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black87,
            colorText: Colors.white,
            duration: Duration(milliseconds: 3000),
          );
          Future.delayed(Duration(milliseconds: 4500), () {
            _isSnackbarShown.value = false;
          });
          print('라이브 불가 지역');
      }
  }

  Future<void> startBackgroundLocationService({required user_id}) async {
    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      preventSuspend: true,
      heartbeatInterval: 5,
      stopOnStationary: false,
      distanceFilter: 0,
      isMoving: true,
      disableElasticity: true,
      stopOnTerminate: true,
      startOnBoot: false,
      stationaryRadius: 25,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      locationUpdateInterval: 5000,
      disableLocationAuthorizationAlert: true,
      showsBackgroundLocationIndicator: true,
      backgroundPermissionRationale: PermissionRationale(
        title: "{applicationName}가 종료되거나 사용하지 않을 때 위치에 접근하도록 허용하시겠습니까?",
        message: "위치 서비스를 사용하시면 라이브 기능을 통해 랭킹 서비스를 이용할 수 있고, 친구와 라이브 상태를 공유할 수 있습니다. 이 앱은 항상 허용을 하면 앱이 사용 중이 아닐 때도 위치 데이터를 수집하여 라이브 서비스 기능을 지원합니다.",
        positiveAction: '{backgroundPermissionOptionLabel}',
        negativeAction: '취소',
      ),
    ));

    await bg.BackgroundGeolocation.start();

    bg.BackgroundGeolocation.onLocation((bg.Location location) async {
      try {
        double latitude = location.coords.latitude;
        double longitude = location.coords.longitude;

        Position position = Position(
          latitude: latitude,
          longitude: longitude,
          accuracy: location.coords.accuracy,
          altitude: location.coords.altitude,
          heading: location.coords.heading,
          speed: location.coords.speed,
          speedAccuracy: location.coords.speedAccuracy,
          timestamp: DateTime.parse(location.timestamp),
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        try {
          bool withinBoundary = _checkPositionWithinBoundary(
              position.latitude,
              position.longitude,
              _resort_info['coordinates']['latitude'],
              _resort_info['coordinates']['longitude'],
              _resort_info['radius']
          );
          if (withinBoundary) {
            Map<String, dynamic>? passPointInfo = checkPositionInAreas(position, slope_info, reset_point, respawn_point );

            if(passPointInfo != null && passPointInfo['type']=='slope_info')
              await RankingAPI().addCheckPoint(
                  {
                    "user_id": user_id,
                    "slope_id": passPointInfo['id'],
                    "coordinates": "${position.latitude}, ${position.longitude}"
                  }
              );

            if(passPointInfo != null && passPointInfo['type']=='reset_point')
              await RankingAPI().reset({"user_id": user_id});
            if(passPointInfo != null && passPointInfo['type']=='respawn_point')
              await RankingAPI().respawn({"user_id": user_id});

          } else{
            await stopForegroundLocationService();
            await stopBackgroundLocationService();
            await liveOff({"user_id":user_id},user_id);
          }
        } catch (e, stackTrace) {
          print('위치 서비스 오류: $e');
          print('Stack trace: $stackTrace');
        }

      } catch (e, stackTrace) {
        print('백그라운드 위치 업데이트 오류: $e');
        print('Stack trace: $stackTrace');
      }
    }, (bg.LocationError error) {
      print('[onLocation] ERROR: $error 리조트 구역 벗어남');
    });
  }

  bool _checkPositionWithinBoundary(lat, lon, lat_resort_info, lon_resort_info, radius) {
    double distanceInMeters = Geolocator.distanceBetween(lat, lon, lat_resort_info, lon_resort_info);
    return distanceInMeters <= radius;
  }

  Map<String, dynamic>? checkPositionInAreas(Position position, List<Map<String, dynamic>> slopeInfo, List<Map<String, dynamic>> resetPoint, List<Map<String, dynamic>> respawnPoint) {
    // 순서대로 검사
    for (var slope in slopeInfo) {
      if (_isWithinRadius(position, slope['coordinates'], slope['radius'])) {
        return {'type': 'slope_info', 'id': slope['slope_id']};
      }
    }

    for (var reset in resetPoint) {
      if (_isWithinRadius(position, reset['coordinates'], reset['radius'])) {
        return {'type': 'reset_point', 'id': reset['reset_point_id']};
      }
    }

    for (var respawn in respawnPoint) {
      if (_isWithinRadius(position, respawn['coordinates'], respawn['radius'])) {
        return {'type': 'respawn_point', 'id': respawn['respawn_point_id']};
      }
    }

    return null; // 해당하는 위치가 없을 경우
  }

  bool _isWithinRadius(Position position, String coordinatesStr, double radius) {
    // 좌표 문자열을 위도와 경도로 변환
    final parts = coordinatesStr.split(';POINT (')[1].replaceAll(')', '').split(' ');
    final double longitude = double.parse(parts[0]);
    final double latitude = double.parse(parts[1]);

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      latitude,
      longitude,
    );

    return distance <= radius;
  }

  Color? getWeatherColor(String pty, String sky) {
    String _timeString = DateFormat('HH').format(DateTime.now());
    int _timeInt = int.parse(_timeString);
    if (pty == '0' ) {
      if (_timeInt < 7 || _timeInt > 17) {
        return Color(0xFF32314D);
      }else {
        if( sky == '4' ){
          return Color(0xFF707C87);
        } else{
          return Color(0xFF3D83ED);
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
    String _timeString = DateFormat('HH').format(DateTime.now());
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

}
