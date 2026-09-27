import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_riding_card_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_step_modal_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_upload_flow_web.dart'
    show showLiveTalkUploadDoneDialog;
import 'package:com.snowlive/web/viewmodel/liveTalk/vm_liveTalkUpload_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 카드 선택·글 작성 단계의 카드 높이(피그마 80:218042 551 / 80:218562 552).
/// 1 차이라 큰 쪽으로 통일해 단계 전환 시 카드가 안 흔들리게 한다.
/// 여기에 [kCardShareExtraBottom]을 더한 값이 실제 높이다.
const double kCardShareHeight = 552 + kCardShareExtraBottom;

/// 카드 아래 추가 여백(사용자 확정). 선택 테두리 칸이 썸네일 줄을 목업보다
/// 키워서 썸네일이 카드 바닥에 붙어 보이는 걸 되돌린다.
const double kCardShareExtraBottom = 10;

/// 기록 없음 안내 카드 높이(피그마 80:219429).
const double kCardShareNoRecordHeight = 323;

/// 1단계 큰 미리보기 카드 폭(목업 200 → 높이 317.5).
const double kCardSharePreviewWidth = 200;

/// 2단계 작은 카드 폭(목업 100.8 → 높이 160).
const double kCardShareThumbWidth = 100;

/// 1단계 배경 썸네일 폭(목업 40 → 높이 64).
const double kCardShareThumbSize = 40;

/// 모바일 시트 높이(피그마 80:250491 / 80:251381 — 두 단계 모두 551).
const double kCardShareSheetHeightMobile = 551;

/// 모바일 1단계에서 썸네일 줄 **위아래** 간격. 목업은 24인데, 선택 테두리 칸이
/// 썸네일을 6씩 감싸서 그만큼 줄여야 보이는 간격이 24가 되고 시트도 551에 맞는다.
/// (PC는 대신 카드 높이를 [kCardShareExtraBottom]만큼 키우는 쪽을 택했다.)
const double kCardShareThumbRowGapMobile = 18;

/// 모바일 기록 없음 시트 높이(피그마 80:252210).
const double kCardShareNoRecordSheetHeightMobile = 317;

