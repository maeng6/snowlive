import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/web/view/onboarding/w_onboarding_profile_image_picker_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_onboarding_web.dart';
import 'package:com.snowlive/web/widget/w_web_form_fields_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// 온보딩에서 고를 수 있는 리조트 index. index 4(에덴밸리리조트)는 제외한다 —
/// 모바일 `w_favoriteResort.dart:58`의 `if (index != 4)`와 같은 규칙이다.
const List<int> kOnboardingSelectableResortIndexes = [0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12];

const double _kProfileCircleSize = 120;
const double _kProfileBadgeSize = 28;

/// 온보딩 2단계 — 프로필 입력(이미지·닉네임·스키장·종목·성별).
class OnboardingProfileStepWeb extends StatelessWidget {
  final OnboardingViewModelWeb vm;

  const OnboardingProfileStepWeb({super.key, required this.vm});

  Future<void> _pickImage(BuildContext context) async {
    final picked = await showOnboardingProfileImagePicker(context);
    if (picked != null) vm.setProfileImage(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: SDSSpacing.md),
        Center(
          child: Obx(() => _ProfileCircle(
                image: vm.profileImage,
                onPick: () => _pickImage(context),
                onRemove: () => vm.setProfileImage(null),
              )),
        ),
        const SizedBox(height: SDSSpacing.xl),
        Obx(() => WebFormTextField(
              label: '닉네임',
              isRequired: true,
              controller: vm.nicknameController,
              hint: '이름을 입력해주세요(최대 10자 이내)',
              maxLength: 10,
              // 앱과 동일하게 공백 입력을 막는다(v_setProfile.dart:267).
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
              errorText: vm.nicknameError,
            )),
        const SizedBox(height: SDSSpacing.md),
        Obx(() => WebFormDropdownField<int>(
              label: '자주가는 스키장',
              isRequired: true,
              value: vm.hasResortSelected
                  ? (resortNameList[vm.selectedResortIndex] ?? '')
                  : '자주가는 스키장을 선택해주세요.',
              placeholder: '자주가는 스키장을 선택해주세요.',
              values: kOnboardingSelectableResortIndexes,
              labelOf: (index) => resortNameList[index] ?? '',
              onSelected: vm.selectResort,
              helperText: '자주가는 스키장의 날씨와 스키장 정보 확인과 그 외 맞춤 서비스를 제공받으실 수 있습니다',
              sheetShowsLabelTitle: true,
              sheetAlignStart: true,
            )),
        const SizedBox(height: SDSSpacing.md),
        // 목업에는 닉네임·스키장에만 `*`가 있지만 4개 모두 없으면 가입이 안 된다
        // (서버가 skiorboard/sex를 blank로 거부한다) → 전부 필수로 표시한다.
        Obx(() => WebFormDropdownField<String>(
              label: '스키를 타시나요? 보드를 타시나요?',
              isRequired: true,
              value: vm.skiOrBoard.isEmpty ? '선택하기' : vm.skiOrBoard,
              placeholder: '선택하기',
              values: kOnboardingSkiOrBoardOptions,
              labelOf: (value) => value,
              onSelected: vm.selectSkiOrBoard,
              sheetShowsLabelTitle: true,
              sheetAlignStart: true,
            )),
        const SizedBox(height: SDSSpacing.md),
        Obx(() => WebFormDropdownField<String>(
              label: '성별은요?',
              isRequired: true,
              value: vm.sex.isEmpty ? '선택하기' : vm.sex,
              placeholder: '선택하기',
              values: kOnboardingSexOptions,
              labelOf: (value) => value,
              onSelected: vm.selectSex,
              sheetShowsLabelTitle: true,
              sheetAlignStart: true,
            )),
        const SizedBox(height: SDSSpacing.xxl),
        Text(
          '입력해주신 정보들은 이후에도 변경이 가능합니다.',
          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
          textAlign: TextAlign.center,
        ),
        Obx(() => vm.errorMessage.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: SDSSpacing.sm),
                child: Text(
                  vm.errorMessage,
                  style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.red),
                  textAlign: TextAlign.center,
                ),
              )),
      ],
    );
  }
}

/// 프로필 원형. 비어 있으면 기본 이미지 + 파란 `+`, 고르면 미리보기 + 검정 `X`.
class _ProfileCircle extends StatelessWidget {
  final XFile? image;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ProfileCircle({required this.image, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;

    return SizedBox(
      width: _kProfileCircleSize + 4,
      height: _kProfileCircleSize + 4,
      child: Stack(
        children: [
          GestureDetector(
            onTap: hasImage ? null : onPick,
            child: ClipOval(
              child: SizedBox(
                width: _kProfileCircleSize,
                height: _kProfileCircleSize,
                child: hasImage
                    // 웹에서 XFile.path는 blob URL이다. dart:io FileImage는 못 쓴다.
                    ? Image.network(image!.path, fit: BoxFit.cover)
                    : Image.asset('assets/imgs/profile/img_profile_default_circle.png',
                        fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: hasImage ? onRemove : onPick,
              child: Container(
                width: _kProfileBadgeSize,
                height: _kProfileBadgeSize,
                decoration: BoxDecoration(
                  color: hasImage ? SDSColor.snowliveBlack : SDSColor.snowliveBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasImage ? Icons.close : Icons.add,
                  size: 18,
                  color: SDSColor.snowliveWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
