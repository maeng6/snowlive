import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

/// 웹 글쓰기 본문 에디터(툴바 + Quill).
///
/// 모바일의 [BulletinQuillToolbar]는 `dart:io`/`image_cropper`/`path_provider`에
/// 의존해서 웹에서 컴파일되지 않는다. 그래서 웹 전용으로 새로 만든다.
///
/// 지원 서식은 **굵게 · 밑줄 · 링크 · 사진** 네 가지다. 웹 상세화면의 본문
/// 렌더러([w_community_body_web.dart])가 정확히 이 넷만 해석하므로, 여기서 더
/// 많은 서식을 허용하면 작성자가 넣은 꾸밈이 상세화면에서 사라진다.
class WebQuillEditor extends StatefulWidget {
  final quill.QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;

  /// 본문 박스 높이. 목업은 화면 하단까지 채우지만, 뷰포트에 맞춰 늘리려면
  /// IntrinsicHeight가 필요한데 Quill과 궁합이 나쁘다 → 폭별 고정 높이로 근사한다.
  final double height;

  /// 여러 줄 가능. Quill의 `placeholder` 옵션은 쓰지 않는다 — 아래 [_buildEditor] 참고.
  final String placeholder;

  /// 사진 버튼. 이미지 선택·업로드 대기열 관리는 뷰모델 몫이라 콜백으로 뺀다.
  final Future<void> Function() onPickImage;

  const WebQuillEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.height,
    required this.placeholder,
    required this.onPickImage,
  });

  @override
  State<WebQuillEditor> createState() => _WebQuillEditorState();
}

class _WebQuillEditorState extends State<WebQuillEditor> {
  late bool _isEmpty = widget.controller.document.isEmpty();

  /// 현재 선택 영역에 적용된 서식 키. 툴바 버튼의 눌림 상태에 쓴다.
  Set<String> _activeAttrs = {};

