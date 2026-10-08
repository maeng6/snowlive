import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('###,###,###,###');

/// 크루홈 헤더 — 로고 + 크루명 + `소개 · 리조트` + 방문자 수 + 알림/설정.
class CrewHomeHeaderWeb extends StatelessWidget {
  final CrewDetailInfo info;

  /// 설정 톱니를 그릴지. 앱과 같이 **내 크루일 때만** 보여준다.
  final bool showSettings;

  /// 방문자수(오늘/전체). null이면 `-`로 표시(아직 집계 전).
  final int? visitorToday;
  final int? visitorTotal;

  const CrewHomeHeaderWeb({
    super.key,
    required this.info,
    this.showSettings = false,
    this.visitorToday,
    this.visitorTotal,
  });

  String _fmtVisitor(int? v) => v == null ? '-' : _numberFormat.format(v);

  @override
  Widget build(BuildContext context) {
    final logoUrl = crewLogoUrlOf(logoUrl: info.crewLogoUrl, color: info.color);
    final leader = info.crewLeaderDisplayName?.trim() ?? '';
    final resort = info.baseResortFullname?.trim().isNotEmpty ?? false
        ? info.baseResortFullname!
        : (info.baseResortNickname ?? '');
    // 크루명 아래 줄 = `크루장닉네임 · 스키장`(앱 v_crewHome.dart:267과 같은 구성).
    // 스키장명 왼쪽에 크루장 닉네임을 둔다.
    final subtitle = [if (leader.isNotEmpty) leader, if (resort.isNotEmpty) resort].join(' · ');

    // 로고 PC 64 / 태블릿 56 / 모바일 36 (목업 161:94357 · 161:102334).
    final double logoSize = switch (context.screenType) {
      WebScreenType.desktop => 64,
      WebScreenType.tablet => 56,
      WebScreenType.mobile => 36,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 크루 홈에서도 개인 프로필과 같이 로고를 누르면 확대해서 본다(앱과 동일).
        WebProfileTap(
          onTap: (logoUrl?.isNotEmpty ?? false)
              ? () => showWebPhotoViewer(context, url: logoUrl, title: info.crewName ?? '')
              : null,
          child: Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              // 라운드는 공용 비율(한 변의 0.2). 목업에는 크루색 테두리가 없지만
              // 선을 아예 빼면 흰 기본 마크가 흰 배경에 묻혀서 gray100으로 바꾼다
              // (크루 팝업·목록 행과 같은 처리).
              borderRadius: BorderRadius.circular(crewLogoRadius(logoSize)),
              border: Border.all(color: SDSColor.gray100),
            ),
            clipBehavior: Clip.antiAlias,
            child: (logoUrl?.isNotEmpty ?? false)
                ? WebNetworkImage(url: logoUrl, width: logoSize, height: logoSize)
                : Container(color: SDSColor.gray100),
          ),
        ),
        // 로고 ↔ 텍스트 12 (목업 161:87212).
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                info.crewName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // 크루명은 서브 페이지 타이틀 공통값(PC 30 / 태블릿 24 / 모바일 20).
                // 목업 PC가 30이라 공통값과 같다.
                style: SDSTextStyle.bold
                    .copyWith(fontSize: webSubPageTitleSize(context), color: SDSColor.gray900),
              ),
              if (subtitle.isNotEmpty) ...[
                // 이름 ↔ 부제 2 (목업 161:94376).
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                ),
              ],
            ],
          ),
        ),
        // 방문자수(게스트 포함, 유저/IP당 5분 스로틀). 서버 POST /crew/visit/{id}/ 집계.
        if (context.isDesktop) ...[
          const SizedBox(width: SDSSpacing.md),
          // 목업에는 없는 줄(실제 동작하는 집계)이라 유지하되, 좁아지면 **먼저 줄어든다**.
          // ⚠️ `Flexible`(loose)로 두면 **남는 폭을 다 쓰지 않아** 그만큼이 줄 끝에
          // 남고 아이콘이 우측선에서 안쪽으로 밀린다 → `Expanded` + 우측 정렬.
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
              '방문자 Today ${_fmtVisitor(visitorToday)}  |  Total ${_fmtVisitor(visitorTotal)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
                style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
              ),
            ),
          ),
        ],
        const SizedBox(width: SDSSpacing.md),
        _HeaderIconButton(
          // 앱과 같은 에셋(v_crewMain.dart:72) — 알림은 틴트 없이 그대로 쓴다.
          asset: 'assets/imgs/icons/icon_alarm_resortHome.png',
          // 크루 알림 화면은 목업이 없어 다음 작업이다.
          onTap: () => Get.snackbar('알림', '크루 알림은 준비 중이에요.'),
          // 설정이 없으면 이게 마지막 아이콘이다.
          flushRight: !showSettings,
        ),
        if (showSettings) ...[
          // 아이콘 **사이 12**(목업 — 묶음 64 = 26 + 12 + 26). 각 버튼이 히트 여백
          // 4씩을 갖고 있으므로 여기서는 4만 준다(4+4+4 = 12).
          const SizedBox(width: 4),
          _HeaderIconButton(
            // 앱과 같은 에셋(v_fleaMarketMain.dart:99) — 설정은 gray900으로 틴트한다.
            asset: 'assets/imgs/icons/icon_header_setting.png',
            tint: SDSColor.gray900,
            onTap: () => Get.toNamed('${WebRoutes.crewSetting}?id=${info.crewId}'),
            flushRight: true,
          ),
        ],
      ],
    );
  }
}

