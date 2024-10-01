import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_setGenderAndCategory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenderAndCategoryPopup extends StatelessWidget {

  final GenderCategoryViewModel _genderCategoryViewModel = Get.find<GenderCategoryViewModel>();

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: SDSColor.snowliveWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '성별과 주 종목을 선택해 주세요',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(
                      color: SDSColor.gray900,
                      fontSize: 16
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Text(
                  '원활한 서비스 이용을 위해 선택 후 선택 완료를 눌러주세요.',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.regular.copyWith(
                    color: SDSColor.gray500,
                    fontSize: 14,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('성별 선택', style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.gray900
                      ),),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _genderCategoryViewModel.selectGender('여자');
                        },
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: _genderCategoryViewModel.selectedGender.value == '여자'
                                  ? 1.5 : 1,
                              color: _genderCategoryViewModel.selectedGender.value == '여자'
                                  ? SDSColor.snowliveBlue
                                  : SDSColor.gray200,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            color: _genderCategoryViewModel.selectedGender.value == '여자'
                                ? SDSColor.snowliveWhite
                                : SDSColor.snowliveWhite,
                          ),
                          child: Center(
                            child: Text(
                              '여자',
                              style: SDSTextStyle.bold.copyWith(
                                fontSize: 14,
                                color: _genderCategoryViewModel.selectedGender.value == '여자'
                                    ? SDSColor.snowliveBlue
                                    : SDSColor.gray900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _genderCategoryViewModel.selectGender('남자');
                        },
                        child: Container(
                          height: 36,
                          decoration:  BoxDecoration(
                            border: Border.all(
                              width: _genderCategoryViewModel.selectedGender.value == '남자'
                                  ? 1.5 : 1,
                              color: _genderCategoryViewModel.selectedGender.value == '남자'
                                  ? SDSColor.snowliveBlue
                                  : SDSColor.gray200,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            color: _genderCategoryViewModel.selectedGender.value == '남자'
                                ? SDSColor.snowliveWhite
                                : SDSColor.snowliveWhite,
                          ),
                          child: Center(
                            child: Text(
                              '남자',
                              style: SDSTextStyle.bold.copyWith(
                                fontSize: 14,
                                color: _genderCategoryViewModel.selectedGender.value == '남자'
                                    ? SDSColor.snowliveBlue
                                    : SDSColor.gray900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('주 종목 선택', style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.gray900
                      ),),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _genderCategoryViewModel.selectCategory('스키');
                        },
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: _genderCategoryViewModel.selectedCategory.value == '스키'
                                  ? 1.5 : 1,
                              color: _genderCategoryViewModel.selectedCategory.value == '스키'
                                  ? SDSColor.snowliveBlue
                                  : SDSColor.gray200,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            color: _genderCategoryViewModel.selectedCategory.value == '스키'
                                ? SDSColor.snowliveWhite
                                : SDSColor.snowliveWhite,
                          ),
                          child: Center(
                            child: Text(
                              '스키',
                              style: SDSTextStyle.bold.copyWith(
                                color: _genderCategoryViewModel.selectedCategory.value == '스키'
                                    ? SDSColor.snowliveBlue
                                    : SDSColor.gray900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _genderCategoryViewModel.selectCategory('스노보드');
                        },
                        child: Container(
                          height: 36, // 버튼 높이를 줄여줍니다.
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: _genderCategoryViewModel.selectedCategory.value == '스노보드'
                                  ? 1.5 : 1,
                              color: _genderCategoryViewModel.selectedCategory.value == '스노보드'
                                  ? SDSColor.snowliveBlue
                                  : SDSColor.gray200,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            color: _genderCategoryViewModel.selectedCategory.value == '스노보드'
                                ? SDSColor.snowliveWhite
                                : SDSColor.snowliveWhite,
                          ),
                          child: Center(
                            child: Text(
                              '스노보드',
                              style: SDSTextStyle.bold.copyWith(
                                color: _genderCategoryViewModel.selectedCategory.value == '스노보드'
                                    ? SDSColor.snowliveBlue
                                    : SDSColor.gray900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
                SizedBox(height: 40),

              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Container(
              width: _size.width,
              height: 48,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: SDSColor.snowliveBlue
              ),
              child: TextButton(
                onPressed: () {
                  if (_genderCategoryViewModel.isSelectionComplete()) {
                    Get.back(result: _genderCategoryViewModel.getSelectionResult());
                  } else {
                    Get.snackbar(
                      "알림",
                      "성별과 종목을 모두 선택해주세요.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: SDSColor.snowliveBlack.withOpacity(0.7),
                      colorText: SDSColor.snowliveWhite,
                    );
                  }
                },
                child: Text(
                  '선택 완료',
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 16,
                    color: SDSColor.snowliveWhite,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
