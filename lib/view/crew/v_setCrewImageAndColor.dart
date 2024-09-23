import 'dart:io';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/model/m_crewList.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
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
                  Navigator.pop(context);
                  _setCrewViewModel.resetImageAndColor(); // 이미지와 색상만 초기화
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              centerTitle: false,
              titleSpacing: 0,
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: _statusBarSize + 58,
                left: 16,
                right: 16,
                bottom: _statusBarSize,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '라이브크루 이미지와 대표 색상을\n설정해주세요.',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '이미지와 대표 색상은 크루 설정에서 변경할 수 있어요.',
                    style: TextStyle(color: Color(0xff949494), fontSize: 13, height: 1.5),
                  ),
                  SizedBox(height: _size.height * 0.1),
                  Center(
                    child: Obx(
                          () => Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: _setCrewViewModel.currentColorBackground.value,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0), // 이미지와 배경 사이 간격
                          child:
                              (_setCrewViewModel.croppedFile != null)
                                ?Stack(
                                  children: [
                                    Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
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
                                      top: 20,
                                      right: 20,
                                      child: GestureDetector(
                                        onTap: () {
                                          _setCrewViewModel.resetImage();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: SDSColor.snowliveBlack.withOpacity(0.7),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
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
                                    borderRadius: BorderRadius.circular(20),
                                    child: ExtendedImage.network(
                                      '${crewDefaultLogoUrl['${_setCrewViewModel.colorToHex(_setCrewViewModel.currentColor.value)}']}',
                                      enableMemoryCache: true,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
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
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  margin: EdgeInsets.only(top: 8, bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Text('이미지 업로드 방법', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 16),
                                Text(
                                  '이미지를 등록하지 않으면 기본 이미지로 설정됩니다.',
                                  style: TextStyle(fontSize: 13, color: Color(0xFF949494)),
                                ),
                                SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        _setCrewViewModel.uploadImage(ImageSource.camera);
                                      },
                                      child: Text(
                                        '사진 촬영',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: SDSColor.gray700,
                                        minimumSize: Size(160, 45),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        _setCrewViewModel.uploadImage(ImageSource.gallery);
                                      },
                                      child: Text(
                                        '앨범에서 선택',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: SDSColor.snowliveBlue,
                                        minimumSize: Size(160, 45),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Text(
                        '이미지 직접 등록',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey),
                        ),
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: Text(
                      '크루 대표 색상 선택하기',
                      style: TextStyle(color: Color(0xff111111), fontSize: 13, height: 1.5),
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: Container(
                      height: 120,
                      width: 240,
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
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: crewColorList.sublist(5).map((color) {
                              return GestureDetector(
                                onTap: () {
                                  _setCrewViewModel.selectColor(color!);
                                },
                                child: Container(
                                  height: 32,
                                  width: 32,
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
                                  Get.toNamed(AppRoutes.crewMain);
                                  await _setCrewViewModel.createCrew();
                                  CustomFullScreenDialog.cancelDialog();
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
                    Get.toNamed(AppRoutes.crewMain);
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
                  minimumSize: Size(double.infinity, 56),
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
