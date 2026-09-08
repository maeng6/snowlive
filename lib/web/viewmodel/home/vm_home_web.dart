import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_fleamarket.dart';
import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/model/m_rankingListCrew.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/core/model/m_weatherModel.dart';
import 'package:com.snowlive/core/viewmodel/crew/vm_crewHome.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:get/get.dart';

/// 웹 홈 화면의 데이터.
///
/// 섹션별 소스가 전부 다르다 — 배너는 Firestore(`banner/home`), 날씨는 기상청 API +
/// 정적 리조트 목록(nx/ny·링크), 오늘의 랭킹은 랭킹 API의 `daily=true`, 우리 크루는요는
/// 크루홈 집계의 공개 크루톡, 중고거래는 중고거래 목록 첫 페이지다.
///
/// 섹션 하나가 실패해도 나머지는 그려야 하므로 로딩·에러 상태를 **섹션별로** 둔다.
class HomeViewModelWeb extends GetxController {
  final RankingAPI _rankingAPI = RankingAPI();
  final FleamarketAPI _fleamarketAPI = FleamarketAPI();

  UserViewModel get _userVM => Get.find<UserViewModel>();

  // ── 배너 ──
  final Rxn<Map<String, dynamic>> _bannerDoc = Rxn<Map<String, dynamic>>();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _bannerSub;

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

  // ── 오늘의 랭킹 ──
  final RxList<RankingUser> _todayIndiv = <RankingUser>[].obs;
  final RxList<CrewRanking> _todayCrew = <CrewRanking>[].obs;
  final RxBool _isRankingLoading = false.obs;

  List<RankingUser> get todayIndiv => List<RankingUser>.from(_todayIndiv);
  List<CrewRanking> get todayCrew => List<CrewRanking>.from(_todayCrew);
  bool get isRankingLoading => _isRankingLoading.value;

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

  /// 오늘의 랭킹 배지에 쓰는 날짜. 화면이 매번 DateTime.now()를 부르지 않게 한 곳에 둔다.
  DateTime get today => DateTime.now();

  @override
  void onInit() {
    super.onInit();
    _listenBanner();
    selectResort(homeDefaultResort(_userVM.user.favorite_resort));
    loadTodayRanking();
    loadCrewCards();
    loadFleamarket();
  }

  @override
  void onClose() {
    _bannerSub?.cancel();
    super.onClose();
  }

  /// 로그인이 늦게 확정되면(자동로그인) 자주 가는 스키장으로 한 번 더 맞춘다.
  void syncResortWithUser() {
    final favorite = _userVM.user.favorite_resort;
    if (favorite == null) return;
    if (_resort.value?.index == favorite) return;
    selectResort(homeDefaultResort(favorite));
  }

  // ── 배너: 앱과 같은 문서를 구독한다(운영에서 `visible`을 껐다 켜면 즉시 반영) ──
  void _listenBanner() {
    _bannerSub?.cancel();
    _bannerSub = FirebaseFirestore.instance
        .collection('banner')
        .doc('home')
        .snapshots()
        .listen(
          (snapshot) {
            _bannerDoc.value = snapshot.data();
            _isBannerLoaded(true);
          },
          // 규칙·네트워크 문제로 실패해도 홈의 다른 섹션은 살아 있어야 한다.
          onError: (_) {
            _bannerDoc.value = null;
            _isBannerLoaded(true);
          },
        );
  }

  // ── 날씨 ──
  Future<void> selectResort(ResortModel resort) async {
    _resort.value = resort;
    await _fetchWeather(resort);
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
}
