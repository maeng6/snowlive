import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_file_drop.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_step_modal_web.dart';
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkUpload_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_switch_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// `라이브톡 올리기` — 사진 선택 → 글 작성 2단계(목업).
/// 등록에 성공하면 true를 리턴해 호출자가 피드를 새로고침한다.
/// [crewId]를 주면 **크루톡 올리기**로 동작한다(제목이 바뀌고 공개범위 토글이 붙는다).
/// 올리는 절차 자체는 라이브톡과 완전히 같다.
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

  /// 모바일만 하단 시트 — 중앙 카드와 여백 규칙이 다르다.
  bool get _isMobile => context.screenType == WebScreenType.mobile;

  WebFileDrop? _drop;

  LiveTalkUploadViewModelWeb get _vm => widget.vm;

  void _onComposeChanged() {
    // 이미지 없이 글만 올릴 때, 글 입력에 따라 업로드 버튼 활성/비활성이 바뀐다.
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onComposeChanged);
    // 모달이 열려 있는 동안만 문서 드롭을 가로챈다. 이걸 안 하면 브라우저가
    // 드롭된 이미지를 새 탭에서 열어버린다.
    _drop = WebFileDrop.attach(
      onFiles: (files) {
        // 지금 단계에 그대로 머문다 — 1단계면 미리보기, 글 작성 단계면 `사진 추가`
        // 칸이 썸네일로 바뀐다(쓰던 글이 그대로 남는다).
        _vm.setPickedImage(files.first);
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
    await showLiveTalkUploadDoneDialog(context, isCrewTalk: _isCrewTalk);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isStep0 = _step == 0;
      return LiveTalkStepModal(
        title: _isCrewTalk ? '크루톡 올리기' : '라이브톡 올리기',
        // 모바일은 시트가 안내 문구를 그리지 않는다 — 1단계는 **사진 칸 아래**,
        // 2단계는 문구 자체가 없는 게 목업이라 위치를 본문이 정한다.
        subtitle: _isMobile
            ? null
            : (isStep0
                ? _pickSubtitle(context)
                : (_vm.hasPickedImage ? '글 내용을 입력하세요.' : '사진 없이 글만 올려요.')),
        onClose: widget.onClose,
        onBack: isStep0 ? null : () => setState(() => _step = 0),
        onNext: _nextAction(isStep0),
        nextLabel: isStep0 ? '다음' : '업로드',
        isFinalStep: !isStep0,
        // 두 단계가 같은 높이라 다음/이전을 눌러도 카드가 흔들리지 않는다.
        // 본문 아래 여백은 이 높이에서 **남는 만큼**이 자동으로 된다
        // (PC 1단계 40·2단계 30 / 태블릿 1단계 25 — 전부 목업값과 일치).
        minHeight: _uploadModalHeight(context),
        // 모바일 시트는 요소마다 좌우 여백이 다르다(버튼 20 / 글 작성 16 /
        // 안내 20) — 본문이 직접 든다.
        mobileBodyPadding: EdgeInsets.zero,
        body: isStep0 ? _buildPickStep(context) : _buildComposeStep(),
      );
    });
  }

  /// 카드(시트) 높이. 목업 높이에 `글만 올리기` 줄이 들어갈 자리를 더한다 —
  /// 목업엔 이 줄이 없어서, 목업 높이 그대로 두면 줄이 카드 아래 끝에 붙어 버렸다.
  /// 두 단계가 같은 높이를 쓰고, 글 작성 칸이 늘어난 만큼을 받는다([_composeExtra]).
  double _uploadModalHeight(BuildContext context) => switch (context.screenType) {
        WebScreenType.desktop => kLiveTalkModalHeight + _kTextOnlyExtraDesktop,
        WebScreenType.tablet => kLiveTalkModalHeightTablet + _kTextOnlyExtraTablet,
        WebScreenType.mobile => kLiveTalkSheetHeightMobile + _kTextOnlyExtraMobile,
      };

  /// 카드가 목업보다 커진 만큼 2단계 글 작성 칸을 키운다(두 단계 높이를 같게).
  double get _composeExtra => switch (context.screenType) {
        WebScreenType.desktop => _kTextOnlyExtraDesktop,
        WebScreenType.tablet => _kTextOnlyExtraTablet,
        WebScreenType.mobile => _kTextOnlyExtraMobile,
      };

  /// PC·태블릿은 같은 드래그 안내(목업 80:217253 / 80:228872), 모바일만 앨범/촬영 안내.
  ///
  /// 사진 없이 글만 올릴 수도 있어서 그 안내를 **문구에 같이 적는다**(사용자 확정) —
  /// 예전에는 아래에 `사진 없이 글만 올리기` 버튼을 따로 뒀는데, 다음 버튼이 늘
  /// 활성이라 그냥 넘어가면 되므로 버튼은 없앴다.
  String _pickSubtitle(BuildContext context) =>
      context.screenType == WebScreenType.mobile
          ? '라이브톡에 올릴 사진을 앨범에서 선택하거나 촬영해주세요\n사진 없이 글만 올려도 괜찮아요'
          : '여기에 사진을 드래그하세요\n사진 없이 글만 올려도 괜찮아요';

  VoidCallback? _nextAction(bool isStep0) {
    if (_vm.isSubmitting) return null;
    if (isStep0) {
      // 사진이 없어도 글만 올릴 수 있으므로 **늘 활성**이다(사용자 확정).
      // 실제로 올릴 수 있는지는 2단계에서 사진·글 유무로 판정한다.
      return () => setState(() => _step = 1);
    }
    // 2단계(업로드): 이미지가 있거나 글이 있으면 올릴 수 있다(둘 다 없으면 비활성).
    final canSubmit = _vm.hasPickedImage || _textController.text.trim().isNotEmpty;
    return canSubmit ? _submit : null;
  }

  /// 사진 칸 → 간격 → (모바일만 안내 문구) → 버튼
  /// (피그마 PC 80:217253 / 태블릿 80:228872 / 모바일 80:249711).
  ///
  /// PC·태블릿은 버튼 아래 여백을 쓰지 않는다 — 카드 높이에서 남는 만큼이 그대로
  /// 여백이 된다(PC 40 / 태블릿 25). 높이가 고정이 아닌 모바일 시트만 직접 든다.
  Widget _buildPickStep(BuildContext context) {
    final isMobile = _isMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _ImagePreviewBox(vm: _vm, isDragging: _isDragging)),
        SizedBox(
          height: switch (context.screenType) {
            // 목업 — PC 42 / 태블릿 50.
            WebScreenType.desktop => _kPickGap,
            WebScreenType.tablet => 50,
            // 모바일은 사진 칸 아래에 안내 문구가 먼저 온다.
            WebScreenType.mobile => 16,
          },
        ),
        if (isMobile) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _pickSubtitle(context),
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular.copyWith(
                fontSize: 14,
                color: SDSColor.gray500,
                height: 20 / 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (context.isDesktop)
          Center(
            child: SizedBox(
              // 사진 칸(240)보다 좁은 208 — 목업 실측.
              width: kLiveTalkPickButtonWidth,
              child: LiveTalkWideButton(
                label: '이미지 직접 선택하기',
                kind: LiveTalkWideButtonKind.quiet,
                onTap: () => _vm.pickImage(),
              ),
            ),
          )
        else
          // 좌우는 태블릿 20 / 모바일 10(목업), 사이는 둘 다 10.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
            child: Row(
              children: [
                Expanded(
                  child: LiveTalkWideButton(
                    label: '앨범에서 선택',
                    kind: LiveTalkWideButtonKind.secondary,
                    onTap: () => _vm.pickImage(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: LiveTalkWideButton(
                    label: '촬영',
                    kind: LiveTalkWideButtonKind.primary,
                    onTap: () => _vm.pickImage(fromCamera: true),
                  ),
                ),
              ],
            ),
          ),
        if (isMobile) const SizedBox(height: 10),
      ],
    );
  }

  /// 썸네일 → 간격 → 글 작성 (피그마 PC 80:219456 / 모바일 80:253768).
  /// PC·태블릿의 아래 여백은 1단계와 같은 이유로 카드 높이에서 남는 만큼이 된다.
  Widget _buildComposeStep() {
    final isMobile = _isMobile;
    // 크루톡은 공개범위 스위치가 한 블록 더 붙는다 → **글 작성 칸을 그만큼 줄여**
    // 시트·카드 전체 높이를 1단계(사진 고르기)와 같게 유지한다.
    final double composeHeight = (isMobile ? 195 : 181) +
        _composeExtra -
        (_isCrewTalk ? SDSSpacing.md + _kVisibilityToggleHeight : 0);
    final double slot = isMobile ? 120 : 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 썸네일 자리는 늘 같은 크기로 둔다 — 사진이 있으면 썸네일(✕로 빼기),
        // 없으면 `사진 추가` 칸. 그래서 글만 올릴 때도 카드 아래가 비지 않고,
        // 쓰던 글을 두고 사진을 넣었다 뺐다 할 수 있다(드래그앤드롭도 된다).
        Center(
          child: _vm.hasPickedImage
              ? _ImageThumb(vm: _vm, size: slot, onRemove: _vm.clearPickedImage)
              : _AddPhotoSlot(size: slot, isDragging: _isDragging, onTap: () => _vm.pickImage()),
        ),
        SizedBox(height: isMobile ? 20 : 30),
        Padding(
          // 모바일 시트는 좌우 여백을 요소마다 따로 든다(글 작성 블록 16).
          padding: EdgeInsets.symmetric(horizontal: isMobile ? SDSSpacing.md : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LiveTalkComposeField(
                controller: _textController,
                height: composeHeight,
                hintText: _isCrewTalk
                    ? '크루톡 글을 남겨주세요.'
                    : '라이브톡 글을 남겨주세요.',
              ),
              if (_isCrewTalk) ...[
                const SizedBox(height: SDSSpacing.md),
                SizedBox(
                  // 높이를 못 박아야 위에서 줄인 값과 정확히 상쇄된다.
                  height: _kVisibilityToggleHeight,
                  child: _VisibilityToggle(
                    isPublic: _isPublic,
                    onChanged: (value) => setState(() => _isPublic = value),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isMobile) const SizedBox(height: 20),
      ],
    );
  }
}

/// 1단계 사진 칸 ↔ 버튼(PC·태블릿). 목업 42/50.
const double _kPickGap = 42;

/// 카드가 목업보다 커지는 양. 안내 문구가 **두 줄**이 되면서(사진 없이도 올릴 수
/// 있다는 안내를 더했다) 늘어난 한 줄만큼이다. 모바일은 본문에 문구가 들어 있어
/// 그 줄만큼, PC·태블릿은 부제라 카드 머리 쪽에서 늘어난다.
const double _kTextOnlyExtraDesktop = 20;
const double _kTextOnlyExtraTablet = 20;
const double _kTextOnlyExtraMobile = 20;

/// 1단계 사진 칸 한 변(PC·태블릿 목업 240). 카드 390 안에서 좌우 75씩 남는다.
const double kLiveTalkPickBoxSize = 240;

/// 모바일 1단계 사진 칸 한 변(목업 80:249711). 시트 375 안에서 좌우 72.5씩.
const double kLiveTalkPickBoxSizeMobile = 230;

/// 1단계 `이미지 직접 선택하기` 버튼 폭(목업 208).
const double kLiveTalkPickButtonWidth = 208;

/// 1단계의 사진 칸(240 정사각). 사진이 없으면 회색 바탕에 카메라 아이콘만
/// 보인다 — 크루 만들기 사진 선택과 같은 구성이다.
class _ImagePreviewBox extends StatelessWidget {
  final LiveTalkUploadViewModelWeb vm;

  /// 파일을 끌고 온 동안 테두리를 켠다 — 드롭이 먹는다는 유일한 신호다.
  final bool isDragging;

  const _ImagePreviewBox({required this.vm, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    final file = vm.pickedImage;
    final side = context.screenType == WebScreenType.mobile
        ? kLiveTalkPickBoxSizeMobile
        : kLiveTalkPickBoxSize;
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: isDragging ? SDSColor.blue50 : SDSColor.gray50,
        borderRadius: BorderRadius.circular(4),
        border: isDragging ? Border.all(color: SDSColor.snowliveBlue, width: 2) : null,
      ),
      clipBehavior: Clip.antiAlias,
      // 웹의 XFile.path는 blob URL이라 Image.network로 그린다.
      child: file == null
          ? Center(
              // ⚠️ colorFilter로 색을 덮지 않는다 — srcIn은 실루엣 전체를 칠해서
              // 렌즈처럼 흰색으로 뚫어둔 구멍까지 메워버린다. 색은 그대로 두고
              // 불투명도만 낮춰 연하게 만든다(검정 10%를 덮었을 때와 같은 밝기).
              child: Opacity(
                opacity: 0.25,
                child: SvgPicture.asset(
                  'assets/imgs/icons/icon_input_camera.svg',
                  width: 48,
                  height: 48,
                ),
              ),
            )
          : Image.network(file.path, fit: BoxFit.cover),
    );
  }
}

