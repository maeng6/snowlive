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

/// 홈 날씨 바 — 리조트 선택 + 현재 날씨 + 네이버날씨/웹캠/슬로프현황/셔틀버스 링크.
///
/// 폭에 따라 구성이 갈린다(목업).
///  - 데스크탑: 한 줄에 `리조트 | 기온 | 바람·습도·강수·최저/최고 | 링크 4개`
///  - 태블릿·모바일: 지표 4개를 접고 `+` 칩으로 펼친다. 모바일은 링크 줄이 아래로 내려간다.
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

  /// 지표 4개(바람·습도·강수·최저/최고)를 한 줄에 펼치려면 이 폭은 있어야 한다.
  /// 1024(데스크탑 진입폭)에서는 사이드바를 빼면 자리가 없어 넘쳤다(실측) →
  /// 그 아래는 태블릿처럼 `+`로 접는다.
  static const double _metricsMinWidth = 1200;

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
    final screenType = context.screenType;
    final isMobile = screenType == WebScreenType.mobile;
    final isDesktop = screenType == WebScreenType.desktop &&
        MediaQuery.sizeOf(context).width >= _metricsMinWidth;

    // 모바일: 앱 리조트홈과 동일한 다이내믹 카드(날씨·시간대별 배경/텍스트 색,
    // 지표는 카드 내부에서 펼침) + 아래 링크 줄.
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMobileCard(),
          const SizedBox(height: SDSSpacing.md),
          _HomeWeatherLinks(resort: widget.resort),
        ],
      );
    }

    if (isDesktop) {
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
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              child: _buildDesktopRow(fg),
            ),
          ),
          // 날씨 카드와 링크 영역 사이 간격 40
          const SizedBox(width: 40),
          _HomeWeatherLinks(resort: widget.resort),
        ],
      );
    }

    // 태블릿: 카드(375x86) + 우측 링크 한 줄. `+`를 누르면 카드가 우측으로
    // 길어지며(전체 폭) 지표가 인라인으로 펼쳐지고, 링크는 우측으로 밀려난다.
    return _buildTabletRow();
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

  Widget _buildTabletRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double total = constraints.maxWidth;
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
                  width: _isExpanded ? total : 375,
                  height: 86,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    // 날씨·시간대별 다이내믹 배경(모바일과 동일 규칙).
                    color: _weatherBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // 우측은 터치 영역(40) 안의 여백 11을 감안해 9로 보정(시각상 20).
                  padding: const EdgeInsets.only(left: 30, right: 9),
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
                        width: _isExpanded ? 360 : 0,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(),
                        child: OverflowBox(
                          minWidth: 360,
                          maxWidth: 360,
                          alignment: Alignment.centerLeft,
                          child: AnimatedOpacity(
                            opacity: _isExpanded ? 1 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: SizedBox(
                              width: 360,
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
                      const SizedBox(width: 3),
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
          flex: 13, // 5.2 : 4.8 비율(= 13 : 12)
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
        const SizedBox(width: 30),
        _divider(fg),
        const SizedBox(width: 40),
        Expanded(flex: 12, child: _buildMetrics(textColor: fg)),
      ],
    );
  }

  Widget _buildResortBlock({
    Color? textColor,
    double nameSize = 18,
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
    this.fontSize = 18,
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
                    .copyWith(fontSize: 16, color: widget.color),
              ),
              const SizedBox(width: 4),
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

  const _HomeWeatherLinks({required this.resort});

  @override
  Widget build(BuildContext context) {
    // 모바일은 카드 아래 전체폭 한 줄이라 네 칸을 균등 분할한다(라벨이 잘리지 않게).
    final isMobile = context.screenType == WebScreenType.mobile;

    final links = <({String label, String asset, String? url})>[
      (label: '네이버 날씨', asset: 'assets/imgs/icons/icon_home_naver.png', url: resort?.naverUrl),
      (label: '실시간 웹캠', asset: 'assets/imgs/icons/icon_home_livecam.png', url: resort?.webcamUrl),
      (label: '슬로프 현황', asset: 'assets/imgs/icons/icon_home_slope.png', url: resort?.slopeUrl),
      (label: '셔틀버스', asset: 'assets/imgs/icons/icon_home_bus.png', url: resort?.busUrl),
    ];

    return Padding(
      // 링크 영역 전체의 우측 여백 20.
      padding: EdgeInsets.only(right: isMobile ? 0 : 20),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < links.length; i++) ...[
            // 항목-구분선 사이 간격 16 (피그마 기준). 모바일은 구분선 미노출.
            if (i > 0 && !isMobile) ...[
              const SizedBox(width: SDSSpacing.md),
              Container(width: 1, height: 28, color: SDSColor.gray100),
              const SizedBox(width: SDSSpacing.md),
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
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : SDSSpacing.sm),
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
                  width: isCompact ? 32 : 30,
                  height: isCompact ? 32 : 30,
                  errorBuilder: (_, __, ___) =>
                      SizedBox.square(dimension: isCompact ? 32 : 30),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: isCompact ? 12 : 11,
                  color: isCompact ? SDSColor.gray800 : SDSColor.gray700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
