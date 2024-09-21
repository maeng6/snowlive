import 'dart:io';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OnBoardingCrewMainView extends StatelessWidget {
  OnBoardingCrewMainView({Key? key}) : super(key: key);

  final CrewApplyViewModel _crewApplyViewModel = Get.find<CrewApplyViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  void _showBottomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '라이브크루 시작하기 ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                '이미 존재하는 라이브크루에 참여하시려면 가입하기를,',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff949494),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 3),
              Text(
                '새로운 라이브크루를 만드시려면 생성하기를 선택해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff949494),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.toNamed(AppRoutes.setCrewNameAndResort);
                      },
                      child: Text(
                        '만들기',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        elevation: 0,
                        splashFactory: InkRipple.splashFactory,
                        minimumSize: Size(100, 56),
                        backgroundColor: Color(0xff7C899D),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _crewApplyViewModel.fetchCrewApplyListUser(_userViewModel.user.user_id);
                        print(_crewApplyViewModel.crewApplyList);
                        if(_crewApplyViewModel.crewApplyList.isNotEmpty){
                          Get.toNamed(AppRoutes.crewApplicationUser);
                        } else{
                          Get.toNamed(AppRoutes.searchCrew);
                        }
                      },
                      child: Text(
                        '가입하기',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        elevation: 0,
                        splashFactory: InkRipple.splashFactory,
                        minimumSize: Size(100, 56),
                        backgroundColor: Color(0xFF3D83ED),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ); // 상단 StatusBar 생성
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: (Platform.isAndroid)
            ? Brightness.light
            : Brightness.dark, //ios:dark, android:light
      ),
    );

    final double _statusBarSize = MediaQuery.of(context).padding.top;
    final Size _size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
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
              backgroundColor: Colors.white,
              elevation: 0.0,
              centerTitle: false,
              titleSpacing: 0,
              title: Text(
                '',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 23),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              height: _size.height - _statusBarSize - 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/imgs/liveCrew/img_liveCrew_title_onboarding.png',
                          scale: 1,
                          width: 100,
                        ),
                        SizedBox(height: 30),
                        Text(
                          '또 하나의 즐거움',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '라이브크루와 함께해요',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '라이브크루를 통해 다양한 사람들과 교류하며',
                          style: TextStyle(
                            color: Color(0xff949494),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          '더욱 특별한 경험을 만들어보세요.',
                          style: TextStyle(
                            color: Color(0xff949494),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 50),
                        Image.asset(
                          'assets/imgs/liveCrew/img_liveCrew_image_onboarding.png',
                          scale: 1,
                          width: 400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: ElevatedButton(
                onPressed: () => _showBottomModal(context),
                child: Text(
                  '라이브크루 시작하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  elevation: 0,
                  splashFactory: InkRipple.splashFactory,
                  minimumSize: Size(200, 56),
                  backgroundColor: Color(0xff3D83ED),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
