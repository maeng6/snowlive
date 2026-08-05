import 'package:com.snowlive/web/routes/bindings_web.dart';
import 'package:com.snowlive/web/view/community/v_communityDetail_web.dart';
import 'package:com.snowlive/web/view/community/v_communityHome_web.dart';
import 'package:com.snowlive/web/view/community/v_communityUpload_web.dart';
import 'package:com.snowlive/web/view/event/v_eventHome_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketDetail_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketHome_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketUpdate_web.dart';
import 'package:com.snowlive/web/view/fleamarket/v_fleamarketUpload_web.dart';
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
      page: () => const _PlaceholderPage(title: '키워드 알림 설정'),
      binding: WebFleamarketAlertBinding(),
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
