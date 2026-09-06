import 'package:com.snowlive/web/routes/bindings_web.dart';
import 'package:com.snowlive/web/view/community/v_communityDetail_web.dart';
import 'package:com.snowlive/web/view/community/v_communityHome_web.dart';
import 'package:com.snowlive/web/view/community/v_communityUpload_web.dart';
import 'package:com.snowlive/web/view/event/v_eventHome_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketAlert_web.dart';
import 'package:com.snowlive/web/view/friend/v_friendBlockList_web.dart';
import 'package:com.snowlive/web/view/friend/v_friendHome_web.dart';
import 'package:com.snowlive/web/view/friend/v_friendRequests_web.dart';
import 'package:com.snowlive/web/view/friend/v_friendSettings_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketDetail_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketHome_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketUpdate_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketUpload_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewCreate_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewDailyRecord_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewRecordRoom_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewSeasonRanking_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewHome_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewApplications_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewJoin_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewMemberAdmin_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewPermissions_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewSettingDesc_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewSettingImage_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewSettingNotice_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewSetting_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewMembers_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_crewTalks_web.dart';
import 'package:com.snowlive/web/view/liveCrew/v_liveCrewHome_web.dart';
import 'package:com.snowlive/web/view/profile/v_profileDetail_web.dart';
import 'package:com.snowlive/web/view/ranking/v_ridingCards_web.dart';
import 'package:com.snowlive/web/view/ranking/v_slopeCraft_web.dart';
import 'package:com.snowlive/web/view/liveTalk/v_liveTalkComments_web.dart';
import 'package:com.snowlive/web/view/liveTalk/v_liveTalkHome_web.dart';
import 'package:com.snowlive/web/view/login/v_login_web.dart';
import 'package:com.snowlive/web/view/onboarding/v_onboarding_web.dart';
import 'package:com.snowlive/web/view/ranking/v_rankingArchive_web.dart';
import 'package:com.snowlive/web/view/ranking/v_rankingHome_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebRoutes {
  static const fleamarketList = '/fleamarket';
  static const fleamarketSearch = '/fleamarket/search';
  // 커뮤니티 상세와 같은 이유로 최상위 경로다(중첩 '/fleamarket/detail'로 두면 GetX가
  // 부모 '/fleamarket'로 매칭해 새로고침 시 목록이 뜬다). 상품 id는 쿼리로 싣는다:
  // '/fleamarket-detail?id=1365' → 새로고침·링크 공유로 직접 들어와도 그 id로 조회한다.
  static const fleamarketDetail = '/fleamarket-detail';
  static const fleamarketUpload = '/fleamarket/upload';
  static const fleamarketUpdate = '/fleamarket/update';
  static const fleamarketAlert = '/fleamarket/alert';
  static const login = '/login';
  static const onboarding = '/onboarding';
  // 각종소식(크롤링 이벤트). 커뮤니티에서 분리된 독립 목록 화면.
  static const event = '/event';
  static const community = '/community';
  // '/community/detail'로 두면 아래 rankingArchive와 같은 사고가 난다
  // (GetX가 부모 '/community'로 매칭) → 최상위 경로로 분리한다.
  // 게시글 id는 쿼리로 싣는다: '/community-detail?id=621'
  static const communityDetail = '/community-detail';
  // 상세와 같은 이유로 '/community/upload'가 아니라 최상위 경로다.
  static const communityUpload = '/community-upload';
  static const liveTalk = '/livetalk';
  // 상세/작성과 같은 이유로 하위 경로가 아니라 최상위다(GetX 부모 매칭 사고 방지).
  static const liveTalkComments = '/livetalk-comments';
  static const ranking = '/ranking';
  // '/ranking/archive'처럼 기존 라우트의 하위 경로로 두면 GetX가 부모('/ranking')로
  // 매칭해버려서 기록실 대신 랭킹 화면이 떴다. 별도 최상위 경로로 분리한다.
  static const rankingArchive = '/ranking-archive';
  // 슬로프크래프트(슬로프 점령도). 랭킹 하위 경로로 두면 GetX가 부모로 매칭하므로
  // 형제 최상위 경로로 둔다.
  static const slopeCraft = '/slopecraft';
  /// 라이딩 기록 카드(시즌 카드 + 데일리 카드 목록).
  static const ridingCards = '/riding-cards';

  // 친구는 하위 경로(`/friend/settings`)로 두면 GetX가 부모 `/friend`로 매칭해버려
  // 새로고침 시 목록이 뜬다 → 커뮤니티·랭킹처럼 형제 최상위 경로로 나눈다.
  // 라이브크루. 크루별 상세(크루홈)는 다음 작업이며, 그때도 하위 경로가 아니라
  // '/livecrew-detail?id=N' 형태의 형제 최상위 경로로 붙인다.
  static const liveCrew = '/livecrew';
  // 크루홈(크루별 상세)과 그 하위 화면들. 하위 경로(`/livecrew/detail`)로 두면 GetX가
  // 부모 `/livecrew`로 매칭해버려 새로고침 시 목록이 뜬다 → 형제 최상위 경로 + 쿼리 id.
  static const crewHome = '/livecrew-detail';
  static const crewMembers = '/livecrew-members';
  static const crewTalks = '/livecrew-talks';
  static const crewCreate = '/livecrew-create';
  static const crewJoin = '/livecrew-join';
  // 크루 설정 묶음. 하위 경로로 두면 GetX가 부모로 매칭하므로 형제 최상위 + 쿼리 id.
  static const crewSetting = '/livecrew-setting';
  static const crewSettingDesc = '/livecrew-desc';
  static const crewSettingNotice = '/livecrew-notice';
  static const crewSettingImage = '/livecrew-image';
  static const crewApplications = '/livecrew-applications';
  static const crewMemberAdmin = '/livecrew-member-admin';
  static const crewPermissions = '/livecrew-permissions';
  // 크루 기록 화면들. 시즌 축(기록실·크루원 랭킹)과 연도 축(일별 현황).
  static const crewRecordRoom = '/livecrew-record';
  static const crewDailyRecord = '/livecrew-daily';
  static const crewSeasonRanking = '/livecrew-season-ranking';

  /// 개인 프로필 상세(라이딩 통계·방명록·시즌 기록실). `?id={userId}`
  static const userProfile = '/profile';

  static const friend = '/friend';
  static const friendSettings = '/friend-settings';
  static const friendRequests = '/friend-requests';
  static const friendBlockList = '/friend-blocklist';

  static final pages = [
    GetPage(
      name: fleamarketList,
      page: () => const FleamarketHomeView(),
      binding: WebFleamarketListBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginViewWeb(),
      binding: WebLoginBinding(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingViewWeb(),
      binding: WebOnboardingBinding(),
    ),
    GetPage(
      name: fleamarketSearch,
      page: () => const _PlaceholderPage(title: '중고거래 검색'),
      binding: WebFleamarketSearchBinding(),
    ),
    GetPage(
      name: fleamarketDetail,
      page: () => const FleamarketDetailView(),
      binding: WebFleamarketDetailBinding(),
    ),
    GetPage(
      name: fleamarketUpload,
      page: () => const FleamarketUploadViewWeb(),
      binding: WebFleamarketUploadBinding(),
    ),
    GetPage(
      name: fleamarketUpdate,
      page: () => const FleamarketUpdateViewWeb(),
      binding: WebFleamarketUpdateBinding(),
    ),
    GetPage(
      name: fleamarketAlert,
      page: () => const FleamarketAlertViewWeb(),
      binding: WebFleamarketAlertBinding(),
    ),
    GetPage(
      name: friend,
      page: () => const FriendHomeViewWeb(),
      binding: WebFriendBinding(),
    ),
    GetPage(
      name: friendSettings,
      page: () => const FriendSettingsViewWeb(),
      binding: WebFriendBinding(),
    ),
    GetPage(
      name: friendRequests,
      page: () => const FriendRequestsViewWeb(),
      binding: WebFriendBinding(),
    ),
    GetPage(
      name: friendBlockList,
      page: () => const FriendBlockListViewWeb(),
      binding: WebFriendBinding(),
    ),
    GetPage(
      name: event,
      page: () => const EventHomeViewWeb(),
      binding: WebEventBinding(),
    ),
    GetPage(
      name: community,
      page: () => const CommunityHomeViewWeb(),
      binding: WebCommunityListBinding(),
    ),
    GetPage(
      name: liveTalk,
      page: () => const LiveTalkHomeViewWeb(),
      binding: WebLiveTalkBinding(),
    ),
    GetPage(
      name: liveTalkComments,
      page: () => const LiveTalkCommentsViewWeb(),
      binding: WebLiveTalkBinding(),
    ),
    GetPage(
      name: communityUpload,
      page: () => const CommunityUploadViewWeb(),
      binding: WebCommunityUploadBinding(),
    ),
    GetPage(
      name: communityDetail,
      page: () => const CommunityDetailViewWeb(),
      binding: WebCommunityDetailBinding(),
    ),
    GetPage(
      name: ranking,
      page: () => const RankingHomeViewWeb(),
      binding: WebRankingListBinding(),
    ),
    GetPage(
      name: rankingArchive,
      page: () => const RankingArchiveViewWeb(),
      binding: WebRankingArchiveBinding(),
    ),
    GetPage(
      name: liveCrew,
      page: () => const LiveCrewHomeViewWeb(),
      binding: WebLiveCrewBinding(),
    ),
    GetPage(
      name: crewHome,
      page: () => const CrewHomeViewWeb(),
      binding: WebCrewHomeBinding(),
    ),
    GetPage(
      name: crewMembers,
      page: () => const CrewMembersViewWeb(),
      binding: WebCrewHomeBinding(),
    ),
    GetPage(
      name: crewTalks,
      page: () => const CrewTalksViewWeb(),
      binding: WebCrewHomeBinding(),
    ),
    GetPage(
      name: crewCreate,
      page: () => const CrewCreateViewWeb(),
      binding: WebCrewCreateBinding(),
    ),
    GetPage(
      name: crewJoin,
      page: () => const CrewJoinViewWeb(),
      binding: WebCrewJoinBinding(),
    ),
    GetPage(
      name: crewSetting,
      page: () => const CrewSettingViewWeb(),
      binding: WebCrewSettingBinding(),
    ),
    GetPage(
      name: crewSettingDesc,
      page: () => const CrewSettingDescViewWeb(),
      binding: WebCrewSettingBinding(),
    ),
    GetPage(
      name: crewSettingNotice,
      page: () => const CrewSettingNoticeViewWeb(),
      binding: WebCrewSettingBinding(),
    ),
    GetPage(
      name: crewSettingImage,
      page: () => const CrewSettingImageViewWeb(),
      binding: WebCrewSettingBinding(),
    ),
    GetPage(
      name: ridingCards,
      page: () => const RidingCardsViewWeb(),
      binding: WebRidingCardsBinding(),
    ),
    GetPage(
      name: slopeCraft,
      page: () => const SlopeCraftViewWeb(),
      binding: WebSlopeCraftBinding(),
    ),
    GetPage(
      name: userProfile,
      page: () => const ProfileDetailViewWeb(),
      binding: WebProfileBinding(),
    ),
    GetPage(
      name: crewRecordRoom,
      page: () => const CrewRecordRoomViewWeb(),
      binding: WebCrewRecordBinding(),
    ),
    GetPage(
      name: crewDailyRecord,
      page: () => const CrewDailyRecordViewWeb(),
      binding: WebCrewRecordBinding(),
    ),
    GetPage(
      name: crewSeasonRanking,
      page: () => const CrewSeasonRankingViewWeb(),
      binding: WebCrewRecordBinding(),
    ),
    GetPage(
      name: crewApplications,
      page: () => const CrewApplicationsViewWeb(),
      binding: WebCrewSettingBinding(),
    ),
    GetPage(
      name: crewMemberAdmin,
      page: () => const CrewMemberAdminViewWeb(),
      binding: WebCrewSettingBinding(),
    ),
    GetPage(
      name: crewPermissions,
      page: () => const CrewPermissionsViewWeb(),
      binding: WebCrewSettingBinding(),
    ),
  ];
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    // 이 화면은 WebAppShell(GNB 상단바/사이드바) 안에 렌더링되므로 자체 Scaffold+AppBar를
    // 두면 헤더가 2단으로 쌓인다. 셸이 이미 배경/구조를 잡아주니 콘텐츠만 그린다.
    return Center(
      child: Text(
        '$title\n(웹 뷰 구현 예정)',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
