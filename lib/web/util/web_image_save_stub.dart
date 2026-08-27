import 'dart:typed_data';

/// 웹이 아닌 타깃(테스트·모바일)용 무동작 스텁.
/// API는 [web_image_save_web.dart]의 실제 구현과 같아야 한다.
bool saveWebPng({required Uint8List bytes, required String filename}) => false;

/// 웹이 아닌 타깃용 스텁. 실제 구현은 [web_image_save_web.dart].
Future<bool> shareWebPng({required Uint8List bytes, required String filename}) async => false;
