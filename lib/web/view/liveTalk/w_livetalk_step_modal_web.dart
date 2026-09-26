import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:flutter/material.dart';

/// 중앙 카드 폭(피그마 80:217253 / 80:219456).
const double kLiveTalkModalWidth = 390;

/// 중앙 카드 높이(PC). **사진 선택 단계와 글 작성 단계가 같은 값**이라 단계를
/// 넘겨도 카드가 커졌다 작아지지 않는다. [LiveTalkStepModal.minHeight]로 넘겨서 쓴다.
const double kLiveTalkModalHeight = 478;

/// 중앙 카드 높이(태블릿, 피그마 80:228872). PC보다 7 낮다 — 사진 칸 아래
/// 여백 배분이 달라서다(사진↔버튼 50, 버튼↔하단 25).
const double kLiveTalkModalHeightTablet = 471;

/// 하단 시트 높이(모바일). 목업은 1단계 449 / 2단계 455로 6 차이가 나는데,
/// 단계를 넘길 때 시트가 들썩이지 않게 **큰 쪽으로 통일**한다(사용자 확정).
/// 남는 6은 1단계 버튼 아래 여백으로 들어간다.
const double kLiveTalkSheetHeightMobile = 455;

/// 카드 좌우 여백. 1단계의 고정폭 요소(사진 칸 240·버튼 208)는 이 안에서
/// 가운데 정렬한다.
const double kLiveTalkModalPaddingH = 20;

/// 타이틀 ↔ 안내 문구 간격. 목업은 6이었는데 붙여 보이게 좁혔다(사용자 확정).
const double _kTitleSubtitleGap = 2;

/// 좁히기 전 목업값. 줄인 만큼 안내↔본문 간격에 되돌려서 카드 높이를 유지한다.
const double _kTitleSubtitleGapBase = 6;

/// 하단 시트의 그랩 핸들(목업 80:252210). 헤더 버튼이 없는 화면에만 뜬다.
const double _kSheetHandleWidth = 36;
const double _kSheetHandleHeight = 4;

/// 하단 시트의 타이틀 ↔ 안내 간격(목업 10). 중앙 카드와 값이 다르다.
const double _kSheetTitleSubtitleGap = 10;

/// 원형 버튼 안 `‹`·`›` 크기.
const double _kChevronSize = 30;

