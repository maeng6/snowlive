import 'package:com.snowlive/core/api/api_locationShare.dart';

/// 유료+상호수락 사용자의 실시간 좌표를 주기적으로 publish한다(5초/10초).
/// 서버가 최종 게이트(유료+수락상대) 판정 → 자격 없으면 no-op.
/// 자격(is_paid+수락상대)은 60초마다 갱신한다.
class LivePublishService {
  LivePublishService._();
  static final LivePublishService instance = LivePublishService._();

  final LocationShareAPI _api = LocationShareAPI();

  bool _eligible = false;
  DateTime? _lastPublish;
  DateTime? _lastEligibilityCheck;

  /// 위치 스트림에서 호출. 라이딩 중이면 5초, 아니면 10초 주기로 전송.
  void onPosition(int userId, double lat, double lng,
      {int? slopeId, bool? isRiding}) {
    _maybeRefreshEligibility(userId);
    if (!_eligible) return;

    final intervalSec = (isRiding == true) ? 5 : 10;
    final now = DateTime.now();
    if (_lastPublish != null &&
        now.difference(_lastPublish!).inSeconds < intervalSec) {
      return;
    }
    _lastPublish = now;
    _publish(userId, lat, lng, slopeId, isRiding);
  }

  Future<void> _publish(
      int userId, double lat, double lng, int? slopeId, bool? isRiding) async {
    try {
      await _api.publish(
          userId: userId,
          lat: lat,
          lng: lng,
          slopeId: slopeId,
          isRiding: isRiding);
    } catch (_) {
      // 위치 공유는 보조 기능 → 실패 무시
    }
  }

  Future<void> _maybeRefreshEligibility(int userId) async {
    final now = DateTime.now();
    if (_lastEligibilityCheck != null &&
        now.difference(_lastEligibilityCheck!).inSeconds < 60) {
      return;
    }
    _lastEligibilityCheck = now;
    try {
      final res = await _api.list(userId: userId);
      if (res.success && res.data is Map) {
        final paid = res.data['is_paid'] == true;
        final accepted = res.data['accepted'];
        _eligible = paid && accepted is List && accepted.isNotEmpty;
      } else {
        _eligible = false;
      }
    } catch (_) {
      _eligible = false;
    }
  }

  void reset() {
    _eligible = false;
    _lastPublish = null;
    _lastEligibilityCheck = null;
  }
}
