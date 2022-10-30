import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:snowlive3/screens/v_loginpage.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class LoginController extends GetxController {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;
  late FacebookAuth facebookAuth = FacebookAuth.instance;
  late GoogleSignIn googleSignIn = GoogleSignIn();
  String? loginKey='false';
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
    }
    CustomFullScreenDialog.cancelDialog();
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
    }
    CustomFullScreenDialog.cancelDialog();
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
    this.loginKey = await FlutterSecureStorage().read(key: 'login');
    this.loginUid = await FlutterSecureStorage().read(key: 'uid');
  }

  Future<void> loginFail() async {
    await FlutterSecureStorage()
        .write(key: 'login', value: 'false');
    await FlutterSecureStorage().delete(key: 'uid');
  }

  Future<void> getLoginAgainUser() async{

  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await FlutterSecureStorage().write(key: 'login', value: 'false');
    Get.offAll(() => LoginPage());
  }

  Future<void> signOut_welcome() async {
    User user = FirebaseAuth.instance.currentUser!;
    await user.delete();
    await FlutterSecureStorage().delete(key: 'uid');
    Get.offAll(() => LoginPage());
  }

  Future<void> deleteUser(uid) async {
    CustomFullScreenDialog.showDialog();
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('user');
      await users.doc(uid).delete();
      User user = FirebaseAuth.instance.currentUser!;
      await user.delete();
      await signOut();
      await FlutterSecureStorage().delete(key: 'uid');
      CustomFullScreenDialog.cancelDialog();
    }catch(e){
      CustomFullScreenDialog.cancelDialog();
      Get.back();
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
      'exist' : true
    });
  } //유저 정보와 선택한 리조트 정보 파베에 저장하기

}
