import 'dart:convert';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  RxString _deviceToken = ''.obs;
  RxString _deviceID = ''.obs;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String get deviceToken => _deviceToken.value;
  String get deviceID => _deviceID.value;

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
    await _initializeNotificationChannel();

    // 토큰 가져오기 및 알림 수신 설정
    await _getToken();
    await _onMessage();
  }

  Future<void> _getToken() async {
    String? deviceToken = await messaging.getToken();
    String? deviceId = await PlatformDeviceId.getDeviceId;
    _deviceToken.value = deviceToken ?? '';
    _deviceID.value = deviceId ?? '';

    print('deviceToken: $_deviceToken');
    print('deviceID: $_deviceID');
  }

  Future<String?> postMessage({required String fcmToken, required String title, required String body}) async {
    try {
      String url = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/fcm/send-push/';
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
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

  Future<void> _initializeNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID
      'High Importance Notifications', // 이름
      description: 'This channel is used for important notifications.', // 설명
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _onMessage() async {
    // 포그라운드 알림 수신 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground에서 알림 수신: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 알림 클릭 시 앱이 열리는 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('알림 클릭 후 앱이 열림: ${message.notification?.title}');
    });

    // 앱 종료 상태에서 알림 클릭 시 처리
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      print('앱이 종료된 상태에서 알림을 클릭해 앱이 열림: ${message?.notification?.title}');
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode, // 고유 ID
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.isNotEmpty ? json.encode(message.data) : null,
    );
  }
}
