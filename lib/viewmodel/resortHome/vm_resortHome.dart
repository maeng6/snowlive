import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_friend.dart';
import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/api/api_resortHome.dart';
import 'package:com.snowlive/api/api_user.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_bestFriendListModel.dart';
import 'package:com.snowlive/model/m_weatherModel.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_resortHome.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'dart:io';

final ref = FirebaseFirestore.instance;

class ResortHomeViewModel extends GetxController {
  var _resortHomeModel = ResortHomeModel().obs;
  var isLoading = true.obs;
  var isLoading_bestFriend = true.obs;
  var isLoading_weather = true.obs;
  final Lock _lock = Lock();
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
  RxList<FriendListModel> _bestFriendList = <FriendListModel>[].obs;
  RxBool _isSnackbarShown = false.obs;
  RxBool _isWeatherInfoExpanded = false.obs;
  RxBool _isVisible_resortHome_openchat = false.obs;
  RxBool _showRecentButton_resortHome_openchat = true.obs;

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
  List<FriendListModel> get bestFriendList => _bestFriendList;
  bool get isVisible_resortHome_openchat  => _isVisible_resortHome_openchat .value;
  bool get showRecentButton_resortHome_openchat => _showRecentButton_resortHome_openchat.value;

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  ScrollController scrollController_resortHome_openchat = ScrollController();

  @override
  void onInit() async{
    super.onInit();
    final UserViewModel _userViewModel = Get.find<UserViewModel>();
    await fetchBestFriendList(user_id: _userViewModel.user.user_id);
    await getRankingGuideUrl();
    await fetchResortHome(_userViewModel.user.user_id!);
    await fetchWeatherModel();
    await checkForUpdate();
  }

  Future<void> fetchResortHome(int userId) async {
    isLoading(true);
    ApiResponse response = await ResortHomeAPI().fetchResortHomeData(userId);
    if(response.success)
      _resortHomeModel.value = ResortHomeModel.fromJson(response.data);
    print('리조트홈 패치 완료');
    if(!response.success)
      Get.snackbar('Error', '데이터 로딩 실패');
    isLoading(false);
  }

  Future<void> fetchWeatherModel() async {
    isLoading_weather(true);
    try {
      _weatherInfo.value = await WeatherModel().parseWeatherData(
          _resortHomeModel.value.nx, _resortHomeModel.value.ny);
      print('날씨정보 패치 완료');
      weatherColors = WeatherModel().getWeatherColor(_weatherInfo['pty'], _weatherInfo['sky']);
      weatherIcons = WeatherModel().getWeatherIcon(_weatherInfo['pty'], _weatherInfo['sky']);
    }catch(e) {
      print(e);
      isLoading_weather(false);
      Get.snackbar('날씨 정보 수신 지연', '잠시후 다시 시도해주세요');
    }
    isLoading_weather(false);
  }


