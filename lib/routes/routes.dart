import 'package:com.snowlive/view/community/free/v_community_Bulletin_Detail.dart';
import 'package:com.snowlive/view/community/free/v_community_Upload.dart';
import 'package:com.snowlive/view/community/free/v_community_update.dart';
import 'package:com.snowlive/view/community/free/v_community_comment_detail.dart';
import 'package:com.snowlive/view/community/v_community_main.dart';
import 'package:com.snowlive/view/crew/v_crewApplication_crew.dart';
import 'package:com.snowlive/view/crew/v_crewApplication_user.dart';
import 'package:com.snowlive/view/crew/v_crewDescription.dart';
import 'package:com.snowlive/view/crew/v_crewMemberSettings.dart';
import 'package:com.snowlive/view/crew/v_crewNotice.dart';
import 'package:com.snowlive/view/crew/v_crewNoticeList.dart';
import 'package:com.snowlive/view/crew/v_crewNoticeModify.dart';
import 'package:com.snowlive/view/crew/v_crewSetting.dart';
import 'package:com.snowlive/view/crew/v_managerPermission.dart';
import 'package:com.snowlive/view/crew/v_searchCrew.dart';
import 'package:com.snowlive/view/crew/v_updateCrewImageAndColor.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketCommentDetail.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_search.dart';
import 'package:com.snowlive/view/fleamarket/v_fleamarketUpdate.dart';
import 'package:com.snowlive/view/fleamarket/v_fleamarketUpload.dart';
import 'package:com.snowlive/view/friend/history/v_rankingIndiv_history_home.dart';
import 'package:com.snowlive/view/friend/v_friendBlockList.dart';
import 'package:com.snowlive/view/friend/v_invitation_friend.dart';
import 'package:com.snowlive/view/moreTab/v_setting_moreTab.dart';
import 'package:com.snowlive/view/ranking/history/v_ranking_history_home.dart';
import 'package:com.snowlive/view/resortHome/v_alarmCenter.dart';
import 'package:com.snowlive/view/v_profileImageScreen.dart';
import 'package:com.snowlive/view/crew/v_crewHome.dart';
import 'package:com.snowlive/view/crew/v_crewMain.dart';
import 'package:com.snowlive/view/crew/v_crewMember.dart';
import 'package:com.snowlive/view/crew/v_onboarding.dart';
import 'package:com.snowlive/view/crew/v_recordRoom.dart';
import 'package:com.snowlive/view/crew/v_setCrewImageAndColor.dart';
import 'package:com.snowlive/view/crew/v_setCrewNameAndResort.dart';
import 'package:com.snowlive/view/moreTab/v_moreTab_main.dart';
import 'package:com.snowlive/view/v_MainHome.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketDetail.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketMain.dart';
import 'package:com.snowlive/view/friend/v_friendDetail.dart';
import 'package:com.snowlive/view/friend/v_friendDetailUpdate.dart';
import 'package:com.snowlive/view/friend/v_friendList.dart';
import 'package:com.snowlive/view/friend/v_friend_setting.dart';
import 'package:com.snowlive/view/login/v_login.dart';
import 'package:com.snowlive/view/friend/v_searchFriend.dart';
import 'package:com.snowlive/view/onboarding/v_setProfile.dart';
import 'package:com.snowlive/view/onboarding/v_tos.dart';
import 'package:com.snowlive/view/resortHome/v_resortHome.dart';
import 'package:get/get.dart';
import 'bindings.dart';

class AppRoutes {

