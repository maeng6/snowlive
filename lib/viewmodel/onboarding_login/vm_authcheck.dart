import 'dart:io';
import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_login.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final ref = FirebaseFirestore.instance;

class AuthCheckViewModel extends GetxController {
  final auth = FirebaseAuth.instance;
  final storage = FlutterSecureStorage();
  RxString? localUid = ''.obs;
  RxString? device_id = ''.obs;
  RxString? device_token = ''.obs;
  ApiResponse? response;
  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  void onInit() async {
    super.onInit();
  }

  Future<void> userCheck() async {

    await loginAgain();

    print('loginAgain 결과 : localUid - $localUid');
    print('loginAgain 결과 : device_id - $device_id');
    print('loginAgain 결과 : device_token - $device_token');

    if ((localUid != null && localUid != '') &&
        (device_id != null && device_id != '') &&
        (device_token != null && device_token != '')) {
      try {
         response = await LoginAPI().compareDeviceId({
          "uid": "$localUid",
          "device_id": "$device_id",
          "device_token": "$device_token"
        });

         print(localUid);
         print(device_id);
         print(device_token);

      } catch (e) {
        await FlutterSecureStorage().delete(key: 'localUid');
        await FlutterSecureStorage().delete(key: 'device_id');
        await FlutterSecureStorage().delete(key: 'device_token');
        await FlutterSecureStorage().delete(key: 'user_id');
        Get.offAllNamed(AppRoutes.login);
      }

      if(response!.success){
        if (response!.data['message'] == '새로운기기') {
          print('compareDeviceId 결과 : ${response!.data['message']}');
          await FlutterSecureStorage()
              .write(key: 'localUid', value: localUid!.value);
          await FlutterSecureStorage()
              .write(key: 'device_id', value: device_id!.value);
          await FlutterSecureStorage()
              .write(key: 'device_token', value: device_token!.value);
          try {
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id);
            Get.offAllNamed(AppRoutes.mainHome);
          }catch(e){
            await FlutterSecureStorage().write(key: 'user_id', value: response!.data['user_id']);
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id);
            Get.offAllNamed(AppRoutes.mainHome);
          }
        } else if (response!.data['message'] == '기존기기') {
          print('compareDeviceId 결과 : ${response!.data['message']}');
          try {
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id);
            Get.offAllNamed(AppRoutes.mainHome);
          }catch(e){
            await FlutterSecureStorage().write(key: 'user_id', value: response!.data['user_id'].toString());
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id);
            Get.offAllNamed(AppRoutes.mainHome);
          }
        }
      }else{
        print('compareDeviceId 결과 : ${response!.error['error']}');
        await FlutterSecureStorage().delete(key: 'localUid');
        await FlutterSecureStorage().delete(key: 'device_id');
        await FlutterSecureStorage().delete(key: 'device_token');
        await FlutterSecureStorage().delete(key: 'user_id');
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      await FlutterSecureStorage().delete(key: 'localUid');
      await FlutterSecureStorage().delete(key: 'device_id');
      await FlutterSecureStorage().delete(key: 'device_token');
      await FlutterSecureStorage().delete(key: 'user_id');
      Get.toNamed(AppRoutes.login);
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

  //로컬의 new_uid 불러오기
  Future<void> loginAgain() async {
    print('로그인어게인시작');
    localUid!.value = await storage.read(key: 'localUid') ?? '';
    device_id!.value = await storage.read(key: 'device_id') ?? '';
    device_token!.value = await storage.read(key: 'device_token') ?? '';
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
