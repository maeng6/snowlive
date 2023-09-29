import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_urlLauncherController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform, exit;



final ref = FirebaseFirestore.instance;

UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();



Future<void> checkForUpdate() async {
  try {
    final currentVersion = await getCurrentAppVersion();
    final latestVersion = await getLatestAppVersion();
    print(currentVersion);
    print(latestVersion);

    if (currentVersion != latestVersion) {
      Get.dialog(
          AlertDialog(
            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            content: Text(
              '최신 버전 앱으로 업데이트를 위해 스토어로 이동합니다.',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
            actions: [
              TextButton(
                  onPressed: () async{

                    if(Platform.isAndroid){
                      final url = 'https://play.google.com/store/apps/details?id=com.snowlive';
                      _urlLauncherController.otherShare(contents: url);
                    }else if(Platform.isIOS){
                      final url = 'https://apps.apple.com/us/app/apple-store/id6444235991';
                      _urlLauncherController.otherShare(contents: url);
                    }
                  },
                  child: Text('확인',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF949494),
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ],
          ),
      barrierDismissible: false
      );
    }
  } catch (e) {
    print('업데이트 확인 중 오류 발생: $e');
  }
}

Future<String> getCurrentAppVersion() async {
  try {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  } catch (e) {
    print('앱 버전을 가져오는 동안 오류 발생: $e');
    return ''; // 오류 발생 시 기본값 또는 빈 문자열 반환
  }
}

Future<String> getLatestAppVersion() async {
  DocumentReference<Map<String, dynamic>> documentReference =
  ref.collection('version').doc('1');
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
  await documentReference.get();
  String latestAppVersion = documentSnapshot.get('version');
  return latestAppVersion;
}