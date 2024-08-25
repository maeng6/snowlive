import 'dart:io';
import 'package:com.snowlive/screens/LiveCrew/CreateOnboarding/v_FirstPage_createCrew.dart';
import 'package:com.snowlive/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/controller/public/vm_imageController.dart';
import '../../../controller/liveCrew/vm_liveCrewModelController.dart';
import '../../../controller/user/vm_userModelController.dart';
import '../../../model_2/m_liveCrewModel.dart';
import '../../../widget/w_fullScreenDialog.dart';

class SetCrewImage extends StatefulWidget {
  SetCrewImage({Key? key, required this.crewName, required this.baseResort}) : super(key: key);

  final String crewName;
  final int baseResort;

  @override
  State<SetCrewImage> createState() => _SetCrewImageState();
}

class _SetCrewImageState extends State<SetCrewImage> {

  //TODO: Dependency Injection********************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection********************************************

  bool crewImage = false;
  XFile? _imageFile;
  XFile? _croppedFile;
  Color? currentColor = crewColorList[6];
  Color? currentColor_background = Color(0xffF1F1F3);

  void changeColor(Color color) => setState(() => currentColor = color);

  String colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2).toUpperCase();
  }

  @override
  void initState() {
    _imageFile = null;
    _croppedFile = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ImageController(), permanent: true);
    ImageController _imageController = Get.find<ImageController>();

    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ); // 상단 StatusBar 생성
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white, // Color for Android
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness:
            (Platform.isAndroid)
                ?Brightness.light
                :Brightness.dark //ios:dark, android:light
        ));
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
              padding: EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16, bottom: _statusBarSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text(
                        '라이브크루 이미지와 대표 색상을\n설정해주세요.',
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            height: 1.3),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    '이미지와 대표 색상은 크루 설정에서 변경할 수 있어요.',
                    style: TextStyle(
                        color: Color(0xff949494),
                        fontSize: 13,
                        height: 1.5
                    ),
                  ),
                  SizedBox(
                    height: _size.height * 1/10,
                  ),
                  Column(
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: currentColor_background,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          width: 150,
                          height: 150,
                          child: _croppedFile != null
                              ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 0,
                                  blurRadius: 16,
                                  offset: Offset(0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            width: 80,
                            height: 80,
                            child: ExtendedImage.file(
                              File(_croppedFile!.path),
                              fit: BoxFit.fill,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              cacheRawData: true,
                              enableLoadState: true,
                            ),
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
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => SafeArea(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      '이미지 업로드 방법',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      '이미지를 등록하지 않으면',
                                      style: TextStyle(
                                          fontSize: 13,
                                        color: Color(0xFF949494)
                                      ),
                                    ),
                                    Text(
                                      '기본 이미지로 설정됩니다.',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF949494)
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            CustomFullScreenDialog.showDialog();
                                            try {
                                              _imageFile = await _imageController.getSingleImage(ImageSource.camera);
                                              _croppedFile = await _imageController.cropImage(_imageFile);
                                              CustomFullScreenDialog.cancelDialog();
                                              crewImage = true;
                                              setState(() {});
                                            } catch (e) {
                                              CustomFullScreenDialog.cancelDialog();
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: Text('사진 촬영',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFFFFF)
                                          ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size(160, 45), // 버튼의 최소 크기 설정
                                            backgroundColor: SDSColor.gray700,
                                          ),
                                        ), // 버튼 간 간격을 줄이기 위해 간격 설정
                                        ElevatedButton(
                                          onPressed: () async {
                                            CustomFullScreenDialog.showDialog();
                                            try {
                                              _imageFile = await _imageController.getSingleImage(ImageSource.gallery);
                                              _croppedFile = await _imageController.cropImage(_imageFile);
                                              CustomFullScreenDialog.cancelDialog();
                                              crewImage = true;
                                              setState(() {});
                                            } catch (e) {
                                              CustomFullScreenDialog.cancelDialog();
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: Text('앨범에서 선택',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFFFFF)
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size(160, 45), // 버튼의 최소 크기 설정
                                            backgroundColor: SDSColor.snowliveBlue,
                                          ),
                                        ),
                                      ],
                                    ),


                                  ],
                                ),
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

                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        '크루 대표 색상 선택하기',
                        style: TextStyle(
                            color: Color(0xff111111),
                            fontSize: 13,
                            height: 1.5
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
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
                                      setState(() {
                                        currentColor = color;
                                        currentColor_background = color!.withOpacity(0.2);
                                      });
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
                                      setState(() {
                                        currentColor = color;
                                        currentColor_background = color!.withOpacity(0.2);
                                      });
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
                onPressed: () async {
                  CustomFullScreenDialog.showDialog();
                  String _profileImageUrl = '';
                  if (_croppedFile != null) {
                    _profileImageUrl = await _imageController.setNewImage_Crew(newImage: _croppedFile!, crewID: widget.crewName);
                  }
                  CustomFullScreenDialog.cancelDialog();
                  print(colorToHex(currentColor!));

                  await _liveCrewModelController.createCrewDoc(
                      uid: 57346,
                      crewName: widget.crewName,
                      resortNum: widget.baseResort,
                      crewImageUrl: _profileImageUrl,
                      crewColor: colorToHex(currentColor!),
                  );
                  print('크루등록 성공쓰');

                  if(_liveCrewModelController.memberUidList!.contains(_userModelController.uid)){
                    Get.to(() => CrewDetailPage_screen());
                  }
                  Get.to(()=> FirstPage_createCrew());

                },
                child: Text(
                  '다음',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                style: TextButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                    elevation: 0,
                    splashFactory: InkRipple.splashFactory,
                    minimumSize: Size(100, 56),
                    backgroundColor: currentColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
