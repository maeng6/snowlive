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
        // 모바일은 시트가 안내 문구를 그리지 않는다 — 1단계는 **사진 칸 아래**,
        // 2단계는 문구 자체가 없는 게 목업이라 위치를 본문이 정한다.
        subtitle: _isMobile
            ? null
            : (isStep0 ? _pickSubtitle(context) : '글 내용을 입력하세요.'),
        onClose: widget.onClose,
        onBack: isStep0 ? null : () => setState(() => _step = 0),
        onNext: _nextAction(isStep0),
        nextLabel: isStep0 ? '다음' : '업로드',
        isFinalStep: !isStep0,
        // 두 단계가 같은 높이라 다음/이전을 눌러도 카드가 흔들리지 않는다.
        // 본문 아래 여백은 이 높이에서 **남는 만큼**이 자동으로 된다
        // (PC 1단계 40·2단계 30 / 태블릿 1단계 25 — 전부 목업값과 일치).
        minHeight: switch (context.screenType) {
          WebScreenType.desktop => kLiveTalkModalHeight,
          WebScreenType.tablet => kLiveTalkModalHeightTablet,
          WebScreenType.mobile => kLiveTalkSheetHeightMobile,
        },
        // 모바일 시트는 요소마다 좌우 여백이 다르다(버튼 20 / 글 작성 16 /
        // 안내 20) — 본문이 직접 든다.
        mobileBodyPadding: EdgeInsets.zero,
        body: isStep0 ? _buildPickStep(context) : _buildComposeStep(),
      );
    });
  }

  /// PC·태블릿은 같은 드래그 안내(목업 80:217253 / 80:228872), 모바일만 앨범/촬영 안내.
  String _pickSubtitle(BuildContext context) =>
      context.screenType == WebScreenType.mobile
          ? '라이브톡에 올릴 사진을\n앨범에서 선택하거나 촬영해주세요'
          : '여기에 사진을 드래그하세요';

  VoidCallback? _nextAction(bool isStep0) {
    if (_vm.isSubmitting) return null;
    if (isStep0) {
      // 사진이 없으면 진행 버튼이 비활성이다(목업의 회색 `›`).
      // 대신 아래 '이미지 없이 글만 올리기'로 텍스트만 올릴 수 있다.
      return _vm.hasPickedImage ? () => setState(() => _step = 1) : null;
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
            WebScreenType.desktop => 42,
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
          const SizedBox(height: 34),
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
        // 이미지 없이 글만 올리고 싶을 때 — 2단계(글 작성)로 바로 넘어간다.
        const SizedBox(height: 14),
        Center(
          child: _SkipImageLink(onTap: () => setState(() => _step = 1)),
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
    final double composeHeight = (isMobile ? 195 : 181) -
        (_isCrewTalk ? SDSSpacing.md + _kVisibilityToggleHeight : 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 이미지 없이 글만 올릴 때는 썸네일 자리를 비운다.
        if (_vm.hasPickedImage) ...[
          Center(child: _ImageThumb(vm: _vm, size: isMobile ? 120 : 100)),
          SizedBox(height: isMobile ? 20 : 30),
        ],
        Padding(
          // 모바일 시트는 좌우 여백을 요소마다 따로 든다(글 작성 블록 16).
          padding: EdgeInsets.symmetric(horizontal: isMobile ? SDSSpacing.md : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LiveTalkComposeField(
                controller: _textController,
                height: composeHeight,
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

/// 2단계의 작은 썸네일. PC·태블릿 100 / 모바일 120(목업).
class _ImageThumb extends StatelessWidget {
  final LiveTalkUploadViewModelWeb vm;
  final double size;

  const _ImageThumb({required this.vm, required this.size});

  @override
  Widget build(BuildContext context) {
    final file = vm.pickedImage;
    if (file == null) return SizedBox(height: size);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(file.path, width: size, height: size, fit: BoxFit.cover),
    );
  }
}

/// 업로드 완료 알럿(목업: `라이브톡 업로드 완료됐어요` + `확인`).
Future<void> showLiveTalkUploadDoneDialog(BuildContext context) {
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
              '라이브톡 업로드 완료됐어요',
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
                isPublic ? '라이브크루 홈에도 사진이 보여요.' : '크루원만 볼 수 있어요.',
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

/// `이미지 없이 글만 올리기` — 1단계에서 2단계(글 작성)로 바로 넘어가는 텍스트 링크.
class _SkipImageLink extends StatefulWidget {
  final VoidCallback onTap;

  const _SkipImageLink({required this.onTap});

  @override
  State<_SkipImageLink> createState() => _SkipImageLinkState();
}

class _SkipImageLinkState extends State<_SkipImageLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Opacity(
          opacity: _hovered ? 0.6 : 1.0,
          child: Text(
            '이미지 없이 글만 올리기',
            style: SDSTextStyle.bold.copyWith(
              fontSize: 14,
              color: SDSColor.gray500,
              decoration: TextDecoration.underline,
              decorationColor: SDSColor.gray500,
            ),
          ),
        ),
      ),
    );
  }
}
