import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';

/// 카테고리/거래장소 선택 시트. 모바일 fleamarket 목록 화면의 바텀시트 스타일을
/// 웹에 이식하되, 딤이 GNB까지 덮도록 showWebOverlayModal 위에 올린다.
Future<void> showFleamarketFilterSheet<T>(
  BuildContext context, {
  required List<T> values,
  required String Function(T value) labelOf,
  required void Function(T value) onSelected,
}) async {
  final selected = await showWebOverlayModal<T>(
    context: context,
    alignment: Alignment.bottomCenter,
    padding: const EdgeInsets.all(16),
    builder: (_, close) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      // ListTile은 Material 조상을 요구한다. 시트 표면을 Material로 만들어
      // 배경색과 잉크를 같은 레이어에서 처리한다.
      child: Material(
        color: SDSColor.snowliveWhite,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                for (final value in values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Center(
                      child: Text(
                        labelOf(value),
                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                      ),
                    ),
                    onTap: () => close(value),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  // 배경 탭으로 닫으면 null — 선택했을 때만 콜백을 태운다.
  if (selected != null) onSelected(selected);
}

/// 필터 pill 버튼(전체 카테고리/전체 거래장소): 선택값이 기본값이 아니면 색 반전.
class FleamarketFilterPill<T> extends StatefulWidget {
  final String label;
  final bool isActive;

  /// 드롭다운 헤더 문구(데스크탑 전용). 목업의 '카테고리'/'거래장소'.
  final String title;
  final List<T> values;
  final String Function(T value) labelOf;
  final void Function(T value) onSelected;

  const FleamarketFilterPill({
    super.key,
    required this.label,
    required this.isActive,
    required this.title,
    required this.values,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  State<FleamarketFilterPill<T>> createState() => _FleamarketFilterPillState<T>();
}

class _FleamarketFilterPillState<T> extends State<FleamarketFilterPill<T>> {
  /// 드롭다운이 열린 채 페이지가 스크롤돼도 pill을 따라가게 하는 링크.
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    // 데스크탑은 pill 아래에 붙는 드롭다운(목업), 태블릿/모바일은 딤 처리된 바텀시트.
    if (!context.isDesktop) {
      await showFleamarketFilterSheet<T>(
        context,
        values: widget.values,
        labelOf: widget.labelOf,
        onSelected: widget.onSelected,
      );
      return;
    }

    final selected = await showWebAnchoredDropdown<T>(
      context: context,
      link: _link,
      builder: (_, close, anchorWidth) => _FilterDropdownPanel<T>(
        title: widget.title,
        values: widget.values,
        labelOf: widget.labelOf,
        onPick: close,
        minWidth: anchorWidth,
      ),
    );
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
    return ElevatedButton(
      onPressed: _open,
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        side: BorderSide(width: 1, color: isActive ? SDSColor.gray900 : SDSColor.gray100),
        backgroundColor: isActive ? SDSColor.gray900 : SDSColor.snowliveWhite,
        foregroundColor: isActive ? SDSColor.snowliveWhite : SDSColor.gray900,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      // ElevatedButton.icon은 아이콘을 라벨 앞에 붙인다. 앱 디자인은 라벨 뒤이므로
      // Row로 직접 배치한다.
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
          // 모바일 앱 필터와 같은 원형 화살표 배지 에셋을 그대로 쓴다.
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

/// 데스크탑 필터 드롭다운 패널. 헤더 한 줄 + 항목 목록(목업).
class _FilterDropdownPanel<T> extends StatelessWidget {
  final String title;
  final List<T> values;
  final String Function(T value) labelOf;
  final void Function(T value) onPick;

  /// 목업처럼 최소한 pill 폭만큼은 확보하고, 항목이 길면 그만큼 넓어진다.
  final double minWidth;

  const _FilterDropdownPanel({
    required this.title,
    required this.values,
    required this.labelOf,
    required this.onPick,
    required this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shadowColor: Colors.black26,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: 280,
          // 항목이 많은 거래장소도 대부분 한 번에 들어가되, 짧은 뷰포트에선 스크롤된다.
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        // 항목 중 가장 긴 라벨에 폭을 맞춘다(고정폭이면 '무주덕유산리조트' 같은 게 잘린다).
        child: IntrinsicWidth(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Text(title, style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
                ),
                for (final value in values)
                  InkWell(
                    onTap: () => onPick(value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      child: Text(
                        labelOf(value),
                        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
