import 'dart:io' as io show File;
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/util/vm_settingsController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/extensions.dart' show isAndroid, isIOS, isWeb;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

class BulletinQuillToolbar extends StatelessWidget {
  const BulletinQuillToolbar({
    required this.controller,
    required this.focusNode,
    super.key,
  });

  final QuillController controller;
  final FocusNode focusNode;

  Future<void> onImageInsertWithCropping(
      String image,
      QuillController controller,
      BuildContext context,
      ) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
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
        WebUiSettings(
          context: context,
        ),
      ],
    );
    final newImage = croppedFile?.path;
    if (newImage == null) {
      return;
    }
    if (isWeb()) {
      controller.insertImageBlock(imageSource: newImage);
      return;
    }
    final newSavedImage = await saveImage(io.File(newImage));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  Future<void> onImageInsert(String image, QuillController controller) async {
    if (isWeb() || isHttpBasedUrl(image)) {
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
    final SettingsController settingsController = Get.put(SettingsController());

    return Obx(() {
      if (settingsController.useCustomQuillToolbar.value) {
        return QuillToolbar(
          configurations: const QuillToolbarConfigurations(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              children: [
                IconButton(
                  onPressed: () => settingsController.toggleCustomQuillToolbar(),
                  icon: const Icon(
                    Icons.width_normal,
                  ),
                ),
                QuillToolbarHistoryButton(
                  isUndo: true,
                  controller: controller,
                ),
                QuillToolbarHistoryButton(
                  isUndo: false,
                  controller: controller,
                ),
                QuillToolbarToggleStyleButton(
                  options: const QuillToolbarToggleStyleButtonOptions(),
                  controller: controller,
                  attribute: Attribute.bold,
                ),
                QuillToolbarToggleStyleButton(
                  options: const QuillToolbarToggleStyleButtonOptions(),
                  controller: controller,
                  attribute: Attribute.italic,
                ),
                QuillToolbarToggleStyleButton(
                  controller: controller,
                  attribute: Attribute.underline,
                ),
                QuillToolbarClearFormatButton(
                  controller: controller,
                ),
                const VerticalDivider(),
                QuillToolbarImageButton(
                  controller: controller,
                ),
                QuillToolbarCameraButton(
                  controller: controller,
                ),
                QuillToolbarVideoButton(
                  controller: controller,
                ),
                const VerticalDivider(),
                QuillToolbarColorButton(
                  controller: controller,
                  isBackground: false,
                ),
                QuillToolbarColorButton(
                  controller: controller,
                  isBackground: true,
                ),
                const VerticalDivider(),
                QuillToolbarSelectHeaderStyleDropdownButton(
                  controller: controller,
                ),
                const VerticalDivider(),
                QuillToolbarSelectLineHeightStyleDropdownButton(
                  controller: controller,
                ),
                const VerticalDivider(),
                QuillToolbarToggleCheckListButton(
                  controller: controller,
                ),
                QuillToolbarToggleStyleButton(
                  controller: controller,
                  attribute: Attribute.ol,
                ),
                QuillToolbarToggleStyleButton(
                  controller: controller,
                  attribute: Attribute.ul,
                ),
                QuillToolbarToggleStyleButton(
                  controller: controller,
                  attribute: Attribute.inlineCode,
                ),
                QuillToolbarToggleStyleButton(
                  controller: controller,
                  attribute: Attribute.blockQuote,
                ),
                QuillToolbarIndentButton(
                  controller: controller,
                  isIncrease: true,
                ),
                QuillToolbarIndentButton(
                  controller: controller,
                  isIncrease: false,
                ),
                const VerticalDivider(),
                QuillToolbarLinkStyleButton(controller: controller),
              ],
            ),
          ),
        );
      }
      return QuillToolbar.simple(
        configurations: QuillSimpleToolbarConfigurations(
          controller: controller,
          color: SDSColor.gray900,
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
          toolbarSize: 36,
          toolbarSectionSpacing: 2,
          decoration: BoxDecoration(
            color: SDSColor.blue50, // 툴바의 배경색을 설정합니다.
            borderRadius: BorderRadius.circular(12), // 필요에 따라 모서리를 둥글게 설정할 수 있습니다.
          ),
          buttonOptions: QuillSimpleToolbarButtonOptions(
            base: QuillToolbarBaseButtonOptions(
              iconSize: 14,
              iconTheme: QuillIconTheme(
                iconButtonSelectedData: IconButtonData(
                  padding: EdgeInsets.zero,
                  color: SDSColor.snowliveBlue,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return SDSColor.sBlue200;
                          } else if (states.contains(MaterialState.hovered)) {
                            return SDSColor.sBlue200;
                          } else if (states.contains(MaterialState.disabled)) {
                            return SDSColor.sBlue50;
                          }
                          return Colors.transparent; // 기본 상태에서의 색상
                        },
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(SDSColor.snowliveBlue,),
                    )
                ),
                iconButtonUnselectedData: IconButtonData(
                  padding: EdgeInsets.zero,
                    color: SDSColor.gray900
                )
              )
            ),
          ),
          fontFamilyValues: {
            'Pretendard': 'Pretendard',
          },
          fontSizesValues: const {
            '14': '14.0',
            '16': '16.0',
            '18': '18.0',
            '20': '20.0'
          },
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('ko'),
          ),
          searchButtonType: SearchButtonType.modern,
          embedButtons: FlutterQuillEmbeds.toolbarButtons(
            imageButtonOptions: QuillToolbarImageButtonOptions(
              dialogTheme: QuillDialogTheme(
                dialogBackgroundColor: Colors.white, // 다이얼로그 배경색
                buttonTextStyle: TextStyle(
                  color: Colors.red, // 버튼 텍스트 색상
                  fontSize: 16,
                ),
                inputTextStyle: TextStyle(
                  color: Colors.black, // 제목 텍스트 색상
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                labelTextStyle: TextStyle(
                  color: Colors.grey[800], // 내용 텍스트 색상
                  fontSize: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 모서리를 둥글게 처리
                ),

              ),
              imageButtonConfigurations: QuillToolbarImageConfigurations(
                onImageInsertCallback: isAndroid(supportWeb: false) ||
                    isIOS(supportWeb: false) ||
                    isWeb()
                    ? (image, controller) =>
                    onImageInsertWithCropping(image, controller, context)
                    : onImageInsert,
              ),
            ),
          ),
        ),
      );
    });
  }
}