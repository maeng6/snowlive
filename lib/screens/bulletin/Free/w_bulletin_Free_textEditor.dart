import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../snowliveDesignStyle.dart';

class BulletinTextEditor extends StatelessWidget {
  quill.QuillController _quillController = quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          quill.QuillToolbar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //이미지, 비디오
                Row(
                  children: [
                    quill.QuillToolbarIconButton(
                      icon: Image.asset('assets/imgs/icons/icon_editor_image.png',
                        width: 22,
                        height: 22,
                      ),
                      onPressed: () {
                        _quillController.formatSelection(quill.Attribute.image);
                      },
                      isSelected: _quillController.getSelectionStyle().attributes.containsKey(quill.Attribute.image.key),
                      iconTheme: quill.QuillIconTheme(
                        iconButtonSelectedData: quill.IconButtonData(
                          color: Colors.blue, // 선택된 상태의 색상
                          highlightColor: Colors.blueAccent,
                          splashColor: Colors.blue.withOpacity(0.3),
                        ),
                        iconButtonUnselectedData: quill.IconButtonData(
                          color: Colors.grey, // 선택되지 않은 상태의 색상
                          highlightColor: Colors.grey.withOpacity(0.5),
                          splashColor: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                    quill.QuillToolbarIconButton(
                      icon: Image.asset('assets/imgs/icons/icon_editor_video.png',
                        width: 22,
                        height: 22,
                      ),
                      onPressed: () {
                        _quillController.formatSelection(quill.Attribute.video);
                      },
                      isSelected: _quillController.getSelectionStyle().attributes.containsKey(quill.Attribute.video.key),
                      iconTheme: quill.QuillIconTheme(
                        iconButtonSelectedData: quill.IconButtonData(
                          color: Colors.blue, // 선택된 상태의 색상
                          highlightColor: Colors.blueAccent,
                          splashColor: Colors.blue.withOpacity(0.3),
                        ),
                        iconButtonUnselectedData: quill.IconButtonData(
                          color: Colors.grey, // 선택되지 않은 상태의 색상
                          highlightColor: Colors.grey.withOpacity(0.5),
                          splashColor: Colors.grey.withOpacity(0.3),
                        ),),
                    ),
                  ],
                ),
                Container(
                  height: 20,
                  width: 1,
                  color: SDSColor.gray200,
                ),

                Row(
                  children: [
                    quill.QuillToolbarIconButton(
                      icon: Image.asset('assets/imgs/icons/icon_editor_bold.png',
                        width: 22,
                        height: 22,
                      ),
                      onPressed: () {
                        _quillController.formatSelection(quill.Attribute.bold);
                      },
                      isSelected: _quillController.getSelectionStyle().attributes.containsKey(quill.Attribute.bold.key),
                      iconTheme: quill.QuillIconTheme(
                        iconButtonSelectedData: quill.IconButtonData(
                          color: Colors.blue, // 선택된 상태의 색상
                          highlightColor: Colors.blueAccent,
                          splashColor: Colors.blue.withOpacity(0.3),
                        ),
                        iconButtonUnselectedData: quill.IconButtonData(
                          color: Colors.grey, // 선택되지 않은 상태의 색상
                          highlightColor: Colors.grey.withOpacity(0.5),
                          splashColor: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                    quill.QuillToolbarIconButton(
                      icon: Image.asset('assets/imgs/icons/icon_editor_italic.png',
                        width: 22,
                        height: 22,
                      ),
                      onPressed: () {
                        _quillController.formatSelection(quill.Attribute.italic);
                      },
                      isSelected: _quillController.getSelectionStyle().attributes.containsKey(quill.Attribute.italic.key),
                      iconTheme: quill.QuillIconTheme(
                        iconButtonSelectedData: quill.IconButtonData(
                          color: Colors.blue, // 선택된 상태의 색상
                          highlightColor: Colors.blueAccent,
                          splashColor: Colors.blue.withOpacity(0.3),
                        ),
                        iconButtonUnselectedData: quill.IconButtonData(
                          color: Colors.grey, // 선택되지 않은 상태의 색상
                          highlightColor: Colors.grey.withOpacity(0.5),
                          splashColor: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                    quill.QuillToolbarIconButton(
                      icon: Image.asset('assets/imgs/icons/icon_editor_size.png',
                        width: 22,
                        height: 22,
                      ),
                      onPressed: () {
                        _quillController.formatSelection(quill.Attribute.size);
                      },
                      isSelected: _quillController.getSelectionStyle().attributes.containsKey(quill.Attribute.size.key),
                      iconTheme: quill.QuillIconTheme(
                        iconButtonSelectedData: quill.IconButtonData(
                          color: Colors.blue, // 선택된 상태의 색상
                          highlightColor: Colors.blueAccent,
                          splashColor: Colors.blue.withOpacity(0.3),
                        ),
                        iconButtonUnselectedData: quill.IconButtonData(
                          color: Colors.grey, // 선택되지 않은 상태의 색상
                          highlightColor: Colors.grey.withOpacity(0.5),
                          splashColor: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                    //밑줄
                    quill.QuillToolbarIconButton(
                      icon: Image.asset('assets/imgs/icons/icon_editor_underline.png',
                        width: 22,
                        height: 22,
                      ),
                      onPressed: () {
                        _quillController.formatSelection(quill.Attribute.underline);
                      },
                      isSelected: _quillController.getSelectionStyle().attributes.containsKey(quill.Attribute.underline.key),
                      iconTheme: quill.QuillIconTheme(
                        iconButtonSelectedData: quill.IconButtonData(
                          color: Colors.blue, // 선택된 상태의 색상
                          highlightColor: Colors.blueAccent,
                          splashColor: Colors.blue.withOpacity(0.3),
                        ),
                        iconButtonUnselectedData: quill.IconButtonData(
                          color: Colors.grey, // 선택되지 않은 상태의 색상
                          highlightColor: Colors.grey.withOpacity(0.5),
                          splashColor: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                    quill.QuillToolbarIconButton(
                      icon: Image.asset('assets/imgs/icons/icon_editor_strike.png',
                        width: 22,
                        height: 22,
                      ),
                      onPressed: () {
                        _quillController.formatSelection(quill.Attribute.strikeThrough);
                      },
                      isSelected: _quillController.getSelectionStyle().attributes.containsKey(quill.Attribute.strikeThrough.key),
                      iconTheme: quill.QuillIconTheme(
                        iconButtonSelectedData: quill.IconButtonData(
                          color: Colors.blue, // 선택된 상태의 색상
                          highlightColor: Colors.blueAccent,
                          splashColor: Colors.blue.withOpacity(0.3),
                        ),
                        iconButtonUnselectedData: quill.IconButtonData(
                          color: Colors.grey, // 선택되지 않은 상태의 색상
                          highlightColor: Colors.grey.withOpacity(0.5),
                          splashColor: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            configurations: quill.QuillToolbarConfigurations(
              sharedConfigurations: quill.QuillSharedConfigurations(),
              buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                  base: quill.QuillToolbarBaseButtonOptions()
              ),
            ) ,
          ),
          Container(
            height: 400,
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: SDSColor.gray50),
              borderRadius: BorderRadius.circular(6),
            ),
            child: quill.QuillEditor(
              configurations: quill.QuillEditorConfigurations(
                controller: _quillController,
                autoFocus: true,
                expands: false,
                padding: EdgeInsets.zero,
              ),
              scrollController: ScrollController(),
              focusNode: FocusNode(),
            ),
          ),
        ],
      ),
    );
  }
}
