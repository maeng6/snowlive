import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_slope_rush.dart';
import 'package:com.snowlive/web/data/slope_craft_maps_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:flutter/material.dart';

/// 지도 카드 배경.
///
/// 지도 PNG는 **배경이 투명**이고 그려진 지형의 바탕색이 `#D2E4EE`다
/// (phoenix·high1·vivaldi·gonjiam 에셋에서 가장 많이 쓰인 불투명 색을 뽑은 값).
/// 카드도 같은 색으로 깔아야 지도와 카드 사이에 경계선이 보이지 않는다
/// — 그래서 목업의 그라데이션(#DFEAF0→#BCD4E2) 대신 이 단색을 쓴다.
const Color kSlopeCraftMapBackground = Color(0xFFD2E4EE);

/// 마커 원 — **웹 목업 실측 36**(82:64717 · 82:65604). 앱은 좁은 화면이라 24지만
/// 웹 지도는 640이라 그 값을 그대로 쓰면 작아 보인다.
/// 고른 슬로프는 앱과 같은 규칙으로 한 단계 크게 그린다(앱 24→36과 같은 +12).
const double _kMarkerSize = 36;
const double _kMarkerSizeSelected = 48;

/// 마우스를 올렸을 때 원만 이만큼 커진다(이름표·위치는 그대로).
/// 이미 고른 마커에는 걸지 않는다 — 선택 표시(크기)와 헷갈린다.
const double _kMarkerHoverGrow = 6;
const Duration _kMarkerHoverDuration = Duration(milliseconds: 120);

/// 미점령 슬로프 마커에 넣는 마크 — `SNOW / LIVE` **2줄 배치**(166x68).
/// 기존 로고는 가로 한 줄(128x22)뿐이라 원 안에서 너무 납작했다. 앱 아이콘
/// (`icon_link_snowlive.png`)에서 파란 판을 걷어내고 글자만 알파로 떠서 만든
/// 에셋이라 색을 자유롭게 입힐 수 있다.
const String _kUnclaimedMarkAsset = 'assets/imgs/logos/snowlive_logo_stacked.png';

/// **마커·이름표**는 지도 폭에 비례한다(기준 PC 640).
/// 목업 실측 — 태블릿 760: 36→42.8 (정확히 비례).
/// 카드 여백·상단 바는 비례하지 않는다(폭별 고정값, 아래 참고).
double slopeCraftMapScale(double mapWidth) => mapWidth / 640;

/// 마커 치수 묶음. **모바일만 앱과 같은 고정값**을 쓴다 —
/// 목업대로 비례(0.536)하면 원 19.3 · 글자 5.4px라 읽히지 않는다(사용자 확정).
class SlopeCraftMarkerStyle {
  final double size;
  final double selectedSize;

  /// 이름표(글자·패딩) 환산값. 모바일은 1.0(앱과 같은 10px).
  final double labelScale;

  const SlopeCraftMarkerStyle({
    required this.size,
    required this.selectedSize,
    required this.labelScale,
  });

  factory SlopeCraftMarkerStyle.of(BuildContext context, double mapWidth) {
    if (context.screenType == WebScreenType.mobile) {
      // 앱 `v_slope_rush.dart`와 같은 값.
      return const SlopeCraftMarkerStyle(
        size: 24,
        selectedSize: 36,
        labelScale: 1,
      );
    }
    final scale = slopeCraftMapScale(mapWidth);
    return SlopeCraftMarkerStyle(
      size: _kMarkerSize * scale,
      selectedSize: _kMarkerSizeSelected * scale,
      labelScale: scale,
    );
  }
}

/// 지도 카드 안쪽 여백 — 목업값이 폭마다 다르다(PC 20 · 태블릿 24 · 모바일 16).
double _mapCardPadding(BuildContext context) {
  switch (context.screenType) {
    case WebScreenType.desktop:
      return 20;
    case WebScreenType.tablet:
      return 24;
    case WebScreenType.mobile:
      return 16;
  }
}

/// 지도 상단 바 좌우 여백 — 모바일만 16(목업 실측), 나머지는 20.
double _mapHeaderPadding(BuildContext context) =>
    context.screenType == WebScreenType.mobile ? 16 : 20;

/// 지도 상단 바 높이 — 폭이 달라도 비슷하다. 모바일 목업이 48이고,
/// 태블릿은 목업 59가 두꺼워 보여 46으로 낮춰 쓴다(사용자 확정).
double _mapHeaderHeight(BuildContext context) {
  switch (context.screenType) {
    case WebScreenType.desktop:
      return 50;
    case WebScreenType.tablet:
      return 46;
    case WebScreenType.mobile:
      return 48;
  }
}

/// 슬로프 점령 지도.
///
/// `{슬러그}_default.png` 위에 선택한 슬로프의 `{슬러그}_{키}.png`를 겹쳐 그리고,
/// 그 위에 슬로프별 마커를 좌표(0~1 비율)로 얹는다 — 앱과 같은 방식이라 에셋·좌표표를
/// 그대로 쓴다([kSlopeCraftMarkerPos]).
class SlopeCraftMapWeb extends StatelessWidget {
  final int resortId;
  final String resortName;
  final List<SlopeRushItem> items;
  final String? selectedSlopeKey;

