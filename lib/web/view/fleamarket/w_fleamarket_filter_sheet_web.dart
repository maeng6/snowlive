import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:flutter/material.dart';

/// 카테고리/거래장소 선택 시트. 앵커 없이 딤 패널만 띄우는 자리(전체폭 폼 선택
/// 필드 등)에서 쓴다. 실제 패널은 공용 [showWebFilterSheet]가 그린다.
Future<void> showFleamarketFilterSheet<T>(
  BuildContext context, {
  required List<T> values,
  required String Function(T value) labelOf,
  required void Function(T value) onSelected,
}) async {
  final selected = await showWebFilterSheet<T>(
    context: context,
    values: values,
    labelOf: labelOf,
  );
  // 배경 탭으로 닫으면 null — 선택했을 때만 콜백을 태운다.
  if (selected != null) onSelected(selected);
}

/// 필터 pill 버튼(전체 카테고리/전체 거래장소): 선택값이 기본값이 아니면 색 반전.
/// hover·드롭다운 열림 동안은 배경을 채워 피드백을 준다
/// (흰 pill: gray50 / 검정 pill: gray800 — 두 상태 동일).
class FleamarketFilterPill<T> extends StatefulWidget {
  final String label;
  final bool isActive;

  /// 드롭다운 헤더 문구(데스크탑 전용). 목업의 '카테고리'/'거래장소'.
  final String title;
  final List<T> values;
  final String Function(T value) labelOf;
  final void Function(T value) onSelected;

  /// 태블릿·모바일 딤 시트에도 헤더를 그릴지. 커뮤니티 정렬 pill만 true다
  /// (목업에 '필터' 헤더가 세 폭 모두 있음). 기존 호출자는 false를 유지해야
  /// 바텀시트 외형이 지금과 같다.
  final bool showTitleInSheet;

  /// 태블릿에서도 PC처럼 pill 아래 앵커 드롭다운을 띄울지.
  /// 중고거래 카테고리/거래장소만 true다(요청) — 랭킹·커뮤니티 등 다른 호출자는
  /// 기존 딤 시트를 유지한다.
  final bool dropdownOnTablet;

  const FleamarketFilterPill({
    super.key,
    required this.label,
    required this.isActive,
    required this.title,
    required this.values,
    required this.labelOf,
    required this.onSelected,
    this.showTitleInSheet = false,
    this.dropdownOnTablet = false,
  });

  @override
  State<FleamarketFilterPill<T>> createState() => _FleamarketFilterPillState<T>();
}

class _FleamarketFilterPillState<T> extends State<FleamarketFilterPill<T>> {
  /// 드롭다운이 열린 채 페이지가 스크롤돼도 pill을 따라가게 하는 링크.
  final LayerLink _link = LayerLink();

  /// 드롭다운(또는 딤 시트)이 떠 있는 동안 true — pill 배경을 채워 표시한다.
  bool _menuOpen = false;

  Future<void> _open() async {
    // 데스크탑은 pill 아래에 붙는 드롭다운, 태블릿/모바일은 딤 처리된 바텀시트.
    // 분기·패널 구현은 공용 showWebFilterMenu가 갖고 있고 여기는 pill 외형만 담당한다.
    setState(() => _menuOpen = true);
    final selected = await showWebFilterMenu<T>(
      context: context,
      link: _link,
      values: widget.values,
      labelOf: widget.labelOf,
      title: widget.title,
      showTitleInSheet: widget.showTitleInSheet,
      dropdownOnTablet: widget.dropdownOnTablet,
    );
    if (mounted) setState(() => _menuOpen = false);
    if (selected != null) widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: _buildPill(),
    );
  }

  Widget _buildPill() {
    final isActive = widget.isActive;

    Color backgroundFor(Set<WidgetState> states) {
      if (isActive) {
        // 검정 pill: 열림·hover 모두 gray800으로 살짝 밝게.
        return (_menuOpen || states.contains(WidgetState.hovered))
            ? SDSColor.gray800
            : SDSColor.gray900;
      }
      // hover·드롭다운 열림 모두 gray50 — 두 상태를 구분하지 않는다.
      if (_menuOpen || states.contains(WidgetState.hovered)) return SDSColor.gray50;
      return SDSColor.snowliveWhite;
    }

    BorderSide sideFor(Set<WidgetState> states) {
      final Color color;
      if (isActive) {
        // 배경과 같은 톤을 유지해 테두리가 따로 보이지 않게 한다.
        color = backgroundFor(states);
      } else {
        color = SDSColor.gray100;
      }
      return BorderSide(width: 1, color: color);
    }

    return ElevatedButton(
      onPressed: _open,
      style: ButtonStyle(
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        // 높이 36 (피그마). 데스크탑 웹은 compact density가 높이를 8px 깎아서
        // 표준 density로 고정해야 실측이 맞는다 — 이전 36도 실제로는 더 낮았다.
        visualDensity: VisualDensity.standard,
        minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
        padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14, vertical: 0)),
        side: WidgetStateProperty.resolveWith(sideFor),
        backgroundColor: WidgetStateProperty.resolveWith(backgroundFor),
        foregroundColor: WidgetStatePropertyAll(
            isActive ? SDSColor.snowliveWhite : SDSColor.gray900),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
      ),
      // ElevatedButton.icon은 아이콘을 라벨 앞에 붙인다. 앱 디자인은 라벨 뒤이므로
      // Row로 직접 배치한다
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: SDSTextStyle.bold.copyWith(
              fontSize: 13,
              color: isActive ? SDSColor.snowliveWhite : SDSColor.gray900,
            ),
          ),
          const SizedBox(width: 6),
          // 모바일 앱 필터와 같은 원형 화살표 배지 에셋을 그대로 쓴다
          // 흰 pill에는 검정 원(흰 화살표), 선택된 검정 pill에는 흰 원(검정 화살표).
          Image.asset(
            isActive ? kFilterPillArrowOnDark : kFilterPillArrowOnLight,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

/// 흰 배경 pill 위에 올리는 검정 원형 화살표(흰 화살표).
const String kFilterPillArrowOnLight = 'assets/imgs/icons/icon_check_round_black.png';

/// 선택되어 검정 배경이 된 pill 위에 올리는 흰 원형 화살표(검정 화살표).
const String kFilterPillArrowOnDark = 'assets/imgs/icons/icon_check_round.png';
