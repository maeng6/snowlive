import 'dart:async';
import 'dart:io';
import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/core/api/api_login.dart';
import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:com.snowlive/mobile/util/secure_storage_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_udid/flutter_udid.dart';

final ref = FirebaseFirestore.instance;

class AuthCheckViewModel extends GetxController {
  final auth = FirebaseAuth.instance;
  final storage = getSecureStorage();
  final messaging = FirebaseMessaging.instance;
  RxString? localUid = ''.obs;
  RxString? device_id = ''.obs;
  RxString? device_token = ''.obs;
  RxString? fcm_token = ''.obs;
  ApiResponse? response;
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  RxBool? _gotoMainHome = false.obs;

  bool get gotoMainHome => _gotoMainHome!.value;

  Future<bool> userCheck() async {

    await loginAgain();

    if ((localUid != null && localUid != '') &&
        (device_id != null && device_id != '') &&
        (device_token != null && device_token != '')) {
      try {
        // 재시도 로직이 포함된 API 호출 (최대 3회, 2초 간격)
        response = await _compareDeviceIdWithRetry();
      } catch (e) {
        // 모든 에러에 대해 로그아웃하지 않고 메인홈으로 진입 (오프라인 모드)
        print('⚠️ API 오류 - 로그아웃하지 않고 메인홈으로 진입');
        await _sendLogoutLog(
          reason: 'offline_mode_after_retry',
          errorDetail: e.toString(),
        );
        // 기존 인증 정보 유지, 저장된 user_id로 사용자 정보 로드 시도
        try {
          String? userIdString = await getSecureStorage().read(key: 'user_id');
          if (userIdString != null) {
            int user_id = int.parse(userIdString);
            await _userViewModel.updateUserModel_api(user_id);
          }
        } catch (_) {
          // 사용자 정보 로드 실패해도 메인홈으로 진입
        }
        _gotoMainHome!.value = true;
        return _gotoMainHome!.value;
      }

      if(response!.success){
        if (response!.data['message'] == '새로운기기') {
          //print('compareDeviceId 결과 : ${response!.data['message']}');
          await getSecureStorage()
              .write(key: 'localUid', value: localUid!.value);
          await getSecureStorage()
              .write(key: 'device_id', value: device_id!.value);
          await getSecureStorage()
              .write(key: 'device_token', value: device_token!.value);
          try {
            String? userIdString = await getSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id, fcm_token: fcm_token!.value);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }catch(e){
            await getSecureStorage().write(key: 'user_id', value: response!.data['user_id']);
            String? userIdString = await getSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id, fcm_token: fcm_token!.value);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }
        } else if (response!.data['message'] == '기존기기') {
          //print('compareDeviceId 결과 : ${response!.data['message']}');
          try {
            String? userIdString = await getSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id, fcm_token: fcm_token!.value);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }catch(e){
            await getSecureStorage().write(key: 'user_id', value: response!.data['user_id'].toString());
            String? userIdString = await getSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id, fcm_token: fcm_token!.value);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }
        }
      }else{
        print('compareDeviceId 결과 : ${response!.error['error']}');
        await _sendLogoutLog(
          reason: 'logout_api_failure',
          errorDetail: response!.error['error']?.toString(),
        );
        await getSecureStorage().delete(key: 'localUid');
        await getSecureStorage().delete(key: 'device_id');
        await getSecureStorage().delete(key: 'device_token');
        await getSecureStorage().delete(key: 'user_id');
        _gotoMainHome!.value = false;
        return _gotoMainHome!.value;
      }

    } else {
      print('로그아웃');
      await _sendLogoutLog(
        reason: 'logout_missing_credentials',
        errorDetail: 'localUid=${localUid?.value?.isEmpty ?? true}, device_id=${device_id?.value?.isEmpty ?? true}, device_token=${device_token?.value?.isEmpty ?? true}',
      );
      await getSecureStorage().delete(key: 'localUid');
      await getSecureStorage().delete(key: 'device_id');
      await getSecureStorage().delete(key: 'device_token');
      await getSecureStorage().delete(key: 'user_id');
      Get.offAllNamed(AppRoutes.login);
      return _gotoMainHome!.value;
    }
    return _gotoMainHome!.value;
  }



  //로컬의 new_uid 불러오기
  Future<void> loginAgain() async {

    localUid!.value = await storage.read(key: 'localUid') ?? '';
    device_id!.value = await storage.read(key: 'device_id') ?? '';
    device_token!.value = await storage.read(key: 'device_token') ?? '';

    // FCM 토큰 가져오기
    await _getFcmToken();

    // print('loginAgain 결과 : localUid - $localUid');
    // print('loginAgain 결과 : device_id - $device_id');
    // print('loginAgain 결과 : device_token - $device_token');
    // print('loginAgain 결과 : fcm_token - $fcm_token');

  }

  /// FCM 토큰 가져오기
  Future<void> _getFcmToken() async {
    try {
      // iOS 시뮬레이터 체크
      if (Platform.isIOS && !await _isPhysicalDevice()) {
        print('⚠️ iOS 시뮬레이터에서는 FCM 토큰을 받을 수 없습니다.');
        return;
      }

      String? token = await messaging.getToken();
      fcm_token!.value = token ?? '';
      print('📱 FCM 토큰 가져오기 완료: ${fcm_token!.value.isNotEmpty}');
    } catch (e) {
      print('❌ FCM 토큰 가져오기 실패: $e');
      fcm_token!.value = '';
    }
  }

  /// 실제 기기인지 확인 (시뮬레이터 체크)
  Future<bool> _isPhysicalDevice() async {
    try {
      final deviceId = await FlutterUdid.udid;
      return deviceId != null && !deviceId.toLowerCase().contains('simulator');
    } catch (_) {
      return false;
    }
  }

  /// 네트워크 에러인지 판별
  /// SocketException: DNS 실패, 연결 중단 등
  /// TimeoutException: 응답 시간 초과
  /// ClientException: HTTP 클라이언트 에러 (네트워크 관련)
  /// FormatException: 서버가 HTML 에러 페이지 반환 시 (JSON 파싱 실패)
  bool _isNetworkError(dynamic e) {
    final errorString = e.toString().toLowerCase();
    return e is SocketException ||
        e is TimeoutException ||
        e is http.ClientException ||
        e is FormatException ||
        errorString.contains('socketexception') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('host lookup') ||
        errorString.contains('network') ||
        errorString.contains('file descriptor') ||
        errorString.contains('clientexception') ||
        errorString.contains('<!doctype') ||
        errorString.contains('errno') ||
        errorString.contains('os error') ||
        errorString.contains('nodename') ||
        errorString.contains('servname') ||
        errorString.contains('no address') ||
        errorString.contains('no route') ||
        errorString.contains('unreachable');
  }

  /// 재시도 로직이 포함된 compareDeviceId API 호출
  /// 모든 예외에 대해 최대 5회 재시도 (첫 시도 전 1초 대기, 실패 시 2초 간격)
  Future<ApiResponse?> _compareDeviceIdWithRetry({int maxRetries = 5}) async {
    // 네트워크 안정화를 위해 첫 시도 전 1초 대기
    await Future.delayed(const Duration(seconds: 1));

    Exception? lastException;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🔄 compareDeviceId 시도 $attempt/$maxRetries');
        return await LoginAPI().compareDeviceId({
          "uid": "$localUid",
          "device_id": "$device_id",
          "device_token": "$device_token",
        });
      } catch (e) {
        print('❌ compareDeviceId 실패 (시도 $attempt): $e');
        lastException = e is Exception ? e : Exception(e.toString());

        if (attempt < maxRetries) {
          // 재시도 횟수가 남았으면 2초 대기 후 재시도
          print('⏳ 2초 후 재시도...');
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
      }
    }
    // 모든 재시도 실패 시 마지막 예외 전파
    if (lastException != null) {
      throw lastException;
    }
    return null;
  }

  /// 로그아웃 발생 시 서버로 로그 전송
  Future<void> _sendLogoutLog({
    required String reason,
    String? errorDetail,
  }) async {
    try {
      String? userIdString = await storage.read(key: 'user_id');
      int? userId = userIdString != null ? int.tryParse(userIdString) : null;

      await RankingAPI().createErrorLog({
        if (userId != null) 'user_id': userId,
        'request_type': reason,
        if (errorDetail != null) 'error': errorDetail,
      });
      print('로그아웃 로그 전송 완료: $reason');
    } catch (e) {
      print('로그아웃 로그 전송 실패: $e');
    }
  }

}
