import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';

class NotificationController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  RxString _deviceToken = ''.obs;
  RxString _deviceID = ''.obs;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // StreamSubscription 저장 (메모리 누수 방지)
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  String get deviceToken => _deviceToken.value;
  String get deviceID => _deviceID.value;

  @override
  void onInit() async {
    super.onInit();

    // 권한 요청
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print("🔔 알림 권한 상태: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 권한이 허용된 경우에만 토큰 요청
      await _initializeNotificationChannel();
      await _getToken();
      await _onMessage();
    } else {
      print("❌ 알림 권한이 거부됨");
    }
  }

  Future<void> _getToken() async {
    try {
      // iOS에서는 APNS 토큰이 설정될 때까지 대기
      if (Platform.isIOS) {
        String? apnsToken;
        int retryCount = 0;
        const maxRetries = 10;

        while (apnsToken == null && retryCount < maxRetries) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken == null) {
            await Future.delayed(const Duration(milliseconds: 500));
            retryCount++;
          }
        }

        if (apnsToken == null) {
          print('⚠️ APNS 토큰을 가져올 수 없습니다. FCM 초기화를 건너뜁니다.');
          return;
        }
        print('✅ APNS 토큰 획득 완료');
      }

      String? deviceToken = await messaging.getToken();
      String? deviceId = await FlutterUdid.udid;

      _deviceToken.value = deviceToken ?? '';
      _deviceID.value = deviceId ?? '';

      print('📱 FCM Token: $_deviceToken');
      print('📱 Device ID: $_deviceID');

      // 전체 유저 대상 푸시 알림을 위한 토픽 구독
      await subscribeToTopic('all_users');
    } catch (e) {
      print('❗️FCM 토큰 가져오기 실패: $e');
    }
  }

  // 토픽 구독
  Future<void> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);
      print('✅ FCM 토픽 구독 완료: $topic');
    } catch (e) {
      print('❌ FCM 토픽 구독 실패: $e');
    }
  }

  // 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);
      print('✅ FCM 토픽 구독 해제: $topic');
    } catch (e) {
      print('❌ FCM 토픽 구독 해제 실패: $e');
    }
  }

  Future<String?> postMessage({required String fcmToken, required String title, required String body}) async {
    try {
      String url = 'https://snowlive-api-0eab29705c9f.herokuapp.com/api/fcm/send-push/';
      // timeout 추가: 백그라운드에서 무한 대기 방지
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "token": fcmToken,
          "title": title,
          "body": body,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('푸시 알림 전송 시간 초과');
        },
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        print("Failed to send push notification: ${response.statusCode}");
        return "Failed to send push notification";
      }
    } on TimeoutException catch (e) {
      print("Timeout occurred: $e");
      return "Error: 요청 시간 초과";
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
    // 포그라운드 알림 수신 처리 (StreamSubscription 저장)
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground에서 알림 수신: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 알림 클릭 시 앱이 열리는 처리 (StreamSubscription 저장)
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('알림 클릭 후 앱이 열림: ${message.notification?.title}');
      _handleNotificationClick(message);
    });

    // 앱 종료 상태에서 알림 클릭 시 처리
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('앱이 종료된 상태에서 알림을 클릭해 앱이 열림: ${message.notification?.title}');
        // 약간의 딜레이 후 처리 (앱 초기화 완료 대기)
        Future.delayed(const Duration(seconds: 2), () {
          _handleNotificationClick(message);
        });
      }
    });
  }

  /// 알림 클릭 시 처리
  void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    print('📬 알림 데이터: $data');

    // 라이브 중단 알림인 경우 복구 시도
    if (type == 'live_interrupted') {
      _handleLiveInterruptedNotification();
    }
  }

  /// 라이브 중단 알림 처리 - 현재 위치에서 liveOn 재시도
  Future<void> _handleLiveInterruptedNotification() async {
    try {
      // UserViewModel과 ResortHomeViewModel 가져오기
      if (!Get.isRegistered<UserViewModel>() || !Get.isRegistered<ResortHomeViewModel>()) {
        print('⚠️ ViewModel이 아직 초기화되지 않음');
        return;
      }

      final userViewModel = Get.find<UserViewModel>();
      final resortHomeViewModel = Get.find<ResortHomeViewModel>();

      final userId = userViewModel.user.user_id;
      if (userId == null) {
        print('⚠️ 사용자 ID가 없음');
        return;
      }

      // 이미 위치 스트림이 활성화되어 있으면 불필요
      if (resortHomeViewModel.isPositionStreamActive) {
        print('ℹ️ 이미 라이브 활성화 상태');
        return;
      }

      // 현재 위치에서 liveOn 재시도 (restoreLiveOn이 위치 판별 수행)
      print('🔄 라이브 재시작 시도 (푸시 알림 클릭)');
      await resortHomeViewModel.restoreLiveOn(userId);
    } catch (e) {
      print('❌ 라이브 재시작 실패: $e');
    }
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

  @override
  void onClose() {
    // StreamSubscription 해제 (메모리 누수 방지)
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    super.onClose();
  }
}
