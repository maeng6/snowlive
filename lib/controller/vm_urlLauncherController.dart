import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UrlLauncherController extends GetxController {

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  void otherShare({required String contents}) async{
    if(await canLaunchUrlString(contents) )
      await launchUrlString(contents);
    else throw "Not!";
}

}