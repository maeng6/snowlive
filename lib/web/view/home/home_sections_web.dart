import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:intl/intl.dart';

/// 홈 화면의 순수 가공 로직. 위젯 없이 단위 테스트할 수 있게 여기 모았다
/// (크루홈·크루기록 화면과 같은 구조).

/// 오늘의 랭킹은 목업처럼 8위까지 보여준다.
const int kHomeRankingCount = 8;

// ────────────────────────────────── 배너 ──────────────────────────────────

/// 홈 상단 배너 한 장. 앱과 같은 Firestore 문서(`banner/home`)를 읽는다.
class HomeBanner {
  final String imageUrl;
  final String landingUrl;

  const HomeBanner({required this.imageUrl, required this.landingUrl});
}

/// 배너 자동 롤링 간격(앱과 동일).
const Duration kHomeBannerInterval = Duration(seconds: 5);

/// `banner/home` 문서 → 노출할 배너 목록.
///
/// 앱과 동일한 구조다 — `imageUrl`/`landingUrl`/`visible` **세 배열이 같은 인덱스로**
/// 짝지어져 있고, 운영에서 `visible`을 껐다 켜서 배너를 노출/숨긴다.
/// 배열 길이가 서로 다를 수 있으므로(운영 실수) 인덱스마다 안전하게 접근한다.
List<HomeBanner> homeVisibleBanners(Map<String, dynamic>? data) {
  if (data == null) return const [];
  final images = (data['imageUrl'] as List?) ?? const [];
  final landings = (data['landingUrl'] as List?) ?? const [];
  final visibles = (data['visible'] as List?) ?? const [];

  final result = <HomeBanner>[];
  for (var i = 0; i < images.length; i++) {
    // visible이 없는 인덱스는 노출하지 않는다(운영에서 켜야 보이는 쪽이 안전하다).
    if (i >= visibles.length || visibles[i] != true) continue;
    final image = images[i];
    if (image is! String || image.isEmpty) continue;
    final landing = i < landings.length && landings[i] is String ? landings[i] as String : '';
    result.add(HomeBanner(imageUrl: image, landingUrl: landing));
  }
  return result;
}

// ────────────────────────────────── 날씨 ──────────────────────────────────

/// 기상청 응답(`pty` 강수형태 / `sky` 하늘상태)과 시각 → 날씨 아이콘 에셋.
/// 앱 `WeatherModel.getWeatherIcon`과 같은 판정을 **Widget이 아니라 경로**로 돌려준다
/// (웹은 크기를 화면마다 다르게 쓰고, 테스트에서도 확인할 수 있어야 한다).
String homeWeatherIconAsset({
  required String pty,
  required String sky,
  required DateTime now,
}) {
  // 강수 없음
  if (pty == '0') {
    // 밤(07시 이전·18시 이후)은 달 아이콘.
    if (now.hour < 7 || now.hour > 17) return 'assets/imgs/weather/icon_weather.png';
    if (sky == '4') return 'assets/imgs/weather/icon_weather_cloud.png';
    return 'assets/imgs/weather/icon_weather_sun.png';
  }
  // 1 비 / 2 비·눈 / 4 소나기 → 비, 3 눈 → 눈
  if (pty == '3') return 'assets/imgs/weather/icon_weather_snow.png';
  return 'assets/imgs/weather/icon_weather_rain.png';
}

/// `2024.12.21 (토)` — 목업의 날씨 카드 둘째 줄.
String homeWeatherDateLabel(DateTime date) =>
    DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(date);

/// `2027. 01. 14` — `오늘의 랭킹` 옆 검은 배지.
String homeTodayBadgeLabel(DateTime date) => DateFormat('yyyy. MM. dd').format(date);

/// 소수점이 섞여 오는 기온(`23.4`) → `23`. 값이 없으면 `-`.
String homeTempLabel(dynamic raw) {
  final text = raw?.toString().trim() ?? '';
  if (text.isEmpty || text == '-') return '-';
  final value = double.tryParse(text);
  if (value == null) return text;
  return value.round().toString();
}

/// 홈 날씨 카드가 쓰는 리조트. 정적 [resortList]가 nx/ny와 네이버·웹캠·슬로프·셔틀
/// 링크를 모두 갖고 있어서 추가 API가 필요 없다.
List<ResortModel> get homeResorts => resortList;