/// 헤더 우측 아이콘 — **앱과 같은 PNG 에셋**을 쓴다(Material 아이콘은 모양이 다르다).
/// hover는 웹 공통 아이콘 버튼(`WebIconButton`)과 같은 **불투명도 페이드**(1.0 → 0.6).
class _HeaderIconButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  /// 단색 아이콘만 틴트한다(설정). 알림은 에셋 색을 그대로 쓴다.
  final Color? tint;

  /// 마지막 아이콘은 **오른쪽 히트 여백을 빼서** 아이콘이 콘텐츠 우측선에 붙는다
  /// (뒤로가기가 좌측선에 붙는 것과 같은 처리).
  final bool flushRight;

  const _HeaderIconButton({
    required this.asset,
    required this.onTap,
    this.tint,
    this.flushRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return WebIconButton(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(4, 4, flushRight ? 0 : 4, 4),
      // 목업(161:87215)·앱 모두 26.
      icon: Image.asset(asset, width: 26, height: 26, color: tint),
    );
  }
}

/// 크루 소개글 블록 — 앱 크루홈(`v_crewHome.dart:301~`)처럼 통계 바 아래에 따로 둔다.
/// 한 줄을 넘으면 +/- 아이콘으로 펼치고 접는다(앱과 같은 에셋). 소개가 비면 아무것도
/// 그리지 않는다(상위에서 비었을 때 넣지 않으니 안전장치 겸용).
class CrewHomeDescriptionWeb extends StatefulWidget {
  final String? description;

  const CrewHomeDescriptionWeb({super.key, required this.description});

  @override
  State<CrewHomeDescriptionWeb> createState() => _CrewHomeDescriptionWebState();
}

class _CrewHomeDescriptionWebState extends State<CrewHomeDescriptionWeb> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.description?.trim() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    final textStyle = SDSTextStyle.regular
        .copyWith(fontSize: 14, height: 22 / 14, color: SDSColor.gray700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 상단 구분선(앱과 같은 위치) — 요약 바 구분선과 같은 gray700 10%.
        Container(height: 1, color: SDSColor.gray700.withValues(alpha: 0.1)),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            // 토글 아이콘(20) + 간격(8) 자리를 빼고 한 줄에 들어가는지 잰다(앱과 같은 방식).
            final painter = TextPainter(
              text: TextSpan(text: text, style: textStyle),
              maxLines: 1,
              // intl이 같은 이름의 TextDirection을 내보내 충돌하므로 컨텍스트에서 가져온다.
              textDirection: Directionality.of(context),
            )..layout(maxWidth: (constraints.maxWidth - 28).clamp(0, constraints.maxWidth));
            final overflowing = painter.didExceedMaxLines;

            return Row(
              crossAxisAlignment:
                  _expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: textStyle,
                    maxLines: _expanded ? null : 1,
                    overflow:
                        _expanded ? TextOverflow.clip : TextOverflow.ellipsis,
                  ),
                ),
                if (overflowing) ...[
                  const SizedBox(width: 8),
                  _CrewIntroToggle(
                    expanded: _expanded,
                    onTap: () => setState(() => _expanded = !_expanded),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 소개글 펼침/접힘 토글 — 앱과 같은 원형 +/- 에셋(20).
class _CrewIntroToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _CrewIntroToggle({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Image.asset(
            expanded
                ? 'assets/imgs/icons/icon_minus_round.png'
                : 'assets/imgs/icons/icon_plus_round.png',
            width: 20,
            height: 20,
          ),
        ),
      ),
    );
  }
}

/// 헤더 아래 요약 바 — `멤버(명) / 통합 랭킹 / 총 점수` (+ 내 크루가 아니면 가입 신청).
class CrewHomeSummaryBarWeb extends StatelessWidget {
  final int? memberCount;
  final int? overallRank;
  final double? totalScore;

  /// null이면 가입 신청 항목을 그리지 않는다(내 크루이거나 신청 불가).
  final VoidCallback? onApply;

  /// `멤버(명)` 칸을 누르면 전체 멤버 화면으로 보낸다.
  final VoidCallback? onMembersTap;

