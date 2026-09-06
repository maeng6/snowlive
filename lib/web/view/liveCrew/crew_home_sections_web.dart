import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';

/// 크루홈 응답(`GET /api/crew/home/`)을 목업 섹션으로 가공하는 순수 함수 모음.
///
/// 화면에서 분리해 둔 이유는 하나다 — 위젯을 띄우지 않고 단위 테스트할 수 있다.
/// (친구 화면의 `alertCategorySubListFor`와 같은 방식)

/// 크루홈 집계 API가 리스트마다 잘라 주는 개수(실측: 리조트별 30개, 종목별 30개).
/// 딱 이 개수면 더 있는데 잘린 것으로 본다.
const int kCrewHomeListCap = 30;

/// 이 목록이 서버에서 잘린 것 같은지. 잘렸으면 화면이 `전체보기` 진입점을 띄운다.
///
/// 리조트 칩만 전체를 다시 받을 수 있다(`GET /api/crew/?base_resort_id=`로 휘닉스
/// 169개까지 확인). **종목(스키/스노보드)은 집계 전용 리스트라 전체 조회 API가 없다.**
bool crewHomeListIsCapped(CrewHomeChip? chip, List<CrewCard> crews) =>
    chip?.kind == CrewHomeChipKind.resort && crews.length >= kCrewHomeListCap;

/// 스키/보드가 많은 크루의 기준(사용자 확정: 크루원 10명 이상 중 **70% 이상**).
///
/// ⚠️ 서버는 `10명 이상 + 50% 초과`로 보낸다(실측: 스키 리스트에 60.6%·64.3% 섞임) →
/// 웹에서 한 번 더 거른다. 서버 기준이 70%로 바뀌면 이 상수를 쓰는 곳만 지우면 된다.
const double kCrewMajorityMinRatio = 0.7;

/// 스키/보드 리스트를 기준 비율로 거른다. 비율을 모르는 항목은 버린다(기준을 못 만족).
List<CrewCard> crewMajorityCrews(List<CrewCard> raw) =>
    raw.where((c) => (c.ratio ?? 0) >= kCrewMajorityMinRatio).toList();

/// 상단 캐러셀 종류. 서버 `top`의 5개 리스트와 1:1이다.
enum CrewHomeSectionKind { slopeOccupied, newest, liveonToday, diverseResort, todayScore }

/// 상단 캐러셀 한 개의 정의. 화면은 [crewHomeSections] 순서대로 그리기만 한다.
class CrewHomeSection {
  final CrewHomeSectionKind kind;

  /// 두 줄 제목(`\n` 포함).
  final String title;
  final String subtitle;

  /// 카드가 없을 때 레일 자리에 넣을 문구. 비시즌에는 `오늘 …` 두 섹션이 비어 있다.
  final String emptyMessage;
  final List<CrewCard> crews;

  /// 1위 카드를 크루 색으로 채울지(목업은 첫 섹션만 그렇다).
  final bool highlightFirst;

  const CrewHomeSection({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.crews,
    required this.highlightFirst,
  });
}

/// 상단 캐러셀 5개.
///
/// ⚠️ `slope_occupied`는 **오늘이 아니라 이번 시즌 누적**이다(실측: 비시즌인 8월에도 값이
/// 차 있고, 진짜 오늘 리스트인 `liveon_today`·`today_score`는 0개다) → 제목도 시즌으로 적는다.
/// 비어 있는 섹션도 목록에 남긴다 — 화면이 안내 문구를 보여준다(사용자 확정).
List<CrewHomeSection> crewHomeSections(CrewHomeModel home) => [
      CrewHomeSection(
        kind: CrewHomeSectionKind.slopeOccupied,
        title: '이번 시즌\n슬로프를 많이 점령한 크루',
        subtitle: '어느 크루가 최다 슬로프를 점령했을까?',
        emptyMessage: '아직 시즌 기록이 없어요',
        crews: home.slopeOccupied,
        highlightFirst: true,
      ),
      CrewHomeSection(
        kind: CrewHomeSectionKind.newest,
        title: '새로 만들어진\n신규 크루',
        subtitle: '막 생긴 크루를 먼저 만나보세요',
        emptyMessage: '아직 새로 생긴 크루가 없어요',
        crews: home.newestCrews,
        highlightFirst: false,
      ),
      CrewHomeSection(
        kind: CrewHomeSectionKind.liveonToday,
        title: '오늘 라이브온을\n많이 한 크루',
        subtitle: '지금 슬로프에 가장 많이 모인 크루',
        emptyMessage: '오늘은 아직 라이브온한 크루가 없어요',
        crews: home.liveonToday,
        highlightFirst: false,
      ),
      CrewHomeSection(
        kind: CrewHomeSectionKind.diverseResort,
        title: '다양한 스키장에서\n라이딩한 크루',
        subtitle: '여러 스키장을 골고루 타는 크루는?',
        emptyMessage: '아직 기록이 없어요',
        crews: home.diverseResort,
        highlightFirst: false,
      ),
      CrewHomeSection(
        kind: CrewHomeSectionKind.todayScore,
        title: '오늘 점수가\n많은 크루',
        subtitle: '오늘 랭킹 점수를 가장 많이 쌓은 크루',
        emptyMessage: '오늘은 아직 점수를 쌓은 크루가 없어요',
        crews: home.todayScore,
        highlightFirst: false,
      ),
    ];

