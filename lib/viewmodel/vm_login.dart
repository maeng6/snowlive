import 'package:com.snowlive/api/api_login.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/ApiResponse.dart';
import '../api/api_user.dart';

final ref = FirebaseFirestore.instance;

class LoginViewModel extends GetxController {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

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
        await FlutterSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await FlutterSecureStorage().write(key: 'device_id', value: device_id!.value);
        await FlutterSecureStorage().write(key: 'device_token', value: device_token!.value);

      }
    }
  }

  //로컬에 signInMethod 저장
  Future<void> signInWithFacebook() async {
    final LoginResult loginResult = await facebookAuth.login();
    if (loginResult == null) {

    } else {
      OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
      await auth.signInWithCredential(facebookAuthCredential);
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        loginUid!.value = currentUser.uid;
        await storage.write(key: 'signInMethod', value: 'facebook');
        await FlutterSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await FlutterSecureStorage().write(key: 'device_id', value: device_id!.value);
        await FlutterSecureStorage().write(key: 'device_token', value: device_token!.value);
      }
    }
  }

  //로컬에 signInMethod 저장
  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        loginUid!.value = currentUser.uid;
        await storage.write(key: 'signInMethod', value: 'apple');
        await FlutterSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await FlutterSecureStorage().write(key: 'device_id', value: device_id!.value);
        await FlutterSecureStorage().write(key: 'device_token', value: device_token!.value);
      }
    } catch (e) {
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

        await FlutterSecureStorage().write(key: 'localUid', value: loginUid!.value);
        await FlutterSecureStorage().write(key: 'device_id', value: device_id!.value);
        await FlutterSecureStorage().write(key: 'device_token', value: device_token!.value);
        await FlutterSecureStorage().write(key: 'user_id', value: data['user']['user_id']);
        Get.offAllNamed(AppRoutes.mainHome);
      } else if (message == '기존기기') {
        await FlutterSecureStorage().write(key: 'user_id', value: data['user']['user_id']);
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

