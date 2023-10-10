import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_urlLauncherController.dart';
import 'package:extended_image/extended_image.dart';
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
    final useUpdatePopup = await getUseUpdatePopup();
    print('로컬버전 : ${currentVersion}');
    print('서버버전 : ${latestVersion}');
    print('강제업데이트 사용 : ${useUpdatePopup}');

    if ((currentVersion != latestVersion) && (useUpdatePopup == true) ) {
      Get.dialog(
        WillPopScope(
          onWillPop: () async {
            // 뒤로가기 버튼을 눌러도 팝업이 닫히지 않게 하려면 true를 반환합니다.
            return false;
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actionsPadding: EdgeInsets.only(top: 0, right: 20, left: 20, bottom: 20),
            content: Container(
              height: 330,
              child: Column(
                children: [
                  ExtendedImage.asset(
                    'assets/imgs/imgs/img_app_update.png',
                    scale: 4,
                    fit: BoxFit.fitHeight,
                    width: MediaQuery.of(Get.context!).size.width,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      right: 20,
                      left: 20,
                      bottom: 24,
                    ),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '새로운 버전이 업데이트 되었습니다',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111111),
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              '최신 버전 앱으로 업데이트를 위해 스토어로 이동합니다.',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF949494),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                width: MediaQuery.of(Get.context!).size.width,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      final url = 'https://play.google.com/store/apps/details?id=com.snowlive';
                      _urlLauncherController.otherShare(contents: url);
                    } else if (Platform.isIOS) {
                      final url = 'https://apps.apple.com/us/app/apple-store/id6444235991';
                      _urlLauncherController.otherShare(contents: url);
                    }
                  },
                  child: Text(
                    '업데이트',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3D83ED),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false, // 외부 영역 터치로 팝업 닫기 금지
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

Future<bool> getUseUpdatePopup() async {
  DocumentReference<Map<String, dynamic>> documentReference =
  ref.collection('version').doc('1');
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
  await documentReference.get();
  bool useUpdatePopup = documentSnapshot.get('useUpdatePopup');
  return useUpdatePopup;
}