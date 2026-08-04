import 'package:com.snowlive/core/viewmodel/community/vm_communityAlarm.dart';
import 'package:com.snowlive/core/viewmodel/community/vm_communityBulletinList.dart';
import 'package:com.snowlive/core/viewmodel/community/vm_communityCommentDetail.dart';
import 'package:com.snowlive/core/viewmodel/community/vm_communityDetail.dart';
import 'package:com.snowlive/core/viewmodel/community/vm_communityUpdate.dart';
import 'package:com.snowlive/core/viewmodel/community/vm_communityUpload.dart';
import 'package:com.snowlive/core/viewmodel/liveTalk/vm_liveTalk.dart';
import 'package:com.snowlive/core/viewmodel/event/vm_event.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail_recordRoom.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_crewMemberRankingList.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_crewMemberRankingList_recordRoom.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewNotice.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
import 'package:com.snowlive/viewmodel/crew/vm_dailyRecord.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingCrewHistory.dart';
import 'package:com.snowlive/viewmodel/crew/vm_searchCrew.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketAlert.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketSearch.dart';
import 'package:com.snowlive/mobile/viewmodel/fleamarket/vm_fleamarketUpdate.dart';
import 'package:com.snowlive/mobile/viewmodel/fleamarket/vm_fleamarketUpload.dart';
import 'package:com.snowlive/viewmodel/forestPark/vm_forestPark.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetailUpdate.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail_recordRoom.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingIndivHistory.dart';
import 'package:com.snowlive/mobile/viewmodel/auth/vm_login.dart';
import 'package:com.snowlive/mobile/viewmodel/auth/vm_tos.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_beta.dart';
import 'package:com.snowlive/mobile/viewmodel/ranking/vm_ridingCard.dart';
import 'package:com.snowlive/mobile/viewmodel/ranking/vm_slope_rush.dart';
import 'package:com.snowlive/mobile/viewmodel/ranking/vm_snowball.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_alarmCenter.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_openChat.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_openChatAlarm.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_liveOnAlarm.dart';
import 'package:com.snowlive/viewmodel/themeStore/vm_themeStore.dart';
import 'package:com.snowlive/viewmodel/vm_eventAlarm.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_setGenderAndCategory.dart';
import 'package:com.snowlive/viewmodel/util/vm_imageController.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/crew/vm_setCrew.dart';
import 'package:com.snowlive/mobile/viewmodel/auth/vm_setProfile.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_streamController_banner.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart';


class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    // 🔴 핵심 ViewModel - 즉시 로드 (홈 화면에서 바로 필요)
    Get.put(MainHomeViewModel());
    Get.put(SnowballShopViewModel());  // ResortHomeViewModel에서 의존
    Get.put(ResortHomeViewModel());
    Get.put(StreamController_Banner());
    Get.put(AlarmCenterViewModel());
    Get.put(FleamarketListViewModel());
    // LiveTalk, Event ViewModel을 먼저 등록 (CommunityBulletinListViewModel에서 참조)
    Get.put(LiveTalkViewModel());
    Get.put(EventViewModel());
    Get.put(CommunityBulletinListViewModel());
    Get.put(CommunityDetailViewModel());
    Get.put(CommunityCommentDetailViewModel());
    Get.put(RankingListViewModel());
    Get.put(RidingCardViewModel());

    // 🟢 서브 화면용 ViewModel - 지연 로드 (해당 화면 진입 시 생성)
    Get.lazyPut(() => FleamarketCommentDetailViewModel(), fenix: true);
    Get.lazyPut(() => GenderCategoryViewModel(), fenix: true);
    Get.lazyPut(() => ChatViewModel(), fenix: true);
    Get.lazyPut(() => OpenChatAlarmViewModel(), fenix: true);
    Get.lazyPut(() => LiveOnAlarmViewModel(), fenix: true);
    Get.lazyPut(() => EventAlarmViewModel(), fenix: true);
    Get.lazyPut(() => CommunityAlarmViewModel(), fenix: true);
    Get.lazyPut(() => FriendDetailUpdateViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketDetailViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketUpdateViewModel(), fenix: true);
    Get.lazyPut(() => ImageController(), fenix: true);
    Get.lazyPut(() => FriendListViewModel(), fenix: true);
    Get.lazyPut(() => CrewMemberListViewModel(), fenix: true);
    Get.lazyPut(() => CrewRankingListViewModel(), fenix: true);
    Get.lazyPut(() => CrewNoticeViewModel(), fenix: true);
    Get.lazyPut(() => CrewApplyViewModel(), fenix: true);
    Get.lazyPut(() => SearchCrewViewModel(), fenix: true);
    Get.lazyPut(() => CrewDetailViewModel(), fenix: true);
    Get.lazyPut(() => SetCrewViewModel(), fenix: true);
    Get.lazyPut(() => RankingListBetaViewModel(), fenix: true);
    Get.lazyPut(() => RankingCrewHistoryViewModel(), fenix: true);
    Get.lazyPut(() => SlopeRushViewModel(), fenix: true);
    Get.lazyPut(() => ThemeStoreViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketAlertViewModel(), fenix: true);
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
    Get.put(CrewDailyRecordViewModel());
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
    Get.put(CrewRecordRoomViewModel());
    Get.put(CrewRankingListViewModel_recordRoom());
    Get.put(CrewDetailViewModel_recordRoom());
  }
}

class IndivHistoryHome extends Bindings {
  @override
  void dependencies() {
    Get.put(RankingIndivHistoryViewModel());
    Get.put(FriendDetailViewModel_recordRoom());
  }
}

class Setting_moreTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginViewModel());
  }
}
class RankingRecordRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RankingListViewModel_recordRoom());
    Get.put(RankingListBetaViewModel());
  }
}
