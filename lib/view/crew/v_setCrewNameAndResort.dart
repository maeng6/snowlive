import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/crew/vm_setCrew.dart';
import 'package:com.snowlive/widget/w_favoriteResort.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class SetCrewNameAndResortView extends StatelessWidget {
  // 뷰모델 선언
  final SetCrewViewModel _setCrewViewModel = Get.find<SetCrewViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(58),
          child: AppBar(
            leading: GestureDetector(
              child: Icon(Icons.arrow_back),
              onTap: () {
                _setCrewViewModel.resetAll();
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: _statusBarSize + 58,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '라이브크루 정보를 입력해 주세요.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '라이브크루 생성을 위해 아래 정보를 입력해 주세요.',
                style: TextStyle(
                  color: Color(0xff949494),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 30),
              Text(
                '크루명',
                style: TextStyle(
                  color: Color(0xff111111),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 10),
              Form(
                key: _setCrewViewModel.formKey,
                child: Stack(
                  children: [
                    TextFormField(
                      controller: _setCrewViewModel.textEditingController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp("[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣]"),
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: '이름을 입력해 주세요(최대 10자 이내)',
                        filled: true,
                        fillColor: Color(0xFFEFEFEF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) => _setCrewViewModel.validateCrewName(val),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: TextButton(
                        onPressed: (_setCrewViewModel.crewName.isNotEmpty && !_setCrewViewModel.isCrewNameChecked)
                            ? () async {
                          CustomFullScreenDialog.showDialog();
                          await _setCrewViewModel.checkCrewName();
                          if (!_setCrewViewModel.isCrewNameChecked) {
                            Get.snackbar(
                              '이미 존재하는 크루명입니다',
                              '다른 크루명을 입력해 주세요',
                              margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: SDSColor.snowliveWhite.withOpacity(0.2),
                              colorText: SDSColor.snowliveBlack,
                              duration: Duration(milliseconds: 3000),
                            );
                            print('이미 존재하는 크루명입니다');
                          }
                        }
                            : null,
                        child: Obx(() => Text(
                          _setCrewViewModel.isCrewNameChecked ? '검사완료' : '중복검사',
                          style: TextStyle(
                            color: (_setCrewViewModel.crewName.isNotEmpty && !_setCrewViewModel.isCrewNameChecked)
                                ? SDSColor.snowliveBlue
                                : SDSColor.gray400,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Text(
                '크루명은 최초 설정 후 수정 불가합니다.',
                style: TextStyle(
                  color: Color(0xff949494),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 30),
              Text(
                '베이스 스키장',
                style: TextStyle(
                  color: Color(0xff111111),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  int? selectedIndex = await showModalBottomSheet<int>(
                    constraints: BoxConstraints(
                      maxHeight: _size.height - _statusBarSize - 44,
                    ),
                    backgroundColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true,
                    enableDrag: true,
                    isDismissible: true,
                    builder: (context) => FavoriteResortWidget(),
                  );
                  if (selectedIndex != null) {
                    _setCrewViewModel.selectResort(selectedIndex);
                  }
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: SDSColor.gray50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _setCrewViewModel.selectedResortName.isEmpty
                            ? '자주가는 스키장 선택'
                            : _setCrewViewModel.selectedResortName,
                        style: SDSTextStyle.regular.copyWith(
                          color: _setCrewViewModel.selectedResortName.isEmpty
                              ? SDSColor.gray400
                              : SDSColor.gray900,
                          fontSize: 14,
                        ),
                      ),
                      ExtendedImage.asset(
                        'assets/imgs/icons/icon_dropdown.png',
                        fit: BoxFit.cover,
                        width: 20,
                      ),
                    ],
                  )),
                ),
              ),
              SizedBox(height: 5),
              Text(
                '베이스 스키장은 최초 설정 후 수정 불가합니다.',
                style: TextStyle(
                  color: Color(0xff949494),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return ElevatedButton(
              onPressed: _setCrewViewModel.isNextButtonEnabled.value
                  ? () {
                if (_setCrewViewModel.formKey.currentState!.validate()) {
                  _setCrewViewModel.goToNextStep(); // 다음 단계로 이동
                }
              }
                  : null,
              child: _setCrewViewModel.isLoading.value
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                '다음',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _setCrewViewModel.isNextButtonEnabled.value
                    ? SDSColor.snowliveBlue
                    : SDSColor.gray300,
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
