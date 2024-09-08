import 'package:com.snowlive/controller/login/vm_notificationController.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketSearch.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketUpdate.dart';
import 'package:com.snowlive/viewmodel/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_friendDetailUpdate.dart';
import 'package:com.snowlive/viewmodel/vm_imageController.dart';
import 'package:com.snowlive/viewmodel/vm_login.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:com.snowlive/viewmodel/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_setProfile.dart';
import 'package:com.snowlive/viewmodel/vm_tos.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import '../viewmodel/vm_fleamarketDetail.dart';
import '../viewmodel/vm_fleamarketList.dart';
import '../viewmodel/vm_fleamarketUpload.dart';


class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainHomeViewModel(),permanent: true);
    Get.put(ResortHomeViewModel(),permanent: true);
    Get.put(FriendDetailViewModel(),permanent: true);
    Get.put(FleamarketListViewModel(),permanent: true);
    Get.put(FleamarketDetailViewModel(),permanent: true);
    Get.put(ImageController(),permanent: true);
  }
}

class ResortHomeBinding extends Bindings {
  @override
  void dependencies() {

  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginViewModel(),permanent: true);
    Get.put(NotificationController(),permanent: true);
  }
}

class TosBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TermsOfServiceViewModel());
  }
}

class SetProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SetProfileViewModel());
    Get.put(UserViewModel(), permanent: true);
  }
}

class FriendListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FriendDetailUpdateViewModel(),);
  }
}

class FriendDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FriendDetailViewModel(),);
  }
}

class FleamarketListBinding extends Bindings {
  @override
  void dependencies() {
  }
}

  class FleamarketSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FleamarketSearchViewModel());
  }

}

class FleamarketDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FleamarketCommentDetailViewModel(), permanent: true);

    Get.put(FleamarketUpdateViewModel(), );
  }
}
class FleamarketUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FleamarketUploadViewModel());
  }
}
