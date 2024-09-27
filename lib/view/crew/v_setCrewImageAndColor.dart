import 'dart:io';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/model/m_crewList.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:com.snowlive/viewmodel/vm_mainHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import 'package:com.snowlive/viewmodel/crew/vm_setCrew.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:image_picker/image_picker.dart';

class SetCrewImageAndColorView extends StatelessWidget {
  final SetCrewViewModel _setCrewViewModel = Get.find<SetCrewViewModel>();
  final CrewApplyViewModel _crewApplyViewModel = Get.find<CrewApplyViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final MainHomeViewModel _mainHomeViewModel = Get.find<MainHomeViewModel>();


  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Scaffold(
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
                  Navigator.pop(context);
                  _setCrewViewModel.resetImageAndColor(); // 이미지와 색상만 초기화
                },
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: false,
              titleSpacing: 0,
            ),
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                ),
                child: Container(
                  height: _size.height - 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '라이브크루 이미지와 대표 색상을\n설정해주세요.',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 22,
                                color: SDSColor.gray900
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '이미지와 대표 색상은 크루 설정에서 변경할 수 있어요.',
                            style: SDSTextStyle.regular.copyWith(
                              color: SDSColor.gray500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Center(
                          child: Column(
                            children: [
                              Obx(
                                    () => Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: _setCrewViewModel.currentColorBackground.value,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: (_setCrewViewModel.croppedFile != null)
                                      ? Stack(
                                    children: [
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: ExtendedImage.file(
                                            File(_setCrewViewModel.croppedFile!.path),
                                            fit: BoxFit.cover, // 배경을 모두 채우도록 설정
                                            cacheRawData: true,
                                            enableLoadState: true,
                                            width: 80, // 배경 안에 들어가도록 크기 조정
                                            height: 80,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 24,
                                        right: 24,
                                        child: GestureDetector(
                                          onTap: () {
                                            _setCrewViewModel.resetImage();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: SDSColor.snowliveBlack.withOpacity(0.7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              weight: 2,
                                              color: SDSColor.snowliveWhite,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                      :Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: ExtendedImage.network(
                                        '${crewDefaultLogoUrl['${_setCrewViewModel.colorToHex(_setCrewViewModel.currentColor.value)}']}',
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(16),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        cacheRawData: true,
                                        enableLoadState: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    builder: (context) => SafeArea(
                                      child: Container(
                                        height: 203,
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 20),
                                                child: Container(
                                                  height: 4,
                                                  width: 36,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: SDSColor.gray200,
                                                  ),
                                                ),
                                              ),
                                              Text('이미지 업로드 방법',
                                                style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                '이미지를 등록하지 않으면 기본 이미지로 설정됩니다.',
                                                textAlign: TextAlign.center,
                                                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                                              ),
                                              SizedBox(height: 40),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        _setCrewViewModel.uploadImage(ImageSource.camera);
                                                      },
                                                      child: Text(
                                                        '사진 촬영',
                                                        style: SDSTextStyle.bold.copyWith(
                                                          color: SDSColor.snowliveWhite,
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
                                                        _setCrewViewModel.uploadImage(ImageSource.gallery);
                                                      },
                                                      child: Text(
                                                        '앨범에서 선택',
                                                        style: SDSTextStyle.bold.copyWith(
                                                          color: SDSColor.snowliveWhite,
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
                                                        backgroundColor: SDSColor.snowliveBlue,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  '이미지 직접 등록',
                                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                  minimumSize: Size(36, 32),
                                  backgroundColor: SDSColor.snowliveWhite,
                                  side: BorderSide(
                                      color: SDSColor.gray200
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '크루 대표 색상 선택하기',
                              style: SDSTextStyle.regular.copyWith(color: SDSColor.gray500, fontSize: 13),
                            ),
                            SizedBox(height: 12),
                            Container(
                              width: 220,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: crewColorList.sublist(0, 5).map((color) {
                                      return GestureDetector(
                                        onTap: () {
                                          _setCrewViewModel.selectColor(color!);
                                        },
                                        child: Container(
                                          height: 24,
                                          width: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: color,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: crewColorList.sublist(5).map((color) {
                                      return GestureDetector(
                                        onTap: () {
                                          _setCrewViewModel.selectColor(color!);
                                        },
                                        child: Container(
                                          height: 24,
                                          width: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: color,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
              child: Obx(() => ElevatedButton(
                onPressed: () async {
                  if(_crewApplyViewModel.crewApplyList.isNotEmpty){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text('현재 가입 신청중인 크루가 있어요',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),
                              textAlign: TextAlign.center
                          ),
                          content: Text('크루를 생성하시면\n자동으로 신청이 취소됩니다',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: SDSColor.gray600
                              ),
                              textAlign: TextAlign.center
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                CustomFullScreenDialog.showDialog();
                                for (var crew in _crewApplyViewModel.crewApplyList) {
                                  await _crewApplyViewModel.deleteCrewApplication(
                                    _userViewModel.user.user_id, // 사용자 ID
                                    crew.crewId!, // 크루 ID
                                    _userViewModel.user.user_id, // 신청한 사용자 ID
                                  );
                                }
                                await _setCrewViewModel.createCrew();
                                CustomFullScreenDialog.cancelDialog();
                                Get.toNamed(AppRoutes.crewMain);
                              },
                              child: Text('크루 생성하기',
                                style: TextStyle(
                                    color: SDSColor.snowliveWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: SDSColor.snowliveBlue, // 신청 취소 버튼 색상
                                minimumSize: Size(double.infinity, 48), // 버튼 크기
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // 팝업 닫기
                              },
                              child: Text('돌아가기',
                                style: TextStyle(
                                    color: SDSColor.snowliveBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                minimumSize: Size(double.infinity, 48), // 버튼 크기
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else{
                    CustomFullScreenDialog.showDialog();
                    await _setCrewViewModel.createCrew();
                    CustomFullScreenDialog.cancelDialog();
                    Get.until((route) => Get.currentRoute == AppRoutes.mainHome); // mainHome까지 pop
                    _mainHomeViewModel.changePage(4); // 모어탭 활성화
                    Get.toNamed(AppRoutes.crewMain);  // crewMain 화면으로 이동
                  }
                },
                child: Text(
                  '완료',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  elevation: 0,
                  splashFactory: InkRipple.splashFactory,
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: _setCrewViewModel.currentColor.value,
                ),
              )),
            ),
          ),
        ),
      ],
    );
  }
}
