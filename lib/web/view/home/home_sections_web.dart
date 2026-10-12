import 'package:com.snowlive/core/model/m_communityList.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:intl/intl.dart';

/// 홈 화면의 순수 가공 로직. 위젯 없이 단위 테스트할 수 있게 여기 모았다
/// (크루홈·크루기록 화면과 같은 구조).

/// 오늘의 랭킹은 목업처럼 8위까지 보여준다.
const int kHomeRankingCount = 8;

// ────────────────────────────────── 배너 ──────────────────────────────────

/// 홈 상단 배너(히어로 슬라이드) 한 장. **웹 전용** Firestore 문서
/// [kHomeHeroBannerDoc]에서 읽는다.
///
/// 앱이 쓰는 `banner/home`과 분리돼 있다 — 웹은 앱에 없는 값(문구·버튼·모바일
/// 전용 이미지)이 필요하고 이미지 비율도 달라서, 한 문서를 같이 쓰면 한쪽 사정에
/// 다른 쪽이 끌려간다. 앱 문서는 이 코드가 건드리지 않는다.
class HomeBanner {
  final String imageUrl;
  final String landingUrl;

  /// 모바일(<768px) 전용 세로 이미지. 없으면 [imageUrl]을 그대로 쓴다.
  final String? imageUrlMobile;

  /// 오버레이 문구/버튼. 없으면 해당 요소를 그리지 않는다.
  final String? title;
  final String? subtitle;
  final String? buttonLabel;

  /// 버튼 클릭 시 새 탭으로 열 URL. 없으면 [landingUrl]로 폴백한다.
  final String? buttonUrl;

  const HomeBanner({
    required this.imageUrl,
    required this.landingUrl,
    this.imageUrlMobile,
    this.title,
    this.subtitle,
    this.buttonLabel,
    this.buttonUrl,
  });
}

/// 배너 자동 롤링 간격(앱과 동일).
const Duration kHomeBannerInterval = Duration(seconds: 5);

/// 웹 홈 히어로 배너 문서. 앱이 쓰는 `banner/home`과 **다른 문서**다.
const String kHomeHeroBannerCollection = 'banner';
const String kHomeHeroBannerDoc = 'homeHeroWeb';

