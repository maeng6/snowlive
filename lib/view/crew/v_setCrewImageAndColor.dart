import 'dart:io';
import 'package:com.snowlive/model_2/m_liveCrewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import 'package:com.snowlive/viewmodel/vm_setCrew.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:image_picker/image_picker.dart';

class SetCrewImageAndColorView extends StatelessWidget {
  final SetCrewViewModel _setCrewViewModel = Get.find<SetCrewViewModel>();

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
                  _setCrewViewModel.resetImageAndColor(); // 이미지와 색상만 초기화
                  Navigator.pop(context);
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
                        decoration: BoxDecoration(
                          color: _setCrewViewModel.currentColorBackground.value,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        width: 150,
                        height: 150,
                        child: _setCrewViewModel.croppedFile != null
                            ? ExtendedImage.file(
                          File(_setCrewViewModel.croppedFile!.path),
                          fit: BoxFit.fill,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                          cacheRawData: true,
                          enableLoadState: true,
                        )
                            : Center(
                          child: ExtendedImage.asset(
                            'assets/imgs/liveCrew/img_liveCrew_logo_setCrewImage.png',
                            width: 145,
                            height: 145,
                            cacheRawData: true,
                            enableLoadState: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
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
                  SizedBox(height: 40),
                  Text(
                    '크루 대표 색상 선택하기',
                    style: TextStyle(color: Color(0xff111111), fontSize: 13, height: 1.5),
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
                  CustomFullScreenDialog.showDialog();
                  await _setCrewViewModel.createCrew(); // 서버에 크루 생성 요청
                  CustomFullScreenDialog.cancelDialog();
                },
                child: Text(
                  '다음',
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
