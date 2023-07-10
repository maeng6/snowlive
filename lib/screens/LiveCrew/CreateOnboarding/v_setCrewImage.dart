import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snowlive3/controller/vm_imageController.dart';
import 'package:snowlive3/screens/LiveCrew/CreateOnboarding/v_setCrewResort.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../model/m_liveCrewModel.dart';
import '../../../widget/w_fullScreenDialog.dart';

class SetCrewImage extends StatefulWidget {
  SetCrewImage({Key? key,required this.crewName}) : super(key: key);

  String? _profileImageUrl;
  var crewName;
  var crewColor;

  @override
  State<SetCrewImage> createState() => _SetCrewImageState();
}

class _SetCrewImageState extends State<SetCrewImage> {
  bool crewImage = false;
  XFile? _imageFile;
  XFile? _croppedFile;
  Color? currentColor = Color(0xff3D83ED);
  Color? currentColor_background = Color(0xffF1F1F3);
  void changeColor(Color color) => setState(() => currentColor = color);

  @override
  void initState() {
    _imageFile = null;
    _croppedFile = null;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //TODO : ****************************************************************
    Get.put(ImageController(), permanent: true);
    ImageController _imageController = Get.find<ImageController>();
    //TODO : ****************************************************************

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
    return Scaffold(
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
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Image.asset(
                'assets/imgs/icons/icon_onb_indicator3.png',
                scale: 4,
                width: 56,
                height: 8,
              ),
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '',
              style: GoogleFonts.notoSans(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w900,
                  fontSize: 23),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16, bottom: _statusBarSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  '라이브 크루의 로고 이미지와\n대표 컬러를 설정해주세요.',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '이미지와 색상은 설정 메뉴에서 언제든지 변경하실 수 있습니다.',
              style: TextStyle(
                color: Color(0xff949494),
                fontSize: 14,
              ),
            ),
            SizedBox(
              height: _size.height * 0.07,
            ),
            (crewImage && _imageFile!=null) //이 값이 true이면 이미지업로드가 된 상태이므로, 미리보기 띄움
                ? Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      height: 249,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  '업로드 방법을 선택해주세요.',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111111)),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  '프로필 이미지를 나중에 설정 하시려면,\n기본 이미지로 설정해주세요.',
                                  style: TextStyle(
                                    color: Color(0xff666666),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      CustomFullScreenDialog.showDialog();
                                      try {
                                        _imageFile = await _imageController.getSingleImage(ImageSource.camera);
                                        _croppedFile = await _imageController.cropImage(_imageFile);
                                        CustomFullScreenDialog.cancelDialog();
                                        crewImage = true;
                                        setState(() {});
                                        Navigator.pop(context);
                                      } catch (e) {
                                        CustomFullScreenDialog.cancelDialog();
                                      }
                                    },
                                    child: Text(
                                      '사진 촬영',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                        splashFactory:
                                        InkRipple.splashFactory,
                                        elevation: 0,
                                        minimumSize: Size(100, 56),
                                        backgroundColor:
                                        Color(0xff555555),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0)),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      CustomFullScreenDialog.showDialog();
                                      try {
                                        _imageFile = await _imageController.getSingleImage(ImageSource.gallery);
                                        _croppedFile = await _imageController.cropImage(_imageFile);
                                        CustomFullScreenDialog.cancelDialog();
                                        crewImage = true;
                                        setState(() {});
                                        Navigator.pop(context);
                                      } catch (e) {
                                        crewImage = false;
                                        CustomFullScreenDialog.cancelDialog();
                                      }
                                    },
                                    child: Text(
                                      '앨범에서 선택',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                        splashFactory:
                                        InkRipple.splashFactory,
                                        elevation: 0,
                                        minimumSize: Size(100, 56),
                                        backgroundColor: currentColor,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  );
                },
                child: Stack(children: [

                  Container(
                    decoration: BoxDecoration(
                      color: currentColor_background,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    padding: EdgeInsets.all(80),
                    width: _size.width*2/3,
                    height: _size.width*2/3,
                    child: Container(
                      width: 147,
                      height: 147,
                      child: ExtendedImage.file(
                        File(_croppedFile!.path),
                        fit: BoxFit.fill,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        cacheRawData: true,
                        enableLoadState: true,
                      ),
                    )
                  ),
                  Positioned(
                      bottom: 180,
                      right: 70,
                      child: GestureDetector(
                        child: ExtendedImage.asset(
                            'assets/imgs/icons/icon_profile_delete.png',
                            scale: 4),
                        onTap: () {
                          crewImage = false;
                          _croppedFile = null;
                          setState(() {});
                        },
                      )),
                ]),
              ),
            )
                : Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      height: 249,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  '업로드 방법을 선택해주세요.',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111111)),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  '로고 이미지를 나중에 설정 하시려면,\n기본 이미지로 설정해주세요.',
                                  style: TextStyle(
                                    color: Color(0xff666666),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      CustomFullScreenDialog.showDialog();
                                      try {
                                        _imageFile =
                                        await _imageController
                                            .getSingleImage(
                                            ImageSource.camera);
                                        _croppedFile =
                                        await _imageController.cropImage(_imageFile);
                                        CustomFullScreenDialog
                                            .cancelDialog();
                                        crewImage = true;
                                        setState(() {});
                                        Navigator.pop(context);
                                      } catch (e) {
                                        CustomFullScreenDialog
                                            .cancelDialog();
                                      }
                                    },
                                    child: Text(
                                      '사진 촬영',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                        splashFactory:
                                        InkRipple.splashFactory,
                                        elevation: 0,
                                        minimumSize: Size(100, 56),
                                        backgroundColor:
                                        Color(0xff555555),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0)),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      CustomFullScreenDialog.showDialog();
                                      try {
                                        _imageFile =
                                        await _imageController.getSingleImage(ImageSource.gallery);
                                        _croppedFile = await _imageController.cropImage(_imageFile);
                                        CustomFullScreenDialog.cancelDialog();
                                        crewImage = true;
                                        setState(() {});
                                        Navigator.pop(context);
                                      } catch (e) {
                                        CustomFullScreenDialog
                                            .cancelDialog();
                                      }
                                    },
                                    child: Text(
                                      '앨범에서 선택',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                        splashFactory:
                                        InkRipple.splashFactory,
                                        elevation: 0,
                                        minimumSize: Size(100, 56),
                                        backgroundColor: currentColor,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  );
                },
                child: Stack(children: [
                  Container(
                      decoration: BoxDecoration(
                        color: currentColor_background,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: EdgeInsets.all(80),
                      width: _size.width*2/3,
                      height: _size.width*2/3,
                      child: Container(
                        width: 147,
                        height: 147,
                        child: ExtendedImage.asset(
                          'assets/imgs/profile/img_profile_default_.png',
                          fit: BoxFit.fill,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          cacheRawData: true,
                          enableLoadState: true,
                        ),
                      )
                  ),
                  Positioned(
                      bottom: 75,
                      right: 70,
                      child: GestureDetector(
                        child: ExtendedImage.asset(
                            'assets/imgs/icons/icon_profile_add.png',
                            scale: 4),
                        onTap: () {
                          crewImage = false;
                          _croppedFile = null;
                          setState(() {});
                        },
                      )),
                ]),//이 컨테이너가 이미지업로드 전에 보여주는 아이콘임
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Container(
                height: 100,
                width: _size.width*2/3,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentColor = crewColorList[0];
                                  currentColor_background = crewColorList[0];
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crewColorList[0],
                                ),
                              ),
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentColor = crewColorList[1];
                                  currentColor_background = crewColorList[1];

                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crewColorList[1],
                                ),
                              ),
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentColor = crewColorList[2];
                                  currentColor_background = crewColorList[2];
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crewColorList[2],
                                ),
                              ),
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentColor = crewColorList[3];
                                  currentColor_background = crewColorList[3];
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crewColorList[3],
                                ),
                              ),
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentColor = crewColorList[4];
                                  currentColor_background = crewColorList[4];
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crewColorList[4],
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentColor = crewColorList[5];
                                  currentColor_background = crewColorList[5];
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crewColorList[5],
                                ),
                              ),
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentColor = crewColorList[6];
                                  currentColor_background = crewColorList[6];
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crewColorList[6],
                                ),
                              ),
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentColor = crewColorList[7];
                                  currentColor_background = crewColorList[7];
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crewColorList[7],
                                ),
                              ),
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentColor = crewColorList[8];
                                  currentColor_background = crewColorList[8];
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crewColorList[8],
                                ),
                              ),
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  currentColor = crewColorList[9];
                                  currentColor_background = crewColorList[9];
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: crewColorList[9],
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: SizedBox()),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_croppedFile != null) {
                    CustomFullScreenDialog.showDialog();
                    String _profileImageUrl =
                    await _imageController.setNewImage_Crew(newImage: _croppedFile!, crewID: widget.crewName);
                    CustomFullScreenDialog.cancelDialog();
                    Get.to(() => CrewFavoriteResort(crewName: widget.crewName, CrewImageUrl: _profileImageUrl, crewColor: currentColor,));
                  } else {
                    Get.snackbar('이미지를 선택해주세요.', '다음에 설정하시려면 기본 이미지로 설정해주세요.',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: EdgeInsets.only(
                            right: 20, left: 20, bottom: 12),
                        backgroundColor: Colors.black87,
                        colorText: Colors.white,
                        duration: Duration(milliseconds: 3000));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '다음',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                style: TextButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                    elevation: 0,
                    splashFactory: InkRipple.splashFactory,
                    minimumSize: Size(1000, 56),
                    backgroundColor: currentColor),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Get.to(() => CrewFavoriteResort(crewName: widget.crewName, CrewImageUrl: '', crewColor: currentColor,));
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '기본 이미지로 설정',
                    style: TextStyle(fontFamily: 'NotoSansKR', color: Color(0xff949494), fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                ),
                style: TextButton.styleFrom(
                    elevation: 0,
                    splashFactory: InkRipple.splashFactory,
                    minimumSize: Size(1000, 41),
                    backgroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
