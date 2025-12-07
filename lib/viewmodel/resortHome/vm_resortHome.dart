import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_friend.dart';
import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/api/api_resortHome.dart';
import 'package:com.snowlive/api/api_snowball.dart';
import 'package:com.snowlive/api/api_user.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_bestFriendListModel.dart';
import 'package:com.snowlive/model/m_treasure_record.dart';
import 'package:com.snowlive/model/m_weatherModel.dart';
import 'package:com.snowlive/native/live_activity_service.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/vm_splashController.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:com.snowlive/widget/w_popUp_bottomSheet.dart';
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
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

final ref = FirebaseFirestore.instance;
DateTime? _lastFakeLocationCheckTime;

class ResortHomeViewModel extends GetxController {
  var _resortHomeModel = ResortHomeModel().obs;
  var isLoading = true.obs;
  var isLoading_bestFriend = true.obs;
  var isLoading_weather = true.obs;
  final Lock _lock = Lock();
  RxString _rankingGuideUrl_ios = ''.obs;
  RxString _rankingGuideUrl_aos = ''.obs;
  RxString _rankingComingSoonUrl = ''.obs;
  RxString _rankingGuideUrl_main = ''.obs;
  RxDouble _latitude = 0.0.obs;
  RxDouble _longitude = 0.0.obs;
  RxDouble _initialHeightFriend = 0.0.obs;
  RxMap _resort_info = {}.obs;
  RxMap _weatherInfo = {}.obs;
  RxList<Map<String, dynamic>> _slope_info = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> _snowball_info = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> _reset_point = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> _respawn_point = <Map<String, dynamic>>[].obs;
  RxList<FriendListModel> _bestFriendList = <FriendListModel>[].obs;
  RxBool _isSnackbarShown = false.obs;
  RxBool _isWeatherInfoExpanded = false.obs;
  RxBool _isVisible_resortHome_openchat = false.obs;
  RxBool _showRecentButton_resortHome_openchat = true.obs;
  RxBool _isParticipate_treasure_hunt = false.obs;
  RxList<TreasureRecord> _treasureRecordList = <TreasureRecord>[].obs;
  RxBool isLoadingTreasureRecords = false.obs;
  RxBool isLoadingTreasureRecordUpdate = false.obs;
  RxInt _treasureHuntNum = 0.obs;

  RxBool _hasFriendInBoundaryAndRevealWb = false.obs;
  bool get hasFriendInBoundaryAndRevealWb => _hasFriendInBoundaryAndRevealWb.value;

  // 경계 외부 debounce를 위한 변수 (GPS 오차로 인한 오탐 방지)
  int _outOfBoundaryCount = 0;
  static const int _outOfBoundaryThreshold = 3; // 3회 연속 경계 외부일 때만 종료
  DateTime? _lastOutOfBoundaryTime;

  // 백그라운드 서비스 재시작을 위한 변수
  int _locationErrorCount = 0;
  static const int _maxLocationErrorRetry = 3;
  bool _isRestartingService = false;

  String? _liveActivityId;
  DateTime? _liveOnStartedAt; // 시작 시각 표시용 (LockScreen에 타이머로 쓰는 값)

  dynamic weatherTextColors;
  dynamic weatherColors;
  dynamic weatherIcons;

  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> bannerStream_home = Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>>();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> bannerStream_fleaMarket = Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>>();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> bannerStream_moreTab = Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>>();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> bannerStream_community = Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>>();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> bannerStream_community_detail = Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>>();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> bannerStream_ranking = Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>>();

