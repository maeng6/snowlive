import 'package:com.snowlive/screens/common/v_profileImageScreen.dart';
import 'package:com.snowlive/screens/resort/v_resortHome.dart';
import 'package:com.snowlive/view/v_MainHome.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketDetail.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketMain.dart';
import 'package:com.snowlive/view/friend/v_friendDetail.dart';
import 'package:com.snowlive/view/friend/v_friendDetailUpdate.dart';
import 'package:com.snowlive/view/friend/v_friendList.dart';
import 'package:com.snowlive/view/friend/v_friend_setting.dart';
import 'package:com.snowlive/view/v_login.dart';
import 'package:com.snowlive/view/friend/v_searchFriend.dart';
import 'package:com.snowlive/view/onboarding/v_setProfile.dart';
import 'package:com.snowlive/view/onboarding/v_tos.dart';
import 'package:get/get.dart';
import '../view/bulletin/v_community_main.dart';
import '../view/fleamarket/v_fleaMarketCommentDetail.dart';
import '../view/fleamarket/v_fleaMarketList_search.dart';
import '../view/fleamarket/v_fleamarketUpdate.dart';
import '../view/fleamarket/v_fleamarketUpload.dart';
import '../view/friend/v_friendBlockList.dart';
import '../view/friend/v_invitation_friend.dart';
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

  static final List<GetPage> pages = [
    GetPage(
      name: mainHome,
      page: () => MainHomeView(),
      binding: MainHomeBinding(),
    ),
    GetPage(
      name: resortHome,
      page: () => ResortHome(),
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
  ];
}
