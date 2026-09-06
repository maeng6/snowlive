import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';

/// 라이브톡의 단계형 모달 셸. `라이브톡 올리기`와 `라이딩 카드 공유`가 공유한다.
///
/// 목업의 폭별 차이를 이 위젯이 흡수한다:
/// - 데스크탑·태블릿 = 중앙 카드 + `‹`/`›`/`✓` 원형 버튼이 **카드 바깥 아래**
/// - 모바일 = 하단 시트 + `이전`/`업로드`(또는 `다음`)가 **시트 헤더 좌·우**
class LiveTalkStepModal extends StatelessWidget {
  final String title;

  /// 제목 아래 회색 안내 문구. 없으면 그리지 않는다.
  final String? subtitle;

  final Widget body;

  /// 뒤로. null이면 첫 단계라 뒤로 갈 곳이 없다.
  final VoidCallback? onBack;

  /// 다음/업로드. null이면 **비활성 상태로 보인다**(목업: 사진 미선택 시 회색 `›`).
  /// 버튼 자체를 없애려면 [showNext]를 false로 둔다.
  final VoidCallback? onNext;

  /// 진행 버튼을 그릴지. 기록 없음 안내처럼 다음 단계가 아예 없는 화면만 false다.
  final bool showNext;

  /// 모바일 헤더의 진행 버튼 문구(`다음` 또는 `업로드`).
  final String nextLabel;

  /// 마지막 단계면 `›` 대신 `✓`를 그린다.
  final bool isFinalStep;

  final VoidCallback onClose;

  const LiveTalkStepModal({
    super.key,
    required this.title,
    required this.body,
    required this.onClose,
    this.subtitle,
    this.onBack,
    this.onNext,
    this.showNext = true,
    this.nextLabel = '다음',
    this.isFinalStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return context.screenType == WebScreenType.mobile
        ? _buildMobileSheet(context)
        : _buildCenteredCard(context);
  }

  /// 데스크탑·태블릿: 중앙 카드 + 아래 원형 버튼.
  Widget _buildCenteredCard(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Material(
            // Overlay 직삽이라 Material 조상이 없다 → 카드 표면을 Material로.
            color: SDSColor.snowliveWhite,
            borderRadius: BorderRadius.circular(4),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // 제목을 정확히 가운데 두기 위해 왼쪽에 X와 같은 크기의 자리를 비운다.
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: SDSTextStyle.bold
                                .copyWith(fontSize: 16, color: SDSColor.gray900),
                          ),
                        ),
                        _CloseX(onTap: onClose),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: SDSTextStyle.regular
                            .copyWith(fontSize: 13, color: SDSColor.gray500, height: 1.45),
                      ),
                    ],
                    const SizedBox(height: SDSSpacing.lg),
                    body,
                  ],
                ),
              ),
            ),
          ),
        ),
        // 목업: 카드 바깥 아래에 원형 버튼이 뜬다.
        if (onBack != null || showNext) ...[
          const SizedBox(height: SDSSpacing.md),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onBack != null) ...[
                _RoundButton(
                  icon: Icons.chevron_left,
                  onTap: onBack,
                  isPrimary: false,
                ),
                const SizedBox(width: SDSSpacing.md),
              ],
              // onNext가 null이어도 그린다 — 회색 비활성으로 보이는 게 목업이다.
              if (showNext)
                _RoundButton(
                  icon: isFinalStep ? Icons.check : Icons.chevron_right,
                  onTap: onNext,
                  isPrimary: true,
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// 모바일: 하단 시트 + 헤더 좌우 버튼.
  Widget _buildMobileSheet(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(SDSSpacing.md, SDSSpacing.md, SDSSpacing.md, SDSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: onBack == null
                        ? const SizedBox.shrink()
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: _OutlinedPill(label: '이전', onTap: onBack),
                          ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    child: !showNext
                        ? const SizedBox.shrink()
                        : Align(
                            alignment: Alignment.centerRight,
                            child: _FilledPill(label: nextLabel, onTap: onNext),
                          ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.regular
                      .copyWith(fontSize: 13, color: SDSColor.gray500, height: 1.45),
                ),
              ],
              const SizedBox(height: SDSSpacing.lg),
              Flexible(child: SingleChildScrollView(child: body)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseX extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseX({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Icon(Icons.close, size: 24, color: SDSColor.gray700),
    );
  }
}

/// 카드 아래에 떠 있는 원형 버튼. 진행 버튼은 파랑, 뒤로는 흰색이다(목업).
class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _RoundButton({required this.icon, required this.onTap, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final background = isPrimary
        ? (enabled ? SDSColor.snowliveBlue : SDSColor.gray200)
        : SDSColor.snowliveWhite;
    final iconColor = isPrimary
        ? (enabled ? SDSColor.snowliveWhite : SDSColor.gray400)
        : SDSColor.gray900;

    return Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 24, color: iconColor),
        ),
      ),
    );
  }
}

/// 모바일 시트 헤더의 `이전`(테두리) 버튼.
class _OutlinedPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _OutlinedPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: SDSColor.gray200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
    );
  }
}

/// 모바일 시트 헤더의 `다음`/`업로드`(파란 채움) 버튼.
class _FilledPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _FilledPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        disabledBackgroundColor: SDSColor.gray200,
        elevation: 0,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(
          fontSize: 14,
          color: onTap == null ? SDSColor.gray400 : SDSColor.snowliveWhite,
        ),
      ),
    );
  }
}

/// 두 플로우가 공유하는 `글 작성하기` 입력 영역.
class LiveTalkComposeField extends StatelessWidget {
  final TextEditingController controller;

  const LiveTalkComposeField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('글 작성하기', style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
        const SizedBox(height: SDSSpacing.sm),
        SizedBox(
          height: 160,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            maxLength: 1000,
            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
            decoration: InputDecoration(
              hintText: '라이브톡 글을 남겨주세요.',
              hintStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
              counterText: '',
              filled: true,
              fillColor: SDSColor.gray50,
              contentPadding: const EdgeInsets.all(SDSSpacing.md),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