  StreamSubscription<Position>? _positionStreamSubscription;
  DateTime? _lastCountMethodCall;
  DateTime? _lastResetMethodCall;
  DateTime? _lastRespawnMethodCall;
  DateTime? _lastSnowballMethodCall;
  String get rankingGuideUrl_ios => _rankingGuideUrl_ios.value;
  String get rankingGuideUrl_aos => _rankingGuideUrl_aos.value;
  String get rankingComingSoonUrl => _rankingComingSoonUrl.value;
  String get rankingGuideUrl_main => _rankingGuideUrl_main.value;
  dynamic get resortHomeModel => _resortHomeModel.value;
  double get latitude => _latitude.value;
  double get longitude => _longitude.value;
  double get initialHeightFriend => _initialHeightFriend.value;
  Map get resort_info => _resort_info;
  Map get weatherInfo => _weatherInfo;
  bool get isSnackbarShown => _isSnackbarShown.value;
  bool get isWeatherInfoExpanded => _isWeatherInfoExpanded.value;
  List<Map<String, dynamic>> get slope_info => _slope_info;
  List<Map<String, dynamic>> get snowball_info => _snowball_info;
  List<Map<String, dynamic>> get reset_point => _reset_point;
  List<Map<String, dynamic>> get respawn_point => _respawn_point;
  List<FriendListModel> get bestFriendList => _bestFriendList;
  List<TreasureRecord> get treasureRecordList => _treasureRecordList;
  bool get isVisible_resortHome_openchat  => _isVisible_resortHome_openchat .value;
  bool get showRecentButton_resortHome_openchat => _showRecentButton_resortHome_openchat.value;
  bool get isParticipate_treasure_hunt => _isParticipate_treasure_hunt.value;
  int get treasureHuntNum => _treasureHuntNum.value;

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  ScrollController scrollController_resortHome_openchat = ScrollController();
  SplashController _splashController = Get.find<SplashController>();
  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();


  @override
  void onInit() async{
    super.onInit();
    final UserViewModel _userViewModel = Get.find<UserViewModel>();
    await fetchBestFriendList(user_id: _userViewModel.user.user_id);
    await getRankingGuideUrl();
    await fetchResortHome(_userViewModel.user.user_id!);
    await fetchWeatherModel();
    await checkForPopUp();
    await _splashController.loadSplashImage();
  }

  //TODO: 라이브온 관련 메소드****************************************************

  void _updateLiveActivity({
    String? lastSlopeName,
    int? todayRideCount,
    int? sessionRideCount,
  }) {
    if (!Platform.isIOS) return;
    if (_liveActivityId == null) return;

    final int today = todayRideCount ?? (resortHomeModel?.todayRideCount ?? 0);
    final int session = sessionRideCount ?? 0; // 세션 카운트 관리 중이면 값 대체
    final String last = lastSlopeName ?? '—';

    LiveActivityService.update(
      activityId: _liveActivityId!,
      todayRideCount: today,
      sessionRideCount: session,
      lastSlopeName: last,
    );
  }

  Future<void> _endLiveActivity(String reason) async {
    try {
      // 종료 호출 위치/사유를 남긴다
      print('🛑 [LA] end requested ($reason), id=$_liveActivityId');

      if (Platform.isIOS && _liveActivityId != null) {
        await LiveActivityService.end(activityId: _liveActivityId!);
        print('✅ [LA] end completed ($reason)');
        _liveActivityId = null;
        _liveOnStartedAt = null;
      } else {
        print('⚠️ [LA] end skipped (no id/platform)');
      }
    } catch (e) {
      print('❌ [LA] end error ($reason): $e');
    }
  }

