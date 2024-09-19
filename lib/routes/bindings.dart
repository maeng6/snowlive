import 'package:com.snowlive/viewmodel/community/vm_communityBulletinList.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityCommentDetail.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityDetail.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityUpdate.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityUpload.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMain.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
import 'package:com.snowlive/viewmodel/crew/vm_searchCrew.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketSearch.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketUpdate.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketUpload.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetailUpdate.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_login.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_tos.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_stramController_resortHome.dart';
import 'package:com.snowlive/viewmodel/util/vm_imageController.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/crew/vm_setCrew.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_setProfile.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_streamController_banner.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';


class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainHomeViewModel(),permanent: true);
    Get.put(StreamController_Banner(),permanent: true);
    Get.put(ResortHomeViewModel(),permanent: true);
    Get.put(StreamController_ResortHome(),permanent: true);
    Get.put(FriendDetailViewModel(),permanent: true);
    Get.put(FleamarketListViewModel(),permanent: true);
    Get.put(FleamarketDetailViewModel(),permanent: true);
    Get.put(FleamarketUpdateViewModel(),permanent: true);
    Get.put(ImageController(),permanent: true);
    Get.put(FriendListViewModel(),permanent: true);
    Get.put(RankingListViewModel(), permanent: true);
    Get.put(CommunityBulletinListViewModel(),permanent: true);
    Get.put(CommunityDetailViewModel(),permanent: true);
    Get.put(SearchCrewViewModel(), permanent: true);
    Get.put(CrewMainViewModel(), permanent: true);
    Get.put(CrewDetailViewModel(), permanent: true);
    Get.put(CrewMemberListViewModel(), permanent: true);

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
    Get.put(CrewRecordRoomViewModel());
  }
}

class CrewHomeBinding extends Bindings {
  @override
  void dependencies() {
  }
}

class CrewRecordRoomBinding extends Bindings {
  @override
  void dependencies() {
  }
}

