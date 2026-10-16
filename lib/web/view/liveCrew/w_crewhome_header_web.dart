import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_title_row_link_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_stats_bar_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:com.snowlive/web/viewmodel/alarm/vm_alarmCenter_web.dart' show AlarmBadgeWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('###,###,###,###');

/// 크루홈 헤더 — 로고 + 크루명 + `소개 · 리조트` + 방문자 수 + 알림/설정.
class CrewHomeHeaderWeb extends StatelessWidget {
  final CrewDetailInfo info;

  /// 설정 톱니를 그릴지. 앱과 같이 **내 크루일 때만** 보여준다.
  final bool showSettings;

  /// 가입 신청 알림 종을 그릴지 — 앱과 같이 크루장, 또는 가입 신청 허가 권한이 있는
  /// 운영진에게만(`CrewDetailViewModelWeb.canManageApplications`).
  final bool showAlarm;

  /// 종의 `N` 배지를 구독할 내 user_id(Firestore `notificationCenter.crew`).
  final int? alarmUserId;

  /// 종을 눌렀을 때(가입 신청 목록으로).
  final VoidCallback? onAlarmTap;

  /// 방문자수(오늘/전체). null이면 `-`로 표시(아직 집계 전).
  final int? visitorToday;
  final int? visitorTotal;

  /// `가입 신청하기` — **모바일에서만** 이 줄 우측 끝에 텍스트 버튼으로 온다
  /// (사용자 확정). PC·태블릿은 요약 바 안에 남아 있어 null로 들어온다.
  final VoidCallback? onApply;

  /// 공유 아이콘(링크 복사 / OS 공유 시트). 로그인·소속 여부와 무관하게 늘 보인다.
  final VoidCallback? onShare;