/// 원형 버튼 안 `✓` 크기. 같은 픽셀이면 체크가 화살표보다 훨씬 커 보여서 줄인다.
const double _kCheckSize = 24;

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

  /// 중앙 카드의 최소 높이. 단계마다 내용 길이가 달라도 카드 크기를 붙잡아두고
  /// 싶을 때 [kLiveTalkModalHeight]를 넘긴다. null이면 내용만큼만 커진다.
  final double? minHeight;

  /// 모바일 시트에서 [body]에 두르는 좌우 여백. 라이브톡 올리기처럼 요소마다
  /// 여백이 다른 화면은 `EdgeInsets.zero`를 넘기고 본문이 직접 든다.
  final EdgeInsets mobileBodyPadding;

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
    this.minHeight,
    this.mobileBodyPadding = const EdgeInsets.symmetric(horizontal: SDSSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return context.screenType == WebScreenType.mobile
        ? _buildMobileSheet(context)
        : _buildCenteredCard(context);
  }

  /// 데스크탑·태블릿: 중앙 카드 + 아래 원형 버튼.
  ///
  /// 세로 배치는 목업 실측값을 그대로 쓴다 — 카드 상단에서 타이틀 42,
  /// 타이틀↔안내 6, 안내↔본문 24. 본문 아래 여백은 단계마다 달라서(1단계 40 /
  /// 2단계 30) [body]가 직접 들고 있다.
  Widget _buildCenteredCard(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SizedBox(
            width: kLiveTalkModalWidth,
            child: Material(
              // Overlay 직삽이라 Material 조상이 없다 → 카드 표면을 Material로.
              color: SDSColor.snowliveWhite,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              // 화면 높이가 카드보다 낮을 때만 스크롤된다.
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight ?? 0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: kLiveTalkModalPaddingH),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 42),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: SDSTextStyle.bold.copyWith(
                                fontSize: 16,
                                color: SDSColor.gray900,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: _kTitleSubtitleGap),
                              Text(
                                subtitle!,
                                textAlign: TextAlign.center,
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 14,
                                  color: SDSColor.gray500,
                                  height: 1.45,
                                ),
                              ),
                            ],
                            // 타이틀↔안내를 좁힌 만큼 여기서 되돌려준다 — 본문이
                            // 늘 같은 자리(카드 상단 108)에서 시작해야 카드 높이가
                            // 안 변한다.
                            SizedBox(
                              height: subtitle == null
                                  ? SDSSpacing.lg
                                  : SDSSpacing.lg + (_kTitleSubtitleGapBase - _kTitleSubtitleGap),
                            ),
                            body,
                          ],
                        ),
                      ),
                      // ✕는 타이틀 줄이 아니라 **카드 우상단**에 붙는다(목업 16/16).
                      // 히트 여백 8을 빼고 8/8에 놓아야 아이콘이 16/16에 온다.
                      Positioned(top: 8, right: 8, child: _CloseX(onTap: onClose)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // 목업: 카드 바깥 아래 24에 원형 버튼이 뜬다.
        if (onBack != null || showNext) ...[
          const SizedBox(height: SDSSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onBack != null) ...[
                _RoundButton(
                  icon: Icons.chevron_left,
                  onTap: onBack,
                  isPrimary: false,
                  iconSize: _kChevronSize,
                ),
                // 버튼 사이 17(목업 실측).
                const SizedBox(width: 17),
              ],
              // onNext가 null이어도 그린다 — 화살표만 흐려지는 게 목업이다.
              if (showNext)
                _RoundButton(
                  icon: isFinalStep ? Icons.check : Icons.chevron_right,
                  onTap: onNext,
                  // 파랑은 **마지막 단계의 ✓만** — `›`는 단계 이동이라 흰 원이다.
                  isPrimary: isFinalStep,
                  iconSize: isFinalStep ? _kCheckSize : _kChevronSize,
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// 모바일: 하단 시트 + 헤더 좌우 알약 버튼 (피그마 80:249711 / 80:253768).
  ///
  /// ⚠️ 좌우 여백을 시트가 일괄로 주지 않는다 — 목업이 요소마다 다르다
  /// (버튼 줄 20 / 글 작성 블록 16 / 안내 문구 20). [body]가 자기 여백을 든다.
  /// 안내 문구도 시트가 그리지 않는다 — 1단계는 **사진 칸 아래**에 오고
  /// 2단계엔 아예 없어서, 위치를 body가 정해야 한다.
  Widget _buildMobileSheet(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          // 단계마다 내용 길이가 달라도 시트가 들썩이지 않게 높이를 붙잡는다.
          constraints: BoxConstraints(minHeight: minHeight ?? 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onBack == null && !showNext) ...[
                // 헤더 버튼이 하나도 없는 화면(기록 없음)은 알약 줄 대신 **그랩
                // 핸들**이 뜨고 타이틀이 그만큼 내려온다(목업 80:252210).
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: _kSheetHandleWidth,
                    height: _kSheetHandleHeight,
                    decoration: BoxDecoration(
                      color: SDSColor.gray200,
                      borderRadius: BorderRadius.circular(_kSheetHandleHeight / 2),
                    ),
                  ),
                ),
                // 핸들 아래 24 — 타이틀이 시트 상단 40에 온다.
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.md),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                  ),
                ),
              ] else
                Padding(
                  // 시트 상단 20, 헤더 버튼은 좌우 16.
                  padding: const EdgeInsets.fromLTRB(SDSSpacing.md, 20, SDSSpacing.md, 0),
                  child: SizedBox(
                    height: kLiveTalkPillHeight,
                    // 타이틀은 버튼 폭과 무관하게 **시트 폭 정중앙**이라 Row가 아닌
                    // Stack으로 얹는다(`이전` 51 / `업로드` 63으로 폭이 다르다).
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 16,
                              color: SDSColor.gray900,
                            ),
                          ),
                        ),
                        if (onBack != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _OutlinedPill(label: '이전', onTap: onBack),
                          ),
                        if (showNext)
                          Align(
                            alignment: Alignment.centerRight,
                            // 파란 채움은 **마지막 단계(`업로드`)만** — `다음`은 단계
                            // 이동이라 `이전`과 같은 테두리 알약이다(목업 80:249732).
                            // PC·태블릿에서 파랑을 `✓`에만 쓰는 규칙과 같다.
                            child: isFinalStep
                                ? _FilledPill(label: nextLabel, onTap: onNext)
                                : _OutlinedPill(label: nextLabel, onTap: onNext),
                          ),
                      ],
                    ),
                  ),
                ),
              // 안내 문구는 화면이 넘겨줄 때만 그린다 — 라이브톡 올리기는 위치가
              // 달라서 직접 그리고 여기엔 null을 넘긴다(라이딩 카드 공유는 그대로).
              if (subtitle != null) ...[
                // 모바일 안내 간격은 10(목업 80:252210) — 중앙 카드(2)와 다르다.
                const SizedBox(height: _kSheetTitleSubtitleGap),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.md),
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 14,
                      color: SDSColor.gray500,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
              // 헤더 줄 ↔ 본문 15 (두 단계 공통 — 본문은 늘 시트 상단 71에서 시작).
              const SizedBox(height: 15),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(padding: mobileBodyPadding, child: body),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카드 우상단 닫기. 목업은 26 아이콘에 불투명도 50%다.
