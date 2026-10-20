import 'package:web/web.dart' as web;

/// 브라우저 이미지 캐시 워밍업(웹 전용).
///
/// Firebase Storage 이미지는 CORS가 없어 Flutter의 바이트 디코드 캐시(ImageCache/
/// precacheImage)가 막힌다 → 히어로배너는 결국 `<img>` 요소로 렌더된다. 그래서 앱
/// 내부 캐시 대신 **브라우저 자체 이미지 캐시**를 첫 진입 때 미리 채워두면, 이후
/// 같은 URL의 `<img>`는 네트워크 없이 즉시 뜬다(로그인→홈 재진입 포함).
///
/// 같은 URL은 한 번만 받고, 이미지가 바뀌면 URL이 달라지므로 그때만 새로 받는다.
final Set<String> _preloaded = <String>{};
final List<web.HTMLImageElement> _kept = <web.HTMLImageElement>[];

void preloadImageWeb(String? url) {
  if (url == null || url.isEmpty) return;
  if (!_preloaded.add(url)) return; // 이미 받음
  final img = web.HTMLImageElement()
    ..decoding = 'async'
    ..src = url; // src만 지정하면 브라우저가 받아서 캐시에 넣는다.
  // 로드 완료 전에 GC되어 중단되지 않도록 참조를 잠깐 들고 있다가 로드되면 놓는다.
  _kept.add(img);
  img.onLoad.listen((_) => _kept.remove(img));
  img.onError.listen((_) {
    _kept.remove(img);
    _preloaded.remove(url); // 실패하면 다음 기회에 다시 시도할 수 있게.
  });
}
