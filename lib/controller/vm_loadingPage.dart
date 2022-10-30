import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import 'package:snowlive3/screens/v_loginpage.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();

}

class _LoadingPageState extends State<LoadingPage> {

  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection************************************************
    Get.put(ResortModelController(), permanent: true);
    Get.put(UserModelController(), permanent: true);
    Get.put(GetDateTimeController(), permanent: true);
    //TODO: Dependency Injection************************************************


    return FutureBuilder(
      future: FlutterSecureStorage().read(key: 'login'),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        print('login상태냐?? -> ${snapshot.hasData}');
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData == true) {
          print('1');
          return MainHome();
        } else {
          if(FirebaseAuth.instance.currentUser != null) {
            print(FirebaseAuth.instance.currentUser != null);
            return FutureBuilder(
                future:FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.uid).delete(),
                builder: (context, AsyncSnapshot<dynamic> snapshot){
                  return FutureBuilder(
                      future: FirebaseAuth.instance.currentUser!.delete(),
                      builder: (context, AsyncSnapshot<dynamic> snapshot){
                        return LoginPage();
                      }
                  );
                }
            );
          }else LoginPage();
        }
        return LoginPage();
      },
    );
  }
}