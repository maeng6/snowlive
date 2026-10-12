import 'dart:typed_data';

/// 웹·테스트 타깃용 무동작 스텁. 실제 구현은 [ride_image_save_io.dart].
/// 웹은 갤러리가 없으므로 공유 시트/다운로드([web_image_save.dart])를 쓴다.
Future<bool> saveRideImageToGallery({
  required Uint8List bytes,
  required String filename,
}) async =>
    false;
