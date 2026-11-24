import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/api/api_snowball.dart';
import 'package:com.snowlive/core/model/m_snowball.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 웹 눈송이 상점 뷰모델.
///
/// 모바일 [SnowballShopViewModel]을 웹 라우팅(GetX 페이지 스택)에 맞춰 옮긴 것.
/// 데이터 출처는 모바일과 완전히 동일하다 — 같은 [SnowballAPI](Heroku 랭킹 API)와
/// Firestore `snowball_market` 문서를 그대로 쓴다. 화면만 웹용으로 다시 그린다.
class SnowballShopViewModelWeb extends GetxController {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final SnowballAPI _api = SnowballAPI();

  // ------------------------ UI 상태 ------------------------
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool isRecordsLoading = false.obs;

  /// 이벤트 날짜(Firestore event_date). 상점/요약/구매 API의 필수 파라미터.
  final RxInt eventDate = 1.obs;

  // ------------------------ 데이터 ------------------------
  final RxList<SnowballKindRemain> summary = <SnowballKindRemain>[].obs;
  final RxList<SnowballRecord> homeRecords = <SnowballRecord>[].obs;
  final RxList<SnowballSponsor> sponsors = <SnowballSponsor>[].obs;

  final RxList<SnowballShopItem> shopItems = <SnowballShopItem>[].obs;
  final RxList<SnowballShopItem> brandItems = <SnowballShopItem>[].obs;
  final RxList<SnowballBuyRecord> purchaseHistory = <SnowballBuyRecord>[].obs;
  final RxList<SnowballRecord> userSnowballRecords = <SnowballRecord>[].obs;
  final RxBool isPremiumUser = false.obs;

  final Rx<MissionStatus> _missionStatus = MissionStatus().obs;
  MissionStatus get missionStatus => _missionStatus.value;
  List<MapEntry<String, MissionPiece>> get missionEntriesSorted =>
      missionStatus.entriesSorted;
  String missionTitle(String id) => missionStatus.titleOf(id);
  bool missionComplete(String id) => missionStatus.isComplete(id);

  final RxString _nextPageUrlShop = ''.obs;
  String get nextPageUrlShop => _nextPageUrlShop.value;
  bool get hasMore => _nextPageUrlShop.value.isNotEmpty;
  bool? _lastIsTierOnly;
  bool? _lastIsForMission;

  // ------------------------ Firestore ------------------------
  final Rxn<Map<String, dynamic>> market = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> goldNotice = Rxn<Map<String, dynamic>>();
  /// 어드민이 관리하는 상점 이미지 영역별 URL 맵(snowball_market/images). 비어있으면 번들 에셋 폴백.
  final RxMap<String, dynamic> images = <String, dynamic>{}.obs;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subMarket;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subGold;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subImages;

  /// 영역 키에 해당하는 어드민 오버라이드 이미지 URL. 없으면 null → 번들 에셋 사용.
  String? imgUrl(String key) {
    final v = images[key];
    return (v is String && v.isNotEmpty) ? v : null;
  }

  int get myUserId => _userViewModel.user.user_id;
  String get myDisplayName => _userViewModel.user.display_name ?? '';

  /// 로그인 여부. 게스트(비로그인)는 user_id가 0 이하 → 눈송이 Pay QR 등 유저
  /// 식별이 필요한 기능을 막는다.
  bool get isLoggedIn => myUserId > 0;

  /// 어드민 설정(Firestore)이 브랜드 미션 노출을 껐으면 false. 기본 true.
  bool get brandMissionVisible =>
      (market.value?['brand_mission_visible'] as bool?) ?? true;

  // ── 상점 공개 게이트(어드민 '상점 공개 게이트'와 동일 규칙) ──
  bool get marketLoaded => market.value != null;
  bool get shopOpen => (market.value?['open'] as bool?) ?? false;
  bool get toEveryone => (market.value?['to_everyone'] as bool?) ?? false;
  bool get brandOnly => (market.value?['brand_only'] as bool?) ?? false;
  String get visibility => (market.value?['visibility'] as String?) ?? 'all';

