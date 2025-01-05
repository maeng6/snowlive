import 'package:com.snowlive/api/api_snowball.dart';
import 'package:com.snowlive/model/m_snowball.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class SnowballShopViewModel extends GetxController {
  // API 호출 상태 관리
  var isLoading = false.obs;

  // 유저 정보
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  // 눈송이 상점 관련 데이터
  var snowballSummary = SnowballSummary().obs;
  var goldShopItems = <SnowballShopItem>[].obs;
  var whiteShopItems = <SnowballShopItem>[].obs;
  var sponsors = <SnowballSponsor>[].obs;
  var purchaseHistory = <SnowballBuyRecord>[].obs;
  var userSnowballRecords = <SnowballRecord>[].obs; // 추가된 필드

  // 현재 선택된 아이템 정보
  var selectedItem = SnowballShopItem().obs;

  // 초기화
  @override
  void onInit() {
    super.onInit();
    fetchSnowballSummary();
  }

  /// 눈송이 상점 데이터 가져오기(눈송이 홈)
  Future<void> fetchSnowballShopData() async {
    try {
      isLoading(true);
      int userId = _userViewModel.user.user_id;

      // API 호출
      final response = await SnowballAPI().fetchSnowballHome({'user_id': userId});
      if (response.success) {
        final data = SnowballHomeResponse.fromJson(response.data!);
        snowballSummary.value = data.summary!;
        goldShopItems.value = data.goldshop!;
        whiteShopItems.value = data.whiteshop!;
        sponsors.value = data.sponsor!;
      } else {
        print("Failed to fetch snowball shop data: ${response.error}");
      }
    } catch (e) {
      print("Error fetching snowball shop data: $e");
    } finally {
      isLoading(false);
    }
  }

  /// 눈송이 기록 생성
  Future<void> createSnowballRecord(Map<String, dynamic> body) async {
    try {
      isLoading(true);

      // API 호출
      final response = await SnowballAPI().createSnowballRecord(body);
      if (response.success) {
        print("Snowball record created successfully: ${response.data}");
      } else {
        print("Failed to create snowball record: ${response.error}");
      }
    } catch (e) {
      print("Error creating snowball record: $e");
    } finally {
      isLoading(false);
    }
  }

  /// 랭킹탭 상단의 획득 눈송이 갯수 보여주는 메서드
  Future<void> fetchSnowballSummary() async {
    try {
      isLoading(true);
      int userId = _userViewModel.user.user_id;

      // API 호출
      final response = await SnowballAPI().fetchSnowballSummary({'user_id': userId});
      if (response.success) {
        print("Snowball summary fetched successfully: ${response.data}");
        // summary 데이터를 snowballSummary에 업데이트
        snowballSummary.value = SnowballSummary.fromJson(response.data!);
      } else {
        print("Failed to fetch snowball summary: ${response.error}");
      }
    } catch (e) {
      print("Error fetching snowball summary: $e");
    } finally {
      isLoading(false);
    }
  }

  /// 아이템 구매버튼 누르면 실행되는 메서드
  Future<void> purchaseSnowballItem({
    required int snowballItemId,
    required String address,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      isLoading(true);
      int userId = _userViewModel.user.user_id;

      // API 호출
      final response = await SnowballAPI().purchaseSnowballItem({
        'user_id': userId,
        'snowball_item_id': snowballItemId,
        'address': address,
        'name': name,
        'phone_number': phoneNumber,
      });

      if (response.success) {
        print("Purchase successful");
        fetchSnowballShopData(); // 데이터 갱신
      } else {
        // 서버에서 반환된 에러 메시지에 따라 처리
        if (response.error?.contains("하얀 눈송이가 모자랍니다.") ?? false) {
          print("Error: 하얀 눈송이가 부족해요.");
        } else if (response.error?.contains("황금 눈송이가 모자랍니다.") ?? false) {
          print("Error: 황금 눈송이가 부족해요.");
        } else {
          print("Failed to purchase item: ${response.error}");
        }
      }
    } catch (e) {
      print("Error purchasing item: $e");
    } finally {
      isLoading(false);
    }
  }

  /// 아이템 구매 내역 가져오기
  Future<void> fetchPurchaseHistory() async {
    try {
      isLoading(true);
      int userId = _userViewModel.user.user_id;

      // API 호출
      final response = await SnowballAPI().fetchSnowballBuyRecords({'user_id': userId});
      if (response.success) {
        print("Purchase history fetched successfully: ${response.data}");
        // 구매 내역 데이터를 purchaseHistory에 업데이트
        purchaseHistory.value = (response.data as List)
            .map((record) => SnowballBuyRecord.fromJson(record))
            .toList();
      } else {
        print("Failed to fetch purchase history: ${response.error}");
      }
    } catch (e) {
      print("Error fetching purchase history: $e");
    } finally {
      isLoading(false);
    }
  }

  /// 특정 user_id의 눈송이 기록 가져오기
  Future<void> fetchUserSnowballRecords() async {
    try {
      isLoading(true);
      int userId = _userViewModel.user.user_id;

      // API 호출
      final response = await SnowballAPI().fetchUserSnowballRecords({'user_id': userId});
      if (response.success) {
        print("User snowball records fetched successfully: ${response.data}");
        userSnowballRecords.value = (response.data as List)
            .map((record) => SnowballRecord.fromJson(record))
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



  /// 아이템 누르면 아이템 정보를 모델에 할당.(구매버튼 누르면 이 아이템의 id를 api에 보내려는 목적)
  void selectItem(SnowballShopItem item) {
    selectedItem.value = item;
  }
}
