import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketSearch.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketAlert.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketMyActivity_web.dart';
import 'package:com.snowlive/web/viewmodel/home/vm_home_web.dart';
import 'package:com.snowlive/web/viewmodel/home/vm_openChat_web.dart';
import 'package:com.snowlive/web/viewmodel/settings/vm_settings_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpload_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpdate_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityDetail_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkDetail_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkUpload_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalk_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityUpload_web.dart';
import 'package:com.snowlive/web/viewmodel/event/vm_eventListPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingArchiveCrew_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingArchiveIndiv_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingList_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingListCrew_web.dart';
import 'package:com.snowlive/core/viewmodel/crew/vm_crewHome.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewCreate_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewJoin_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/viewmodel/util/vm_imageController_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewDetail_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewRecord_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_profileDetail_web.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_ridingCard.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_slopeCraft_web.dart';
import 'package:com.snowlive/core/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_login_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_onboarding_web.dart';
import 'package:get/get.dart';

/// 로그인 라우트용 바인딩 (팀원이 로그인/스플래시 라우트에 연결).
class WebLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginViewModelWeb(), fenix: true);
    Get.lazyPut(() => AuthCheckViewModelWeb(), fenix: true);
  }
}

class WebOnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // OnboardingViewModelWeb이 pendingUid/pendingEmail을 읽으려고 LoginViewModelWeb을
    // Get.find 한다. 여기서 등록하지 않으면 `/onboarding`으로 직접 진입하거나
    // 새로고침했을 때 제출 시점에 "not found"로 죽는다(fenix는 한 번 등록된 뒤
    // 삭제된 경우만 부활시키므로 도움이 안 된다).
    Get.lazyPut(() => LoginViewModelWeb(), fenix: true);
    Get.lazyPut(() => OnboardingViewModelWeb(), fenix: true);
  }
}

/// 웹 라이브톡 라우트용 바인딩.
class WebLiveTalkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LiveTalkListPaginationViewModelWeb(), fenix: true);
    Get.lazyPut(() => LiveTalkDetailViewModelWeb(), fenix: true);
    Get.lazyPut(() => LiveTalkUploadViewModelWeb(), fenix: true);
  }
}

/// 웹 커뮤니티 목록 라우트용 바인딩.
class WebCommunityListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommunityListPaginationViewModelWeb(), fenix: true);
  }
}

/// 웹 각종소식(이벤트) 독립 목록 라우트용 바인딩.
class WebEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EventListPaginationViewModelWeb(), fenix: true);
  }
}

/// 웹 커뮤니티 게시글 작성 라우트용 바인딩.
class WebCommunityUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommunityUploadViewModelWeb(), fenix: true);
    // 등록 후 목록을 1페이지로 되돌리기 위해 필요하다. URL 직접 진입/새로고침으로
    // 목록을 거치지 않고 들어오는 경우까지 커버한다.
    Get.lazyPut(() => CommunityListPaginationViewModelWeb(), fenix: true);
  }
}

/// 웹 커뮤니티 상세 라우트용 바인딩.
class WebCommunityDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommunityDetailViewModelWeb(), fenix: true);
  }
}

/// 웹 랭킹 라우트용 바인딩 (팀원이 랭킹 화면 라우트에 연결).
class WebRankingListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RankingListViewModelWeb(), fenix: true);
    Get.lazyPut(() => RankingListCrewViewModelWeb(), fenix: true);
    // 랭킹 목록의 프로필 모달에서 '친구 추가'를 누르면 FriendViewModelWeb을 쓴다
    // → 랭킹 라우트에도 등록해야 "not found"로 죽지 않는다.
    Get.lazyPut(() => FriendListViewModel(), fenix: true);
    Get.lazyPut(() => FriendViewModelWeb(), fenix: true);
  }
}

/// 웹 "랭킹 기록실"(시즌별 지난 기록) 라우트용 바인딩.
class WebRankingArchiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RankingArchiveIndivViewModelWeb(), fenix: true);
    Get.lazyPut(() => RankingArchiveCrewViewModelWeb(), fenix: true);
    // 랭킹 목록의 프로필 모달에서 '친구 추가'를 누르면 FriendViewModelWeb을 쓴다
    // → 랭킹 라우트에도 등록해야 "not found"로 죽지 않는다.
    Get.lazyPut(() => FriendListViewModel(), fenix: true);
    Get.lazyPut(() => FriendViewModelWeb(), fenix: true);
  }
}

/// 설정 라우트용 바인딩. 로그아웃·회원탈퇴만 있어 뷰모델 하나로 끝난다.
class WebSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsViewModelWeb(), fenix: true);
  }
}

/// 홈 라우트용 바인딩. 홈은 섹션마다 소스가 달라서 필요한 VM이 여러 개다.
class WebHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeViewModelWeb(), fenix: true);
    Get.lazyPut(() => OpenChatViewModelWeb(), fenix: true);
    // `우리 크루는요`는 크루홈 집계(공개 크루톡)를 그대로 쓴다.
    Get.lazyPut(() => CrewHomeViewModel(), fenix: true);
  }
}

class WebFleamarketListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FleamarketListViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketSearchViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketMyActivityViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketPaginationViewModelWeb(), fenix: true);
    // 목록 카드 탭에서 상세로 이동하기 전에 fetchFleamarketDetailFromList로 미리
    // 채워야 하므로 상세 라우트 진입 전인 목록 화면에도 등록해둔다.
    Get.lazyPut(() => FleamarketDetailViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketCommentDetailViewModel(), fenix: true);
  }
}

class WebFleamarketAlertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FleamarketAlertViewModel(), fenix: true);
  }
}

class WebFleamarketSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FleamarketSearchViewModel(), fenix: true);
  }
}