  int? _asInt(dynamic v) => v is int ? v : int.tryParse('$v');
  bool get _inCrewList {
    final cid = _userViewModel.user.crew_id;
    if (cid == null) return false;
    final list = (market.value?['crew_list'] as List?) ?? const [];
    return list.map(_asInt).contains(cid);
  }
  bool get _inUserList {
    final list = (market.value?['user_list'] as List?) ?? const [];
    return list.map(_asInt).contains(myUserId);
  }

  /// 입장 가능 여부: 숨김 아님 + open + (전체공개 or 허용 크루 or 허용 유저).
  bool get canEnterShop =>
      visibility != 'off' && shopOpen && (toEveryone || _inCrewList || _inUserList);

  /// 남은 하얀/황금 눈송이(요약 0번=하얀, 1번=황금). 비어있으면 0.
  int get whiteRemaining =>
      summary.isNotEmpty ? (summary[0].remaining ?? 0) : 0;
  int get goldRemaining =>
      summary.length > 1 ? (summary[1].remaining ?? 0) : 0;

  @override
  void onInit() {
    super.onInit();
    _listenMarket();
    _listenGoldNotice();
    _listenImages();
  }

  void _listenImages() {
    _subImages?.cancel();
    _subImages = FirebaseFirestore.instance
        .collection('snowball_market')
        .doc('images')
        .snapshots()
        .listen((snap) {
      images.value = snap.data() ?? <String, dynamic>{};
    });
  }

  void _listenMarket() {
    _subMarket?.cancel();
    _subMarket = FirebaseFirestore.instance
        .collection('snowball_market')
        .doc('snowball_market')
        .snapshots()
        .listen((snap) {
      market.value = snap.data();
      final ed = (snap.data()?['event_date'] as num?)?.toInt();
      if (ed != null) eventDate.value = ed;
    });
  }

  void _listenGoldNotice() {
    _subGold?.cancel();
    _subGold = FirebaseFirestore.instance
        .collection('snowball_market')
        .doc('gold_snowball_notice')
        .snapshots()
        .listen((snap) => goldNotice.value = snap.data());
  }

