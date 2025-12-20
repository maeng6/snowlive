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
import 'package:com.snowlive/viewmodel/resortHome/vm_liveOnAlarm.dart';
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

class ResortHomeViewModel extends GetxController with WidgetsBindingObserver {
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

  // 배터리 최적화 시스템 팝업 후 자동 라이브온을 위한 변수
  int? _pendingLiveOnUserId;
  bool _isWaitingForBatteryOptimization = false;

  // 에러 로그 전송을 위한 변수
  final RankingAPI _rankingAPI = RankingAPI();
  bool _isLoggingOn = false; // 로깅 활성화 여부
  StreamSubscription<DocumentSnapshot>? _errorLogSubscription;
  Timer? _heartbeatTimer; // Heartbeat 타이머
  int? _currentLiveUserId; // 현재 라이브온 중인 사용자 ID

  String? _liveActivityId;
  DateTime? _liveOnStartedAt; // 시작 시각 표시용 (LockScreen에 타이머로 쓰는 값)
  Timer? _liveActivityRefreshTimer; // Live Activity 시간 갱신 타이머
  Worker? _liveFriendsWorker; // 친구 라이브 상태 변경 감지 워커

  // Live Activity 상태 관리 변수
  int _sessionRideCount = 0;          // 현재 세션 라이딩 횟수
  String _lastSlopeName = '';          // 마지막 라이딩 슬로프명 (체크포인트에서 저장)
  DateTime? _lastRideAt;               // 마지막 라이딩 시간

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
  void onInit() async {
    super.onInit();
    // 앱 lifecycle 감지를 위한 observer 등록
    WidgetsBinding.instance.addObserver(this);

    final UserViewModel _userViewModel = Get.find<UserViewModel>();

    // 독립적인 작업들 병렬 처리 (약 60% 시간 단축)
    await Future.wait([
      fetchBestFriendList(user_id: _userViewModel.user.user_id),
      getRankingGuideUrl(),
      fetchResortHome(_userViewModel.user.user_id!),
      checkForPopUp(),
      _splashController.loadSplashImage(),
    ]);

    // fetchResortHome 완료 후 날씨 정보 fetch (nx, ny 값 필요)
    await fetchWeatherModel();
  }

