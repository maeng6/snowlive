import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_community.dart';
import 'package:com.snowlive/core/api/api_event.dart';
import 'package:com.snowlive/core/api/api_fleamarket.dart';
import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:com.snowlive/core/model/m_communityList.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_event.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/model/m_rankingListCrew.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/core/model/m_weatherModel.dart';
import 'package:com.snowlive/core/viewmodel/crew/vm_crewHome.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/web_image_preload.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:get/get.dart';

/// 웹 홈 화면의 데이터.
///
/// 섹션별 소스가 전부 다르다 — 배너는 Firestore(`banner/homeHeroWeb`), 날씨는 기상청 API +
/// 정적 리조트 목록(nx/ny·링크), 오늘의 랭킹은 랭킹 API의 `daily=true`, 커뮤니티는 게시판
/// 최신글, 우리 크루는요는 크루홈 집계의 공개 크루톡, 중고거래는 중고거래 목록 첫 페이지다.
///
/// 섹션 하나가 실패해도 나머지는 그려야 하므로 로딩·에러 상태를 **섹션별로** 둔다.
class HomeViewModelWeb extends GetxController {
  final RankingAPI _rankingAPI = RankingAPI();
  final FleamarketAPI _fleamarketAPI = FleamarketAPI();
  final CommunityAPI _communityAPI = CommunityAPI();

  UserViewModel get _userVM => Get.find<UserViewModel>();

  // ── 배너 ──
  final Rxn<Map<String, dynamic>> _bannerDoc = Rxn<Map<String, dynamic>>();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _bannerSub;
  Timer? _bannerFallbackTimer;

  List<HomeBanner> get banners => homeVisibleBanners(_bannerDoc.value);

  /// 문서를 한 번이라도 받았는지. 받기 전에는 자리(스켈레톤)를 잡고, 받은 뒤
  /// 켜진 배너가 없으면 **영역을 아예 감춘다**(앱과 동일 — 운영에서 다 끄면 안 보인다).
  bool get isBannerLoaded => _isBannerLoaded.value;
  final RxBool _isBannerLoaded = false.obs;

  // ── 날씨 ──
  final Rxn<ResortModel> _resort = Rxn<ResortModel>();
  final RxMap<String, dynamic> _weather = <String, dynamic>{}.obs;
  final RxBool _isWeatherLoading = false.obs;

  ResortModel? get resort => _resort.value;
  /// ⚠️ Rx 컬렉션 **객체를 그대로** 돌려주면 Obx가 의존성을 등록하지 못한다
  /// (실측: 날씨가 도착해도 화면이 `-`에 멈춰 있었다 — Obx 빌더는 위젯을 만들 뿐이고
  /// 값 읽기는 자식 build에서 일어나기 때문). 복사해서 돌려주면 읽는 순간
  /// (`keys`/`length` 접근) 의존성이 등록된다.
  Map<String, dynamic> get weather => Map<String, dynamic>.from(_weather);
  bool get isWeatherLoading => _isWeatherLoading.value;

  /// 네이버/웹캠/슬로프/셔틀 링크를 **DB(Resort_info)**에서 받아둔다(어드민이 DB만 고치면
  /// 반영되도록). 비어 있으면 위젯이 정적 리스트 값으로 폴백한다. 키: naver/webcam/slope/bus.
  final RxMap<String, String> _resortLinks = <String, String>{}.obs;
  Map<String, String> get resortLinks => Map<String, String>.from(_resortLinks);

  // ── 오늘의 랭킹 ──
  final RxList<RankingUser> _todayIndiv = <RankingUser>[].obs;
  final RxList<CrewRanking> _todayCrew = <CrewRanking>[].obs;
  final RxBool _isRankingLoading = false.obs;

  List<RankingUser> get todayIndiv => List<RankingUser>.from(_todayIndiv);
  List<CrewRanking> get todayCrew => List<CrewRanking>.from(_todayCrew);
  bool get isRankingLoading => _isRankingLoading.value;

  // ── 커뮤니티(게시판 최신글) ──
  final RxList<Community> _community = <Community>[].obs;
  final RxBool _isCommunityLoading = false.obs;

  List<Community> get community => List<Community>.from(_community);
  bool get isCommunityLoading => _isCommunityLoading.value;

  // ── 우리 크루는요 ──
  final RxBool _isCrewLoading = false.obs;
  bool get isCrewLoading => _isCrewLoading.value;
  CrewHomeModel? get crewHome => Get.find<CrewHomeViewModel>().home;

  List<HomeCrewCard> get crewCards => homeCrewCards(crewHome);

  // ── 중고거래 ──
  final RxList<Fleamarket> _fleamarket = <Fleamarket>[].obs;
  final RxBool _isFleamarketLoading = false.obs;

  List<Fleamarket> get fleamarket => List<Fleamarket>.from(_fleamarket);
  bool get isFleamarketLoading => _isFleamarketLoading.value;

  // ── 각종소식(이벤트 크롤 피드 최신) ──
  final EventAPI _eventAPI = EventAPI();
  final RxList<EventModel> _events = <EventModel>[].obs;
  final RxBool _isEventLoading = false.obs;

