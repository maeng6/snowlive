import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketSearch.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketAlert.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketMyActivity_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpload_web.dart';
import 'package:com.snowlive/web/viewmodel/fleamarket/vm_fleamarketUpdate_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingList_web.dart';
import 'package:com.snowlive/web/viewmodel/ranking/vm_rankingListCrew_web.dart';
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
    Get.lazyPut(() => OnboardingViewModelWeb(), fenix: true);
  }
}

/// 웹 랭킹 라우트용 바인딩 (팀원이 랭킹 화면 라우트에 연결).
class WebRankingListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RankingListViewModelWeb(), fenix: true);
    Get.lazyPut(() => RankingListCrewViewModelWeb(), fenix: true);
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
