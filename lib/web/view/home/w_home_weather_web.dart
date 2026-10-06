import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/core/model/m_weatherModel.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ── 레이아웃 치수 (위젯과 필요폭 계산이 **같은 값**을 보게 한 곳에 둔다) ──
// PC 한 줄
const double _kDesktopCardPadH = 40; // 카드 좌우 패딩
const double _kDesktopGapToLinks = 40; // 카드 ↔ 링크
const double _kDesktopDividerGapL = 30; // 기온 ↔ 구분선
const double _kDesktopDividerGapR = 40; // 구분선 ↔ 지표
const double _kDesktopLeftMinGap = 24; // 리조트 ↔ 기온 (spaceBetween 최소)
const int _kDesktopLeftFlex = 13; // 좌(리조트·기온) : 우(지표) = 13 : 12
const int _kDesktopRightFlex = 12;
// 태블릿(카드 + 링크)
const double _kTabletCardMaxWidth = 375; // 접힌 카드 기본 폭(피그마)
const double _kTabletCardPadL = 30;
const double _kTabletCardPadR = 9; // 칩 터치영역(40) 안의 여백 11을 감안한 보정
const double _kTabletGapToLinks = 16; // 접힌 카드 ↔ 링크 최소 간격
const double _kTabletMinSpacer = 16; // 리조트 ↔ 기온 최소 간격
const double _kMetricsWindowWidth = 360; // 펼쳤을 때 지표 창
const double _kChipGap = 3;
const double _kChipSize = 40; // `+` 칩 터치 영역
// 공통
const double _kDividerWidth = 1;
const double _kMetricsMinGap = 8; // 지표 4개 사이 최소 간격(spaceBetween)
const double _kLinksRightPad = 20;
const double _kLinkPadH = SDSSpacing.sm;
const double _kLinkIconSize = 30;
const double _kLinkDividerGap = SDSSpacing.md; // 링크 ↔ 구분선
const double _kResortArrowGap = 4;
const double _kResortNameSize = 16; // 리조트명(PC·태블릿)

/// 홈 날씨 바 — 리조트 선택 + 현재 날씨 + 네이버날씨/웹캠/슬로프현황/셔틀버스 링크.
///
/// 폭에 따라 구성이 갈린다(목업).
///  - PC 한 줄: `리조트 | 기온 | 바람·습도·강수·최저/최고 | 링크 4개`
///  - 카드 + 링크: 지표 4개를 접고 `+` 칩으로 펼친다(태블릿 목업).
///  - 세로 스택: 카드 아래 링크 줄, 지표는 카드 안에서 펼친다(모바일 목업).
///
/// ⚠️ 구성은 **이 위젯이 받은 폭**으로 고른다(뷰포트 폭이 아니다). 데스크탑(≥1024)부터
/// 좌측 사이드바가 붙어 실제 폭이 1024에서 오히려 239px 줄어들기 때문에, 뷰포트 기준으로
/// 고르면 1024~1056에서 카드가 링크를 덮고, 1200~1300에서 PC 한 줄이 넘쳤다(2026-10 실측).
/// 각 구성이 실제로 들어가는 최소폭을 [_WeatherBarFit]이 글자 폭을 재서 계산한다.
class HomeWeatherBarWeb extends StatefulWidget {
  final ResortModel? resort;
  final Map<String, dynamic> weather;
  final ValueChanged<ResortModel> onResortSelected;

  const HomeWeatherBarWeb({
    super.key,
    required this.resort,
    required this.weather,
    required this.onResortSelected,
  });

  @override
  State<HomeWeatherBarWeb> createState() => _HomeWeatherBarWebState();
}

