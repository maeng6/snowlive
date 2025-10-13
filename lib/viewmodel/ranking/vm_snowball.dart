import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/api_snowball.dart';
import 'package:com.snowlive/model/m_snowball.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class SnowballShopViewModel extends GetxController {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final _api = SnowballAPI();

  // ------------------------
  // UI 상태
  // ------------------------
  var isLoading = false.obs;

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

  // ------------------------
  // 홈/상점/구매/기록 상태
  // ------------------------
  var summary = <SnowballKindRemain>[].obs;     // 남은 눈송이 요약
  var homeRecords = <SnowballRecord>[].obs;     // 홈: 눈송이 획득 기록
  var sponsors = <SnowballSponsor>[].obs;       // 홈: 스폰서

  var shopItems = <SnowballShopItem>[].obs;     // 상점 아이템 (필터 반영)
  var purchaseHistory = <SnowballBuyRecord>[].obs;
  var userSnowballRecords = <SnowballRecord>[].obs;

  var selectedItem = SnowballShopItem().obs;

  // Firebase 공지/배너 스트림
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_snowballShop = Rxn();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_snowballShop_entrance = Rxn();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_snowballShop_notice_gold = Rxn();

  @override
  void onInit() {
    super.onInit();
    // 진입 시 홈 데이터와 상점 기본 목록 로딩
    fetchSnowballHomeData();
    fetchSnowballShop(); // 기본필터 없음
  }

  // ------------------------
  // Firestore Streams
  // ------------------------
  Future<void> getInfo_snowballMarket_entrance() async {
    infoStream_snowballShop_entrance.value = FirebaseFirestore.instance
        .collection('snowball_market')
        .doc('snowball_market')
        .snapshots();
  }

  Future<void> getInfo_snowballMarket() async {
    infoStream_snowballShop.value = FirebaseFirestore.instance
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

  // ------------------------
  // 홈 데이터 (summary + records + sponsor)
  // POST /snowball-home/ { user_id, event_date }
  // ------------------------
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

  // ------------------------
  // 상점 목록 (필터 옵션)
  // POST /snowball-shop/ { user_id, event_date, is_tier_only?, is_for_mission? }
  // ------------------------
  Future<void> fetchSnowballShop({bool? isTierOnly, bool? isForMission}) async {
    try {
      isLoading(true);
      final userId = _userViewModel.user.user_id;
      final body = {
        'user_id': userId,
        'event_date': eventDate.value,
        if (isTierOnly != null) 'is_tier_only': isTierOnly,
        if (isForMission != null) 'is_for_mission': isForMission,
      };

      final response = await _api.fetchSnowballShop(body);
      if (response.success) {
        final shop = SnowballShopResponse.fromJson(response.data!);
        // 상점 summary도 동일 포맷이므로 병행 업데이트 가능
        summary.value = shop.summary ?? [];
        shopItems.value = shop.items ?? [];
      } else {
        print("Failed to fetch shop: ${response.error}");
      }
    } catch (e) {
      print("Error fetchSnowballShop: $e");
    } finally {
      isLoading(false);
    }
  }

  // ------------------------
  // 남은 눈송이 요약만 갱신
  // POST /snowball-summary/ { user_id, event_date }
  // 응답: List<Map(kind, remaining)>
  // ------------------------
  Future<void> fetchSnowballSummaryOnly() async {
    try {
      isLoading(true);
      final userId = _userViewModel.user.user_id;
      final body = {
        'user_id': userId,
        'event_date': eventDate.value,
      };

      final response = await _api.fetchSnowballSummary(body);
      if (response.success) {
        final list = (response.data as List)
            .map((e) => SnowballKindRemain.fromJson(e))
            .toList();
        summary.value = list;
      } else {
        print("Failed to fetch summary: ${response.error}");
      }
    } catch (e) {
      print("Error fetchSnowballSummaryOnly: $e");
    } finally {
      isLoading(false);
    }
  }

  // ------------------------
  // 아이템 구매
  // POST /snowball-item-purchase/ { user_id, snowball_item_id, event_date }
  // ------------------------
  Future<void> purchaseSnowballItem({
    required int snowballItemId,
  }) async {
    try {
      isLoading(true);
      final userId = _userViewModel.user.user_id;

      final response = await _api.purchaseSnowballItem({
        'user_id': userId,
        'snowball_item_id': snowballItemId,
        'event_date': eventDate.value,
      });

      if (response.success) {
        // 구매 성공 시 홈/상점/구매내역 새로 고침
        await Future.wait([
          fetchSnowballHomeData(),
          fetchSnowballShop(),
          fetchPurchaseHistory(),
        ]);
      } else {
        print("Failed to purchase item: ${response.error}");
      }
    } catch (e) {
      print("Error purchasing item: $e");
    } finally {
      isLoading(false);
    }
  }

  // ------------------------
  // 구매 기록
  // POST /snowball-buy-record/ { user_id }
  // ------------------------
  Future<void> fetchPurchaseHistory() async {
    try {
      isLoading(true);
      final userId = _userViewModel.user.user_id;

      final response = await _api.fetchSnowballBuyRecords({'user_id': userId});
      if (response.success) {
        final List<dynamic> records = response.data?['snowball_buy_records'] ?? [];
        purchaseHistory.value =
            records.map((e) => SnowballBuyRecord.fromJson(e)).toList();
      } else {
        print("Failed to fetch purchase history: ${response.error}");
      }
    } catch (e) {
      print("Error fetching purchase history: $e");
    } finally {
      isLoading(false);
    }
  }

  // ------------------------
  // 내 눈송이 기록
  // POST /user-snowball-record/ { user_id, event_date }
  // ------------------------
  Future<void> fetchUserSnowballRecords() async {
    try {
      isLoading(true);
      final userId = _userViewModel.user.user_id;

      final response = await _api.fetchUserSnowballRecords({
        'user_id': userId,
        'event_date': eventDate.value,
      });
      if (response.success) {
        userSnowballRecords.value = (response.data as List)
            .map((e) => SnowballRecord.fromJson(e))
            .toList();
      } else {
        print("Failed to fetch user snowball records: ${response.error}");
      }
    } catch (e) {
      print("Error fetching user snowball records: $e");
    } finally {
      isLoading(false);
    }
  }

  // ------------------------
  // 선택 아이템
  // ------------------------
  void selectItem(SnowballShopItem item) {
    selectedItem.value = item;
  }

  // ------------------------
  // 미션 상태 확인
  // POST /snowball-mission-status/ { user_id, event_date }
  // ------------------------
  Future<void> fetchMissionStatus() async {
    try {
      isLoading(true);
      final userId = _userViewModel.user.user_id;

      final response = await _api.fetchSnowballMissionStatus({
        'user_id': userId,
        'event_date': eventDate.value,
      });

      if (response.success) {
        final missionData = MissionStatus.fromJson(response.data!);

        // 필요하면 상태 변수에 저장하도록 추가
        _missionStatus.value = missionData;

        // 혹은 바로 UI 업데이트용 print
        print("미션 상태 불러오기 성공: 전체완료=${missionData.completeTotal}");
      } else {
        print("미션 상태 요청 실패: ${response.error}");
      }
    } catch (e) {
      print("Error fetchMissionStatus: $e");
    } finally {
      isLoading(false);
    }
  }

  // ------------------------
  // 미션 신청
  // POST /snowball-mission-apply/ { user_id, event_date, Snowball_sponsor_id }
  // ------------------------
  Future<void> applyMission(int sponsorId) async {
    try {
      isLoading(true);
      final userId = _userViewModel.user.user_id;

      final response = await _api.applySnowballMission({
        'user_id': userId,
        'event_date': eventDate.value,
        'Snowball_sponsor_id': sponsorId,
      });

      if (response.success) {
        print("미션 신청 성공: ${response.data?['message'] ?? ''}");
        // 신청 후 다시 상태 갱신
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
