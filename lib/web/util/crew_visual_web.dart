import 'package:com.snowlive/core/data/imgaUrls/Data_url_image.dart';
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

/// 크루 로고 URL. 비어 있으면 **색별 기본 `LIVE CREW` 로고**로 대체한다
/// (목업 카드의 초록 로고가 이것 — `crewDefaultLogoUrl`은 색 문자열이 키다).
String? crewLogoUrlOf({String? logoUrl, String? color}) {
  if (logoUrl != null && logoUrl.isNotEmpty) return logoUrl;
  return crewDefaultLogoUrl[color ?? ''];
}
