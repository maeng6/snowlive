import 'package:com.snowlive/core/model/m_dailyRidingCard.dart';
// 시즌 enum만 좁게 가져온다 — 이 파일 전체를 import하면 모바일 라우트 테이블(dart:io)까지
// 딸려와 웹에서 컴파일되지 않는다(다른 웹 화면들과 같은 방식).
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart'
    show RankingFilter_season;

/// 라이딩 기록 카드 화면의 순수 가공 함수 모음(위젯 없이 단위 테스트할 수 있게 분리).

/// 시즌 탭 목록(최신 시즌 먼저). 다른 웹 화면들과 같은 enum을 쓴다.
///
/// ⚠️ 앱은 `25/26`만 두지만(`vm_ridingCard.dart:93`) 시즌 카드 API는 `season`을 받아
/// 지난 시즌도 준다(실측: `2425` 200) → 목업처럼 두 개를 노출한다. `2324`는 다른
/// 화면들과 마찬가지로 서버에 기록실 모델이 없어 뺀다.
List<RankingFilter_season> ridingCardSeasons() => RankingFilter_season.values
    .where((s) => s.dbSeason != '2324')
    .toList();

/// `2526` → 시즌 시작 연도(2025). 시즌은 그 해 10월부터 다음 해 9월까지로 본다.
int? ridingCardSeasonStartYear(String dbSeason) {
  if (dbSeason.length != 4) return null;
  final prefix = int.tryParse(dbSeason.substring(0, 2));
  if (prefix == null) return null;
  return 2000 + prefix;
}

/// 데일리 카드 목록 API에는 **시즌 파라미터가 없다**(실측: `user_id`만 받는다) →
/// 날짜로 그 시즌 범위(시작 연도 10월 ~ 다음 해 9월)만 남긴다.
bool ridingCardIsInSeason(String? date, String dbSeason) {
  final startYear = ridingCardSeasonStartYear(dbSeason);
  if (startYear == null || date == null) return false;
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return false;
  final start = DateTime(startYear, 10, 1);
  final end = DateTime(startYear + 1, 10, 1);
  return !parsed.isBefore(start) && parsed.isBefore(end);
}

List<DailyRidingCard> ridingCardsForSeason(
  List<DailyRidingCard> cards,
  String dbSeason,
) =>
    cards.where((c) => ridingCardIsInSeason(c.date, dbSeason)).toList();

/// 한 달 묶음.
class RidingCardMonth {
  /// `yyyy-MM`(정렬·key용).
  final String key;
  final int year;
  final int month;
  final List<DailyRidingCard> cards;

  const RidingCardMonth({
    required this.key,
    required this.year,
    required this.month,
    required this.cards,
  });

  String get title => '$month월';
}

/// 월별로 묶는다 — 월도 카드도 **최신순**(목업).
List<RidingCardMonth> groupRidingCardsByMonth(List<DailyRidingCard> cards) {
  final sorted = [...cards]..sort((a, b) => (b.date ?? '').compareTo(a.date ?? ''));
  final order = <String>[];
  final buckets = <String, List<DailyRidingCard>>{};

  for (final card in sorted) {
    final date = DateTime.tryParse(card.date ?? '');
    if (date == null) continue;
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    if (!buckets.containsKey(key)) {
      buckets[key] = [];
      order.add(key);
    }
    buckets[key]!.add(card);
  }

  return [
    for (final key in order)
      RidingCardMonth(
        key: key,
        year: int.parse(key.split('-')[0]),
        month: int.parse(key.split('-')[1]),
        cards: buckets[key]!,
      ),
  ];
}

const List<String> _kWeekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

/// 그리드 카드 왼쪽 위 배지 — `31(금)`.
String ridingCardDayBadge(String? date) {
  final parsed = DateTime.tryParse(date ?? '');
  if (parsed == null) return '';
  return '${parsed.day}(${_kWeekdayLabels[parsed.weekday - 1]})';
}

/// 목록 행의 날짜 — `31일 (금)`.
String ridingCardDayLabel(String? date) {
  final parsed = DateTime.tryParse(date ?? '');
  if (parsed == null) return '';
  return '${parsed.day}일 (${_kWeekdayLabels[parsed.weekday - 1]})';
}

/// 저장할 파일명 — `snowlive_riding_2026-03-22.png`.
String ridingCardFileName(String? date) {
  final safe = (date ?? '').replaceAll(RegExp(r'[^0-9-]'), '');
  return 'snowlive_riding_${safe.isEmpty ? 'card' : safe}.png';
}

/// 시즌 카드 저장 파일명 — `snowlive_season_2526.png`.
String ridingCardSeasonFileName(String dbSeason) => 'snowlive_season_$dbSeason.png';
