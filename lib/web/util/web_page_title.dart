import 'package:com.snowlive/web/routes/routes_web.dart';

/// 브라우저 탭 제목의 브랜드 부분. 홈과 모르는 경로는 이것만 쓴다.
const String kWebBrandTitle = '스노우라이브';

/// 화면 이름(브라우저 탭 제목 앞부분). 이름은 각 화면의 제목 줄과 같게 둔다 —
/// 탭과 화면 제목이 다르면 어느 탭이 어느 화면인지 헷갈린다.
///
/// 새 라우트를 추가하면 여기에도 넣을 것(빠지면 탭이 `스노우라이브`로만 나온다 —
/// 테스트가 모든 [WebRoutes.pages]에 이름이 있는지 확인한다).
const Map<String, String> kWebPageNames = {
  WebRoutes.home: '',
  // 중고거래
  WebRoutes.fleamarketList: '중고거래',
  WebRoutes.fleamarketSearch: '중고거래 검색',
  WebRoutes.fleamarketDetail: '중고거래 상품',
  WebRoutes.fleamarketUpload: '내 물건 팔기',
  WebRoutes.fleamarketUpdate: '중고거래 글 수정',
  WebRoutes.fleamarketAlert: '중고거래 알림 설정',
  // 각종소식 · 커뮤니티
  WebRoutes.event: '각종소식',
  WebRoutes.community: '커뮤니티',
  WebRoutes.communityDetail: '커뮤니티 게시글',
  WebRoutes.communityUpload: '게시글 작성',
  // 라이브톡
  WebRoutes.liveTalk: '라이브톡',
  WebRoutes.liveTalkDetail: '라이브톡',
  WebRoutes.liveTalkComments: '라이브톡',
  // 랭킹 · 기록
  WebRoutes.ranking: '랭킹',
  WebRoutes.rankingArchive: '랭킹 기록실',
  WebRoutes.slopeCraft: '슬로프크래프트',
  WebRoutes.ridingCards: '라이딩 기록 카드',
  // 라이브크루
  WebRoutes.liveCrew: '라이브크루',
  WebRoutes.crewHome: '크루홈',
  WebRoutes.crewMembers: '크루 멤버',
  WebRoutes.crewTalks: '크루톡',
  WebRoutes.crewCreate: '라이브크루 만들기',
  WebRoutes.crewJoin: '크루 가입하기',
  WebRoutes.crewSetting: '크루 설정',
  WebRoutes.crewSettingDesc: '크루 소개글 작성/변경',
  WebRoutes.crewSettingNotice: '공지사항 작성',
  WebRoutes.crewSettingImage: '크루 이미지 및 컬러 설정',
  WebRoutes.crewApplications: '가입 신청 목록',
  WebRoutes.crewMemberAdmin: '크루원 관리',
  WebRoutes.crewPermissions: '운영진 권한 설정',
  WebRoutes.crewRecordRoom: '시즌 기록실',
  WebRoutes.crewDailyRecord: '일별 현황',
  WebRoutes.crewSeasonRanking: '크루원 시즌 랭킹',
  // 프로필 · 친구 · 알림 · 설정
  WebRoutes.userProfile: '프로필',
  WebRoutes.friend: '친구',
  WebRoutes.friendSettings: '친구 설정',
  WebRoutes.friendRequests: '친구 요청 관리',
  WebRoutes.friendBlockList: '차단한 친구 관리',
  WebRoutes.alarm: '알림',
  WebRoutes.settings: '설정',
  // 계정
  WebRoutes.login: '로그인',
  WebRoutes.onboarding: '회원가입',
};

/// 라우트(쿼리 포함 가능) → 브라우저 탭 제목. `중고거래 | 스노우라이브`.
/// 홈·모르는 경로는 `스노우라이브`.
String webPageTitle(String route) {
  final path = route.split('?').first.split('#').first;
  final name = kWebPageNames[path] ?? '';
  return name.isEmpty ? kWebBrandTitle : '$name | $kWebBrandTitle';
}
