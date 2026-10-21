import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/core/model/m_seasonRidingCard.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_riding_card_web.dart';
import 'package:com.snowlive/web/view/ranking/riding_card_sections_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_season_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_actions_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 데일리 카드 상세(목업) — 큰 카드 + `✕` / `⇄`(스킨 변경) / `이미지 저장`.
///
/// 스킨은 앱과 같이 카드별로 기억한다(코어 뷰모델이 SharedPreferences에 저장) →
/// 여기서는 토글만 호출하고 값은 [cardTypeOf]로 다시 읽는다.
Future<void> showRidingCardDetail(
  BuildContext context, {
  required DailyRidingCard card,
  String? displayName,
  String? profileImageUrl,
  required int Function() cardTypeOf,
  required Future<void> Function() onSwapCardType,
}) {
  return showWebOverlayModal<void>(
    context: context,
    // 목업은 딤이 gray900 90%다(공통 기본값 검정 50%보다 어둡다) — 카드만 남기고
    // 뒤를 지우는 화면이라 그대로 따른다.
    barrierColor: SDSColor.gray900.withValues(alpha: 0.9),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    builder: (_, close) => _RidingCardDetail(
      card: card,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      cardTypeOf: cardTypeOf,
      onSwapCardType: onSwapCardType,
      onClose: close,
    ),
  );
}

/// 시즌 카드 상세 — 카드를 누르면 크게 본다(앱 `SeasonCardDetailDialog`와 같은 경로).
///
/// 데일리와 **틀은 같고 카드 교체(`⇄`)만 없다** — 시즌 카드는 스킨이 하나다.
/// 대신 그 자리에 공유를 둔다(앱 시즌 다이얼로그도 닫기·공유·저장만 있다).
Future<void> showSeasonRidingCardDetail(
  BuildContext context, {
  required SeasonRidingCard card,
  required String seasonLabel,
  required String dbSeason,
  String? displayName,
  String? profileImageUrl,
}) {
  return showWebOverlayModal<void>(
    context: context,
    barrierColor: SDSColor.gray900.withValues(alpha: 0.9),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    builder: (_, close) => _SeasonCardDetail(
      card: card,
      seasonLabel: seasonLabel,
      dbSeason: dbSeason,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      onClose: close,
    ),
  );
}

class _SeasonCardDetail extends StatefulWidget {
  final SeasonRidingCard card;
  final String seasonLabel;
  final String dbSeason;
  final String? displayName;
  final String? profileImageUrl;
  final void Function([void result]) onClose;

  const _SeasonCardDetail({
    required this.card,
    required this.seasonLabel,
    required this.dbSeason,
    required this.displayName,
    required this.profileImageUrl,
    required this.onClose,
  });

  @override
  State<_SeasonCardDetail> createState() => _SeasonCardDetailState();
}