  Future<void> fetchBestFriendList({required int user_id}) async {
    isLoading_bestFriend(true);
    ApiResponse response = await FriendAPI().fetchFriendList(userId: user_id, bestFriend: true);

    if (response.success) {
      try {
        // JSON 데이터를 List<Map<String, dynamic>>로 변환
        List<dynamic> dataList = response.data as List<dynamic>;

        // List<Map<String, dynamic>>를 List<BestFriendListModel>로 변환
        List<FriendListModel> friendList = dataList
            .map((e) => FriendListModel.fromJson(e as Map<String, dynamic>))
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

    isLoading_bestFriend(false);
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
      CustomFullScreenDialog.cancelDialog();
    }
    isLoading(false);
  }

  Future<ApiResponse> liveOn(Map<String, dynamic> body) async {
    try {
      isLoading(true);
      ApiResponse response = await RankingAPI().check_wb(body);
      if (response.success) {
        _resort_info.value = response.data['resort_info'];
        _slope_info.value = List<Map<String, dynamic>>.from(response.data['slope_info']);
        _reset_point.value = List<Map<String, dynamic>>.from(response.data['reset_point']);
        _respawn_point.value = List<Map<String, dynamic>>.from(response.data['respawn_point']);
        return response;
      } else {
        await stopForegroundLocationService();
        await stopBackgroundLocationService();
        CustomFullScreenDialog.cancelDialog();
        return response;
      }
    } catch (e) {
      await stopForegroundLocationService();
      await stopBackgroundLocationService();
      CustomFullScreenDialog.cancelDialog();
      print('Error in liveOn: $e'); // 예외 발생 시 출력
      return ApiResponse.error('An error occurred: $e'); // 에러 응답 반환
    } finally {
      isLoading(false); // 성공/실패/예외 발생 여부와 상관없이 로딩 상태 종료
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

    if (response.success) {
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
            Map<String, dynamic>? passPointInfo = checkPositionInAreas(position, slope_info, reset_point, respawn_point);

            // 동시성 제어를 위해 lock 사용
            await _lock.synchronized(() async {
              if (passPointInfo != null && passPointInfo['type'] == 'slope_info') {
                await RankingAPI().addCheckPoint({
                  "user_id": user_id,
                  "slope_id": passPointInfo['id'],
                  "coordinates": "${position.latitude}, ${position.longitude}"
                });
              }

              if (passPointInfo != null && passPointInfo['type'] == 'reset_point') {
                await RankingAPI().reset({"user_id": user_id});
              }

              if (passPointInfo != null && passPointInfo['type'] == 'respawn_point') {
                await RankingAPI().respawn({"user_id": user_id});
              }
            });
          } else {
            await stopForegroundLocationService();
            await stopBackgroundLocationService();
            await liveOff({"user_id": user_id}, user_id);
            CustomFullScreenDialog.cancelDialog();
          }
        } catch (e, stackTrace) {
          await stopForegroundLocationService();
          await stopBackgroundLocationService();
          CustomFullScreenDialog.cancelDialog();
          print('위치 서비스 오류: $e');
          print('Stack trace: $stackTrace');
        }
      });
    } else {
      await stopForegroundLocationService();
      await stopBackgroundLocationService();
      CustomFullScreenDialog.cancelDialog();
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
          Map<String, dynamic>? passPointInfo = checkPositionInAreas(position, slope_info, reset_point, respawn_point);

          // 동시성 제어를 위해 lock 사용
          await _lock.synchronized(() async {
            if (passPointInfo != null && passPointInfo['type'] == 'slope_info') {
              await RankingAPI().addCheckPoint({
                "user_id": user_id,
                "slope_id": passPointInfo['id'],
                "coordinates": "${position.latitude}, ${position.longitude}"
              });
            }

            if (passPointInfo != null && passPointInfo['type'] == 'reset_point') {
              await RankingAPI().reset({"user_id": user_id});
            }

            if (passPointInfo != null && passPointInfo['type'] == 'respawn_point') {
              await RankingAPI().respawn({"user_id": user_id});
            }
          });
        } else {
          await stopForegroundLocationService();
          await stopBackgroundLocationService();
          await liveOff({"user_id": user_id}, user_id);
          CustomFullScreenDialog.cancelDialog();
        }
      } catch (e, stackTrace) {
        await stopForegroundLocationService();
        await stopBackgroundLocationService();
        CustomFullScreenDialog.cancelDialog();
        print('위치 서비스 오류: $e');
        print('Stack trace: $stackTrace');
      }

    }, (bg.LocationError error) async{
      await stopForegroundLocationService();
      await stopBackgroundLocationService();
      CustomFullScreenDialog.cancelDialog();
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

  Future<void> checkForUpdate() async {
    try {
      final currentVersion = await getCurrentAppVersion();
      final latestVersion = await getLatestAppVersion();
      final useUpdatePopup = await getUseUpdatePopup();
      print('로컬버전 : ${currentVersion}');
      print('서버버전 : ${latestVersion}');
      print('강제업데이트 사용 : ${useUpdatePopup}');

      if ((currentVersion != latestVersion) && (useUpdatePopup == true)) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actionsPadding:
              EdgeInsets.only(top: 0, right: 20, left: 20, bottom: 20),
              content: Container(
                height: 330,
                child: Column(
                  children: [
                    ExtendedImage.asset(
                      'assets/imgs/imgs/img_app_update.png',
                      scale: 4,
                      fit: BoxFit.fitHeight,
                      width: MediaQuery.of(Get.context!).size.width,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        right: 20,
                        left: 20,
                        bottom: 24,
                      ),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '새로운 버전이 업데이트 되었습니다',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111111),
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                '최신 버전 앱으로 업데이트를 위해 스토어로 이동합니다.',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF949494),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Container(
                  width: MediaQuery.of(Get.context!).size.width,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        final url =
                            'https://play.google.com/store/apps/details?id=com.snowlive';
                        await otherShare(contents: url);
                      } else if (Platform.isIOS) {
                        final url =
                            'https://apps.apple.com/us/app/apple-store/id6444235991';
                        await otherShare(contents: url);
                      }
                    },
                    child: Text(
                      '업데이트',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3D83ED),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('업데이트 확인 중 오류 발생: $e');
    }
  }

  Future<String> getCurrentAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      print('앱 버전을 가져오는 동안 오류 발생: $e');
      return ''; // 오류 발생 시 기본값 또는 빈 문자열 반환
    }
  }

  Future<String> getLatestAppVersion() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('version').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    String latestAppVersion = documentSnapshot.get('version');
    return latestAppVersion;
  }

  Future<bool> getUseUpdatePopup() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('version').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    bool useUpdatePopup = documentSnapshot.get('useUpdatePopup');
    return useUpdatePopup;
  }

}
