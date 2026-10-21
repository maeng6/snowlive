/// 라이딩 기록 카드 화면의 **UI 작업용 더미**.
///
/// 서버에 아직 내 기록이 없어 화면을 비교·조정할 수 없을 때만 쓴다.
/// `#/riding-cards?dummy=cards`로 들어오면 네트워크 조회를 건너뛰고 이 값을 채운다
/// (로그인 여부와 무관). 쿼리가 없으면 평소처럼 서버 데이터만 쓴다.
///
/// ⚠️ 작업이 끝나면 이 파일과 화면의 `_isDummy` 분기를 **같이 지운다**.
library;

import 'package:com.snowlive/core/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/core/model/m_seasonRidingCard.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// `?dummy=cards`가 붙었는지.
///
/// 웹은 해시 라우팅(`/#/riding-cards?dummy=cards`)이라 쿼리가 **fragment 안**에 들어간다.
/// 보통은 GetX가 이걸 파싱해 `Get.parameters`에 넣지만, 주소만 고쳐 들어오거나
/// 라우트가 갈리는 시점에 비어 있을 수 있어 **URL에서도 직접** 읽는다.
bool ridingCardsDummyRequested() {
  final on = Get.parameters['dummy'] == 'cards' || _dummyInUrl();
  if (on) debugPrint('[RidingCards] 더미 모드 ON (?dummy=cards)');
  return on;
}

bool _dummyInUrl() {
  final uri = Uri.base;
  if (uri.queryParameters['dummy'] == 'cards') return true;
  // fragment = `/riding-cards?dummy=cards`
  final fragment = uri.fragment;
  final q = fragment.indexOf('?');
  if (q < 0) return false;
  return Uri.splitQueryString(fragment.substring(q + 1))['dummy'] == 'cards';
}

/// 슬로프 이름은 리조트별로 실재하는 것을 쓴다(길이·글자수가 레이아웃에 영향을 준다).
const Map<String, List<String>> _kSlopesByResort = {
  '곤지암': ['레이크', '밸리', '힐'],
  '비발디파크': ['발라드', '재즈', '블루스', '펑키'],
  '하이원': ['제우스1', '아테나2', '빅토리아', '아폴로3'],
  '웰리힐리': ['스카이1', '블루밸리', '레인보우'],
};

/// 칭호는 앱이 서버 값을 그대로 보여준다 — 길이가 다른 것을 섞어 둔다.
const List<String> _kRiderTitles = [
  '슬로프 지배자',
  '새벽 라이더',
  '파우더 헌터',
  '카빙 장인',
  '야간 질주자',
];

/// 하루치 카드 하나. 숫자는 서로 어긋나지 않게 맞춘다
/// (총 횟수 = 슬로프별 합계, 최다 슬로프 = 그중 최댓값).
DailyRidingCard _daily({
  required int cardId,
  required String date,
  required String resort,
  required List<int> counts,
  required double distance,
  required double topSpeed,
  required double avgSlope,
  required String title,
}) {
  final slopes = _kSlopesByResort[resort]!;
  final byName = <String, int>{
    for (var i = 0; i < counts.length && i < slopes.length; i++)
      slopes[i]: counts[i],
  };
  final total = byName.values.fold<int>(0, (a, b) => a + b);
  final top = byName.entries.reduce((a, b) => a.value >= b.value ? a : b);
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  return DailyRidingCard(
    cardId: cardId,
    userId: 0,
    date: date,
    weekday: weekdays[DateTime.parse(date).weekday - 1],
    totalSlopeCount: total,
    totalDistance: distance,
    slopeCountsByName: byName,
    mostRiddenSlope: top.key,
    mostRiddenCount: top.value,
    topSpeed: topSpeed,
    avgSlope: avgSlope,
    riderTitle: title,
    resorts: [resort],
  );
}