  // ------------------------ 홈 ------------------------
  Future<void> fetchHome() async {
    try {
      isLoading(true);
      final res = await _api.fetchSnowballHome({
        'user_id': myUserId,
        'event_date': eventDate.value,
      });
      if (res.success) {
        final data = SnowballHomeResponse.fromJson(res.data!);
        summary.value = data.summary ?? [];
        homeRecords.value = data.records ?? [];
        sponsors.value = data.sponsor ?? [];
      } else {
        debugPrint('[SnowballWeb] 홈 조회 실패: ${res.error}');
      }
    } catch (e) {
      debugPrint('[SnowballWeb] fetchHome 오류: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchUserRecords() async {
    try {
      isRecordsLoading(true);
      final res = await _api.fetchUserSnowballRecords({
        'user_id': myUserId,
        'event_date': eventDate.value,
      });
      if (res.success && res.data is List) {
        userSnowballRecords.value =
            (res.data as List).map((e) => SnowballRecord.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('[SnowballWeb] fetchUserRecords 오류: $e');
    } finally {
      isRecordsLoading(false);
    }
  }

  // ------------------------ 상점 ------------------------
  Future<void> fetchShop({
    bool? isTierOnly,
    bool? isForMission,
    String? url,
  }) async {
    try {
      if (url == null) {
        isLoading(true);
      } else {
        isMoreLoading(true);
      }
      _lastIsTierOnly = isTierOnly;
      _lastIsForMission = isForMission;

      final res = await _api.fetchSnowballShop(
        userId: myUserId,
        eventDate: eventDate.value,
        isTierOnly: isTierOnly,
        isForMission: isForMission,
        url: url,
      );
      if (!res.success) {
        debugPrint('[SnowballWeb] 상점 조회 실패: ${res.error}');
        return;
      }
      final shop = SnowballShopResponse.fromJson(res.data!);
      if (url == null) {
        shopItems.assignAll(shop.items?.results ?? []);
        brandItems.assignAll(shop.brandItems ?? []);
        summary.value = shop.summary ?? [];
        isPremiumUser.value = shop.isPremiumUser ?? false;
      } else {
        shopItems.addAll(shop.items?.results ?? []);
      }
      _nextPageUrlShop.value = shop.items?.next ?? '';
    } catch (e) {
      debugPrint('[SnowballWeb] fetchShop 오류: $e');
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }

  Future<void> fetchNextPageShop() async {
    if (_nextPageUrlShop.value.isEmpty || isMoreLoading.value) return;
    await fetchShop(
      url: _nextPageUrlShop.value,
      isTierOnly: _lastIsTierOnly,
      isForMission: _lastIsForMission,
    );
  }

  /// 로딩 오버레이 없이 조용히 재조회(구매 직후 잔량/수량 갱신용).
  Future<void> refreshShopSilently() async {
    try {
      final res = await _api.fetchSnowballShop(
        userId: myUserId,
        eventDate: eventDate.value,
        isTierOnly: _lastIsTierOnly,
        isForMission: _lastIsForMission,
      );
      if (!res.success) return;
      final shop = SnowballShopResponse.fromJson(res.data!);
      shopItems.assignAll(shop.items?.results ?? []);
      brandItems.assignAll(shop.brandItems ?? []);
      summary.value = shop.summary ?? [];
      isPremiumUser.value = shop.isPremiumUser ?? false;
      _nextPageUrlShop.value = shop.items?.next ?? '';
    } catch (e) {
      debugPrint('[SnowballWeb] refreshShopSilently 오류: $e');
    }
  }

  Future<bool> purchaseItem(int snowballItemId) async {
    try {
      final res = await _api.purchaseSnowballItem({
        'user_id': myUserId,
        'snowball_item_id': snowballItemId,
        'event_date': eventDate.value,
      });
      if (res.success) {
        await Future.wait([refreshShopSilently(), fetchPurchaseHistory()]);
        return true;
      }
      debugPrint('[SnowballWeb] 구매 실패: ${res.error}');
      return false;
    } catch (e) {
      debugPrint('[SnowballWeb] purchaseItem 오류: $e');
      return false;
    }
  }

  // ------------------------ 구매 기록 ------------------------
  Future<void> fetchPurchaseHistory() async {
    try {
      final res = await _api.fetchSnowballBuyRecords({'user_id': myUserId});
      if (res.success) {
        final list = res.data?['snowball_buy_records'] ?? [];
        purchaseHistory.value = (list as List)
            .map<SnowballBuyRecord>((e) => SnowballBuyRecord.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('[SnowballWeb] fetchPurchaseHistory 오류: $e');
    }
  }

  // ------------------------ 미션 ------------------------
  Future<void> fetchMissionStatus() async {
    try {
      isLoading(true);
      final res = await _api.fetchSnowballMissionStatus({
        'user_id': myUserId,
        'event_date': eventDate.value,
      });
      if (res.success) {
        _missionStatus.value = MissionStatus.fromJson(res.data!);
      } else {
        debugPrint('[SnowballWeb] 미션 상태 실패: ${res.error}');
      }
    } catch (e) {
      debugPrint('[SnowballWeb] fetchMissionStatus 오류: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> applyMission(int snowballItemBrandId) async {
    try {
      isLoading(true);
      final res = await _api.applySnowballMission({
        'user_id': myUserId,
        'event_date': eventDate.value,
        'snowball_item_brand_id': snowballItemBrandId,
      });
      if (res.success) {
        await fetchMissionStatus();
      } else {
        debugPrint('[SnowballWeb] 미션 신청 실패: ${res.error}');
      }
    } catch (e) {
      debugPrint('[SnowballWeb] applyMission 오류: $e');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    _subMarket?.cancel();
    _subGold?.cancel();
    _subImages?.cancel();
    _subMarket = null;
    _subGold = null;
    _subImages = null;
    super.onClose();
  }
}