  quill.QuillController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onDocumentChanged);
  }

  @override
  void didUpdateWidget(covariant WebQuillEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_onDocumentChanged);
      widget.controller.addListener(_onDocumentChanged);
      _onDocumentChanged();
    }
  }

  @override
  void dispose() {
    // 컨트롤러는 뷰모델 소유다. 리스너만 떼고 dispose는 하지 않는다.
    controller.removeListener(_onDocumentChanged);
    super.dispose();
  }

  /// QuillController는 문서 변경뿐 아니라 **선택 변경에도** 알린다.
  /// 그래서 placeholder 표시와 툴바 눌림 상태를 한 리스너로 처리한다.
  void _onDocumentChanged() {
    final isEmpty = controller.document.isEmpty();
    final active = controller.getSelectionStyle().attributes.keys.toSet();
    if (isEmpty == _isEmpty && setEquals(active, _activeAttrs)) return;
    setState(() {
      _isEmpty = isEmpty;
      _activeAttrs = active;
    });
  }

  /// 링크 입력 모달. Quill 내장 링크 버튼은 `showDialog`를 써서 셸 안쪽
  /// Navigator에 붙는다 → 딤이 GNB를 못 덮는다. 그래서 직접 만든다.
  Future<void> _insertLink(BuildContext context) async {
    final selection = controller.selection;
    if (selection.isCollapsed) {
      // 링크는 선택 영역에 입히는 서식이라 선택이 없으면 붙일 곳이 없다.
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('링크를 걸 텍스트를 먼저 선택해주세요.')),
      );
      return;
    }

    final textController = TextEditingController();
    final url = await showWebOverlayModal<String>(
      context: context,
      builder: (_, close) => Material(
        color: SDSColor.snowliveWhite,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('링크 삽입', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
              const SizedBox(height: SDSSpacing.md),
              TextField(
                controller: textController,
                autofocus: true,
                keyboardType: TextInputType.url,
                onSubmitted: (v) => close(v.trim()),
                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                decoration: InputDecoration(
                  hintText: 'https://',
                  hintStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
                  filled: true,
                  fillColor: SDSColor.gray50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: SDSSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => close(),
                    child: Text('취소', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray500)),
                  ),
                  const SizedBox(width: SDSSpacing.xs),
                  ElevatedButton(
                    onPressed: () => close(textController.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('확인', style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    textController.dispose();

    if (url == null || url.isEmpty) return;
    controller.formatSelection(quill.LinkAttribute(url));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildToolbar(context),
          const SizedBox(height: 8),
          Expanded(child: _buildEditor(context)),
        ],
      ),
    );
  }

  /// Quill의 `placeholder` 옵션은 **줄바꿈을 못 넣는다** — 패키지가 문자열을 JSON
  /// 리터럴에 그대로 끼워 넣고 `"`만 이스케이프해서, 개행이 들어가면
  /// "Bad control character in string literal in JSON"으로 에디터가 통째로 죽는다
  /// (flutter_quill 11.5.0 raw_editor_state.dart). 목업 문구는 두 문단이라
  /// placeholder를 직접 겹쳐 그린다.
  Widget _buildEditor(BuildContext context) {
    const contentPadding = EdgeInsets.symmetric(horizontal: 4, vertical: 8);

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(cursorColor: SDSColor.snowliveBlue),
      ),
      child: Stack(
        children: [
          if (_isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: contentPadding,
                  child: Text(
                    widget.placeholder,
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 15,
                      color: SDSColor.gray400,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          quill.QuillEditor(
            controller: controller,
            focusNode: widget.focusNode,
            scrollController: widget.scrollController,
            config: quill.QuillEditorConfig(
              scrollable: true,
              showCursor: true,
              padding: contentPadding,
              // 웹에서는 blob URL을 NetworkImage로 처리하는 웹용 빌더가 선택된다.
              embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
              customStyles: quill.DefaultStyles(
                paragraph: quill.DefaultTextBlockStyle(
                  SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900, height: 1.5),
                  const quill.HorizontalSpacing(0, 0),
                  const quill.VerticalSpacing(0, 0),
                  const quill.VerticalSpacing(0, 0),
                  null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 툴바는 직접 만든다. QuillSimpleToolbar는 버튼을 바 전체에 균등 분배해서
  /// 왼쪽 정렬이 되지 않고(toolbarIconAlignment가 이 레이아웃엔 안 먹는다),
  /// 아이콘/색도 앱 토큰과 따로 논다.
  Widget _buildToolbar(BuildContext context) {
    return Container(
      height: 40,
      // 목업의 ToolBar 바 — 본문 박스(gray50)보다 한 단계 진한 회색.
      decoration: BoxDecoration(color: SDSColor.gray200, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          _ToolbarButton(
            icon: Icons.format_bold,
            tooltip: '굵게',
            isActive: _activeAttrs.contains(quill.Attribute.bold.key),
            onTap: () => _toggle(quill.Attribute.bold),
          ),
          _ToolbarButton(
            icon: Icons.format_underlined,
            tooltip: '밑줄',
            isActive: _activeAttrs.contains(quill.Attribute.underline.key),
            onTap: () => _toggle(quill.Attribute.underline),
          ),
          _ToolbarButton(
            icon: Icons.link,
            tooltip: '링크',
            isActive: _activeAttrs.contains(quill.Attribute.link.key),
            onTap: () => _insertLink(context),
          ),
          _ToolbarButton(
            icon: Icons.image_outlined,
            tooltip: '사진',
            onTap: widget.onPickImage,
          ),
        ],
      ),
    );
  }

  void _toggle(quill.Attribute attribute) {
    final isActive = _activeAttrs.contains(attribute.key);
    controller.formatSelection(
      isActive ? quill.Attribute.clone(attribute, null) : attribute,
    );
  }
}

/// 툴바 아이콘 하나. 적용 중인 서식은 배경을 눌러 표시한다.
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive ? SDSColor.snowliveWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? SDSColor.snowliveBlue : SDSColor.gray700,
          ),
        ),
      ),
    );
  }
}
