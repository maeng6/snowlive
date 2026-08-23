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

/// 칩 종류. 목업의 칩은 **리조트 그룹**과 **종목**이 한 줄에 섞여 있다.
enum CrewHomeChipKind { resort, ski, board }

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

/// 목업 순서대로 칩을 만든다 — 리조트 그룹(응답 순서) → `스키` → `스노보드`.
/// 크루가 하나도 없는 그룹은 칩을 만들지 않는다(눌러도 빈 화면이므로).
List<CrewHomeChip> crewHomeChips(CrewHomeModel home) {
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
  if (home.skiMajority.isNotEmpty) {
    chips.add(const CrewHomeChip(kind: CrewHomeChipKind.ski, label: '스키'));
  }
  if (home.boardMajority.isNotEmpty) {
    chips.add(const CrewHomeChip(kind: CrewHomeChipKind.board, label: '스노보드'));
  }
  return chips;
}

/// 선택한 칩에 해당하는 크루 목록(그리드에 뿌릴 것).
List<CrewCard> crewsForChip(CrewHomeModel home, CrewHomeChip? chip) {
  if (chip == null) return const [];
  switch (chip.kind) {
    case CrewHomeChipKind.ski:
      return home.skiMajority;
    case CrewHomeChipKind.board:
      return home.boardMajority;
    case CrewHomeChipKind.resort:
      for (final group in home.byResort) {
        if (group.resortId == chip.resortId) return group.crews;
      }
      return const [];
  }
}

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
