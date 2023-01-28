import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snowlive3/controller/vm_imageController.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class SetProfileImage_moreTab extends StatefulWidget {
  SetProfileImage_moreTab({Key? key}) : super(key: key);

  @override
  State<SetProfileImage_moreTab> createState() =>
      _SetProfileImage_moreTabState();
}

class _SetProfileImage_moreTabState extends State<SetProfileImage_moreTab> {
  bool profileImage = false;
  XFile? _imageFile;
  bool _isSelected = true;

  @override
  void initState() {
    _imageFile = null;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ); // 상단 StatusBar 생성
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: (Platform.isAndroid)
            ? Brightness.light
            : Brightness.dark //ios:dark, android:light
        ));

    //TODO : ****************************************************************
    Get.put(ImageController(), permanent: true);
    UserModelController _userModelController = Get.find<UserModelController>();
    ImageController _imageController = Get.find<ImageController>();
    //TODO : ****************************************************************

    _isSelected = _userModelController.profileImageUrl!.isNotEmpty;

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
        padding:    EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16, bottom: _statusBarSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  '프로필 이미지를\n선택해 주세요.',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: _size.height * 0.14,
            ),
            (profileImage) //이 값이 true이면 이미지업로드가 된 상태이므로, 미리보기 띄움
                ? Center(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            height: 200,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                              CustomFullScreenDialog
                                                  .cancelDialog();
                                              profileImage = true;
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
                                                  await _imageController
                                                      .getSingleImage(
                                                          ImageSource.gallery);
                                              CustomFullScreenDialog
                                                  .cancelDialog();
                                              profileImage = true;
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
                                              backgroundColor:
                                                  Color(0xff2C97FB),
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
                          width: 160,
                          height: 160,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            backgroundImage: (_imageFile == null)
                                ? null
                                : FileImage(File(_imageFile!.path)),
                          ),
                        ),
                        Positioned(
                            bottom: 13,
                            right: 8,
                            child: GestureDetector(
                              child: ExtendedImage.asset(
                                  'assets/imgs/icons/icon_profile_delete.png',
                                  scale: 4),
                              onTap: () {
                                profileImage = false;
                                _imageFile = null;
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
                            height: 200,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                              CustomFullScreenDialog
                                                  .cancelDialog();
                                              profileImage = true;
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
                                              await _imageController
                                                  .getSingleImage(
                                                  ImageSource.gallery);
                                              CustomFullScreenDialog
                                                  .cancelDialog();
                                              profileImage = true;
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
                                              backgroundColor:
                                              Color(0xff2C97FB),
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
                      child: Stack(
                        children: [
                          if (_isSelected)
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                backgroundImage: NetworkImage(
                                    _userModelController.profileImageUrl!),
                              ),
                            ),
                          if (!_isSelected)
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                backgroundImage: AssetImage(
                                    'assets/imgs/profile/img_profile_default_circle.png'),
                              ),
                            ),
                          Positioned(
                              bottom: 13,
                              right: 8,
                              child: GestureDetector(
                                child: ExtendedImage.asset(
                                    'assets/imgs/icons/icon_profile_add.png',
                                    scale: 4),
                                onTap: () {},
                              )),
                        ],
                      ), //이 컨테이너가 이미지업로드 전에 보여주는 아이콘임
                    ),
                  ),
            Expanded(child: SizedBox()),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_imageFile != null) {
                    CustomFullScreenDialog.showDialog();
                    String profileImageUrl = await _imageController.setNewImage(_imageFile!);
                    await _userModelController.updateProfileImageUrl(profileImageUrl);
                    CustomFullScreenDialog.cancelDialog();
                    Navigator.pop(context);
                    Get.snackbar('프로필 이미지', '선택한 이미지로 변경이 완료되었습니다.',
                        margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.black87,
                        colorText: Colors.white,
                        duration: Duration(milliseconds: 3000));
                  } else {
                    null;
                  }
                },
                child: Text(
                  '수정하기',
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
                    minimumSize: Size(1000, 56),
                    backgroundColor: (_imageFile != null)
                        ? Color(0xff377EEA)
                        : Color(0xffDEDEDE)),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  showModalBottomSheet(
                      context: context,
                      builder:  (context) => Container(
                        height: 200,
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    '기본 이미지로 변경하시겠습니까?',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111111)),
                                  ),
                                  SizedBox(
                                    height: 44,
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
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        '취소',
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
                                        await _userModelController
                                            .deleteProfileImageUrl();
                                        CustomFullScreenDialog.cancelDialog();
                                        Navigator.pop(context);
                                        Get.snackbar('프로필 이미지', '기본 이미지로 변경이 완료되었습니다.',
                                            margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.black87,
                                            colorText: Colors.white,
                                            duration: Duration(milliseconds: 3000));
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        '변경하기',
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
                                          Color(0xff2C97FB),
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '기본 이미지로 변경',
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