/// 처음 보여줄 리조트. 로그인 유저는 자주 가는 스키장, 게스트는 목업의 휘닉스파크.
///
/// `favorite_resort`는 서버 리조트 id인데 정적 목록의 `index`와 값 체계가 같다
/// (앱이 `resortList[favorite_resort]`로 바로 쓰고 있다).
ResortModel homeDefaultResort(int? favoriteResortId) {
  if (favoriteResortId != null) {
    for (final resort in homeResorts) {
      if (resort.index == favoriteResortId) return resort;
    }
  }
  for (final resort in homeResorts) {
    if (resort.resortNickname == '휘닉스') return resort;
  }
  return homeResorts.first;
}

// ─────────────────────────────── 우리 크루는요 ───────────────────────────────

/// `우리 크루는요` 카드 하나.
///
/// 소스는 크루홈 집계의 공개 크루톡(`crew_talks`)이다. 크루톡에는 제목 필드가 없어서
/// **본문 첫 줄을 제목**으로, 나머지를 설명으로 쓴다(목업의 두 줄 구성).
class HomeCrewCard {
  final int? crewId;
  final String crewName;
  final String? crewLogoUrl;
  final String? crewColor;

  /// 카드 상단 사진. 없으면 화면이 크루 색 + 기본 로고로 채운다.
  final String? imageUrl;
  final String title;
  final String description;

  /// 신규 생성 크루면 목업처럼 `NEW` 배지를 붙인다.
  final bool isNew;

  const HomeCrewCard({
    required this.crewId,
    required this.crewName,
    required this.crewLogoUrl,
    required this.crewColor,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.isNew,
  });
}

/// 본문에서 제목으로 쓸 첫 줄.
String homeCrewCardTitle(String? description) {
  final lines = (description ?? '')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  return lines.isEmpty ? '' : lines.first;
}

/// 제목으로 쓴 첫 줄을 뺀 나머지 본문(한 줄로 이어 붙인다).
String homeCrewCardBody(String? description) {
  final lines = (description ?? '')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (lines.length <= 1) return '';
  return lines.sublist(1).join(' ');
}

/// 크루홈 집계 → `우리 크루는요` 카드 목록.
///
/// 크루톡은 서버가 이미 공개만 주지만 `secret == true`를 한 번 더 걸러 비공개가
/// 새는 경로를 없앤다(크루홈 갤러리와 같은 방어).
List<HomeCrewCard> homeCrewCards(CrewHomeModel? home) {
  if (home == null) return const [];

  final crews = <int, CrewCard>{};
  void collect(List<CrewCard> list) {
    for (final crew in list) {
      final id = crew.crewId;
      if (id != null) crews.putIfAbsent(id, () => crew);
    }
  }

  collect(home.newestCrews);
  collect(home.slopeOccupied);
  collect(home.diverseResort);
  collect(home.liveonToday);
  collect(home.todayScore);
  collect(home.mostMembers);
  collect(home.liveonSeason);
  for (final group in home.byResort) {
    collect(group.crews);
  }

  final newestIds = {
    for (final crew in home.newestCrews)
      if (crew.crewId != null) crew.crewId!,
  };

  final cards = <HomeCrewCard>[];
  for (final LiveTalk talk in home.crewTalks) {
    if (talk.secret == true) continue;
    final crewId = talk.crewId;
    final crew = crewId == null ? null : crews[crewId];
    final title = homeCrewCardTitle(talk.description);
    if (title.isEmpty) continue;
    cards.add(HomeCrewCard(
      crewId: crewId,
      crewName: crew?.crewName ?? '',
      crewLogoUrl: crew?.crewLogoUrl,
      crewColor: crew?.color,
      imageUrl: (talk.imageUrl?.isNotEmpty ?? false) ? talk.imageUrl : null,
      title: title,
      description: homeCrewCardBody(talk.description),
      isNew: crewId != null && newestIds.contains(crewId),
    ));
  }
  return cards;
}

// ───────────────────────────────── 캐러셀 ─────────────────────────────────

/// 목록을 [size]개씩 끊어 캐러셀 페이지로 만든다(목업의 `‹ ›` 한 번에 한 페이지).
List<List<T>> homeCarouselPages<T>(List<T> items, int size) {
  if (items.isEmpty || size <= 0) return const [];
  final pages = <List<T>>[];
  for (var start = 0; start < items.length; start += size) {
    final end = start + size;
    pages.add(items.sublist(start, end > items.length ? items.length : end));
  }
  return pages;
}

// ─────────────────────────────── 오픈 채팅 ───────────────────────────────

/// 새 채팅 말풍선이 떠 있는 시간(요청: 5초 후 사라짐).
const Duration kHomeChatBubbleDuration = Duration(seconds: 5);

/// 이 스크롤 오프셋을 넘으면 오픈 채팅을 아이콘으로 접는다(요청).
const double kHomeChatCollapseOffset = 80;
