import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 웹 글쓰기 폼(중고거래 물건 팔기/수정, 커뮤니티 게시글 작성) 공용 필드 위젯.
///
/// [compact]는 라벨 크기만 바꾼다. 기본(false)은 중고거래 목업의 `bold 14`,
/// true는 커뮤니티 목업·모바일 앱과 같은 `regular 13`.

/// 섹션 라벨(제목/제품명/가격 등 필드 위 텍스트).
class WebFormLabel extends StatelessWidget {
  final String text;
  final bool compact;

  const WebFormLabel(this.text, {super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SDSSpacing.sm),
      child: Text(
        text,
        style: compact
            ? SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray900)
            : SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
      ),
    );
  }
}

/// 라벨 + 텍스트 입력 필드 한 세트.
class WebFormTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int? maxLength;
  final int maxLines;
  final bool expands;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? suffixText;
  final double? height;
  final String? helperText;
  final bool compact;

  const WebFormTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLength,
    this.maxLines = 1,
    this.expands = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.suffixText,
    this.height,
    this.helperText,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: expands ? null : maxLines,
      expands: expands,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      textAlignVertical: expands ? TextAlignVertical.top : null,
      style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
        counterText: '',
        suffixText: suffixText,
        suffixStyle: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
        filled: true,
        fillColor: SDSColor.gray50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WebFormLabel(label, compact: compact),
        height != null ? SizedBox(height: height, child: field) : field,
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(helperText!, style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
        ],
      ],
    );
  }
}

/// 라벨 + 탭하면 선택지가 열리는 드롭다운형 필드.
/// 데스크탑은 필드 바로 아래 앵커 드롭다운(딤 없음), 그 외는 딤 시트다(목업).
class WebFormDropdownField<T> extends StatefulWidget {
  final String label;
  final String value;
  final String placeholder;
  final List<T> values;
  final String Function(T value) labelOf;
  final void Function(T value) onSelected;
  final bool compact;

  /// 태블릿에서 시트를 화면 중앙에 띄울지. 커뮤니티 작성 폼 목업이 중앙 다이얼로그다.
  /// 중고거래 폼은 하단 시트라 기본값(false)을 유지해야 외형이 지금과 같다.
  final bool centerSheetOnTablet;

  /// 열기 전 검사. false를 리턴하면 열지 않는다(안내 문구는 이 콜백에서 띄운다).
  /// 상세 카테고리처럼 선행 선택이 필요한 필드에 쓴다.
  final bool Function()? canOpen;

  const WebFormDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.values,
    required this.labelOf,
    required this.onSelected,
    this.compact = false,
    this.centerSheetOnTablet = false,
    this.canOpen,
  });

  @override
  State<WebFormDropdownField<T>> createState() => _WebFormDropdownFieldState<T>();
}

class _WebFormDropdownFieldState<T> extends State<WebFormDropdownField<T>> {
  /// 드롭다운이 열린 채 폼이 스크롤돼도 필드를 따라가게 하는 링크.
  final LayerLink _link = LayerLink();

  /// 필드 박스의 위치/폭을 재려면 라벨을 제외한 입력 박스만의 컨텍스트가 필요하다.
  final GlobalKey _boxKey = GlobalKey();

  Future<void> _open() async {
    if (widget.canOpen != null && !widget.canOpen!()) return;

    // 데스크탑은 필드 아래에 붙는 드롭다운(목업), 태블릿/모바일은 딤 처리된 시트.
    if (!context.isDesktop) {
      final picked = await showWebFilterSheet<T>(
        context: context,
        values: widget.values,
        labelOf: widget.labelOf,
        centerOnTablet: widget.centerSheetOnTablet,
      );
      // 배경 탭으로 닫으면 null — 선택했을 때만 콜백을 태운다.
      if (picked != null) widget.onSelected(picked);
      return;
    }

    final selected = await showWebAnchoredDropdown<T>(
      context: _boxKey.currentContext!,
      link: _link,
      gap: 4,
      builder: (_, close, anchorWidth) => _FormDropdownPanel<T>(
        values: widget.values,
        labelOf: widget.labelOf,
        onPick: close,
        width: anchorWidth,
      ),
    );
    if (selected != null) widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.value != widget.placeholder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WebFormLabel(widget.label, compact: widget.compact),
        CompositedTransformTarget(
          link: _link,
          child: InkWell(
            key: _boxKey,
            borderRadius: BorderRadius.circular(8),
            onTap: _open,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.value,
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 15,
                        color: isSelected ? SDSColor.gray900 : SDSColor.gray400,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: SDSColor.gray500),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 폼 필드용 드롭다운 패널. 필터 pill과 달리 **필드 폭에 정확히 맞추고** 헤더가 없다(목업).
class _FormDropdownPanel<T> extends StatelessWidget {
  final List<T> values;
  final String Function(T value) labelOf;
  final void Function(T value) onPick;
  final double width;

  const _FormDropdownPanel({
    required this.values,
    required this.labelOf,
    required this.onPick,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SizedBox(
        width: width,
        child: ConstrainedBox(
          // 거래장소처럼 항목이 많으면 짧은 뷰포트에서 스크롤된다.
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
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

/// 두 필드를 화면 크기와 무관하게 항상 좌우로 나란히 배치(레퍼런스 디자인 기준).
class WebFormTwoColumnRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const WebFormTwoColumnRow({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: SDSSpacing.md),
        Expanded(child: right),
      ],
    );
  }
}