/// 모바일 2단계 카드 폭(목업 135.4 → 높이 215). PC(100)보다 크다.
const double kCardShareThumbWidthMobile = 135;

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
  // 로컬 확인용 스위치가 켜져 있으면 서버 대신 가짜 기록을 쓴다(배포 전 false).
  if (kDebugFakeRidingCard) {
    vm.useFakeRidingCard();
  } else if (userId != null) {
    await vm.loadRidingCard(userId);
  }

  final isMobile = context.screenType == WebScreenType.mobile;
  final done = await showWebOverlayModal<bool>(
    context: context,
    alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
    padding: isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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

  bool get _isMobile => context.screenType == WebScreenType.mobile;

  /// 중앙 카드(PC·태블릿)와 하단 시트(모바일)는 높이가 다르다.
  double _cardHeight({required double wide, required double mobile}) => _isMobile ? mobile : wide;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_vm.isLoadingCard) {
        return LiveTalkStepModal(
          title: '라이딩 기록 카드 공유',
          onClose: widget.onClose,
          showNext: false,
          // 기록 유무를 모르는 동안은 작은 쪽(기록 없음) 높이로 둔다.
          minHeight: _cardHeight(
            wide: kCardShareNoRecordHeight,
            mobile: kCardShareNoRecordSheetHeightMobile,
          ),
          body: const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      }

      if (!_vm.hasRidingRecord) return _buildNoRecord();
      return _step == 0 ? _buildSelectStep() : _buildComposeStep();
    });
  }

  /// 기록 없음(피그마 80:219429 — 카드 390×323).
  /// 카드 단계로 넘어갈 수 없으므로 진행 버튼을 아예 두지 않는다.
  Widget _buildNoRecord() {
    return LiveTalkStepModal(
      title: '라이딩 기록 카드 공유',
      subtitle: '아직 오늘의 라이딩 기록이 없어요.\n스노우라이브 앱을 다운받아 라이브온해보세요.',
      onClose: widget.onClose,
      // 다음 단계가 없는 화면이라 진행 버튼을 아예 두지 않는다(목업).
      showNext: false,
      minHeight: _cardHeight(
        wide: kCardShareNoRecordHeight,
        mobile: kCardShareNoRecordSheetHeightMobile,
      ),
      mobileBodyPadding: EdgeInsets.zero,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 모바일은 안내 ↔ 아이콘이 30이라 셸의 15에 15를 더한다(목업 80:252210).
          if (_isMobile) const SizedBox(height: 15),
          // 카드 데이터가 없으니 배경만 작게 보여준다(목업 50×80 — 카드와 같은 비율).
          Center(child: _CardBackgroundThumb(asset: kRidingCardBackgrounds[0], width: 50)),
          const SizedBox(height: 40),
          Padding(
            // 모바일 버튼은 시트 좌우 10(목업). PC·태블릿은 셸 여백 안쪽 그대로.
            padding: EdgeInsets.symmetric(horizontal: _isMobile ? 10 : 0),
            child: LiveTalkWideButton(
              label: '앱 다운로드 받기',
              kind: LiveTalkWideButtonKind.quiet,
              onTap: () => Get.snackbar('알림', '앱 다운로드 링크는 준비 중이에요.'),
            ),
          ),
          if (_isMobile) const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// 카드 3종 중 하나를 고른다(피그마 80:218042 — 카드 390×551).
  Widget _buildSelectStep() {
    return LiveTalkStepModal(
      title: '라이딩 기록 카드 공유',
      onClose: widget.onClose,
      onNext: () => setState(() => _step = 1),
      minHeight: _cardHeight(wide: kCardShareHeight, mobile: kCardShareSheetHeightMobile),
      mobileBodyPadding: EdgeInsets.zero,
      // 모바일은 안내 문구가 **썸네일 줄 아래**라 본문이 직접 그린다(목업 80:250491).
      subtitle: _isMobile ? null : '원하는 카드를 선택해 업로드하세요.',
      body: Column(
        children: [
          _buildCard(width: kCardSharePreviewWidth),
          // 큰 카드 ↔ 썸네일 줄 — 목업 24, 모바일은 테두리 칸 몫을 뺀 18.
          SizedBox(height: _isMobile ? kCardShareThumbRowGapMobile : SDSSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < kRidingCardBackgrounds.length; i++) ...[
                _CardThumb(
                  asset: kRidingCardBackgrounds[i],
                  isSelected: _vm.selectedCardType == i,
                  onTap: () => _vm.selectCardType(i),
                ),
                // 썸네일 사이 10 — 선택 테두리 칸이 붙으면서 넓어 보여 목업(12.8)에서 줄임.
                if (i != kRidingCardBackgrounds.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
          // 모바일은 안내 문구가 썸네일 줄 아래에 온다(목업 80:250491).
          if (_isMobile) ...[
            const SizedBox(height: kCardShareThumbRowGapMobile),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '원하는 카드를 선택해 업로드하세요.',
                textAlign: TextAlign.center,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: SDSColor.gray500,
                  height: 20 / 14,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }

  /// 글 작성(피그마 80:218562 — 카드 390×552, 1단계와 같은 높이).
  Widget _buildComposeStep() {
    return LiveTalkStepModal(
      title: '라이딩 기록 카드 공유',
      onClose: widget.onClose,
      onBack: () => setState(() => _step = 0),
      onNext: _vm.isSubmitting ? null : _submit,
      nextLabel: '업로드',
      isFinalStep: true,
      minHeight: _cardHeight(wide: kCardShareHeight, mobile: kCardShareSheetHeightMobile),
      mobileBodyPadding: EdgeInsets.zero,
      // 모바일 2단계는 안내 문구가 없다(목업 80:251381).
      subtitle: _isMobile ? null : '원하는 카드를 선택해 업로드하세요.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 캡처 대상은 항상 트리에 있어야 한다. 작성 단계에서도 카드를 그려둔다.
          Center(
            child: _buildCard(width: _isMobile ? kCardShareThumbWidthMobile : kCardShareThumbWidth),
          ),
          // 카드 ↔ 글 작성 — PC 30 / 모바일 20(목업).
          SizedBox(height: _isMobile ? 20 : 30),
          Padding(
            // 모바일 글 작성 블록은 시트 좌우 16(목업).
            padding: EdgeInsets.symmetric(horizontal: _isMobile ? SDSSpacing.md : 0),
            // 입력칸 높이 PC 187 / 모바일 195(목업).
            child: LiveTalkComposeField(controller: _textController, height: _isMobile ? 195 : 187),
          ),
          if (_isMobile) const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 캡처 대상 카드. RepaintBoundary로 감싸야 toImage로 뽑을 수 있다.
  Widget _buildCard({required double width}) {
    final card = _vm.ridingCard;
    if (card == null) return const SizedBox.shrink();
    final user = Get.find<UserViewModel>().user;
    return RepaintBoundary(
      key: _boundaryKey,
      child: LiveTalkRidingCardWeb(
        card: card,
        cardType: _vm.selectedCardType,
        // 데일리 카드에는 닉네임·프로필이 없다(앱도 로그인 사용자에서 가져온다).
        displayName: user.display_name,
        profileImageUrl: user.profile_image_url_user,
        width: width,
      ),
    );
  }
}

/// 카드 배경만 보여주는 작은 그림. 높이는 카드 종횡비로 계산해서
/// 어떤 폭에서도 배경이 잘리지 않게 한다(목업도 같은 비율).
class _CardBackgroundThumb extends StatelessWidget {
  final String asset;
  final double width;

  const _CardBackgroundThumb({required this.asset, required this.width});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Image.asset(
        asset,
        width: width,
        height: width / kRidingCardAspectRatio,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// 카드 배경 썸네일 40×64. 선택되면 **바깥에 파란 2px 테두리**가 붙는다.
/// 테두리와 썸네일 사이는 [_kSelectRingGap]만큼 띄우고 모서리도 둥글린다
/// (목업은 각진 사각형에 여백 0이었는데 붙어 보여서 조정 — 사용자 확정).
/// 선택 여부와 무관하게 자리를 차지해야 고를 때마다 줄이 흔들리지 않으므로
/// 테두리 칸은 늘 그린다(선택 전에는 투명).
class _CardThumb extends StatelessWidget {
  /// 테두리 ↔ 썸네일 여백.
  static const double _kSelectRingGap = 3;
  static const double _kSelectRingWidth = 3;
  static const double _kSelectRingRadius = 6;

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
          padding: const EdgeInsets.all(_kSelectRingGap),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kSelectRingRadius),
            border: Border.all(
              color: isSelected ? SDSColor.snowliveBlue : Colors.transparent,
              width: _kSelectRingWidth,
            ),
          ),
          child: _CardBackgroundThumb(asset: asset, width: kCardShareThumbSize),
        ),
      ),
    );
  }
}
