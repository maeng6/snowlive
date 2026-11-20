import 'package:web/web.dart' as web;

/// 브라우저를 통째로 다시 로드하면서 해당 해시 라우트로 보낸다.
///
/// GetX 라우팅으로 이동하면 그때까지 만들어진 뷰모델·구독이 그대로 남는다.
/// "처음부터 다시"가 필요한 자리(상단 로고)에서는 문서를 새로 로드한다.
///
/// 두 가지를 같이 처리해야 실제로 그 화면에 도착한다.
///  - 주소창이 `/share/...`로 바뀌어 있을 수 있다(공유 메타용 replaceState).
///    그 상태로 그냥 `reload()`하면 백엔드 `/share` 리다이렉트를 타 버린다.
///    경로가 다르면 `href` 지정만으로 새 문서가 로드되므로 그걸로 끝낸다.
///  - 같은 경로에서 **해시만** 바꾸면 문서는 다시 로드되지 않는다.
///    그래서 해시를 먼저 맞춘 뒤 `reload()`를 부른다.
void hardReloadToRouteWeb(String route) {
  final loc = web.window.location;
  final hash = '#$route';

  if (loc.pathname != '/') {
    loc.href = '${loc.origin}/$hash';
    return;
  }

  if (loc.hash != hash) loc.hash = hash;
  loc.reload();
}
