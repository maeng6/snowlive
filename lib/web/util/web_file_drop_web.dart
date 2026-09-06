import 'dart:js_interop';

import 'package:cross_file/cross_file.dart';
import 'package:web/web.dart' as web;

/// 브라우저 파일 드롭 수신기.
///
/// **`dragover`에서 preventDefault를 하지 않으면 브라우저가 드롭된 파일을
/// 새 탭에서 열어버린다.** 그게 드래그가 "안 되는" 것처럼 보이는 원인이다.
/// 그래서 dragenter/dragover/drop 셋 다 기본동작을 막는다.
///
/// 문서 전체에 붙는다 — 드롭 영역이 캔버스 안(Flutter 위젯)이라 특정 DOM
/// 엘리먼트에 걸 수가 없다. 대신 모달이 열려 있는 동안만 붙여서 다른 화면의
/// 드래그 동작에는 영향을 주지 않는다.
class WebFileDrop {
  final void Function(List<XFile> files) _onFiles;
  final void Function(bool isDragging)? _onDragChanged;

  /// dragleave는 자식 엘리먼트를 지날 때도 발생한다. 깊이를 세서
  /// 진짜로 문서를 벗어났을 때만 드래그 상태를 끈다.
  int _depth = 0;

  late final web.EventListener _onDragEnter;
  late final web.EventListener _onDragOver;
  late final web.EventListener _onDragLeave;
  late final web.EventListener _onDrop;

  WebFileDrop._(this._onFiles, this._onDragChanged);

  /// 리스너를 붙이고 핸들을 돌려준다. 반드시 [detach]로 떼야 한다.
  static WebFileDrop attach({
    required void Function(List<XFile> files) onFiles,
    void Function(bool isDragging)? onDragChanged,
  }) {
    final instance = WebFileDrop._(onFiles, onDragChanged);
    instance._start();
    return instance;
  }

  void _start() {
    _onDragEnter = ((web.Event event) {
      event.preventDefault();
      _depth++;
      if (_depth == 1) _onDragChanged?.call(true);
    }).toJS;

    // 이게 없으면 drop 이벤트가 아예 오지 않고 브라우저가 파일을 열어버린다.
    _onDragOver = ((web.Event event) => event.preventDefault()).toJS;

    _onDragLeave = ((web.Event event) {
      event.preventDefault();
      if (_depth > 0) _depth--;
      if (_depth == 0) _onDragChanged?.call(false);
    }).toJS;

    _onDrop = ((web.Event event) {
      event.preventDefault();
      _depth = 0;
      _onDragChanged?.call(false);

      final transfer = (event as web.DragEvent).dataTransfer;
      final fileList = transfer?.files;
      if (fileList == null) return;

      final picked = <XFile>[];
      for (var i = 0; i < fileList.length; i++) {
        final file = fileList.item(i);
        if (file == null) continue;
        // 이미지만 받는다. 그 외 파일이 떨어지면 조용히 무시한다.
        if (!file.type.startsWith('image/')) continue;
        picked.add(
          // image_picker_for_web과 같은 방식 — blob URL을 경로로 삼는 XFile.
          XFile(
            web.URL.createObjectURL(file),
            name: file.name,
            length: file.size,
            mimeType: file.type,
          ),
        );
      }
      if (picked.isNotEmpty) _onFiles(picked);
    }).toJS;

    web.document.addEventListener('dragenter', _onDragEnter);
    web.document.addEventListener('dragover', _onDragOver);
    web.document.addEventListener('dragleave', _onDragLeave);
    web.document.addEventListener('drop', _onDrop);
  }

  void detach() {
    web.document.removeEventListener('dragenter', _onDragEnter);
    web.document.removeEventListener('dragover', _onDragOver);
    web.document.removeEventListener('dragleave', _onDragLeave);
    web.document.removeEventListener('drop', _onDrop);
    _onDragChanged?.call(false);
  }
}
