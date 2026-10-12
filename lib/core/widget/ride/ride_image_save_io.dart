import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

/// PNG 바이트를 임시파일로 쓴 뒤 gal로 'Snowlive' 앨범에 저장(라이딩 카드와 동일).
/// 성공 시 true. 권한 거부·실패 시 false.
Future<bool> saveRideImageToGallery({
  required Uint8List bytes,
  required String filename,
}) async {
  File? tempFile;
  try {
    final tempDir = await getTemporaryDirectory();
    tempFile = File('${tempDir.path}/$filename');
    await tempFile.writeAsBytes(bytes);
    await Gal.putImage(tempFile.path, album: 'Snowlive');
    return true;
  } catch (_) {
    return false;
  } finally {
    try {
      if (tempFile != null && await tempFile.exists()) await tempFile.delete();
    } catch (_) {}
  }
}
