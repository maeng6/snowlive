import 'dart:convert';
import 'dart:io';
import 'dart:js';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:package_info_plus/package_info_plus.dart';

  Future<String> getAndroidStoreVersion(PackageInfo packageInfo) async {
    final id = packageInfo.packageName;
    final uri =
    Uri.https("play.google.com", "/store/apps/details", {"id": "$id"});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Can\'t find an app in the Play Store with the id: $id');
      return "";
    }
    final document = htmlParser.parse(response.body);
    final elements = document.getElementsByClassName('hAyfc');
    final versionElement = elements.firstWhere(
          (elm) => elm.querySelector('.BgcNfc')!.text == 'Current Version',
    );
    return versionElement.querySelector('.htlgb')!.text;
  }

  Future<dynamic> getiOSStoreVersion(PackageInfo packageInfo) async {
    final id = packageInfo.packageName;

    final parameters = {"bundleId": "$id"};

    var uri = Uri.https("itunes.apple.com", "/lookup", parameters);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      debugPrint('Can\'t find an app in the App Store with the id: $id');
      return "";
    }

    final jsonObj = json.decode(response.body);

    /* 일반 print에서 일정 길이 이상의 문자열이 들어왔을 때,
     해당 길이만큼 문자열이 출력된 후 나머지 문자열은 잘린다.
     debugPrint의 경우 일반 print와 달리 잘리지 않고 여러 행의 문자열 형태로 출력된다. */

    // debugPrint(response.body.toString());
    return jsonObj['results'][0]['version'];
  }


Future<bool> initialize() async {

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  /* ***************************************** */
  // playStore || appStore -> version check
  /* ***************************************** */

  var storeVersion = Platform.isAndroid ? await getAndroidStoreVersion(packageInfo) : Platform.isIOS ? await getiOSStoreVersion(packageInfo) : "";

  print('my device version : ${packageInfo.version}');
  print('current store version: ${storeVersion.toString()}');

  if (storeVersion.toString().compareTo(packageInfo.version) != 0 && storeVersion.toString().compareTo("") != 0) {
    final int result = await Get.dialog(AlertDialog(
      title: Text('앱업데이트를 해주세요')
    ));
    if (result == 0) {
          getStoreUrlValue(packageInfo.packageName, packageInfo.appName);
    }
  }
}

String getStoreUrlValue(String packageName, String appName) {
  if (Platform.isAndroid) {
    return "https://play.google.com/store/apps/details?id=$packageName";
  } else if (Platform.isIOS)
    return "http://apps.apple.com/kr/app/$appName/id${ConstantString.APP_STORE_ID}";
  else
    return null;
}