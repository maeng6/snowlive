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
  FocusNode _textfocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () {
        _textfocus.unfocus();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: AppBar(
            leading: GestureDetector(
              child: Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
              onTap: () {
                _setCrewViewModel.resetAll();
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: 10,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '라이브크루 정보를 입력해 주세요.',
                  style: SDSTextStyle.bold.copyWith(
                      fontSize: 22,
                      color: SDSColor.gray900
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '라이브크루 생성을 위해 아래 정보를 입력해 주세요.',
                  style: SDSTextStyle.regular.copyWith(
                    color: SDSColor.gray500,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('크루명', style: SDSTextStyle.regular.copyWith(
                          fontSize: 12,
                          color: SDSColor.gray900
                      ),),
                      Padding(
                        padding: const EdgeInsets.only(left: 2, top: 2),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: SDSColor.red,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Form(
                  key: _setCrewViewModel.formKey,
                  child: Stack(
                    children: [
                      Container(
                        height: 93,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              focusNode: _textfocus,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: SDSColor.snowliveBlue,
                              cursorHeight: 16,
                              cursorWidth: 2,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: SDSTextStyle.regular.copyWith(fontSize: 15),
                              strutStyle: StrutStyle(fontSize: 14, leading: 0),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp("[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣]"),
                                ),
                              ],
                              controller: _setCrewViewModel.textEditingController,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                errorMaxLines: 2,
                                errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                hintText: '크루 이름을 입력해 주세요(최대 10자 이내)',
                                contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 50),
                                filled: true,
                                fillColor: SDSColor.gray50,
                                hoverColor: SDSColor.snowliveBlue,
                                focusColor: SDSColor.snowliveBlue,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: SDSColor.gray50),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              validator: (val) => _setCrewViewModel.validateCrewName(val),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 4, top: 4),
                              child: Text('크루명은 최초 설정 후 수정 불가합니다.',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 12,
                                  color: SDSColor.gray500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 1,
                        child: TextButton(
                          style: ButtonStyle(
                            surfaceTintColor: WidgetStateColor.transparent,
                            backgroundColor: WidgetStateColor.transparent,
                            overlayColor: WidgetStateColor.transparent,
                          ),
                          onPressed: (_setCrewViewModel.crewName.isNotEmpty && !_setCrewViewModel.isCrewNameChecked)
                              ? () async {
                            _textfocus.unfocus();
                            CustomFullScreenDialog.showDialog();
                            await _setCrewViewModel.checkCrewName();
                            if (!_setCrewViewModel.isCrewNameChecked) {
                              Get.snackbar(
                                '이미 존재하는 크루명입니다',
                                '다른 크루명을 입력해 주세요',
                                margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                                snackPosition: SnackPosition.BOTTOM,
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

                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('베이스 스키장', style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: SDSColor.gray900
                      ),),
                      Padding(
                        padding: const EdgeInsets.only(left: 2, top: 2),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: SDSColor.red,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    _textfocus.unfocus();
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
                        Image.asset(
                          'assets/imgs/icons/icon_dropdown.png',
                          fit: BoxFit.cover,
                          width: 20,
                        ),
                      ],
                    )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4, top: 4),
                  child: Text('베이스 스키장은 최초 설정 후 수정 불가합니다.',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
                      color: SDSColor.gray500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
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
                    ? Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      backgroundColor: SDSColor.gray100,
                      color: SDSColor.gray300.withOpacity(0.6),
                    ),
                  ),
                )
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
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