class WebFleamarketDetailBinding extends Bindings {
  @override
  void dependencies() {
    // FleamarketDetailViewModel이 생성 시 FleamarketListViewModel을 Get.find 하므로
    // (목록 갱신용) 반드시 함께 등록해야 한다. 목록을 거치지 않고 상세 URL로 직접
    // 진입/새로고침할 때 이게 없으면 "FleamarketListViewModel not found"로 크래시난다.
    Get.lazyPut(() => FleamarketListViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketDetailViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketCommentDetailViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketAlertViewModel(), fenix: true);
    Get.lazyPut(() => FleamarketUpdateViewModelWeb(), fenix: true);
  }
}

class WebFleamarketUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FleamarketUploadViewModelWeb(), fenix: true);
    // 등록 성공 직후 사진을 붙이는 마무리 단계(update API 재사용)에 필요.
    Get.lazyPut(() => FleamarketUpdateViewModelWeb(), fenix: true);
  }
}

class WebFleamarketUpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FleamarketUpdateViewModelWeb(), fenix: true);
  }
}

/// 친구 라우트 4개(목록·설정·요청 관리·차단 관리) 공용 바인딩.
class WebFriendBinding extends Bindings {
  @override
  void dependencies() {
    // 읽기는 코어 뷰모델을 그대로 쓴다(웹 금지 의존성이 없다). FriendViewModelWeb이
    // 이걸 Get.find 하므로 **함께** 등록해야 URL 직접 진입 시 죽지 않는다.
    Get.lazyPut(() => FriendListViewModel(), fenix: true);
    Get.lazyPut(() => FriendViewModelWeb(), fenix: true);
  }
}

/// 라이브크루 홈 라우트용 바인딩.
class WebLiveCrewBinding extends Bindings {
  @override
  void dependencies() {
    // 크루홈 집계 조회는 코어 뷰모델을 그대로 쓴다 — 웹 금지 의존성이 없고
    // 화면이 필요한 4개 섹션이 이 응답 하나에서 나온다.
    Get.lazyPut(() => CrewHomeViewModel(), fenix: true);
    // 갤러리 사진의 `라이브톡에서 보기`·신고·숨기기가 라이브톡 상세 VM을 Get.find 한다
    // → 함께 등록해야 URL 직접 진입(#/livecrew 새로고침)에서 죽지 않는다.
    Get.lazyPut(() => LiveTalkDetailViewModelWeb(), fenix: true);
  }
}

/// 크루홈 라우트 3개(크루홈·전체 멤버·크루톡 목록) 공용 바인딩.
class WebCrewHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CrewDetailViewModelWeb(), fenix: true);
    // 크루톡 상세 오버레이 + 크루톡 올리기 플로우가 쓴다.
    Get.lazyPut(() => LiveTalkDetailViewModelWeb(), fenix: true);
    Get.lazyPut(() => LiveTalkUploadViewModelWeb(), fenix: true);
    // 멤버 프로필 팝업의 `친구 추가`가 쓴다(랭킹 바인딩과 같은 이유).
    Get.lazyPut(() => FriendListViewModel(), fenix: true);
    Get.lazyPut(() => FriendViewModelWeb(), fenix: true);
  }
}

/// 크루 만들기 라우트용 바인딩.
class WebCrewCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CrewCreateViewModelWeb(), fenix: true);
    // 로고 업로드에 쓴다(온보딩·라이브톡과 같은 웹 이미지 파이프라인).
    Get.lazyPut(() => ImageControllerWeb(), fenix: true);
  }
}

/// 크루 가입하기 라우트용 바인딩.
class WebCrewJoinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CrewJoinViewModelWeb(), fenix: true);
  }
}

/// 라이딩 기록 카드 라우트용 바인딩.
class WebRidingCardsBinding extends Bindings {
  @override
  void dependencies() {
    // 코어 뷰모델을 그대로 쓴다 — 웹 금지 의존성이 없고(api·모델·shared_preferences)
    // 카드 스킨 저장·월별 그룹화까지 이미 들어 있다.
    Get.lazyPut(() => RidingCardViewModel(), fenix: true);
  }
}

/// 슬로프크래프트 라우트용 바인딩.
class WebSlopeCraftBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SlopeCraftViewModelWeb(), fenix: true);
    // 상단 `전체 스키장 점령 TOP 5`는 전용 API가 없어 크루홈 집계를 쓴다.
    Get.lazyPut(() => CrewHomeViewModel(), fenix: true);
  }
}

/// 개인 프로필 상세 라우트용 바인딩.
class WebProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileDetailViewModelWeb(), fenix: true);
    // 헤더의 `친구 추가`가 쓴다(랭킹·크루홈 바인딩과 같은 이유).
    Get.lazyPut(() => FriendListViewModel(), fenix: true);
    Get.lazyPut(() => FriendViewModelWeb(), fenix: true);
  }
}

/// 크루 기록 라우트 3개(시즌 기록실·일별 현황·크루원 시즌 랭킹) 공용 바인딩.
class WebCrewRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CrewRecordViewModelWeb(), fenix: true);
    // 멤버 프로필 팝업의 `친구 추가`가 쓴다(크루홈 바인딩과 같은 이유).
    Get.lazyPut(() => FriendListViewModel(), fenix: true);
    Get.lazyPut(() => FriendViewModelWeb(), fenix: true);
  }
}

/// 크루 설정 라우트 7개(허브·소개글·공지·이미지·신청·크루원·권한) 공용 바인딩.
class WebCrewSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CrewSettingViewModelWeb(), fenix: true);
    // 로고 업로드에 쓴다(크루 만들기와 같은 웹 이미지 파이프라인).
    Get.lazyPut(() => ImageControllerWeb(), fenix: true);
  }
}