/// 25/26 시즌(2025-10 ~ 2026-09) 데일리 카드.
/// 월이 4개(12·1·2·3월) 나오도록, 한 달에 하루~다섯 날이 섞이도록 둔다 —
/// 월 묶음 간격·그리드 줄바꿈·목록 길이를 한 화면에서 같이 볼 수 있게.
List<DailyRidingCard> _season2526() => [
      // 3월 — 1장(마지막 달이 한 장일 때의 그리드 여백 확인용)
      _daily(
        cardId: 9301,
        date: '2026-03-07',
        resort: '하이원',
        counts: [6, 4, 3, 2],
        distance: 48.2,
        topSpeed: 71.4,
        avgSlope: 17.3,
        title: _kRiderTitles[3],
      ),
      // 2월 — 5장(그리드 한 줄 넘김)
      _daily(
        cardId: 9211,
        date: '2026-02-28',
        resort: '비발디파크',
        counts: [9, 7, 5, 4],
        distance: 62.8,
        topSpeed: 78.9,
        avgSlope: 19.1,
        title: _kRiderTitles[0],
      ),
      _daily(
        cardId: 9212,
        date: '2026-02-21',
        resort: '곤지암',
        counts: [12, 5, 3],
        distance: 39.4,
        topSpeed: 64.2,
        avgSlope: 15.8,
        title: _kRiderTitles[1],
      ),
      _daily(
        cardId: 9213,
        date: '2026-02-14',
        resort: '하이원',
        counts: [8, 8, 6, 1],
        distance: 55.1,
        topSpeed: 73.6,
        avgSlope: 18.4,
        title: _kRiderTitles[2],
      ),
      _daily(
        cardId: 9214,
        date: '2026-02-08',
        resort: '웰리힐리',
        counts: [4, 3, 2],
        distance: 21.7,
        topSpeed: 58.3,
        avgSlope: 14.2,
        title: _kRiderTitles[4],
      ),
      _daily(
        cardId: 9215,
        date: '2026-02-01',
        resort: '비발디파크',
        counts: [7, 6, 4, 3],
        distance: 44.9,
        topSpeed: 69.5,
        avgSlope: 16.7,
        title: _kRiderTitles[0],
      ),
      // 1월 — 3장
      _daily(
        cardId: 9121,
        date: '2026-01-25',
        resort: '하이원',
        counts: [11, 9, 7, 5],
        distance: 74.3,
        topSpeed: 82.1,
        avgSlope: 20.6,
        title: _kRiderTitles[0],
      ),
      _daily(
        cardId: 9122,
        date: '2026-01-17',
        resort: '곤지암',
        counts: [6, 4, 2],
        distance: 27.5,
        topSpeed: 61.8,
        avgSlope: 15.1,
        title: _kRiderTitles[1],
      ),
      _daily(
        cardId: 9123,
        date: '2026-01-03',
        resort: '웰리힐리',
        counts: [5, 5, 3],
        distance: 33.2,
        topSpeed: 66.4,
        avgSlope: 16.2,
        title: _kRiderTitles[3],
      ),
      // 12월 — 2장(시즌 시작 달)
      _daily(
        cardId: 9031,
        date: '2025-12-27',
        resort: '비발디파크',
        counts: [8, 5, 4, 2],
        distance: 41.6,
        topSpeed: 70.2,
        avgSlope: 17.8,
        title: _kRiderTitles[4],
      ),
      _daily(
        cardId: 9032,
        date: '2025-12-13',
        resort: '곤지암',
        counts: [3, 2, 1],
        distance: 12.9,
        topSpeed: 52.7,
        avgSlope: 13.4,
        title: _kRiderTitles[1],
      ),
    ];

/// 24/25 시즌 — 시즌 탭을 눌렀을 때도 비지 않게 짧게 둔다.
List<DailyRidingCard> _season2425() => [
      _daily(
        cardId: 8211,
        date: '2025-02-15',
        resort: '하이원',
        counts: [7, 5, 4, 2],
        distance: 46.8,
        topSpeed: 72.3,
        avgSlope: 17.9,
        title: _kRiderTitles[2],
      ),
      _daily(
        cardId: 8121,
        date: '2025-01-11',
        resort: '곤지암',
        counts: [5, 4, 2],
        distance: 24.1,
        topSpeed: 59.6,
        avgSlope: 14.8,
        title: _kRiderTitles[1],
      ),
    ];

/// 두 시즌을 한 번에 넣는다 — 데일리 목록 API에는 시즌 파라미터가 없어서
/// 화면이 전체를 받아 날짜로 걸러 쓰기 때문이다(실제 응답과 같은 모양).
List<DailyRidingCard> dummyDailyRidingCards() => [
      ..._season2526(),
      ..._season2425(),
    ];

/// 시즌 카드. 합계는 위 데일리 카드들과 맞춰 둔다(최고 기록은 그중 최댓값).
SeasonRidingCard? dummySeasonRidingCard(String dbSeason) {
  final cards = dbSeason == '2425' ? _season2425() : _season2526();
  if (cards.isEmpty) return null;

  final totalCount =
      cards.fold<int>(0, (sum, c) => sum + (c.totalSlopeCount ?? 0));
  final totalDistance =
      cards.fold<double>(0, (sum, c) => sum + (c.totalDistance ?? 0));
  final topSpeed = cards
      .map((c) => c.topSpeed ?? 0)
      .reduce((a, b) => a >= b ? a : b);
  final avgSlope = cards
          .map((c) => c.avgSlope ?? 0)
          .reduce((a, b) => a + b) /
      cards.length;

  return SeasonRidingCard(
    userId: 0,
    season: dbSeason,
    totalSlopeCount: totalCount,
    totalDistance: double.parse(totalDistance.toStringAsFixed(1)),
    topSpeed: topSpeed,
    avgSlope: double.parse(avgSlope.toStringAsFixed(1)),
  );
}
