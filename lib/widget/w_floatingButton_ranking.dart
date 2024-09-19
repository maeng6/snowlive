import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingButtonWithOptions extends StatelessWidget {
  final String selectedOption;
  final Function(String) onOptionSelected;

  FloatingButtonWithOptions(
      {required this.selectedOption, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black, // 배경을 검정색으로 설정
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(0,5)
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(context, '일간'),
          _buildOption(context, '누적'),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String option) {
    final isSelected = option == selectedOption;
    return GestureDetector(
      onTap: (){
        HapticFeedback.lightImpact();
        onOptionSelected(option);
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.black, // 선택된 옵션의 배경을 흰색으로 설정
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              option,
              style: SDSTextStyle.extraBold.copyWith(
                color: isSelected ? Color(0xFF111111) : Colors.white.withOpacity(0.5), // 선택된 옵션의 텍스트 색상 설정
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                fontSize: 14
              ),
            ),
          ],
        ),
      ),
    );
  }
}