class _CloseX extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseX({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return WebIconButton(
      onTap: onTap,
      padding: const EdgeInsets.all(8),
      icon: Icon(Icons.close, size: 26, color: SDSColor.gray900.withValues(alpha: 0.5)),
    );
  }
}

/// 카드 아래에 떠 있는 원형 버튼(48).
///
/// 목업 규칙: `‹`·`›`는 **흰 원 + 검정 아이콘**, 마지막 단계의 `✓`만 파란 원이다.
/// 비활성일 때도 원은 흰색 그대로 두고 **아이콘만 10%로 흐려진다** — 원까지
/// 회색으로 바꾸면 카드 아래에서 버튼이 통째로 사라진 것처럼 보인다.
class _RoundButton extends StatelessWidget {
  /// 원 지름(목업). 아이콘 크기가 달라져도 원은 이 값으로 고정된다.
  static const double _diameter = 48;

  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  /// 아이콘 크기. 같은 픽셀이어도 `✓`가 `›`보다 훨씬 커 보여서 따로 준다.
  final double iconSize;

  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final background = isPrimary
        ? (enabled ? SDSColor.snowliveBlue : SDSColor.gray200)
        : SDSColor.snowliveWhite;
    final iconColor = isPrimary
        ? (enabled ? SDSColor.snowliveWhite : SDSColor.gray400)
        : SDSColor.gray900.withValues(alpha: enabled ? 1 : 0.1);

    return Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          // 아이콘이 몇이든 여백으로 메워 원을 48로 맞춘다.
          padding: EdgeInsets.all((_diameter - iconSize) / 2),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}

/// 모바일 시트 헤더 알약 버튼 규격(목업 80:253785 / 80:253788).
/// 높이 36 = 상하 10 + 글자 줄 16. 라운드 20, 좌 14 / 우 12.
const double kLiveTalkPillHeight = 36;