  List<EventModel> get events => List<EventModel>.from(_events);
  bool get isEventLoading => _isEventLoading.value;

  /// 오늘의 랭킹 배지에 쓰는 날짜. 화면이 매번 DateTime.now()를 부르지 않게 한 곳에 둔다.
  DateTime get today => DateTime.now();

  @override
  void onInit() {
    super.onInit();
    _listenBanner();
    selectResort(homeDefaultResort(_userVM.user.favorite_resort));
    loadTodayRanking();
    loadCommunity();
    loadCrewCards();
    loadFleamarket();
    loadEvents();
  }

  @override
  void onClose() {
    _bannerSub?.cancel();
    _bannerFallbackTimer?.cancel();
    super.onClose();
  }

  /// 로그인이 늦게 확정되면(자동로그인) 자주 가는 스키장으로 한 번 더 맞춘다.
  void syncResortWithUser() {
    final favorite = _userVM.user.favorite_resort;
    if (favorite == null) return;
    if (_resort.value?.index == favorite) return;
    selectResort(homeDefaultResort(favorite));
  }

  /// 당겨서 새로고침 — 날씨·오늘 랭킹·크루·플리마켓을 다시 받는다(배너는 스트림이라 자동).
  /// 홈에서 로고·사이드바 `홈`을 다시 눌렀을 때 — 화면이 맨 위로 올라가고([scrollToTopTick]을
  /// 홈 화면이 구독한다) 섹션 데이터를 다시 받는다. 배너는 실시간 구독이라 그대로 둔다.
  final RxInt scrollToTopTick = 0.obs;

  Future<void> refreshFromGnb() {
    scrollToTopTick.value++;
    // 배너는 영구 유지되는 VM의 실시간 스트림이라 재구독이 필요 없다(자동 반영).
    return refreshAll();
  }

  Future<void> refreshAll() async {
    final r = _resort.value;
    await Future.wait([
      if (r != null) _fetchWeather(r),
      loadTodayRanking(),
      loadCommunity(),
      loadCrewCards(),
      loadFleamarket(),
      loadEvents(),
    ]);
  }

  // ── 배너: **웹 전용 문서**를 구독한다(운영에서 값을 바꾸면 새로고침 없이 반영).
  //     앱이 쓰는 `banner/home`과 분리돼 있어 서로 영향이 없다. ──
  void _listenBanner() {
    _bannerSub?.cancel();
    _bannerFallbackTimer?.cancel();
    // Firestore가 끝내 응답(데이터·에러)을 안 줘도 배너 영역이 스켈레톤에 영영
    // 갇히지 않게, 일정 시간 내 첫 스냅샷이 없으면 기본 슬라이드(로컬 에셋)로 연다.
    _bannerFallbackTimer = Timer(const Duration(seconds: 4), () {
      if (!_isBannerLoaded.value) {
        _bannerDoc.value = null;
        _isBannerLoaded(true);
      }
    });
    _bannerSub = FirebaseFirestore.instance
        .collection(kHomeHeroBannerCollection)
        .doc(kHomeHeroBannerDoc)
        .snapshots()
        .listen(
          (snapshot) {
            _bannerFallbackTimer?.cancel();
            _bannerDoc.value = snapshot.data();
            _isBannerLoaded(true);
            // 첫 진입 때 브라우저 이미지 캐시를 데워둔다 → 로그인 후 홈 재진입에도
            // 네트워크 없이 즉시 뜬다. 같은 URL은 한 번만, 이미지가 바뀌면 그때만 받음.
            for (final b in banners) {
              preloadImageWeb(b.imageUrl);
              preloadImageWeb(b.imageUrlMobile);
            }
          },
          // 규칙·네트워크 문제로 실패해도 홈의 다른 섹션은 살아 있어야 한다.
          onError: (_) {
            _bannerFallbackTimer?.cancel();
            _bannerDoc.value = null;
            _isBannerLoaded(true);
          },
        );
  }

  // ── 날씨 ──
  Future<void> selectResort(ResortModel resort) async {
    _resort.value = resort;
    // 링크(셔틀 등)는 DB에서 받아 쓴다 — 리조트 바뀌면 이전 DB링크는 버리고(그 사이엔
    // 정적값 폴백) 새로 받는다. 날씨와 병렬로(블로킹하지 않음).
    _resortLinks.clear();
    _fetchResortLinks(resort);
    await _fetchWeather(resort);
  }

  /// 선택 리조트의 링크(naver/webcam/slope/bus)를 DB(Resort_info)에서 받아둔다.
  /// 정적 ResortModel.index(0-based) + 1 == DB resort_id 매핑을 쓴다(실측 일치).
  Future<void> _fetchResortLinks(ResortModel resort) async {
    final index = resort.index;
    if (index == null) return;
    final resortId = index + 1;
    try {
      final res = await http.get(Uri.parse(
          'https://snowlive-api-c617725e2b78.herokuapp.com/api/resort/resort/$resortId/'));
      if (res.statusCode != 200) return;
      final d = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      // 리조트를 빠르게 바꾸면 응답이 뒤바뀔 수 있다 → 마지막 선택만 반영.
      if (_resort.value?.index != index) return;
      _resortLinks.value = {
        if ((d['url_naver'] ?? '').toString().isNotEmpty) 'naver': d['url_naver'],
        if ((d['url_webcam'] ?? '').toString().isNotEmpty) 'webcam': d['url_webcam'],
        if ((d['url_slope'] ?? '').toString().isNotEmpty) 'slope': d['url_slope'],
        if ((d['url_bus'] ?? '').toString().isNotEmpty) 'bus': d['url_bus'],
      };
    } catch (_) {
      // 실패 시 정적값으로 폴백(위젯이 처리).
    }
  }

