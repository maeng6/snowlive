import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_riding_card_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_step_modal_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_upload_flow_web.dart' show showLiveTalkUploadDoneDialog;
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkUpload_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// `라이딩 기록 카드 공유` — 기록없음 / 카드 선택 → 글 작성(목업).
///
/// 오늘 라이딩 기록이 없으면 카드 단계로 가지 않고 앱 다운로드 안내만 띄운다.
/// 웹에서는 라이브온을 할 수 없으므로 게스트는 항상 그 상태다.
Future<bool> showLiveTalkCardShareFlow({
  required BuildContext context,
  required int? userId,
}) async {
  final vm = Get.find<LiveTalkUploadViewModelWeb>();
  vm.reset();
  if (userId != null) await vm.loadRidingCard(userId);

  final isMobile = context.screenType == WebScreenType.mobile;
  final done = await showWebOverlayModal<bool>(
    context: context,
    alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
    padding: isMobile
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    builder: (ctx, close) => _CardShareFlow(vm: vm, userId: userId, onClose: close),
  );
  return done ?? false;
}

class _CardShareFlow extends StatefulWidget {
  final LiveTalkUploadViewModelWeb vm;
  final int? userId;
  final void Function([bool? result]) onClose;

  const _CardShareFlow({required this.vm, required this.userId, required this.onClose});

  @override
  State<_CardShareFlow> createState() => _CardShareFlowState();
}

class _CardShareFlowState extends State<_CardShareFlow> {
  final _textController = TextEditingController();

  /// 캡처 대상. 미리보기와 캡처가 같은 위젯이라 이 키를 카드에 씌운다.
  final _boundaryKey = GlobalKey();

  int _step = 0;

  LiveTalkUploadViewModelWeb get _vm => widget.vm;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = widget.userId;
    if (userId == null) return;
    final ok = await _vm.submitCard(
      userId: userId,
      description: _textController.text.trim(),
      boundaryKey: _boundaryKey,
    );
    if (!ok) {
      Get.snackbar('오류', '업로드에 실패했어요. 잠시 후 다시 시도해주세요.');
      return;
    }
    widget.onClose(true);
    await showLiveTalkUploadDoneDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_vm.isLoadingCard) {
        return LiveTalkStepModal(
          title: '라이딩 기록 카드 공유',
          onClose: widget.onClose,
          showNext: false,
          body: const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      }

      if (!_vm.hasRidingRecord) return _buildNoRecord();
      return _step == 0 ? _buildSelectStep() : _buildComposeStep();
    });
  }

  /// 기록 없음 — 카드 단계로 넘어갈 수 없으므로 진행 버튼을 아예 두지 않는다.
  Widget _buildNoRecord() {
    return LiveTalkStepModal(
      title: '라이딩 기록 카드 공유',
      subtitle: '아직 오늘의 라이딩 기록이 없어요.\n스노우라이브 앱을 다운받아 라이브온해보세요.',
      onClose: widget.onClose,
      // 다음 단계가 없는 화면이라 진행 버튼을 아예 두지 않는다(목업).
      showNext: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 카드 데이터가 없으니 배경만 작게 보여준다(목업).
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(kRidingCardBackgrounds[0], width: 48, height: 68, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: SDSSpacing.lg),
          ElevatedButton(
            onPressed: () => Get.snackbar('알림', '앱 다운로드 링크는 준비 중이에요.'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SDSColor.gray50,
              elevation: 0,
              shadowColor: Colors.transparent,
              overlayColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('앱 다운로드 받기',
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
          ),
        ],
      ),
    );
  }

  /// 카드 3종 중 하나를 고른다.
  Widget _buildSelectStep() {
    return LiveTalkStepModal(
      title: '라이딩 기록 카드 공유',
      subtitle: '원하는 카드를 선택해 업로드하세요.',
      onClose: widget.onClose,
      onNext: () => setState(() => _step = 1),
      body: Column(
        children: [
          _buildCard(width: 200),
          const SizedBox(height: SDSSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < kRidingCardBackgrounds.length; i++) ...[
                _CardThumb(
                  asset: kRidingCardBackgrounds[i],
                  isSelected: _vm.selectedCardType == i,
                  onTap: () => _vm.selectCardType(i),
                ),
                if (i != kRidingCardBackgrounds.length - 1) const SizedBox(width: SDSSpacing.sm),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComposeStep() {
    return LiveTalkStepModal(
      title: '라이딩 기록 카드 공유',
      subtitle: '원하는 카드를 선택해 업로드하세요.',
      onClose: widget.onClose,
      onBack: () => setState(() => _step = 0),
      onNext: _vm.isSubmitting ? null : _submit,
      nextLabel: '업로드',
      isFinalStep: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 캡처 대상은 항상 트리에 있어야 한다. 작성 단계에서도 카드를 그려둔다.
          Center(child: _buildCard(width: 100)),
          const SizedBox(height: SDSSpacing.lg),
          LiveTalkComposeField(controller: _textController),
        ],
      ),
    );
  }

  /// 캡처 대상 카드. RepaintBoundary로 감싸야 toImage로 뽑을 수 있다.
  Widget _buildCard({required double width}) {
    final card = _vm.ridingCard;
    if (card == null) return const SizedBox.shrink();
    return RepaintBoundary(
      key: _boundaryKey,
      child: LiveTalkRidingCardWeb(
        card: card,
        cardType: _vm.selectedCardType,
        width: width,
      ),
    );
  }
}

/// 카드 배경 썸네일. 선택된 것에 파란 테두리(목업).
class _CardThumb extends StatelessWidget {
  final String asset;
  final bool isSelected;
  final VoidCallback onTap;

  const _CardThumb({required this.asset, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? SDSColor.snowliveBlue : Colors.transparent,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Image.asset(asset, width: 40, height: 56, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
