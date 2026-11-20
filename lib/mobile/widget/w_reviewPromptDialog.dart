import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:com.snowlive/core/api/api_review.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';

/// 인앱 평점/피드백(2단계). 라이딩 세션 저장 직후 호출한다.
///
/// 흐름:
///  1) 서버 eligibility 판정(가입14일↑ AND 세션3회↑, 쿨다운60일, 좋아요이력 영구제외)
///  2) prompt로 노출 1건 기록 → review_prompt_id
///  3) 1단계 "스라 쓰기 어떠세요?" → 좋아요!/아쉬워요
///     - 좋아요!  → OS 인앱리뷰 시트(iOS/Android) + respond(positive, store_review_prompted)
///     - 아쉬워요 → 피드백(객관식 1~4 + 기타 주관식) + respond(negative, category, text)
///     - 닫음     → respond(dismissed)
///
/// 라이딩 종료 플로우를 절대 막지 않도록 모든 단계는 조용히 실패한다(try/catch).

/// 아쉬워요 피드백 객관식 — 백엔드 ReviewPrompt.FEEDBACK_CHOICES와 코드 일치.
const List<MapEntry<String, String>> kReviewFeedbackOptions = [
  MapEntry('accuracy', '기록이 부정확해요 (속도·거리·궤적)'),
  MapEntry('stability', '앱이 느리거나 자꾸 멈춰요'),
  MapEntry('battery', '배터리가 너무 많이 닳아요'),
  MapEntry('feature', '원하는 기능이 없어요 / 쓰기 불편해요'),
  MapEntry('etc', '기타'),
];

/// 라이딩 세션 저장 직후 호출하는 진입점. eligibility 통과 시에만 다이얼로그를 띄운다.
Future<void> maybeShowReviewAfterSession({
  required int userId,
  String appVersion = '',
}) async {
  final api = ReviewAPI();
  try {
    final elig = await api.eligibility(userId);
    final eligible = (elig.data is Map) && (elig.data['eligible'] == true);
    if (!elig.success || !eligible) return;

    // 1건 기록 → review_prompt_id
    final created = await api.prompt({
      'user_id': userId,
      'platform': _platformCode(),
      'app_version': appVersion,
    });
    if (!created.success) return;
    final int? promptId = (created.data is Map) ? created.data['review_prompt_id'] as int? : null;
    if (promptId == null) return;

    // 1단계
    final String? stage1 = await _showStage1Dialog();

    if (stage1 == 'positive') {
      final prompted = await _requestStoreReview();
      await api.respond({
        'review_prompt_id': promptId,
        'response': 'positive',
        'store_review_prompted': prompted,
      });
    } else if (stage1 == 'negative') {
      final fb = await _showFeedbackDialog();
      await api.respond({
        'review_prompt_id': promptId,
        'response': 'negative',
        'feedback_category': fb?.category ?? '',
        'feedback_text': fb?.text ?? '',
      });
    } else {
      // 배경 탭/닫기 = 무응답
      await api.respond({'review_prompt_id': promptId, 'response': 'dismissed'});
    }
  } catch (_) {
    // 조용히 무시 — 라이딩 종료 흐름을 막지 않는다.
  }
}

String _platformCode() {
  if (kIsWeb) return 'web';
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  return '';
}

/// OS 인앱리뷰 시트 호출. 시트를 띄웠으면 true(= store_review_prompted).
/// ⚠️ 실제 제출 여부·별점은 OS가 알려주지 않는다.
Future<bool> _requestStoreReview() async {
  if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) return false;
  try {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      return true;
    }
  } catch (_) {}
  return false;
}

/// 1단계. 'positive' | 'negative' | null(닫음).
Future<String?> _showStage1Dialog() {
  return Get.dialog<String>(
    AlertDialog(
      backgroundColor: SDSColor.snowliveWhite,
      contentPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 28),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('스라 쓰기 어떠세요? 😊',
              textAlign: TextAlign.center,
              style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900)),
          const SizedBox(height: 10),
          Text('짧은 한 마디가 스라를 더 좋게 만들어요.',
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular.copyWith(fontSize: 14, height: 1.45, color: SDSColor.gray600)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(result: 'negative'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.gray200,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('아쉬워요',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(result: 'positive'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.snowliveBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('좋아요!',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
  );
}

/// 아쉬워요 피드백 결과.
class ReviewFeedback {
  final String category;
  final String text;
  const ReviewFeedback(this.category, this.text);
}

Future<ReviewFeedback?> _showFeedbackDialog() {
  return Get.dialog<ReviewFeedback>(
    const _ReviewFeedbackDialog(),
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
  );
}

class _ReviewFeedbackDialog extends StatefulWidget {
  const _ReviewFeedbackDialog();

  @override
  State<_ReviewFeedbackDialog> createState() => _ReviewFeedbackDialogState();
}

class _ReviewFeedbackDialogState extends State<_ReviewFeedbackDialog> {
  String? _selected; // 선택된 카테고리 코드
  final TextEditingController _etcController = TextEditingController();

  bool get _isEtc => _selected == 'etc';
  bool get _canSubmit =>
      _selected != null && (!_isEtc || _etcController.text.trim().isNotEmpty);

  @override
  void dispose() {
    _etcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SDSColor.snowliveWhite,
      contentPadding: const EdgeInsets.only(bottom: 20, left: 22, right: 22, top: 26),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('어떤 점이 아쉬우셨어요?',
                textAlign: TextAlign.center,
                style: SDSTextStyle.bold.copyWith(fontSize: 18, height: 1.4, color: SDSColor.gray900)),
            const SizedBox(height: 6),
            Text('가장 가까운 것을 하나 골라주세요.',
                textAlign: TextAlign.center,
                style: SDSTextStyle.regular.copyWith(fontSize: 13, height: 1.4, color: SDSColor.gray600)),
            const SizedBox(height: 18),
            ...kReviewFeedbackOptions.map(_optionTile),
            if (_isEtc) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _etcController,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                decoration: InputDecoration(
                  hintText: '자세한 의견을 들려주세요.',
                  hintStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
                  counterText: '',
                  filled: true,
                  fillColor: SDSColor.gray50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.gray200,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('닫기',
                        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canSubmit
                        ? () => Get.back(
                            result: ReviewFeedback(_selected!, _etcController.text.trim()))
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
                      disabledBackgroundColor: SDSColor.blue100,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('보내기',
                        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(MapEntry<String, String> opt) {
    final selected = _selected == opt.key;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _selected = opt.key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? SDSColor.blue50 : SDSColor.gray50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? SDSColor.snowliveBlue : SDSColor.gray50, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 18, color: selected ? SDSColor.snowliveBlue : SDSColor.gray400),
              const SizedBox(width: 10),
              Expanded(
                child: Text(opt.value,
                    style: SDSTextStyle.regular.copyWith(
                        fontSize: 14,
                        height: 1.35,
                        color: selected ? SDSColor.gray900 : SDSColor.gray700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
