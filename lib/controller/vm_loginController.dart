import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class LoginController extends GetxController {

  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;
  late FacebookAuth facebookAuth = FacebookAuth.instance;
  late GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    CustomFullScreenDialog.showDialog();
    GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();
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
  }

  Future<void> signInWithFacebook() async {
    CustomFullScreenDialog.showDialog();
    final LoginResult loginResult =
    await facebookAuth.login();
    if(loginResult == null){
      CustomFullScreenDialog.cancelDialog();
    } else{
      OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(loginResult.accessToken!.token);
      await auth.signInWithCredential(facebookAuthCredential);
      CustomFullScreenDialog.cancelDialog();


    }
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
      'instantResort': index
    });
  } //유저 정보와 선택한 리조트 정보 파베에 저장하기

}