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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '성별과 주 종목을 모두 선택해 주세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5,),
            Text(
              '원활한 서비스 이용을 위해 꼭 알려주세요!',
              style: TextStyle(
                  fontSize: 12,
                  color: SDSColor.gray500
              ),
            ),
            SizedBox(height: 16),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _genderCategoryViewModel.selectGender('여자');
                    },
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _genderCategoryViewModel.selectedGender.value == '여자'
                              ? SDSColor.snowliveBlue
                              : SDSColor.gray500,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        color: _genderCategoryViewModel.selectedGender.value == '여자'
                            ? SDSColor.snowliveBlue
                            : SDSColor.snowliveWhite,
                      ),
                      child: Center(
                        child: Text(
                          '여자',
                          style: TextStyle(
                            color: _genderCategoryViewModel.selectedGender.value == '여자'
                                ? Colors.white
                                : SDSColor.gray500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _genderCategoryViewModel.selectGender('남자');
                    },
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration:  BoxDecoration(
                        border: Border.all(
                          color: _genderCategoryViewModel.selectedGender.value == '남자'
                              ? SDSColor.snowliveBlue
                              : SDSColor.gray500,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        color: _genderCategoryViewModel.selectedGender.value == '남자'
                            ? SDSColor.snowliveBlue
                            : SDSColor.snowliveWhite,
                      ),
                      child: Center(
                        child: Text(
                          '남자',
                          style: TextStyle(
                            color: _genderCategoryViewModel.selectedGender.value == '남자'
                                ? Colors.white
                                : SDSColor.gray500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            )),
            SizedBox(height: 20,),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _genderCategoryViewModel.selectCategory('스키');
                    },
                    child: Container(
                      height: 40, // 버튼 높이를 줄여줍니다.
                      margin: EdgeInsets.symmetric(horizontal: 8), // 버튼 간격 조정
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _genderCategoryViewModel.selectedCategory.value == '스키'
                              ? SDSColor.snowliveBlue
                              : SDSColor.gray500,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        color: _genderCategoryViewModel.selectedCategory.value == '스키'
                            ? SDSColor.snowliveBlue
                            : SDSColor.snowliveWhite,
                      ),
                      child: Center(
                        child: Text(
                          '스키',
                          style: TextStyle(
                            color: _genderCategoryViewModel.selectedCategory.value == '스키'
                                ? Colors.white
                                : SDSColor.gray500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _genderCategoryViewModel.selectCategory('스노보드');
                    },
                    child: Container(
                      height: 40, // 버튼 높이를 줄여줍니다.
                      margin: EdgeInsets.symmetric(horizontal: 8), // 버튼 간격 조정
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _genderCategoryViewModel.selectedCategory.value == '스노보드'
                              ? SDSColor.snowliveBlue
                              : SDSColor.gray500,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        color: _genderCategoryViewModel.selectedCategory.value == '스노보드'
                            ? SDSColor.snowliveBlue
                            : SDSColor.snowliveWhite,
                      ),
                      child: Center(
                        child: Text(
                          '스노보드',
                          style: TextStyle(
                            color: _genderCategoryViewModel.selectedCategory.value == '스노보드'
                                ? Colors.white
                                : SDSColor.gray500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
            SizedBox(height: 24),
            Container(
              width: _size.width,
              height: 48,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
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
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: SDSColor.snowliveWhite,
                      colorText: SDSColor.snowliveBlack,
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
          ],
        ),
      ),
    );
  }
}
