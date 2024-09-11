import 'dart:io';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/vm_tos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/screens/v_webPage.dart';
import '../../screens/snowliveDesignStyle.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final TermsOfServiceViewModel _termsOfServiceController = Get.find<TermsOfServiceViewModel>();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: (Platform.isAndroid) ? Brightness.light : Brightness.dark,
      ),
    );

    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
                _termsOfServiceController.goBack();
              },
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/imgs/icons/icon_onboarding.png', scale: 4, width: 72, height: 72),
                    SizedBox(height: 6),
                    Text(
                      '스노우라이브 이용을 위해 \n기본 정보를 입력해 주세요',
                      style: SDSTextStyle.bold.copyWith(fontSize: 24, color: SDSColor.gray900, height: 1.4),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '스노우라이브의 모든 기능을 편리하게 사용하시기 위해\n아래의 약관동의 후 기본 정보를 입력해 주세요.',
                      style: SDSTextStyle.regular.copyWith(color: SDSColor.gray500, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
                Expanded(child: Container()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _termsOfServiceController.toggleAllCheckboxes();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Obx(() => Image.asset(
                              _termsOfServiceController.isEveryItemChecked()
                                  ? 'assets/imgs/icons/icon_check_filled.png'
                                  : 'assets/imgs/icons/icon_check_unfilled.png',
                              height: 24,
                              width: 24,
                            )),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "전체 동의",
                                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Divider(color: SDSColor.gray50, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        children: List.generate(
                          _termsOfServiceController.checkListItems.length,
                              (index) => GestureDetector(
                            onTap: () {
                              _termsOfServiceController.toggleCheckbox(index);
                            },
                            child: Row(
                              children: [
                                Obx(() => Image.asset(
                                  _termsOfServiceController.checkListItems[index]["value"]==true
                                      ? 'assets/imgs/icons/icon_check_filled.png'
                                      : 'assets/imgs/icons/icon_check_unfilled.png',
                                  height: 24,
                                  width: 24,
                                )),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _termsOfServiceController.checkListItems[index]["title"].toString(),
                                    style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Container(
                                    width: 20,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      onPressed: () {
                                        Get.to(() => WebPage(
                                          url: _termsOfServiceController.checkListItems[index]["url"].toString(),
                                        ));
                                      },
                                      icon: Image.asset(
                                        'assets/imgs/icons/icon_arrow_g.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Obx(()=>Center(
                  child: ElevatedButton(
                    onPressed: _termsOfServiceController.isAllChecked()
                        ? () {
                      Get.toNamed(AppRoutes.setProfile);
                    }
                        : null,
                    child: Text(
                      '다음',
                      style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveWhite, fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                      elevation: 0,
                      splashFactory: InkRipple.splashFactory,
                      minimumSize: Size(1000, 48),
                      backgroundColor: _termsOfServiceController.isAllChecked() ? SDSColor.snowliveBlue : SDSColor.gray200,
                    ),
                  ),
                ),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