  static const String mainHome = '/mainHome';
  static const String resortHome = '/resortHome';
  static const String login = '/login';
  static const String tos = '/tos';
  static const String setProfile = '/setProfile';
  static const String friendList = '/friendList';
  static const String friendDetail = '/friendDetail';
  static const String userProfileIamge = '/userProfileIamge';
  static const String fleamarket = '/fleamarket';
  static const String fleamarketSearch = '/fleamarketSearch';
  static const String fleamarketDetail = '/fleamarketDetail';
  static const String fleamarketCommentDetail = '/fleamarketCommentDetail';
  static const String fleamarketUpload = '/fleamarketUpload';
  static const String fleamarketUpdate = '/fleamarketUpdate';
  static const String friendDetailUpdate = '/friendDetailUpdate';
  static const String searchFriend = '/searchFriend';
  static const String invitaionFriend = '/invitaionFriend';
  static const String settingFriend = '/settingFriend';
  static const String friendBlockList = '/friendBlockList';
  static const String bulletinMain = '/bulletinMain';
  static const String bulletinUpload = '/bulletinUpload';
  static const String bulletinDetail = '/bulletinDetail';
  static const String bulletinCommentDetail = '/bulletinCommentDetail';
  static const String bulletinDetailUpdate = '/bulletinDetailUpdate';
  static const String moreTab = '/moreTab';
  static const String onBoardingCrewMain = '/onBoardingCrewMain';
  static const String setCrewNameAndResort = '/setCrewNameAndResort';
  static const String setCrewImageAndColor = '/setCrewImageAndColor';
  static const String crewMain = '/crewMain';
  static const String crewHome = '/crewHome';
  static const String crewMember = '/crewMember';
  static const String rankingHome = '/rankingHome';
  static const String crewRecordRoom = '/crewRecordRoom';
  static const String searchCrew = '/searchCrew';
  static const String crewApplicationUser = '/crewApplicationUser';
  static const String crewSetting = '/crewSetting';
  static const String crewApplicationCrew = '/crewApplicationCrew';
  static const String updateCrewImageAndColor = '/updateCrewImageAndColor';
  static const String crewDescription = '/crewDescription';
  static const String crewNoticeCreate = '/crewNoticeCreate';
  static const String crewNoticeList = '/crewNoticeList';
  static const String crewMemberSettings = '/crewMemberSettings';
  static const String managerPermission = '/managerPermission';
  static const String crewNoticeModify = '/crewNoticeModify';
  static const String rankingHistoryHome = '/rankingHistoryHome';
  static const String rankingIndivHistoryHome = '/rankingIndivHistoryHome';
  static const String setting_moreTab = '/setting_moreTab';
  static const String alarmCenter = '/alarmCenter';












