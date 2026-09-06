import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_file_drop.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_step_modal_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkUpload_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// `라이브톡 올리기` — 사진 선택 → 글 작성 2단계(목업).
/// 등록에 성공하면 true를 리턴해 호출자가 피드를 새로고침한다.
/// [crewId]를 주면 **크루톡 올리기**로 동작한다(제목이 바뀌고 공개범위 토글이 붙는다).
/// 올리는 절차 자체는 라이브톡과 완전히 같다(사용자 확정).
Future<bool> showLiveTalkUploadFlow({
  required BuildContext context,
  required int userId,
  int? crewId,
}) async {
  final vm = Get.find<LiveTalkUploadViewModelWeb>();
  vm.reset();

  final done = await showWebOverlayModal<bool>(
    context: context,
    // 모바일은 하단 시트, 그 외는 중앙 카드(목업).
    alignment: context.screenType == WebScreenType.mobile
        ? Alignment.bottomCenter
        : Alignment.center,
    padding: context.screenType == WebScreenType.mobile
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    builder: (ctx, close) =>
        _UploadFlow(vm: vm, userId: userId, crewId: crewId, onClose: close),
  );
  return done ?? false;
}

class _UploadFlow extends StatefulWidget {
  final LiveTalkUploadViewModelWeb vm;
  final int userId;

  /// null이면 일반 라이브톡, 값이 있으면 그 크루의 크루톡.
  final int? crewId;
  final void Function([bool? result]) onClose;

  const _UploadFlow({
    required this.vm,
    required this.userId,
    required this.crewId,
    required this.onClose,
  });

  @override
  State<_UploadFlow> createState() => _UploadFlowState();
}

class _UploadFlowState extends State<_UploadFlow> {
  final _textController = TextEditingController();
  int _step = 0;

  /// 파일을 문서 위로 끌고 온 상태. 드롭 영역에 테두리를 켜서 알려준다.
  bool _isDragging = false;

  /// 크루톡 공개범위. 기본은 전체공개(라이브크루 홈 갤러리에도 노출된다).
  bool _isPublic = true;

  bool get _isCrewTalk => widget.crewId != null;

  WebFileDrop? _drop;

  LiveTalkUploadViewModelWeb get _vm => widget.vm;

  @override
  void initState() {
    super.initState();
    // 모달이 열려 있는 동안만 문서 드롭을 가로챈다. 이걸 안 하면 브라우저가
    // 드롭된 이미지를 새 탭에서 열어버린다.
    _drop = WebFileDrop.attach(
      onFiles: (files) {
        _vm.setPickedImage(files.first);
        // 사진이 들어왔으니 바로 다음 단계로 갈 수 있게 첫 단계로 맞춰둔다.
        if (mounted && _step != 0) setState(() => _step = 0);
      },
      onDragChanged: (dragging) {
        if (mounted && dragging != _isDragging) {
          setState(() => _isDragging = dragging);
        }
      },
    );
  }

  @override
  void dispose() {
    _drop?.detach();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await _vm.submitPhoto(
      userId: widget.userId,
      description: _textController.text.trim(),
      crewId: widget.crewId,
      // 서버는 crew_id가 있으면 secret을 반드시 요구한다.
      secret: _isCrewTalk ? !_isPublic : null,
    );
    if (!ok) {
      Get.snackbar('오류', '업로드에 실패했어요. 잠시 후 다시 시도해주세요.');
      return;
    }
    widget.onClose(true);
    // 목업: 업로드가 끝나면 완료 알럿을 띄운다.
    await showLiveTalkUploadDoneDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isStep0 = _step == 0;
      return LiveTalkStepModal(
        title: _isCrewTalk ? '크루톡 올리기' : '라이브톡 올리기',
        subtitle: isStep0 ? _pickSubtitle(context) : '글 내용을 입력하세요.',
        onClose: widget.onClose,
        onBack: isStep0 ? null : () => setState(() => _step = 0),
        onNext: _nextAction(isStep0),
        nextLabel: isStep0 ? '다음' : '업로드',
        isFinalStep: !isStep0,
        body: isStep0 ? _buildPickStep(context) : _buildComposeStep(),
      );
    });
  }

  /// 데스크탑은 드래그 안내, 태블릿·모바일은 앨범/촬영 안내(목업).
  String _pickSubtitle(BuildContext context) => context.isDesktop
      ? '여기에 사진을 드래그하세요'
      : '라이브톡에 올릴 사진을\n앨범에서 선택하거나 촬영해주세요';

  VoidCallback? _nextAction(bool isStep0) {
    if (_vm.isSubmitting) return null;
    if (isStep0) {
      // 사진이 없으면 진행 버튼이 비활성이다(목업의 회색 `›`).
      return _vm.hasPickedImage ? () => setState(() => _step = 1) : null;
    }
    return _submit;
  }

  Widget _buildPickStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ImagePreviewBox(vm: _vm, isDragging: _isDragging),
        const SizedBox(height: SDSSpacing.lg),
        if (context.isDesktop)
          _WideButton(
            label: '이미지 직접 선택하기',
            isPrimary: false,
            onTap: () => _vm.pickImage(),
          )
        else
          Row(
            children: [
              Expanded(
                child: _WideButton(
                  label: '앨범에서 선택',
                  isPrimary: false,
                  onTap: () => _vm.pickImage(),
                ),
              ),
              const SizedBox(width: SDSSpacing.sm),
              Expanded(
                child: _WideButton(
                  label: '촬영',
                  isPrimary: true,
                  onTap: () => _vm.pickImage(fromCamera: true),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildComposeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _ImageThumb(vm: _vm)),
        const SizedBox(height: SDSSpacing.lg),
        LiveTalkComposeField(controller: _textController),
        if (_isCrewTalk) ...[
          const SizedBox(height: SDSSpacing.md),
          _VisibilityToggle(
            isPublic: _isPublic,
            onChanged: (value) => setState(() => _isPublic = value),
          ),
        ],
      ],
    );
  }
}

