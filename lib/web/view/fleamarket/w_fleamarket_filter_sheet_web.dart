import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 카테고리/거래장소 선택 시트. 모바일 fleamarket 목록 화면의
/// showModalBottomSheet + 리스트 스타일을 그대로 웹에 이식한다.
Future<void> showFleamarketFilterSheet<T>(
  BuildContext context, {
  required List<T> values,
  required String Function(T value) labelOf,
  required void Function(T value) onSelected,
}) {
  return showModalBottomSheet(
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 360),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
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
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onSelected(value);
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// 필터 pill 버튼(전체 카테고리/전체 거래장소): 선택값이 기본값이 아니면 색 반전.
class FleamarketFilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const FleamarketFilterPill({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.keyboard_arrow_down, size: 16, color: isActive ? SDSColor.snowliveWhite : SDSColor.gray900),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        side: BorderSide(width: 1, color: isActive ? SDSColor.gray900 : SDSColor.gray100),
        backgroundColor: isActive ? SDSColor.gray900 : SDSColor.snowliveWhite,
        foregroundColor: isActive ? SDSColor.snowliveWhite : SDSColor.gray900,
        elevation: 0,
        textStyle: SDSTextStyle.bold.copyWith(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }
}
