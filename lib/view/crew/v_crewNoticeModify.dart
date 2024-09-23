import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewNotice.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CrewNoticeModifyView extends StatelessWidget {

  final CrewNoticeViewModel _crewNoticeViewModel = Get.find<CrewNoticeViewModel>();


  CrewNoticeModifyView() {
    // Get.arguments를 통해 전달받은 Map 데이터를 활용하여 초기화
    Map<String, dynamic> args = Get.arguments;
    int noticeId = args['noticeId'];
    String noticeText = args['noticeText'] ?? '';
    _crewNoticeViewModel.noticeModifyController.text = noticeText;
    _noticeId = noticeId;
  }

  int? _noticeId;

  @override
  Widget build(BuildContext context) {


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
            '공지사항',
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
                '공지사항',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Form(
                key: _crewNoticeViewModel.formKeyNotice,
                child: TextFormField(
                  controller: _crewNoticeViewModel.noticeModifyController,
                  maxLength: 100,  // 최대 100자 제한
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: '공지사항을 입력해 주세요. (최대 100자 이내)',
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
                      return '공지사항을 입력해 주세요.';
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
                  onPressed: () async {
                    if (_crewNoticeViewModel.formKeyNotice.currentState!.validate()) {
                      Get.back();
                      await _crewNoticeViewModel.updateCrewNotice(
                          _noticeId!,
                          _crewNoticeViewModel.noticeModifyController.text
                      );
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
            ],
          ),
        ),
      ),
    );
  }
}