/// 목업은 좌 14 / 우 12지만 그대로 두면 글자가 1px 오른쪽으로 쏠린다.
/// 좌우 합(26)은 그대로라 버튼 폭은 목업과 같다.
const EdgeInsets _kPillPadding = EdgeInsets.symmetric(horizontal: 13, vertical: 10);
const double _kPillRadius = 20;

/// 알약 글자 — bold 14, 줄 높이 16(목업). 높이 36을 맞추려면 줄 높이가 고정이어야 한다.
TextStyle _pillTextStyle(Color color) =>
    SDSTextStyle.bold.copyWith(fontSize: 14, height: 16 / 14, color: color);

/// 모바일 시트 헤더의 `이전`·`다음`(테두리) 버튼. 배경 없이 gray100 테두리만(목업).
/// 비활성이면 테두리는 그대로 두고 글자만 흐려진다 — 채움 알약의 비활성 글자색과
/// 같은 gray400(카드 아래 `›`가 원은 두고 화살표만 흐려지는 것과 같은 규칙).
class _OutlinedPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _OutlinedPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // ⚠️ 높이를 겉에서 못 박는다 — 웹 기본 visualDensity(compact)가 버튼
      // 높이를 8 깎아서 패딩만으로는 36이 안 나온다(공통 버튼도 같은 이유로
      // SizedBox(48)로 감싼다).
      height: kLiveTalkPillHeight,
      child: OutlinedButton(
        onPressed: onTap,
        style:
            OutlinedButton.styleFrom(
              side: BorderSide(color: SDSColor.gray100),
              padding: _kPillPadding,
              minimumSize: Size.zero,
              visualDensity: VisualDensity.standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kPillRadius)),
            ).copyWith(
              // styleFrom의 side는 비활성에서도 유지되지만, 눌리지 않을 때
              // Material이 글자색을 자기 값으로 덮으므로 여기서 고정한다.
              side: WidgetStatePropertyAll(BorderSide(color: SDSColor.gray100)),
            ),
        child: Text(
          label,
          style: _pillTextStyle(onTap == null ? SDSColor.gray400 : SDSColor.gray900),
        ),
      ),
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
    return SizedBox(
      // 테두리 알약과 같은 이유로 높이를 겉에서 못 박는다.
      height: kLiveTalkPillHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: SDSColor.snowliveBlue,
          disabledBackgroundColor: SDSColor.gray200,
          elevation: 0,
          shadowColor: Colors.transparent,
          overlayColor: Colors.transparent,
          padding: _kPillPadding,
          minimumSize: Size.zero,
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kPillRadius)),
        ),
        child: Text(
          label,
          style: _pillTextStyle(onTap == null ? SDSColor.gray400 : SDSColor.snowliveWhite),
        ),
      ),
    );
  }
}

/// 두 플로우가 공유하는 `글 작성하기` 입력 영역(피그마 80:219847).
/// 라벨 bold 14 ↔ 12 ↔ 입력 칸 181(내부 여백 16).
class LiveTalkComposeField extends StatefulWidget {
  final TextEditingController controller;

  /// 입력칸 높이. PC·태블릿 181 / 모바일 195(목업).
  final double height;

  const LiveTalkComposeField({super.key, required this.controller, this.height = 181});

  @override
  State<LiveTalkComposeField> createState() => _LiveTalkComposeFieldState();
}

