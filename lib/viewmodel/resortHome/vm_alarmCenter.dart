import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/api/api_alarmcenter..dart';
import 'package:com.snowlive/model/m_alarmCenterList.dart'; // AlarmCenterModel이 정의된 파일
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class AlarmCenterViewModel extends GetxController {
  var isLoading = false.obs;
  var _alarmCenterList = <AlarmCenterModel>[].obs;
  var _deleteSuccess = false.obs;
  var _updateSuccess = false.obs;

  List<AlarmCenterModel> get alarmCenterList => _alarmCenterList;
  bool get deleteSuccess => _deleteSuccess.value;
  bool get updateSuccess => _updateSuccess.value;

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();

  @override
  void onInit() async {
    super.onInit();
    await fetchAlarmCenterList(userId: _userViewModel.user.user_id);
  }

// 알람 센터 리스트 불러오기
  Future<void> fetchAlarmCenterList({required int userId, int? alarminfoId}) async {
    isLoading(true);
    try {
      final response = await AlarmCenterAPI().fetchAlarmCenterList(userId: userId, alarminfoId: alarminfoId);

      if (response.success && response.data != null) {
        // 응답 데이터가 Map<String, dynamic> 형태일 경우 처리
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseData = response.data;
          // results 리스트를 추출하여 AlarmCenterModel 리스트로 변환
          if (responseData['results'] != null) {
            final List<dynamic> resultsList = responseData['results'] as List<dynamic>;
            _alarmCenterList.value = resultsList.map((data) => AlarmCenterModel.fromJson(data)).toList();
          } else {
            _alarmCenterList.value = []; // results가 없을 경우 빈 리스트 처리
          }
          print('알람 센터 목록 불러오기 완료');
        } else {
          _alarmCenterList.value = [];
          print('알람 센터 목록 불러오기 실패: 응답 데이터가 리스트가 아님');
        }
      } else {
        _alarmCenterList.value = []; // 빈 리스트로 처리
        print('알람 센터 목록 불러오기 실패: ${response.error}');
      }
    } catch (e) {
      print('알람 센터 목록을 불러오는 중 오류 발생: $e');
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
        await fetchAlarmCenterList(userId: _userViewModel.user.user_id);
      } else {
        _deleteSuccess.value = false;
        print("알람 센터 삭제 실패: ${response.error}");
      }
    } catch (e) {
      print("알람 센터 삭제 중 오류 발생: $e");
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
        await fetchAlarmCenterList(userId: _userViewModel.user.user_id);
      } else {
        _updateSuccess.value = false;
        print("알람 센터 수정 실패: ${response.error}");
      }
    } catch (e) {
      print("알람 센터 수정 중 오류 발생: $e");
      _updateSuccess.value = false;
    }
    isLoading(false);
  }

  // Firebase Firestore에서 알림 설정 업데이트
  Future<void> updateNotification(
      int uid, {
        bool? total,
        bool? friend,
        bool? crew,
      }) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notificationCenter')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot document = querySnapshot.docs.first;
        Map<String, dynamic> updateData = {};

        if (total != null) {
          updateData['total'] = total;
        }
        if (friend != null) {
          updateData['friend'] = friend;
        }
        if (crew != null) {
          updateData['crew'] = crew;
        }
        if (updateData.isNotEmpty) {
          await document.reference.update(updateData);
          print('알림 필드 업데이트 완료');
        }
      } else {
        await FirebaseFirestore.instance.collection('notificationCenter').add({
          'uid': uid,
          'total': total ?? false, // 기본값 false
          'friend': friend ?? false,
          'crew': crew ?? false,
        });
        print('문서 생성 및 필드 설정 완료');
      }
    } catch (e) {
      print('문서 업데이트 또는 생성 중 오류 발생: $e');
    }
  }
}