  /// 슬로프명(별명 우선) → 지도 이미지 키.
  final String? Function(SlopeRushItem item) slopeKeyOf;
  final SlopeCrew? Function(SlopeRushItem item) leaderOf;
  final ValueChanged<String> onSelectSlope;
  final ValueChanged<int> onSelectResort;

  const SlopeCraftMapWeb({
    super.key,
    required this.resortId,
    required this.resortName,
    required this.items,
    required this.selectedSlopeKey,
    required this.slopeKeyOf,
    required this.leaderOf,
    required this.onSelectSlope,
    required this.onSelectResort,
  });

  @override
  Widget build(BuildContext context) {
    final defaultAsset = slopeCraftDefaultAsset(resortId);
    final selectedName = selectedSlopeKey == null
        ? '전체'
        : (slopeCraftSlopeName(resortId, selectedSlopeKey!) ?? '전체');

    return Container(
      decoration: const BoxDecoration(
        color: kSlopeCraftMapBackground,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      padding: EdgeInsets.all(_mapCardPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MapHeader(
            resortId: resortId,
            resortName: resortName,
            selectedLabel: selectedName,
            onSelectResort: onSelectResort,
          ),
          const SizedBox(height: SDSSpacing.md),
          if (defaultAsset == null)
            // 슬러그가 없는 리조트는 지도 에셋이 없다(현재는 전부 있다).
            AspectRatio(
              aspectRatio: kSlopeCraftMapAspect,
              child: Center(
                child: Text(
                  '이 스키장은 지도가 준비되지 않았어요.',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: SDSColor.gray400,
                  ),
                ),
              ),
            )
          else
            AspectRatio(
              aspectRatio: kSlopeCraftMapAspect,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    // 가장자리 마커의 이름표가 잘리지 않게 넘치도록 둔다.
                    clipBehavior: Clip.none,
                    children: [
                      // 배경을 따로 깔지 않는다 — 카드 색이 그대로 비쳐야
                      // 지도와 카드가 한 덩어리로 보인다.
                      Image.asset(defaultAsset, fit: BoxFit.cover),
                      if (selectedSlopeKey != null)
                        Image.asset(
                          slopeCraftSlopeAsset(resortId, selectedSlopeKey!)!,
                          fit: BoxFit.cover,
                          // 좌표표에는 있지만 이미지가 없는 슬로프가 있어도 지도는 살린다.
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ..._buildMarkers(context, constraints),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMarkers(BuildContext context, BoxConstraints constraints) {
    final style = SlopeCraftMarkerStyle.of(context, constraints.maxWidth);
    final positions = kSlopeCraftMarkerPos[resortId] ?? const {};
    if (positions.isEmpty) return const [];

    // 서버 응답을 이미지 키로 색인해 둔다(좌표표 기준으로 마커를 그리므로 없는 슬로프는
    // `미점령`으로 남는다 — 앱과 같은 처리).
    final byKey = <String, SlopeRushItem>{};
    for (final item in items) {
      final key = slopeKeyOf(item);
      if (key != null) byKey[key] = item;
    }

    final markers = <Widget>[];
    positions.forEach((key, offset) {
      final item = byKey[key];
      final leader = item == null ? null : leaderOf(item);
      final label = slopeCraftSlopeName(resortId, key) ?? key;

      final isSelected = selectedSlopeKey == key;
      // 고른 마커는 커지므로 세로 중심 보정도 그 크기로 한다.
      final size = isSelected ? style.selectedSize : style.size;

      markers.add(
        Positioned(
          left: offset.dx * constraints.maxWidth,
          top: offset.dy * constraints.maxHeight - size / 2,
          // ⚠️ 가로는 **자기 폭의 절반**만큼 당겨서 가운데를 맞춘다.
          // 마커 묶음의 폭은 원이 아니라 **이름표**가 정한다(이름표가 더 넓다)
          // → 원 크기로 빼면 이름이 길수록 원이 오른쪽으로 밀린다.
          child: FractionalTranslation(
            translation: const Offset(-0.5, 0),
            child: _SlopeMarker(
            label: label,
            leader: leader,
            style: style,
              isSelected: isSelected,
              onTap: () => onSelectSlope(key),
            ),
          ),
        ),
      );
    });
    return markers;
  }
}

class _MapHeader extends StatelessWidget {
  final int resortId;
  final String resortName;
  final String selectedLabel;
  final ValueChanged<int> onSelectResort;

  const _MapHeader({
    required this.resortId,
    required this.resortName,
    required this.selectedLabel,
    required this.onSelectResort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      // 목업 실측: 바 600x50 · 글자 좌우 24.
      // 바는 폭에 비례하지 않는다 — 글자 크기가 그대로라 같이 줄이면 답답해진다.
      height: _mapHeaderHeight(context),
      padding: EdgeInsets.symmetric(horizontal: _mapHeaderPadding(context)),
      child: Row(
        children: [
          _ResortDropdown(
            resortName: resortName,
            onSelectResort: onSelectResort,
          ),
          const Spacer(),
          Text(
            selectedLabel,
            style: SDSTextStyle.regular.copyWith(
              fontSize: 14,
              color: SDSColor.gray700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 스키장 선택 트리거.
///
/// ⚠️ **트리거만** 담은 위젯이어야 한다 — [showWebFilterMenu]는 넘겨받은 `context`의
/// RenderBox로 앵커 위치·폭을 재기 때문에, 헤더 전체의 context를 넘기면 앵커 폭이
/// 헤더 폭(576)으로 잡혀 패널 최대폭(280)보다 커지고 `BoxConstraints has
/// non-normalized width constraints`로 화면이 죽는다(실측).
class _ResortDropdown extends StatefulWidget {
  final String resortName;
  final ValueChanged<int> onSelectResort;

  const _ResortDropdown({
    required this.resortName,
    required this.onSelectResort,
  });

  @override
  State<_ResortDropdown> createState() => _ResortDropdownState();
}

class _ResortDropdownState extends State<_ResortDropdown> {
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    final selected = await showWebFilterMenu<SlopeCraftResort>(
      context: context,
      link: _link,
      values: kSlopeCraftResorts,
      labelOf: (r) => r.name,
      title: '스키장',
      centerSheetOnTablet: true,
    );
    if (selected == null) return;
    widget.onSelectResort(selected.id);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.resortName,
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 15,
                  color: SDSColor.gray900,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.expand_more, size: 18, color: SDSColor.gray900),
            ],
          ),
        ),
      ),
    );
  }
}

/// 슬로프 마커 — 점령 크루 로고(없으면 스노우라이브 마크) + 슬로프명 라벨.
class _SlopeMarker extends StatefulWidget {
  final String label;
  final SlopeCrew? leader;
  final bool isSelected;
  final VoidCallback onTap;

  /// 폭별 마커 치수(모바일은 앱과 같은 고정값).
  final SlopeCraftMarkerStyle style;

  const _SlopeMarker({
    required this.label,
    required this.leader,
    required this.isSelected,
    required this.onTap,
    required this.style,
  });

  @override
  State<_SlopeMarker> createState() => _SlopeMarkerState();
}

class _SlopeMarkerState extends State<_SlopeMarker> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final leader = widget.leader;
    final isSelected = widget.isSelected;
    final style = widget.style;
    final scale = style.labelScale;

    // 로고 없는 크루도 앱처럼 기본 `LIVE CREW` 마크를 쓴다(빈 회색 원 방지).
    final logoUrl =
        leader == null ? '' : (crewLogoUrlOf(logoUrl: leader.crewLogoUrl) ?? '');

    final baseSize = isSelected ? style.selectedSize : style.size;
    // 이미 고른 마커는 hover로 더 커지지 않는다 — 선택 표시(크기)와 섞이지 않게.
    final canHover = !isSelected;
    final markerSize =
        (_hovered && canHover) ? baseSize + _kMarkerHoverGrow * scale : baseSize;
    // 커질 자리를 미리 잡아 둔다 — 안 그러면 원이 커질 때 중심이 아래로 밀리고
    // 이름표도 따라 내려간다.
    final slotSize =
        canHover ? baseSize + _kMarkerHoverGrow * scale : baseSize;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: slotSize,
              height: slotSize,
              child: Center(
                child: AnimatedContainer(
                  duration: _kMarkerHoverDuration,
                  curve: Curves.easeOut,
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SDSColor.snowliveWhite,
                    border: Border.all(color: SDSColor.snowliveWhite, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: SDSColor.gray900.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: logoUrl.isEmpty
                      // 미점령 슬로프는 흰 원에 스노우라이브 마크를 흐리게 넣는다.
                      ? Center(
                          child: Image.asset(
                            _kUnclaimedMarkAsset,
                            width: markerSize * 0.78,
                            color: SDSColor.gray300,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        )
                      : WebNetworkImage(
                          url: logoUrl,
                          width: markerSize,
                          height: markerSize,
                          isCircle: true,
                        ),
                ),
              ),
            ),
            SizedBox(height: 2 * scale),
            // 라벨도 앱과 같은 사각 캡슐이다 — 라운드 4 · 1px 테두리 · 옅은 그림자 ·
            // 선택 시 검정 바탕 + 흰 글자. 다만 **폭은 제한하지 않는다** — 앱은 좁은
            // 화면이라 38에서 말줄임하지만 웹 지도는 넓어 끝까지 보여준다.
            Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? SDSColor.snowliveBlack
                    : SDSColor.snowliveWhite,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: SDSColor.gray900.withValues(alpha: 0.26),
                ),
                boxShadow: [
                  BoxShadow(
                    color: SDSColor.gray900.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 3 * scale,
                vertical: 1 * scale,
              ),
              child: Text(
                // 아무도 점령하지 않은 슬로프는 앱과 같이 `미점령`(흐린 글자)으로 적는다.
                leader == null ? '미점령' : label,
                maxLines: 1,
                softWrap: false,
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 10 * scale,
                  color: isSelected
                      ? SDSColor.snowliveWhite
                      : (leader == null ? SDSColor.gray500 : SDSColor.gray900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
