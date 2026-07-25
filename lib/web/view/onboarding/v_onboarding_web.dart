import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_onboarding_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 모바일 w_favoriteResort.dart와 동일하게 4번(에덴밸리리조트)은 선택지에서 제외.
const List<int> kOnboardingSelectableResortIndexes = [0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12];

class OnboardingViewWeb extends StatelessWidget {
  const OnboardingViewWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<OnboardingViewModelWeb>();

    return Scaffold(
      backgroundColor: SDSColor.gray50,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(SDSSpacing.xl),
            margin: const EdgeInsets.symmetric(vertical: SDSSpacing.xl),
            decoration: BoxDecoration(
              color: SDSColor.snowliveWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: SDSColor.gray200, blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('프로필을 설정해주세요', style: SDSTextStyle.extraBold.copyWith(fontSize: 20, color: SDSColor.gray900)),
                const SizedBox(height: SDSSpacing.sm),
                Text('닉네임과 자주가는 스키장을 알려주세요.', style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500)),
                const SizedBox(height: SDSSpacing.lg),

                // 닉네임 + 중복검사
                Obx(() => Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextField(
                          controller: vm.nicknameController,
                          maxLength: 10,
                          style: SDSTextStyle.regular.copyWith(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: '닉네임을 입력해 주세요 (최대 10자)',
                            counterText: '',
                            filled: true,
                            fillColor: SDSColor.gray50,
                            contentPadding: const EdgeInsets.only(left: 12, right: 64, top: 14, bottom: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TextButton(
                            onPressed: (vm.nicknameController.text.trim().isEmpty ||
                                    vm.isCheckedDisplayName ||
                                    vm.isCheckingDisplayName)
                                ? null
                                : () => vm.checkDisplayName(),
                            child: vm.isCheckingDisplayName
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(
                                    vm.isCheckedDisplayName ? '확인완료' : '중복확인',
                                    style: SDSTextStyle.bold.copyWith(
                                      fontSize: 13,
                                      color: vm.isCheckedDisplayName ? SDSColor.gray500 : SDSColor.snowliveBlue,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: SDSSpacing.md),

                // 리조트 선택
                Obx(() => InkWell(
                      onTap: () => showFleamarketFilterSheet<int>(
                        context,
                        values: kOnboardingSelectableResortIndexes,
                        labelOf: (i) => resortNameList[i] ?? '',
                        onSelected: (i) => vm.selectResort(i),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                vm.hasResortSelected ? (resortNameList[vm.selectedResortIndex] ?? '') : '자주가는 스키장을 선택해주세요',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 15,
                                  color: vm.hasResortSelected ? SDSColor.gray900 : SDSColor.gray400,
                                ),
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, color: SDSColor.gray500),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: SDSSpacing.lg),

                Obx(() => vm.status == WebOnboardingStatus.error
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: SDSSpacing.md),
                        child: Text(vm.errorMessage, style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.red)),
                      )
                    : const SizedBox.shrink()),

                Obx(() => ElevatedButton(
                      onPressed: vm.canSubmit ? () => vm.submit() : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SDSColor.snowliveBlue,
                        disabledBackgroundColor: SDSColor.gray200,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: vm.status == WebOnboardingStatus.submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('시작하기', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite)),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
