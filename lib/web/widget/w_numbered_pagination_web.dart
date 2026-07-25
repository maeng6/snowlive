import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 번호식 페이지네이션 바(‹ 1 … n-1 n n+1 … N ›). 중고거래/랭킹 등
/// gotoPage/pageWindow 인터페이스를 갖는 웹 전용 페이지네이션 뷰모델과 함께 쓴다.
class NumberedPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final List<int> pageWindow;
  final ValueChanged<int> onGotoPage;

  const NumberedPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.pageWindow,
    required this.onGotoPage,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        IconButton(
          onPressed: hasPrevious ? () => onGotoPage(currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        if (pageWindow.first > 1) ...[
          _PageNumberButton(label: '1', isActive: false, onTap: () => onGotoPage(1)),
          if (pageWindow.first > 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('…', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400)),
            ),
        ],
        for (final page in pageWindow)
          _PageNumberButton(label: '$page', isActive: page == currentPage, onTap: () => onGotoPage(page)),
        if (pageWindow.last < totalPages) ...[
          if (pageWindow.last < totalPages - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('…', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400)),
            ),
          _PageNumberButton(label: '$totalPages', isActive: false, onTap: () => onGotoPage(totalPages)),
        ],
        IconButton(
          onPressed: hasNext ? () => onGotoPage(currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PageNumberButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? SDSColor.gray900 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: (isActive ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
            fontSize: 14,
            color: isActive ? SDSColor.snowliveWhite : SDSColor.gray700,
          ),
        ),
      ),
    );
  }
}
