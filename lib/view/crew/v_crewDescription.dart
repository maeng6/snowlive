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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '소개글',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Form(
                key: _crewDetailViewModel.formKey_description,
                child: TextFormField(
                  controller: _crewDetailViewModel.textEditingController_description,
                  maxLength: 50,  // 최대 50자 제한
                  maxLines: 5,  // 소개글이므로 여러 줄로 입력 가능
                  decoration: InputDecoration(
                    hintText: '크루 소개글을 입력해 주세요. (최대 50자 이내)',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,  // 테두리 제거
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '소개글을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
              ),
              Spacer(),
              SizedBox(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '완료',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30,)
            ],
          ),
        ),
      ),
    );
  }
}