class _SeasonCardDetailState extends State<_SeasonCardDetail> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSaving = false;

  void _toast(String message) => showWebToast(
        context,
        message,
        alignment: context.screenType == WebScreenType.mobile
            ? Alignment.bottomCenter
            : Alignment.topCenter,
      );

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await saveRidingCardWithFeedback(
      context,
      boundaryKey: _boundaryKey,
      filename: ridingCardSeasonFileName(widget.dbSeason),
      toast: _toast,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
  }

  Future<void> _share() async {
    final ok = await shareRidingCardPng(
      boundaryKey: _boundaryKey,
      filename: ridingCardSeasonFileName(widget.dbSeason),
    );
    if (!mounted || ok) return;
    _toast('이 브라우저에서는 공유를 지원하지 않아요. 이미지 저장을 이용해 주세요.');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _boundaryKey,
              child: RidingCardSeasonWeb(
                card: widget.card,
                seasonLabel: widget.seasonLabel,
                displayName: widget.displayName,
                profileImageUrl: widget.profileImageUrl,
                width: _detailCardWidth(context),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundButton(icon: Icons.close, onTap: () => widget.onClose()),
                const SizedBox(width: SDSSpacing.lg),
                _RoundButton(
                  asset: 'assets/imgs/icons/icon_summury_share.svg',
                  onTap: _share,
                ),
              ],
            ),
            const SizedBox(height: 30),
            _SaveButton(
              label: _isSaving ? '저장 중…' : '이미지 저장',
              onTap: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

/// 상세로 띄우는 카드 폭. **모바일 목업(65:44774)도 PC(65:37552)와 같은 320**이다.
/// 375보다 좁은 기기에서만 좌우 여백(24씩)을 빼고 줄인다.
double _detailCardWidth(BuildContext context) {
  final available = MediaQuery.sizeOf(context).width - 48;
  return available < 320 ? available : 320;
}

class _RidingCardDetail extends StatefulWidget {
  final DailyRidingCard card;
  final String? displayName;
  final String? profileImageUrl;
  final int Function() cardTypeOf;
  final Future<void> Function() onSwapCardType;
  final void Function([void result]) onClose;

  const _RidingCardDetail({
    required this.card,
    required this.displayName,
    required this.profileImageUrl,
    required this.cardTypeOf,
    required this.onSwapCardType,
    required this.onClose,
  });

  @override
  State<_RidingCardDetail> createState() => _RidingCardDetailState();
}

class _RidingCardDetailState extends State<_RidingCardDetail> {
  final GlobalKey _boundaryKey = GlobalKey();

  late int _cardType = widget.cardTypeOf();
  bool _isSaving = false;

  Future<void> _swap() async {
    await widget.onSwapCardType();
    if (!mounted) return;
    setState(() => _cardType = widget.cardTypeOf());
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await saveRidingCardWithFeedback(
      context,
      boundaryKey: _boundaryKey,
      filename: ridingCardFileName(widget.card.date),
      toast: (message) => showWebToast(
        context,
        message,
        alignment: context.screenType == WebScreenType.mobile
            ? Alignment.bottomCenter
            : Alignment.topCenter,
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final width = _detailCardWidth(context);

    // ⚠️ Overlay 직삽이라 Dialog가 주던 `Material` 조상이 없다. 그러면 카드 안 텍스트가
    // Material 밖 텍스트 표시(노란 이중 밑줄)를 물려받는다(실측) → 투명 Material로 감싼다.
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _boundaryKey,
              child: LiveTalkRidingCardWeb(
                card: widget.card,
                cardType: _cardType,
                displayName: widget.displayName,
                profileImageUrl: widget.profileImageUrl,
                width: width,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundButton(icon: Icons.close, onTap: () => widget.onClose()),
                const SizedBox(width: SDSSpacing.lg),
                // 카드 스킨을 바꾼다(앱의 카드 타입 토글과 같다) — 아이콘도 앱과 같은 에셋.
                _RoundButton(
                  asset: 'assets/imgs/icons/icon_summury_change.svg',
                  onTap: _swap,
                ),
              ],
            ),
            const SizedBox(height: 30),
            _SaveButton(
              label: _isSaving ? '저장 중…' : '이미지 저장',
              onTap: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  /// 닫기는 앱도 머티리얼 아이콘을 쓴다(`Icons.close`). 카드 교체만 에셋이다.
  final IconData? icon;
  final String? asset;
  final VoidCallback onTap;

  const _RoundButton({this.icon, this.asset, required this.onTap})
      : assert(icon != null || asset != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        // 목업 56 원 · 아이콘 32.
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 32, color: SDSColor.gray900)
                : SvgPicture.asset(
                    asset!,
                    width: 32,
                    height: 32,
                    colorFilter: const ColorFilter.mode(SDSColor.gray900, BlendMode.srcIn),
                  ),
          ),
        ),
      ),
    );
  }
}

/// 상세 팝업의 파란 저장 버튼(목업 65:37552 — 170x56 · 완전히 둥근 모서리).
class _SaveButton extends StatelessWidget {
  final String label;

  /// null이면 저장 중 — 눌리지 않는다.
  final VoidCallback? onTap;

  const _SaveButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: SDSColor.snowliveBlue,
          disabledBackgroundColor: SDSColor.blue200,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // 웹 기본 visualDensity가 높이를 깎는다 — 56을 지키려면 함께 준다.
          visualDensity: VisualDensity.standard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(55)),
        ),
        child: Text(
          label,
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite),
        ),
      ),
    );
  }
}
