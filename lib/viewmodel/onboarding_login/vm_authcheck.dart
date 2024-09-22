import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_login.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          "device_token": "$device_token"
        });

      } catch (e) {
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
            await _userViewModel.updateUserModel_api(user_id);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }catch(e){
            await FlutterSecureStorage().write(key: 'user_id', value: response!.data['user_id']);
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }
        } else if (response!.data['message'] == '기존기기') {
          //print('compareDeviceId 결과 : ${response!.data['message']}');
          try {
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }catch(e){
            await FlutterSecureStorage().write(key: 'user_id', value: response!.data['user_id'].toString());
            String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
            int user_id = int.parse(userIdString!);
            await _userViewModel.updateUserModel_api(user_id);
            _gotoMainHome!.value = true;
            return _gotoMainHome!.value;
          }
        }
      }else{
        print('compareDeviceId 결과 : ${response!.error['error']}');
        await FlutterSecureStorage().delete(key: 'localUid');
        await FlutterSecureStorage().delete(key: 'device_id');
        await FlutterSecureStorage().delete(key: 'device_token');
        await FlutterSecureStorage().delete(key: 'user_id');
        _gotoMainHome!.value = false;
        return _gotoMainHome!.value;
      }

    } else {
      print('로그아웃');
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

    // print('loginAgain 결과 : localUid - $localUid');
    // print('loginAgain 결과 : device_id - $device_id');
    // print('loginAgain 결과 : device_token - $device_token');

  }


}