/// 칩 종류. 1단은 `스키장별`·순위 2종·종목 2종이고, `resort`는 **2단(스키장) 칩**이다.
enum CrewHomeChipKind { byResort, mostMembers, liveonSeason, ski, board, resort }

/// `어떤 크루가 있을까요?` 줄의 칩 하나.
class CrewHomeChip {
  final CrewHomeChipKind kind;

  /// 칩에 찍히는 글자. 리조트는 `resort_fullname`(곤지암리조트 · 휘닉스파크 …).
  final String label;

  /// 리조트 칩일 때만 채운다.
  final int? resortId;

  const CrewHomeChip({required this.kind, required this.label, this.resortId});

  @override
  bool operator ==(Object other) =>
      other is CrewHomeChip && other.kind == kind && other.resortId == resortId;

  @override
  int get hashCode => Object.hash(kind, resortId);
}

/// 1단 칩. 사용자가 확정한 순서 — `스키장별` · `멤버 많은 순` ·
/// `이번 시즌 라이브온 많이 한 순` · `스키가 많은 크루` · `보드가 많은 크루`.
/// 해당 목록이 비면 눌러도 빈 화면이므로 칩을 만들지 않는다.
List<CrewHomeChip> crewHomeChips(CrewHomeModel home) {
  final chips = <CrewHomeChip>[];
  if (crewHomeResortChips(home).isNotEmpty) {
    chips.add(const CrewHomeChip(kind: CrewHomeChipKind.byResort, label: '스키장별'));
  }
  if (home.mostMembers.isNotEmpty) {
    chips.add(const CrewHomeChip(kind: CrewHomeChipKind.mostMembers, label: '멤버 많은 순'));
  }
  if (home.liveonSeason.isNotEmpty) {
    chips.add(const CrewHomeChip(
        kind: CrewHomeChipKind.liveonSeason, label: '이번 시즌 라이브온 많이 한 순'));
  }
  if (crewMajorityCrews(home.skiMajority).isNotEmpty) {
    chips.add(const CrewHomeChip(kind: CrewHomeChipKind.ski, label: '스키가 많은 크루'));
  }
  if (crewMajorityCrews(home.boardMajority).isNotEmpty) {
    chips.add(const CrewHomeChip(kind: CrewHomeChipKind.board, label: '보드가 많은 크루'));
  }
  return chips;
}

/// 2단(스키장) 칩. `스키장별`을 고른 뒤에만 그린다. 라벨은 `resort_fullname`
/// (곤지암리조트 · 휘닉스파크 …)이고 크루가 없는 리조트는 뺀다.
List<CrewHomeChip> crewHomeResortChips(CrewHomeModel home) {
  final chips = <CrewHomeChip>[];
  for (final group in home.byResort) {
    if (group.crews.isEmpty) continue;
    final label = (group.resortFullname?.isNotEmpty ?? false)
        ? group.resortFullname!
        : (group.resortNickname ?? '');
    if (label.isEmpty) continue;
    chips.add(CrewHomeChip(
      kind: CrewHomeChipKind.resort,
      label: label,
      resortId: group.resortId,
    ));
  }
  return chips;
}

/// 선택한 칩에 해당하는 크루 목록(그리드에 뿌릴 것).
///
/// `스키장별`(1단) 자체는 목록이 없다 — 화면이 2단에서 고른 리조트 칩을 넘겨야 한다.
List<CrewCard> crewsForChip(CrewHomeModel home, CrewHomeChip? chip) {
  if (chip == null) return const [];
  switch (chip.kind) {
    case CrewHomeChipKind.byResort:
      return const [];
    case CrewHomeChipKind.mostMembers:
      return home.mostMembers;
    case CrewHomeChipKind.liveonSeason:
      return home.liveonSeason;
    case CrewHomeChipKind.ski:
      return crewMajorityCrews(home.skiMajority);
    case CrewHomeChipKind.board:
      return crewMajorityCrews(home.boardMajority);
    case CrewHomeChipKind.resort:
      for (final group in home.byResort) {
        if (group.resortId == chip.resortId) return group.crews;
      }
      return const [];
  }
}