  /// 앱이 포그라운드로 돌아왔을 때 호출 (배터리 최적화 시스템 팝업 후 자동 라이브온)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isWaitingForBatteryOptimization) {
      _isWaitingForBatteryOptimization = false;
      _checkBatteryOptimizationAndStartLive();
    }
  }

  /// 시스템 팝업 후 배터리 최적화 상태 확인하고 라이브온 자동 진행
  Future<void> _checkBatteryOptimizationAndStartLive() async {
    if (_pendingLiveOnUserId == null) return;

    final isIgnoring = await isIgnoringBatteryOptimizations();
    if (isIgnoring) {
      // 배터리 최적화 허용됨 → 라이브온 자동 진행
      final userId = _pendingLiveOnUserId!;
      _pendingLiveOnUserId = null;
      await startLiveLocationService(user_id: userId);
    } else {
      // 사용자가 거부함
      _pendingLiveOnUserId = null;
      Get.snackbar('알림', '배터리 최적화 설정이 거부되어 라이브 기능을 사용할 수 없습니다.');
    }
  }

  //TODO: 라이브온 관련 메소드****************************************************

  /// Firebase error_log 컬렉션 스트림 구독 시작
  void _startErrorLogSubscription(int userId) {
    _errorLogSubscription?.cancel();

    _errorLogSubscription = FirebaseFirestore.instance
        .collection('error_log')
        .doc('user_id')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        _isLoggingOn = data?['logging_on'] ?? false;
        print('🔍 로깅 활성화 상태: $_isLoggingOn');
      } else {
        _isLoggingOn = false;
      }
    }, onError: (e) {
      print('❌ 에러 로그 스트림 구독 오류: $e');
      _isLoggingOn = false;
    });
  }

  /// 서버로 라이브온 로그 전송 (로깅이 활성화된 경우에만)
  Future<void> _sendLiveLog({
    required int userId,
    required String requestType,
    String? error,
    double? lat,
    double? lon,
  }) async {
    if (!_isLoggingOn) return;

    try {
      final coordinates = (lat != null && lon != null)
          ? 'POINT($lon $lat)'
          : null;

      await _rankingAPI.createErrorLog({
        'user_id': userId,
        if (coordinates != null) 'coordinates': coordinates,
        if (error != null) 'error': error,
        'request_type': requestType,
      });
      print('📝 로그 전송 완료: $requestType');
    } catch (e) {
      print('❌ 로그 전송 실패: $e');
    }
  }

  /// Heartbeat 타이머 시작 (60초마다 서버로 생존 신호 전송)
  /// 이미 위치 스트림에서 _latitude, _longitude가 갱신되므로 추가 GPS 호출 없이 저장된 값 사용
  void _startHeartbeatTimer() {
    _stopHeartbeatTimer(); // 기존 타이머 정리

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (_currentLiveUserId != null) {
        // 위치 스트림에서 이미 갱신된 저장된 위치 사용 (이중 GPS 호출 방지)
        _sendLiveLog(
          userId: _currentLiveUserId!,
          requestType: 'fg_heartbeat',
          lat: _latitude.value,
          lon: _longitude.value,
        );
      }
    });
    print('💓 Heartbeat 타이머 시작');
  }

  /// Heartbeat 타이머 정지
  void _stopHeartbeatTimer() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    print('💔 Heartbeat 타이머 정지');
  }

  /// 라이브온 성공 시 친구들에게 알림 등록
  Future<void> _notifyFriendsLiveOn(int myUserId) async {
    try {
      // bestFriendList에서 친구들의 user_id 추출
      List<int> friendUserIds = _bestFriendList
          .map((friend) => friend.friendInfo.userId)
          .toList();

      if (friendUserIds.isEmpty) {
        print('📢 알림 대상 친구 없음');
        return;
      }

      // LiveOnAlarmViewModel을 통해 알림 등록
      final liveOnAlarmViewModel = Get.find<LiveOnAlarmViewModel>();
      await liveOnAlarmViewModel.notifyFriendsLiveOn(
        myUserId: myUserId,
        friendUserIds: friendUserIds,
      );
    } catch (e) {
      print('❌ 친구 라이브온 알림 등록 실패: $e');
    }
  }

  /// 라이브오프 시 친구들에게서 알림 제거
  Future<void> _removeLiveOnNotification() async {
    try {
      final liveOnAlarmViewModel = Get.find<LiveOnAlarmViewModel>();
      await liveOnAlarmViewModel.removeLiveOnNotification();
    } catch (e) {
      print('❌ 친구 라이브온 알림 제거 실패: $e');
    }
  }

  /// 현재 라이브 중인 친구 수 계산 (Firebase 스트림에서 실시간으로 받음)
  int _getLiveFriendCount() {
    final liveOnAlarmViewModel = Get.find<LiveOnAlarmViewModel>();
    return liveOnAlarmViewModel.liveOnFriendIds.length;
  }

  /// Live Activity 시간 갱신 타이머 시작 (30초마다 업데이트)
  void _startLiveActivityRefreshTimer() {
    _stopLiveActivityRefreshTimer();
    _liveActivityRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_liveActivityId != null) {
        _updateLiveActivity();
      }
    });
  }

  /// Live Activity 시간 갱신 타이머 중지
  void _stopLiveActivityRefreshTimer() {
    _liveActivityRefreshTimer?.cancel();
    _liveActivityRefreshTimer = null;
  }

  /// 친구 라이브 상태 변경 감지 워커 시작 (실시간 업데이트)
  void _startLiveFriendsWorker() {
    _stopLiveFriendsWorker();
    final liveOnAlarmViewModel = Get.find<LiveOnAlarmViewModel>();
    _liveFriendsWorker = ever(liveOnAlarmViewModel.liveOnFriendIds, (_) {
      if (_liveActivityId != null) {
        _updateLiveActivity();
      }
    });
  }

  /// 친구 라이브 상태 변경 감지 워커 중지
  void _stopLiveFriendsWorker() {
    _liveFriendsWorker?.dispose();
    _liveFriendsWorker = null;
  }

  void _updateLiveActivity({
    String? lastSlopeName,
    int? todayRideCount,
    int? sessionRideCount,
    DateTime? lastRideAt,
  }) {
    if (!Platform.isIOS) return;
    if (_liveActivityId == null) return;

    final int today = todayRideCount ?? (resortHomeModel?.dailyTotalCount ?? 0);
    final int session = sessionRideCount ?? _sessionRideCount;
    final String last = lastSlopeName ?? _lastSlopeName;
    final DateTime? rideAt = lastRideAt ?? _lastRideAt;
    final int liveFriends = _getLiveFriendCount();

    LiveActivityService.update(
      activityId: _liveActivityId!,
      todayRideCount: today,
      sessionRideCount: session,
      lastSlopeName: last.isEmpty ? '—' : last,
      lastRideAt: rideAt,
      liveFriendCount: liveFriends,
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

  Future<void> startLiveLocationService({required user_id, bool isRestart = false}) async {
    try {
      // 현재 라이브온 사용자 ID 저장
      _currentLiveUserId = user_id;

      // 에러 로그 대상 사용자 스트림 구독 시작 (라이브온 시에만)
      _startErrorLogSubscription(user_id);

      // 재시작인 경우 로그 전송
      if (isRestart) {
        _sendLiveLog(userId: user_id, requestType: 'liveOn_restart', error: '오류로인한 재시작');
      }

      // Heartbeat 타이머 시작 (60초마다 서버로 생존 신호 전송)
      _startHeartbeatTimer();

      // Android: 배터리 최적화 제외 확인 (백그라운드 kill 방지)
      if (Platform.isAndroid) {
        final shouldProceed = await showBatteryOptimizationDialog(userId: user_id);
        if (!shouldProceed) {
          // 시스템 팝업이 뜬 경우 - 앱이 resumed 되면 자동으로 재시도됨
          return;
        }
      }

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
    await Get.dialog(
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
      _sendLiveLog(userId: user_id, requestType: 'foreground_start_begin');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _sendLiveLog(userId: user_id, requestType: 'foreground_error', error: 'Location services are disabled');
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          _sendLiveLog(userId: user_id, requestType: 'foreground_error', error: 'Location permissions are permanently denied');
          throw Exception('Location permissions are permanently denied.');
        }
        if (permission == LocationPermission.denied) {
          _sendLiveLog(userId: user_id, requestType: 'foreground_error', error: 'Location permissions are denied');
          throw Exception('Location permissions are denied.');
        }
      }

      // "항상 허용" 권한 체크 - 백그라운드 위치 추적에 필수
      if (permission == LocationPermission.whileInUse) {
        _sendLiveLog(userId: user_id, requestType: 'foreground_error', error: 'Location permission is whileInUse, not always');
        await showSettingsPopup(
          title: '위치 권한 설정 필요',
          message: '라이브 기능을 사용하려면 위치 권한을\n"항상 허용"으로 설정해주세요.',
          action: () => openAppSettings(),
        );
        return false;
      }

      // 현재 위치 가져오기
      Position currentPosition = await Geolocator.getCurrentPosition();
      _latitude.value = currentPosition.latitude;
      _longitude.value = currentPosition.longitude;

      _sendLiveLog(userId: user_id, requestType: 'foreground_got_position', lat: _latitude.value, lon: _longitude.value);

      // 서버와 라이브 상태 동기화
      ApiResponse response = await liveOn({
        "user_id": user_id,
        "coordinates": "POINT (${_longitude.value} ${_latitude.value})"
      });

      if (response.success) {
        _sendLiveLog(userId: user_id, requestType: 'liveOn_success', lat: _latitude.value, lon: _longitude.value);
        // 라이브온 성공 시 친구들에게 알림 등록
        _notifyFriendsLiveOn(user_id);

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
              print('포그라운드 판별중');

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
                    final isSuccess = response.statusCode == 201 || response.statusCode == 416;
                    if (isSuccess) {
                      _lastCountMethodCall = DateTime.now();
                      // 슬로프명 저장 (리스폰 시 Live Activity에 표시하기 위해)
                      _lastSlopeName = passPointInfo['fullname'] ?? '';
                      print(response.statusCode);
                      print('포그라운드 체크포인트 업데이트 성공: $_lastSlopeName');
                    } else {
                      print('포그라운드 체크포인트 업데이트 실패: ${response.statusCode}');
                    }
                    _sendLiveLog(userId: user_id, requestType: 'fg_checkpoint', error: isSuccess ? 'success' : 'statusCode: ${response.statusCode}', lat: position.latitude, lon: position.longitude);
                  }
                }

                if (passPointInfo['type'] == 'snowball_info') {
                  if (resort_info['snowball'] == true) {
                    int setNum = passPointInfo['set_num'] ?? 0;
                    bool isGoldenSnowball = setNum >= 91;

                    // 황금눈송이(set_num >= 91)는 시간 제한 없이 등록, 하얀눈송이는 300초 제한
                    bool canRegister = isGoldenSnowball ||
                        _lastSnowballMethodCall == null ||
                        DateTime.now().difference(_lastSnowballMethodCall!).inSeconds > 300;

                    if (canRegister) {
                      final response = await SnowballAPI().createSnowballRecord({
                        "user_id": user_id,
                        "snowball_id": passPointInfo['id'],
                        "coordinates": "POINT (${position.longitude} ${position.latitude})",
                        "event_date": _snowballShopViewModel.eventDate.value,
                      });
                      if (response.success) {
                        // 하얀눈송이일 때만 시간 기록 (황금눈송이는 시간 제한 없으므로 기록 안함)
                        if (!isGoldenSnowball) {
                          _lastSnowballMethodCall = DateTime.now();
                        }
                        print('포그라운드 ${isGoldenSnowball ? "황금" : "하얀"}눈송이 기록 성공');
                      } else {
                        print('포그라운드 눈송이 기록 실패: ${response.error}');
                      }
                    }
                  }
                }

                if (passPointInfo['type'] == 'reset_point') {
                  if (_lastResetMethodCall == null || DateTime.now().difference(_lastResetMethodCall!).inSeconds > 180) {
                    _lastResetMethodCall = DateTime.now();
                    final resetResponse = await RankingAPI().reset({"user_id": user_id});
                    print('리셋 성공');
                    _sendLiveLog(userId: user_id, requestType: 'fg_reset', error: resetResponse.success ? 'success' : resetResponse.error.toString(), lat: position.latitude, lon: position.longitude);
                  }
                }

                if (passPointInfo['type'] == 'respawn_point') {
                  if (_lastRespawnMethodCall == null || DateTime.now().difference(_lastRespawnMethodCall!).inSeconds > 180) {
                    _lastRespawnMethodCall = DateTime.now();
                    final respawnResponse = await RankingAPI().respawn({"user_id": user_id});
                    if (respawnResponse.success) {
                      print('리스폰 성공');
                      // 라이딩 완료: 세션 카운트 증가 및 시간 기록
                      _sessionRideCount++;
                      _lastRideAt = DateTime.now();
                      // Live Activity 업데이트
                      _updateLiveActivity();
                    }
                    _sendLiveLog(userId: user_id, requestType: 'fg_respawn', error: respawnResponse.success ? 'success' : respawnResponse.error.toString(), lat: position.latitude, lon: position.longitude);
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
                _sendLiveLog(userId: user_id, requestType: 'fg_out_of_boundary', lat: position.latitude, lon: position.longitude);
                _outOfBoundaryCount = 0; // 카운터 리셋
                await stopForegroundLocationService();
                await stopBackgroundLocationService();
                await liveOff({"user_id": user_id}, user_id);
              }
            }
          });
        });
        print('포그라운드 서비스 실행 성공');
        _sendLiveLog(userId: user_id, requestType: 'foreground_stream_started');
        return true; // 성공 반환
      } else {
        print('라이브 서비스 불가 지역');
        _sendLiveLog(userId: user_id, requestType: 'liveOn_fail_not_in_resort', lat: _latitude.value, lon: _longitude.value);
        return false; // 실패 반환
      }
    } catch (error) {
      print('포그라운드 서비스 실행 실패: $error');
      _sendLiveLog(userId: user_id, requestType: 'foreground_error', error: error.toString());
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
    _sendLiveLog(userId: user_id, requestType: 'background_service_started');

    // 위치 서비스(GPS) on/off 감지
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('📍 위치 제공자 상태 변경: enabled=${event.enabled}, status=${event.status}');
      if (!event.enabled) {
        _sendLiveLog(
          userId: user_id,
          requestType: 'location_provider_disabled',
          error: 'GPS/위치 서비스가 꺼졌습니다',
        );
      } else {
        _sendLiveLog(
          userId: user_id,
          requestType: 'location_provider_enabled',
        );
      }
    });

    // 백그라운드 heartbeat 이벤트 (플러그인 내장 heartbeat)
    bg.BackgroundGeolocation.onHeartbeat((bg.HeartbeatEvent event) {
      print('💓 백그라운드 Heartbeat: ${event.location?.coords.latitude}, ${event.location?.coords.longitude}');
      _sendLiveLog(
        userId: user_id,
        requestType: 'bg_heartbeat',
        lat: event.location?.coords.latitude,
        lon: event.location?.coords.longitude,
      );
    });

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
          print('백그라운드 판별중');

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
                final isSuccess = response.statusCode == 201 || response.statusCode == 416;
                if (isSuccess) {
                  _lastCountMethodCall = DateTime.now();
                  // 슬로프명 저장 (리스폰 시 Live Activity에 표시하기 위해)
                  _lastSlopeName = passPointInfo['fullname'] ?? '';
                  print('백그라운드 체크포인트 업데이트 성공: $_lastSlopeName');
                } else {
                  print('백그라운드 체크포인트 업데이트 실패: ${response.statusCode}');
                }
                _sendLiveLog(userId: user_id, requestType: 'bg_checkpoint', error: isSuccess ? 'success' : 'statusCode: ${response.statusCode}', lat: position.latitude, lon: position.longitude);
              }
            }

            if (passPointInfo['type'] == 'snowball_info') {
              if (resort_info['snowball'] == true) {
                int setNum = passPointInfo['set_num'] ?? 0;
                bool isGoldenSnowball = setNum >= 91;

                // 황금눈송이(set_num >= 91)는 시간 제한 없이 등록, 하얀눈송이는 300초 제한
                bool canRegister = isGoldenSnowball ||
                    _lastSnowballMethodCall == null ||
                    DateTime.now().difference(_lastSnowballMethodCall!).inSeconds > 300;

                if (canRegister) {
                  final response = await SnowballAPI().createSnowballRecord({
                    "user_id": user_id,
                    "snowball_id": passPointInfo['id'],
                    "coordinates": "POINT (${position.longitude} ${position.latitude})",
                    "event_date": _snowballShopViewModel.eventDate.value,
                  });
                  if (response.success) {
                    // 하얀눈송이일 때만 시간 기록 (황금눈송이는 시간 제한 없으므로 기록 안함)
                    if (!isGoldenSnowball) {
                      _lastSnowballMethodCall = DateTime.now();
                    }
                    print('백그라운드 ${isGoldenSnowball ? "황금" : "하얀"}눈송이 기록 성공');
                  } else {
                    print('백그라운드 눈송이 기록 실패: ${response.error}');
                  }
                }
              }
            }

            if (passPointInfo['type'] == 'reset_point') {
              if (_lastResetMethodCall == null || DateTime.now().difference(_lastResetMethodCall!).inSeconds > 180) {
                _lastResetMethodCall = DateTime.now();
                final resetResponse = await RankingAPI().reset({"user_id": user_id});
                print('리셋 성공');
                _sendLiveLog(userId: user_id, requestType: 'bg_reset', error: resetResponse.success ? 'success' : resetResponse.error.toString(), lat: position.latitude, lon: position.longitude);
              }
            }

            if (passPointInfo['type'] == 'respawn_point') {
              if (_lastRespawnMethodCall == null || DateTime.now().difference(_lastRespawnMethodCall!).inSeconds > 180) {
                _lastRespawnMethodCall = DateTime.now();
                final respawnResponse = await RankingAPI().respawn({"user_id": user_id});
                if (respawnResponse.success) {
                  print('리스폰 성공');
                  // 라이딩 완료: 세션 카운트 증가 및 시간 기록
                  _sessionRideCount++;
                  _lastRideAt = DateTime.now();
                  // Live Activity 업데이트
                  _updateLiveActivity();
                }
                _sendLiveLog(userId: user_id, requestType: 'bg_respawn', error: respawnResponse.success ? 'success' : respawnResponse.error.toString(), lat: position.latitude, lon: position.longitude);
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
            _sendLiveLog(userId: user_id, requestType: 'bg_out_of_boundary', lat: position.latitude, lon: position.longitude);
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
      _sendLiveLog(userId: user_id, requestType: 'bg_location_error', error: error.toString());

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
          // 재시작 실패 시 서비스 완전 정리 (메모리 누수 및 비정상 상태 방지)
          try {
            await stopBackgroundLocationService();
            await stopForegroundLocationService();
            _locationErrorCount = 0;
            print('위치 서비스 정리 완료 - 앱 재시작 필요');
          } catch (cleanupError) {
            print('위치 서비스 정리 실패: $cleanupError');
          }
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
        detectedAreas.add({
          'type': 'slope_info',
          'id': slope['slope_id'],
          'fullname': slope['fullname'],
        });
      }
    }

    // 트레저 헌트 영역 검사
    for (var treasure in treasureHuntInfo) {
      if (_isWithinRadius(position, treasure['coordinates'], treasure['radius'])) {
        detectedAreas.add({'type': 'snowball_info', 'id': treasure['snowball_id'],'set_num':treasure['set_num']});
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

    // 로그 전송 (스트림 구독 해제 전에 전송)
    _sendLiveLog(userId: user_id, requestType: 'liveOff_start');

    final ApiResponse response_off = await RankingAPI().liveOff(body);

    if (response_off.success) {
      _sendLiveLog(userId: user_id, requestType: 'liveOff_success');

      // ✅ 위치 추적 서비스 완전 종료 (백그라운드 + 포그라운드)
      await stopBackgroundLocationService();
      await stopForegroundLocationService();
      print('🛑 위치 추적 서비스 종료 완료');

      // ✅ Heartbeat 타이머 정지
      _stopHeartbeatTimer();
      _currentLiveUserId = null;

      // ✅ 에러 로그 스트림 구독 해제 (로그 전송 후에 해제)
      _errorLogSubscription?.cancel();
      _errorLogSubscription = null;
      _isLoggingOn = false;

      // ✅ 친구들에게서 라이브온 알림 제거 (백그라운드 처리 - 인디케이터와 무관)
      _removeLiveOnNotification();

      // ✅ Live Activity 시간 갱신 타이머 중지
      _stopLiveActivityRefreshTimer();

      // ✅ 친구 라이브 상태 변경 감지 워커 중지
      _stopLiveFriendsWorker();

      // ✅ 라이브 액티비티 종료 (iOS에서만)
      await _endLiveActivity('liveOff()');

      // ✅ 세션 변수 초기화
      _sessionRideCount = 0;
      _lastSlopeName = '';
      _lastRideAt = null;

      // 경계 외부 카운트 초기화
      _outOfBoundaryCount = 0;
      _lastOutOfBoundaryTime = null;

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

        // 🔍 디버그: respawn_point 데이터 확인
        print('🔍 [liveOn] respawn_point count: ${_respawn_point.length}');
        for (var rp in _respawn_point) {
          print('🔍 [liveOn] respawn_point: $rp');
        }

        // ✅ 라이브 액티비티 시작 (iOS에서만)
        if (Platform.isIOS) {
          _liveOnStartedAt = DateTime.now();
          // 세션 변수 초기화
          _sessionRideCount = 0;
          _lastSlopeName = '';
          _lastRideAt = null;

          _liveActivityId = await LiveActivityService.start(
            liveOnStartAt: _liveOnStartedAt!,
            todayRideCount: resortHomeModel?.dailyTotalCount ?? 0,
            sessionRideCount: _sessionRideCount,
            lastSlopeName: '—',
            liveFriendCount: _getLiveFriendCount(),
          );

          // Live Activity 시간 갱신 타이머 시작 (30초마다)
          _startLiveActivityRefreshTimer();

          // 친구 라이브 상태 변경 감지 워커 시작 (실시간 업데이트)
          _startLiveFriendsWorker();
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
      final intent = AndroidIntent(
        action: 'android.settings.BATTERY_SAVER_SETTINGS',
      );
      await intent.launch();
    } else if (Platform.isIOS) {
      const url = 'App-Prefs:root=BATTERY_USAGE';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        openAppSettings();
      }
    }
  }

  /// 배터리 최적화 제외 상태 확인 (Android 전용)
  /// true: 제외됨 (백그라운드 실행 제한 없음), false: 제외 안됨
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (Platform.isAndroid) {
      try {
        const channel = MethodChannel('detect_battery_saver');
        final result = await channel.invokeMethod('isIgnoringBatteryOptimizations');
        return result == true;
      } catch (e) {
        print('배터리 최적화 상태 확인 오류: $e');
        return false;
      }
    }
    return true; // iOS는 해당 없음
  }

  /// 배터리 최적화 제외 요청 (시스템 다이얼로그 표시)
  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      try {
        const channel = MethodChannel('detect_battery_saver');
        final result = await channel.invokeMethod('requestIgnoreBatteryOptimizations');
        return result == true;
      } catch (e) {
        print('배터리 최적화 제외 요청 오류: $e');
        return false;
      }
    }
    return true;
  }

  /// 배터리 최적화 안내 다이얼로그 표시 후 시스템 설정 호출
  /// 반환값: true = 바로 라이브온 진행, false = 시스템 팝업 띄움 (resumed 후 자동 재시도)
  Future<bool> showBatteryOptimizationDialog({required int userId}) async {
    if (!Platform.isAndroid) return true;

    // 이미 제외되어 있으면 바로 진행
    final isIgnoring = await isIgnoringBatteryOptimizations();
    if (isIgnoring) return true;

    // 앱 내 안내 다이얼로그 표시
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('배터리 설정 안내'),
        content: const Text(
          '라이브 기능을 원활히 사용하기 위해 배터리 최적화를 무시하도록 설정해야 합니다.\n\n허용하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('설정하기'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (result == true) {
      // pending 상태 저장 (앱이 resumed 되면 자동으로 라이브온 재시도)
      _pendingLiveOnUserId = userId;
      _isWaitingForBatteryOptimization = true;

      // 시스템 다이얼로그 호출 (앱이 백그라운드로 감)
      await requestIgnoreBatteryOptimizations();

      // false 반환하여 현재 흐름 중단 → resumed 후 자동 재시도
      return false;
    }

    // 사용자가 취소한 경우
    return false;
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
    ApiResponse response = await FriendAPI().fetchFriendList(userId: user_id, bestFriend: false);

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

  @override
  void onClose() {
    // WidgetsBindingObserver 해제
    WidgetsBinding.instance.removeObserver(this);

    // StreamSubscription 해제 (메모리 누수 방지)
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    // ScrollController dispose
    scrollController_resortHome_openchat.dispose();

    super.onClose();
  }
}
