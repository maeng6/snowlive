import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/login/vm_notificationController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:com.snowlive/controller/public/vm_limitController.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import 'package:com.snowlive/screens/login/v_loginpage.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';

import '../../screens/onboarding/v_FirstPage.dart';
import '../../screens/v_MainHome.dart';

class LoginController extends GetxController {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;
  late FacebookAuth facebookAuth = FacebookAuth.instance;
  late GoogleSignIn googleSignIn = GoogleSignIn();
  String? loginUid;
  RxString? _signInMethod=''.obs;

  String? get signInMethod => _signInMethod!.value;

  @override
  void onInit() async{
    // TODO: implement onInit
    super.onInit();
    await getLocalSignInMethod();
    if(_signInMethod!.value == ''){
      this._signInMethod!.value = getCurrentUserSignInMethod();
      await FlutterSecureStorage().write(key: 'signInMethod', value: this._signInMethod!.value);
      print('기존 로그인 이용자의 로그인방법 저장 성공');
    }
    print('마지막 로그인 방법 : $_signInMethod');
  }

//TODO: Dependency Injection**************************************************
  limitController _seasonController = Get.find<limitController>();
  UserModelController _userModelController = Get.find<UserModelController>();
  NotificationController _notificationController = Get.find<NotificationController>();
  //TODO: Dependency Injection**************************************************

  String getCurrentUserSignInMethod() {
    final user = auth.currentUser;

    if (user != null) {
      for (final info in user.providerData) {
        final providerId = info.providerId;

        if (providerId == 'password') {
          return 'Email/Password';
        } else if (providerId == 'google.com') {
          return 'google';
        } else if (providerId == 'facebook.com') {
          return 'facebook';
        } else if (providerId == 'apple.com') {
          return 'apple';
        }
      }
    }
    return '';  // 로그인하지 않은 경우 null 반환
  }

  Future<void> getLocalSignInMethod() async {
    final signInMethod = await FlutterSecureStorage().read(key: 'signInMethod');
    this._signInMethod!.value = signInMethod ?? '';  // null이면 빈 문자열을 반환합니다.
  }

