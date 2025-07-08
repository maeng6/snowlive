
// ✅ 추후 SnowballAPI 추가 메서드와 통합
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/api_snowball.dart';
import 'package:com.snowlive/model/m_snowball.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class SnowballShopViewModel extends GetxController {
  var isLoading = false.obs;
  var _isLodaing_entrance = false.obs;

  bool get loadingEntrance => _isLodaing_entrance.value;
  set loadingEntrance(bool value) => _isLodaing_entrance.value = value;

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  var snowballSummary = SnowballSummary().obs;
  var goldShopItems = <SnowballShopItem>[].obs;
  var whiteShopItems = <SnowballShopItem>[].obs;
  var sponsors = <SnowballSponsor>[].obs;
  var purchaseHistory = <SnowballBuyRecord>[].obs;
  var userSnowballRecords = <SnowballRecord>[].obs;

  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_snowballShop = Rxn();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_snowballShop_entrance = Rxn();
  Rxn<Stream<DocumentSnapshot<Map<String, dynamic>>>> infoStream_snowballShop_notice_gold = Rxn();

  var selectedItem = SnowballShopItem().obs;

  @override
  void onInit() {
    super.onInit();
    fetchSnowballShopData();
  }

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

  Future<void> fetchSnowballShopData() async {
    try {
      isLoading(true);
      int userId = _userViewModel.user.user_id;

      final response = await SnowballAPI().fetchSnowballHome({'user_id': userId});
      if (response.success) {
        final data = SnowballHomeResponse.fromJson(response.data!);
        snowballSummary.value = data.summary!;
        goldShopItems.value = data.goldshop!;
        whiteShopItems.value = data.whiteshop!;
        sponsors.value = data.sponsor!;
      } else {
        print("Failed to fetch snowball shop data: \${response.error}");
      }
    } catch (e) {
      print("Error fetching snowball shop data: \$e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSnowballSummary() async {
    try {
      isLoading(true);
      int userId = _userViewModel.user.user_id;

      final response = await SnowballAPI().fetchSnowballSummary({'user_id': userId});
      if (response.success) {
        snowballSummary.value = SnowballSummary.fromJson(response.data!);
      } else {
        print("Failed to fetch snowball summary: \${response.error}");
      }
    } catch (e) {
      print("Error fetching snowball summary: \$e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> purchaseSnowballItem({
    required int snowballItemId,
    required String address,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      isLoading(true);
      int userId = _userViewModel.user.user_id;

      final response = await SnowballAPI().purchaseSnowballItem({
        'user_id': userId,
        'snowball_item_id': snowballItemId,
        'address': address,
        'name': name,
        'phone_number': phoneNumber,
      });

      if (response.success) {
        fetchSnowballShopData();
      } else {
        print("Failed to purchase item: \${response.error}");
      }
    } catch (e) {
      print("Error purchasing item: \$e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPurchaseHistory() async {
    try {
      isLoading(true);
      int userId = _userViewModel.user.user_id;

      final response = await SnowballAPI().fetchSnowballBuyRecords({'user_id': userId});
      if (response.success) {
        final List<dynamic> records = response.data?['snowball_buy_records'] ?? [];
        purchaseHistory.value = records
            .map((record) => SnowballBuyRecord.fromJson(record as Map<String, dynamic>))
            .toList();
      } else {
        print("Failed to fetch purchase history: \${response.error}");
      }
    } catch (e) {
      print("Error fetching purchase history: \$e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchUserSnowballRecords() async {
    try {
      isLoading(true);
      int userId = _userViewModel.user.user_id;

      final response = await SnowballAPI().fetchUserSnowballRecords({'user_id': userId});
      if (response.success) {
        userSnowballRecords.value = (response.data as List)
            .map((record) => SnowballRecord.fromJson(record))
            .toList();
      } else {
        print("Failed to fetch user snowball records: \${response.error}");
      }
    } catch (e) {
      print("Error fetching user snowball records: \$e");
    } finally {
      isLoading(false);
    }
  }

  void selectItem(SnowballShopItem item) {
    selectedItem.value = item;
  }
}
