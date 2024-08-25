import 'package:com.snowlive/api/api_user.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import '../api/ApiResponse.dart';
import '../model/m_user.dart';

class UserViewModel extends GetxController {
  var isLoading = true.obs;
  var _user = UserModel().obs;

  dynamic get user => _user.value;

  Future<void> updateUserModel_api(int user_id)  async{

    isLoading(true);
    ApiResponse response = await UserAPI().getUserInfo(user_id);
    if(response.success) {
      _user.value = UserModel.fromJson(response.data);
      print('updateUserModel_api 완료');
    }else {
      Get.snackbar('Error', '데이터 로딩 실패');
    }
    isLoading(false);
  }

  Future<void> updateUserModel_data(var data)  async{
      _user.value = UserModel.fromJson(data);
  }

}
