import 'dart:io';
import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_login.dart';
import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_udid/flutter_udid.dart';

final ref = FirebaseFirestore.instance;

class AuthCheckViewModel extends GetxController {
  final auth = FirebaseAuth.instance;
  final storage = FlutterSecureStorage();
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
         response = await LoginAPI().compareDeviceId({
          "uid": "$localUid",
          "device_id": "$device_id",
          "device_token": "$device_token",
        });

      } catch (e) {
        await _sendLogoutLog(
          reason: 'logout_api_exception',
          errorDetail: e.toString(),
        );
        await FlutterSecureStorage().delete(key: 'localUid');
        await FlutterSecureStorage().delete(key: 'device_id');
        await FlutterSecureStorage().delete(key: 'device_token');
        await FlutterSecureStorage().delete(key: 'user_id');
        _gotoMainHome!.value = true;
        return _gotoMainHome!.value;
      }

      if(response!.success){
        if (response!.data['message'] == '새로운기기') {
          //print('compareDeviceId 결과 : ${response!.data['message']}');
          await FlutterSecureStorage()
              .write(key: 'localUid', value: localUid!.value);
          await FlutterSecureStorage()
              .write(key: 'device_id', value: device_id!.value);
          await FlutterSecureStorage()
              .write(key: 'device_token', value: device_token!.value);
          try {
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id, fcm_token: fcm_token!.value);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }catch(e){
            await FlutterSecureStorage().write(key: 'user_id', value: response!.data['user_id']);
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id, fcm_token: fcm_token!.value);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }
        } else if (response!.data['message'] == '기존기기') {
          //print('compareDeviceId 결과 : ${response!.data['message']}');
          try {
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id, fcm_token: fcm_token!.value);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }catch(e){
            await FlutterSecureStorage().write(key: 'user_id', value: response!.data['user_id'].toString());
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
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
        await FlutterSecureStorage().delete(key: 'localUid');
        await FlutterSecureStorage().delete(key: 'device_id');
        await FlutterSecureStorage().delete(key: 'device_token');
        await FlutterSecureStorage().delete(key: 'user_id');
        _gotoMainHome!.value = false;
        return _gotoMainHome!.value;
      }

    } else {
      print('로그아웃');
      await _sendLogoutLog(
        reason: 'logout_missing_credentials',
        errorDetail: 'localUid=${localUid?.value?.isEmpty ?? true}, device_id=${device_id?.value?.isEmpty ?? true}, device_token=${device_token?.value?.isEmpty ?? true}',
      );
      await FlutterSecureStorage().delete(key: 'localUid');
      await FlutterSecureStorage().delete(key: 'device_id');
      await FlutterSecureStorage().delete(key: 'device_token');
      await FlutterSecureStorage().delete(key: 'user_id');
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