  static final List<GetPage> pages = [
    GetPage(
      name: mainHome,
      page: () => MainHomeView(),
      binding: MainHomeBinding(),
    ),
    GetPage(
      name: resortHome,
      page: () => ResortHomeView(),
      binding: ResortHomeBinding(),
    ),
    GetPage(
      name: login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: tos,
      page: () => TermsOfServiceView(),
      binding: TosBinding(),
    ),
    GetPage(
      name: setProfile,
      page: () => SetProfileView(),
      binding: SetProfileBinding(),
    ),
    GetPage(
      name: friendList,
      page: () => FriendListView(),
      binding: FriendListBinding(),
    ),
    GetPage(
      name: friendDetail,
      page: () => FriendDetailView(),
      binding: FriendListBinding(),
    ),
    GetPage(
      name: userProfileIamge,
      page: () {
        final userProfileUrl = Get.arguments as String;
        return ProfileImageView(userProfileUrl: userProfileUrl);
      },
      binding: FriendListBinding(),
    ),
    GetPage(
      name: fleamarket,
      page: () => FleaMarketMainView(),
      binding: FleamarketListBinding(),
    ),
    GetPage(
      name: fleamarketSearch,
      page: () => FleaMarketListView_search(),
      binding: FleamarketSearchBinding(),
    ),
    GetPage(
      name: fleamarketDetail,
      page: () => FleaMarketDetailView(),
      binding: FleamarketDetailBinding(),
    ),
    GetPage(
        name: fleamarketCommentDetail,
        page: () => FleamarketCommentDetailView()
    ),
    GetPage(
      name: fleamarketUpload,
      page: () => FleamarketUploadView(),
      binding: FleamarketUploadBinding(),
    ),
    GetPage(
      name: fleamarketUpdate,
      page: () => FleamarketUpdateView(),
    ),
    GetPage(
      name: friendDetailUpdate,
      page: () => FriendDetailUpdateView(),
    ),
    GetPage(
      name: friendList,
      page: () => FriendListView(),
    ),
    GetPage(
      name: searchFriend,
      page: () => SearchFriendView(),
      binding: SearchFriendViewBinding(),
    ),
    GetPage(
      name: invitaionFriend,
      page: () => InvitationFriendView(),
    ),
    GetPage(
      name: settingFriend,
      page: () => FriendSettingView(),
    ),
    GetPage(
      name: friendBlockList,
      page: () => FriendBlockListView(),
    ),
    GetPage(
      name: bulletinMain,
      page: () => CommunityMainView(),
    ),
    GetPage(
      name: bulletinUpload,
      page: () => CommunityBulletinUpload(),
      binding: BulletinUploadBinding(),
    ),
    GetPage(
        name: bulletinDetail,
        page: () => CommunityBulletinDetailView(),
        binding: BulletinDetailBinding()
    ),
    GetPage(
      name: bulletinDetailUpdate,
      page: () => CommunityBulletinUpdateView(),
    ),
    GetPage(
      name: bulletinCommentDetail,
      page: () => CommunityCommentDetailView(),
    ),
    GetPage(
      name: moreTab,
      page: () => MoreTabMainView(),
    ),
    GetPage(
      name: onBoardingCrewMain,
      page: () => OnBoardingCrewMainView(),
    ),
    GetPage(
        name: setCrewNameAndResort,
        page: () => SetCrewNameAndResortView(),
        binding: SetCrewNameAndResortBinding()
    ),
    GetPage(
      name: setCrewImageAndColor,
      page: () => SetCrewImageAndColorView(),
    ),
    GetPage(
        name: crewMain,
        page: () => CrewMainView(),
        binding: CrewMainBinding()
    ),
    GetPage(
      name: crewHome,
      page: () => CrewHomeView(),
    ),
    GetPage(
      name: crewMember,
      page: () => CrewMemberListView(),
    ),
    GetPage(
      name: crewRecordRoom,
      page: () => CrewRecordRoomView(),
    ),
    GetPage(
      name: searchCrew,
      page: () => SearchCrewView(),
    ),
    GetPage(
      name: crewApplicationUser,
      page: () => CrewApplicationUserView(),
    ),
    GetPage(
      name: crewSetting,
      page: () => CrewSettingView(),
    ),
    GetPage(
      name: crewApplicationCrew,
      page: () => CrewApplicationCrewView(),
    ),
    GetPage(
      name: updateCrewImageAndColor,
      page: () => UpdateCrewImageAndColorView(),
    ),
    GetPage(
      name: crewDescription,
      page: () => CrewDescriptionView(),
    ),
    GetPage(
      name: crewNoticeCreate,
      page: () => CrewNoticeCreateView(),
    ),
    GetPage(
      name: crewNoticeList,
      page: () => CrewNoticeListView(),
    ),
    GetPage(
      name: crewMemberSettings,
      page: () => CrewMemberSettingsView(),
    ),
    GetPage(
      name: managerPermission,
      page: () => ManagerPermissionView(),
    ),
    GetPage(
      name: crewNoticeModify,
      page: () => CrewNoticeModifyView(),
    ),
    GetPage(
      name: rankingHistoryHome,
      page: () => RankingHistoryHomeView(),
    ),
    GetPage(
      name: rankingIndivHistoryHome,
      page: () => RankingIndivHistoryHomeView(),
      binding: IndivHistoryHome()
    ),
    GetPage(
      name: setting_moreTab,
      page: () => Setting_moreTabView(),
      binding: Setting_moreTabBinding()
    ),
    GetPage(
      name: alarmCenter,
      page: () => AlarmCenterView(),
    ),
  ];
}