  Future<void> _fetchWeather(ResortModel resort) async {
    final nx = resort.nX;
    final ny = resort.nY;
    if (nx == null || ny == null) return;
    _isWeatherLoading(true);
    try {
      final parsed = await WeatherModel().parseWeatherData(nx, ny);
      // 리조트를 빠르게 바꾸면 응답 순서가 뒤바뀔 수 있다 → 마지막 선택만 반영한다.
      if (_resort.value?.index != resort.index) return;
      _weather.value = parsed;
    } catch (_) {
      _weather.clear();
    } finally {
      _isWeatherLoading(false);
    }
  }

  // ── 오늘의 랭킹(개인·크루 일간 상위 8) ──
  Future<void> loadTodayRanking() async {
    _isRankingLoading(true);
    try {
      final results = await Future.wait([
        _rankingAPI.fetchRankingData_indiv(
          userId: _userVM.user.user_id,
          daily: true,
          page: 1,
          pageSize: kHomeRankingCount,
        ),
        _rankingAPI.fetchRankingData_crew(
          userId: _userVM.user.user_id,
          daily: true,
          page: 1,
          pageSize: kHomeRankingCount,
        ),
      ]);

      final indiv = results[0];
      if (indiv.success && indiv.data is Map<String, dynamic>) {
        final parsed = RankingListIndivResponse.fromJson(indiv.data as Map<String, dynamic>);
        _todayIndiv.value = parsed.results?.rankingUsers ?? [];
      }

      final crew = results[1];
      if (crew.success && crew.data is Map<String, dynamic>) {
        final parsed = RankingListCrewModel.fromJson(crew.data as Map<String, dynamic>);
        _todayCrew.value = parsed.rankingResults?.results ?? [];
      }
    } catch (_) {
      // 랭킹만 비고 나머지 섹션은 그대로 둔다.
    } finally {
      _isRankingLoading(false);
    }
  }

  // ── 커뮤니티(게시판 최신글) ──
  Future<void> loadCommunity() async {
    _isCommunityLoading(true);
    try {
      final ApiResponse res = await _communityAPI.fetchCommunityList(
        // 커뮤니티는 게시판/이벤트 두 갈래인데 웹은 게시판만 쓴다(목록 화면과 같다).
        categoryMain: '게시판',
        // 로그인했으면 보내야 차단한 유저 글이 빠진다. 게스트는 아예 빼야 한다
        // (`"null"` 문자열이 가면 서버가 파싱에 실패한다).
        userId: _userVM.user.user_id?.toString(),
        page: 1,
      );
      if (res.success && res.data is Map<String, dynamic>) {
        final posts = homeParseCommunity((res.data as Map<String, dynamic>)['results']);
        _community.value = posts.take(kHomeCommunityFetchCount).toList();
      }
    } catch (_) {
      // 커뮤니티만 비고 나머지 섹션은 그대로 둔다.
    } finally {
      _isCommunityLoading(false);
    }
  }

  // ── 우리 크루는요(크루홈 집계 재사용) ──
  Future<void> loadCrewCards() async {
    _isCrewLoading(true);
    try {
      await Get.find<CrewHomeViewModel>().fetchCrewHome();
    } catch (_) {
      // 무시 — 카드가 비면 화면이 안내를 띄운다.
    } finally {
      _isCrewLoading(false);
    }
  }

  // ── 중고거래(최신 첫 페이지) ──
  Future<void> loadFleamarket() async {
    _isFleamarketLoading(true);
    try {
      final ApiResponse res = await _fleamarketAPI.fetchFleamarketList(
        userId: _userVM.user.user_id,
      );
      if (res.success && res.data is Map<String, dynamic>) {
        final parsed = FleamarketResponse.fromJson(res.data as Map<String, dynamic>);
        _fleamarket.value = parsed.results ?? [];
      }
    } catch (_) {
      // 무시 — 목록이 비면 화면이 안내를 띄운다.
    } finally {
      _isFleamarketLoading(false);
    }
  }

  // ── 각종소식(최신 첫 페이지) ──
  Future<void> loadEvents() async {
    _isEventLoading(true);
    try {
      final ApiResponse res = await _eventAPI.fetchEventList();
      if (res.success && res.data is Map<String, dynamic>) {
        final parsed = EventListResponse.fromJson(res.data as Map<String, dynamic>);
        _events.value = parsed.events;
      }
    } catch (_) {
      // 무시 — 목록이 비면 화면이 안내를 띄운다.
    } finally {
      _isEventLoading(false);
    }
  }
}
