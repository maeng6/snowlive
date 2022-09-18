import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import 'package:snowlive3/screens/v_loginpage.dart';
import 'package:snowlive3/controller/vm_getDateTimeController.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> user) {

        //TODO: Dependency Injection********************************************
        Get.put(GetDateTimeController(),permanent: true);
        //TODO: Dependency Injection********************************************

        if (user.hasData) {
          return MainHome();
        } else {
          return LoginPage();
        }
      },
    );
  }
}