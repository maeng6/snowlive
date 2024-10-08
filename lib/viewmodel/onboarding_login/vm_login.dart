import 'dart:convert';

import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_login.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math; // math 패키지 추가
import 'package:crypto/crypto.dart'; // sha256을 위한 crypto 패키지 추가
import 'package:firebase_storage/firebase_storage.dart';

final ref = FirebaseFirestore.instance;

class LoginViewModel extends GetxController {

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  RxBool? _isAndroidEmailLogIn = false.obs;
  bool? get isAndroidEmailLogIn => _isAndroidEmailLogIn!.value;

  final auth = FirebaseAuth.instance;
  final storage = FlutterSecureStorage();
  final googleSignIn = GoogleSignIn();
  final loginAPI = LoginAPI();
  RxString signInMethod = ''.obs;
  RxString? loginUid = ''.obs;
  RxString? device_id = ''.obs;
  RxString? device_token = ''.obs;

  @override
  void onInit()  async{
    await _getToken();
    await getIsAndroidEmailLogIn();
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
      await FlutterSecureStorage().delete(key: 'localUid');
      await FlutterSecureStorage().delete(key: 'device_id');
      await FlutterSecureStorage().delete(key: 'device_token');
      await FlutterSecureStorage().delete(key: 'user_id');

      // 로그인 페이지로 이동
      Get.offAllNamed(AppRoutes.login);
    } else if (response.error['error'] == '크루장은 탈퇴할 수 없습니다.') {
      Get.snackbar('먼저 할 일이 있어요.', '크루장을 위임하거나, 크루를 삭제해주세요.');
    }
  }

}

