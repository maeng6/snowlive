import 'dart:convert';

import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_login.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math; // math 패키지 추가
import 'package:crypto/crypto.dart'; // sha256을 위한 crypto 패키지 추가

final ref = FirebaseFirestore.instance;

class LoginViewModel extends GetxController {

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  RxBool? _isAndroidEmailLogIn = false.obs;
  bool? get isAndroidEmailLogIn => _isAndroidEmailLogIn!.value;

  final auth = FirebaseAuth.instance;
  final storage = FlutterSecureStorage();
  final googleSignIn = GoogleSignIn();
  final facebookAuth = FacebookAuth.instance;
  final loginAPI = LoginAPI();
  RxString signInMethod = ''.obs;
  RxString? loginUid = ''.obs;
  RxString? device_id = ''.obs;
  RxString? device_token = ''.obs;

  @override
  void onInit()  async{
    await _getToken();
    super.onInit();
  }

  Future<void> _getToken() async{
    String? deviceToken= await messaging.getToken();
    String? deviceId = await PlatformDeviceId.getDeviceId;
    this.device_token!.value = deviceToken!;
    this.device_id!.value = deviceId!;

    try{
      print('deviceToken : $device_token');
      print('deviceID : $device_id');
    } catch(e) {}
  }

  //로컬에 signInMethod 저장
  Future<void> signInWithGoogle() async {
    CustomFullScreenDialog.showDialog();
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount == null) {

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
        await storage.write(key: 'signInMethod', value: 'google');
        await getLocalSignInMethod();
        await FlutterSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await FlutterSecureStorage().write(key: 'device_id', value: device_id!.value);
        await FlutterSecureStorage().write(key: 'device_token', value: device_token!.value);
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

  Future<void> signInWithFacebook_android() async {
    print('1');
    final LoginResult loginResult = await facebookAuth.login();
    if (loginResult == null) {

    } else {
      print('2');
      OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
      print('3');
      await auth.signInWithCredential(facebookAuthCredential);
      print('4');
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        loginUid!.value = currentUser.uid;
        await storage.write(key: 'signInMethod', value: 'facebook');
        await getLocalSignInMethod();
        await FlutterSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await FlutterSecureStorage().write(key: 'device_id', value: device_id!.value);
        await FlutterSecureStorage().write(key: 'device_token', value: device_token!.value);
      }
    }
  }

  Future<void> signInWithFacebook() async {
    CustomFullScreenDialog.showDialog();
    try {
      // Nonce 생성 및 SHA256 해시화
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // 페이스북 로그인 시도, LoginTracking을 Limited로 설정하고 nonce 포함
      final LoginResult loginResult = await facebookAuth.login(
        loginTracking: LoginTracking.limited,
        nonce: nonce,
      );

      if (loginResult.status == LoginStatus.success) {
        // 액세스 토큰이 LimitedToken인 경우 처리
        final AccessToken? accessToken = await loginResult.accessToken;

        if (accessToken != null && accessToken is LimitedToken) {
          // LimitedToken에서 tokenString 가져오기
          final String? tokenString = await accessToken.tokenString;

          // Firebase OAuth 자격 증명 생성
          final OAuthCredential facebookAuthCredential = OAuthCredential(
            providerId: 'facebook.com',
            signInMethod: 'oauth',
            idToken: tokenString,
            rawNonce: rawNonce,
          );

          // Firebase에 자격 증명으로 로그인 시도
          final UserCredential userCredential = await auth.signInWithCredential(facebookAuthCredential);

          final User? currentUser = userCredential.user;

          if (currentUser != null) {
            // 로그인 성공 시 로컬 스토리지에 저장
            loginUid!.value = currentUser.uid;
            await storage.write(key: 'signInMethod', value: 'facebook');
            await getLocalSignInMethod();
            await FlutterSecureStorage().write(key: 'localUid', value: loginUid!.value);
            await FlutterSecureStorage().write(key: 'device_id', value: device_id!.value);
            await FlutterSecureStorage().write(key: 'device_token', value: device_token!.value);

            await findUserAPI();
            CustomFullScreenDialog.cancelDialog();
            await getLocalSignInMethod();
          } else {
            CustomFullScreenDialog.cancelDialog();
            print('로그인에 실패했습니다. 사용자 정보를 가져오지 못했습니다.');
          }
        } else {
          CustomFullScreenDialog.cancelDialog();
          print('Facebook 로그인 실패: LimitedToken을 가져오지 못했습니다.');
        }
      } else if (loginResult.status == LoginStatus.cancelled) {
        // 사용자가 로그인 취소
        CustomFullScreenDialog.cancelDialog();
        print('사용자가 Facebook 로그인을 취소했습니다.');
      } else if (loginResult.status == LoginStatus.failed) {
        // 로그인 실패
        CustomFullScreenDialog.cancelDialog();
        print('Facebook 로그인 실패: ${loginResult.message}');
      }
    } catch (e) {
      // 예외 처리: 로그인 시 발생하는 모든 에러 처리
      CustomFullScreenDialog.cancelDialog();
      print('Facebook 로그인 중 에러 발생: $e');
    }
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
        await storage.write(key: 'signInMethod', value: 'apple');
        await FlutterSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await FlutterSecureStorage().write(key: 'device_id', value: device_id!.value);
        await FlutterSecureStorage().write(key: 'device_token', value: device_token!.value);
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

        await FlutterSecureStorage().write(key: 'localUid', value: loginUid!.value);

        await FlutterSecureStorage().write(key: 'device_id', value: device_id!.value);

        await FlutterSecureStorage().write(key: 'device_token', value: device_token!.value);

        await FlutterSecureStorage().write(key: 'user_id', value: data['user']['user_id'].toString());

        String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
        print(userIdString);
        int user_id = int.parse(userIdString!);

        await _userViewModel.updateUserModel_api(user_id);

        Get.offAllNamed(AppRoutes.mainHome);
      } else if (message == '기존기기') {

        await FlutterSecureStorage().write(key: 'localUid', value: loginUid!.value);

        await FlutterSecureStorage().write(key: 'user_id', value: data['user']['user_id'].toString());

        await FlutterSecureStorage().write(key: 'device_id', value: device_id!.value);

        await FlutterSecureStorage().write(key: 'device_token', value: device_token!.value);

        String? userIdString = await FlutterSecureStorage().read(key: 'user_id');
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
  //로컬의 signInMethod 불러오기
  Future<void> getLocalSignInMethod() async {
    final signInMethod = await FlutterSecureStorage().read(key: 'signInMethod');
    this.signInMethod.value = signInMethod ?? '';
  }

  Future<void> signOut_welcome() async {
    User user = FirebaseAuth.instance.currentUser!;
    await user.delete();
    await FlutterSecureStorage().delete(key: 'signInMethod');
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

}

