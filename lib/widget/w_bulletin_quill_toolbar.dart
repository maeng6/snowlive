import 'dart:io' as io show File;
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

class BulletinQuillToolbar extends StatelessWidget {
  const BulletinQuillToolbar({
    required this.controller,
    required this.focusNode,
    super.key,
  });

  final quill.QuillController controller;
  final FocusNode focusNode;

  bool _isWeb() => kIsWeb;

  bool _isHttpBasedUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Future<void> onImageInsertWithCropping(
      String image,
      quill.QuillController controller,
      BuildContext context,
      ) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    final newImage = croppedFile?.path;
    if (newImage == null) {
      return;
    }
    if (_isWeb()) {
      controller.insertImageBlock(imageSource: newImage);
      return;
    }
    final newSavedImage = await saveImage(io.File(newImage));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  Future<void> onImageInsert(String image, quill.QuillController controller) async {
    if (_isWeb() || _isHttpBasedUrl(image)) {
      controller.insertImageBlock(imageSource: image);
      return;
    }
    final newSavedImage = await saveImage(io.File(image));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  Future<String> saveImage(io.File file) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final fileExt = path.extension(file.path);
    final newFileName = '${DateTime.now().toIso8601String()}$fileExt';
    final newPath = path.join(
      appDocDir.path,
      newFileName,
    );
    final copiedFile = await file.copy(newPath);
    return copiedFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return quill.QuillSimpleToolbar(
      controller: controller,
      config: quill.QuillSimpleToolbarConfig(
        showRedo: false,
        showUndo: false,
        showFontFamily: false,
        showFontSize: false,
        showBoldButton: true,
        showAlignmentButtons: false,
        showSearchButton: false,
        showClearFormat: false,
        showBackgroundColorButton: false,
        showCodeBlock: false,
        showDirection: false,
        showQuote: false,
        showSmallButton: false,
        showListBullets: false,
        showListNumbers: false,
        showListCheck: false,
        showJustifyAlignment: false,
        showCenterAlignment: false,
        showColorButton: false,
        showLineHeightButton: false,
        showInlineCode: false,
        showSubscript: false,
        showSuperscript: false,
        showHeaderStyle: false,
        showDividers: false,
        showIndent: false,
        multiRowsDisplay: false,
        decoration: BoxDecoration(
          color: SDSColor.blue50,
          borderRadius: BorderRadius.circular(12),
        ),
        embedButtons: FlutterQuillEmbeds.toolbarButtons(
          videoButtonOptions: null,
        ),
      ),
    );
  }
}