/// 이 칩의 목록이 **서버 상위 30개**인지. 전체 조회 API가 없어 화면 이동은 못 하고
/// 문구로만 알린다(리조트 칩은 `crewHomeListIsCapped`로 전체보기 진입점을 만든다).
bool crewHomeChipIsRankedTop(CrewHomeChip? chip) =>
    chip?.kind == CrewHomeChipKind.mostMembers || chip?.kind == CrewHomeChipKind.liveonSeason;

/// `crewId` → 크루 카드. 갤러리 사진의 크루 이름·로고·리조트를 찾는 데 쓴다
/// (`LiveTalk`에는 `crew_id`만 있고 크루명이 없다). 응답 안의 모든 리스트를 훑는다.
Map<int, CrewCard> crewIndexOf(CrewHomeModel home) {
  final index = <int, CrewCard>{};
  void add(Iterable<CrewCard> crews) {
    for (final crew in crews) {
      final id = crew.crewId;
      if (id == null) continue;
      index.putIfAbsent(id, () => crew);
    }
  }

  add(home.slopeOccupied);
  add(home.newestCrews);
  add(home.liveonToday);
  add(home.diverseResort);
  add(home.todayScore);
  add(home.mostMembers);
  add(home.liveonSeason);
  add(home.skiMajority);
  add(home.boardMajority);
  for (final group in home.byResort) {
    add(group.crews);
  }
  return index;
}

/// `base_resort_id` → 리조트 전체 이름. 카드/모달 둘째 줄이 목업처럼 `휘닉스파크`
/// (전체 이름)인데 `CrewCard`에는 별명(`휘닉스`)만 있어서 그룹에서 끌어온다.
Map<int, String> crewResortFullnames(CrewHomeModel home) {
  final names = <int, String>{};
  for (final group in home.byResort) {
    final id = group.resortId;
    final name = group.resortFullname;
    if (id == null || name == null || name.isEmpty) continue;
    names[id] = name;
  }
  return names;
}

/// 갤러리에 그릴 사진. 서버(`crew_talks`)가 이미 공개만 주지만
/// **`secret == true`를 한 번 더 걸러** 비공개 사진이 새는 경로를 없앤다.
List<LiveTalk> crewGalleryTalks(CrewHomeModel home) {
  return home.crewTalks
      .where((talk) => talk.secret != true && (talk.imageUrl?.isNotEmpty ?? false))
      .toList();
}

/// 목록을 **열 우선**으로 [columns]개 열에 나눈다(목업은 한 열을 위에서 아래로 채운다).
/// 30개를 3열로 나누면 10/10/10.
List<List<CrewCard>> splitIntoColumns(List<CrewCard> crews, int columns) {
  if (columns <= 1 || crews.isEmpty) return [crews];
  final perColumn = (crews.length / columns).ceil();
  final result = <List<CrewCard>>[];
  for (var start = 0; start < crews.length; start += perColumn) {
    final end = start + perColumn;
    result.add(crews.sublist(start, end > crews.length ? crews.length : end));
  }
  return result;
}

/// 카드·모달 둘째 줄. 목업은 `올두맹 · 휘닉스파크`(소개 · 리조트 전체이름) 순서다.
/// 목록 행은 반대 순서(`휘닉스 · 중앙대 보드 동아리`)를 쓴다 — 목업 그대로.
String crewCardSubtitle(CrewCard crew, {Map<int, String> resortFullnames = const {}}) {
  final resortId = crew.baseResortId;
  final resort = (resortId != null ? resortFullnames[resortId] : null) ??
      crew.baseResortNickname ??
      '';
  final desc = crew.description?.trim().replaceAll('\n', ' ') ?? '';
  return [
    if (desc.isNotEmpty) desc,
    if (resort.isNotEmpty) resort,
  ].join(' · ');
}

/// 목록 행 보조줄. `휘닉스 · 중앙대 보드 동아리`(별명 · 소개) — 웹 랭킹 크루 행과 같다.
String crewRowSubtitle(CrewCard crew) {
  final nick = crew.baseResortNickname?.trim() ?? '';
  final desc = crew.description?.trim().replaceAll('\n', ' ') ?? '';
  return [
    if (nick.isNotEmpty) nick,
    if (desc.isNotEmpty) desc,
  ].join(' · ');
}
