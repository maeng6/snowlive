/// 쿠팡 배너(블로그용 태그 이미지)의 상품 사진 구간만 보여주는 뷰 — 플랫폼별 구현을 고른다.
///
/// 쿠팡 CDN은 CORS 헤더가 없어 Flutter가 캔버스로 그리지 못하고 **DOM `<img>`(플랫폼뷰)**로
/// 떨어진다. 그 플랫폼뷰에 Flutter 쪽 ClipRect/Transform은 iOS Safari에서 **적용되지 않아**
/// 배너 전체(로고·제목·버튼)가 셀 밖으로 넘쳐 칩 줄과 다른 카드를 덮었다(실측, 시뮬레이터).
/// 그래서 자르기를 Flutter가 아니라 DOM 안(CSS overflow·object-position)에서 한다 —
/// 플랫폼뷰 자체는 셀 크기 그대로다.
export 'shop_banner_image_stub.dart'
    if (dart.library.html) 'shop_banner_image_web.dart';
