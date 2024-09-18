import 'package:com.snowlive/controller/login/vm_notificationController.dart';
import 'package:com.snowlive/viewmodel/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/vm_crewMain.dart';
import 'package:com.snowlive/viewmodel/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketSearch.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketUpdate.dart';
import 'package:com.snowlive/viewmodel/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_friendDetailUpdate.dart';
import 'package:com.snowlive/viewmodel/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/vm_imageController.dart';
import 'package:com.snowlive/viewmodel/vm_login.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:com.snowlive/viewmodel/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_setCrew.dart';
import 'package:com.snowlive/viewmodel/vm_setProfile.dart';
import 'package:com.snowlive/viewmodel/vm_tos.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import '../viewmodel/vm_communityBulletinList.dart';
import '../viewmodel/vm_communityCommentDetail.dart';
import '../viewmodel/vm_communityDetail.dart';
import '../viewmodel/vm_communityUpdate.dart';
import '../viewmodel/vm_communityUpload.dart';
import '../viewmodel/vm_fleamarketDetail.dart';
import '../viewmodel/vm_fleamarketList.dart';
import '../viewmodel/vm_fleamarketUpload.dart';
import '../viewmodel/vm_rankingList.dart';


class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainHomeViewModel(),permanent: true);
    Get.put(ResortHomeViewModel(),permanent: true);
    Get.put(FriendDetailViewModel(),permanent: true);
    Get.put(FleamarketListViewModel(),permanent: true);
    Get.put(FleamarketDetailViewModel(),permanent: true);
    Get.put(ImageController(),permanent: true);
    Get.put(FriendListViewModel(),permanent: true);
    Get.put(CommunityBulletinListViewModel(),permanent: true);
    Get.put(CommunityDetailViewModel(),permanent: true);
    Get.put(CrewMainViewModel(), permanent: true);
    Get.put(CrewDetailViewModel(), permanent: true);
    Get.put(CrewMemberListViewModel(), permanent: true);
    Get.put(RankingListViewModel(), permanent: true);

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

class SearchFriendViewBinding extends Bindings {
  @override
  void dependencies() {
  }
}

class BulletinUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CommunityUploadViewModel());
  }
}

class BulletinDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CommunityCommentDetailViewModel());
    Get.put(CommunityUpdateViewModel());
  }
}

class MoreTabMainBinding extends Bindings {
  @override
  void dependencies() {

  }
}

class OnBoardingCrewMainBinding extends Bindings {
  @override
  void dependencies() {

  }
}

class SetCrewNameAndResortBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SetCrewViewModel());
  }
}

class CrewMainBinding extends Bindings {
  @override
  void dependencies() {
  }
}

class CrewHomeBinding extends Bindings {
  @override
  void dependencies() {
  }
}

