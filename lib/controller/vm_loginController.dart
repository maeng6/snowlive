import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:com.snowlive/controller/vm_loadingPage.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/screens/login/v_loginpage.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';

import '../screens/onboarding/v_FirstPage.dart';

class LoginController extends GetxController {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;
  late FacebookAuth facebookAuth = FacebookAuth.instance;
  late GoogleSignIn googleSignIn = GoogleSignIn();
  String? loginUid;

//TODO: Dependency Injection**************************************************
  SeasonController _seasonController = Get.find<SeasonController>();
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************


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
      CustomFullScreenDialog.cancelDialog();
      Get.offAll(() => FirstPage());
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
      CustomFullScreenDialog.cancelDialog();
      Get.offAll(() => FirstPage());
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
  }

  Future<void> getLoginAgainUser() async{

  }

  Future<void> signOut_welcome() async {
    User user = FirebaseAuth.instance.currentUser!;
    await user.delete();
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
        CollectionReference users = FirebaseFirestore.instance.collection('user');
        await users.doc(uid).delete();
        print('유저독 삭제');
        User user = FirebaseAuth.instance.currentUser!;
        await user.delete();
        print('어센 삭제');
      } catch(e){
        CustomFullScreenDialog.cancelDialog();
        Get.offAll(()=>LoginPage());
      }
    }

    CustomFullScreenDialog.cancelDialog();
    Get.offAll(()=>LoginPage());
  }

  Future<void> createUserDoc(index) async {
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
    });
    await ref.collection('newAlarm')
        .doc(uid)
        .set({
      'uid': uid,
      'newInvited_friend': false,
      'newInvited_crew': false,
    });


  } //유저 정보와 선택한 리조트 정보 파베에 저장하기

}
