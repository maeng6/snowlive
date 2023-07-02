import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:snowlive3/controller/vm_loadingPage.dart';
import 'package:snowlive3/screens/login/v_loginpage.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

import '../screens/onboarding/v_FirstPage.dart';

class LoginController extends GetxController {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;
  late FacebookAuth facebookAuth = FacebookAuth.instance;
  late GoogleSignIn googleSignIn = GoogleSignIn();
  String? loginUid;

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

  Future<void> deleteUser({required uid, required fleaCount}) async {
    CustomFullScreenDialog.showDialog();
    try {
      await deleteFleaItemAll(myUid: uid , fleaCount: fleaCount);
      await FlutterSecureStorage().delete(key: 'uid');
      CollectionReference users = FirebaseFirestore.instance.collection('user');
      await users.doc(uid).delete();
      User user = FirebaseAuth.instance.currentUser!;
      await user.delete();
      FirebaseStorage.instance.refFromURL('$uid.jpg').delete();
      Get.offAll(() => LoginPage());
      CustomFullScreenDialog.cancelDialog();
    }catch(e){
      CustomFullScreenDialog.cancelDialog();
      Get.offAll(()=>LoginPage());
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
      'liveCrew':[],
      'applyCrewList':[],
      'totalScores':<String, dynamic>{},
    });


  } //유저 정보와 선택한 리조트 정보 파베에 저장하기

}
