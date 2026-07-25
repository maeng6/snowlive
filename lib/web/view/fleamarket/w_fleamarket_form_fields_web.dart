import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketList.dart';
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
class FleamarketFormDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;

  const FleamarketFormDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value != placeholder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FleamarketFormLabel(label),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
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
      ],
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
