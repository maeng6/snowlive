import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class PushNotification {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static String? _token;

  // 권한 요청
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // iOS에서는 APNS 토큰이 설정될 때까지 대기
    if (Platform.isIOS) {
      String? apnsToken;
      int retryCount = 0;
      const maxRetries = 10;

      while (apnsToken == null && retryCount < maxRetries) {
        apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(milliseconds: 500));
          retryCount++;
        }
      }

      if (apnsToken == null) {
        print('⚠️ APNS 토큰을 가져올 수 없습니다. FCM 토큰 요청을 건너뜁니다.');
        return;
      }
      print('✅ APNS 토큰 획득 완료');
    }

    // get the device fcm token
    try {
      _token = await _firebaseMessaging.getToken();
      print("📱 FCM device token: $_token");
    } catch (e) {
      print('❌ FCM 토큰 획득 실패: $e');
    }
  }

  // flutter_local_notifications 패키지 관련 초기화
  static Future localNotiInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux
    );

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 포그라운드로 알림을 받아서 알림을 탭했을 때 페이지 이동
  // static void onNotificationTap(NotificationResponse notificationResponse) {
  //   App.navigatorKey.currentState!
  //       .pushNamed('/message', arguments: notificationResponse);
  // }

  // 포그라운드에서 푸시 알림을 전송받기 위한 패키지 푸시 알림 발송
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('pomo_timer_alarm_1', 'pomo_timer_alarm',
        channelDescription: '',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  // API를 이용한 발송 요청
  // static Future<void> send({required String title, required String message}) async {
  //   final jsonCredentials = await rootBundle.loadString('assets/data/auth.json');
  //   final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);
  //   final client = await auth.clientViaServiceAccount(
  //       creds,
  //       ['https://www.googleapis.com/auth/cloud-platform']
  //   );
  //
  //   final notificationData = {
  //     'message': {
  //       'token': _token, // 기기 토큰
  //       'data': { // payload 데이터 구성
  //         'via': 'FlutterFire Cloud Messaging!!!',
  //       },
  //       'notification': {
  //         'title': title, // 푸시 알림 제목
  //         'body': message, // 푸시 알림 내용
  //       },
  //     },
  //   };
  //
  //   final response = await client.post(
  //     Uri.parse('https://fcm.googleapis.com/v1/projects/${App.senderId}/messages:send'),
  //     headers: {
  //       'content-type': 'application/json',
  //     },
  //     body: jsonEncode(notificationData),
  //   );
  //
  //   client.close();
  //   if (response.statusCode == 200) {
  //     debugPrint('FCM notification sent with status code: ${response.statusCode}');
  //   } else {
  //     debugPrint('${response.statusCode}, ${response.reasonPhrase}, ${response.body}');
  //   }
  // }
}
