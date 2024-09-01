import 'package:com.snowlive/screens/common/v_profileImageScreen.dart';
import 'package:com.snowlive/screens/resort/v_resortHome.dart';
import 'package:com.snowlive/view/v_MainHome.dart';
import 'package:com.snowlive/view/v_fleaMarketMain.dart';
import 'package:com.snowlive/view/v_friendDetail.dart';
import 'package:com.snowlive/view/v_friendList.dart';
import 'package:com.snowlive/view/v_login.dart';
import 'package:com.snowlive/view/v_setProfile.dart';
import 'package:com.snowlive/view/v_tos.dart';
import 'package:get/get.dart';
import '../view/v_fleaMarketList_search.dart';
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
  ];
}
