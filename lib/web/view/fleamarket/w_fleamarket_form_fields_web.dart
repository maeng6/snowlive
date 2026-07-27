import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 게시글 올리기/수정 폼에서 공통으로 쓰는 선택지 목록.
/// (모바일 lib/widget/w_category_main_fleamarket.dart 등과 동일한 값)
const List<String> kFleamarketCategoryMainList = ['스키', '스노보드'];
const List<String> kFleamarketCategorySubSkiList = ['플레이트', '바인딩', '부츠', '의류', '기타'];
const List<String> kFleamarketCategorySubBoardList = ['데크', '바인딩', '부츠', '의류', '기타'];
const List<String> kFleamarketTradeMethodList = ['직거래', '택배거래', '무관'];
final List<String> kFleamarketTradeSpotList = FleamarketCategory_spot.values
    .where((e) => e != FleamarketCategory_spot.total)
    .map((e) => e.korean)
    .toList();

const String kFleamarketCategoryMainPlaceholder = '상위 카테고리';
const String kFleamarketCategorySubPlaceholder = '하위 카테고리';
const String kFleamarketTradeMethodPlaceholder = '거래방법 선택';
const String kFleamarketTradeSpotPlaceholder = '거래장소 선택';

/// 섹션 라벨(제목/제품명/가격 등 필드 위 작은 굵은 텍스트).
class FleamarketFormLabel extends StatelessWidget {
  final String text;
  const FleamarketFormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SDSSpacing.sm),
      child: Text(text, style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900)),
    );
  }
}

/// 라벨 + 텍스트 입력 필드 한 세트.
class FleamarketFormTextField extends StatelessWidget {
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

  const FleamarketFormTextField({
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
        FleamarketFormLabel(label),
        height != null ? SizedBox(height: height, child: field) : field,
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(helperText!, style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400)),
        ],
      ],
    );
  }
}

/// 라벨 + 탭하면 바텀시트가 열리는 드롭다운형 필드(카테고리/거래방법/거래장소 공용).
class FleamarketFormDropdownField<T> extends StatefulWidget {
  final String label;
  final String value;
  final String placeholder;
  final List<T> values;
  final String Function(T value) labelOf;
  final void Function(T value) onSelected;

  /// 열기 전 검사. false를 리턴하면 열지 않는다(안내 문구는 이 콜백에서 띄운다).
  /// 상세 카테고리처럼 선행 선택이 필요한 필드에 쓴다.
  final bool Function()? canOpen;

  const FleamarketFormDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.values,
    required this.labelOf,
    required this.onSelected,
    this.canOpen,
  });

  @override
  State<FleamarketFormDropdownField<T>> createState() => _FleamarketFormDropdownFieldState<T>();
}

class _FleamarketFormDropdownFieldState<T> extends State<FleamarketFormDropdownField<T>> {
  /// 드롭다운이 열린 채 폼이 스크롤돼도 필드를 따라가게 하는 링크.
  final LayerLink _link = LayerLink();

  /// 필드 박스의 위치/폭을 재려면 라벨을 제외한 입력 박스만의 컨텍스트가 필요하다.
  final GlobalKey _boxKey = GlobalKey();

  Future<void> _open() async {
    if (widget.canOpen != null && !widget.canOpen!()) return;

    // 데스크탑은 필드 아래에 붙는 드롭다운(목업), 태블릿/모바일은 딤 처리된 바텀시트.
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
        FleamarketFormLabel(widget.label),
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
class FleamarketFormTwoColumnRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const FleamarketFormTwoColumnRow({super.key, required this.left, required this.right});

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
