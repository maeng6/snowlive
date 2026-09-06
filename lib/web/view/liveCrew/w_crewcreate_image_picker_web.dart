import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_file_drop.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

/// 크루 이미지 등록 모달. 고른 파일을 돌려주고, 취소하면 null.
///
/// 온보딩의 프로필 이미지 피커와 모양이 비슷하지만 흐름이 다르다 — 목업은 고른 사진을
/// **모달 안에서 미리 보고** 아래 파란 체크 버튼으로 확정한다(온보딩은 고르는 즉시 닫힘).
/// 그래서 별도 위젯으로 둔다.
Future<XFile?> showCrewImagePicker(BuildContext context, {XFile? initial}) {
  // 모바일 목업은 `업로드 방법 선택` 바텀시트다(앨범/촬영) — 온보딩과 같은 형태.
  if (context.screenType == WebScreenType.mobile) {
    return showWebOverlayModal<XFile>(
      context: context,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.zero,
      builder: (_, close) => _CrewUploadSheet(onPicked: close),
    );
  }
  return showWebOverlayModal<XFile>(
    context: context,
    padding: const EdgeInsets.all(SDSSpacing.lg),
    builder: (_, close) => _CrewImagePickerModal(initial: initial, onDone: close),
  );
}

/// 모바일 — 앨범/촬영을 고르는 하단 시트(목업).
class _CrewUploadSheet extends StatelessWidget {
  final void Function([XFile? file]) onPicked;

  const _CrewUploadSheet({required this.onPicked});

  Future<void> _pick(bool fromCamera) async {
    final picked = await ImagePicker().pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
    );
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
              textAlign: TextAlign.center,
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
            const SizedBox(height: SDSSpacing.sm),
            Text(
              '스노우라이브에서 사용하실 크루 이미지를 선택해주세요.\n크루 이미지는 나중에 업로드할 수 있어요.',
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500, height: 1.5),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 14, color: foreground)),
    );
  }
}

class _CrewImagePickerModal extends StatefulWidget {
  final XFile? initial;
  final void Function([XFile? file]) onDone;

  const _CrewImagePickerModal({required this.initial, required this.onDone});

  @override
  State<_CrewImagePickerModal> createState() => _CrewImagePickerModalState();
}

class _CrewImagePickerModalState extends State<_CrewImagePickerModal> {
  WebFileDrop? _drop;
  bool _isDragging = false;
  XFile? _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
    // 모달이 열려 있는 동안만 문서 드롭을 가로챈다(안 하면 브라우저가 새 탭에서 연다).
    _drop = WebFileDrop.attach(
      onFiles: (files) {
        if (files.isEmpty || !mounted) return;
        setState(() => _picked = files.first);
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

  Future<void> _pickFromDevice() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null && mounted) setState(() => _picked = picked);
  }

  @override
  Widget build(BuildContext context) {
    final file = _picked;
    final isMobile = context.screenType == WebScreenType.mobile;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: SDSColor.snowliveWhite,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  SDSSpacing.lg, SDSSpacing.md, SDSSpacing.lg, SDSSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      // 인자 없이 닫으면 취소다(고른 사진을 반영하지 않는다).
                      onPressed: () => widget.onDone(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      icon: Icon(Icons.close, size: 22, color: SDSColor.gray500),
                    ),
                  ),
                  Text(
                    // 목업: 사진이 있으면 `등록`, 없으면 `선택`.
                    file == null ? '크루 이미지 선택' : '크루 이미지 등록',
                    textAlign: TextAlign.center,
                    style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                  ),
                  const SizedBox(height: SDSSpacing.xs),
                  Text(
                    isMobile ? '앨범에서 사진을 선택하세요' : '여기에 사진을 드래그하세요',
                    textAlign: TextAlign.center,
                    style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
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
                      clipBehavior: Clip.antiAlias,
                      child: file == null
                          ? Center(
                              child: SvgPicture.asset(
                                'assets/imgs/icons/icon_input_camera.svg',
                                width: 40,
                                height: 40,
                              ),
                            )
                          // 웹의 XFile.path는 blob URL이라 Image.network로 그린다.
                          : Image.network(file.path, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: SDSSpacing.lg),
                  Center(
                    child: SizedBox(
                      width: 210,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _pickFromDevice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SDSColor.gray50,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
        ),
        const SizedBox(height: SDSSpacing.md),
        // 목업의 확정 버튼 — 카드 밖 아래에 파란 원형 체크다.
        Material(
          color: file == null ? SDSColor.gray300 : SDSColor.snowliveBlue,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: file == null ? null : () => widget.onDone(file),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.check, size: 24, color: SDSColor.snowliveWhite),
            ),
          ),
        ),
      ],
    );
  }
}
