import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// 콘텐츠 라우트 → 백엔드 공유(/share) 경로 매핑 + 공유 메타(canonical/og) 동적 갱신.
///
/// 스라 웹은 해시 라우팅 SPA라, 카카오/페북 크롤러가 주소창의 생 URL을 읽어도
/// (`#` 뒤는 서버로 전송되지 않으므로) index.html의 사이트 공통 OG(홈)만 본다.
/// → 공유 가능한 콘텐츠 페이지에 들어오면 주소창을 크롤러가 읽는 `/share/...`로
/// `history.replaceState` 한다. 백엔드가 `/share/...`를 302하고 OG를 서빙한다.
///
/// 그런데 **모바일/iOS 네이티브 공유 시트는 주소창(location)이 아니라 문서의
/// `<link rel="canonical">`·`<meta property="og:url">`을 읽는다.** 이게 index.html에
/// `snowlive.kr/`로 하드코딩돼 있으면 주소창을 바꿔도 공유는 홈으로 간다. 그래서
/// 콘텐츠 페이지에선 이 메타들도 `/share/...`로 함께 갱신하고(이벤트는 제목/이미지까지),
/// 페이지를 떠나면 원래 값으로 되돌린다.

/// 공유 대상이면 그 `/share/...` 경로, 아니면 null.
String? _desiredSharePath;

/// 공유 대상이 아닐 때 주소창에 둘 정상 해시 경로(이전 `/share`가 남았으면 복구용).
String _desiredRestorePath = '/';

/// 이벤트 공유 미리보기(발신자 공유 시트에도 이벤트로 보이게).
const String _eventOgTitle = '스라 개장빵 이벤트!';
const String _eventOgDesc = '26/27시즌 전국 스키장 개장빵이벤트 진행 안내';
const String _eventOgImage = 'https://app.snowlive.kr/static/event_og.png';

// index.html의 원래 메타값(최초 1회 캡처해 복구에 쓴다).
bool _origCaptured = false;
String _origCanonical = 'https://snowlive.kr/';
String _origOgUrl = 'https://snowlive.kr/';
String _origOgTitle = '';
String _origOgDesc = '';
String _origOgImage = '';

/// [fragment]는 해시 라우트(예: `/community-detail?id=3`, `/season-open-event/`).
/// 공유 경로로 매핑되면 그 상대경로를, 아니면 null.
String? _sharePathFor(String fragment) {
  final qi = fragment.indexOf('?');
  var path = qi >= 0 ? fragment.substring(0, qi) : fragment;
  final query = qi >= 0 ? fragment.substring(qi + 1) : '';
  if (!path.startsWith('/')) path = '/$path';
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  final params =
      query.isEmpty ? const <String, String>{} : Uri.splitQueryString(query);
  final id = params['id'] ?? '';
  switch (path) {
    case '/season-open-event':
      return '/share/season-open-event';
    case '/community-detail':
      return id.isEmpty ? null : '/share/community/$id';
    case '/fleamarket-detail':
      return id.isEmpty ? null : '/share/flea/$id';
    case '/livecrew-detail':
      return id.isEmpty ? null : '/share/crew/$id';
    case '/livetalk-detail':
      return id.isEmpty ? null : '/share/livetalk/$id';
    case '/profile':
      return id.isEmpty ? null : '/share/user/$id';
    default:
      return null;
  }
}

String? _metaContent(String property) =>
    web.document.querySelector('meta[property="$property"]')?.getAttribute('content');

void _setMeta(String property, String content) {
  var el = web.document.querySelector('meta[property="$property"]');
  if (el == null) {
    final created = web.document.createElement('meta');
    created.setAttribute('property', property);
    web.document.head?.appendChild(created);
    el = created;
  }
  el.setAttribute('content', content);
}

void _setCanonical(String href) {
  var el = web.document.querySelector('link[rel="canonical"]');
  if (el == null) {
    final created = web.document.createElement('link');
    created.setAttribute('rel', 'canonical');
    web.document.head?.appendChild(created);
    el = created;
  }
  el.setAttribute('href', href);
}

void _captureOrig() {
  if (_origCaptured) return;
  _origCaptured = true;
  _origCanonical =
      web.document.querySelector('link[rel="canonical"]')?.getAttribute('href') ??
          _origCanonical;
  _origOgUrl = _metaContent('og:url') ?? _origOgUrl;
  _origOgTitle = _metaContent('og:title') ?? _origOgTitle;
  _origOgDesc = _metaContent('og:description') ?? _origOgDesc;
  _origOgImage = _metaContent('og:image') ?? _origOgImage;
}

/// 기억해 둔 목표 상태를 주소창 + 공유 메타에 강제한다(프레임워크가 되돌려도 재적용).
void _apply() {
  try {
    _captureOrig();
    final loc = web.window.location;
    if (_desiredSharePath != null) {
      // 주소창: pathname이 맞아도 프레임워크가 해시(#/..)를 덧붙였으면 지운다.
      if (loc.pathname != _desiredSharePath || loc.hash.isNotEmpty) {
        web.window.history.replaceState(null, '', _desiredSharePath!);
      }
      // 공유 메타: 네이티브 공유 시트가 읽는 canonical·og:url을 /share 절대URL로.
      final abs = loc.origin + _desiredSharePath!;
      _setCanonical(abs);
      _setMeta('og:url', abs);
      if (_desiredSharePath == '/share/season-open-event') {
        // 이벤트는 제목/설명/이미지까지 바꿔 발신자 공유 시트 미리보기도 이벤트로.
        _setMeta('og:title', _eventOgTitle);
        _setMeta('og:description', _eventOgDesc);
        _setMeta('og:image', _eventOgImage);
      } else {
        // 그 외 콘텐츠는 제목/이미지는 기본값 유지. 링크만 /share라, 수신측/카카오는
        // 백엔드 OG로 올바른 미리보기가 뜬다.
        _setMeta('og:title', _origOgTitle);
        _setMeta('og:description', _origOgDesc);
        _setMeta('og:image', _origOgImage);
      }
    } else {
      if (loc.pathname != '/') {
        web.window.history.replaceState(null, '', _desiredRestorePath);
      }
      // 공유 메타 원복.
      _setCanonical(_origCanonical);
      _setMeta('og:url', _origOgUrl);
      _setMeta('og:title', _origOgTitle);
      _setMeta('og:description', _origOgDesc);
      _setMeta('og:image', _origOgImage);
    }
  } catch (_) {
    // 주소창/메타 조정 실패는 무시.
  }
}

/// 새 라우트 진입 시 호출. [fragment]는 **그 시점의 유효한** 해시 라우트
/// (`Uri.base.fragment`, 쿼리 포함). 목표 상태를 기억하고 즉시 적용한 뒤, 프레임워크의
/// 초기/전환 동기화가 되돌릴 수 있어 몇 번 더(idempotent) 재적용한다.
void syncShareAddressBar(String fragment) {
  // 빈 프래그먼트는 "이미 /share로 치환된 뒤의 재호출"일 수 있으니 기억값을 건드리지
  // 않고(오판 방지) 재적용만 한다.
  if (fragment.isNotEmpty) {
    _desiredSharePath = _sharePathFor(fragment);
    final frag = fragment.startsWith('/') ? fragment : '/$fragment';
    _desiredRestorePath = '/#$frag';
  }
  _apply();
  for (final ms in const [250, 900, 2500]) {
    Timer(Duration(milliseconds: ms), _apply);
  }
}