  Future<void> startLiveLocationService({required user_id}) async {
    try {
      // 포그라운드 서비스 실행 및 성공 여부 확인
      bool foregroundSuccess = await startForegroundLocationService(user_id: user_id);

      if (foregroundSuccess) {
        print('포그라운드 서비스 실행 성공, 백그라운드 서비스 시작');
        await startBackgroundLocationService(user_id: user_id);
      } else {
        print('포그라운드 서비스 실패로 백그라운드 실행 중단');
      }
    } catch (error) {
      // 포그라운드 실행 실패 및 모든 서비스 정리
      await stopForegroundLocationService();
      await stopBackgroundLocationService();
      await liveOff({"user_id": user_id}, user_id);
      print('라이브 위치 서비스 실행 실패: $error');
    }
  }

// 팝업 표시 함수
  Future<void> showSettingsPopup({
    required String title,
    required String message,
    required VoidCallback action,
  }) async {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => true, // 뒤로가기 허용 (기본값)
        child: AlertDialog(
          backgroundColor: SDSColor.snowliveWhite,
          contentPadding: EdgeInsets.only(bottom: 28, left: 28, right: 28, top: 30),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min, // 다이얼로그 크기를 내용에 맞게 조정
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                message,
                style: SDSTextStyle.regular.copyWith(fontSize: 14, height: 1.4, color: SDSColor.gray600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Get.back(); // 팝업 닫기
                  action(); // 기존 기능 유지
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: SDSColor.snowliveBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text(
                  '설정으로 이동',
                  style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true, // 팝업 외부 클릭으로 닫히게 설정
    );
  }

  Future<bool> startForegroundLocationService({required user_id}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are permanently denied.');
        }
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      // 현재 위치 가져오기
      Position currentPosition = await Geolocator.getCurrentPosition();
      _latitude.value = currentPosition.latitude;
      _longitude.value = currentPosition.longitude;

      // 서버와 라이브 상태 동기화
      ApiResponse response = await liveOn({
        "user_id": user_id,
        "coordinates": "POINT (${_longitude.value} ${_latitude.value})"
      });

      if (response.success) {
        _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) async {
          await _lock.synchronized(() async {
            bool withinBoundary = _checkPositionWithinBoundary(
              position.latitude,
              position.longitude,
              _resort_info['coordinates']['latitude'],
              _resort_info['coordinates']['longitude'],
              _resort_info['radius'],
            );

            DateTime now = DateTime.now();

            if (withinBoundary) {
              // 경계 내부 진입 시 카운터 리셋
              _outOfBoundaryCount = 0;
              _locationErrorCount = 0;

              // try {
              //   // 현재 시간 가져오기
              //   final now = DateTime.now();
              //
              //   // 마지막 페이크 위치 감지 시간과의 차이 계산 (10초 초과 시 실행)
              //   if (_lastFakeLocationCheckTime == null ||
              //       now.difference(_lastFakeLocationCheckTime!).inSeconds > 10) {
              //     _lastFakeLocationCheckTime = now; // 마지막 실행 시간 업데이트
              //
              //     // 페이크 위치 감지0
              //     final isFakeLocation = await DetectFakeLocation().detectFakeLocation();
              //
              //     if (isFakeLocation) {
              //       print('페이크 위치가 감지되었습니다. 위치 추적을 중지합니다.');
              //
              //       // 위치 추적 서비스 중지
              //       await stopForegroundLocationService();
              //       await stopBackgroundLocationService();
              //
              //       // 사용자에게 경고 메시지 표시
              //       Get.snackbar(
              //         '경고',
              //         '페이크 위치가 감지되었습니다. 위치 추적 서비스가 중단되었습니다.',
              //         snackPosition: SnackPosition.BOTTOM,
              //       );
              //
              //       return; // 이후 코드 실행 방지
              //     }
              //   }
              // } catch (e) {
              //   print('페이크 위치 감지 중 오류 발생: $e');
              // }

              List<Map<String, dynamic>> passPointInfos = checkPositionInAreas(
                position,
                _slope_info,
                _snowball_info,
                _reset_point,
                _respawn_point,
              );

              for (var passPointInfo in passPointInfos) {
                if (passPointInfo['type'] == 'slope_info') {
                  if (_lastCountMethodCall == null || DateTime.now().difference(_lastCountMethodCall!).inSeconds > 10) {
                    final response = await RankingAPI().addCheckPoint({
                      "user_id": user_id,
                      "slope_id": passPointInfo['id'],
                      "coordinates": "${position.latitude}, ${position.longitude}"
                    });
                    if (response.statusCode == 201 || response.statusCode == 416) {
                      _lastCountMethodCall = DateTime.now();
                      print('포그라운드 체크포인트 업데이트 성공');
                    } else {
                      print('포그라운드 체크포인트 업데이트 실패: ${response.statusCode}');
                    }
                  }
                }

                if (passPointInfo['type'] == 'snowball_info') {
                  if (resort_info['snowball'] == true) {
                    if (_lastSnowballMethodCall == null || DateTime.now().difference(_lastSnowballMethodCall!).inSeconds > 300) {
                      final response = await SnowballAPI().createSnowballRecord({
                        "user_id": user_id,
                        "snowball_id": passPointInfo['id'],
                        "coordinates": "POINT (${position.longitude} ${position.latitude})",
                        "event_date": _snowballShopViewModel.eventDate.value,
                      });
                      if (response.success) {
                        _lastSnowballMethodCall = DateTime.now();
                        print('포그라운드 눈송이 기록 성공');
                      } else {
                        print('포그라운드 눈송이 기록 실패: ${response.error}');
                      }
                    }
                  }
                }

                if (passPointInfo['type'] == 'reset_point') {
                  if (_lastResetMethodCall == null || DateTime.now().difference(_lastResetMethodCall!).inSeconds > 180) {
                    _lastResetMethodCall = DateTime.now();
                    await RankingAPI().reset({"user_id": user_id});
                    print('리셋 성공');
                  }
                }

                if (passPointInfo['type'] == 'respawn_point') {
                  if (_lastRespawnMethodCall == null || DateTime.now().difference(_lastRespawnMethodCall!).inSeconds > 180) {
                    _lastRespawnMethodCall = DateTime.now();
                    await RankingAPI().respawn({"user_id": user_id});
                    print('리스폰 성공');

                    _updateLiveActivity(
                      lastSlopeName: 'Respawn',
                      // todayRideCount/sessionRideCount 값 추적 중이면 전달해도 됨
                      // todayRideCount: resortHomeModel?.todayRideCount,
                      // sessionRideCount: ...,
                    );

                  }
                }
              }
            } else {
              // 경계 외부 debounce 로직: GPS 오차로 인한 오탐 방지
              _outOfBoundaryCount++;
              _lastOutOfBoundaryTime = DateTime.now();
              print('포그라운드 경계 외부 감지 ($_outOfBoundaryCount/$_outOfBoundaryThreshold)');

              // 연속 3회 이상 경계 외부일 때만 종료
              if (_outOfBoundaryCount >= _outOfBoundaryThreshold) {
                print('경계 외부 확정 - 위치 서비스 종료');
                _outOfBoundaryCount = 0; // 카운터 리셋
                await stopForegroundLocationService();
                await stopBackgroundLocationService();
                await liveOff({"user_id": user_id}, user_id);
              }
            }
          });
        });
        print('포그라운드 서비스 실행 성공');
        return true; // 성공 반환
      } else {
        print('라이브 서비스 불가 지역');
        return false; // 실패 반환
      }
    } catch (error) {
      print('포그라운드 서비스 실행 실패: $error');
      return false; // 실패 반환
    }
  }

  Future<void> startBackgroundLocationService({required user_id}) async {
    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,

      // 🔥 iOS suspend 방지 / 백그라운드 안정화
      preventSuspend: true,
      disableMotionActivityUpdates: false,   // 반드시 false (중요)
      stopOnStationary: false,

      // 🔥 Android foreground service 유지 → 삼성 종료 방지
      foregroundService: true,

      // 🔥 위치 업데이트 튜닝
      distanceFilter: 5,                     // 5m 이동 시 업데이트 (더 정밀한 추적)
      stationaryRadius: 25,
      elasticityMultiplier: 1.0,             // disableElasticity 쓰지 않음

      // 🔥 앱 종료 / 재부팅 이후에도 계속 동작
      stopOnTerminate: false,
      startOnBoot: true,
      forceReloadOnBoot: true,               // 🆕 삼성/중국 기기 재부팅 후에도 재시작

      // 🔥 iOS/Android 백그라운드 유지를 위한 heartbeat
      heartbeatInterval: 60,                 // 🆕 60초마다 heartbeat (iOS suspend 방지)
      enableHeadless: true,                  // 🆕 앱 종료 후에도 headless 모드로 동작

      // 🔥 위치 업데이트 속도 (삼성 Doze 정책 준수)
      locationUpdateInterval: 5000,           // 5초
      fastestLocationUpdateInterval: 3000,    // 3초

      // 🔥 Android 배터리 최적화 안내
      backgroundPermissionRationale: PermissionRationale(
        title: "{applicationName}가 종료되거나 사용하지 않을 때 위치 접근을 허용하시겠습니까?",
        message: "라이브 기능과 랭킹 서비스를 위해 앱이 백그라운드에서도 위치를 수집해야 합니다.",
        positiveAction: '{backgroundPermissionOptionLabel}',
        negativeAction: '취소',
      ),

      // 🔥 Android 알림 설정 (포그라운드 서비스)
      notification: bg.Notification(
        title: "스노우라이브",
        text: "라이브 위치 추적 중...",
        sticky: true,                         // 🆕 알림 고정 (스와이프로 삭제 불가)
      ),

      showsBackgroundLocationIndicator: true,
      disableLocationAuthorizationAlert: true,
      logLevel: bg.Config.LOG_LEVEL_OFF,
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

      await _lock.synchronized(() async {
        bool withinBoundary = _checkPositionWithinBoundary(
            position.latitude,
            position.longitude,
            _resort_info['coordinates']['latitude'],
            _resort_info['coordinates']['longitude'],
            _resort_info['radius']
        );

        if (withinBoundary) {
          // 경계 내부 진입 시 카운터 리셋
          _outOfBoundaryCount = 0;
          _locationErrorCount = 0;

          List<Map<String, dynamic>> passPointInfos = checkPositionInAreas(
            position,
            _slope_info,
            _snowball_info,
            _reset_point,
            _respawn_point,
          );

          for (var passPointInfo in passPointInfos) {
            if (passPointInfo['type'] == 'slope_info') {
              if (_lastCountMethodCall == null || DateTime.now().difference(_lastCountMethodCall!).inSeconds > 10) {
                final response = await RankingAPI().addCheckPoint({
                  "user_id": user_id,
                  "slope_id": passPointInfo['id'],
                  "coordinates": "${position.latitude}, ${position.longitude}"
                });
                if (response.statusCode == 201 || response.statusCode == 416) {
                  _lastCountMethodCall = DateTime.now();
                  print('백그라운드 체크포인트 업데이트 성공');
                  await LiveActivityService.update(
                    activityId: _liveActivityId!,
                    todayRideCount: 1,
                    sessionRideCount: 1,
                    lastSlopeName: '테스트슬로프',
                  );
                } else {
                  print('백그라운드 체크포인트 업데이트 실패: ${response.statusCode}');
                }
              }
            }

            if (passPointInfo['type'] == 'snowball_info') {
              if (resort_info['snowball'] == true) {
                if (_lastSnowballMethodCall == null || DateTime.now().difference(_lastSnowballMethodCall!).inSeconds > 300) {
                  final response = await SnowballAPI().createSnowballRecord({
                    "user_id": user_id,
                    "snowball_id": passPointInfo['id'],
                    "coordinates": "POINT (${position.longitude} ${position.latitude})",
                    "event_date": _snowballShopViewModel.eventDate.value,
                  });
                  if (response.success) {
                    _lastSnowballMethodCall = DateTime.now();
                    print('포그라운드 눈송이 기록 성공');
                  } else {
                    print('포그라운드 눈송이 기록 실패: ${response.error}');
                  }
                }
              }
            }

            if (passPointInfo['type'] == 'reset_point') {
              if (_lastResetMethodCall == null || DateTime.now().difference(_lastResetMethodCall!).inSeconds > 180) {
                _lastResetMethodCall = DateTime.now();
                await RankingAPI().reset({"user_id": user_id});
                print('리셋 성공');
              }
            }

            if (passPointInfo['type'] == 'respawn_point') {
              if (_lastRespawnMethodCall == null || DateTime.now().difference(_lastRespawnMethodCall!).inSeconds > 180) {
                _lastRespawnMethodCall = DateTime.now();
                await RankingAPI().respawn({"user_id": user_id});
                print('리스폰 성공');

                _updateLiveActivity(
                  lastSlopeName: 'Respawn',
                  // todayRideCount/sessionRideCount 값 추적 중이면 전달해도 됨
                  // todayRideCount: resortHomeModel?.todayRideCount,
                  // sessionRideCount: ...,
                );

              }
            }
          }

        } else {
          // 경계 외부 debounce 로직: GPS 오차로 인한 오탐 방지
          _outOfBoundaryCount++;
          _lastOutOfBoundaryTime = DateTime.now();
          print('백그라운드 경계 외부 감지 ($_outOfBoundaryCount/$_outOfBoundaryThreshold)');

          // 연속 3회 이상 경계 외부일 때만 종료
          if (_outOfBoundaryCount >= _outOfBoundaryThreshold) {
            print('경계 외부 확정 - 위치 서비스 종료');
            _outOfBoundaryCount = 0; // 카운터 리셋
            await stopForegroundLocationService();
            await stopBackgroundLocationService();
            await liveOff({"user_id": user_id}, user_id);
          }
        }
      });

    }, (bg.LocationError error) async {
      // 위치 에러 발생 시 복구 로직
      _locationErrorCount++;
      print('[onLocation] ERROR ($_locationErrorCount/$_maxLocationErrorRetry): $error');

      // 최대 재시도 횟수 초과 시 서비스 재시작 시도
      if (_locationErrorCount >= _maxLocationErrorRetry && !_isRestartingService) {
        _isRestartingService = true;
        print('위치 에러 최대 횟수 도달 - 서비스 재시작 시도');

        try {
          await bg.BackgroundGeolocation.stop();
          await Future.delayed(const Duration(seconds: 2));
          await bg.BackgroundGeolocation.start();
          _locationErrorCount = 0;
          print('백그라운드 위치 서비스 재시작 성공');
        } catch (e) {
          print('백그라운드 위치 서비스 재시작 실패: $e');
        } finally {
          _isRestartingService = false;
        }
      }
    });
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

  bool _checkPositionWithinBoundary(lat, lon, lat_resort_info, lon_resort_info, radius) {
    double distanceInMeters = Geolocator.distanceBetween(lat, lon, lat_resort_info, lon_resort_info);
    return distanceInMeters <= radius;
  }

  List<Map<String, dynamic>> checkPositionInAreas(
      Position position,
      List<Map<String, dynamic>> slopeInfo,
      List<Map<String, dynamic>> treasureHuntInfo,
      List<Map<String, dynamic>> resetPoint,
      List<Map<String, dynamic>> respawnPoint,
      ) {
    List<Map<String, dynamic>> detectedAreas = [];

    // 슬로프 영역 검사
    for (var slope in slopeInfo) {
      if (_isWithinRadius(position, slope['coordinates'], slope['radius'])) {
        detectedAreas.add({'type': 'slope_info', 'id': slope['slope_id']});
      }
    }

    // 트레저 헌트 영역 검사
    for (var treasure in treasureHuntInfo) {
      if (_isWithinRadius(position, treasure['coordinates'], treasure['radius'])) {
        detectedAreas.add({'type': 'snowball_info', 'id': treasure['snowball_id']});
      }
    }

    // 리셋 포인트 영역 검사
    for (var reset in resetPoint) {
      if (_isWithinRadius(position, reset['coordinates'], reset['radius'])) {
        detectedAreas.add({'type': 'reset_point', 'id': reset['reset_point_id']});
      }
    }

    // 리스폰 포인트 영역 검사
    for (var respawn in respawnPoint) {
      if (_isWithinRadius(position, respawn['coordinates'], respawn['radius'])) {
        detectedAreas.add({'type': 'respawn_point', 'id': respawn['respawn_point_id']});
      }
    }
    print('지나간 구간 : ${detectedAreas}');
    return detectedAreas; // 모든 감지된 영역 정보를 반환
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

  Future<void> liveOff(Map<String, dynamic> body, user_id) async {
    isLoading(true);
    final ApiResponse response_off = await RankingAPI().liveOff(body);

    if (response_off.success) {
      // ✅ 라이브 액티비티 종료 (iOS에서만)
      if (Platform.isIOS && _liveActivityId != null) {
        await LiveActivityService.end(activityId: _liveActivityId!);
        _liveActivityId = null;
        _liveOnStartedAt = null;
      }

      await _endLiveActivity('liveOff()');

      final ApiResponse response_fetchResortHome = await ResortHomeAPI().fetchResortHomeData(user_id);
      if (response_fetchResortHome.success) {
        _resortHomeModel.value = ResortHomeModel.fromJson(response_fetchResortHome.data);
      }
      await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
      print('liveOff 완료');
    } else {
      CustomFullScreenDialog.cancelDialog();
    }
    isLoading(false);
  }

  Future<ApiResponse> liveOn(Map<String, dynamic> body) async {
    try {
      isLoading(true);
      final ApiResponse response = await RankingAPI().check_wb(body);
      if (response.success) {
        _resort_info.value   = response.data['resort_info'];
        _slope_info.value    = List<Map<String, dynamic>>.from(response.data['slope_info']);
        _snowball_info.value = List<Map<String, dynamic>>.from(response.data['snowball_info']);
        _reset_point.value   = List<Map<String, dynamic>>.from(response.data['reset_point']);
        _respawn_point.value = List<Map<String, dynamic>>.from(response.data['respawn_point']);

        // ✅ 라이브 액티비티 시작 (iOS에서만)
        if (Platform.isIOS) {
          _liveOnStartedAt = DateTime.now();
          final int todayRide = 0;
          final int sessionRide = 0; // 세션 카운트 관리 중이면 실제 값 사용
          final String lastSlope = '—';

          _liveActivityId = await LiveActivityService.start(
            liveOnStartAt: _liveOnStartedAt!,
            todayRideCount: todayRide,
            sessionRideCount: sessionRide,
            lastSlopeName: lastSlope,
          );
        }

        return response;
      } else {
        await stopForegroundLocationService();
        CustomFullScreenDialog.cancelDialog();
        return response;
      }
    } catch (e) {
      await stopForegroundLocationService();
      CustomFullScreenDialog.cancelDialog();
      print('Error in liveOn: $e');
      return ApiResponse.error('An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }


  /// 배터리 절약 모드 확인 메서드
  Future<bool> isBatterySaverOn() async {
    if (Platform.isAndroid|| Platform.isIOS) {
      try {
        const channel = MethodChannel('detect_battery_saver');
        final result = await channel.invokeMethod('isBatterySaverOn');
        return result == true;
      } catch (e) {
        print('배터리 절약 모드 확인 중 오류 발생: $e');
        return false; // 기본값은 꺼져 있다고 가정
      }
    }
    return false; // 지원하지 않는 플랫폼
  }

  Future<void> navigateToBatterySettings() async {
    if (Platform.isAndroid) {
      // Android의 경우 배터리 절약 모드 설정 화면으로 이동
      final intent = AndroidIntent(
        action: 'android.settings.BATTERY_SAVER_SETTINGS',
      );
      await intent.launch();
    } else if (Platform.isIOS) {
      // iOS의 경우 배터리 설정 화면으로 이동
      const url = 'App-Prefs:root=BATTERY_USAGE';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        openAppSettings(); // URL 스킴이 실패하면 앱 설정으로 이동
      }
    }
  }

  //TODO: 라이브온 관련 메소드****************************************************




  Future<void> fetchResortHome(int userId) async {
    isLoading(true);
    ApiResponse response = await ResortHomeAPI().fetchResortHomeData(userId);
    await fetchBestFriendList(user_id: _userViewModel.user.user_id);

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
      weatherTextColors = WeatherModel().getWeatherTextColor(_weatherInfo['pty'], _weatherInfo['sky']);
    }catch(e) {
      print(e);
      isLoading_weather(false);
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

        // ✅ within_boundary && reveal_wb 인 친구가 있는지 계산
        _hasFriendInBoundaryAndRevealWb.value = _bestFriendList.any(
              (f) => f.friendInfo.withinBoundary == true &&
              f.friendInfo.revealWb == true,
        );

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
    fetchWeatherModel();
  }

  Future<void> changeInstantResort(Map<String, dynamic> body, user_id) async {

    isLoading(true);
    isLoading_weather(true);
    ApiResponse response_updateUser = await UserAPI().updateUserInfo(body);
    if(response_updateUser.success) {
      ApiResponse response_fetchResortHome = await ResortHomeAPI().fetchResortHomeData(user_id);
      if (response_fetchResortHome.success)
        _resortHomeModel.value = ResortHomeModel.fromJson(response_fetchResortHome.data);
      await fetchWeatherModel();
    } else {
      Get.snackbar('Error', '데이터 로딩 실패');
      isLoading(false);
      isLoading_weather(false);
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
    _rankingComingSoonUrl.value = snapshot.docs[0]['url_rankingComingSoon'];
    _rankingGuideUrl_main.value = snapshot.docs[0]['url_rankingGuide'];
    print('랭킹 url 불러오기 완료');
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

  Future<void> checkForPopUp() async {
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
              backgroundColor: SDSColor.snowliveWhite,
              contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              content: Container(
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/imgs/imgs/img_app_update_new.png',
                      scale: 4,
                      width: 200,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '새로운 버전이 업데이트 되었습니다',
                            textAlign: TextAlign.center,
                            style: SDSTextStyle.bold.copyWith(
                                color: SDSColor.gray900,
                                fontSize: 16
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            '최신 버전 앱으로 업데이트를 위해 스토어로 이동합니다.',
                            textAlign: TextAlign.center,
                            style: SDSTextStyle.regular.copyWith(
                              color: SDSColor.gray500,
                              fontSize: 14,
                            ),
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
                      '업데이트하기',
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 16,
                        color: SDSColor.snowliveWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
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
      bottomPopUp();
      print('바텀팝업');
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

  Future<void> getBanner(String accountName) async {
    Stream<DocumentSnapshot<Map<String, dynamic>>> stream = FirebaseFirestore.instance
        .collection('banner')
        .doc(accountName)
        .snapshots();

    switch (accountName) {
      case 'home':
        bannerStream_home.value = stream;
        break;
      case 'fleaMarket':
        bannerStream_fleaMarket.value = stream;
        break;
      case 'moreTab':
        bannerStream_moreTab.value = stream;
        break;
      case 'community':
        bannerStream_community.value = stream;
        break;
      case 'community_detail':
        bannerStream_community_detail.value = stream;
        break;
      case 'ranking':
        bannerStream_ranking.value = stream;
        break;
      default:
        print('알 수 없는 accountName: $accountName');
    }
  }
}