/// `banner/homeHeroWeb` 문서 → 노출할 배너 목록.
///
/// 문서에는 `slides` 배열 하나만 있고, **배너 하나가 맵 하나**다(평행 배열이
/// 아니라서 순서를 바꾸거나 중간을 지워도 짝이 깨지지 않는다).
///
/// 맵 키: `visible`(bool) · `imageUrl` · `imageUrlMobile` · `landingUrl` ·
/// `title` · `subtitle` · `buttonLabel` · `buttonUrl`.
/// 운영 실수에 대비해 타입이 어긋나는 값은 조용히 건너뛴다.
List<HomeBanner> homeVisibleBanners(Map<String, dynamic>? data) {
  final slides = data?['slides'];
  if (slides is! List) return const [];

  // 빈 문자열은 "값 없음"으로 본다(콘솔에서 지우는 대신 비워두는 경우가 많다).
  String? stringOf(Map slide, String key) {
    final value = slide[key];
    if (value is! String || value.isEmpty) return null;
    return value;
  }

  final result = <HomeBanner>[];
  for (final slide in slides) {
    if (slide is! Map) continue;
    // visible을 켜야 보이는 쪽이 안전하다(빠뜨리면 숨김).
    if (slide['visible'] != true) continue;
    // 사진이 없는 배너는 그릴 수 없다.
    final image = stringOf(slide, 'imageUrl');
    if (image == null) continue;

    result.add(HomeBanner(
      imageUrl: image,
      landingUrl: stringOf(slide, 'landingUrl') ?? '',
      imageUrlMobile: stringOf(slide, 'imageUrlMobile'),
      // Firestore 콘솔에서는 개행을 `\n` 문자로 넣으므로 실제 줄바꿈으로 바꾼다.
      title: stringOf(slide, 'title')?.replaceAll(r'\n', '\n'),
      subtitle: stringOf(slide, 'subtitle')?.replaceAll(r'\n', '\n'),
      buttonLabel: stringOf(slide, 'buttonLabel'),
      buttonUrl: stringOf(slide, 'buttonUrl'),
    ));
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

// ──────────────────────────────── 커뮤니티 ────────────────────────────────

/// 홈 커뮤니티 섹션에 받아 두는 최신글 수(PC·태블릿 2열 × 3행).
const int kHomeCommunityFetchCount = 6;

/// 폭별로 보여줄 글 수 — PC·태블릿 6(2열 × 3행) / 모바일 4(1열).
int homeCommunityCount({required bool isMobile}) => isMobile ? 4 : kHomeCommunityFetchCount;

/// 목록 응답을 **한 건씩** 파싱한다. `Community.fromJson`은 항목별 방어가 없어서
/// 글 한 건이 깨지면 섹션 전체가 비었다(커뮤니티 목록 화면과 같은 방어).
List<Community> homeParseCommunity(Object? rawResults) {
  if (rawResults is! List) return const [];
  final parsed = <Community>[];
  for (final item in rawResults) {
    if (item is! Map<String, dynamic>) continue;
    try {
      parsed.add(Community.fromJson(item));
    } catch (_) {
      // 깨진 글은 건너뛴다.
    }
  }
  return parsed;
}

/// 작성 시각을 `방금 전 / n분 전 / n시간 전 / n일 전 / n개월 전 / n년 전`으로.
/// 앱(`TimeStamp.getAgo`)과 같은 표기 — 그 유틸은 Firebase를 물고 있어 홈 데이터
/// 규칙 파일(순수 Dart)에서는 쓰지 않고 같은 규칙을 둔다. 파싱 실패면 빈 문자열.
String homeTimeAgo(String? uploadTime, {DateTime? now}) {
  final parsed = uploadTime == null ? null : DateTime.tryParse(uploadTime);
  if (parsed == null) return '';
  final diff = (now ?? DateTime.now()).difference(parsed.toLocal());
  if (diff.inDays >= 365) return '${diff.inDays ~/ 365}년 전';
  if (diff.inDays >= 30) return '${diff.inDays ~/ 30}개월 전';
  if (diff.inDays >= 1) return '${diff.inDays}일 전';
  if (diff.inHours >= 1) return '${diff.inHours}시간 전';
  if (diff.inMinutes >= 1) return '${diff.inMinutes}분 전';
  return '방금 전';
}

/// 글 아래 메타 줄 — `닉네임 · 3시간 전 · 조회 52`. 빠진 값은 건너뛴다.
String homeCommunityMeta(Community community, {DateTime? now}) {
  final name = community.userInfo?.displayName?.trim() ?? '';
  final ago = homeTimeAgo(community.uploadTime, now: now);
  final views = community.viewsCount;
  return [
    if (name.isNotEmpty) name,
    if (ago.isNotEmpty) ago,
    if (views != null) '조회 ${NumberFormat('#,###').format(views)}',
  ].join(' · ');
}

// ─────────────────────────────── 우리 크루는요 ───────────────────────────────

/// `우리 크루는요` 카드 하나.
///
/// 소스는 크루홈 집계의 공개 크루톡(`crew_talks`)이다. 크루톡에는 제목 필드가 없어서
/// **본문 첫 줄을 제목**으로, 나머지를 설명으로 쓴다(목업의 두 줄 구성).
class HomeCrewCard {
  /// 이 카드가 보여주는 크루톡(라이브톡) id — 탭하면 라이브톡 상세로 이동.
  final int? talkId;
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
    required this.talkId,
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
      talkId: talk.livetalkId,
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

/// 홈 중고거래 캐러셀 최대 페이지 수. 첫 페이지 API는 30개를 주는데 다 넣으면 점이
/// PC 5 · 태블릿 8 · 모바일 15개가 된다 → 폭과 상관없이 3페이지(PC 18 · 태블릿 12 ·
/// 모바일 6개)까지만, 더 보려면 `더보기`(사용자 확정 2026-10-11).
const int kHomeFleamarketMaxPages = 3;

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

/// 새 채팅 말풍선이 떠 있는 시간(요청: 3초 후 사라짐).
const Duration kHomeChatBubbleDuration = Duration(seconds: 3);

/// 접힌 바 아래에 동시에 쌓이는 말풍선 최대 개수.
const int kHomeChatMaxBubbles = 3;

/// 이 스크롤 오프셋을 넘으면 오픈 채팅을 아이콘으로 접는다.
const double kHomeChatCollapseOffset = 80;
