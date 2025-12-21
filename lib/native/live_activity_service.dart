import 'dart:io';
import 'package:flutter/services.dart';

class LiveActivityService {
  static const MethodChannel _channel = MethodChannel('live_activity');

  /// iOS와 Android 모두 지원
  /// iOS: Dynamic Island / Lock Screen Live Activity
  /// Android: Foreground Notification
  static Future<String?> start({
    required DateTime liveOnStartAt,
    required int todayRideCount,
    required int sessionRideCount,
    required String lastSlopeName,
    DateTime? lastRideAt,
    int liveFriendCount = 0,
  }) async {
    // iOS와 Android 모두 지원
    if (!Platform.isIOS && !Platform.isAndroid) return null;

    final payload = {
      'liveOnStartAtMs': liveOnStartAt.toUtc().millisecondsSinceEpoch,
      'todayRideCount': todayRideCount,
      'sessionRideCount': sessionRideCount,
      'lastSlopeName': lastSlopeName,
      'liveFriendCount': liveFriendCount,
      if (lastRideAt != null) 'lastRideAtMs': lastRideAt.toUtc().millisecondsSinceEpoch,
    };
    print('[LiveActivityService.start] platform: ${Platform.operatingSystem}, payload: $payload');

    try {
      final id = await _channel.invokeMethod<String>('start', payload);
      print('[LA] start() returned id = $id');
      return id;
    } on PlatformException catch (e) {
      print('[LA] start error: $e');
      return null;
    }
  }


  static Future<void> update({
    required String activityId,
    required int todayRideCount,
    required int sessionRideCount,
    required String lastSlopeName,
    DateTime? lastRideAt,
    int liveFriendCount = 0,
  }) async {
    // iOS와 Android 모두 지원
    if (!Platform.isIOS && !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('update', {
        'activityId': activityId,
        'todayRideCount': todayRideCount,
        'sessionRideCount': sessionRideCount,
        'lastSlopeName': lastSlopeName,
        'liveFriendCount': liveFriendCount,
        if (lastRideAt != null) 'lastRideAtMs': lastRideAt.toUtc().millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      print('LiveActivity update error: $e');
    }
  }

  static Future<void> end({required String activityId}) async {
    // iOS와 Android 모두 지원
    if (!Platform.isIOS && !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('end', {'activityId': activityId});
    } on PlatformException catch (e) {
      print('LiveActivity end error: $e');
    }
  }
}
