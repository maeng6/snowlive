import 'dart:async';
import 'dart:convert';

import 'package:com.snowlive/core/api/api_locationShare.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/mobile/test_polygon/slope_geometry.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// 웹 실시간 위치 지도 뷰모델. 공유 상태 관리 + 지도 좌표 폴링(5초).
/// 친구들이 서로 다른 스키장에 있으면 리조트별로 그룹핑하고, 선택 리조트의 슬로프 폴리곤을 로드한다.
class LiveMapViewModelWeb extends GetxController {
  static const String _apiHost = 'https://snowlive-api-c617725e2b78.herokuapp.com';

  final LocationShareAPI _api = LocationShareAPI();

  final RxBool isPaid = false.obs;
  final RxList<Map<String, dynamic>> accepted = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> incoming = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> outgoing = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> friendsOnMap = <Map<String, dynamic>>[].obs;

  // 리조트 그룹핑/슬로프 배경.
  final RxnInt selectedResortId = RxnInt();
  final RxList<SlopePoly> slopesForSelected = <SlopePoly>[].obs;
  final Map<int, List<SlopePoly>> _slopeCache = {};
  bool _loadingSlopes = false;

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
      _ensureResortSelection();
    }
  }

  /// 친구가 올라와 있는 리조트 그룹(인원 내림차순). [{resort_id, resort_name, count}]
  List<Map<String, dynamic>> get resortGroups {
    final map = <int, Map<String, dynamic>>{};
    for (final f in friendsOnMap) {
      final rid = (f['resort_id'] as num?)?.toInt();
      if (rid == null) continue;
      final g = map.putIfAbsent(rid, () => {
            'resort_id': rid,
            'resort_name': (f['resort_name'] ?? '스키장').toString(),
            'count': 0,
          });
      g['count'] = (g['count'] as int) + 1;
    }
    final list = map.values.toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return list;
  }

  /// 선택 리조트에 있는 친구만.
  List<Map<String, dynamic>> get friendsInSelectedResort {
    final rid = selectedResortId.value;
    if (rid == null) return [];
    return friendsOnMap
        .where((f) => (f['resort_id'] as num?)?.toInt() == rid)
        .toList();
  }

  /// 스키장 밖(resort 미상/세션 아님) 친구 수.
  int get outsideCount =>
      friendsOnMap.where((f) => (f['resort_id'] as num?) == null).length;

  /// 선택 리조트가 비거나 사라졌으면 가장 친구 많은 리조트로 자동 선택 + 슬로프 로드.
  void _ensureResortSelection() {
    final groups = resortGroups;
    if (groups.isEmpty) {
      selectedResortId.value = null;
      slopesForSelected.clear();
      return;
    }
    final still = groups.any((g) => g['resort_id'] == selectedResortId.value);
    if (!still) selectedResortId.value = groups.first['resort_id'] as int;
    loadSlopes(selectedResortId.value!);
  }

  Future<void> loadSlopes(int resortId) async {
    if (_slopeCache.containsKey(resortId)) {
      if (selectedResortId.value == resortId) {
        slopesForSelected.assignAll(_slopeCache[resortId]!);
      }
      return;
    }
    if (_loadingSlopes) return;
    _loadingSlopes = true;
    try {
      final r = await http
          .get(Uri.parse('$_apiHost/api/resort/slopes-2627/?resort=$resortId'));
      final data = json.decode(utf8.decode(r.bodyBytes));
      final slopes = (data['slopes'] as List)
          .map((j) => SlopePoly.fromJson(j as Map<String, dynamic>))
          .where((s) => s.hasPolygon)
          .toList();
      _slopeCache[resortId] = slopes;
    } catch (_) {
      _slopeCache[resortId] = [];
    } finally {
      _loadingSlopes = false;
      if (selectedResortId.value == resortId) {
        slopesForSelected.assignAll(_slopeCache[resortId] ?? const []);
      }
    }
  }

  void selectResort(int rid) {
    selectedResortId.value = rid;
    if (_slopeCache.containsKey(rid)) {
      slopesForSelected.assignAll(_slopeCache[rid]!);
    } else {
      loadSlopes(rid);
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