  Future<void> getExistUserDoc({required uid}) async{

    final userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc('$uid');
    var userDocSnapshot = await userDoc.get();
    var localDeviceID = await FlutterSecureStorage().read(key: 'deviceID');

    if (localDeviceID == null) {
      localDeviceID = '${_notificationController.deviceID}';
      await FlutterSecureStorage().write(key: 'deviceID', value: '${_notificationController.deviceID}');
    }


    if (userDocSnapshot.exists ) {
      if(localDeviceID == userDocSnapshot['deviceID']) {
        CustomFullScreenDialog.cancelDialog();
        await FlutterSecureStorage().write(key: 'uid', value: auth.currentUser!.uid);
        await FlutterSecureStorage().write(key: 'deviceID', value: '${_notificationController.deviceID}');
        Get.offAll(() => MainHome(uid: uid));
      }else {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              content:
              Container(
                height: 128,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/imgs/icons/icon_popup_notice.png',
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: Text(
                        '해당 기기에서 로그인하면\n다른 기기에서는 모두 로그아웃됩니다.',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        CustomFullScreenDialog.cancelDialog();
                        Get.back();
                      },
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF949494),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await _userModelController.updateDeviceID(deviceID: localDeviceID);
                          await _userModelController.updateDeviceToken(deviceToken: _notificationController.deviceToken);
                          await FlutterSecureStorage().write(key: 'deviceID', value: '${_notificationController.deviceID}');
                          await FlutterSecureStorage().write(key: 'uid', value: auth.currentUser!.uid);
                          CustomFullScreenDialog.cancelDialog();
                          Get.offAll(() => MainHome(uid: uid));
                        } catch (e) {
                          Get.back();
                        }
                      },
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3D83ED),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      }
    } else {
      print('Document does not exist on the database');
      CustomFullScreenDialog.cancelDialog();
      Get.offAll(() => FirstPage());
    }
  }

  Future<void> deviceIdentificate({required uid}) async{

    final userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc('$uid');
    var userDocSnapshot = await userDoc.get();
    var localDeviceID = await FlutterSecureStorage().read(key: 'deviceID');
    String? deviceId = await PlatformDeviceId.getDeviceId;
    if (userDocSnapshot.exists ) {
      print(userDocSnapshot['deviceID']);

      if(userDocSnapshot['deviceID'] == '' || deviceId != localDeviceID){

        localDeviceID = '${_notificationController.deviceID}';
        await FlutterSecureStorage().write(key: 'deviceID', value: '${_notificationController.deviceID}');

        await _userModelController.updateDeviceID(deviceID: deviceId);

        final updatedUserDocSnapshot = await userDoc.get();
        userDocSnapshot = updatedUserDocSnapshot;
        print('업데이트된 파베 디바이스 아이디: ${updatedUserDocSnapshot['deviceID']}');
      }


      try{
        print('로컬 DeviceID : $localDeviceID');
        print('real Device ID : ${deviceId}');

        if(localDeviceID == userDocSnapshot['deviceID']){
        }else{
          print('로컬 DeviceID : $localDeviceID');
          print('real Device ID : ${deviceId}');
          Get.dialog(WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              content: Container(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/imgs/icons/icon_popup_notice.png',
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: Text(
                        '기존 계정으로 다시 로그인해주세요.',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.4),
                        textAlign: TextAlign.center,

                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: TextButton(
                      onPressed: () async {
                        try{
                          await signOutFromAll;
                          await FlutterSecureStorage().delete(key: 'uid');
                          await getLocalSignInMethod();
                          Get.offAll(() => LoginPage());
                        }catch(e){
                          Get.back();
                        }
                      },
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3D83ED),
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                )
              ],
            ),
          ),
              barrierDismissible: false);
        }
      }catch(e){
        print('로컬 스토리지 불러오기 에러');
        Get.dialog(WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            content: Container(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/icons/icon_popup_notice.png',
                    width: 48,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: Text(
                      '기존 계정으로 다시 로그인해주세요.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.4),
                      textAlign: TextAlign.center,

                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Center(
                child: TextButton(
                    onPressed: () async {
                      try{
                        await signOutFromAll;
                        await FlutterSecureStorage().delete(key: 'uid');
                        await getLocalSignInMethod();
                        Get.offAll(() => LoginPage());
                      }catch(e){
                        Get.back();
                      }
                    },
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3D83ED),
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              )
            ],
          ),
        ),
            barrierDismissible: false);
      }
    }
  }

  Future<void> signOutFromAll() async {
    try {
      // Firebase에서 로그아웃
      await FirebaseAuth.instance.signOut();

      // Google Sign-In에서 로그아웃
      await GoogleSignIn().signOut();

      // Facebook 로그아웃
      await FacebookAuth.instance.logOut();

    } catch (error) {
      print("로그아웃 중 오류 발생: $error");
    }
  }

  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount == null) {
      CustomFullScreenDialog.cancelDialog();
    } else {
      GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);
      await auth.signInWithCredential(oAuthCredential);

      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        await getExistUserDoc(uid: currentUser.uid);
        await FlutterSecureStorage().write(key: 'signInMethod', value: 'google');
      }
    }
  }

  Future<void> signInWithFacebook() async {
    final LoginResult loginResult = await facebookAuth.login();
    if (loginResult == null) {
      CustomFullScreenDialog.cancelDialog();
    } else {
      OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(loginResult.accessToken!.token);
      await auth.signInWithCredential(facebookAuthCredential);
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        await getExistUserDoc(uid: currentUser.uid);
        await FlutterSecureStorage().write(key: 'signInMethod', value: 'facebook');
      }
    }
  }

  Future<UserCredential> signInWithApple() async {
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

    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future<void> loginAgain() async {
    try {
      this.loginUid = await FlutterSecureStorage().read(key: 'uid');
    }catch(e){
      this.loginUid = null;
    }
  }

  Future<void> loginFail() async {
    await FlutterSecureStorage()
        .write(key: 'login', value: 'false');
    await FlutterSecureStorage().delete(key: 'uid');
    await FlutterSecureStorage().delete(key: 'signInMethod');
  }

  Future<void> getLoginAgainUser() async{

  }

  Future<void> signOut_welcome() async {
    User user = FirebaseAuth.instance.currentUser!;
    await user.delete();
    await FlutterSecureStorage().delete(key: 'signInMethod');
    Get.offAll(() => LoginPage());
  }

  Future<void> deleteFleaItemAll({required myUid, required fleaCount}) async{
    print(myUid);
    for (int i = fleaCount; i > -1; i--) {
      DocumentReference fleaDocs = FirebaseFirestore
          .instance.collection('fleaMarket').doc('$myUid#$i');
      FirebaseFirestore.instance.runTransaction((transaction) async => await transaction.delete(fleaDocs));
      print(i);
    }
  }

  Future<void> deleteBulletinCrewAll({required myUid, required bulletinCrewCount}) async{
    print(myUid);
    for (int i = bulletinCrewCount; i > -1; i--) {
      DocumentReference bulletinCrewDocs = FirebaseFirestore
          .instance.collection('bulletinCrew').doc('$myUid#$i');
      FirebaseFirestore.instance.runTransaction((transaction) async => await transaction.delete(bulletinCrewDocs));
      print(i);
    }
  }

  Future<void> deleteBulletinRoomAll({required myUid, required bulletinRoomCount}) async{
    print(myUid);
    for (int i = bulletinRoomCount; i > -1; i--) {
      DocumentReference bulletinRoomDocs = FirebaseFirestore
          .instance.collection('bulletinRoom').doc('$myUid#$i');
      FirebaseFirestore.instance.runTransaction((transaction) async => await transaction.delete(bulletinRoomDocs));
      print(i);
    }
  }

  Future<dynamic> deleteUser({
    required uid,
    required fleaCount,
    required bulletinCrewCount,
    required bulletinRoomCount,
    required crewID}) async {

    CustomFullScreenDialog.showDialog();

    String leaderUid='';
    DocumentReference? liveCrewRef;
    DocumentSnapshot? crewSnapshot;

    try{
      await _userModelController.getCurrentUser_crew(uid);
      if(_userModelController.liveCrew != null && _userModelController.liveCrew!.isNotEmpty) {
        liveCrewRef = await FirebaseFirestore.instance
            .collection('liveCrew')
            .doc('${_userModelController.liveCrew}');
        crewSnapshot = await liveCrewRef.get();
        if (crewSnapshot.exists) {
          leaderUid = crewSnapshot.get('leaderUid') ?? '';
        } else {
          print('Document does not exist on the database');
        }
      }else{}
    } catch(e){}

    print('리더uid : $leaderUid');

    if(leaderUid == _userModelController.uid && _userModelController.uid != ''){
      CustomFullScreenDialog.cancelDialog();
      return Get.dialog(AlertDialog(
        contentPadding: EdgeInsets.only(
            bottom: 0,
            left: 20,
            right: 20,
            top: 30),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
                10.0)),
        buttonPadding:
        EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 0),
        content: Text(
          '운영중인 크루가 있습니다.\n크루장을 위임한 후 다시 시도해주세요.',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                  onPressed: () async {
                    Get.back();
                    Get.back();
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(
                          0xff377EEA),
                      fontWeight: FontWeight
                          .bold,
                    ),
                  )),
            ],
            mainAxisAlignment: MainAxisAlignment
                .center,
          )
        ],
      ));
    } else {
      try {
        for (int i = 0; i <= 12; i++) {
          DocumentReference rankingDocRef = FirebaseFirestore.instance
              .collection('Ranking')
              .doc('${_seasonController.currentSeason}')
              .collection('$i')
              .doc("${_userModelController.uid}");
          await rankingDocRef.delete();
          print('랭킹독 삭제 완료');
        }
      } catch (e) {}


      try{
        if (liveCrewRef != null) {
          await liveCrewRef.update({
            'memberUidList': FieldValue.arrayRemove([uid])
          });
          print('크루 멤버 삭제');
        }
      } catch(e){}


      try{
        await deleteFleaItemAll(myUid: uid, fleaCount: fleaCount);
        print('중고거래 게시글 삭제');
      } catch(e){}

      try{
        await deleteBulletinCrewAll(myUid: uid, bulletinCrewCount: bulletinCrewCount);
        print('커뮤니티 크루 게시글 삭제');
      } catch(e){}

      try{
        await deleteBulletinRoomAll(myUid: uid, bulletinRoomCount: bulletinRoomCount);
        print('커뮤니티 시즌방 게시글 삭제');
      } catch(e){}


      try {
        await FirebaseStorage.instance.refFromURL('$uid.jpg').delete();
        print('프사 삭제');
      } catch(e){}


      try{
        await FlutterSecureStorage().delete(key: 'uid');
        print('자동로그인 삭제');
        await FlutterSecureStorage().delete(key: 'signInMethod');
        this._signInMethod!.value = '';
        print('마지막 로그인 정보 삭제');
        CollectionReference users = FirebaseFirestore.instance.collection('user');
        await users.doc(uid).delete();
        print('유저독 삭제');
        _userModelController.resetProfileImage();
        User user = FirebaseAuth.instance.currentUser!;
        await user.delete();
        print('어센 삭제');
      } catch(e){
        CustomFullScreenDialog.cancelDialog();
        Get.offAll(()=>LoginPage());
      }
    }
    this._signInMethod!.value = '';

    CustomFullScreenDialog.cancelDialog();
    Get.offAll(()=>LoginPage());
  }

  Future<void> createUserDoc({required index,required token,required deviceID}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    final email = user.providerData[0].email;
    final displayName = user.displayName;

    await ref.collection('user').doc(uid).set({
      'userEmail': email,
      'displayName': displayName,
      'uid': uid,
      'favoriteResort': index,
      'instantResort': index,
      'profileImageUrl' : '',
      'exist' : true,
      'repoCount' : 0,
      'fleaCount' : 0,
      'bulletinRoomCount' : 0,
      'bulletinCrewCount' : 0,
      'repoUidList' : List.empty(),
      'friendUidList' : List.empty(),
      'commentCount' : 0,
      'resortNickname' : '',
      'phoneAuth' : false,
      'phoneNum' : '',
      'resistDate' : Timestamp.now(),
      'likeUidList' : [],
      'newChat' : false,
      'friendUidList' : [],
      'stateMsg':'',
      'isOnLive': false,
      'whoResistMe':[],
      'whoResistMeBF':[],
      'withinBoundary': false,
      'whoRepoMe':[],
      'liveFriendUidList':[],
      'myFriendCommentUidList':[],
      'commentCheck':false,
      'whoIinvite':[],
      'whoInviteMe':[],
      'liveCrew':'',
      'applyCrewList':[],
      'totalScores':<String, dynamic>{},
      'deviceToken': token,
      'liveTalkHideList':[],
      'deviceID': deviceID,
      'kusbf': false,
      'bulletinFreeCount': 0,
      'bulletinEventCount' : 0
    });
    await ref.collection('newAlarm')
        .doc(uid)
        .set({
      'uid': uid,
      'newInvited_friend': false,
      'newInvited_crew': false,
      'alarmCenter': false,
    });


  } //유저 정보와 선택한 리조트 정보 파베에 저장하기

}
