import 'dart:io' as io show Directory, File;
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/util/vm_imageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/extensions.dart'
    show isAndroid, isDesktop, isIOS, isWeb;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/embeds/widgets/image.dart'
    show getImageProviderByImageSource, imageFileExtensions;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill_extensions/models/config/video/editor/youtube_video_support_mode.dart';
import 'package:path/path.dart' as path;


class MyQuillEditor extends StatelessWidget {
  const MyQuillEditor({
    required this.configurations,
    required this.scrollController,
    required this.focusNode,
    super.key,
  });

  final QuillEditorConfigurations configurations;
  final ScrollController scrollController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    //TODO : ****************************************************************
    Get.put(ImageController());
    //TODO : ****************************************************************

    final defaultTextStyle = DefaultTextStyle.of(context);
    return QuillEditor(
      scrollController: scrollController,
      focusNode: focusNode,
      configurations: configurations.copyWith(
        elementOptions: const QuillEditorElementOptions(
          codeBlock: QuillEditorCodeBlockElementOptions(
            enableLineNumbers: true,
          ),
          orderedList: QuillEditorOrderedListElementOptions(),
          unorderedList: QuillEditorUnOrderedListElementOptions(
            useTextColorForDot: true,
          ),
        ),
        customStyles: DefaultStyles(
          color: SDSColor.gray900,
          placeHolder: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              height: 1.4,
              color: SDSColor.gray300
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(16, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          h1: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.normal,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(16, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          h2: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.normal,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(16, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          h3: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.normal,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(16, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          h4: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.normal,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(16, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          h5: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.normal,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(16, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          h6: DefaultTextBlockStyle(
            defaultTextStyle.style.copyWith(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.normal,
            ),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(16, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          sizeSmall: defaultTextStyle.style.copyWith(fontSize: 16),
        ),
        scrollable: true,
        placeholder: '게시글 상세 내용을 적어주세요.',

        padding: const EdgeInsets.only(top: 20, bottom: 40, left: 10, right: 10),
        onImagePaste: (imageBytes) async {
          if (isWeb()) {
            return null;
          }
          final newFileName = 'imageFile-${DateTime.now().toIso8601String()}.png';
          final newPath = path.join(io.Directory.systemTemp.path, newFileName);
          final file = await io.File(newPath).writeAsBytes(imageBytes, flush: true);
          return file.path;
        },
        onGifPaste: (gifBytes) async {
          if (isWeb()) {
            return null;
          }
          final newFileName = 'gifFile-${DateTime.now().toIso8601String()}.gif';
          final newPath = path.join(io.Directory.systemTemp.path, newFileName);
          final file = await io.File(newPath).writeAsBytes(gifBytes, flush: true);
          return file.path;
        },
        embedBuilders: [
          ...(isWeb()
              ? FlutterQuillEmbeds.editorWebBuilders()
              : FlutterQuillEmbeds.editorBuilders(
            imageEmbedConfigurations: QuillEditorImageEmbedConfigurations(
              imageErrorWidgetBuilder: (context, error, stackTrace) {
                return Text('Error while loading an image: ${error.toString()}');
              },
              imageProviderBuilder: (context, imageUrl) {
                if (isHttpBasedUrl(imageUrl)) {
                  return NetworkImage(imageUrl);
                } else {
                  return FileImage(io.File(imageUrl));
                }
              },
            ),
            videoEmbedConfigurations: QuillEditorVideoEmbedConfigurations(
              youtubeVideoSupportMode: isIOS(supportWeb: false)
                  ? YoutubeVideoSupportMode.customPlayerWithDownloadUrl
                  : YoutubeVideoSupportMode.iframeView,
            ),
          )),
        ],
      ),
    );
  }
}