import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingButtonWithOptions extends StatelessWidget {
  final String selectedOption;
  final Function(String) onOptionSelected;

  FloatingButtonWithOptions(
      {required this.selectedOption, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.black, // 배경을 검정색으로 설정
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(context, '일간'),
          SizedBox(width: 10),
          _buildOption(context, '주간'),
          SizedBox(width: 10),
          _buildOption(context, '누적'),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String option) {
    final isSelected = option == selectedOption;
    return GestureDetector(
      onTap: () => onOptionSelected(option),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.black, // 선택된 옵션의 배경을 흰색으로 설정
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white, // 선택된 옵션의 텍스트 색상 설정
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
