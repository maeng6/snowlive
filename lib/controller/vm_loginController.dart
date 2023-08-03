import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:snowlive3/controller/vm_loadingPage.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/login/v_loginpage.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

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
    this.loginUid = await FlutterSecureStorage().read(key: 'uid');
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

  Future<dynamic> deleteUser({required uid, required fleaCount,required crewID}) async {
    CustomFullScreenDialog.showDialog();

    String leaderUid='';
    DocumentReference? liveCrewRef;
    DocumentSnapshot? crewSnapshot;
    await _userModelController.getCurrentUser_crew(uid);
    if(_userModelController.liveCrew!.isNotEmpty
        && _userModelController.liveCrew != '') {
      liveCrewRef = await FirebaseFirestore.instance
          .collection('liveCrew')
          .doc('${_userModelController.liveCrew}');
      crewSnapshot = await liveCrewRef.get();
      if (crewSnapshot.exists) {
        leaderUid = crewSnapshot.get('leaderUid');
      } else {
        print('Document does not exist on the database');
      }
    }else{}

    if(leaderUid == _userModelController.uid){
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
    }
    else {
      try {
        for (int i = 0; i <= 12; i++) {
          try {
            DocumentReference rankingDocRef = FirebaseFirestore.instance
                .collection('Ranking')
                .doc('${_seasonController.currentSeason}')
                .collection('$i')
                .doc("${_userModelController.uid}");
            await rankingDocRef.delete();
          } catch (e) {
            // 에러가 발생한 경우, 해당 값을 출력하고 다음 번호로 넘어감
            print('Error occurred for value $i: $e');
            continue;
          }
        }

        await ref.collection('liveCrew').doc(crewID).update({
          'memberUidList': FieldValue.arrayRemove([uid])
        });

      } catch (e) {
        CustomFullScreenDialog.cancelDialog();
        Get.offAll(() => LoginPage());
      }

      try{
      await ref.collection('liveCrew').doc(crewID).update({
        'memberUidList': FieldValue.arrayRemove([uid])
      });}catch(e){}

      await deleteFleaItemAll(myUid: uid, fleaCount: fleaCount);
      await FlutterSecureStorage().delete(key: 'uid');
      CollectionReference users = FirebaseFirestore.instance.collection('user');
      await users.doc(uid).delete();
      User user = await FirebaseAuth.instance.currentUser!;
      await user.delete();
      try {
        await FirebaseStorage.instance.refFromURL('$uid.jpg').delete();
      }catch(e){}
      CustomFullScreenDialog.cancelDialog();
      Get.offAll(() => LoginPage());

    }
    CustomFullScreenDialog.cancelDialog();
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
