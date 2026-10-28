import 'dart:convert';
import 'dart:io';
import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_login.dart';
import 'package:com.snowlive/mobile/routes/routes.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:com.snowlive/mobile/util/secure_storage_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math; // math 패키지 추가
import 'package:crypto/crypto.dart'; // sha256을 위한 crypto 패키지 추가
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
// firebase_auth의 User와 이름이 겹쳐 카카오 User는 숨긴다(사용 안 함).
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' hide User;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

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


  /// 카카오 로그인 — 네이티브 SDK로 access_token을 받아 백엔드에서 Firebase 커스텀토큰을
  /// 발급받고 로그인한다. 이후는 구글/애플과 동일하게 findUserAPI()가 홈/온보딩으로 보낸다.
  Future<void> signInWithKakao() async {
    CustomFullScreenDialog.showDialog();
    try {
      final OAuthToken kakaoToken = await _kakaoSdkLogin();

      final ApiResponse res = await loginAPI.socialLogin({
        'provider': 'kakao',
        'access_token': kakaoToken.accessToken,
      });
      if (!res.success) {
        CustomFullScreenDialog.cancelDialog();
        print('카카오 서버 로그인 실패: ${res.error}');
        return;
      }
      final data = res.data as Map<String, dynamic>;
      final String customToken = data['custom_token'];

      await auth.signInWithCustomToken(customToken);
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        loginUid!.value = currentUser.uid;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('signInMethod', 'kakao');
        await getLocalSignInMethod();
        await getSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await getSecureStorage().write(key: 'device_id', value: device_id!.value);
        await getSecureStorage().write(key: 'device_token', value: device_token!.value);
        await findUserAPI();
        CustomFullScreenDialog.cancelDialog();
        await getLocalSignInMethod();
      } else {
        CustomFullScreenDialog.cancelDialog();
      }
    } catch (e) {
      CustomFullScreenDialog.cancelDialog();
      print('Kakao sign-in failed: $e');
    }
  }

  /// 네이버 로그인 — 네이티브 SDK로 access_token을 받아 백엔드에서 Firebase 커스텀토큰을
  /// 발급받고 로그인한다. 이후는 구글/애플/카카오와 동일(findUserAPI → 홈/온보딩).
  Future<void> signInWithNaver() async {
    CustomFullScreenDialog.showDialog();
    try {
      // 자동 로그인 방지 — 기존 토큰을 지우고 로그인(매번 로그인 화면).
      try {
        await FlutterNaverLogin.logOutAndDeleteToken();
      } catch (_) {}

      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      final String? naverAccessToken = result.accessToken?.accessToken;
      if (result.status != NaverLoginStatus.loggedIn ||
          naverAccessToken == null || naverAccessToken.isEmpty) {
        CustomFullScreenDialog.cancelDialog(); // 취소/실패
        return;
      }

      final ApiResponse res = await loginAPI.socialLogin({
        'provider': 'naver',
        'access_token': naverAccessToken,
      });
      if (!res.success) {
        CustomFullScreenDialog.cancelDialog();
        print('네이버 서버 로그인 실패: ${res.error}');
        return;
      }
      final data = res.data as Map<String, dynamic>;
      final String customToken = data['custom_token'];

      await auth.signInWithCustomToken(customToken);
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        loginUid!.value = currentUser.uid;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('signInMethod', 'naver');
        await getLocalSignInMethod();
        await getSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await getSecureStorage().write(key: 'device_id', value: device_id!.value);
        await getSecureStorage().write(key: 'device_token', value: device_token!.value);
        await findUserAPI();
        CustomFullScreenDialog.cancelDialog();
        await getLocalSignInMethod();
      } else {
        CustomFullScreenDialog.cancelDialog();
      }
    } catch (e) {
      CustomFullScreenDialog.cancelDialog();
      print('Naver sign-in failed: $e');
    }
  }

  /// 카카오 로그인 토큰 획득.
  /// - Android: 카카오톡 설치 시 카카오톡으로(매니페스트 리다이렉트 처리), 없으면 계정으로.
  /// - iOS: 카카오톡 앱 복귀는 별도 네이티브 모듈 연결이 필요해, 그 없이도 동작하는
  ///   카카오계정(웹) 로그인을 쓴다. (ASWebAuthenticationSession이 콜백을 자체 처리)
  /// 계정 로그인은 prompt=login으로 자동 로그인을 막는다(웹과 동일한 취지).
  Future<OAuthToken> _kakaoSdkLogin() async {
    if (Platform.isAndroid && await isKakaoTalkInstalled()) {
      try {
        return await UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        // 사용자가 취소(뒤로가기)면 중단, 그 외 오류면 계정 로그인으로 폴백.
        if (error is PlatformException && error.code == 'CANCELED') rethrow;
        return await UserApi.instance
            .loginWithKakaoAccount(prompts: [Prompt.login]);
      }
    }
    return await UserApi.instance.loginWithKakaoAccount(prompts: [Prompt.login]);
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