class _HomeWeatherBarWebState extends State<HomeWeatherBarWeb> {
  /// 태블릿·모바일에서 `+`로 펼친 상태.
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // 웹은 글꼴(Pretendard)이 비동기로 들어온다. 그 전에 잰 글자 폭은 대체 글꼴 기준이라
    // 구성 선택이 틀릴 수 있는데, 폭(constraints)이 그대로면 LayoutBuilder가 다시 돌지
    // 않는다 → 글꼴이 바뀌었다는 신호를 받으면 다시 그린다.
    PaintingBinding.instance.systemFonts.addListener(_onFontsChanged);
  }

  @override
  void dispose() {
    PaintingBinding.instance.systemFonts.removeListener(_onFontsChanged);
    super.dispose();
  }

  void _onFontsChanged() {
    if (mounted) setState(() {});
  }

  /// 날씨·시간대별 카드 배경색(WeatherModel 규칙, 앱과 동일).
  Color get _weatherBg =>
      WeatherModel().getWeatherColor(
        '${widget.weather['pty'] ?? '0'}',
        '${widget.weather['sky'] ?? '1'}',
      ) ??
      const Color(0xFFDCEAFF);

  /// 날씨·시간대별 텍스트색(WeatherModel 규칙, 앱과 동일).
  Color get _weatherFg =>
      WeatherModel().getWeatherTextColor(
        '${widget.weather['pty'] ?? '0'}',
        '${widget.weather['sky'] ?? '1'}',
      ) ??
      SDSColor.gray900;

  /// +/− 칩의 원 배경 — 맑은 낮(어두운 텍스트)은 텍스트색 20%,
  /// 밤/흐림/비/눈(흰 텍스트)은 검정 40%.
  Color get _chipCircleColor => _weatherFg.computeLuminance() > 0.5
      ? Colors.black.withOpacity(0.4)
      : _weatherFg.withOpacity(0.2);

  @override
  Widget build(BuildContext context) {
    // 모바일은 폭과 상관없이 목업의 세로 스택.
    if (context.screenType == WebScreenType.mobile) return _buildStacked();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final fit = _WeatherBarFit.measure(
          context,
          resortName: widget.resort?.resortName ?? '스키장 선택',
          weather: widget.weather,
        );
        if (width >= fit.desktopRowMinWidth) return _buildDesktop();
        if (width >= fit.tabletRowMinWidth) {
          // 접힌 카드는 피그마 375가 기본이지만, 내용(긴 리조트명 등)이 더 필요하면 그만큼
          // 늘리고, 링크와 겹치지 않는 폭을 넘지는 않는다. tabletRowMinWidth가 이미
          // "내용 최소폭 + 간격 + 링크"를 보장하므로 아래 범위는 항상 비어 있지 않다.
          final available = width - fit.linksWidth - _kTabletGapToLinks;
          final wanted = fit.collapsedCardMinWidth > _kTabletCardMaxWidth
              ? fit.collapsedCardMinWidth
              : _kTabletCardMaxWidth;
          return _buildTabletRow(
            total: width,
            collapsedWidth: wanted < available ? wanted : available,
          );
        }
        // 두 줄 구성이 다 안 들어가면 모바일처럼 쌓는다(접힌 카드가 링크를 덮지 않게).
        return _buildStacked();
      },
    );
  }

  /// 카드 아래 링크 줄(모바일 목업). 좁은 데스크탑·태블릿 폭의 대체 구성으로도 쓴다.
  Widget _buildStacked() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMobileCard(),
        const SizedBox(height: SDSSpacing.md),
        _HomeWeatherLinks(resort: widget.resort, fillWidth: true),
      ],
    );
  }

  Widget _buildDesktop() {
    final Color fg = _weatherFg;
    return Row(
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              // 날씨·시간대별 다이내믹 배경(모바일과 동일 규칙).
              color: _weatherBg,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: _kDesktopCardPadH, vertical: 18),
            child: _buildDesktopRow(fg),
          ),
        ),
        const SizedBox(width: _kDesktopGapToLinks),
        _HomeWeatherLinks(resort: widget.resort),
      ],
    );
  }

  /// 모바일 카드 — 앱(v_resortHome)과 동일한 디자인.
  /// 배경/텍스트 색은 WeatherModel의 날씨·시간대 규칙을 그대로 쓴다.
  Widget _buildMobileCard() {
    final weather = widget.weather;
    final String pty = '${weather['pty'] ?? '0'}';
    final String sky = '${weather['sky'] ?? '1'}';
    final weatherModel = WeatherModel();
    final Color bg = weatherModel.getWeatherColor(pty, sky) ?? const Color(0xFFDCEAFF);
    final Color fg = weatherModel.getWeatherTextColor(pty, sky) ?? SDSColor.gray900;
    final icon = homeWeatherIconAsset(pty: pty, sky: sky, now: DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      // 피그마 모바일 가이드(1:13377): 좌 20, 나머지 16.
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildResortBlock(
                  textColor: fg,
                  nameSize: 16,
                  dateSize: 12,
                  arrowSize: 12,
                ),
              ),
              // 피그마 가이드: 날씨 아이콘(40) → 기온(Bebas 40) → °(32) → 펼침 버튼.
              Image.asset(icon, width: 40, height: 40),
              const SizedBox(width: 8),
              Text(
                homeTempLabel(weather['temp']),
                style: GoogleFonts.bebasNeue(fontSize: 36, color: fg, height: 1.0),
              ),
              const SizedBox(width: 2),
              Text(
                '°',
                style: GoogleFonts.bebasNeue(fontSize: 28, color: fg, height: 1.0),
              ),
              const SizedBox(width: 4),
              // 펼침 버튼 — 웹 형태(원형 칩 18 + 두께 1.5)에 색만 배경 대응:
              // 원 = 텍스트색 20%, 아이콘 = 텍스트색.
              _PlusChip(
                isExpanded: _isExpanded,
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                circleColor: _chipCircleColor,
                iconColor: fg,
              ),
            ],
          ),
          // 지표는 카드 **안**에서 펼쳐진다(앱과 동일).
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !_isExpanded
                ? const SizedBox(width: double.infinity)
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Container(
                          height: 1,
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ),
                      // 양끝 마진 10, 그 안에서 균등 간격(spaceBetween).
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _buildMetrics(
                          textColor: fg,
                          labelSize: 12,
                          unitSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// 카드 + 링크. `+`를 누르면 카드가 [total]까지 길어지며 지표가 인라인으로 펼쳐지고,
  /// 링크는 우측으로 밀려난다. 접힌 카드 폭은 [collapsedWidth](링크와 겹치지 않는 폭).
  Widget _buildTabletRow({required double total, required double collapsedWidth}) {
    return Builder(
      builder: (context) {
        return SizedBox(
          height: 86,
          child: ClipRect(
            child: Stack(
              children: [
                // 링크(우측 정렬) — 펼치면 우측 바깥으로 슬라이드 아웃.
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedSlide(
                    offset: _isExpanded ? const Offset(1.2, 0) : Offset.zero,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      opacity: _isExpanded ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Center(child: _HomeWeatherLinks(resort: widget.resort)),
                    ),
                  ),
                ),
                // 카드 — 펼치면 전체 폭으로 길어진다.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _isExpanded ? total : collapsedWidth,
                  height: 86,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    // 날씨·시간대별 다이내믹 배경(모바일과 동일 규칙).
                    color: _weatherBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // 우측은 터치 영역(40) 안의 여백 11을 감안해 9로 보정(시각상 20).
                  padding: const EdgeInsets.only(left: _kTabletCardPadL, right: _kTabletCardPadR),
                  child: Row(
                    children: [
                      _buildResortBlock(textColor: _weatherFg),
                      // 가변 여백 — 접힘: 온도를 우측 끝으로 / 펼침: PC처럼 리조트↔온도 사이.
                      const Spacer(),
                      _buildTemp(textColor: _weatherFg),
                      // 지표 창 — 펼치면 온도 오른쪽에서 0→360으로 늘어나며
                      // PC와 같은 순서(온도 | 구분선 | 지표)가 된다.
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: _isExpanded ? _kMetricsWindowWidth : 0,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(),
                        child: OverflowBox(
                          minWidth: _kMetricsWindowWidth,
                          maxWidth: _kMetricsWindowWidth,
                          alignment: Alignment.centerLeft,
                          child: AnimatedOpacity(
                            opacity: _isExpanded ? 1 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: SizedBox(
                              width: _kMetricsWindowWidth,
                              child: Row(
                                children: [
                                  const SizedBox(width: 30),
                                  _divider(_weatherFg),
                                  const SizedBox(width: 30),
                                  Expanded(child: _buildMetrics(textColor: _weatherFg)),
                                  // 최저/최고 우측 여백.
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: _kChipGap),
                      _PlusChip(
                        isExpanded: _isExpanded,
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        circleColor: _chipCircleColor,
                        iconColor: _weatherFg,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopRow(Color fg) {
    // 좌측(리조트·기온·날씨 아이콘) : 우측(지표 4개) = 6 : 4
    return Row(
      children: [
        Expanded(
          flex: _kDesktopLeftFlex, // 5.2 : 4.8 비율(= 13 : 12)
          child: Row(
            // 리조트(좌) ↔ 기온·날씨 아이콘(우) 양끝 정렬
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResortBlock(textColor: fg),
              _buildTemp(textColor: fg),
            ],
          ),
        ),
        // 구분선 좌 30 / 우 40 간격
        const SizedBox(width: _kDesktopDividerGapL),
        _divider(fg),
        const SizedBox(width: _kDesktopDividerGapR),
        Expanded(flex: _kDesktopRightFlex, child: _buildMetrics(textColor: fg)),
      ],
    );
  }

  Widget _buildResortBlock({
    Color? textColor,
    // 화면에 실제로 보이던 값(16)을 기본값으로 둔다. 예전엔 드롭다운이 이 인자를
    // 무시하고 16을 하드코딩해서, 기본값 18은 한 번도 적용된 적이 없었다.
    double nameSize = _kResortNameSize,
    double dateSize = 14,
    double arrowSize = 20,
  }) {
    final resort = widget.resort;
    final Color color = textColor ?? SDSColor.gray900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ResortDropdown(
          label: resort?.resortName ?? '스키장 선택',
          onSelected: widget.onResortSelected,
          color: color,
          fontSize: nameSize,
          arrowSize: arrowSize,
        ),
        const SizedBox(height: 2),
        // 날짜: Regular, 텍스트색 60%.
        Text(
          homeWeatherDateLabel(DateTime.now()),
          style: SDSTextStyle.regular.copyWith(
            fontSize: dateSize,
            color: color.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTemp({Color? textColor}) {
    final weather = widget.weather;
    final Color color = textColor ?? SDSColor.gray900;
    final icon = homeWeatherIconAsset(
      pty: '${weather['pty'] ?? '0'}',
      sky: '${weather['sky'] ?? '1'}',
      now: DateTime.now(),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 기온 숫자: Bebas Neue 36 / ° 28 (피그마 기준).
        Text(
          homeTempLabel(weather['temp']),
          style: GoogleFonts.bebasNeue(fontSize: 36, color: color, height: 1.0),
        ),
        const SizedBox(width: 2),
        Text(
          '°',
          style: GoogleFonts.bebasNeue(fontSize: 28, color: color, height: 1.0),
        ),
        const SizedBox(width: SDSSpacing.xs),
        Image.asset(icon, width: 40, height: 40),
      ],
    );
  }

  Widget _buildMetrics({
    Color? textColor,
    double labelSize = 11,
    double unitSize = 14,
    bool spaceEvenly = false,
  }) {
    final weather = widget.weather;
    final max = homeTempLabel(weather['maxTemp']);
    final min = homeTempLabel(weather['minTemp']);
    return Row(
      mainAxisAlignment:
          spaceEvenly ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.spaceBetween,
      children: [
        _Metric(label: '바람', value: '${weather['wind'] ?? '-'}', unit: 'M/S',
            textColor: textColor, labelSize: labelSize, unitSize: unitSize),
        _Metric(label: '습도', value: '${weather['wet'] ?? '-'}', unit: '%',
            textColor: textColor, labelSize: labelSize, unitSize: unitSize),
        _Metric(label: '강수', value: '${weather['rain'] ?? '0'}', unit: 'MM',
            textColor: textColor, labelSize: labelSize, unitSize: unitSize),
        _Metric(label: '최저/최고', value: '$min / $max', unit: '',
            textColor: textColor, labelSize: labelSize, unitSize: unitSize),
      ],
    );
  }

  /// 구분선 — 텍스트색 15%로 배경에 대응한다.
  Widget _divider(Color fg) =>
      Container(width: 1, height: 28, color: fg.withOpacity(0.15));
}

/// 리조트 선택 트리거. 앵커 드롭다운은 **트리거만** 감싸야 한다
/// (상위 Row를 감싸면 메뉴 위치 계산이 깨져 `BoxConstraints ... NOT NORMALIZED`가 난다)
class _ResortDropdown extends StatefulWidget {
  final String label;
  final ValueChanged<ResortModel> onSelected;

  /// 모바일 다이내믹 카드에서는 배경에 맞춰 글자/화살표 색이 바뀐다.
  final Color color;
  final double fontSize;
  final double arrowSize;

  const _ResortDropdown({
    required this.label,
    required this.onSelected,
    this.color = SDSColor.gray900,
    this.fontSize = _kResortNameSize,
    this.arrowSize = 20,
  });

  @override
  State<_ResortDropdown> createState() => _ResortDropdownState();
}

class _ResortDropdownState extends State<_ResortDropdown> {
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    final names = [for (final resort in homeResorts) resort.resortName ?? ''];
    final picked = await showWebFilterMenu<String>(
      context: context,
      link: _link,
      values: names,
      labelOf: (name) => name,
      title: '스키장 선택',
    );
    if (picked == null) return;
    for (final resort in homeResorts) {
      if (resort.resortName == picked) {
        widget.onSelected(resort);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 앵커 드롭다운은 **트리거만** 감싸야 한다(상위 Row를 감싸면 메뉴 폭 계산이 깨져
    // `BoxConstraints ... NOT NORMALIZED`가 난다 — 슬로프크래프트에서 겪은 사고)
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _open,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: SDSTextStyle.bold
                    .copyWith(fontSize: widget.fontSize, color: widget.color),
              ),
              const SizedBox(width: _kResortArrowGap),
              Icon(Icons.keyboard_arrow_down, size: widget.arrowSize, color: widget.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlusChip extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  /// 모바일 다이내믹 카드에서 배경에 맞춰 색을 바꿀 때 사용
  final Color circleColor;
  final Color iconColor;

  const _PlusChip({
    required this.isExpanded,
    required this.onTap,
    this.circleColor = SDSColor.snowliveWhite,
    this.iconColor = SDSColor.gray600,
  });

  @override
  Widget build(BuildContext context) {
    // 원형 18px + 두께 1.5의 +/− (피그마 기준).
    // 보이는 건 18px이지만 터치 영역은 40x40으로 넓힌다.
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: CustomPaint(
                painter: _PlusMinusPainter(
                  isPlus: !isExpanded,
                  color: iconColor,
                  strokeWidth: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 두께를 지정할 수 있는 +/− 아이콘(머티리얼 아이콘은 두께 조절이 안 된다).
class _PlusMinusPainter extends CustomPainter {
  final bool isPlus;
  final Color color;
  final double strokeWidth;

  const _PlusMinusPainter({
    required this.isPlus,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    // 원(18) 안에서 십자 길이는 8px.
    const half = 4.0;

    canvas.drawLine(
      Offset(center.dx - half, center.dy),
      Offset(center.dx + half, center.dy),
      paint,
    );
    if (isPlus) {
      canvas.drawLine(
        Offset(center.dx, center.dy - half),
        Offset(center.dx, center.dy + half),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PlusMinusPainter oldDelegate) =>
      oldDelegate.isPlus != isPlus ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  /// 모바일 다이내믹 카드용 — 텍스트 색과 크기를 배경에 맞춰 바꾼다.
  final Color? textColor;
  final double labelSize;
  final double unitSize;

  const _Metric({
    required this.label,
    required this.value,
    required this.unit,
    this.textColor,
    this.labelSize = 11,
    this.unitSize = 14,
  });

  Color get _valueColor => textColor ?? SDSColor.gray900;
  Color get _labelColor =>
      textColor?.withOpacity(0.5) ?? SDSColor.gray700.withOpacity(0.6);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 지표 라벨: Pretendard Regular (PC 11/gray700 60%, 모바일 12/텍스트색 50%).
        Text(
          label,
          style: SDSTextStyle.regular.copyWith(
            fontSize: labelSize,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 지표 숫자/단위: Bebas Neue 24 + 단위(PC 14 / 모바일 16).
            ..._buildValueTexts(),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 3),
              Text(unit,
                  style: GoogleFonts.bebasNeue(
                      fontSize: unitSize, color: _valueColor, height: 1.0)),
            ],
          ],
        ),
      ],
    );
  }

  /// 값 텍스트. `12 / 26`처럼 슬래시가 있으면 슬래시만 16px로 작게 그린다(피그마).
  List<Widget> _buildValueTexts() {
    if (!value.contains('/')) {
      return [
        Text(value,
            style: GoogleFonts.bebasNeue(fontSize: 24, color: _valueColor, height: 1.0)),
      ];
    }
    final parts = value.split('/');
    return [
      for (var i = 0; i < parts.length; i++) ...[
        if (i > 0) ...[
          const SizedBox(width: 2),
          Text('/',
              style: GoogleFonts.bebasNeue(
                  fontSize: 16, color: _valueColor, height: 1.0)),
          const SizedBox(width: 2),
        ],
        Text(parts[i].trim(),
            style: GoogleFonts.bebasNeue(fontSize: 24, color: _valueColor, height: 1.0)),
      ],
    ];
  }
}

/// 네이버 날씨 / 실시간 웹캠 / 슬로프 현황 / 셔틀버스. 링크는 정적 리조트 목록에 있다.
class _HomeWeatherLinks extends StatelessWidget {
  final ResortModel? resort;

  /// 카드 아래 전체폭 한 줄일 때(세로 스택) — 네 칸을 균등 분할한다(라벨이 잘리지 않게).
  /// 뷰포트가 아니라 **배치**로 정한다: 좁은 데스크탑 폭에서도 세로 스택이면 이 모양이다.
  final bool fillWidth;

  const _HomeWeatherLinks({required this.resort, this.fillWidth = false});

  /// 링크 줄 텍스트 스타일(필요폭 계산과 공유).
  static TextStyle labelStyle({required bool compact}) => SDSTextStyle.regular.copyWith(
        fontSize: compact ? 12 : 11,
        color: compact ? SDSColor.gray800 : SDSColor.gray700,
      );

  static const List<String> labels = ['네이버 날씨', '실시간 웹캠', '슬로프 현황', '셔틀버스'];

  @override
  Widget build(BuildContext context) {
    final isMobile = fillWidth;

    final links = <({String label, String asset, String? url})>[
      (label: labels[0], asset: 'assets/imgs/icons/icon_home_naver.png', url: resort?.naverUrl),
      (label: labels[1], asset: 'assets/imgs/icons/icon_home_livecam.png', url: resort?.webcamUrl),
      (label: labels[2], asset: 'assets/imgs/icons/icon_home_slope.png', url: resort?.slopeUrl),
      (label: labels[3], asset: 'assets/imgs/icons/icon_home_bus.png', url: resort?.busUrl),
    ];

    return Padding(
      // 링크 영역 전체의 우측 여백 20.
      padding: EdgeInsets.only(right: isMobile ? 0 : _kLinksRightPad),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < links.length; i++) ...[
            // 항목-구분선 사이 간격 16 (피그마 기준). 모바일은 구분선 미노출.
            if (i > 0 && !isMobile) ...[
              const SizedBox(width: _kLinkDividerGap),
              Container(width: _kDividerWidth, height: 28, color: SDSColor.gray100),
              const SizedBox(width: _kLinkDividerGap),
            ],
            Expanded(
              flex: isMobile ? 1 : 0,
              child: _QuickLink(
                label: links[i].label,
                asset: links[i].asset,
                url: links[i].url,
                isCompact: isMobile,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickLink extends StatefulWidget {
  final String label;
  final String asset;
  final String? url;
  final bool isCompact;

  const _QuickLink({
    required this.label,
    required this.asset,
    required this.url,
    this.isCompact = false,
  });

  @override
  State<_QuickLink> createState() => _QuickLinkState();
}

class _QuickLinkState extends State<_QuickLink> {
  bool _hovered = false;

  /// 터치(태블릿)용 — 빠르게 탭해도 효과가 잠깐(150ms) 보이게 유지한다.
  bool _pressed = false;
  Timer? _pressTimer;

  bool get _highlighted => _hovered || _pressed;

  String get label => widget.label;
  String get asset => widget.asset;
  String? get url => widget.url;
  bool get isCompact => widget.isCompact;

  @override
  void dispose() {
    _pressTimer?.cancel();
    super.dispose();
  }

  void _pressDown() {
    _pressTimer?.cancel();
    setState(() => _pressed = true);
  }

  void _pressUpDelayed() {
    _pressTimer?.cancel();
    _pressTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _pressDown(),
        onTapUp: (_) => _pressUpDelayed(),
        onTapCancel: () {
          _pressTimer?.cancel();
          setState(() => _pressed = false);
        },
        onTap: () async {
          final target = url;
          if (target == null || target.isEmpty) return;
          final uri = Uri.tryParse(target);
          if (uri == null) return;
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Padding(
          // 데스크탑은 구분선 좌우 16 간격을 Row에서 주므로 내부 패딩은 줄인다
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : _kLinkPadH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // PC/태블릿: 아이콘 30, 라벨 11 gray700 (피그마).
              // 모바일(isCompact): 앱과 동일하게 아이콘 32, 라벨 12 gray800.
              // hover 시 하단 기준으로 10% 확대(위로만 커져서 라벨이 밀리지 않는다).
              AnimatedScale(
                scale: _highlighted ? 1.1 : 1.0,
                alignment: Alignment.bottomCenter,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: Image.asset(
                  asset,
                  width: isCompact ? 32 : _kLinkIconSize,
                  height: isCompact ? 32 : _kLinkIconSize,
                  errorBuilder: (_, __, ___) =>
                      SizedBox.square(dimension: isCompact ? 32 : 30),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: _HomeWeatherLinks.labelStyle(compact: isCompact),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 날씨 바의 각 구성이 **넘치지 않고 들어가는 최소폭**.
///
/// 위젯 트리와 같은 상수(`_kDesktop*` / `_kTablet*` / `_kLink*`)와 같은 글자 스타일로
/// 글자 폭을 직접 잰다. 리조트명·기온·지표 값은 바뀌므로 매번 다시 잰다(값 몇 개라 가볍다).
class _WeatherBarFit {
  /// PC 한 줄 구성 최소폭.
  final double desktopRowMinWidth;

  /// 카드 + 링크 구성 최소폭(접힘·펼침 둘 다 들어가야 한다).
  final double tabletRowMinWidth;

  /// 우측 링크 줄 폭.
  final double linksWidth;

  /// 접힌 카드가 내용을 담는 데 필요한 최소폭(패딩 포함).
  final double collapsedCardMinWidth;

  const _WeatherBarFit({
    required this.desktopRowMinWidth,
    required this.tabletRowMinWidth,
    required this.linksWidth,
    required this.collapsedCardMinWidth,
  });

  static _WeatherBarFit measure(
    BuildContext context, {
    required String resortName,
    required Map<String, dynamic> weather,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    double w(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    // ── 링크 줄 ──
    final linkStyle = _HomeWeatherLinks.labelStyle(compact: false);
    var linksWidth = _kLinksRightPad;
    for (var i = 0; i < _HomeWeatherLinks.labels.length; i++) {
      final label = w(_HomeWeatherLinks.labels[i], linkStyle);
      linksWidth += _kLinkPadH * 2 + (label > _kLinkIconSize ? label : _kLinkIconSize);
      if (i > 0) linksWidth += _kLinkDividerGap * 2 + _kDividerWidth;
    }

    // ── 리조트 블록(이름 + ▼ / 날짜) ──
    final nameWidth = w(resortName, SDSTextStyle.bold.copyWith(fontSize: _kResortNameSize));
    final dateWidth = w(homeWeatherDateLabel(DateTime.now()),
        SDSTextStyle.regular.copyWith(fontSize: 14));
    final nameRow = nameWidth + _kResortArrowGap + 20; // ▼ 20
    final resortBlock = nameRow > dateWidth ? nameRow : dateWidth;

    // ── 기온 블록(숫자 + ° + 아이콘) ──
    final tempBlock = w(homeTempLabel(weather['temp']), GoogleFonts.bebasNeue(fontSize: 36, height: 1.0)) +
        2 +
        w('°', GoogleFonts.bebasNeue(fontSize: 28, height: 1.0)) +
        SDSSpacing.xs +
        40;

    // ── 지표 4개 ──
    double metric(String label, String value, String unit) {
      final labelWidth = w(label, SDSTextStyle.regular.copyWith(fontSize: 11));
      double valueWidth = 0;
      final parts = value.split('/');
      for (var i = 0; i < parts.length; i++) {
        if (i > 0) valueWidth += 2 + w('/', GoogleFonts.bebasNeue(fontSize: 16, height: 1.0)) + 2;
        valueWidth += w(parts[i].trim(), GoogleFonts.bebasNeue(fontSize: 24, height: 1.0));
      }
      if (unit.isNotEmpty) {
        valueWidth += 3 + w(unit, GoogleFonts.bebasNeue(fontSize: 14, height: 1.0));
      }
      return labelWidth > valueWidth ? labelWidth : valueWidth;
    }

    final metrics = metric('바람', '${weather['wind'] ?? '-'}', 'M/S') +
        metric('습도', '${weather['wet'] ?? '-'}', '%') +
        metric('강수', '${weather['rain'] ?? '0'}', 'MM') +
        metric('최저/최고', '${homeTempLabel(weather['minTemp'])} / ${homeTempLabel(weather['maxTemp'])}', '') +
        _kMetricsMinGap * 3;

    // ── PC 한 줄 ──
    // 좌·우 Expanded가 13 : 12로 나눠 가지므로, 각자 자기 내용이 들어가는 만큼의
    // 유연폭이 필요하다 → 둘 중 큰 쪽이 기준.
    const totalFlex = _kDesktopLeftFlex + _kDesktopRightFlex;
    final leftNeed = resortBlock + _kDesktopLeftMinGap + tempBlock;
    final flexForLeft = leftNeed * totalFlex / _kDesktopLeftFlex;
    final flexForRight = metrics * totalFlex / _kDesktopRightFlex;
    final flexible = flexForLeft > flexForRight ? flexForLeft : flexForRight;
    final desktopCard = flexible +
        _kDesktopDividerGapL +
        _kDividerWidth +
        _kDesktopDividerGapR +
        _kDesktopCardPadH * 2;
    final desktopRowMinWidth = desktopCard + _kDesktopGapToLinks + linksWidth;

    // ── 카드 + 링크 ──
    final cardContent = resortBlock + _kTabletMinSpacer + tempBlock + _kChipGap + _kChipSize;
    final collapsedCardMin = _kTabletCardPadL + cardContent + _kTabletCardPadR;
    final expandedCardMin = collapsedCardMin + _kMetricsWindowWidth;
    final collapsedRow = collapsedCardMin + _kTabletGapToLinks + linksWidth;
    final tabletRowMinWidth = collapsedRow > expandedCardMin ? collapsedRow : expandedCardMin;

    return _WeatherBarFit(
      desktopRowMinWidth: desktopRowMinWidth,
      tabletRowMinWidth: tabletRowMinWidth,
      linksWidth: linksWidth,
      collapsedCardMinWidth: collapsedCardMin,
    );
  }
}
