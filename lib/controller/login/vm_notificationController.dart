import 'dart:convert';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 추가
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  RxString? _deviceToken = ''.obs;
  RxString? _deviceID = ''.obs;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // 추가

  String? get deviceToken => _deviceToken!.value;
  String? get deviceID => _deviceID!.value;

  @override
  void onInit() async {
    super.onInit();

    // 권한 요청 및 초기 설정
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print(settings.authorizationStatus);

    // 알림 채널 생성
    await _initializeNotificationChannel(); // 추가

    // 토큰 가져오기 및 알림 수신 설정
    await _getToken();
    await _onMessage();
  }

  /// 디바이스 고유 토큰과 ID를 가져오는 함수
  Future<void> _getToken() async {
    String? deviceToken = await messaging.getToken();
    String? deviceId = await PlatformDeviceId.getDeviceId;
    this._deviceToken!.value = deviceToken!;
    this._deviceID!.value = deviceId!;

    try {
      print('deviceToken : $_deviceToken');
      print('deviceID : $_deviceID');
    } catch (e) {
      print(e);
    }
  }

  /// Django 서버로 푸시 알림 요청을 보내는 함수
  Future<String?> postMessage({required fcmToken, required String title, required String body}) async {
    try {
      String url = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/fcm/send-push/';
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "token": fcmToken,
          "title": title,
          "body": body,
        }),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        print("Failed to send push notification: ${response.statusCode}");
        return "Failed to send push notification";
      }
    } catch (e) {
      print("Error occurred: $e");
      return "Error: $e";
    }
  }

  /// 알림 채널 초기화 함수
  Future<void> _initializeNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID
      'High Importance Notifications', // 이름
      description: 'This channel is used for important notifications.', // 설명
      importance: Importance.max,
    );

    // 채널을 플러그인에 추가
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 포그라운드, 백그라운드 및 종료된 상태에서 알림 수신 처리
  Future<void> _onMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground에서 알림 수신: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      print('알림 클릭 후 앱이 열림: ${message?.notification?.title}');
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      print('앱이 종료된 상태에서 알림을 클릭해 앱이 열림: ${message?.notification?.title}');
    });
  }
}
