import 'dart:convert';
import 'dart:io';
import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_login.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:com.snowlive/util/secure_storage_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math; // math 패키지 추가
import 'package:crypto/crypto.dart'; // sha256을 위한 crypto 패키지 추가
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ref = FirebaseFirestore.instance;

class LoginViewModel extends GetxController {

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  RxBool? _isAndroidEmailLogIn = false.obs;
  bool? get isAndroidEmailLogIn => _isAndroidEmailLogIn!.value;

  final auth = FirebaseAuth.instance;
  final storage = getSecureStorage();
  final googleSignIn = GoogleSignIn();
  final loginAPI = LoginAPI();
  RxString signInMethod = ''.obs;
  RxString? loginUid = ''.obs;
  RxString? device_id = '1'.obs;
  RxString? device_token = '1'.obs;

  @override
  void onInit()  async{
    await _getToken();
    await getIsAndroidEmailLogIn();
    await getLocalSignInMethod(); // 마지막 로그인 방식 불러오기
    super.onInit();
  }

  Future<void> _getToken() async {
    if (Platform.isIOS && !await _isPhysicalDevice()) {
      print('⚠️ 시뮬레이터에서는 FCM 토큰을 받을 수 없습니다.');
      return;
    }

    try {
      NotificationSettings settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? deviceToken = await messaging.getToken();
        String? deviceId = await FlutterUdid.udid;

        device_token!.value = deviceToken ?? '';
        device_id!.value = deviceId ?? '';

        print('📱 FCM Token (Login): $device_token');
        print('📱 Device ID (Login): $device_id');
      }
    } catch (e) {
      print('❗️LoginViewModel에서 FCM 토큰 에러: $e');
    }
  }

  Future<bool> _isPhysicalDevice() async {
    try {
      final deviceId = await FlutterUdid.udid;
      return deviceId != null && !deviceId.toLowerCase().contains('simulator');
    } catch (_) {
      return false;
    }
  }

  //로컬에 signInMethod 저장
  Future<void> signInWithGoogle() async {
    CustomFullScreenDialog.showDialog();
    // 기존 로그인 세션 해제하여 계정 선택창 항상 표시
    await googleSignIn.signOut();
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    print('22');
    if (googleSignInAccount == null) {
      CustomFullScreenDialog.cancelDialog();
    } else {
      GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await auth.signInWithCredential(oAuthCredential);

      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        loginUid!.value = currentUser.uid;
        // SharedPreferences로 변경 (앱 삭제 전까지 유지)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('signInMethod', 'google');
        await getLocalSignInMethod();
        await getSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await getSecureStorage().write(key: 'device_id', value: device_id!.value);
        await getSecureStorage().write(key: 'device_token', value: device_token!.value);
        await findUserAPI();
        CustomFullScreenDialog.cancelDialog();
        await getLocalSignInMethod();
      }else{
        CustomFullScreenDialog.cancelDialog();
      }
    }
  }



  /// Nonce 생성 함수
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = math.Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// SHA256 해시 함수
  String sha256ofString(String input) {
    final bytes = utf8.encode(input); // 데이터 변환
    final digest = sha256.convert(bytes); // 해싱
    return digest.toString();
  }


  //로컬에 signInMethod 저장
  Future<void> signInWithApple() async {
    CustomFullScreenDialog.showDialog();
    try {
      // 애플 로그인 자격 증명 가져오기
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // idToken과 authorizationCode가 null이 아닌지 확인하고 처리
      final String? idToken = appleCredential.identityToken;
      final String? authorizationCode = appleCredential.authorizationCode;

      if (idToken == null || authorizationCode == null) {

        throw Exception('Apple sign-in failed: idToken or authorizationCode is null');
      }

      // Firebase OAuth 자격 증명 생성
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: idToken,
        accessToken: authorizationCode,
      );

      // Firebase에 자격 증명으로 로그인 시도
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // 현재 사용자 가져오기
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        loginUid!.value = currentUser.uid;
        // SharedPreferences로 변경 (앱 삭제 전까지 유지)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('signInMethod', 'apple');
        await getSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await getSecureStorage().write(key: 'device_id', value: device_id!.value);
        await getSecureStorage().write(key: 'device_token', value: device_token!.value);
        await findUserAPI();
        CustomFullScreenDialog.cancelDialog();
        await getLocalSignInMethod();
      } else {
        CustomFullScreenDialog.cancelDialog();
        print('로그인에 실패했습니다.');
      }
    } catch (e) {
      CustomFullScreenDialog.cancelDialog();
      print('Apple sign-in failed: $e');
    }
  }


  Future<void> findUserAPI() async {
    ApiResponse response = await LoginAPI().findUser({
      "uid": "${loginUid!.value}",
      "device_id": "${device_id!.value}",
      "device_token": "${device_token!.value}",
    });


    if (response.success) {
      final data = response.data as Map<String, dynamic>;
      final message = data['message'];

      if (message == '새로운기기' || message == '이관성공') {
        print('새로운기기 or 이관성공');

        await getSecureStorage().write(key: 'localUid', value: loginUid!.value);

        await getSecureStorage().write(key: 'device_id', value: device_id!.value);

        await getSecureStorage().write(key: 'device_token', value: device_token!.value);

        await getSecureStorage().write(key: 'user_id', value: data['user']['user_id'].toString());

        String? userIdString = await getSecureStorage().read(key: 'user_id');
        print(userIdString);
        int user_id = int.parse(userIdString!);

        await _userViewModel.updateUserModel_api(user_id);

        Get.offAllNamed(AppRoutes.mainHome);
      } else if (message == '기존기기') {

        await getSecureStorage().write(key: 'localUid', value: loginUid!.value);

        await getSecureStorage().write(key: 'user_id', value: data['user']['user_id'].toString());

        await getSecureStorage().write(key: 'device_id', value: device_id!.value);

        await getSecureStorage().write(key: 'device_token', value: device_token!.value);

        String? userIdString = await getSecureStorage().read(key: 'user_id');
        print(userIdString);
        int user_id = int.parse(userIdString!);

        await _userViewModel.updateUserModel_api(user_id);

        Get.offAllNamed(AppRoutes.mainHome);
      } else {
        // 추가 처리
      }
    } else {
      final data = response.error as Map<String, dynamic>;
      final message = data['message'];
      if (message == '온보딩이동') {
        Get.offAllNamed(AppRoutes.tos);
      }
    }
  }
  //로컬의 signInMethod 불러오기 (SharedPreferences 사용 - 앱 삭제 전까지 유지)
  Future<void> getLocalSignInMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final signInMethod = prefs.getString('signInMethod');
    this.signInMethod.value = signInMethod ?? '';
  }

  Future<void> signOut_welcome() async {
    User user = FirebaseAuth.instance.currentUser!;
    await user.delete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('signInMethod');
    // Get.offAll(() => LoginPage());
  }

  Future<void> getIsAndroidEmailLogIn() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('emailLogIn').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    bool isAndroidEmailLogIn = documentSnapshot.get('visible');
    this._isAndroidEmailLogIn!.value = isAndroidEmailLogIn;
  }

  Future<void> deleteUser({required int userId}) async {
    ApiResponse response = await LoginAPI().deleteUser(userId);
    CustomFullScreenDialog.cancelDialog();

    if (response.success) {
      String uid = response.data['uid']; // message 대신 uid로 변경하여 가져옴

      // Firebase Storage에서 프로필 이미지 삭제
      try {
        final storageRef = FirebaseStorage.instance.ref();
        final profileImageRef = storageRef.child('user_profile/$uid.jpg');

        // 메타데이터로 이미지가 존재하는지 확인
        try {
          await profileImageRef.getMetadata();
          // 메타데이터 가져오기가 성공하면 파일이 존재하므로 삭제
          await profileImageRef.delete();
          print('Firebase Storage에서 프로필 이미지가 삭제되었습니다.');
        } catch (e) {
          if (e is FirebaseException && e.code == 'object-not-found') {
            print('Firebase Storage에서 해당 프로필 이미지를 찾을 수 없습니다.');
          } else {
            print('Firebase Storage에서 프로필 이미지 삭제 중 오류 발생: $e');
          }
        }
      } catch (e) {
        print('Firebase Storage에서 프로필 이미지 삭제 중 오류 발생: $e');
      }

      // SecureStorage 데이터 삭제
      await getSecureStorage().delete(key: 'localUid');
      await getSecureStorage().delete(key: 'device_id');
      await getSecureStorage().delete(key: 'device_token');
      await getSecureStorage().delete(key: 'user_id');

      // SharedPreferences의 signInMethod 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('signInMethod');

      // 로그인 페이지로 이동
      Get.offAllNamed(AppRoutes.login);
    } else if (response.error['error'] == '크루장은 탈퇴할 수 없습니다.') {
      Get.snackbar('먼저 할 일이 있어요.', '크루장을 위임하거나, 크루를 삭제해주세요.');
    }
  }

}

