import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/core/model/m_crewRecordRoom.dart';

/// ⚠️ **UI 작업용 더미.** 기록실·일별 현황의 날짜 카드가 많아질 때(가로 스크롤)와
/// 멤버 수가 다양할 때를 눈으로 보기 위한 임시 데이터다.
///
/// 치울 때: 이 파일을 지우고 `v_crewRecordRoom_web.dart` / `v_crewDailyRecord_web.dart`의
/// `_records` getter를 `_vm.records`로 되돌린다. [kCrewRecordForceDummy]만 false로 두면
/// 서버 값이 있을 때는 그걸 쓴다.
const bool kCrewRecordForceDummy = true;

/// 얼굴 이미지가 있는 실제 프로필 URL 묶음(없는 멤버도 섞어 기본 아바타를 본다).
const List<String?> _kFaces = [
  'https://firebasestorage.googleapis.com/v0/b/snowlive-cf446.appspot.com/o/images%2Fprofile%2F5zzl3JVlY9SEJs8o0CmYYyjroVa2.jpg?alt=media&token=0d8ff3d6-cfd8-4017-b167-cfa57607a8e5',
  'https://firebasestorage.googleapis.com/v0/b/snowlive-cf446.appspot.com/o/user_profile%2F2228_1774187384541.jpg?alt=media&token=e828e1ea-b3ca-4c70-a346-814f203b7ead',
  'https://firebasestorage.googleapis.com/v0/b/snowlive-cf446.appspot.com/o/user_profile%2FpE93yCDFPQb5s3vElHJc4PhGO8P2_1767448625199.jpg?alt=media&token=44265114-3c64-4cba-b5ff-346ccbadd99f',
  'https://firebasestorage.googleapis.com/v0/b/snowlive-cf446.appspot.com/o/user_profile%2FLvWXTXiuSKaH8rXy5W9oHRLITKL2.jpg?alt=media&token=395091c1-94b3-4f54-b550-53b889305c36',
  null,
  'https://firebasestorage.googleapis.com/v0/b/snowlive-cf446.appspot.com/o/user_profile%2F13419_1769381388035.jpg?alt=media&token=56ca6fee-0029-4f87-94bc-5f3622dd9c23',
  'https://firebasestorage.googleapis.com/v0/b/snowlive-cf446.appspot.com/o/user_profile%2F1icxkpmsy0cjYLe0KZxSYPCxP8k2.jpg?alt=media&token=c17bd17f-ff98-44be-acad-6d93fd787f7d',
  null,
];

const List<String> _kNames = [
  '고기=해우네정육', '김삿갓', '피셔후원기다립니다', '올두맹', '낭만라이더',
  '할리스커피', '호야가타는보드', '세징야', '펜스뚫고후경몸턴난사', '지픽',
  '정플', 'seoy1210', '분홀뿔소년', '흑우김만종이', '충남대 기가지니',
];

/// 날짜 하나의 멤버 목록. [count]만큼 이름·얼굴을 돌려 쓴다.
List<TodayMemberInfo> _members(int count, int seed) {
  return [
    for (var i = 0; i < count; i++)
      TodayMemberInfo(
        userId: 1000 + seed * 50 + i,
        displayName: _kNames[(seed + i) % _kNames.length],
        profileImageUrlUser: _kFaces[(seed * 3 + i) % _kFaces.length],
        withinBoundary: i % 3 != 0,
        revealWb: true,
        totalScore: (900 - i * 37 + seed * 11).toDouble(),
      ),
  ];
}

/// 시간대 9칸을 만든다. 하루마다 모양이 달라지도록 seed로 흔든다.
Map<String, int> _timeCounts(int seed) {
  const shape = [2, 6, 9, 4, 5, 5, 6, 4, 1];
  return {
    for (var i = 0; i < 9; i++)
      ['00-08', '08-10', '10-12', '12-14', '14-16', '16-18', '18-20', '20-22', '22-00'][i]:
          // 0이 섞여야 막대 없는 칸도 보인다.
          ((shape[(i + seed) % 9] * (1 + seed % 3)) - (seed % 2 == 0 ? 0 : i % 3))
              .clamp(0, 99),
  };
}

/// **멤버 수를 여러 경우로** 섞은 날짜 카드들. 0명(라이딩 멤버 없음) · 1~3명(배지 없음) ·
/// 4명(딱 맞음) · 5명 이상(`+ N 멤버`) · 수십 명(팝업 스크롤)이 모두 들어 있다.
const List<int> _kMemberCounts = [
  5, 12, 1, 0, 4, 37, 2, 8, 3, 61, 6, 0, 15, 4, 9,
  1, 23, 7, 2, 48, 5, 11, 0, 3, 14, 6, 29, 4, 2, 18,
];

/// 한 달치 날짜 카드. [year]·[month]의 1일부터 [days]일까지 만든다
/// (가로 스크롤을 보려면 한 달이 길어야 한다).
List<CrewRidingRecord> _month(int year, int month, int days) {
  return [
    for (var day = days; day >= 1; day--)
      () {
        final seed = day + month;
        final memberCount = _kMemberCounts[(day - 1) % _kMemberCounts.length];
        final counts = _timeCounts(seed);
        final total = counts.values.fold<int>(0, (a, b) => a + b);
        final record = CrewRidingRecord(
          date: '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
          totalScore: (total * 39.5 + seed * 7).roundToDouble(),
          totalCount: total,
          memberCount: memberCount,
          withinBoundaryCount: (memberCount * 0.7).round(),
          timeInfo: counts.values.toList(),
          todayMemberInfo: _members(memberCount, seed),
        );
        record.timeCountInfo = counts;
        return record;
      }(),
  ];
}

/// 기록실·일별 현황 더미 — 세 달치(가로 스크롤 + 월 섹션 여러 개).
final List<CrewRidingRecord> kCrewRecordsDummy = [
  ..._month(2026, 1, 28),
  ..._month(2025, 12, 31),
  ..._month(2025, 11, 12),
];

/// 기록실 상단 요약·라이딩 통계용 더미.
final SeasonRankingInfo kCrewRecordStatsDummy = SeasonRankingInfo(
  overallRank: 24,
  overallTotalScore: 12344,
  totalSlopeCount: 884,
  countInfo: [
    CountInfo(slope: '스패로우', count: 135),
    CountInfo(slope: '파노라마', count: 102),
    CountInfo(slope: '펭귄', count: 57),
    CountInfo(slope: '챔피온', count: 36),
    CountInfo(slope: '호크1', count: 15),
    CountInfo(slope: '호크2', count: 67),
    CountInfo(slope: '파크', count: 42),
  ],
  timeCountInfo: const {
    '00-08': 57, '08-10': 102, '10-12': 135, '12-14': 36, '14-16': 15,
    '16-18': 0, '18-20': 0, '20-22': 0, '22-00': 0,
  },
);
