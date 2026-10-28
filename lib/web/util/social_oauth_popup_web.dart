import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'social_oauth_popup_types.dart';
export 'social_oauth_popup_types.dart';

/// 소셜 로그인 시작 — 전체 페이지를 백엔드 start로 이동시킨다.
/// 백엔드가 provider 인증 후 결과를 `{origin}/#/login?sl_token=...`로 되돌려준다.
/// (팝업/opener/postMessage 미사용 → COOP·모바일에서도 안정적)
void startSocialLoginRedirect(String startUrl) {
  final origin = web.window.location.origin;
  web.window.location.href = '$startUrl?origin=${Uri.encodeComponent(origin)}';
}

/// 리다이렉트로 돌아온 URL(#/login?sl_token=...)에서 결과를 읽고, 읽은 뒤 URL을 정리한다.
/// 결과가 없으면 null.
SocialLoginResult? readSocialRedirectResult() {
  final p = _hashParams();
  final token = p['sl_token'];
  final err = p['sl_error'];
  if ((token == null || token.isEmpty) && (err == null || err.isEmpty)) return null;

  _clearParams(); // 새로고침 시 재처리 방지

  if (token != null && token.isNotEmpty) {
    return SocialLoginResult(
      customToken: token,
      email: p['sl_email'],
      nickname: p['sl_nick'],
    );
  }
  return SocialLoginResult(error: err);
}

Map<String, String> _hashParams() {
  final hash = web.window.location.hash; // 예: '#/login?sl_token=...'
  final qi = hash.indexOf('?');
  if (qi < 0) return const {};
  return Uri.splitQueryString(hash.substring(qi + 1));
}

void _clearParams() {
  final loc = web.window.location;
  web.window.history.replaceState(null, '', '${loc.pathname}#/login');
}

// ─── 온보딩 미완료 이탈 시 Firebase 소셜 유저 정리(beforeunload/pagehide 비콘) ───
web.EventListener? _unloadDiscard;

/// 탭 닫기·새로고침 등 페이지 언로드 시 백엔드로 삭제 비콘을 보낸다.
/// (백엔드는 미가입 소셜 uid만 삭제하므로, 가입 완료 후 남아 발사돼도 안전)
void registerUnloadDiscard(String discardUrl, String uid) {
  clearUnloadDiscard();
  final body = 'uid=${Uri.encodeComponent(uid)}';
  _unloadDiscard = ((web.Event e) {
    try {
      web.window.navigator.sendBeacon(discardUrl, body.toJS);
    } catch (_) {}
  }).toJS;
  web.window.addEventListener('beforeunload', _unloadDiscard);
  web.window.addEventListener('pagehide', _unloadDiscard); // iOS Safari
}

void clearUnloadDiscard() {
  final l = _unloadDiscard;
  if (l == null) return;
  web.window.removeEventListener('beforeunload', l);
  web.window.removeEventListener('pagehide', l);
  _unloadDiscard = null;
}