  const CrewHomeSummaryBarWeb({
    super.key,
    required this.memberCount,
    required this.overallRank,
    required this.totalScore,
    this.onApply,
    this.onMembersTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final stats = [
      _StatCell(
        label: '멤버(명)',
        value: _numberFormat.format(memberCount ?? 0),
        onTap: onMembersTap,
        stacked: isMobile,
      ),
      _StatCell(
        label: '통합 랭킹',
        value: _numberFormat.format(overallRank ?? 0),
        stacked: isMobile,
      ),
      _StatCell(
        label: '총 점수',
        value: _numberFormat.format((totalScore ?? 0).round()),
        stacked: isMobile,
      ),
    ];

    // 랭킹 `내 랭킹 카드`(w_ranking_my_card_web.dart)와 **같은 규격**으로 맞춘다
    // (사용자 확정) — gray50 · 라운드 16 · PC 패딩 30/7 ·
    // 라벨 Regular 14(검정 50%) · 값 Bold 17 · 구분선 1×16 gray700 10%, 좌우 24.
    // 크루홈 목업(161:86732)은 15/18/30/60이지만 같은 성격의 지표 바라 통일한다.
    //
    // 높이는 **54**로 못 박는다 — 랭킹 카드는 티어 아이콘(40)이 높이를 만들어
    // 7+40+7 = 54가 되는데, 여기는 아이콘이 없어 그냥 두면 40으로 얇아진다.
    return Container(
      constraints: BoxConstraints(minHeight: isMobile ? 0 : 54),
      alignment: isMobile ? null : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      // 좌우 30은 세 폭 공통, 모바일만 상하 16(목업 161:101488 — 바 높이 73).
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: isMobile ? 16 : 7),
      child: isMobile ? _buildStacked(stats) : _buildInline(stats),
    );
  }

  /// 모바일 — 세 지표가 **한 줄**에 나란히 서되 각 칸이 값(위)·라벨(아래)로
  /// 쌓인다(목업 161:101494). 남는 폭은 칸 사이에 고르게 퍼진다.
  Widget _buildStacked(List<Widget> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) _divider(margin: 0),
              stats[i],
            ],
          ],
        ),
        if (onApply != null) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: onApply,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '가입 신청하기',
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 20, color: SDSColor.gray900),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInline(List<Widget> stats) {
    return Row(
        children: [
          // 목업은 세 지표가 **왼쪽에 모여** 있다(남은 폭을 나눠 갖지 않는다).
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) _divider(),
            // 각 칸은 내용 폭 그대로(숫자 안 잘림). 남는 폭은 아래 Spacer가 먹는다.
            stats[i],
          ],
          if (onApply != null) ...[
            const Spacer(),
            InkWell(
              onTap: onApply,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '가입 신청하기',
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 20, color: SDSColor.gray900),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
  }

  /// 항목 사이 구분선 — 1×16, gray700 10%, 좌우 24(랭킹 내 랭킹 카드와 동일).
  Widget _divider({double margin = 24}) => Container(
        width: 1,
        height: 16,
        margin: EdgeInsets.symmetric(horizontal: margin),
        color: SDSColor.gray700.withValues(alpha: 0.1),
      );
}

class _StatCell extends StatefulWidget {
  final String label;
  final String value;

  /// 주면 칸 전체가 탭 대상이 된다(`멤버(명)` → 전체 멤버 화면).
  final VoidCallback? onTap;

  /// 모바일은 값(위) · 라벨(아래)로 쌓고 가운데 정렬한다(목업).
  final bool stacked;

  const _StatCell({
    required this.label,
    required this.value,
    this.onTap,
    this.stacked = false,
  });

  @override
  State<_StatCell> createState() => _StatCellState();
}

class _StatCellState extends State<_StatCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // 누를 수 있는 칸(`멤버(명)`)만 hover에서 **밑줄**로 알린다 — 바 안이라
    // 배경 틴트를 쓰면 gray50 위에 또 회색이 깔려 잘 안 보인다.
    final underline =
        widget.onTap != null && _hovered ? TextDecoration.underline : null;
    // 랭킹 내 랭킹 카드와 동일 — 라벨 Regular 14(검정 50%), 값 Bold 17.
    final label = Text(
      widget.label,
      style: SDSTextStyle.regular.copyWith(
        fontSize: 14,
        color: SDSColor.gray900.withValues(alpha: 0.5),
        decoration: underline,
        decorationColor: SDSColor.gray900.withValues(alpha: 0.5),
      ),
    );
    final value = Text(
      widget.value,
      maxLines: 1,
      softWrap: false,
      // 가로(인라인)에서는 숫자를 절대 줄이지 않고 전부 보여준다. 모바일 쌓임은 기존대로.
      overflow: widget.stacked ? TextOverflow.ellipsis : TextOverflow.visible,
      style: SDSTextStyle.bold.copyWith(
        fontSize: 17,
        color: SDSColor.gray900,
        decoration: underline,
      ),
    );

    final cell = widget.stacked
        // 값 ↔ 라벨 4 (목업 — 값 21 / 라벨 16, 칸 높이 41).
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [value, const SizedBox(height: 4), label],
          )
        // 가로 배치는 라벨 ↔ 값 11.
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [label, const SizedBox(width: 11), value],
          );
    if (widget.onTap == null) return cell;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: cell,
      ),
    );
  }
}
