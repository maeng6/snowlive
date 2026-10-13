import 'package:com.snowlive/core/model/m_crewApplyList.dart';

/// UI 작업용 더미 — `가입 신청한 크루`(`v_crewMyApplications_web.dart`).
///
/// 신청을 실제로 보내 놓지 않으면 목록이 늘 비어 있어 레이아웃을 볼 수 없다.
/// **배포 전에 이 파일과 호출부의 `kCrewMyApplicationsForceDummy` 분기를 지운다.**
const bool kCrewMyApplicationsForceDummy = true;

/// 색별 기본 `LIVE CREW` 마크를 돌려 쓴다(로고를 안 올린 크루가 대부분이다).
const List<String> _colors = [
  '0XFF68A1F6',
  '0XFF37CBA8',
  '0XFFEA4E4E',
  '0XFFFDAF04',
  '0XFF9241F9',
  '0XFF0D4CA9',
  '0XFFFD6D04',
];

/// 보조줄 `리조트 별명 · 소개`를 다양하게 보려고 고른 조합 —
/// 소개가 아주 긴 것(말줄임 확인), 소개가 없는 것, 리조트가 없는 것을 섞었다.
const List<(String, int?, String?)> _crews = [
  ('스노우라이브 크루', 13, '휘닉스에서 주말마다 모여 타는 보드 크루입니다. 초보도 환영!'),
  ('용평 아침라이딩', 9, '첫 리프트 타러 모이는 사람들'),
  ('하이원 카빙연구소', 12, '카빙 자세 서로 봐주면서 타요. 영상 촬영 지원합니다. 중급 이상 권장이고 주로 토요일 오전에 모입니다.'),
  ('지산 나이트', 11, null),
  ('무주 프리스타일', 2, '지빙·파크 위주로 탑니다'),
  ('곤지암 직장인 모임', 1, '평일 야간 라이딩'),
  ('이름만 있는 크루', null, null),
];

/// 신청 목록(최근 신청이 위).
final List<CrewApply> kCrewMyApplicationsDummy = [
  for (final (index, crew) in _crews.indexed)
    CrewApply.fromJson({
      'apply_crew_id': 9000 + index,
      'title': '안녕하세요. 크루 가입 신청합니다.',
      'apply_date': '2026-01-${(20 - index).toString().padLeft(2, '0')}',
      'crew_id': 300 + index,
      'applicant_user_id': 1,
      'crewinfo': {
        'crew_id': 300 + index,
        'crew_name': crew.$1,
        'crew_logo_url': null,
        'color': _colors[index % _colors.length],
        'description': crew.$3,
        'base_resort_id': crew.$2,
      },
    }),
];
