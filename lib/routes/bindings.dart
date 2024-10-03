import 'package:com.snowlive/viewmodel/community/vm_communityBulletinList.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityCommentDetail.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityDetail.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityUpdate.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityUpload.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewNotice.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
import 'package:com.snowlive/viewmodel/crew/vm_rankingCrewHistory.dart';
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
import 'package:com.snowlive/viewmodel/friend/vm_rankingIndivHistory.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_login.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_tos.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList_beta.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_alarmCenter.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_openChat.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_setGenderAndCategory.dart';
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
    Get.put(MainHomeViewModel());
    Get.put(AlarmCenterViewModel());
    Get.put(StreamController_Banner());
    Get.put(ResortHomeViewModel());
    Get.put(GenderCategoryViewModel());
    Get.put(ChatViewModel());
    Get.put(FriendDetailUpdateViewModel());
    Get.put(FleamarketListViewModel());
    Get.put(FleamarketDetailViewModel());
    Get.put(FleamarketUpdateViewModel());
    Get.put(ImageController());
    Get.put(FriendListViewModel());
    Get.put(RankingListViewModel());
    Get.put(CommunityBulletinListViewModel());
    Get.put(CommunityDetailViewModel());
    Get.put(CrewMemberListViewModel());
    Get.put(CrewNoticeViewModel());
    Get.put(CrewApplyViewModel());
    Get.put(SearchCrewViewModel());
    Get.put(CrewDetailViewModel());
    Get.put(SetCrewViewModel());
    Get.put(RankingListBetaViewModel());
    Get.put(CrewRecordRoomViewModel());
    Get.put(RankingCrewHistoryViewModel());

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

class CrewRecordRoomBinding extends Bindings {
  @override
  void dependencies() {

  }
}

class IndivHistoryHome extends Bindings {
  @override
  void dependencies() {
    Get.put(RankingIndivHistoryViewModel());
  }
}

class Setting_moreTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginViewModel());
  }
}