/// 1단계의 큰 미리보기 박스. 사진이 없으면 빈 회색 박스다(목업).
class _ImagePreviewBox extends StatelessWidget {
  final LiveTalkUploadViewModelWeb vm;

  /// 파일을 끌고 온 동안 테두리를 켠다 — 드롭이 먹는다는 유일한 신호다.
  final bool isDragging;

  const _ImagePreviewBox({required this.vm, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    final file = vm.pickedImage;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: isDragging ? SDSColor.blue50 : SDSColor.gray50,
          borderRadius: BorderRadius.circular(4),
          border: isDragging ? Border.all(color: SDSColor.snowliveBlue, width: 2) : null,
        ),
        clipBehavior: Clip.antiAlias,
        // 웹의 XFile.path는 blob URL이라 Image.network로 그린다.
        child: file == null
            ? null
            : Image.network(file.path, fit: BoxFit.cover),
      ),
    );
  }
}

/// 2단계의 작은 썸네일.
class _ImageThumb extends StatelessWidget {
  final LiveTalkUploadViewModelWeb vm;

  const _ImageThumb({required this.vm});

  @override
  Widget build(BuildContext context) {
    final file = vm.pickedImage;
    if (file == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(file.path, width: 100, height: 100, fit: BoxFit.cover),
    );
  }
}

class _WideButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _WideButton({required this.label, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? SDSColor.snowliveBlue : SDSColor.gray50,
        elevation: 0,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(
          fontSize: 14,
          color: isPrimary ? SDSColor.snowliveWhite : SDSColor.gray900,
        ),
      ),
    );
  }
}

/// 업로드 완료 알럿(목업: `라이브톡 업로드 완료됐어요` + `확인`).
Future<void> showLiveTalkUploadDoneDialog(BuildContext context) {
  return showWebOverlayModal<void>(
    context: context,
    barrierDismissible: false,
    builder: (_, close) => Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '라이브톡 업로드 완료됐어요',
              textAlign: TextAlign.center,
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
            const SizedBox(height: SDSSpacing.lg),
            ElevatedButton(
              onPressed: () => close(),
              style: ElevatedButton.styleFrom(
                backgroundColor: SDSColor.snowliveBlue,
                elevation: 0,
                shadowColor: Colors.transparent,
                overlayColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('확인',
                  style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite)),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 크루톡 공개범위 스위치. 전체공개면 라이브크루 홈 갤러리에도 노출된다.
class _VisibilityToggle extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const _VisibilityToggle({required this.isPublic, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '전체공개',
                style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
              ),
              const SizedBox(height: 2),
              Text(
                isPublic ? '라이브크루 홈에도 사진이 보여요.' : '크루원만 볼 수 있어요.',
                style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
              ),
            ],
          ),
        ),
        Switch(
          value: isPublic,
          onChanged: onChanged,
          activeTrackColor: SDSColor.snowliveBlue,
        ),
      ],
    );
  }
}
