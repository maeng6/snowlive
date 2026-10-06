import 'package:com.snowlive/core/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:flutter/material.dart';

/// 크루의 색·로고 표현. 서버가 주는 값이 그대로 쓸 수 없는 형태라 한 곳에 모았다.
///
/// 랭킹 화면들(`v_rankingHome_web.dart`, `v_rankingArchive_web.dart`)이 로고 대체를
/// 인라인으로 하고 있는데, 그 두 줄은 지금 잘 동작하므로 건드리지 않는다.

/// 크루 색 문자열 → [Color]. 서버는 `"0XFF68A1F6"`처럼 **대문자 `0X`** 접두로 준다.
/// 값이 없거나 형식이 깨지면 null(호출자가 기본색으로 대체).
Color? crewColorOf(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  // `int.tryParse`는 `0x`/`0X` 접두를 받아주지만, 서버가 접두 없이 보내는 경우도
  // 대비해 16진수로 한 번 더 시도한다.
  final parsed = int.tryParse(value) ??
      int.tryParse(value.replaceFirst(RegExp('^0[xX]'), ''), radix: 16);
  return parsed == null ? null : Color(parsed);
}

/// 크루 색이 없거나 모르는 값일 때 쓸 기본 로고(회색 `LIVE CREW`).
/// 앱과 같은 에셋을 가리킨다 — `crewDefaultLogoUrl`의 `0XFF5E6B7F`(회색) 항목.
const String _kFallbackCrewLogoColor = '0XFF5E6B7F';

/// 크루 로고 URL. 비어 있으면 **색별 기본 `LIVE CREW` 로고**로 대체한다
/// (목업 카드의 초록 로고가 이것 — `crewDefaultLogoUrl`은 색 문자열이 키다).
///
/// 색까지 없거나 등록되지 않은 값이면 회색 기본 로고로 한 번 더 떨어진다 —
/// 그냥 null을 돌려주면 로고 자리가 빈 회색 네모로 남는다.
/// 크루 베이스 리조트의 **정식 이름**(`휘닉스파크`). 서버가 주는 건 id뿐이라
/// 로컬 리조트 목록에서 찾는다 — 상세 API를 기다릴 필요가 없다.
/// (id는 1부터, 목록 인덱스는 0부터)
String crewResortFullnameOf(int? baseResortId) {
  if (baseResortId == null) return '';
  final index = baseResortId - 1;
  if (index < 0 || index >= resortNameList.length) return '';
  return resortNameList[index] ?? '';
}

/// 크루 로고(라운드 사각)의 모서리 반지름. 목업이 **한 변의 0.2**로 일정하다
/// (타일 150→30, 안쪽 마크 80→16). 곳마다 다른 값을 쓰면 기본 마크 이미지에
/// 구워진 모서리와 테두리 곡률이 어긋나 보인다.
double crewLogoRadius(double size) => size * 0.2;

/// 색별 기본 `LIVE CREW` 마크 8장을 미리 받아 둔다.
///
/// 크루 만들기·크루 설정에서 색을 고르면 **색마다 다른 이미지**로 갈아끼우는데,
/// 처음 보는 색은 받아오는 동안 이전 마크가 남아 있다가 바뀐다. 화면에 들어올 때
/// 한 번 데워 두면 그 지연이 사라진다(실패는 무시 — 못 받으면 평소처럼 로드된다).
Future<void> precacheCrewDefaultLogos(BuildContext context) async {
  for (final url in crewDefaultLogoUrl.values) {
    try {
      await precacheImage(NetworkImage(url), context);
    } catch (_) {
      // 네트워크·CORS 문제는 조용히 넘긴다.
    }
    if (!context.mounted) return;
  }
}

String? crewLogoUrlOf({String? logoUrl, String? color}) {
  if (logoUrl != null && logoUrl.isNotEmpty) return logoUrl;
  return crewDefaultLogoUrl[color ?? ''] ?? crewDefaultLogoUrl[_kFallbackCrewLogoColor];
}