/// 2단계의 작은 썸네일. PC·태블릿 100 / 모바일 120(목업). 우상단 ✕로 사진을 뺀다
/// (= 글만 올리기로 전환, 쓰던 글은 그대로).
class _ImageThumb extends StatelessWidget {
  final LiveTalkUploadViewModelWeb vm;
  final double size;
  final VoidCallback onRemove;

  const _ImageThumb({required this.vm, required this.size, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final file = vm.pickedImage;
    if (file == null) return SizedBox(width: size, height: size);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(file.path, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Tooltip(
              message: '사진 빼기',
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    key: const ValueKey('livetalk-remove-photo'),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: SDSColor.snowliveBlack.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: SDSColor.snowliveWhite),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2단계에서 사진이 없을 때 썸네일 자리에 두는 `사진 추가` 칸. 누르면 사진을 고르고,
/// 파일을 끌고 오면 1단계 사진 칸처럼 파랗게 켜진다.
class _AddPhotoSlot extends StatefulWidget {
  final double size;
  final bool isDragging;
  final VoidCallback onTap;

  const _AddPhotoSlot({required this.size, required this.isDragging, required this.onTap});

  @override
  State<_AddPhotoSlot> createState() => _AddPhotoSlotState();
}

class _AddPhotoSlotState extends State<_AddPhotoSlot> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isDragging;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: active
                ? SDSColor.blue50
                : (_hovered ? SDSColor.gray100 : SDSColor.gray50),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: active ? SDSColor.snowliveBlue : SDSColor.gray200,
              width: active ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1단계 사진 칸과 **같은 카메라 아이콘**을 쓴다(크기만 26으로 줄임).
              // ⚠️ colorFilter로 색을 덮지 않는다 — srcIn은 실루엣 전체를 칠해서
              // 렌즈처럼 흰색으로 뚫어둔 구멍까지 메워버린다. 색은 그대로 두고
              // 불투명도만 조절한다(1단계와 같은 처리).
              Opacity(
                opacity: active ? 0.55 : 0.25,
                child: SvgPicture.asset(
                  'assets/imgs/icons/icon_input_camera.svg',
                  width: 26,
                  height: 26,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '사진 추가',
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 12,
                  height: 16 / 12,
                  color: active ? SDSColor.snowliveBlue : SDSColor.gray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 업로드 완료 알럿(목업: `라이브톡 업로드 완료됐어요` + `확인`). 크루톡이면 문구만 바꾼다.
Future<void> showLiveTalkUploadDoneDialog(BuildContext context,
    {bool isCrewTalk = false}) {
  return showWebOverlayModal<void>(
    context: context,
    barrierDismissible: false,
    // 웹 표준 팝업 카드 스펙(라운드 16 / 최대폭 320 / 패딩 24,28,24,12 /
    // 타이틀 bold 16) — showWebConfirmDialog와 동일. 버튼 구성만 목업대로.
    builder: (_, close) => Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isCrewTalk ? '크루톡 업로드가 완료됐어요' : '라이브톡 업로드 완료됐어요',
              textAlign: TextAlign.center,
              style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
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

/// 공개범위 스위치 줄 높이. 글 작성 칸을 이만큼 줄여 전체 높이를 맞춘다.
const double _kVisibilityToggleHeight = 36;

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
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⚠️ 두 줄 모두 line height를 못 박는다 — Pretendard 기본 줄 높이는
              // 더 커서 줄 높이 36(= 글 작성 칸에서 빼둔 값)을 넘겨 오버플로우가 난다.
              Text(
                '전체공개',
                style: SDSTextStyle.bold.copyWith(
                    fontSize: 14, height: 18 / 14, color: SDSColor.gray900),
              ),
              const SizedBox(height: 2),
              Text(
                isPublic ? '라이브톡에도 글이 노출돼요.' : '크루원만 볼 수 있어요.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.regular.copyWith(
                    fontSize: 12, height: 16 / 12, color: SDSColor.gray500),
              ),
            ],
          ),
        ),
        // 크기·색 규칙은 공용 WebSwitch에 있다.
        WebSwitch(value: isPublic, onChanged: onChanged),
      ],
    );
  }
}