  const CrewHomeHeaderWeb({
    super.key,
    required this.info,
    this.showSettings = false,
    this.showAlarm = false,
    this.alarmUserId,
    this.onAlarmTap,
    this.visitorToday,
    this.visitorTotal,
    this.onApply,
    this.onShare,
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
              // `가입 신청하기`(모바일 전용)는 **크루명과 같은 줄**에 둬서 글자와
              // 세로 중심이 맞는다(사용자 확정 — 헤더 줄 전체 기준으로 가운데
              // 두면 부제까지 포함한 중심이라 크루명보다 11 내려간다).
              // 아이콘이 없는 상태라 이 열이 콘텐츠 우측선까지 차지한다.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      info.crewName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // 크루명은 서브 페이지 타이틀 공통값(PC 30 / 태블릿 24 / 모바일 20).
                      // 목업 PC가 30이라 공통값과 같다.
                      style: SDSTextStyle.bold.copyWith(
                          fontSize: webSubPageTitleSize(context), color: SDSColor.gray900),
                    ),
                  ),
                  if (onApply != null) ...[
                    const SizedBox(width: SDSSpacing.sm),
                    // ⚠️ 높이는 링크에 **직접** 넘긴다(바깥에서 감싸면 상하 패딩까지
                    // 조여져 글자 아래가 잘린다). 크루명 글줄과 같은 높이라
                    // 세로 중심이 맞고 부제도 밀리지 않는다.
                    WebTitleRowLink(
                      label: '가입 신청하기',
                      onTap: onApply!,
                      boxHeight: webSubPageTitleSize(context) * (24 / 20),
                    ),
                  ],
                ],
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
        if (onShare != null) ...[
          const SizedBox(width: SDSSpacing.md),
          WebIconButton(
            onTap: onShare!,
            tooltip: '링크 복사',
            padding: const EdgeInsets.all(1),
            icon: SvgPicture.asset(
              'assets/imgs/icons/icon_header_share_web.svg',
              width: 26,
              height: 26,
            ),
          ),
        ],
        if (showAlarm || showSettings) const SizedBox(width: SDSSpacing.md),
        if (showAlarm)
          _CrewAlarmButton(
            userId: alarmUserId,
            onTap: onAlarmTap ?? () {},
            // 설정이 없으면 이게 마지막 아이콘이다.
            flushRight: !showSettings,
          ),
        if (showSettings) ...[
          // 아이콘 **사이 12**(목업 — 묶음 64 = 26 + 12 + 26). 각 버튼이 히트 여백
          // 4씩을 갖고 있으므로 여기서는 4만 준다(4+4+4 = 12).
          if (showAlarm) const SizedBox(width: 4),
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

/// 가입 신청 알림 종 — 새 신청이 있으면 오른쪽 위에 빨간 `N`(앱 `v_crewMain.dart:104`과 같은 모양).
class _CrewAlarmButton extends StatefulWidget {
  final int? userId;
  final VoidCallback onTap;
  final bool flushRight;

  const _CrewAlarmButton({required this.userId, required this.onTap, required this.flushRight});

  @override
  State<_CrewAlarmButton> createState() => _CrewAlarmButtonState();
}

class _CrewAlarmButtonState extends State<_CrewAlarmButton> {
  int? _uid;
  Stream<bool>? _stream;

  /// 리빌드마다 구독을 새로 걸지 않게 user_id별로 한 번만 만든다.
  Stream<bool>? get _crewStream {
    if (widget.userId != _uid) {
      _uid = widget.userId;
      _stream = _uid == null ? null : AlarmBadgeWeb.crewStream(_uid!);
    }
    return _stream;
  }

  @override
  Widget build(BuildContext context) {
    final button = _HeaderIconButton(
      // 앱과 같은 에셋(v_crewMain.dart:72) — 알림은 틴트 없이 그대로 쓴다.
      asset: 'assets/imgs/icons/icon_alarm_resortHome.png',
      onTap: widget.onTap,
      flushRight: widget.flushRight,
    );
    final stream = _crewStream;
    if (stream == null) return button;
    return StreamBuilder<bool>(
      stream: stream,
      builder: (context, snap) {
        if (snap.data != true) return button;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            button,
            Positioned(
              top: -4,
              right: widget.flushRight ? -8 : -4,
              child: IgnorePointer(
                child: Container(
                  key: const ValueKey('crew-alarm-new'),
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD6382B),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'N',
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 10,
                      height: 1,
                      color: SDSColor.snowliveWhite,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 크루 소개글 블록 — 앱 크루홈(`v_crewHome.dart:301~`)처럼 통계 바 아래에 따로 둔다.
/// 한 줄을 넘으면 +/- 아이콘으로 펼치고 접는다(앱과 같은 에셋). 소개가 비면 아무것도
/// 그리지 않는다(상위에서 비었을 때 넣지 않으니 안전장치 겸용).
/// 소개글 글줄 높이. 펼침/접힘 토글도 **같은 높이**를 써야 글자가 튀지 않는다.
const double _kIntroLineHeight = 22;

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

    final textStyle = SDSTextStyle.regular.copyWith(
        fontSize: 14, height: _kIntroLineHeight / 14, color: SDSColor.gray700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ⚠️ 상단 구분선·여백은 여기서 그리지 않는다 — 소개글이 **지표 바 박스 안쪽
        // 하단**에 들어가므로 선과 간격은 `WebStatsBar(footer:)`가 담당한다
        // (사용자 확정). 선을 여기서 또 그리면 두 줄이 된다.
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

            // ⚠️ 정렬을 **항상 start**로 둔다. 접힘만 center로 주면 토글(22)과
            // 글줄(22)이 같은 높이여도, 예전처럼 토글이 더 높으면 접힘에서 글자가
            // 아래로 밀려 펼칠 때 1px 튀었다(사용자 지적).
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
        // ⚠️ 높이를 **글줄(22)과 같게** 못 박고 아이콘을 그 안에서 가운데 둔다.
        // 상하 패딩으로 24가 되면 글줄보다 높아져서 Row가 글자를 밀어낸다 —
        // 펼침/접힘에서 글자 위치가 바뀌던 원인이다. 좌우 2는 유지해 누를 폭을 둔다.
        child: SizedBox(
          height: _kIntroLineHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Image.asset(
                expanded
                    ? 'assets/imgs/icons/icon_minus_round.png'
                    : 'assets/imgs/icons/icon_plus_round.png',
                width: 20,
                height: 20,
              ),
            ),
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

  /// 박스 안쪽 하단에 들어갈 크루 소개글. 없으면 지표 줄만 그린다.
  final Widget? footer;

  const CrewHomeSummaryBarWeb({
    super.key,
    required this.memberCount,
    required this.overallRank,
    required this.totalScore,
    this.onApply,
    this.onMembersTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    // 규격은 공용 지표 바(`WebStatsBar`)가 들고 있다 — 기록실 요약 바와 같은 것이다.
    return WebStatsBar(
      items: [
        WebStatItem(
          label: '멤버(명)',
          value: _numberFormat.format(memberCount ?? 0),
          onTap: onMembersTap,
        ),
        WebStatItem(label: '통합 랭킹', value: _numberFormat.format(overallRank ?? 0)),
        WebStatItem(
          label: '총 점수',
          value: _numberFormat.format((totalScore ?? 0).round()),
        ),
      ],
      // 내 크루가 아닐 때만 가입 신청을 노출한다(목업).
      trailing: onApply == null
          ? null
          // 글자 15 — 같은 지표 바 진입 링크(`크루원 시즌 랭킹`)와 같은 값으로 맞춘다
          // (사용자 확정. 공용 기본값 16은 이 바에서 다른 곳과 어긋났다).
          : WebStatsBarLink(label: '가입 신청하기', fontSize: 15, onTap: onApply!),
      footer: footer,
    );
  }
}
