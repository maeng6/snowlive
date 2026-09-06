import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_file_drop.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

/// 프로필 이미지 선택 UI를 띄우고 고른 파일을 돌려준다. 취소하면 null.
///
/// 폭에 따라 형태가 갈린다(목업) — 데스크탑·태블릿은 드래그앤드롭이 가능한 중앙
/// 모달, 모바일은 앨범/촬영을 고르는 하단 시트.
///
/// 둘 다 [showWebOverlayModal]을 통과한다. 셸(WebAppShell)이 라우트 Navigator를
/// 감싸는 구조라 `showDialog`/`Get.dialog`로는 딤이 GNB를 덮지 못한다.
Future<XFile?> showOnboardingProfileImagePicker(BuildContext context) {
  if (context.screenType == WebScreenType.mobile) {
    return showWebOverlayModal<XFile>(
      context: context,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.zero,
      builder: (_, close) => _MobileUploadSheet(onPicked: close),
    );
  }

  return showWebOverlayModal<XFile>(
    context: context,
    padding: const EdgeInsets.all(SDSSpacing.lg),
    builder: (_, close) => _DesktopDropModal(onPicked: close),
  );
}

Future<XFile?> _pickFromDevice({required bool fromCamera}) {
  return ImagePicker().pickImage(
    source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    imageQuality: 70,
  );
}

/// 데스크탑·태블릿 — 드롭존이 있는 중앙 모달.
class _DesktopDropModal extends StatefulWidget {
  final void Function([XFile? file]) onPicked;

  const _DesktopDropModal({required this.onPicked});

  @override
  State<_DesktopDropModal> createState() => _DesktopDropModalState();
}

class _DesktopDropModalState extends State<_DesktopDropModal> {
  WebFileDrop? _drop;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // 모달이 열려 있는 동안만 문서 리스너를 붙인다(다른 화면의 드래그에 영향 없게).
    _drop = WebFileDrop.attach(
      onFiles: (files) {
        if (files.isEmpty) return;
        widget.onPicked(files.first);
      },
      onDragChanged: (dragging) {
        if (!mounted || dragging == _isDragging) return;
        setState(() => _isDragging = dragging);
      },
    );
  }

  @override
  void dispose() {
    _drop?.detach();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await _pickFromDevice(fromCamera: false);
    if (picked != null) widget.onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(SDSSpacing.lg, SDSSpacing.md, SDSSpacing.lg, SDSSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: widget.onPicked,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: Icon(Icons.close, size: 22, color: SDSColor.gray500),
                ),
              ),
              Text(
                '프로필 이미지 선택',
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SDSSpacing.xs),
              Text(
                '여기에 사진을 드래그하세요',
                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SDSSpacing.md),
              Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: _isDragging ? SDSColor.blue50 : SDSColor.gray50,
                    border: _isDragging
                        ? Border.all(color: SDSColor.snowliveBlue, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/imgs/icons/icon_input_camera.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SDSSpacing.lg),
              Center(
                child: SizedBox(
                  width: 210,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _pick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.gray50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      '이미지 직접 선택하기',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 모바일 — 앨범/촬영을 고르는 하단 시트.
class _MobileUploadSheet extends StatelessWidget {
  final void Function([XFile? file]) onPicked;

  const _MobileUploadSheet({required this.onPicked});

  Future<void> _pick(bool fromCamera) async {
    final picked = await _pickFromDevice(fromCamera: fromCamera);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(SDSSpacing.md, SDSSpacing.sm, SDSSpacing.md, SDSSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: SDSColor.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SDSSpacing.md),
            Text(
              '업로드 방법 선택',
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SDSSpacing.sm),
            Text(
              '스노우라이브에서 사용하실 프로필 이미지를 선택해주세요.\n프로필 이미지는 나중에 업로드할 수 있어요.',
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SDSSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: '앨범에서 선택',
                    background: SDSColor.gray50,
                    foreground: SDSColor.gray900,
                    onTap: () => _pick(false),
                  ),
                ),
                const SizedBox(width: SDSSpacing.sm),
                Expanded(
                  child: _SheetButton(
                    label: '촬영',
                    background: SDSColor.snowliveBlue,
                    foreground: SDSColor.snowliveWhite,
                    onTap: () => _pick(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: foreground)),
    );
  }
}
