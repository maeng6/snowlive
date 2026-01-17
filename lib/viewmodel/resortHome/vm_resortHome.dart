import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_friend.dart';
import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/api/api_resortHome.dart';
import 'package:com.snowlive/api/api_resort.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:com.snowlive/api/api_snowball.dart';
import 'package:com.snowlive/api/api_user.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_bestFriendListModel.dart';
import 'package:com.snowlive/model/m_liveOffSummary.dart';
import 'package:com.snowlive/model/m_treasure_record.dart';
import 'package:com.snowlive/model/m_weatherModel.dart';
import 'package:com.snowlive/widget/w_liveOffSummaryDialog.dart';
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
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.snowlive/main.dart' show backgroundGeolocationHeadlessTask;

final ref = FirebaseFirestore.instance;
DateTime? _lastFakeLocationCheckTime;

// 마지막 액션 타입 (리스폰 로직용)
enum LastActionType {
  none,       // 초기 상태
  checkpoint, // 체크포인트 통과
  respawn,    // 리스폰 성공
  reset,      // 리셋 성공
}

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
  double _currentSpeed = 0.0; // 현재 속도 (m/s)
  double _currentAltitude = 0.0; // 현재 고도 (m)
  double? _lastHeartbeatLat; // 마지막 heartbeat 위치 (거리 계산용)
  double? _lastHeartbeatLon;
  double? _lastHeartbeatAltitude; // 마지막 heartbeat 고도 (리프트/슬로프 판별용)
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
  Worker? _liveFriendsWorker; // 친구 라이브 상태 변경 감지 워커

  // Live Activity 상태 관리 변수
  int _sessionRideCount = 0;          // 현재 세션 라이딩 횟수
  String _lastSlopeName = '';          // 마지막 라이딩 슬로프명 (체크포인트에서 저장)
  LastActionType _lastActionType = LastActionType.none; // 마지막 액션 타입 (리스폰 조건 판별용)
  DateTime? _lastRideAt;               // 마지막 라이딩 시간

  // 등록된 Geofence 정보 저장 (초기 위치 체크용)
  List<Map<String, dynamic>> _registeredGeofences = [];

  // GPS 튐 탐지용 변수 (정확도/속도 필터링)
  Position? _lastValidationPosition;
  DateTime? _lastValidationTime;

  // GPS 보간용 변수 (이전 유효 위치 저장)
  Position? _previousValidPosition;

  // API 타임아웃 설정 (데드락 방지)
  static const Duration _apiTimeout = Duration(seconds: 10);
  static const Duration _futureWaitTimeout = Duration(seconds: 5);
  static const int _staleRequestThresholdSeconds = 5; // 🔥 오래된 요청 스킵 기준

  // RxList 데이터 보호 (메모리 압박으로 비워졌을 때 자동 재로드)
  bool _isReloadingAreaData = false;
  DateTime? _lastAreaDataReload;

  // 백그라운드 위치 요청 중복 방지 플래그 (getCurrentPosition 무한 루프 방지)
  bool _isGettingBackgroundPosition = false;

  // onLocation 디바운싱 (메모리 누수 방지)
  DateTime? _lastOnLocationTime;

  // 앱 포그라운드/백그라운드 상태 추적 (위치 스트림 충돌 방지)
  bool _isAppInForeground = true;

  // 자동 라이브온 설정 관련 변수
  RxBool _isAutoLiveOnEnabled = false.obs;
  RxBool _shouldShowAutoLiveOnTooltip = false.obs;
  static const String _autoLiveOnKey = 'auto_liveon_enabled';
  static const String _autoLiveOnDialogShownKey = 'auto_liveon_dialog_shown';
  static const String _autoLiveOnTooltipShownKey = 'auto_liveon_tooltip_shown';
  bool _isAutoLiveOnInProgress = false;  // 🔥 자동 라이브온 중복 실행 방지
  bool _isLiveOffInProgress = false;      // 🔥 liveOff 중복 실행 방지

  // 🔥 백그라운드에서 liveOn 시 Live Activity 시작 지연용
  Map<String, dynamic>? _pendingLiveActivityData;

  // 자동 라이브온 getter
  bool get isAutoLiveOnEnabled => _isAutoLiveOnEnabled.value;
  bool get shouldShowAutoLiveOnTooltip => _shouldShowAutoLiveOnTooltip.value;

  dynamic weatherTextColors;
  dynamic weatherColors;
  dynamic weatherIcons;

  // 🛡️ 메모리 누수 방지: StreamSubscription 패턴으로 변경
  // 배너 데이터 (reactive)
  Rxn<Map<String, dynamic>> bannerData_home = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> bannerData_fleaMarket = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> bannerData_moreTab = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> bannerData_community = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> bannerData_community_detail = Rxn<Map<String, dynamic>>();
  Rxn<Map<String, dynamic>> bannerData_ranking = Rxn<Map<String, dynamic>>();

  // 배너 스트림 구독
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _bannerSub_home;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _bannerSub_fleaMarket;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _bannerSub_moreTab;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _bannerSub_community;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _bannerSub_community_detail;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _bannerSub_ranking;

  StreamSubscription<Position>? _positionStreamSubscription;
  DateTime? _lastCountMethodCall;
  DateTime? _lastResetMethodCall;
  DateTime? _lastRespawnMethodCall;
  DateTime? _lastSnowballMethodCall;
  bool _respawnSkipLogSent = false; // 스킵 로그 중복 전송 방지

  // 로그 버퍼링 관련 변수
  final List<Map<String, dynamic>> _logBuffer = [];
  Timer? _logFlushTimer;
  static const int _logFlushIntervalSeconds = 60; // 1분마다 일괄 전송
  static const int _maxBufferSize = 500; // 최대 버퍼 크기
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
  bool get isPositionStreamActive => _positionStreamSubscription != null;

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  ScrollController scrollController_resortHome_openchat = ScrollController();
  SplashController _splashController = Get.find<SplashController>();
  SnowballShopViewModel _snowballShopViewModel = Get.find<SnowballShopViewModel>();


  @override
  void onInit() async {
    super.onInit();
    // 앱 lifecycle 감지를 위한 observer 등록
    WidgetsBinding.instance.addObserver(this);

    // 🧹 앱 시작 시 이전 세션에서 남은 라이브 액티비티 정리 (강제 종료 대응)
    // 라이브 복구나 자동 라이브온 시 새로 시작하므로 먼저 정리
    await LiveActivityService.endAll();

    final UserViewModel _userViewModel = Get.find<UserViewModel>();
    final userId = _userViewModel.user.user_id;

    // user_id가 없으면 초기화 중단 (로그인 전 상태)
    if (userId == null) {
      print('⚠️ user_id가 null - 초기화 스킵');
      isLoading_weather(false);
      return;
    }

    // 독립적인 작업들 병렬 처리 (약 60% 시간 단축)
    // 에러가 발생해도 다른 작업은 계속 진행
    await Future.wait([
      _safeCall('fetchBestFriendList', () => fetchBestFriendList(user_id: userId)),
      _safeCall('getRankingGuideUrl', () => getRankingGuideUrl()),
      _safeCall('fetchResortHome', () => fetchResortHome(userId)),
      _safeCall('checkForPopUp', () => checkForPopUp()),
      _safeCall('loadSplashImage', () => _splashController.loadSplashImage()),
    ]);

    // fetchResortHome 완료 후 날씨 정보 fetch (nx, ny 값 필요)
    // 에러 발생해도 반드시 호출 (isLoading_weather를 false로 설정)
    await fetchWeatherModel();

    // 자동 라이브온 설정 로드 (Geofence 설정보다 먼저!)
    await _loadAutoLiveOnPreference();

    // Geofence 설정 (자동 라이브온 설정 로드 후 호출)
    await setupResortGeofences();

    // 앱 종료 상태에서 저장된 pending 지오펜스 확인 및 자동 라이브온
    // 🔥 await 추가 - 순차 실행으로 충돌 방지
    await _checkPendingGeofenceFromHeadless();

    // 앱 비정상 종료 후 복구 체크 (서버는 liveOn인데 앱은 추적 안 하는 경우)
    // 🔥 await 추가 - pending 지오펜스 처리 완료 후 실행
    await _checkAndRecoverFromAbnormalTermination();
  }

  /// 개별 작업 에러 로깅 헬퍼
  Future<void> _safeCall(String name, Future<void> Function() fn) async {
    try {
      await fn();
      print('✅ [onInit] $name 완료');
    } catch (e, stackTrace) {
      print('❌ [onInit] $name 실패: $e');
      print('📍 스택트레이스: $stackTrace');
    }
  }

  /// 앱이 포그라운드로 돌아왔을 때 호출 (배터리 최적화 시스템 팝업 후 자동 라이브온)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱 상태 추적 (위치 스트림 충돌 방지)
    if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      print('📱 앱 상태: 포그라운드');

      // 🔥 백그라운드에서 지연된 Live Activity 시작
      _startPendingLiveActivity();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isAppInForeground = false;
      print('📱 앱 상태: 백그라운드');
    }

    if (state == AppLifecycleState.resumed && _isWaitingForBatteryOptimization) {
      _isWaitingForBatteryOptimization = false;
      _checkBatteryOptimizationAndStartLive();
    }
  }

  /// 백그라운드에서 지연된 Live Activity 시작 (포그라운드 복귀 시 호출)
  /// iOS 전용: Android는 백그라운드에서도 ForegroundService 시작 가능
  Future<void> _startPendingLiveActivity() async {
    if (_pendingLiveActivityData == null) return;
    if (_liveActivityId != null) {
      // 이미 Live Activity가 실행 중이면 스킵
      _pendingLiveActivityData = null;
      return;
    }

    try {
      print('📱 [LA] iOS 지연된 Live Activity 시작');
      final data = _pendingLiveActivityData!;
      _pendingLiveActivityData = null;

      _liveActivityId = await LiveActivityService.start(
        liveOnStartAt: data['liveOnStartAt'] as DateTime,
        todayRideCount: data['todayRideCount'] as int,
        sessionRideCount: data['sessionRideCount'] as int,
        lastSlopeName: data['lastSlopeName'] as String,
        resortName: data['resortName'] as String,
        liveFriendCount: data['liveFriendCount'] as int,
      );
      print('📱 [LA] 지연된 Live Activity 시작 완료: $_liveActivityId');
    } catch (e) {
      print('❌ [LA] 지연된 Live Activity 시작 실패: $e');
      _pendingLiveActivityData = null;
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

  /// 앱 비정상 종료 후 복구 체크
  /// 서버에서는 within_boundary=true (liveOn 상태)인데 앱에서 위치 추적이 안 되고 있으면 복구 다이얼로그 표시
  Future<void> _checkAndRecoverFromAbnormalTermination() async {
    try {
      // 🔥 자동 라이브온이 진행 중이면 복구 체크 스킵
      if (_isAutoLiveOnInProgress) {
        print('ℹ️ [복구 체크] 자동 라이브온 진행 중, 복구 체크 스킵');
        return;
      }

      final userId = _userViewModel.user.user_id;
      if (userId == null) return;

      // 서버 상태: within_boundary가 true면 liveOn 상태
      final isServerLiveOn = _userViewModel.user.within_boundary == true;

      // 앱 상태: 위치 스트림이 활성화되어 있는지
      final isAppTracking = isPositionStreamActive || _liveActivityId != null;

      print('🔍 [복구 체크] 서버 liveOn: $isServerLiveOn, 앱 추적 중: $isAppTracking');

      // 서버는 liveOn인데 앱은 추적 안 하는 경우 → 비정상 종료됨
      if (isServerLiveOn && !isAppTracking) {
        print('⚠️ [복구 체크] 비정상 종료 감지! 복구 다이얼로그 표시');
        await _showRecoveryDialog(userId);
      }
    } catch (e) {
      print('❌ [복구 체크] 오류: $e');
    }
  }

  /// 라이브 복구 다이얼로그 표시
  Future<void> _showRecoveryDialog(int userId) async {
    // 약간의 딜레이 (UI가 완전히 로드된 후 표시)
    await Future.delayed(const Duration(milliseconds: 500));

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '라이브가 중단되었습니다',
              style: SDSTextStyle.bold.copyWith(fontSize: 18, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '앱이 백그라운드에서 종료되어\n라이브 추적이 중단되었습니다.\n다시 시작하시겠습니까?',
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(result: false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      '종료하기',
                      style: SDSTextStyle.regular.copyWith(fontSize: 16, color: SDSColor.gray500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      '다시 시작',
                      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    if (result == true) {
      // 라이브 다시 시작 (liveOff → startLiveLocationService)
      await restoreLiveOn(userId);
    } else {
      // 종료하기 선택 → liveOff 호출
      CustomFullScreenDialog.showDialog();
      try {
        await liveOff({"user_id": userId}, userId);
        await _userViewModel.updateUserModel_api(userId);
        print('✅ [복구] 라이브 종료 완료');
      } catch (e) {
        print('❌ [복구] 라이브 종료 실패: $e');
      } finally {
        CustomFullScreenDialog.cancelDialog();
      }
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

  /// 서버로 라이브온 로그 전송 (버퍼에 추가 후 1분마다 일괄 전송)
  void _sendLiveLog({
    required int userId,
    required String requestType,
    String? error,
    double? lat,
    double? lon,
    double? speed,
    double? distance,
  }) {
    if (!_isLoggingOn) return;

    final coordinates = (lat != null && lon != null)
        ? 'POINT($lon $lat)'
        : null;

    final logEntry = {
      'user_id': userId,
      if (coordinates != null) 'coordinates': coordinates,
      if (error != null) 'error': error,
      'request_type': requestType,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      if (speed != null) 'speed': speed,
      if (distance != null) 'distance': distance,
    };

    _logBuffer.add(logEntry);
    print('📝 로그 버퍼에 추가: $requestType (버퍼 크기: ${_logBuffer.length})');

    // 버퍼가 최대 크기에 도달하면 즉시 전송
    if (_logBuffer.length >= _maxBufferSize) {
      _flushLogBuffer();
    }
  }

  /// Heartbeat 로그 즉시 전송 (버퍼 사용 안함)
  Future<void> _sendHeartbeatLogDirect({
    required int userId,
    required String requestType,
    double? lat,
    double? lon,
    double? speed,
    double? distance,
    double? altitude,
    String? locationType, // 'slope', 'lift', 'unknown'
  }) async {
    if (!_isLoggingOn) return;

    final coordinates = (lat != null && lon != null)
        ? 'POINT($lon $lat)'
        : null;

    final logEntry = {
      'user_id': userId,
      if (coordinates != null) 'coordinates': coordinates,
      'request_type': requestType,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      if (speed != null) 'speed': speed,
      if (distance != null) 'distance': distance,
      if (altitude != null) 'altitude': altitude,
      'location_type': locationType ?? 'unknown',
    };

    try {
      await _rankingAPI.createErrorLog(logEntry);
      print('💓 Heartbeat: $locationType (속도: ${speed?.toStringAsFixed(1)}m/s, 고도: ${altitude?.toStringAsFixed(0)}m, 거리: ${distance?.toStringAsFixed(1)}m)');
    } catch (e) {
      print('❌ Heartbeat 로그 전송 실패: $e');
    }
  }

  /// 로그 버퍼 일괄 전송 타이머 시작
  void _startLogFlushTimer() {
    _stopLogFlushTimer();
    _logFlushTimer = Timer.periodic(
      const Duration(seconds: _logFlushIntervalSeconds),
      (_) => _flushLogBuffer(),
    );
    print('📤 로그 플러시 타이머 시작 (${_logFlushIntervalSeconds}초 주기)');
  }

  /// 로그 버퍼 일괄 전송 타이머 정지
  void _stopLogFlushTimer() {
    _logFlushTimer?.cancel();
    _logFlushTimer = null;
  }

  /// 버퍼에 쌓인 로그를 서버로 일괄 전송
  Future<void> _flushLogBuffer() async {
    if (_logBuffer.isEmpty) return;

    // 버퍼 복사 후 비우기 (전송 중 새 로그 추가 대비)
    final logsToSend = List<Map<String, dynamic>>.from(_logBuffer);
    _logBuffer.clear();

    try {
      final response = await _rankingAPI.createErrorLogBulk(logsToSend);
      if (response.success) {
        print('📤 로그 일괄 전송 완료: ${logsToSend.length}건');
      } else {
        print('❌ 로그 일괄 전송 실패, 버퍼에 다시 추가');
        _logBuffer.insertAll(0, logsToSend); // 실패 시 다시 버퍼에 추가
      }
    } catch (e) {
      print('❌ 로그 일괄 전송 오류: $e');
      _logBuffer.insertAll(0, logsToSend); // 오류 시 다시 버퍼에 추가
    }
  }

  /// Heartbeat 타이머 시작 (60초마다 서버로 생존 신호 전송)
  /// 이미 위치 스트림에서 _latitude, _longitude, _currentSpeed, _currentAltitude가 갱신되므로 추가 GPS 호출 없이 저장된 값 사용
  void _startHeartbeatTimer() {
    _stopHeartbeatTimer(); // 기존 타이머 정리

    // 첫 heartbeat 위치/고도 초기화
    _lastHeartbeatLat = null;
    _lastHeartbeatLon = null;
    _lastHeartbeatAltitude = null;

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (_currentLiveUserId != null) {
        final currentLat = _latitude.value;
        final currentLon = _longitude.value;
        final currentAltitude = _currentAltitude;
        final currentSpeed = _currentSpeed;

        // 이전 heartbeat 위치와의 거리 계산
        double? distanceFromLastHeartbeat;
        if (_lastHeartbeatLat != null && _lastHeartbeatLon != null) {
          distanceFromLastHeartbeat = Geolocator.distanceBetween(
            _lastHeartbeatLat!,
            _lastHeartbeatLon!,
            currentLat,
            currentLon,
          );
        }

        // 🎿 리프트/슬로프 판별 로직
        String locationType = _determineLocationType(
          currentAltitude: currentAltitude,
          lastAltitude: _lastHeartbeatAltitude,
          speed: currentSpeed,
        );

        // Heartbeat는 버퍼 없이 즉시 전송 (속도, 거리, 고도, 위치타입 포함)
        // 속도: m/s → km/h 변환
        final speedKmh = currentSpeed * 3.6;
        _sendHeartbeatLogDirect(
          userId: _currentLiveUserId!,
          requestType: 'fg_heartbeat',
          lat: currentLat,
          lon: currentLon,
          speed: speedKmh,
          distance: distanceFromLastHeartbeat,
          altitude: currentAltitude,
          locationType: locationType,
        );

        // 현재 위치/고도를 마지막 heartbeat로 저장
        _lastHeartbeatLat = currentLat;
        _lastHeartbeatLon = currentLon;
        _lastHeartbeatAltitude = currentAltitude;
      }
    });
    print('💓 Heartbeat 타이머 시작 (60초 주기)');
  }

  /// 🎿 리프트/슬로프 판별 (고도 변화 + 속도 조합)
  /// - slope: 고도 하강 또는 빠른 속도 (스키/보드 타는 중)
  /// - lift: 고도 상승 + 속도 느림 (리프트 탑승 중)
  /// - unknown: 판별 불가 (정지, 걷기 등)
  String _determineLocationType({
    required double currentAltitude,
    required double? lastAltitude,
    required double speed,
  }) {
    final speedKmh = speed * 3.6; // m/s → km/h 변환

    // 1️⃣ 속도 기반 우선 판별 (고도 변화 없어도 빠르면 슬로프)
    if (speedKmh >= 15.0) {
      return 'slope'; // 15km/h 이상 = 슬로프 (라이딩 중)
    }

    // 이전 고도 데이터 없으면 속도로만 판별
    if (lastAltitude == null) {
      if (speedKmh >= 5.0) return 'slope'; // 5km/h 이상 = 슬로프 추정
      return 'unknown';
    }

    final altitudeDiff = currentAltitude - lastAltitude; // 양수: 상승, 음수: 하강

    // 고도 변화 임계값 (60초 간격 고려하여 낮춤)
    const double altitudeThreshold = 1.0; // 1m 이상 변화면 판별

    // 2️⃣ 슬로프: 고도 하강 + 이동 중
    if (altitudeDiff < -altitudeThreshold && speedKmh >= 3.0) {
      return 'slope';
    }

    // 3️⃣ 리프트: 고도 상승 + 느린 속도 (0~15km/h)
    if (altitudeDiff > altitudeThreshold && speedKmh <= 15.0 && speedKmh > 0) {
      return 'lift';
    }

    // 4️⃣ 중간 속도인데 고도 변화 없음 = 슬로프 추정 (평지 구간)
    if (speedKmh >= 5.0) {
      return 'slope';
    }

    // 그 외: 정지, 걷기 등
    return 'unknown';
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
    final count = liveOnAlarmViewModel.liveOnFriendIds.length;
    print('👥 [LA] 라이브 친구 수 조회: $count명 (ids: ${liveOnAlarmViewModel.liveOnFriendIds})');
    return count;
  }

  /// 친구 라이브 상태 변경 감지 워커 시작 (실시간 업데이트)
  void _startLiveFriendsWorker() {
    _stopLiveFriendsWorker();
    final liveOnAlarmViewModel = Get.find<LiveOnAlarmViewModel>();

    // 변경 감지 워커 (Firestore 스트림에서 liveOnFriendIds 변경 시 호출)
    _liveFriendsWorker = ever(liveOnAlarmViewModel.liveOnFriendIds, (_) {
      if (_liveActivityId != null) {
        print('🔄 [LA] 친구 수 변경 감지: ${liveOnAlarmViewModel.liveOnFriendIds.length}명');
        _updateLiveActivity();
      }
    });

    // 현재 값이 있으면 즉시 업데이트
    if (liveOnAlarmViewModel.liveOnFriendIds.isNotEmpty && _liveActivityId != null) {
      print('🔄 [LA] 초기 친구 수 반영: ${liveOnAlarmViewModel.liveOnFriendIds.length}명');
      _updateLiveActivity();
    }
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
    // iOS와 Android 모두 지원
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

      // iOS: activityId가 있어야 종료 가능
      // Android: activityId 없어도 서비스 종료 시도 (항상 종료)
      if (_liveActivityId != null || Platform.isAndroid) {
        await LiveActivityService.end(activityId: _liveActivityId ?? 'android_live_activity');
        print('✅ [LA] end completed ($reason)');
        _liveActivityId = null;
        _liveOnStartedAt = null;
      } else {
        print('⚠️ [LA] end skipped (no id)');
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

        // 🔥 liveOn 성공 후에만 타이머 시작 (실패 시 heartbeat 방지)
        _startHeartbeatTimer();
        _startLogFlushTimer();

        await startBackgroundLocationService(user_id: user_id);
        // 자동 라이브온 다이얼로그는 뷰에서 로딩 다이얼로그 닫힌 후 호출
      } else {
        print('포그라운드 서비스 실패로 백그라운드 실행 중단');
        // 🔥 liveOn 실패 시 모든 서비스 정리
        _stopHeartbeatTimer();
        _stopLogFlushTimer();
        _currentLiveUserId = null;
      }
    } catch (error) {
      // 포그라운드 실행 실패 및 모든 서비스 정리
      await stopForegroundLocationService();
      await stopBackgroundLocationService();
      _stopHeartbeatTimer();
      _stopLogFlushTimer();
      await liveOff({"user_id": user_id}, user_id, showSummary: false);
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

      // "정확한 위치" 권한 체크 (iOS 14+) - GPS 정밀도에 필수
      if (Platform.isIOS) {
        final accuracyStatus = await Geolocator.getLocationAccuracy();
        if (accuracyStatus == LocationAccuracyStatus.reduced) {
          _sendLiveLog(userId: user_id, requestType: 'foreground_error', error: 'Location accuracy is reduced, not precise');
          await showSettingsPopup(
            title: '정확한 위치 설정 필요',
            message: '라이브 기능을 사용하려면 \n"정확한 위치" 옵션을 켜주세요.\n설정 > 스노우라이브 >\n위치 > 정확한 위치 활성화',
            action: () => openAppSettings(),
          );
          return false;
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
        _sendLiveLog(userId: user_id, requestType: 'liveOn_success', lat: _latitude.value, lon: _longitude.value);
        // 라이브온 성공 시 친구들에게 알림 등록
        _notifyFriendsLiveOn(user_id);

        // 플랫폼별 위치 설정
        late LocationSettings locationSettings;
        if (Platform.isIOS) {
          locationSettings = AppleSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
            activityType: ActivityType.fitness,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,  // 상태바 파란 표시
          );
        } else if (Platform.isAndroid) {
          locationSettings = AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
            forceLocationManager: false,
            intervalDuration: const Duration(seconds: 1),
            // foregroundNotificationConfig 제거 - LiveActivityService가 포그라운드 서비스 역할 수행
          );
        } else {
          locationSettings = const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          );
        }

        _positionStreamSubscription = Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen(
              (Position position) async {
            // 🛡️ 캐시된 오래된 위치 필터링 (iOS GPS 점프 방지)
            final positionAge = DateTime.now().difference(position.timestamp);
            if (positionAge.inSeconds > 10) {
              print('⚠️ 캐시된 위치 무시: ${positionAge.inSeconds}초 전 위치');
              _sendLiveLog(
                userId: user_id,
                requestType: 'fg_cached_position_ignored',
                lat: position.latitude,
                lon: position.longitude,
                error: 'age: ${positionAge.inSeconds}s',
              );
              return;
            }

            // 현재 좌표, 속도, 고도 갱신
            _latitude.value = position.latitude;
            _longitude.value = position.longitude;
            _currentSpeed = position.speed >= 0 ? position.speed : 0.0; // 음수 속도 방지
            _currentAltitude = position.altitude; // 고도 (m)

            // 🔍 위치 스트림 로그 (디버깅용)
            double? distanceFromLast;
            if (_lastValidationPosition != null) {
              distanceFromLast = Geolocator.distanceBetween(
                _lastValidationPosition!.latitude,
                _lastValidationPosition!.longitude,
                position.latitude,
                position.longitude,
              );
            }
            _sendLiveLog(
              userId: user_id,
              requestType: 'fg_position_stream',
              lat: position.latitude,
              lon: position.longitude,
              error: Platform.isIOS ? 'iOS' : 'Android',
              speed: position.speed,
              distance: distanceFromLast,
            );

            // 🚨 GPS 튐 탐지: 정확도/속도 필터링
            if (!_validatePosition(position, user_id)) {
              return; // 유효하지 않은 위치면 처리 안함
            }

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

                // 🛡️ 영역 데이터 보호: 비어있으면 재로드 (메모리 압박 대응)
                await _reloadAreaDataIfNeeded(user_id, position.latitude, position.longitude);

                // 현재 위치에서 영역 체크 (보간 제거)
                List<Map<String, dynamic>> passPointInfos = checkPositionInAreas(
                  position,
                  _slope_info,
                  _snowball_info,
                  _reset_point,
                  _respawn_point,
                );

                // 🔍 디버깅: 영역 데이터가 비어있으면 경고
                if (_slope_info.isEmpty && _respawn_point.isEmpty) {
                  _sendLiveLog(
                    userId: user_id,
                    requestType: 'fg_area_data_empty',
                    lat: position.latitude,
                    lon: position.longitude,
                    error: 'slope: ${_slope_info.length}, reset: ${_reset_point.length}, respawn: ${_respawn_point.length}',
                  );
                }

                // 병렬 처리를 위한 Future 리스트
                List<Future<void>> futures = [];

                for (var passPointInfo in passPointInfos) {
                  // 체크포인트 처리
                  if (passPointInfo['type'] == 'slope_info') {
                    if (_lastCountMethodCall == null || DateTime.now().difference(_lastCountMethodCall!).inSeconds > 5) {
                      final slopeId = passPointInfo['id'];
                      final slopeFullname = passPointInfo['fullname'] ?? '';
                      // 📍 보간점 정보 (error 필드에 추가용)
                      final detectedLat = passPointInfo['detected_lat'];
                      final detectedLon = passPointInfo['detected_lon'];
                      final detectedInfo = (detectedLat != null && detectedLon != null)
                          ? ', detected: ${detectedLat.toStringAsFixed(6)},${detectedLon.toStringAsFixed(6)}'
                          : '';
                      final callTime = DateTime.now(); // 🔥 요청 생성 시간 캡처
                      futures.add(() async {
                        // 🔥 타임아웃 후 지연 실행 방지 (5초 이상 지연된 요청은 스킵)
                        final elapsed = DateTime.now().difference(callTime).inSeconds;
                        if (elapsed > _staleRequestThresholdSeconds) {
                          print('⚠️ [FG] 체크포인트 스킵: ${elapsed}초 지연');
                          _sendLiveLog(userId: user_id, requestType: 'fg_checkpoint_stale', error: 'skipped: ${elapsed}s delay$detectedInfo', lat: position.latitude, lon: position.longitude);
                          return;
                        }
                        // 🔄 네트워크 재시도 로직 (최대 3회, 1초 간격)
                        for (int attempt = 1; attempt <= 3; attempt++) {
                          try {
                            final response = await RankingAPI().addCheckPoint({
                              "user_id": user_id,
                              "slope_id": slopeId,
                              "coordinates": "${position.latitude}, ${position.longitude}"
                            });
                            final isSuccess = response.statusCode == 201 || response.statusCode == 416;
                            if (isSuccess) {
                              print('포그라운드 체크포인트 업데이트 성공: $slopeFullname (시도 $attempt)');
                              _lastCountMethodCall = DateTime.now(); // ✅ 성공 시에만 쿨다운 설정
                              _lastActionType = LastActionType.checkpoint;
                            } else {
                              print('포그라운드 체크포인트 업데이트 실패: ${response.statusCode}');
                            }
                            _sendLiveLog(userId: user_id, requestType: 'fg_checkpoint', error: (isSuccess ? 'success (attempt $attempt)' : 'statusCode: ${response.statusCode}') + detectedInfo, lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                            break; // API 호출 완료 시 루프 종료
                          } catch (e) {
                            print('포그라운드 체크포인트 오류 (시도 $attempt/3): $e');
                            if (attempt < 3) {
                              await Future.delayed(const Duration(seconds: 1));
                            } else {
                              _sendLiveLog(userId: user_id, requestType: 'fg_checkpoint_error', error: 'all retries failed: $e$detectedInfo', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                            }
                          }
                        }
                      }());
                    }
                  }

                  // 눈송이 처리
                  if (passPointInfo['type'] == 'snowball_info') {
                    if (resort_info['snowball'] == true) {
                      int setNum = passPointInfo['set_num'] ?? 0;
                      bool isGoldenSnowball = setNum >= 91;

                      bool canRegister = isGoldenSnowball ||
                          _lastSnowballMethodCall == null ||
                          DateTime.now().difference(_lastSnowballMethodCall!).inSeconds > 300;

                      if (canRegister) {
                        final snowballId = passPointInfo['id'];
                        futures.add(() async {
                          try {
                            final response = await SnowballAPI().createSnowballRecord({
                              "user_id": user_id,
                              "snowball_id": snowballId,
                              "coordinates": "POINT (${position.longitude} ${position.latitude})",
                              "event_date": _snowballShopViewModel.eventDate.value,
                            });
                            if (response.success) {
                              print('포그라운드 ${isGoldenSnowball ? "황금" : "하얀"}눈송이 기록 성공');
                              if (!isGoldenSnowball) {
                                _lastSnowballMethodCall = DateTime.now(); // ✅ 성공 시에만 쿨다운 설정
                              }
                            } else {
                              print('포그라운드 눈송이 기록 실패: ${response.error}');
                            }
                          } catch (e) {
                            print('포그라운드 눈송이 오류: $e');
                          }
                        }());
                      }
                    }
                  }

                  // 리셋 처리
                  if (passPointInfo['type'] == 'reset_point') {
                    if (_lastResetMethodCall == null || DateTime.now().difference(_lastResetMethodCall!).inSeconds > 180) {
                      // 📍 보간점 정보 (error 필드에 추가용)
                      final detectedLat = passPointInfo['detected_lat'];
                      final detectedLon = passPointInfo['detected_lon'];
                      final detectedInfo = (detectedLat != null && detectedLon != null)
                          ? ', detected: ${detectedLat.toStringAsFixed(6)},${detectedLon.toStringAsFixed(6)}'
                          : '';
                      // 📌 위치 데이터 캡처 시간 기록 (신선도 체크용)
                      final positionCapturedAt = DateTime.now();
                      futures.add(() async {
                        // 🔄 네트워크 재시도 로직 (최대 3회, 1초 간격)
                        for (int attempt = 1; attempt <= 3; attempt++) {
                          // 🕐 위치 데이터 신선도 체크 (5초 이상 지나면 스킵)
                          final positionAge = DateTime.now().difference(positionCapturedAt).inSeconds;
                          if (positionAge > _staleRequestThresholdSeconds) {
                            print('⏰ 리셋 스킵: 위치 데이터가 ${positionAge}초 경과 (stale)');
                            _sendLiveLog(userId: user_id, requestType: 'fg_reset_stale', error: 'position age ${positionAge}s > ${_staleRequestThresholdSeconds}s, skipped$detectedInfo', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                            break; // 오래된 데이터는 재시도하지 않고 종료
                          }
                          try {
                            final resetResponse = await RankingAPI().reset({"user_id": user_id});
                            if (resetResponse.success) {
                              print('리셋 성공 (시도 $attempt)');
                              _lastResetMethodCall = DateTime.now(); // ✅ 성공 시에만 쿨다운 설정
                              _lastActionType = LastActionType.reset;
                            }
                            _sendLiveLog(userId: user_id, requestType: 'fg_reset', error: (resetResponse.success ? 'success (attempt $attempt)' : resetResponse.error.toString()) + detectedInfo, lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                            break; // API 호출 완료 시 루프 종료
                          } catch (e) {
                            print('포그라운드 리셋 오류 (시도 $attempt/3): $e');
                            if (attempt < 3) {
                              await Future.delayed(const Duration(seconds: 1));
                            } else {
                              _sendLiveLog(userId: user_id, requestType: 'fg_reset_error', error: 'all retries failed: $e$detectedInfo', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                            }
                          }
                        }
                      }());
                    }
                  }

                  // 리스폰 처리 (새로운 액션 기반 로직)
                  if (passPointInfo['type'] == 'respawn_point') {
                    print('========== 리스폰 디버깅 시작 (액션 기반) ==========');
                    print('📍 마지막 액션 타입: $_lastActionType');

                    bool canRespawn = false;
                    String respawnReason = '';

                    // 액션 타입에 따라 리스폰 가능 여부 판단
                    if (_lastActionType == LastActionType.checkpoint) {
                      // 직전 액션이 체크포인트 통과 → 무조건 리스폰 성공
                      canRespawn = true;
                      respawnReason = '직전 액션이 체크포인트 통과 → 무조건 성공';
                    } else if (_lastActionType == LastActionType.respawn) {
                      // 직전 액션이 리스폰 → 60초 쿨다운 체크
                      final secondsSinceLastRespawn = _lastRespawnMethodCall != null
                          ? DateTime.now().difference(_lastRespawnMethodCall!).inSeconds
                          : 999;

                      if (secondsSinceLastRespawn > 60) {
                        canRespawn = true;
                        respawnReason = '직전 액션이 리스폰, 60초 경과 (${secondsSinceLastRespawn}초)';
                      } else {
                        canRespawn = false;
                        respawnReason = '직전 액션이 리스폰, 60초 미경과 (${secondsSinceLastRespawn}초)';
                      }
                    } else {
                      // 첫 리스폰 (none 또는 reset) → 무조건 성공
                      canRespawn = true;
                      respawnReason = '첫 리스폰 또는 리셋 후 → 무조건 성공';
                    }

                    print('✅ 리스폰 가능 여부: $canRespawn ($respawnReason)');

                    // 📍 보간점 정보 (error 필드에 추가용)
                    final detectedLat = passPointInfo['detected_lat'];
                    final detectedLon = passPointInfo['detected_lon'];
                    final detectedInfo = (detectedLat != null && detectedLon != null)
                        ? ', detected: ${detectedLat.toStringAsFixed(6)},${detectedLon.toStringAsFixed(6)}'
                        : '';

                    if (canRespawn) {
                      print('🚀 리스폰 실행!');
                      _respawnSkipLogSent = false;
                      // 📌 위치 데이터 캡처 시간 기록 (신선도 체크용)
                      final positionCapturedAt = DateTime.now();
                      futures.add(() async {
                        // 🔄 네트워크 재시도 로직 (최대 3회, 1초 간격)
                        for (int attempt = 1; attempt <= 3; attempt++) {
                          // 🕐 위치 데이터 신선도 체크 (5초 이상 지나면 스킵)
                          final positionAge = DateTime.now().difference(positionCapturedAt).inSeconds;
                          if (positionAge > _staleRequestThresholdSeconds) {
                            print('⏰ 리스폰 스킵: 위치 데이터가 ${positionAge}초 경과 (stale)');
                            _sendLiveLog(userId: user_id, requestType: 'fg_respawn_stale', error: 'position age ${positionAge}s > ${_staleRequestThresholdSeconds}s, skipped$detectedInfo', lat: position.latitude, lon: position.longitude);
                            break; // 오래된 데이터는 재시도하지 않고 종료
                          }
                          try {
                            final respawnResponse = await RankingAPI().respawn({"user_id": user_id});
                            if (respawnResponse.success) {
                              print('✅ 리스폰 성공 (시도 $attempt)');
                              _lastRespawnMethodCall = DateTime.now(); // ✅ 성공 시에만 쿨다운 설정
                              _lastActionType = LastActionType.respawn;

                              int insertedCount = respawnResponse.data['inserted_count'] ?? 0;
                              print('📊 추가된 라이딩 수: $insertedCount');
                              _sessionRideCount += insertedCount;
                              String? latestSlopeFullname = respawnResponse.data['latest_slope_fullname'];
                              if (latestSlopeFullname != null && latestSlopeFullname.isNotEmpty) {
                                _lastSlopeName = latestSlopeFullname;
                              }
                              if (insertedCount > 0) {
                                _lastRideAt = DateTime.now();
                              }
                              // 서버에서 최신 dailyTotalCount 받아오기 (Live Activity 업데이트용)
                              await fetchResortHome(user_id);
                              _updateLiveActivity();
                            }
                            _sendLiveLog(userId: user_id, requestType: 'fg_respawn', error: (respawnResponse.success ? 'success (attempt $attempt): $respawnReason' : respawnResponse.error.toString()) + detectedInfo, lat: position.latitude, lon: position.longitude);
                            break; // API 호출 완료 시 루프 종료
                          } catch (e) {
                            print('포그라운드 리스폰 오류 (시도 $attempt/3): $e');
                            if (attempt < 3) {
                              await Future.delayed(const Duration(seconds: 1));
                            } else {
                              _sendLiveLog(userId: user_id, requestType: 'fg_respawn_error', error: 'all retries failed: $e$detectedInfo', lat: position.latitude, lon: position.longitude);
                            }
                          }
                        }
                      }());
                    } else {
                      if (!_respawnSkipLogSent) {
                        _respawnSkipLogSent = true;
                        _sendLiveLog(userId: user_id, requestType: 'fg_respawn_skipped', error: respawnReason + detectedInfo, lat: position.latitude, lon: position.longitude);
                      }
                      print('⏭️  리스폰 스킵: $respawnReason');
                    }
                  }
                }

                // 모든 API 호출 병렬 실행 (타임아웃 적용으로 데드락 방지)
                if (futures.isNotEmpty) {
                  try {
                    await Future.wait(futures).timeout(
                      _futureWaitTimeout,
                      onTimeout: () {
                        print('⚠️ [FG] API 호출 타임아웃 (${_futureWaitTimeout.inSeconds}초)');
                        _sendLiveLog(
                          userId: user_id,
                          requestType: 'fg_api_timeout',
                          lat: position.latitude,
                          lon: position.longitude,
                          error: 'Future.wait timeout after ${_futureWaitTimeout.inSeconds}s',
                        );
                        return [];
                      },
                    );
                  } catch (e) {
                    print('⚠️ [FG] Future.wait 오류: $e');
                    _sendLiveLog(
                      userId: user_id,
                      requestType: 'fg_future_wait_error',
                      lat: position.latitude,
                      lon: position.longitude,
                      error: e.toString(),
                    );
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
                  _sendLiveLog(userId: user_id, requestType: 'fg_out_of_boundary', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                  _outOfBoundaryCount = 0; // 카운터 리셋
                  await stopForegroundLocationService();
                  await stopBackgroundLocationService();
                  await liveOff({"user_id": user_id}, user_id);
                }
              }
            });
          },
          onError: (error) {
            print('위치 스트림 에러: $error');
            _sendLiveLog(userId: user_id, requestType: 'fg_stream_error', error: error.toString());
          },
        );
        print('포그라운드 서비스 실행 성공');
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

      // 🔥 iOS 백그라운드 안정화
      // preventSuspend: false - iOS 14+에서 30초 이상 백그라운드 태스크 유지 시 앱 강제 종료됨
      // iOS 네이티브 백그라운드 위치 모드로 안정적으로 동작
      preventSuspend: false,
      disableMotionActivityUpdates: false,   // 반드시 false (중요)
      stopOnStationary: false,

      // 🔥 Android: 포그라운드 서비스 알림 비활성화 (LiveActivityService가 대신 표시)
      foregroundService: false,
      disableStopDetection: true,            // 🆕 정지 감지 비활성화 (삼성 Doze 대응)

      // 🔥 위치 업데이트 튜닝
      distanceFilter: 5,                     // 5m 이동 시 업데이트 (더 정밀한 추적)
      stationaryRadius: 25,
      elasticityMultiplier: 1.0,             // disableElasticity 쓰지 않음

      // 🔥 앱 종료 시 위치 추적 중단
      stopOnTerminate: true,
      startOnBoot: false,
      forceReloadOnBoot: false,

      // 🔥 iOS/Android 백그라운드 유지를 위한 heartbeat
      heartbeatInterval: 60,                 // 60초마다 heartbeat
      enableHeadless: false,                 // 앱 종료 시 위치 추적 중단 (iOS 미지원, 안정성 우선)

      // 🔥 위치 업데이트 속도 (삼성 Doze 정책 준수)
      locationUpdateInterval: 5000,           // 5초 (백업용, 포그라운드가 주력)
      fastestLocationUpdateInterval: 3000,    // 3초

      // 🔥 Android 배터리 최적화 안내
      backgroundPermissionRationale: PermissionRationale(
        title: "{applicationName}가 종료되거나 사용하지 않을 때 위치 접근을 허용하시겠습니까?",
        message: "라이브 기능과 랭킹 서비스를 위해 앱이 백그라운드에서도 위치를 수집해야 합니다.",
        positiveAction: '{backgroundPermissionOptionLabel}',
        negativeAction: '취소',
      ),

      showsBackgroundLocationIndicator: true,
      disableLocationAuthorizationAlert: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,

      // 🆕 캐시 방지: 위치 데이터를 SQLite에 저장하지 않음 (bg_heartbeat 캐시 문제 해결)
      persistMode: bg.Config.PERSIST_MODE_NONE,
    ));

    await bg.BackgroundGeolocation.start();

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
    bg.BackgroundGeolocation.onHeartbeat((bg.HeartbeatEvent event) async {
      // 캐시된 위치 사용 안함 - 항상 새 위치 요청
      try {
        final freshLocation = await bg.BackgroundGeolocation.getCurrentPosition(
          samples: 1,
          timeout: 30,
          maximumAge: 0,
          desiredAccuracy: 10,
        );
        print('💓 백그라운드 Heartbeat: ${freshLocation.coords.latitude}, ${freshLocation.coords.longitude}');
        // Heartbeat는 버퍼 없이 즉시 전송
        _sendHeartbeatLogDirect(
          userId: user_id,
          requestType: 'bg_heartbeat',
          lat: freshLocation.coords.latitude,
          lon: freshLocation.coords.longitude,
        );
      } catch (e) {
        print('💓 백그라운드 Heartbeat: 새 위치 획득 실패, 이벤트 무시 ($e)');
        // 새 위치 획득 실패 시 로그 전송하지 않음
      }
    });

    bg.BackgroundGeolocation.onLocation((bg.Location location) async {
      // 무한 루프 방지: getCurrentPosition 호출 중이면 스킵
      if (_isGettingBackgroundPosition) {
        return;
      }

      // 디바운싱: 3초 내 중복 호출 방지 (메모리 누수 방지)
      final now = DateTime.now();
      if (_lastOnLocationTime != null &&
          now.difference(_lastOnLocationTime!).inSeconds < 3) {
        return;
      }
      _lastOnLocationTime = now;

      // 캐시된 위치 대신 항상 새 위치 요청 (포그라운드와 동일하게 실시간 위치 사용)
      _isGettingBackgroundPosition = true;
      bg.Location freshLocation;
      try {
        freshLocation = await bg.BackgroundGeolocation.getCurrentPosition(
          samples: 1,
          timeout: 30,
          maximumAge: 0,
          desiredAccuracy: 10,
        );
      } catch (e) {
        print('📍 onLocation: 새 위치 획득 실패, 이벤트 무시 ($e)');
        _isGettingBackgroundPosition = false;
        return;
      }
      _isGettingBackgroundPosition = false;

      // 🛡️ 캐시된 오래된 위치 필터링 (iOS GPS 점프 방지)
      final locationTimestamp = DateTime.parse(freshLocation.timestamp);
      final positionAge = DateTime.now().difference(locationTimestamp);
      if (positionAge.inSeconds > 10) {
        print('⚠️ [백그라운드] 캐시된 위치 무시: ${positionAge.inSeconds}초 전 위치');
        _sendLiveLog(
          userId: user_id,
          requestType: 'bg_cached_position_ignored',
          lat: freshLocation.coords.latitude,
          lon: freshLocation.coords.longitude,
          error: 'age: ${positionAge.inSeconds}s',
        );
        return;
      }

      double latitude = freshLocation.coords.latitude;
      double longitude = freshLocation.coords.longitude;

      // 🛡️ 포그라운드일 때는 _latitude/_longitude 업데이트 건너뛰기
      // (포그라운드 스트림과 충돌 방지 - heartbeat 위치 튐 현상 해결)
      if (!_isAppInForeground) {
        _latitude.value = latitude;
        _longitude.value = longitude;
      }

      Position position = Position(
        latitude: latitude,
        longitude: longitude,
        accuracy: freshLocation.coords.accuracy,
        altitude: freshLocation.coords.altitude,
        heading: freshLocation.coords.heading,
        speed: freshLocation.coords.speed,
        speedAccuracy: freshLocation.coords.speedAccuracy,
        timestamp: locationTimestamp,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      // 🚨 GPS 튐 탐지: 정확도/속도 필터링
      if (!_validatePosition(position, user_id)) {
        return; // 유효하지 않은 위치면 처리 안함
      }

      // 이전 위치와의 거리 계산
      double? distanceFromLast;
      if (_lastValidationPosition != null) {
        distanceFromLast = Geolocator.distanceBetween(
          _lastValidationPosition!.latitude,
          _lastValidationPosition!.longitude,
          position.latitude,
          position.longitude,
        );
      }

      await _lock.synchronized(() async {
        bool withinBoundary = _checkPositionWithinBoundary(
            position.latitude,
            position.longitude,
            _resort_info['coordinates']['latitude'],
            _resort_info['coordinates']['longitude'],
            _resort_info['radius']
        );

        // 🔍 진단 로그: withinBoundary 결과
        if (!withinBoundary) {
          _sendLiveLog(
            userId: user_id,
            requestType: 'bg_outside_boundary',
            lat: latitude,
            lon: longitude,
            speed: position.speed,
            distance: distanceFromLast,
          );
        }

        if (withinBoundary) {
          // 경계 내부 진입 시 카운터 리셋
          _outOfBoundaryCount = 0;
          _locationErrorCount = 0;
          print('백그라운드 판별중');

          // 🛡️ 영역 데이터 보호: 비어있으면 재로드 (메모리 압박 대응)
          await _reloadAreaDataIfNeeded(user_id, position.latitude, position.longitude);

          // 현재 위치에서 영역 체크 (보간 제거)
          List<Map<String, dynamic>> passPointInfos = checkPositionInAreas(
            position,
            _slope_info,
            _snowball_info,
            _reset_point,
            _respawn_point,
          );

          // 병렬 처리를 위한 Future 리스트
          List<Future<void>> futures = [];

          for (var passPointInfo in passPointInfos) {
            // 체크포인트 처리
            if (passPointInfo['type'] == 'slope_info') {
              if (_lastCountMethodCall == null || DateTime.now().difference(_lastCountMethodCall!).inSeconds > 5) {
                final slopeId = passPointInfo['id'];
                final slopeFullname = passPointInfo['fullname'] ?? '';
                // 📍 보간점 정보 (error 필드에 추가용)
                final detectedLat = passPointInfo['detected_lat'];
                final detectedLon = passPointInfo['detected_lon'];
                final detectedInfo = (detectedLat != null && detectedLon != null)
                    ? ', detected: ${detectedLat.toStringAsFixed(6)},${detectedLon.toStringAsFixed(6)}'
                    : '';
                // 📌 위치 데이터 캡처 시간 기록 (신선도 체크용)
                final positionCapturedAt = DateTime.now();
                futures.add(() async {
                  // 🔄 네트워크 재시도 로직 (최대 3회, 1초 간격)
                  for (int attempt = 1; attempt <= 3; attempt++) {
                    // 🕐 위치 데이터 신선도 체크 (5초 이상 지나면 스킵)
                    final positionAge = DateTime.now().difference(positionCapturedAt).inSeconds;
                    if (positionAge > _staleRequestThresholdSeconds) {
                      print('⏰ 백그라운드 체크포인트 스킵: 위치 데이터가 ${positionAge}초 경과 (stale)');
                      _sendLiveLog(userId: user_id, requestType: 'bg_checkpoint_stale', error: 'position age ${positionAge}s > ${_staleRequestThresholdSeconds}s, skipped$detectedInfo', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                      break;
                    }
                    try {
                      final response = await RankingAPI().addCheckPoint({
                        "user_id": user_id,
                        "slope_id": slopeId,
                        "coordinates": "${position.latitude}, ${position.longitude}"
                      });
                      final isSuccess = response.statusCode == 201 || response.statusCode == 416;
                      if (isSuccess) {
                        print('백그라운드 체크포인트 업데이트 성공: $slopeFullname (시도 $attempt)');
                        _lastCountMethodCall = DateTime.now(); // ✅ 성공 시에만 쿨다운 설정
                        _lastActionType = LastActionType.checkpoint;
                      } else {
                        print('백그라운드 체크포인트 업데이트 실패: ${response.statusCode}');
                      }
                      _sendLiveLog(userId: user_id, requestType: 'bg_checkpoint', error: (isSuccess ? 'success (attempt $attempt)' : 'statusCode: ${response.statusCode}') + detectedInfo, lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                      break; // API 호출 완료 시 루프 종료
                    } catch (e) {
                      print('백그라운드 체크포인트 오류 (시도 $attempt/3): $e');
                      if (attempt < 3) {
                        await Future.delayed(const Duration(seconds: 1));
                      } else {
                        _sendLiveLog(userId: user_id, requestType: 'bg_checkpoint_error', error: 'all retries failed: $e$detectedInfo', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                      }
                    }
                  }
                }());
              }
            }

            // 눈송이 처리
            if (passPointInfo['type'] == 'snowball_info') {
              if (resort_info['snowball'] == true) {
                int setNum = passPointInfo['set_num'] ?? 0;
                bool isGoldenSnowball = setNum >= 91;

                bool canRegister = isGoldenSnowball ||
                    _lastSnowballMethodCall == null ||
                    DateTime.now().difference(_lastSnowballMethodCall!).inSeconds > 300;

                if (canRegister) {
                  final snowballId = passPointInfo['id'];
                  futures.add(() async {
                    try {
                      final response = await SnowballAPI().createSnowballRecord({
                        "user_id": user_id,
                        "snowball_id": snowballId,
                        "coordinates": "POINT (${position.longitude} ${position.latitude})",
                        "event_date": _snowballShopViewModel.eventDate.value,
                      });
                      if (response.success) {
                        print('백그라운드 ${isGoldenSnowball ? "황금" : "하얀"}눈송이 기록 성공');
                        if (!isGoldenSnowball) {
                          _lastSnowballMethodCall = DateTime.now(); // ✅ 성공 시에만 쿨다운 설정
                        }
                      } else {
                        print('백그라운드 눈송이 기록 실패: ${response.error}');
                      }
                    } catch (e) {
                      print('백그라운드 눈송이 오류: $e');
                    }
                  }());
                }
              }
            }

            // 리셋 처리
            if (passPointInfo['type'] == 'reset_point') {
              if (_lastResetMethodCall == null || DateTime.now().difference(_lastResetMethodCall!).inSeconds > 180) {
                // 📍 보간점 정보 (error 필드에 추가용)
                final detectedLat = passPointInfo['detected_lat'];
                final detectedLon = passPointInfo['detected_lon'];
                final detectedInfo = (detectedLat != null && detectedLon != null)
                    ? ', detected: ${detectedLat.toStringAsFixed(6)},${detectedLon.toStringAsFixed(6)}'
                    : '';
                // 📌 위치 데이터 캡처 시간 기록 (신선도 체크용)
                final positionCapturedAt = DateTime.now();
                futures.add(() async {
                  // 🔄 네트워크 재시도 로직 (최대 3회, 1초 간격)
                  for (int attempt = 1; attempt <= 3; attempt++) {
                    // 🕐 위치 데이터 신선도 체크 (5초 이상 지나면 스킵)
                    final positionAge = DateTime.now().difference(positionCapturedAt).inSeconds;
                    if (positionAge > _staleRequestThresholdSeconds) {
                      print('⏰ 백그라운드 리셋 스킵: 위치 데이터가 ${positionAge}초 경과 (stale)');
                      _sendLiveLog(userId: user_id, requestType: 'bg_reset_stale', error: 'position age ${positionAge}s > ${_staleRequestThresholdSeconds}s, skipped$detectedInfo', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                      break; // 오래된 데이터는 재시도하지 않고 종료
                    }
                    try {
                      final resetResponse = await RankingAPI().reset({"user_id": user_id});
                      if (resetResponse.success) {
                        print('리셋 성공 (시도 $attempt)');
                        _lastResetMethodCall = DateTime.now(); // ✅ 성공 시에만 쿨다운 설정
                        _lastActionType = LastActionType.reset;
                      }
                      _sendLiveLog(userId: user_id, requestType: 'bg_reset', error: (resetResponse.success ? 'success (attempt $attempt)' : resetResponse.error.toString()) + detectedInfo, lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                      break; // API 호출 완료 시 루프 종료
                    } catch (e) {
                      print('백그라운드 리셋 오류 (시도 $attempt/3): $e');
                      if (attempt < 3) {
                        await Future.delayed(const Duration(seconds: 1));
                      } else {
                        _sendLiveLog(userId: user_id, requestType: 'bg_reset_error', error: 'all retries failed: $e$detectedInfo', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                      }
                    }
                  }
                }());
              }
            }

            // 리스폰 처리 - persistMode: PERSIST_MODE_NONE으로 캐시 문제 해결됨, 백그라운드에서도 활성화
            if (passPointInfo['type'] == 'respawn_point') {
              // 리스폰 조건 판별 (포그라운드와 동일한 로직)
              bool canRespawn = false;
              String respawnReason = '';

              if (_lastActionType == LastActionType.checkpoint) {
                // 직전 액션이 체크포인트 통과 → 무조건 리스폰 성공
                canRespawn = true;
                respawnReason = '직전 액션이 체크포인트 통과 → 무조건 성공';
              } else if (_lastActionType == LastActionType.respawn) {
                // 직전 액션이 리스폰 → 60초 쿨다운 체크
                final secondsSinceLastRespawn = _lastRespawnMethodCall != null
                    ? DateTime.now().difference(_lastRespawnMethodCall!).inSeconds
                    : 999;
                if (secondsSinceLastRespawn > 60) {
                  canRespawn = true;
                  respawnReason = '직전 액션이 리스폰, 60초 경과 (${secondsSinceLastRespawn}초)';
                } else {
                  canRespawn = false;
                  respawnReason = '직전 액션이 리스폰, 60초 미경과 (${secondsSinceLastRespawn}초)';
                }
              } else {
                // 첫 리스폰 (none 또는 reset) → 무조건 성공
                canRespawn = true;
                respawnReason = '첫 리스폰 또는 리셋 후 → 무조건 성공';
              }

              // 📍 보간점 정보 (error 필드에 추가용)
              final detectedLat = passPointInfo['detected_lat'];
              final detectedLon = passPointInfo['detected_lon'];
              final detectedInfo = (detectedLat != null && detectedLon != null)
                  ? ', detected: ${detectedLat.toStringAsFixed(6)},${detectedLon.toStringAsFixed(6)}'
                  : '';

              if (!canRespawn) {
                if (!_respawnSkipLogSent) {
                  _sendLiveLog(
                    userId: user_id,
                    requestType: 'bg_respawn_skip',
                    lat: position.latitude,
                    lon: position.longitude,
                    error: respawnReason + detectedInfo,
                  );
                  _respawnSkipLogSent = true;
                }
              } else if (_lastRespawnMethodCall == null || DateTime.now().difference(_lastRespawnMethodCall!).inSeconds > 10) {
                _respawnSkipLogSent = false;
                final respawnId = passPointInfo['id'];
                // 📌 위치 데이터 캡처 시간 기록 (신선도 체크용)
                final positionCapturedAt = DateTime.now();
                futures.add(() async {
                  // 🔄 네트워크 재시도 로직 (최대 3회, 1초 간격)
                  for (int attempt = 1; attempt <= 3; attempt++) {
                    // 🕐 위치 데이터 신선도 체크 (5초 이상 지나면 스킵)
                    final positionAge = DateTime.now().difference(positionCapturedAt).inSeconds;
                    if (positionAge > _staleRequestThresholdSeconds) {
                      print('⏰ 백그라운드 리스폰 스킵: 위치 데이터가 ${positionAge}초 경과 (stale)');
                      _sendLiveLog(userId: user_id, requestType: 'bg_respawn_stale', error: 'position age ${positionAge}s > ${_staleRequestThresholdSeconds}s, skipped$detectedInfo', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                      break; // 오래된 데이터는 재시도하지 않고 종료
                    }
                    try {
                      final respawnResponse = await RankingAPI().respawn({
                        "user_id": user_id,
                        "respawn_id": respawnId,
                        "coordinates": "${position.latitude}, ${position.longitude}"
                      });
                      if (respawnResponse.success) {
                        print('백그라운드 리스폰 성공 (시도 $attempt)');
                        _lastRespawnMethodCall = DateTime.now(); // ✅ 성공 시에만 쿨다운 설정
                        _lastActionType = LastActionType.respawn;

                        // 라이브 액티비티 업데이트 (포그라운드와 동일하게 처리)
                        int insertedCount = respawnResponse.data['inserted_count'] ?? 0;
                        print('📊 [BG] 추가된 라이딩 수: $insertedCount');
                        _sessionRideCount += insertedCount;
                        String? latestSlopeFullname = respawnResponse.data['latest_slope_fullname'];
                        if (latestSlopeFullname != null && latestSlopeFullname.isNotEmpty) {
                          _lastSlopeName = latestSlopeFullname;
                        }
                        if (insertedCount > 0) {
                          _lastRideAt = DateTime.now();
                        }
                        // 서버에서 최신 dailyTotalCount 받아오기 (Live Activity 업데이트용)
                        await fetchResortHome(user_id);
                        _updateLiveActivity();
                      }
                      _sendLiveLog(userId: user_id, requestType: 'bg_respawn', error: (respawnResponse.success ? 'success (attempt $attempt): $respawnReason' : respawnResponse.error.toString()) + detectedInfo, lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                      break; // API 호출 완료 시 루프 종료
                    } catch (e) {
                      print('백그라운드 리스폰 오류 (시도 $attempt/3): $e');
                      if (attempt < 3) {
                        await Future.delayed(const Duration(seconds: 1));
                      } else {
                        _sendLiveLog(userId: user_id, requestType: 'bg_respawn_error', error: 'all retries failed: $e$detectedInfo', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
                      }
                    }
                  }
                }());
              }
            }
          }

          // 모든 API 호출 병렬 실행 (타임아웃 적용으로 데드락 방지)
          if (futures.isNotEmpty) {
            try {
              await Future.wait(futures).timeout(
                _futureWaitTimeout,
                onTimeout: () {
                  print('⚠️ [BG] API 호출 타임아웃 (${_futureWaitTimeout.inSeconds}초)');
                  _sendLiveLog(
                    userId: user_id,
                    requestType: 'bg_api_timeout',
                    lat: position.latitude,
                    lon: position.longitude,
                    error: 'Future.wait timeout after ${_futureWaitTimeout.inSeconds}s',
                  );
                  return [];
                },
              );
            } catch (e) {
              print('⚠️ [BG] Future.wait 오류: $e');
              _sendLiveLog(
                userId: user_id,
                requestType: 'bg_future_wait_error',
                lat: position.latitude,
                lon: position.longitude,
                error: e.toString(),
              );
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
            _sendLiveLog(userId: user_id, requestType: 'bg_out_of_boundary', lat: position.latitude, lon: position.longitude, speed: position.speed, distance: distanceFromLast);
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

  /// 영역 데이터가 비어있으면 재로드 (메모리 압박 대응)
  /// 반환값: true = 데이터 정상, false = 재로드 실패
  Future<bool> _reloadAreaDataIfNeeded(int userId, double lat, double lon) async {
    // 데이터가 있으면 바로 통과
    if (_slope_info.isNotEmpty) return true;

    // 이미 재로드 중이면 스킵
    if (_isReloadingAreaData) {
      print('⏳ [AreaData] 이미 재로드 중, 스킵');
      return false;
    }

    // 30초 내 재로드 시도한 적 있으면 스킵 (과도한 API 호출 방지)
    if (_lastAreaDataReload != null &&
        DateTime.now().difference(_lastAreaDataReload!).inSeconds < 30) {
      print('⏳ [AreaData] 30초 내 재로드 시도함, 스킵');
      return false;
    }

    print('⚠️ [AreaData] 영역 데이터 비어있음, 재로드 시도');
    _isReloadingAreaData = true;
    _lastAreaDataReload = DateTime.now();

    try {
      // check_wb API 호출하여 영역 데이터 재로드
      final response = await RankingAPI().check_wb({
        "user_id": userId,
        "coordinates": "POINT ($lon $lat)"
      }).timeout(_apiTimeout);

      if (response.success) {
        _slope_info.value = List<Map<String, dynamic>>.from(response.data['slope_info']);
        _snowball_info.value = List<Map<String, dynamic>>.from(response.data['snowball_info']);
        _reset_point.value = List<Map<String, dynamic>>.from(response.data['reset_point']);
        _respawn_point.value = List<Map<String, dynamic>>.from(response.data['respawn_point']);

        print('✅ [AreaData] 재로드 성공: slope=${_slope_info.length}, respawn=${_respawn_point.length}');
        _sendLiveLog(
          userId: userId,
          requestType: 'area_data_reloaded',
          lat: lat,
          lon: lon,
          error: 'slope: ${_slope_info.length}, reset: ${_reset_point.length}, respawn: ${_respawn_point.length}',
        );
        return true;
      } else {
        print('❌ [AreaData] 재로드 실패: ${response.error}');
        _sendLiveLog(
          userId: userId,
          requestType: 'area_data_reload_failed',
          lat: lat,
          lon: lon,
          error: response.error.toString(),
        );
        return false;
      }
    } catch (e) {
      print('❌ [AreaData] 재로드 오류: $e');
      _sendLiveLog(
        userId: userId,
        requestType: 'area_data_reload_error',
        lat: lat,
        lon: lon,
        error: e.toString(),
      );
      return false;
    } finally {
      _isReloadingAreaData = false;
    }
  }

  /// GPS 튐 탐지 (스키/보드용)
  /// 반환값: true = 유효한 위치, false = 무시해야 할 위치
  bool _validatePosition(Position newPosition, int userId) {
    // 1️⃣ 정확도 필터링 (GPS 신호 약하면 무시)
    if (newPosition.accuracy > 50) {
      print('⚠️ [GPS] 정확도 낮음 무시: ${newPosition.accuracy.toStringAsFixed(0)}m');
      _sendLiveLog(
        userId: userId,
        requestType: 'gps_low_accuracy_ignored',
        error: 'accuracy: ${newPosition.accuracy.toStringAsFixed(0)}m',
        lat: newPosition.latitude,
        lon: newPosition.longitude,
      );
      return false;
    }

    // 2️⃣ 속도 기반 필터링 (비현실적 속도 감지)
    if (_lastValidationPosition != null && _lastValidationTime != null) {
      final distance = Geolocator.distanceBetween(
        _lastValidationPosition!.latitude, _lastValidationPosition!.longitude,
        newPosition.latitude, newPosition.longitude,
      );
      final timeDiff = DateTime.now().difference(_lastValidationTime!).inMilliseconds / 1000.0;

      if (timeDiff > 0.5 && timeDiff < 30) { // 0.5초 이상일 때만 (너무 짧은 간격 제외)
        final speedMps = distance / timeDiff;
        final speedKmh = speedMps * 3.6;

        // 🚨 비현실적 속도: 150km/h 초과 시 무시 (스키 최고속도 ~120km/h)
        if (speedKmh > 150) {
          print('🚨 [GPS] 비현실적 속도 무시: ${speedKmh.toStringAsFixed(1)}km/h, dist=${distance.toStringAsFixed(0)}m');
          _sendLiveLog(
            userId: userId,
            requestType: 'gps_high_speed_ignored',
            error: 'speed: ${speedKmh.toStringAsFixed(1)}km/h, dist: ${distance.toStringAsFixed(0)}m, time: ${timeDiff.toStringAsFixed(1)}s',
            lat: newPosition.latitude,
            lon: newPosition.longitude,
          );
          return false;
        }
      }
    }

    _lastValidationPosition = newPosition;
    _lastValidationTime = DateTime.now();
    return true;
  }

  Future<void> liveOff(Map<String, dynamic> body, user_id, {bool showSummary = true}) async {
    // 🔥 중복 실행 방지
    if (_isLiveOffInProgress) {
      print('⚠️ liveOff 이미 진행 중, 중복 호출 무시');
      return;
    }
    _isLiveOffInProgress = true;

    try {
      isLoading(true);

      // 🔥 API 호출 전에 위치 서비스 먼저 종료 (API 실패해도 위치 추적은 반드시 중단)
      await Future.wait([
        stopBackgroundLocationService(),
        stopForegroundLocationService(),
      ]);
      print('🛑 위치 추적 서비스 종료 완료');

      final ApiResponse response_off = await RankingAPI().liveOff(body);

      if (response_off.success) {
        // 🔥 로그 전송 (비동기, await 안함)
        _sendLiveLog(userId: user_id, requestType: 'liveOff_success', lat: _latitude.value, lon: _longitude.value);

        // ✅ 동기 작업들 (빠름)
        _stopHeartbeatTimer();
        _currentLiveUserId = null;
        _stopLogFlushTimer();
        _errorLogSubscription?.cancel();
        _errorLogSubscription = null;
        _isLoggingOn = false;
        _stopLiveFriendsWorker();

        // ✅ 세션 변수 초기화
        _sessionRideCount = 0;
        _lastSlopeName = '';
        _lastRideAt = null;
        _lastActionType = LastActionType.none;
        _lastCountMethodCall = null;
        _lastRespawnMethodCall = null;
        _lastSnowballMethodCall = null;
        _lastResetMethodCall = null;
        _respawnSkipLogSent = false;
        _previousValidPosition = null;
        _outOfBoundaryCount = 0;
        _lastOutOfBoundaryTime = null;

        // ✅ 라이브 액티비티 알림 종료 (await 필수 - 알림이 사라진 후 다이얼로그 표시)
        await _endLiveActivity('liveOff()');

        // 🔥 여기서 로딩 다이얼로그 먼저 닫기 (빠른 응답)
        isLoading(false);
        print('liveOff 완료');

        // 🔥 비필수 작업들은 백그라운드에서 처리 (다이얼로그와 병렬 실행)
        _performPostLiveOffTasks(user_id);

        // ✅ 라이브오프 요약 다이얼로그 표시 (showSummary가 true일 때만)
        if (showSummary) {
          try {
            final summary = LiveOffSummaryModel.fromJson(response_off.data);
            await showLiveOffSummaryDialog(summary);
          } catch (e) {
            print('❌ 라이브오프 요약 다이얼로그 오류: $e');
          }
        }

        return;
      } else {
        // API 실패해도 정리 작업 수행
        _stopHeartbeatTimer();
        _currentLiveUserId = null;
        _stopLogFlushTimer();
        _stopLiveFriendsWorker();
        await _endLiveActivity('liveOff() - API failed');
        CustomFullScreenDialog.cancelDialog();
        print('⚠️ liveOff API 실패, 위치 서비스는 종료됨');
        print('⚠️ liveOff API 실패 상세: success=${response_off.success}, error=${response_off.error}, statusCode=${response_off.statusCode}, data=${response_off.data}');
      }
      isLoading(false);
    } finally {
      // 🔥 liveOff 완료 후 플래그 리셋 (성공/실패 모두)
      _isLiveOffInProgress = false;
    }
  }

  /// liveOff 후 백그라운드 정리 작업 (사용자 대기 불필요)
  Future<void> _performPostLiveOffTasks(int user_id) async {
    try {
      // 로그 버퍼 전송
      _flushLogBuffer();

      // 친구들에게서 라이브온 알림 제거
      _removeLiveOnNotification();

      // 데이터 갱신 (UI 업데이트용)
      final ApiResponse response_fetchResortHome = await ResortHomeAPI().fetchResortHomeData(user_id);
      if (response_fetchResortHome.success) {
        _resortHomeModel.value = ResortHomeModel.fromJson(response_fetchResortHome.data);
      }
      _userViewModel.updateUserModel_api(_userViewModel.user.user_id);

      // Geofence 모니터링 재시작 (자동 라이브온 설정이 켜져있을 때만)
      if (isAutoLiveOnEnabled) {
        _restartGeofenceMonitoring();
      }
    } catch (e) {
      print('⚠️ postLiveOffTasks 오류: $e');
    }
  }

  /// Geofence 전용 모드 재시작 (liveOff 후 호출)
  Future<void> _restartGeofenceMonitoring() async {
    try {
      // 🔥 기존 지오펜스 상태 초기화를 위해 완전히 새로 등록
      // (INSIDE 상태로 남아있으면 재진입 감지가 안됨)
      await setupResortGeofences();
      print('🌐 Geofence 모니터링 재시작 완료 (지오펜스 재등록됨)');
    } catch (e) {
      print('❌ Geofence 모니터링 재시작 실패: $e');
    }
  }

  Future<ApiResponse> liveOn(Map<String, dynamic> body) async {
    try {
      isLoading(true);
      final ApiResponse response = await RankingAPI().check_wb(body);
      if (response.success) {
        final resortInfo = response.data['resort_info'] as Map<String, dynamic>;
        _resort_info.value   = resortInfo;
        _slope_info.value    = List<Map<String, dynamic>>.from(response.data['slope_info']);
        _snowball_info.value = List<Map<String, dynamic>>.from(response.data['snowball_info']);
        _reset_point.value   = List<Map<String, dynamic>>.from(response.data['reset_point']);
        _respawn_point.value = List<Map<String, dynamic>>.from(response.data['respawn_point']);

        // 🔍 디버그: respawn_point 데이터 확인
        //print('🔍 [liveOn] respawn_point count: ${_respawn_point.length}');
        for (var rp in _respawn_point) {
          print('🔍 [liveOn] respawn_point: $rp');
        }

        // 🔍 디버그: resort_info 확인
        final resortFullname = resortInfo['fullname'] ?? '';
        print('🔍 [liveOn] resort_info: $resortInfo');
        print('🔍 [liveOn] resortFullname: $resortFullname');

        // ✅ 라이브 액티비티 시작 (iOS, Android 모두 지원)
        _liveOnStartedAt = DateTime.now();
        // 세션 변수 초기화
        _sessionRideCount = 0;
        _lastSlopeName = '';
        _lastRideAt = null;
        _previousValidPosition = null; // GPS 보간용 이전 위치 초기화

        // 🔥 플랫폼별 Live Activity 시작 처리
        // - Android: 지오펜스 이벤트에서 ForegroundService 시작 허용 → 항상 시도
        // - iOS: 백그라운드에서 Live Activity 시작 불가 → 포그라운드에서만 시작
        final bool shouldStartNow = Platform.isAndroid || _isAppInForeground;

        if (shouldStartNow) {
          _liveActivityId = await LiveActivityService.start(
            liveOnStartAt: _liveOnStartedAt!,
            todayRideCount: resortHomeModel?.dailyTotalCount ?? 0,
            sessionRideCount: _sessionRideCount,
            lastSlopeName: '—',
            resortName: resortFullname,
            liveFriendCount: _getLiveFriendCount(),
          );
          _pendingLiveActivityData = null;
          print('📱 [liveOn] Live Activity 시작 시도 (${Platform.isAndroid ? "Android" : "iOS"})');
        } else {
          // iOS 백그라운드 상태: Live Activity 데이터 저장 (포그라운드 복귀 시 시작)
          print('📱 [liveOn] iOS 백그라운드 상태 - Live Activity 시작 지연');
          _pendingLiveActivityData = {
            'liveOnStartAt': _liveOnStartedAt!,
            'todayRideCount': resortHomeModel?.dailyTotalCount ?? 0,
            'sessionRideCount': _sessionRideCount,
            'lastSlopeName': '—',
            'resortName': resortFullname,
            'liveFriendCount': _getLiveFriendCount(),
          };
        }

        // 친구 라이브 상태 변경 감지 워커 시작 (실시간 업데이트)
        _startLiveFriendsWorker();

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

  /// 앱 재시작 시 liveOn 복구 (비정상 종료 후 재시작 대응)
  /// 이전 세션 정리(liveOff) 후 현재 위치에서 liveOn 재시도
  Future<void> restoreLiveOn(int userId) async {
    CustomFullScreenDialog.showDialog();
    try {
      print('🔄 [restoreLiveOn] 복구 시작 - userId: $userId');

      // 1. 이전 세션 정리 (liveOff)
      // - 서버에 liveOff 요청
      // - 위치 추적 서비스 정리
      // - 쿨다운 변수 초기화
      print('🔄 [restoreLiveOn] 이전 세션 정리 (liveOff)');
      await liveOff({"user_id": userId}, userId, showSummary: false);

      // 2. 현재 위치에서 liveOn 시도
      // startLiveLocationService → startForegroundLocationService 내부에서:
      // - 현재 GPS 위치 가져오기
      // - liveOn API 호출 (서버에서 경계 내부 확인 + slope_info 로드)
      // - 경계 내부면 위치 스트림 시작, 외부면 중단
      print('🔄 [restoreLiveOn] liveOn 시도');
      await startLiveLocationService(user_id: userId);

      // 3. UI 상태 업데이트 (버튼 색상 등)
      await _userViewModel.updateUserModel_api(userId);

      _sendLiveLog(userId: userId, requestType: 'liveOn_restored', lat: _latitude.value, lon: _longitude.value);
      print('✅ [restoreLiveOn] 복구 완료');
    } catch (e) {
      print('❌ [restoreLiveOn] 복구 중 오류: $e');
      _sendLiveLog(userId: userId, requestType: 'liveOn_restore_error', error: e.toString());
    } finally {
      CustomFullScreenDialog.cancelDialog();
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

  /// 🛡️ 메모리 누수 방지: StreamSubscription 패턴 사용
  Future<void> getBanner(String accountName) async {
    Stream<DocumentSnapshot<Map<String, dynamic>>> stream = FirebaseFirestore.instance
        .collection('banner')
        .doc(accountName)
        .snapshots();

    switch (accountName) {
      case 'home':
        _bannerSub_home?.cancel();
        _bannerSub_home = stream.listen((snapshot) {
          bannerData_home.value = snapshot.data();
        });
        break;
      case 'fleaMarket':
        _bannerSub_fleaMarket?.cancel();
        _bannerSub_fleaMarket = stream.listen((snapshot) {
          bannerData_fleaMarket.value = snapshot.data();
        });
        break;
      case 'moreTab':
        _bannerSub_moreTab?.cancel();
        _bannerSub_moreTab = stream.listen((snapshot) {
          bannerData_moreTab.value = snapshot.data();
        });
        break;
      case 'community':
        _bannerSub_community?.cancel();
        _bannerSub_community = stream.listen((snapshot) {
          bannerData_community.value = snapshot.data();
        });
        break;
      case 'community_detail':
        _bannerSub_community_detail?.cancel();
        _bannerSub_community_detail = stream.listen((snapshot) {
          bannerData_community_detail.value = snapshot.data();
        });
        break;
      case 'ranking':
        _bannerSub_ranking?.cancel();
        _bannerSub_ranking = stream.listen((snapshot) {
          bannerData_ranking.value = snapshot.data();
        });
        break;
      default:
        print('알 수 없는 accountName: $accountName');
    }
  }

  // ============================================
  // Geofencing - 리조트 진입 감지 및 자동 라이브온
  // ============================================

  /// 리조트 Geofence 등록 (앱 시작 시 호출)
  /// 자동 라이브온 설정이 켜진 사용자만 등록됨
  Future<void> setupResortGeofences() async {
    try {
      print('🌐 리조트 Geofence 설정 시작...');

      // 🚫 자동 라이브온 설정이 꺼져있으면 지오펜스 등록하지 않음
      if (!isAutoLiveOnEnabled) {
        print('ℹ️ 자동 라이브온 설정이 꺼져있음, Geofence 등록 생략');
        await removeAllGeofences();
        return;
      }

      // 0. BackgroundGeolocation 초기화 (Geofence 전용 모드)
      // 🔋 배터리 최적화 + 안정적인 지오펜스 감지를 위한 설정
      await bg.BackgroundGeolocation.ready(bg.Config(
        // 📍 위치 정확도: Android는 MEDIUM 필수, iOS는 LOW로도 충분
        desiredAccuracy: Platform.isAndroid
            ? bg.Config.DESIRED_ACCURACY_MEDIUM
            : bg.Config.DESIRED_ACCURACY_LOW,
        // 📏 거리 필터: 50m 이동 시 위치 업데이트 (더 정밀한 지오펜스 감지)
        distanceFilter: 50,
        // 🔥 앱 종료 후에도 지오펜스 모니터링 유지
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        // 🔥 iOS: "항상 허용" 권한 요청 (백그라운드 지오펜스에 필수)
        locationAuthorizationRequest: 'Always',
        // Geofence 전용 설정
        geofenceProximityRadius: 100000, // 100km 범위 내 Geofence 모니터링
        geofenceInitialTriggerEntry: false, // false: 실제 반경 진입 시에만 ENTER 트리거 (이미 안에 있으면 무시)
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        // 🔥 iOS 파란색 상태바 표시 안함 (Geofence 전용 모드에서는 불필요)
        showsBackgroundLocationIndicator: false,
        // 🔥 Android: Geofence 백그라운드 작동을 위해 포그라운드 서비스 필수
        // foregroundService: false로 하면 Android가 백그라운드에서 앱을 kill함
        foregroundService: Platform.isAndroid,
        // ⏱️ 위치 업데이트 주기 (배터리 절약 + 안정적 감지)
        // - 차량 60km/h 기준: 1분에 1km 이동 → 리조트 반경(1-5km) 내 충분히 감지
        locationUpdateInterval: 60000, // 1분마다 위치 확인
        fastestLocationUpdateInterval: 30000, // 최소 30초 간격 (너무 빠른 업데이트 방지)
        // 🔥 Android 알림 최소화 (조용한 알림)
        notification: bg.Notification(
          title: '스노우라이브',
          text: '스키장 도착 시 자동으로 라이브가 시작됩니다',
          sticky: false,
          priority: bg.Config.NOTIFICATION_PRIORITY_MIN,
          channelName: 'Geofence Service',
        ),
      ));
      print('✅ BackgroundGeolocation 초기화 완료');

      // 🔥 Headless 태스크 등록 (앱 종료 시에도 지오펜스 이벤트 처리)
      bg.BackgroundGeolocation.registerHeadlessTask(backgroundGeolocationHeadlessTask);
      print('✅ Headless 태스크 등록 완료');

      // 1. 서버에서 활성 리조트 목록 조회
      final response = await ResortAPI().getActiveResorts();
      if (!response.success) {
        print('❌ 리조트 목록 조회 실패: ${response.error}');
        return;
      }

      final List<dynamic> resortList = response.data as List<dynamic>;
      print('📍 활성 리조트 ${resortList.length}개 조회됨');

      // 2. 기존 Geofence 모두 삭제
      await bg.BackgroundGeolocation.removeGeofences();
      print('🗑️ 기존 Geofence 삭제 완료');

      // 3. 새 Geofence 등록
      int registeredCount = 0;
      _registeredGeofences.clear(); // 기존 목록 초기화

      for (var resortJson in resortList) {
        try {
          print('📋 리조트 JSON: $resortJson');

          // coordinates_geofencing 필드 확인
          final coordinatesGeofencing = resortJson['coordinates_geofencing'];
          if (coordinatesGeofencing == null || coordinatesGeofencing.toString().isEmpty) {
            print('⚠️ coordinates_geofencing 없음, 스킵: ${resortJson['fullname']}');
            continue;
          }

          final resort = ResortGeofence.fromJson(resortJson as Map<String, dynamic>);

          // 좌표가 유효한지 확인
          if (resort.latitude == 0.0 || resort.longitude == 0.0) {
            print('⚠️ 좌표 파싱 실패, 스킵: ${resort.fullname}');
            continue;
          }

          await bg.BackgroundGeolocation.addGeofence(bg.Geofence(
            identifier: resort.identifier,
            latitude: resort.latitude,
            longitude: resort.longitude,
            radius: resort.radius,
            notifyOnEntry: true,
            notifyOnExit: true,
            extras: {
              'resort_id': resort.resortId,
              'fullname': resort.fullname,
            },
          ));

          // 초기 위치 체크용으로 정보 저장
          _registeredGeofences.add({
            'resort_id': resort.resortId,
            'fullname': resort.fullname,
            'latitude': resort.latitude,
            'longitude': resort.longitude,
            'radius': resort.radius,
          });

          registeredCount++;
          print('✅ Geofence 등록: ${resort.fullname} (lat=${resort.latitude}, lon=${resort.longitude}, r=${resort.radius}m)');
        } catch (e) {
          print('⚠️ Geofence 등록 실패: $resortJson - $e');
        }
      }
      print('📊 총 $registeredCount개 Geofence 등록됨');

      // 4. Geofence 이벤트 리스너 설정
      _setupGeofenceListener();

      // 5. Geofence 모니터링 시작
      await bg.BackgroundGeolocation.startGeofences();
      print('🌐 리조트 Geofence 모니터링 시작');

      // 현재 상태 로그
      final state = await bg.BackgroundGeolocation.state;
      print('📊 BackgroundGeolocation 상태: enabled=${state.enabled}, trackingMode=${state.trackingMode}');

      // 초기 위치 체크 제거 - GPS 활성화 방지 (Geofence 이벤트로만 감지)

    } catch (e) {
      print('❌ Geofence 설정 오류: $e');
    }
  }

  /// 모든 Geofence 해제 및 백그라운드 위치 추적 중지
  /// 자동 라이브온 설정이 꺼질 때 호출
  Future<void> removeAllGeofences() async {
    try {
      print('🗑️ 모든 Geofence 해제 시작...');

      // 등록된 모든 Geofence 삭제
      await bg.BackgroundGeolocation.removeGeofences();
      _registeredGeofences.clear();

      // BackgroundGeolocation 중지 (백그라운드 위치 추적 완전 중지)
      await bg.BackgroundGeolocation.stop();

      print('✅ 모든 Geofence 해제 및 백그라운드 위치 추적 중지 완료');
    } catch (e) {
      print('❌ Geofence 해제 오류: $e');
    }
  }

  /// Geofence 이벤트 리스너 설정 (중복 등록 방지)
  void _setupGeofenceListener() {
    // 🔥 기존 리스너 모두 제거 후 새로 등록 (중복 방지)
    bg.BackgroundGeolocation.removeListeners();

    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
      final resortId = event.extras?['resort_id'];
      final resortName = event.extras?['fullname'] ?? '리조트';

      print('📍 Geofence 이벤트: ${event.action} - $resortName (ID: $resortId)');

      if (event.action == 'ENTER') {
        _handleGeofenceEnter(resortId, resortName);
      }
      // EXIT 이벤트는 처리하지 않음 (자동 라이브오프 비활성화)
    });
  }

  /// 리조트 진입 시 처리 (자동 라이브온)
  Future<void> _handleGeofenceEnter(dynamic resortId, String resortName) async {
    print('🎿 리조트 진입 감지: $resortName');

    // 🔥 중복 실행 방지 - 이미 자동 라이브온 진행 중이면 무시
    if (_isAutoLiveOnInProgress) {
      print('⚠️ 자동 라이브온 이미 진행 중, 중복 호출 무시');
      return;
    }

    // 이미 라이브온 상태면 무시
    if (isPositionStreamActive || _liveActivityId != null) {
      print('ℹ️ 이미 라이브온 활성 상태, 자동 라이브온 생략');
      return;
    }

    // 자동 라이브온 설정이 꺼져있으면 무시
    if (!isAutoLiveOnEnabled) {
      print('ℹ️ 자동 라이브온 설정이 꺼져있음, 자동 라이브온 생략');
      return;
    }

    // 사용자 ID 확인
    final userId = _userViewModel.user.user_id;
    if (userId == null) {
      print('❌ 사용자 ID 없음, 자동 라이브온 시작 불가');
      return;
    }

    // 🔥 자동 라이브온 시작 플래그 설정
    _isAutoLiveOnInProgress = true;

    // 🚀 자동 라이브온 시작 (라이브 시작하기 버튼과 동일한 흐름)
    try {
      print('🚀 Geofence 진입: 자동 라이브온 시작 - $resortName (ID: $resortId)');
      await startLiveLocationService(user_id: userId);
      await _userViewModel.updateUserModel_api(userId);

      // 라이브온 성공 여부 확인
      if (_userViewModel.user.within_boundary == true && isPositionStreamActive) {
        // ✅ 라이브온 성공 - 푸시 알림 전송
        await _showGeofenceNotification(
          title: '라이브 시작',
          body: '$resortName 스키장에 도착해서 라이브가 시작되었습니다.',
          payload: 'geofence_liveon_success:$resortId:$resortName',
        );
        print('✅ 자동 라이브온 성공: $resortName');
      } else {
        // ❌ 리조트 영역 외부 - 라이브온 실패
        print('⚠️ 자동 라이브온 실패: 리조트 영역 밖');
      }
    } catch (e) {
      print('❌ 자동 라이브온 시작 실패: $e');
    } finally {
      // 🔥 자동 라이브온 완료 플래그 해제
      _isAutoLiveOnInProgress = false;
    }
  }

  /// 앱 시작 시 Headless 모드에서 저장된 pending 지오펜스 확인 및 자동 라이브온
  /// 앱이 종료된 상태에서 지오펜스 진입 시 저장된 정보를 확인하고 라이브온 시작
  Future<void> _checkPendingGeofenceFromHeadless() async {
    try {
      print('🔍 [Headless] Pending 지오펜스 확인 중...');

      final prefs = await SharedPreferences.getInstance();
      final resortIdStr = prefs.getString('pending_geofence_resort_id');
      final resortName = prefs.getString('pending_geofence_resort_name');
      final timestampStr = prefs.getString('pending_geofence_timestamp');

      // pending 데이터가 없으면 종료
      if (resortIdStr == null || resortIdStr.isEmpty || timestampStr == null) {
        print('ℹ️ [Headless] Pending 지오펜스 데이터 없음');
        return;
      }

      // timestamp 확인 (30분 이내만 유효)
      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) {
        print('⚠️ [Headless] 타임스탬프 파싱 실패');
        await _clearPendingGeofenceData();
        return;
      }

      final now = DateTime.now();
      final difference = now.difference(timestamp);
      if (difference.inMinutes > 30) {
        print('ℹ️ [Headless] Pending 지오펜스 만료 (${difference.inMinutes}분 전)');
        await _clearPendingGeofenceData();
        return;
      }

      print('📍 [Headless] 유효한 Pending 지오펜스 발견: $resortName (${difference.inMinutes}분 전)');

      // pending 데이터 삭제 (중복 처리 방지)
      await _clearPendingGeofenceData();

      // 이미 라이브온 상태면 무시
      if (isPositionStreamActive || _liveActivityId != null) {
        print('ℹ️ [Headless] 이미 라이브온 활성 상태, 자동 라이브온 생략');
        return;
      }

      // 자동 라이브온 설정이 꺼져있으면 무시
      if (!isAutoLiveOnEnabled) {
        print('ℹ️ [Headless] 자동 라이브온 설정이 꺼져있음');
        return;
      }

      // 사용자 ID 확인
      final userId = _userViewModel.user.user_id;
      if (userId == null) {
        print('❌ [Headless] 사용자 ID 없음, 자동 라이브온 시작 불가');
        return;
      }

      final resortId = int.tryParse(resortIdStr);

      // 🚀 자동 라이브온 시작
      print('🚀 [Headless] 자동 라이브온 시작 - $resortName');
      await startLiveLocationService(user_id: userId);
      await _userViewModel.updateUserModel_api(userId);

      // 라이브온 성공 여부 확인
      if (_userViewModel.user.within_boundary == true && isPositionStreamActive) {
        await _showGeofenceNotification(
          title: '라이브 시작',
          body: '$resortName 스키장에서 라이브가 시작되었습니다.',
          payload: 'geofence_liveon_success:$resortId:$resortName',
        );
        print('✅ [Headless] 자동 라이브온 성공: $resortName');
      } else {
        print('⚠️ [Headless] 자동 라이브온 실패: 리조트 영역 밖');
      }
    } catch (e) {
      print('❌ [Headless] Pending 지오펜스 처리 실패: $e');
    }
  }

  /// Pending 지오펜스 데이터 삭제
  Future<void> _clearPendingGeofenceData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_geofence_resort_id');
    await prefs.remove('pending_geofence_resort_name');
    await prefs.remove('pending_geofence_timestamp');
    print('🗑️ [Headless] Pending 지오펜스 데이터 삭제 완료');
  }

  /// 해당 리조트에 오늘 이미 알림을 보냈는지 확인 (SharedPreferences)
  Future<bool> _hasNotifiedTodayForResort(int resortId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'geofence_notified_$resortId';
      final lastNotifiedStr = prefs.getString(key);

      print('🔍 [Geofence] resortId=$resortId 알림 기록 확인: key=$key, 저장된 값=$lastNotifiedStr');

      if (lastNotifiedStr == null) {
        print('🔍 [Geofence] 저장된 기록 없음 → 알림 발송 가능');
        return false;
      }

      final lastNotified = DateTime.tryParse(lastNotifiedStr);
      if (lastNotified == null) {
        print('🔍 [Geofence] 날짜 파싱 실패 → 알림 발송 가능');
        return false;
      }

      final today = DateTime.now();
      final isToday = lastNotified.year == today.year &&
          lastNotified.month == today.month &&
          lastNotified.day == today.day;

      print('🔍 [Geofence] 마지막 알림: ${lastNotified.toString()}, 오늘: ${today.toString()}, 오늘 알림 여부: $isToday');

      return isToday;
    } catch (e) {
      print('❌ Geofence 알림 기록 확인 실패: $e');
      return false;
    }
  }

  /// 리조트 알림 전송 기록 저장 (SharedPreferences)
  Future<void> _saveGeofenceNotificationDate(int resortId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'geofence_notified_$resortId';
      final now = DateTime.now().toIso8601String();
      await prefs.setString(key, now);
      print('💾 Geofence 알림 기록 저장: resortId=$resortId, date=$now');
    } catch (e) {
      print('❌ Geofence 알림 기록 저장 실패: $e');
    }
  }

  /// 앱 시작 시 초기 위치 체크 (이미 Geofence 내에 있는지 확인)
  Future<void> _checkInitialGeofenceStatus() async {
    try {
      print('🔍 [Geofence] 초기 위치 체크 시작...');

      // 등록된 geofence가 없으면 스킵
      if (_registeredGeofences.isEmpty) {
        print('ℹ️ [Geofence] 등록된 Geofence 없음, 초기 체크 스킵');
        return;
      }

      // 현재 위치 가져오기
      Position currentPosition;
      try {
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        );
        print('📍 [Geofence] 현재 위치: lat=${currentPosition.latitude}, lon=${currentPosition.longitude}');
      } catch (e) {
        print('⚠️ [Geofence] 현재 위치 가져오기 실패: $e');
        return;
      }

      // 각 등록된 geofence와 현재 위치 비교
      for (final geofence in _registeredGeofences) {
        final resortId = geofence['resort_id'];
        final resortName = geofence['fullname'] as String? ?? '리조트';
        final lat = geofence['latitude'] as double;
        final lon = geofence['longitude'] as double;
        final radius = geofence['radius'] as double;

        // 현재 위치와 geofence 중심 간의 거리 계산
        final distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          lat,
          lon,
        );

        print('🔍 [Geofence] $resortName: 거리=${distance.toStringAsFixed(0)}m, 반경=${radius}m');

        // 반경 내에 있으면 진입 처리
        if (distance <= radius) {
          print('✅ [Geofence] 이미 $resortName 반경 내에 있음! 알림 트리거');
          await _handleGeofenceEnter(resortId, resortName);
          break; // 첫 번째 매칭된 리조트에서만 알림
        }
      }

      print('🔍 [Geofence] 초기 위치 체크 완료');
    } catch (e) {
      print('❌ [Geofence] 초기 위치 체크 오류: $e');
    }
  }

  /// 로컬 푸시 알림 표시매이
  Future<void> _showGeofenceNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Notifications',
      channelDescription: '리조트 진입/이탈 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // 고유 ID
      title,
      body,
      details,
      payload: payload,
    );

    print('🔔 로컬 푸시 알림 전송: $title');
  }

  /// Geofence 알림 탭 시 라이브온 자동 시작 (라이브 시작하기 버튼과 동일하게 동작)
  Future<void> handleGeofenceNotificationTap(String? payload) async {
    if (payload == null || !payload.startsWith('geofence_enter:')) return;

    final parts = payload.split(':');
    if (parts.length < 3) return;

    final resortId = int.tryParse(parts[1]);
    final resortName = parts[2];

    print('🚀 Geofence 알림 탭: 라이브온 자동 시작 - $resortName (ID: $resortId)');

    // 사용자 ID 확인
    final userId = _userViewModel.user.user_id;
    if (userId == null) {
      print('❌ 사용자 ID 없음, 라이브온 시작 불가');
      return;
    }

    // 라이브온 시작 (라이브 시작하기 버튼과 동일한 흐름)
    try {
      CustomFullScreenDialog.showDialog();
      await startLiveLocationService(user_id: userId);
      await _userViewModel.updateUserModel_api(userId);
      CustomFullScreenDialog.cancelDialog();

      // 리조트 영역 외부인 경우 안내 메시지
      if (_userViewModel.user.within_boundary == false) {
        Get.snackbar(
          '알림',
          '리조트 영역 밖입니다. 리조트 영역 내에서 다시 시도해주세요.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      print('✅ 자동 라이브온 시작 완료');
    } catch (e) {
      CustomFullScreenDialog.cancelDialog();
      print('❌ 자동 라이브온 시작 실패: $e');
    }
  }

  /// 자동 라이브온 설정 로드 (SharedPreferences)
  Future<void> _loadAutoLiveOnPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAutoLiveOnEnabled.value = prefs.getBool(_autoLiveOnKey) ?? false;

      // 툴팁 표시 여부 확인 (자동 라이브온 다이얼로그가 표시된 적 있고, 툴팁은 아직 표시 안 된 경우)
      final dialogShown = prefs.getBool(_autoLiveOnDialogShownKey) ?? false;
      final tooltipShown = prefs.getBool(_autoLiveOnTooltipShownKey) ?? false;
      _shouldShowAutoLiveOnTooltip.value = dialogShown && !tooltipShown;

      print('📱 자동 라이브온 설정 로드: enabled=${_isAutoLiveOnEnabled.value}, showTooltip=${_shouldShowAutoLiveOnTooltip.value}');
    } catch (e) {
      print('❌ 자동 라이브온 설정 로드 실패: $e');
    }
  }

  /// 자동 라이브온 설정 저장
  /// 설정 변경 시 지오펜스 등록/해제도 함께 처리
  Future<void> setAutoLiveOnEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoLiveOnKey, enabled);
      _isAutoLiveOnEnabled.value = enabled;
      print('💾 자동 라이브온 설정 저장: $enabled');

      // 🌐 지오펜스 등록/해제 처리
      if (enabled) {
        // 자동 라이브온 켜짐 → 지오펜스 등록
        print('🌐 자동 라이브온 활성화 → 지오펜스 등록');
        await setupResortGeofences();
      } else {
        // 자동 라이브온 꺼짐 → 지오펜스 해제 (백그라운드 위치 추적 중지)
        print('🌐 자동 라이브온 비활성화 → 지오펜스 해제');
        await removeAllGeofences();
      }
    } catch (e) {
      print('❌ 자동 라이브온 설정 저장 실패: $e');
    }
  }

  /// 첫 라이브온 시 자동 라이브온 다이얼로그 표시 (외부에서 호출 가능)
  Future<void> showAutoLiveOnDialog() async {
    print('📢 [AutoLiveOn] _showAutoLiveOnDialog 호출됨');
    final prefs = await SharedPreferences.getInstance();
    final dialogShown = prefs.getBool(_autoLiveOnDialogShownKey) ?? false;
    print('📢 [AutoLiveOn] dialogShown: $dialogShown');

    if (dialogShown) {
      print('📢 [AutoLiveOn] 이미 다이얼로그 표시됨, return');
      return; // 이미 다이얼로그를 표시한 적 있으면 무시
    }

    // 다이얼로그 표시 (사용자가 "다시보지않기"를 누를 때만 기록)
    await Get.dialog(
      AlertDialog(
        backgroundColor: SDSColor.snowliveWhite,
        contentPadding: EdgeInsets.only(bottom: 28, left: 28, right: 28, top: 30),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '자동 라이브온 설정',
              style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '다음부터 스키장에 오면 자동으로\n라이브가 켜지게 설정할까요?\n더보기 탭에서 언제든 설정할 수 있어요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 14, height: 1.4, color: SDSColor.gray600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            // 확인 버튼 (블루, 상단)
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: SDSColor.snowliveBlue,
              ),
              child: TextButton(
                onPressed: () async {
                  // 확인: 자동 라이브온 활성화 + 다이얼로그 표시 기록 후 닫기
                  await setAutoLiveOnEnabled(true);
                  await prefs.setBool(_autoLiveOnDialogShownKey, true);
                  Get.back();
                },
                child: Text(
                  '확인',
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 16,
                    color: SDSColor.snowliveWhite,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            // 취소 버튼 (그레이, 중간)
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: SDSColor.gray100,
              ),
              child: TextButton(
                onPressed: () {
                  // 취소: 그냥 닫기 (다음에 다시 표시됨)
                  Get.back();
                },
                child: Text(
                  '취소',
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 16,
                    color: SDSColor.gray600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // 다시보지않기 (텍스트 버튼, 하단)
            GestureDetector(
              onTap: () async {
                // 다시보지않기: 다이얼로그 표시 기록 후 닫기
                await prefs.setBool(_autoLiveOnDialogShownKey, true);
                Get.back();
              },
              child: Text(
                '다시보지않기',
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: SDSColor.gray600,
                  decorationColor: SDSColor.gray400,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 자동 라이브온 툴팁 표시 완료 처리
  Future<void> markAutoLiveOnTooltipShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoLiveOnTooltipShownKey, true);
      _shouldShowAutoLiveOnTooltip.value = false;
      print('📱 자동 라이브온 툴팁 표시 완료 기록');
    } catch (e) {
      print('❌ 자동 라이브온 툴팁 표시 완료 기록 실패: $e');
    }
  }

  @override
  void onClose() {
    // WidgetsBindingObserver 해제
    WidgetsBinding.instance.removeObserver(this);

    // StreamSubscription 해제 (메모리 누수 방지)
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    // 라이브온 관련 리소스 정리
    _errorLogSubscription?.cancel();
    _errorLogSubscription = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _logFlushTimer?.cancel();
    _logFlushTimer = null;
    _liveFriendsWorker?.dispose();
    _liveFriendsWorker = null;

    // ScrollController dispose
    scrollController_resortHome_openchat.dispose();

    // 🛡️ 메모리 누수 방지: bannerStream 구독 취소
    _bannerSub_home?.cancel();
    _bannerSub_fleaMarket?.cancel();
    _bannerSub_moreTab?.cancel();
    _bannerSub_community?.cancel();
    _bannerSub_community_detail?.cancel();
    _bannerSub_ranking?.cancel();
    _bannerSub_home = null;
    _bannerSub_fleaMarket = null;
    _bannerSub_moreTab = null;
    _bannerSub_community = null;
    _bannerSub_community_detail = null;
    _bannerSub_ranking = null;

    super.onClose();
  }
}
