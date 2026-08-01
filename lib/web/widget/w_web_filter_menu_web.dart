import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';

/// 값 목록 하나를 고르는 공용 메뉴.
///
/// 데스크탑은 앵커에 붙는 드롭다운(딤 없음), 태블릿/모바일은 화면 전체를 덮는 딤 패널.
/// 이 "폭에 따라 형태가 갈리는" 규칙이 지금 필터 pill(중고거래·랭킹), 정렬 pill,
/// 검색바 안의 검색범위 버튼처럼 **트리거 모양이 다른 여러 곳**에서 필요해서,
/// 트리거 위젯과 분리해 여기 모아둔다. 트리거의 생김새는 호출자가 정한다.
///
/// 데스크탑 패널과 딤 패널은 정렬·항목 스타일이 실제로 달라서 하나로 합치지 않고
/// 브레이크포인트로 고른다.
Future<T?> showWebFilterMenu<T>({
  required BuildContext context,
  required LayerLink link,
  required List<T> values,
  required String Function(T value) labelOf,

  /// 회색 헤더 문구. null이면 헤더를 그리지 않는다.
  String? title,

  /// 딤 패널에도 헤더를 그릴지. **기본값 false로 두는 게 중요하다** —
  /// true로 통일하면 기존 중고거래·랭킹 바텀시트에 없던 헤더가 생겨 회귀가 된다.
  bool showTitleInSheet = false,

  /// 딤 패널에서 태블릿은 화면 중앙, 모바일은 하단에 붙인다(목업).
  /// 기존 호출자(중고거래·랭킹)는 항상 하단이었으므로 기본값은 false.
  bool centerSheetOnTablet = false,
}) {
  if (context.isDesktop) {
    return showWebAnchoredDropdown<T>(
      context: context,
      link: link,
      builder: (_, close, anchorWidth) => WebFilterDropdownPanel<T>(
        title: title,
        values: values,
        labelOf: labelOf,
        onPick: close,
        minWidth: anchorWidth,
      ),
    );
  }

  return showWebFilterSheet<T>(
    context: context,
    values: values,
    labelOf: labelOf,
    title: title,
    showTitle: showTitleInSheet,
    centerOnTablet: centerSheetOnTablet,
  );
}

/// 딤 패널(바텀시트) 단독 버전. 앵커가 없어서 데스크탑에서도 드롭다운을 띄울 수
/// 없는 자리(전체폭 폼 선택 필드 등)에서 쓴다.
Future<T?> showWebFilterSheet<T>({
  required BuildContext context,
  required List<T> values,
  required String Function(T value) labelOf,
  String? title,
  bool showTitle = false,
  bool centerOnTablet = false,
}) {
  final isTablet = context.screenType == WebScreenType.tablet;
  return showWebOverlayModal<T>(
    context: context,
    alignment: (centerOnTablet && isTablet) ? Alignment.center : Alignment.bottomCenter,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null && showTitle)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      title,
                      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
                    ),
                  ),
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
}

/// 데스크탑 앵커 드롭다운 패널. 헤더 한 줄(선택) + 항목 목록.
class WebFilterDropdownPanel<T> extends StatelessWidget {
  final String? title;
  final List<T> values;
  final String Function(T value) labelOf;
  final void Function(T value) onPick;

  /// 최소한 앵커 폭만큼은 확보하고, 항목 라벨이 길면 그만큼 넓어진다.
  final double minWidth;

  const WebFilterDropdownPanel({
    super.key,
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
          // 항목이 많아도 짧은 뷰포트에서는 스크롤된다.
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        // 항목 중 가장 긴 라벨에 폭을 맞춘다(고정폭이면 긴 라벨이 잘린다).
        child: IntrinsicWidth(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Text(
                      title!,
                      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
                    ),
                  )
                else
                  const SizedBox(height: 8),
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

/// "텍스트 + ⌄" 형태의 드롭다운 트리거. pill이 아니라 텍스트로 보여야 하는 자리
/// (검색바 안의 검색범위, 모바일 카테고리 선택)에 쓴다.
///
/// 자기 자신에만 [LayerLink]를 감는다 — 부모 컨테이너(예: 검색바 전체)에 감으면
/// 앵커 폭이 커져서 드롭다운이 엉뚱한 위치에 뜬다.
class WebDropdownTextButton<T> extends StatefulWidget {
  final String label;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;
  final String? title;
  final bool showTitleInSheet;
  final bool centerSheetOnTablet;
  final TextStyle? labelStyle;
  final double iconSize;

  /// 라벨 길이가 바뀔 때 옆에 있는 입력창 폭이 흔들리지 않게 고정폭을 줄 수 있다.
  final double? labelWidth;

  /// 메뉴를 열기 직전에 호출한다. 검색바의 최근검색어 오버레이처럼 다른 오버레이가
  /// 열려 있으면 투명 배리어가 서로를 삼키므로, 여기서 먼저 닫는 용도.
  final VoidCallback? onBeforeOpen;

  const WebDropdownTextButton({
    super.key,
    required this.label,
    required this.values,
    required this.labelOf,
    required this.onSelected,
    this.title,
    this.showTitleInSheet = false,
    this.centerSheetOnTablet = false,
    this.labelStyle,
    this.iconSize = 18,
    this.labelWidth,
    this.onBeforeOpen,
  });

  @override
  State<WebDropdownTextButton<T>> createState() => _WebDropdownTextButtonState<T>();
}

class _WebDropdownTextButtonState<T> extends State<WebDropdownTextButton<T>> {
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    widget.onBeforeOpen?.call();
    final selected = await showWebFilterMenu<T>(
      context: context,
      link: _link,
      values: widget.values,
      labelOf: widget.labelOf,
      title: widget.title,
      showTitleInSheet: widget.showTitleInSheet,
      centerSheetOnTablet: widget.centerSheetOnTablet,
    );
    if (selected != null) widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.labelStyle ??
        SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900);
    final labelText = Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);

    return CompositedTransformTarget(
      link: _link,
      // ElevatedButton은 최소 높이 48을 강제해서 44px 검색바 안에서 넘친다.
      // InkWell도 쓰지 않는다 — 검색바처럼 TextField와 같은 Row에 놓이면 탭이
      // 잡히지 않는 경우가 있었다. behavior: opaque인 GestureDetector가 자기 박스
      // 전체에서 탭을 확실히 받는다.
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _open,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.labelWidth != null)
                  SizedBox(width: widget.labelWidth, child: labelText)
                else
                  labelText,
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down, size: widget.iconSize, color: style.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
