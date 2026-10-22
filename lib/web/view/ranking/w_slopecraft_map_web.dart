import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_slope_rush.dart';
import 'package:com.snowlive/web/data/slope_craft_maps_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:flutter/material.dart';

/// 지도 카드 배경.
///
/// 지도 PNG는 **배경이 투명**이고 그려진 지형의 바탕색이 `#D2E4EE`다
/// (phoenix·high1·vivaldi·gonjiam 에셋에서 가장 많이 쓰인 불투명 색을 뽑은 값).
/// 카드도 같은 색으로 깔아야 지도와 카드 사이에 경계선이 보이지 않는다
/// — 그래서 목업의 그라데이션(#DFEAF0→#BCD4E2) 대신 이 단색을 쓴다.
const Color kSlopeCraftMapBackground = Color(0xFFD2E4EE);

/// 마커 한 개 크기(로고 지름).
/// 마커 원 — 앱과 같이 고른 슬로프만 크다(`v_slope_rush.dart`).
const double _kMarkerSize = 24;
const double _kMarkerSizeSelected = 36;

/// 라벨 최대폭(앱과 동일). 넘치면 말줄임.
const double _kMarkerLabelMaxWidth = 38;

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
      // 목업 실측: 카드 640 안에서 상단 바가 600 → 안쪽 여백 20.
      padding: const EdgeInsets.all(20),
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
                      ..._buildMarkers(constraints),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMarkers(BoxConstraints constraints) {
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
      // 고른 마커는 커지므로(24→36) 중심 보정도 그 크기로 해야 제자리에 선다.
      final size = isSelected ? _kMarkerSizeSelected : _kMarkerSize;

      markers.add(
        Positioned(
          left: offset.dx * constraints.maxWidth - size / 2,
          top: offset.dy * constraints.maxHeight - size / 2,
          child: _SlopeMarker(
            label: label,
            leader: leader,
            isSelected: isSelected,
            onTap: () => onSelectSlope(key),
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
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24),
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

/// 슬로프 마커 — 점령 크루 로고(없으면 회색 원) + 슬로프명 라벨.
class _SlopeMarker extends StatelessWidget {
  final String label;
  final SlopeCrew? leader;
  final bool isSelected;
  final VoidCallback onTap;

  const _SlopeMarker({
    required this.label,
    required this.leader,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 로고 없는 크루도 앱처럼 기본 `LIVE CREW` 마크를 쓴다(빈 회색 원 방지).
    final logoUrl = leader == null
        ? ''
        : (crewLogoUrlOf(logoUrl: leader!.crewLogoUrl) ?? '');
    final markerSize = isSelected ? _kMarkerSizeSelected : _kMarkerSize;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 앱과 같이 **고른 슬로프만 크게**(36) 보이고 나머지는 24다.
            Container(
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
                  ? Container(color: SDSColor.gray200)
                  : WebNetworkImage(
                      url: logoUrl,
                      width: markerSize,
                      height: markerSize,
                      isCircle: true,
                    ),
            ),
            const SizedBox(height: 2),
            // 라벨도 앱과 같은 사각 캡슐이다 — 라운드 4 · 1px 테두리 · 옅은 그림자 ·
            // 최대폭 38(긴 크루명은 말줄임). 선택 시 검정 바탕 + 흰 글자.
            Container(
              constraints: const BoxConstraints(
                maxWidth: _kMarkerLabelMaxWidth,
              ),
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
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              child: Text(
                // 아무도 점령하지 않은 슬로프는 앱과 같이 `미점령`(흐린 글자)으로 적는다.
                leader == null ? '미점령' : label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 10,
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
