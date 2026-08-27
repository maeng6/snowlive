import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_riding_card_web.dart';
import 'package:com.snowlive/web/view/ranking/riding_card_sections_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ridingcard_actions_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';

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
    final ok = await saveRidingCardPng(
      boundaryKey: _boundaryKey,
      filename: ridingCardFileName(widget.card.date),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    showWebToast(
      context,
      ok ? '이미지를 저장했어요.' : '이미지 저장에 실패했어요.',
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 좁은 화면에서는 폭에 맞춰 줄인다(카드 비율은 유지된다).
    final width = context.screenType == WebScreenType.mobile ? 300.0 : 320.0;

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
            const SizedBox(height: SDSSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundButton(icon: Icons.close, onTap: () => widget.onClose()),
                const SizedBox(width: SDSSpacing.md),
                // 카드 스킨을 바꾼다(앱의 카드 타입 토글과 같다).
                _RoundButton(icon: Icons.swap_horiz, onTap: _swap),
              ],
            ),
            const SizedBox(height: SDSSpacing.lg),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SDSColor.snowliveBlue,
                  disabledBackgroundColor: SDSColor.blue200,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                child: Text(
                  _isSaving ? '저장 중…' : '이미지 저장',
                  style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 22, color: SDSColor.gray900),
        ),
      ),
    );
  }
}
