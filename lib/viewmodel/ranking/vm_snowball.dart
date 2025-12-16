import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/api_snowball.dart';
import 'package:com.snowlive/model/m_snowball.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SnowballShopViewModel extends GetxController {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final _api = SnowballAPI();

  // ------------------------
  // UI 상태
  // ------------------------
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var isLoading_fetchSnowballShopData = false.obs;
  var isLoading_fetchPurchageHistoryOnly = false.obs;


  // (오탈자 유지 대신 명시적 getter/setter 유지)
  var _isLodaing_entrance = false.obs;
  bool get loadingEntrance => _isLodaing_entrance.value;
  set loadingEntrance(bool value) => _isLodaing_entrance.value = value;

  // ------------------------
  // 이벤트 날짜 상태 (필수)
  // 예: 1, 2, 3 ...
  // ------------------------
  final RxInt eventDate = 1.obs; // 필요 시 외부에서 setEventDate(..)로 갱신

  void setEventDate(int v) {
    eventDate.value = v;
  }

  // 미션 상태 저장용 (선택적)
  var _missionStatus = MissionStatus().obs;
  MissionStatus get missionStatus => _missionStatus.value;

  List<MapEntry<String, MissionPiece>> get missionEntriesSorted =>
      missionStatus.entriesSorted;

  String missionTitle(String id) => missionStatus.titleOf(id);

  bool missionComplete(String id) => missionStatus.isComplete(id);

  // ------------------------
  // 데이터 저장소
  // ------------------------
  var summary = <SnowballKindRemain>[].obs;
  var homeRecords = <SnowballRecord>[].obs;
  var sponsors = <SnowballSponsor>[].obs;

  var shopItems = <SnowballShopItem>[].obs;   // UI가 보는 리스트
  var brandItems = <SnowballShopItem>[].obs;  // UI가 보는 리스트
  var purchaseHistory = <SnowballBuyRecord>[].obs;
  var userSnowballRecords = <SnowballRecord>[].obs;
  var isPremiumUser = false.obs;

  var selectedItem = SnowballShopItem().obs;

  // ------------------------
  // 내부 저장소 (랭킹 방식 동일)
  // ------------------------
  var _shopList = <SnowballShopItem>[].obs;
  var _brandList = <SnowballShopItem>[].obs;

  var _nextPageUrl_shop = ''.obs;

  String get nextPageUrlShop => _nextPageUrl_shop.value;
  bool get hasMore => _nextPageUrl_shop.value.isNotEmpty;

  bool? lastIsTierOnly;
  bool? lastIsForMission;

  // ------------------------
  // Firestore Streams
  // ------------------------
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_snowballShop = Rxn();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_snowballShop_entrance = Rxn();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_snowballShop_entrance_ranking = Rxn();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_snowballShop_notice_gold = Rxn();

  @override
  Future<void> onInit() async {
    super.onInit();
    await getInfo_snowballMarket();
    await getInfo_snowballMarket_entrance();
  }

  // ============================================================
  // Firestore 정보
  // ============================================================

  Future<void> getInfo_snowballMarket() async {
    infoStream_snowballShop.value = FirebaseFirestore.instance
        .collection('snowball_market')
        .doc('snowball_market')
        .snapshots();

    final doc = await FirebaseFirestore.instance
        .collection('snowball_market')
        .doc('snowball_market')
        .get();

    final eventDateInt = (doc.data()?['event_date'] as num?)?.toInt();
    if (eventDateInt != null) eventDate.value = eventDateInt;
  }

  Future<void> getInfo_snowballMarket_entrance() async {
    infoStream_snowballShop_entrance.value = FirebaseFirestore.instance
        .collection('snowball_market')
        .doc('snowball_market')
        .snapshots();
  }

  Future<void> getInfo_snowballMarket_entrance_ranking() async {
    infoStream_snowballShop_entrance_ranking.value = FirebaseFirestore.instance
        .collection('snowball_market')
        .doc('snowball_market')
        .snapshots();
  }



  Future<void> getInfo_snowballMarket_notice_gold() async {
    infoStream_snowballShop_notice_gold.value = FirebaseFirestore.instance
        .collection('snowball_market')
        .doc('gold_snowball_notice')
        .snapshots();
  }

  // ============================================================
  // 홈 데이터
  // ============================================================

  Future<void> fetchSnowballHomeData() async {
    try {
      isLoading(true);

      final userId = _userViewModel.user.user_id;
      final body = {
        'user_id': userId,
        'event_date': eventDate.value,
      };

      final response = await _api.fetchSnowballHome(body);
      if (response.success) {
        final data = SnowballHomeResponse.fromJson(response.data!);
        summary.value = data.summary ?? [];
        homeRecords.value = data.records ?? [];
        sponsors.value = data.sponsor ?? [];
      } else {
        print("Failed to fetch home: ${response.error}");
      }
    } catch (e) {
      print("Error fetchSnowballHomeData: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSnowballHomeDataExchange() async {
    try {

      final userId = _userViewModel.user.user_id;
      final body = {
        'user_id': userId,
        'event_date': eventDate.value,
      };

      final response = await _api.fetchSnowballHome(body);
      if (response.success) {
        final data = SnowballHomeResponse.fromJson(response.data!);
        summary.value = data.summary ?? [];
        homeRecords.value = data.records ?? [];
        sponsors.value = data.sponsor ?? [];
      } else {
        print("Failed to fetch home: ${response.error}");
      }
    } catch (e) {
      print("Error fetchSnowballHomeData: $e");
    } finally {
    }
  }


  // ============================================================
  // ⭐⭐ 상점 조회 (랭킹 방식 동일)
  // ============================================================

  Future<void> fetchSnowballShop({
    bool? isTierOnly,
    bool? isForMission,
    String? url, // null → 첫 페이지, not null → 다음 페이지
  }) async {
    print('fetchSnowballShop 시작');

    try {
      if (url == null) {
        isLoading(true);
      } else {
        isMoreLoading(true);
      }

      lastIsTierOnly = isTierOnly;
      lastIsForMission = isForMission;

      final userId = _userViewModel.user.user_id;

      final response = await _api.fetchSnowballShop(
        userId: userId,
        eventDate: eventDate.value,
        isTierOnly: isTierOnly,
        isForMission: isForMission,
        url: url,
      );

      if (!response.success) {
        print('❌ fetchSnowballShop 실패: ${response.error}');
        return;
      }

      final shop = SnowballShopResponse.fromJson(response.data!);

      // ⭐ 첫 페이지
      if (url == null) {
        _shopList.value = shop.items?.results ?? [];
        _brandList.value = shop.brandItems ?? [];

        summary.value = shop.summary ?? [];
        isPremiumUser.value = shop.isPremiumUser ?? false;

        // UI 반영
        shopItems.assignAll(_shopList);
        brandItems.assignAll(_brandList);
      }

      // ⭐ 다음 페이지
      else {
        _shopList.addAll(shop.items?.results ?? []);

        // UI 반영
        shopItems.assignAll(_shopList);
      }

      _nextPageUrl_shop.value = shop.items?.next ?? '';

    } catch (e) {
      print('❌ Error fetchSnowballShop: $e');
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }

    print('fetchSnowballShop 끝');
  }

  Future<void> fetchSnowballShopExchange({
    bool? isTierOnly,
    bool? isForMission,
    String? url, // null → 첫 페이지, not null → 다음 페이지
  }) async {
    print('fetchSnowballShop 시작');

    try {

      lastIsTierOnly = isTierOnly;
      lastIsForMission = isForMission;

      final userId = _userViewModel.user.user_id;

      final response = await _api.fetchSnowballShop(
        userId: userId,
        eventDate: eventDate.value,
        isTierOnly: isTierOnly,
        isForMission: isForMission,
        url: url,
      );

      if (!response.success) {
        print('❌ fetchSnowballShop 실패: ${response.error}');
        return;
      }

      final shop = SnowballShopResponse.fromJson(response.data!);

      // ⭐ 첫 페이지
      if (url == null) {
        _shopList.value = shop.items?.results ?? [];
        _brandList.value = shop.brandItems ?? [];

        summary.value = shop.summary ?? [];
        isPremiumUser.value = shop.isPremiumUser ?? false;

        // UI 반영
        shopItems.assignAll(_shopList);
        brandItems.assignAll(_brandList);
      }

      // ⭐ 다음 페이지
      else {
        _shopList.addAll(shop.items?.results ?? []);

        // UI 반영
        shopItems.assignAll(_shopList);
      }

      _nextPageUrl_shop.value = shop.items?.next ?? '';

    } catch (e) {
      print('❌ Error fetchSnowballShop: $e');
    } finally {
    }

    print('fetchSnowballShop 끝');
  }

  // ⭐ 다음 페이지 (랭킹과 동일)
  Future<void> fetchNextPageSnowballShop() async {
    if (_nextPageUrl_shop.value.isEmpty) return;

    print('fetchNextPageSnowballShop 시작');

    await fetchSnowballShop(
      url: _nextPageUrl_shop.value,
      isTierOnly: lastIsTierOnly,
      isForMission: lastIsForMission,
    );
    print('fetchNextPageSnowballShop 끝');
  }

  // ⭐ 탭 눌렀을 때 (초기화 후 첫 페이지)
  // Future<void> fetchSnowballShopTapTheList({bool? isTierOnly, bool? isForMission}) async {
  //   try {
  //     isLoading_fetchSnowballShopData(true);
  //     final userId = _userViewModel.user.user_id;
  //
  //     final body = {
  //       'user_id': userId,
  //       'event_date': eventDate.value,
  //       if (isTierOnly != null) 'is_tier_only': isTierOnly,
  //       if (isForMission != null) 'is_for_mission': isForMission,
  //     };
  //
  //     final response = await _api.fetchSnowballShop(
  //       userId: userId,
  //       eventDate: eventDate.value,
  //       isTierOnly: isTierOnly,
  //       isForMission: isForMission,
  //     );
  //     if (response.success) {
  //       final shop = SnowballShopResponse.fromJson(response.data!);
  //
  //       // 요약, 일반 아이템
  //       summary.value = shop.summary ?? [];
  //
  //       // ✅ 프리미엄 여부
  //       isPremiumUser.value = shop.isPremiumUser ?? false;
  //
  //       // ✅ 브랜드 아이템 (미션일 때만 내려오므로 null 체크)
  //       if (shop.brandItems != null) {
  //         brandItems.value = shop.brandItems!;
  //       } else {
  //         brandItems.clear();
  //       }
  //     } else {
  //       print("Failed to fetch shop: ${response.error}");
  //       shopItems.clear();
  //       brandItems.clear();
  //       isPremiumUser.value = false;
  //     }
  //   } catch (e) {
  //     print("Error fetchSnowballShop: $e");
  //     shopItems.clear();
  //     brandItems.clear();
  //     isPremiumUser.value = false;
  //   } finally {
  //     isLoading_fetchSnowballShopData(false);
  //   }
  // }

  // ============================================================
  // 요약만 갱신
  // ============================================================

  Future<void> fetchSnowballSummaryOnly() async {
    try {
      isLoading(true);

      final userId = _userViewModel.user.user_id;
      final response = await _api.fetchSnowballSummary({
        'user_id': userId,
        'event_date': eventDate.value,
      });

      if (response.success) {
        final list = (response.data as List)
            .map((e) => SnowballKindRemain.fromJson(e))
            .toList();
        summary.value = list;
      }
    } catch (e) {
      print("Error fetchSnowballSummaryOnly: $e");
    } finally {
      isLoading(false);
    }
  }

  // ============================================================
  // 구매
  // ============================================================

  Future<bool> purchaseSnowballItem({required int snowballItemId}) async {
    try {

      final userId = _userViewModel.user.user_id;

      final response = await _api.purchaseSnowballItem({
        'user_id': userId,
        'snowball_item_id': snowballItemId,
        'event_date': eventDate.value,
      });

      if (response.success) {
        await Future.wait([
          fetchSnowballHomeDataExchange(),
          fetchPurchaseHistoryOnly(),
        ]);
        return true;
      } else {
        print("❌ Failed to purchase: ${response.error}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error purchase: $e");
      return false;
    } finally {
    }
  }

  // ============================================================
  // 구매 기록
  // ============================================================

  Future<void> fetchPurchaseHistory() async {
    try {
      isLoading(true);

      final userId = _userViewModel.user.user_id;
      final response = await _api.fetchSnowballBuyRecords({'user_id': userId});

      if (response.success) {
        final list = response.data?['snowball_buy_records'] ?? [];
        purchaseHistory.value =
            list.map<SnowballBuyRecord>((e) => SnowballBuyRecord.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetchPurchaseHistory: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPurchaseHistoryOnly() async {
    try {
      isLoading_fetchPurchageHistoryOnly(true);

      final userId = _userViewModel.user.user_id;
      final response = await _api.fetchSnowballBuyRecords({'user_id': userId});

      if (response.success) {
        final list = response.data?['snowball_buy_records'] ?? [];
        purchaseHistory.value =
            list.map<SnowballBuyRecord>((e) => SnowballBuyRecord.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetchPurchaseHistoryOnly: $e");
    } finally {
      isLoading_fetchPurchageHistoryOnly(false);
    }
  }

  // ============================================================
  // 유저 눈송이 기록
  // ============================================================

  Future<void> fetchUserSnowballRecords() async {
    try {
      isLoading(true);

      final userId = _userViewModel.user.user_id;
      final response = await _api.fetchUserSnowballRecords({
        'user_id': userId,
        'event_date': eventDate.value,
      });

      if (response.success) {
        userSnowballRecords.value =
            (response.data as List).map((e) => SnowballRecord.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetchUserSnowballRecords: $e");
    } finally {
      isLoading(false);
    }
  }

  // ============================================================
  // 선택 아이템
  // ============================================================

  void selectItem(SnowballShopItem item) {
    selectedItem.value = item;
  }

  // ============================================================
  // 미션 상태 조회
  // ============================================================

  Future<void> fetchMissionStatus() async {
    try {
      isLoading(true);

      final userId = _userViewModel.user.user_id;
      final response = await _api.fetchSnowballMissionStatus({
        'user_id': userId,
        'event_date': eventDate.value,
      });

      if (response.success) {
        _missionStatus.value = MissionStatus.fromJson(response.data!);
      } else {
        print("미션 상태 요청 실패: ${response.error}");
      }
    } catch (e) {
      print("Error fetchMissionStatus: $e");
    } finally {
      isLoading(false);
    }
  }

  // ============================================================
  // 미션 신청
  // ============================================================

  Future<void> applyMission(int snowballItemBrandId) async {
    try {
      isLoading(true);

      final userId = _userViewModel.user.user_id;
      final response = await _api.applySnowballMission({
        'user_id': userId,
        'event_date': eventDate.value,
        'snowball_item_brand_id': snowballItemBrandId,
      });

      if (response.success) {
        await fetchMissionStatus();
      } else {
        print("미션 신청 실패: ${response.error}");
      }
    } catch (e) {
      print("Error applyMission: $e");
    } finally {
      isLoading(false);
    }
  }
}

