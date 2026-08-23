import 'package:com.snowlive/core/model/m_crewRecordRoom.dart';
// 시즌 enum만 좁게 가져온다 — 이 파일 전체를 import하면 모바일 라우트 테이블(dart:io)까지
// 딸려와 웹에서 컴파일되지 않는다(랭킹 기록실 화면과 같은 방식).
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart'
    show RankingFilter_season;

/// 서버에 데이터가 없는 시즌. 세 record-room 엔드포인트 전부 400을 준다
/// (실측: `Ranking_record_2324 모델을 찾을 수 없습니다`). 앱은 이 시즌만 별도 베타
/// API로 그리는데 그 데이터원이 웹에는 없어서 탭 자체를 만들지 않는다(사용자 확정).
const String kUnsupportedRecordSeason = '2324';

/// 일별 현황 연도 탭의 가장 오래된 해. 서버 데이터도 2025-11부터 있다(실측).
const int kCrewRecordFirstYear = 2025;

/// 기록실 시즌 탭 목록(최신 시즌 먼저).
List<RankingFilter_season> crewRecordSeasons() => RankingFilter_season.values
    .where((s) => s.dbSeason != kUnsupportedRecordSeason)
    .toList();

/// 일별 현황 연도 탭 목록(최신 연도 먼저).
List<int> crewRecordYears(int currentYear) {
  final last = currentYear < kCrewRecordFirstYear ? kCrewRecordFirstYear : currentYear;
  return [for (var y = last; y >= kCrewRecordFirstYear; y--) y];
}

/// 한 달 묶음. 서버가 날짜 내림차순으로 주므로 그 순서를 그대로 유지한다.
class CrewRecordMonth {
  /// `yyyy-MM`. 위젯 key로도 쓴다.
  final String key;
  final int year;
  final int month;
  final List<CrewRidingRecord> records;

  const CrewRecordMonth({
    required this.key,
    required this.year,
    required this.month,
    required this.records,
  });

  String get title => '$month월';
}

/// 응답 목록을 월별로 묶는다. 날짜를 못 읽는 항목은 버린다(그리려면 날짜가 필요하다).
List<CrewRecordMonth> groupCrewRecordsByMonth(List<CrewRidingRecord> records) {
  final order = <String>[];
  final buckets = <String, List<CrewRidingRecord>>{};

  for (final record in records) {
    final date = crewRecordDateOf(record);
    if (date == null) continue;
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    if (!buckets.containsKey(key)) {
      buckets[key] = [];
      order.add(key);
    }
    buckets[key]!.add(record);
  }

  return [
    for (final key in order)
      CrewRecordMonth(
        key: key,
        year: int.parse(key.split('-')[0]),
        month: int.parse(key.split('-')[1]),
        records: buckets[key]!,
      ),
  ];
}

DateTime? crewRecordDateOf(CrewRidingRecord record) => DateTime.tryParse(record.date ?? '');

/// 그 달의 일수. 다음 달 1일에서 하루를 빼 구한다(윤년 포함).
int crewRecordDaysInMonth(int year, int month) =>
    DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 1)
        .subtract(const Duration(days: 1))
        .day;

/// 기록이 있는 날(일자 칩 활성 판정용).
Set<int> crewRecordDaysWithRecord(CrewRecordMonth month) => {
      for (final record in month.records)
        if (crewRecordDateOf(record) != null) crewRecordDateOf(record)!.day,
    };

/// 시간대 9칸. ⚠️ 코어 모델은 `time_info`가 없으면 빈 리스트를 만들고 곧바로
/// `timeInfo![0]`을 읽어 RangeError를 던진다(`m_crewRecordRoom.dart:44-58`) →
/// 웹은 `timeCountInfo`를 쓰지 않고 원본 배열을 직접 9칸으로 보정한다.
List<int> crewRecordTimeCounts(CrewRidingRecord record) {
  final raw = record.timeInfo ?? const <int>[];
  return [for (var i = 0; i < 9; i++) i < raw.length ? raw[i] : 0];
}

/// 일별 응답을 파싱하기 **전에** `time_info`를 9칸으로 맞춘다.
///
/// ⚠️ 코어 모델은 `time_info`가 없거나 짧으면 빈/짧은 리스트를 만든 뒤 곧바로
/// `timeInfo![0]`부터 9칸을 읽어 **RangeError로 파싱 전체를 날린다**
/// (`m_crewRecordRoom.dart:38-58`). 실측 응답에는 항상 9칸이 있었지만 한 항목 때문에
/// 목록이 통째로 비지 않도록 미리 채운다.
List<dynamic> withCrewRecordTimeInfo(List<dynamic> raw) {
  return [
    for (final item in raw)
      if (item is! Map)
        item
      else
        {
          // 원본을 고치지 않고 새 맵을 만든다(응답 맵의 값 타입에 기대지 않는다).
          ...Map<String, dynamic>.from(item),
          'time_info': _paddedTimeInfo(item['time_info']),
        },
  ];
}

List<int> _paddedTimeInfo(dynamic counts) {
  final list = counts is List ? counts : const [];
  return [for (var i = 0; i < 9; i++) i < list.length ? (list[i] as num?)?.toInt() ?? 0 : 0];
}

const List<String> _kWeekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

/// `15일(토)`(목업 표기). 앱은 `DateFormat('dd일 (E)','ko')`를 쓰지만 로케일 초기화에
/// 의존하지 않도록(위젯 테스트 포함) 요일 라벨을 직접 붙인다.
String crewRecordDayLabel(DateTime date) =>
    '${date.day}일(${_kWeekdayLabels[date.weekday - 1]})';

/// 카드 헤더의 `오늘` 배지 판정.
bool crewRecordIsToday(DateTime date, DateTime now) =>
    date.year == now.year && date.month == now.month && date.day == now.day;

/// 번호식 페이지네이션의 번호 범위(목업 5개). 현재 페이지를 가운데 두되 양 끝에서는
/// 밀어서 개수를 유지한다.
List<int> crewRecordPageWindow(int page, int totalPages, {int span = 5}) {
  if (totalPages <= span) return [for (var i = 1; i <= totalPages; i++) i];
  var start = page - span ~/ 2;
  if (start < 1) start = 1;
  if (start + span - 1 > totalPages) start = totalPages - span + 1;
  return [for (var i = 0; i < span; i++) start + i];
}
