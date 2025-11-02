import 'dart:io';
import 'package:flutter/services.dart';

class LiveActivityService {
  static const MethodChannel _channel = MethodChannel('live_activity');

  static Future<String?> start({
    required DateTime liveOnStartAt,
    required int todayRideCount,
    required int sessionRideCount,
    required String lastSlopeName,
  }) async {
    if (!Platform.isIOS) return null;
    try {
      // ✅ 날짜를 문자열이 아닌 epoch(ms)로 보냅니다 (UTC 권장)
      final payload = {
        'liveOnStartAtMs': liveOnStartAt.toUtc().millisecondsSinceEpoch,
        'todayRideCount': todayRideCount,
        'sessionRideCount': sessionRideCount,
        'lastSlopeName': lastSlopeName,
      };
      // 디버그용 로그 (원하면 남겨두세요)
      print('[LiveActivityService.start] payload: $payload');

      final id = await _channel.invokeMethod<String>('start', payload);
      return id;
    } on PlatformException catch (e) {
      print('LiveActivity start error: $e');
      return null;
    }
  }

  static Future<void> update({
    required String activityId,
    required int todayRideCount,
    required int sessionRideCount,
    required String lastSlopeName,
  }) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('update', {
        'activityId': activityId,
        'todayRideCount': todayRideCount,
        'sessionRideCount': sessionRideCount,
        'lastSlopeName': lastSlopeName,
      });
    } on PlatformException catch (e) {
      print('LiveActivity update error: $e');
    }
  }

  static Future<void> end({required String activityId}) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('end', {'activityId': activityId});
    } on PlatformException catch (e) {
      print('LiveActivity end error: $e');
    }
  }
}
