import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final isMobile = screenType == WebScreenType.mobile;
    final isDesktop = screenType == WebScreenType.desktop &&
        MediaQuery.sizeOf(context).width >= _metricsMinWidth;

    final card = Container(
      decoration: BoxDecoration(
        color: SDSColor.blue50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.lg, vertical: 18),
      child: isDesktop ? _buildDesktopRow() : _buildCompactRow(),
    );

    // 모바일은 링크 줄이 카드 밖 아래로 내려간다(목업).
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          card,
          const SizedBox(height: SDSSpacing.md),
          _HomeWeatherLinks(resort: widget.resort),
          if (_isExpanded) ...[
            const SizedBox(height: SDSSpacing.md),
            _buildMetrics(),
          ],
        ],
      );
    }

    if (isDesktop) {
      return Row(
        children: [
          Flexible(child: card),
          const SizedBox(width: SDSSpacing.lg),
          _HomeWeatherLinks(resort: widget.resort),
        ],
      );
    }

    // 태블릿: 카드 + 링크가 한 줄, 펼친 지표는 아래 줄.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: card),
            const SizedBox(width: SDSSpacing.md),
            _HomeWeatherLinks(resort: widget.resort),
          ],
        ),
        if (_isExpanded) ...[
          const SizedBox(height: SDSSpacing.md),
          _buildMetrics(),
        ],
      ],
    );
  }

  Widget _buildDesktopRow() {
    return Row(
      children: [
        _buildResortBlock(),
        const SizedBox(width: SDSSpacing.lg),
        _buildTemp(),
        const SizedBox(width: SDSSpacing.lg),
        _divider(),
        const SizedBox(width: SDSSpacing.lg),
        Flexible(child: _buildMetrics()),
      ],
    );
  }

  Widget _buildCompactRow() {
    return Row(
      children: [
        Expanded(child: _buildResortBlock()),
        _buildTemp(),
        const SizedBox(width: SDSSpacing.sm),
        // 목업의 `+` 칩 — 누르면 바람·습도·강수·최저/최고를 펼친다.
        _PlusChip(
          isExpanded: _isExpanded,
          onTap: () => setState(() => _isExpanded = !_isExpanded),
        ),
      ],
    );
  }

  Widget _buildResortBlock() {
    final resort = widget.resort;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ResortDropdown(
          label: resort?.resortName ?? '스키장 선택',
          onSelected: widget.onResortSelected,
        ),
        const SizedBox(height: 2),
        Text(
          homeWeatherDateLabel(DateTime.now()),
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
        ),
      ],
    );
  }

  Widget _buildTemp() {
    final weather = widget.weather;
    final icon = homeWeatherIconAsset(
      pty: '${weather['pty'] ?? '0'}',
      sky: '${weather['sky'] ?? '1'}',
      now: DateTime.now(),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          homeTempLabel(weather['temp']),
          style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('°', style: SDSTextStyle.regular.copyWith(fontSize: 20, color: SDSColor.gray900)),
        ),
        const SizedBox(width: SDSSpacing.sm),
        Image.asset(icon, width: 32, height: 32),
      ],
    );
  }

  Widget _buildMetrics() {
    final weather = widget.weather;
    final max = homeTempLabel(weather['maxTemp']);
    final min = homeTempLabel(weather['minTemp']);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Metric(label: '바람', value: '${weather['wind'] ?? '-'}', unit: 'M/S'),
        _Metric(label: '습도', value: '${weather['wet'] ?? '-'}', unit: '%'),
        _Metric(label: '강수', value: '${weather['rain'] ?? '0'}', unit: 'MM'),
        _Metric(label: '최저/최고', value: '$min / $max', unit: ''),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 28, color: SDSColor.blue100);
}

/// 리조트 선택 트리거. 앵커 드롭다운은 **트리거만** 감싸야 한다
/// (상위 Row를 감싸면 메뉴 위치 계산이 깨져 `BoxConstraints ... NOT NORMALIZED`가 난다).
class _ResortDropdown extends StatefulWidget {
  final String label;
  final ValueChanged<ResortModel> onSelected;

  const _ResortDropdown({required this.label, required this.onSelected});

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
    // `BoxConstraints ... NOT NORMALIZED`가 난다 — 슬로프크래프트에서 겪은 사고).
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
                style: SDSTextStyle.bold.copyWith(fontSize: 18, color: SDSColor.gray900),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 20, color: SDSColor.gray900),
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

  const _PlusChip({required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            isExpanded ? Icons.remove : Icons.add,
            size: 16,
            color: SDSColor.gray600,
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _Metric({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray500)),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900)),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(unit, style: SDSTextStyle.regular.copyWith(fontSize: 10, color: SDSColor.gray500)),
            ],
          ],
        ),
      ],
    );
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

    return Row(
      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var i = 0; i < links.length; i++) ...[
          if (i > 0) Container(width: 1, height: 28, color: SDSColor.gray100),
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
    );
  }
}

class _QuickLink extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final target = url;
          if (target == null || target.isEmpty) return;
          final uri = Uri.tryParse(target);
          if (uri == null) return;
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : SDSSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                asset,
                width: 28,
                height: 28,
                errorBuilder: (_, __, ___) => const SizedBox(width: 28, height: 28),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                // 좁은 폭에서 라벨이 잘리지 않게 살짝 줄인다(목업은 네 칸 모두 한 줄).
                style: SDSTextStyle.regular.copyWith(
                  fontSize: isCompact ? 11 : 12,
                  color: SDSColor.gray700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
