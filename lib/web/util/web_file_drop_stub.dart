import 'package:cross_file/cross_file.dart';

/// 웹이 아닌 타깃(테스트·모바일)용 무동작 스텁.
/// API는 [web_file_drop_web.dart]의 실제 구현과 같아야 한다.
class WebFileDrop {
  WebFileDrop._();

  static WebFileDrop attach({
    required void Function(List<XFile> files) onFiles,
    void Function(bool isDragging)? onDragChanged,
  }) =>
      WebFileDrop._();

  void detach() {}
}
