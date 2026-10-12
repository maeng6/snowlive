import 'dart:async';

import 'package:com.snowlive/core/api/api_locationShare.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:get/get.dart';

/// 웹 실시간 위치 지도 뷰모델. 공유 상태 관리 + 지도 좌표 폴링(5초).
class LiveMapViewModelWeb extends GetxController {
  final LocationShareAPI _api = LocationShareAPI();

  final RxBool isPaid = false.obs;
  final RxList<Map<String, dynamic>> accepted = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> incoming = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> outgoing = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> friendsOnMap = <Map<String, dynamic>>[].obs;

  Timer? _poll;

  int? get _uid {
    if (!Get.isRegistered<UserViewModel>()) return null;
    final id = Get.find<UserViewModel>().user.user_id;
    return (id is int) ? id : int.tryParse('$id');
  }

  @override
  void onInit() {
    super.onInit();
    loadShares();
    _startPolling();
  }

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => loadMap());
    loadMap();
  }

  Future<void> loadShares() async {
    final uid = _uid;
    if (uid == null) return;
    final res = await _api.list(userId: uid);
    if (res.success && res.data is Map) {
      final d = Map<String, dynamic>.from(res.data);
      isPaid.value = d['is_paid'] == true;
      accepted.assignAll(_asList(d['accepted']));
      incoming.assignAll(_asList(d['incoming']));
      outgoing.assignAll(_asList(d['outgoing']));
    }
  }

  Future<void> loadMap() async {
    final uid = _uid;
    if (uid == null) return;
    final res = await _api.map(userId: uid);
    if (res.success && res.data is Map && res.data['friends'] is List) {
      friendsOnMap.assignAll(_asList(res.data['friends']));
    }
  }

  List<Map<String, dynamic>> _asList(dynamic v) {
    if (v is! List) return [];
    return v.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> acceptRequest(int friendUserId) async {
    final uid = _uid;
    if (uid == null) return;
    await _api.accept(userId: uid, friendUserId: friendUserId);
    await loadShares();
    await loadMap();
  }

  Future<void> revoke(int friendUserId) async {
    final uid = _uid;
    if (uid == null) return;
    await _api.revoke(userId: uid, friendUserId: friendUserId);
    await loadShares();
    await loadMap();
  }

  Future<void> requestShare(int friendUserId) async {
    final uid = _uid;
    if (uid == null) return;
    await _api.request(userId: uid, friendUserId: friendUserId);
    await loadShares();
  }
}
