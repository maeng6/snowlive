/// 궤적 상세 이미지(PNG) → 기기 갤러리 저장 파사드.
/// 모바일(dart.library.io): gal로 'Snowlive' 앨범에 직접 저장(라이딩 카드와 동일).
/// 웹: 미지원(stub) — 웹은 [web_image_save.dart]의 공유 시트/다운로드를 쓴다.
export 'ride_image_save_stub.dart'
    if (dart.library.io) 'ride_image_save_io.dart';
