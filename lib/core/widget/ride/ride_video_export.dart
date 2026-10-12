/// 궤적 재생 애니메이션 → mp4 영상 저장 파사드.
/// 모바일(dart.library.io): ffmpeg_kit로 프레임 인코딩 + gal 갤러리 저장.
/// 웹: 미지원(stub).
export 'ride_video_export_stub.dart'
    if (dart.library.io) 'ride_video_export_io.dart';
