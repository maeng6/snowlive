import 'package:com.snowlive/api/api_alarmcenter..dart';
import 'package:com.snowlive/model/m_alarmCenterList.dart';
import 'package:get/get.dart';

class AlarmCenterViewModel extends GetxController {
  var isLoading = false.obs;
  var _alarmCenterList = <AlarmCenterModel>[].obs;
  var _deleteSuccess = false.obs;
  var _updateSuccess = false.obs;

  List<AlarmCenterModel> get alarmCenterList => _alarmCenterList;
  bool get deleteSuccess => _deleteSuccess.value;
  bool get updateSuccess => _updateSuccess.value;

  @override
  void onInit() {
    super.onInit();
  }

  // 알람 센터 리스트 불러오기
  Future<void> fetchAlarmCenterList(int userId, {int? alarminfoId}) async {
    isLoading(true);
    try {
      final response = await AlarmCenterAPI().fetchAlarmCenterList(userId: userId, alarminfoId: alarminfoId);

      if (response.success && response.data != null) {
        // 데이터를 AlarmCenterModel 리스트로 변환
        final List<dynamic> dataList = response.data as List<dynamic>;
        _alarmCenterList.value = dataList.map((data) => AlarmCenterModel.fromJson(data)).toList();
      } else {
        _alarmCenterList.value = []; // 빈 리스트로 처리
        print('알람 센터 리스트 불러오기 실패: ${response.error}');
      }
    } catch (e) {
      print('Error fetching alarm center list: $e');
    }
    isLoading(false);
  }

  // 알람 센터 삭제
  Future<void> deleteAlarmCenter(int alarmCenterId) async {
    isLoading(true);
    try {
      final response = await AlarmCenterAPI().deleteAlarmCenter(alarmCenterId);

      if (response.success) {
        _deleteSuccess.value = true;
        print("알람 센터 삭제 성공");
        // 삭제 후 알람 센터 리스트를 다시 불러올 수 있음
      } else {
        _deleteSuccess.value = false;
        print("알람 센터 삭제 실패: ${response.error}");
      }
    } catch (e) {
      print("Error deleting alarm center: $e");
      _deleteSuccess.value = false;
    }
    isLoading(false);
  }

  // 알람 센터 수정
  Future<void> updateAlarmCenter(int alarmCenterId, Map<String, dynamic> body) async {
    isLoading(true);
    try {
      final response = await AlarmCenterAPI().updateAlarmCenter(alarmCenterId, body);

      if (response.success) {
        _updateSuccess.value = true;
        print("알람 센터 수정 성공");
        // 수정 후 알람 센터 리스트를 다시 불러올 수 있음
      } else {
        _updateSuccess.value = false;
        print("알람 센터 수정 실패: ${response.error}");
      }
    } catch (e) {
      print("Error updating alarm center: $e");
      _updateSuccess.value = false;
    }
    isLoading(false);
  }
}