class _LiveTalkComposeFieldState extends State<LiveTalkComposeField> {
  /// 글이 길어지면 입력칸 안에서 스크롤된다. 스크롤바를 **칸 오른쪽 끝**에
  /// 붙이려면(페이지 스크롤바와 같은 규칙) 내부 스크롤을 직접 잡아 Scrollbar에
  /// 물려야 한다 — 여백은 스크롤 영역 안쪽(contentPadding)에 남는다.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⚠️ line height를 목업값(17)으로 묶는다. 이 라벨은 2단계 본문에서
        // 유일하게 폰트 메트릭으로 높이가 정해지는 요소라, 풀어두면 Pretendard가
        // 19~20으로 잡아서 카드가 1단계보다 그만큼 높아진다.
        Text(
          '글 작성하기',
          style: SDSTextStyle.bold.copyWith(fontSize: 14, height: 17 / 14, color: SDSColor.gray900),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: widget.height,
          child: Scrollbar(
            controller: _scrollController,
            // ⚠️ TextField 안쪽 자동 스크롤바를 끈다 — 안 끄면 칸 가장자리(위
            // Scrollbar)와 여백 안쪽에 스크롤바가 두 줄로 보인다.
            child: ScrollConfiguration(
              behavior: const _NoScrollbarBehavior(),
              child: TextField(
                controller: widget.controller,
                scrollController: _scrollController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                maxLength: 1000,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 15,
                  color: SDSColor.gray900,
                  height: 22 / 15,
                ),
                cursorHeight: 16,
                decoration: InputDecoration(
                  hintText: '라이브톡 글을 남겨주세요.',
                  // 목업 #949494 = gray500.
                  hintStyle: SDSTextStyle.regular.copyWith(
                    fontSize: 15,
                    color: SDSColor.gray500,
                    height: 22 / 15,
                  ),
                  counterText: '',
                  filled: true,
                  // 목업 #F6F6F6 ↔ 토큰 gray50(#F5F5F5) — 1 차이라 토큰을 쓴다.
                  fillColor: SDSColor.gray50,
                  contentPadding: const EdgeInsets.all(SDSSpacing.md),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 공통 버튼(comp_button)의 세 가지 변형.
/// - [primary] `촬영` — snowliveBlue + 흰 글씨
/// - [secondary] `앨범에서 선택` — sBlue500(#7C899D) + 흰 글씨. 목업의
///   comp_button Secondary 변형이라 회색 배경이 아니다.
/// - [quiet] PC `이미지 직접 선택하기` — gray50 + gray900. 이 버튼만 목업이
///   실제로 연회색이다.
/// 두 플로우(올리기·카드 공유)가 공유한다.
enum LiveTalkWideButtonKind { primary, secondary, quiet }

/// 공통 버튼 규격(comp_button) — 높이 48 / 라운드 5 / bold 16.
/// hover는 **배경에 검정을 섞어** 한 톤 어둡게 한다(채움 버튼은 투명도 대신
/// 배경을 쓴다). 농도는 4% — 박스형 팝업의 파란 버튼(10%)과 같은 값을 쓰면
/// 연회색 바탕에서는 대비가 커서 너무 어둡게 보인다.
class LiveTalkWideButton extends StatelessWidget {
  final String label;
  final LiveTalkWideButtonKind kind;
  final VoidCallback onTap;

  const LiveTalkWideButton({required this.label, required this.kind, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final background = switch (kind) {
      LiveTalkWideButtonKind.primary => SDSColor.snowliveBlue,
      LiveTalkWideButtonKind.secondary => SDSColor.sBlue500,
      LiveTalkWideButtonKind.quiet => SDSColor.gray50,
    };
    final foreground = kind == LiveTalkWideButtonKind.quiet
        ? SDSColor.gray900
        : SDSColor.snowliveWhite;
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style:
            ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              overlayColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.hovered)
                    ? Color.alphaBlend(Colors.black.withValues(alpha: 0.04), background)
                    : background,
              ),
            ),
        child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 16, color: foreground)),
      ),
    );
  }
}

/// 스크롤바를 **아예 만들지 않는** 스크롤 동작.
///
/// `ScrollConfiguration(...copyWith(scrollbars: false))`만으로는 TextField를 못 막는다 —
/// [EditableText]가 여러 줄일 때 조상 설정을 `scrollbars: _isMultiline`으로 **덮어쓰기**
/// 때문이다(editable_text.dart). 그래서 플래그 대신 [buildScrollbar]를 비워
/// 그 경로 자체를 막는다. TextField는 `scrollBehavior`를 넘길 통로가 없다.
class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}
