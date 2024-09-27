import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_setCrew.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CrewDescriptionView extends StatelessWidget {

  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final SetCrewViewModel _setCrewViewModel = Get.find<SetCrewViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    // 기존에 작성된 소개글이 있다면 해당 내용으로 초기화
    _crewDetailViewModel.textEditingController_description.text = _crewDetailViewModel.description ?? '';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();  // 화면을 탭하면 키보드가 내려가도록 처리
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: SDSColor.snowliveWhite,
          foregroundColor: SDSColor.snowliveWhite,
          surfaceTintColor: SDSColor.snowliveWhite,
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Get.back();
            },
          ),
          title: Text(
            '크루 소개글',
            style: TextStyle(
                color: SDSColor.snowliveBlack,
                fontSize: 18
            ),
          ),
          elevation: 0,
          toolbarHeight: 44,
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 10, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '소개글',
                  style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
                      color: SDSColor.gray900
                  ),
                ),
              ),
              SizedBox(height: 8),
              Form(
                key: _crewDetailViewModel.formKey_description,
                child: Container(
                  height: 200,
                  child: TextFormField(
                    controller: _crewDetailViewModel.textEditingController_description,
                    textAlignVertical: TextAlignVertical.top,
                    cursorColor: SDSColor.snowliveBlue,
                    cursorHeight: 16,
                    cursorWidth: 2,
                    maxLines: null,
                    minLines: null,
                    expands: true,
                    maxLength: 200,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: SDSTextStyle.regular.copyWith(fontSize: 15),
                    strutStyle: StrutStyle(fontSize: 14, leading: 0),
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorMaxLines: 2,
                      errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                      labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                      hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                      hintText: '크루 소개글을 입력해 주세요. (최대 50자 이내)',
                      hintMaxLines: 20,
                      contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
                      fillColor: SDSColor.gray50,
                      hoverColor: SDSColor.snowliveBlue,
                      filled: true,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '소개글을 입력해 주세요.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async{
                      if (_crewDetailViewModel.formKey_description.currentState!.validate()) {
                        CustomFullScreenDialog.showDialog();
                        await _setCrewViewModel.updateCrewDetails(_userViewModel.user.crew_id);
                        CustomFullScreenDialog.cancelDialog();
                        Get.back();
                      }
                    },
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      elevation: 0,
                      splashFactory: InkRipple.splashFactory,
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: SDSColor.snowliveBlue,
                    ),
                    child: Text(
                      '완료',
                      style: SDSTextStyle.bold
                          .copyWith(color: SDSColor.snowliveWhite, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
