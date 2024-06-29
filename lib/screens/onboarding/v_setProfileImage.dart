import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/controller/public/vm_imageController.dart';
import 'package:com.snowlive/screens/onboarding/v_favoriteResort.dart';
import '../../controller/user/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class SetProfileImage extends StatefulWidget {
  SetProfileImage({Key? key,required this.nickName}) : super(key: key);

  String? _profileImageUrl;
  var nickName;

  @override
  State<SetProfileImage> createState() => _SetProfileImageState();
}

class _SetProfileImageState extends State<SetProfileImage> {
  bool profileImage = false;
  XFile? _imageFile;
  XFile? _croppedFile;
  bool _isSelected = true;

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
    UserModelController _userModelController = Get.find<UserModelController>();
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

    _isSelected = _userModelController.profileImageUrl!.isNotEmpty;


    return Stack(
      children: [
        Scaffold(backgroundColor: Colors.white,
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
          body: Padding(
            padding:
                 EdgeInsets.only(top: _statusBarSize+58, left: 16, right: 16, bottom: _statusBarSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      '프로필 이미지를\n설정해 주세요.',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.3),

                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '스노우라이브에서 사용할 프로필 이미지를 설정해 주세요.\n프로필 이미지는 언제든지 변경할 수 있습니다.',
                  style: TextStyle(
                      color: Color(0xff949494),
                      fontSize: 13,
                      height: 1.5
                  ),
                ),
                SizedBox(
                  height: _size.height * 0.16,
                ),
                (profileImage) //이 값이 true이면 이미지업로드가 된 상태이므로, 미리보기 띄움
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => SafeArea(
                                child: Container(
                                  height: 187,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 24,
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
                                              height: 24,
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
                                                    if(_imageFile != null){
                                                      _croppedFile = await _imageController.cropImage(_imageFile);
                                                    }
                                                    if(_croppedFile != null){
                                                      profileImage = true;
                                                      setState(() {});
                                                    }
                                                  } catch (e) {
                                                    CustomFullScreenDialog.cancelDialog();
                                                  }
                                                  CustomFullScreenDialog.cancelDialog();
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  '사진 촬영',
                                                  style: TextStyle(
                                                      color: Color(0xff377EEA),
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                style: TextButton.styleFrom(
                                                    splashFactory: InkRipple.splashFactory,
                                                    elevation: 0,
                                                    minimumSize: Size(100, 56),
                                                    backgroundColor: Color(0xFFD8E7FD),
                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
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
                                                    if(_imageFile != null){
                                                      _croppedFile = await _imageController.cropImage(_imageFile);
                                                    }
                                                    if(_croppedFile != null){
                                                      profileImage = true;
                                                      setState(() {});
                                                    }
                                                  } catch (e) {
                                                    CustomFullScreenDialog.cancelDialog();
                                                  }
                                                  CustomFullScreenDialog.cancelDialog();
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  '앨범에서 선택',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                style: TextButton.styleFrom(
                                                    splashFactory: InkRipple.splashFactory,
                                                    elevation: 0,
                                                    minimumSize: Size(100, 56),
                                                    backgroundColor: Color(0xff377EEA),
                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                                backgroundImage:
                                    FileImage(File(_croppedFile!.path)),
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
                              builder: (context) => SafeArea(
                                child: Container(
                                  height: 187,
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
                                              height: 24,
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
                                              height: 24,
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
                                                    if(_imageFile != null){
                                                      _croppedFile = await _imageController.cropImage(_imageFile);
                                                    }
                                                    if(_croppedFile != null){
                                                      profileImage = true;
                                                      setState(() {});
                                                    }
                                                  } catch (e) {
                                                    CustomFullScreenDialog.cancelDialog();
                                                  }
                                                  CustomFullScreenDialog.cancelDialog();
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  '사진 촬영',
                                                  style: TextStyle(
                                                      color: Color(0xff377EEA),
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                style: TextButton.styleFrom(
                                                    splashFactory: InkRipple.splashFactory,
                                                    elevation: 0,
                                                    minimumSize: Size(100, 56),
                                                    backgroundColor: Color(0xFFD8E7FD),
                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
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
                                                    if(_imageFile != null){
                                                      _croppedFile = await _imageController.cropImage(_imageFile);
                                                    }
                                                    if(_croppedFile != null){
                                                      profileImage = true;
                                                      setState(() {});
                                                    }
                                                  } catch (e) {
                                                    CustomFullScreenDialog.cancelDialog();
                                                  }
                                                  CustomFullScreenDialog.cancelDialog();
                                                  Navigator.pop(context);
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
                                                    Color(0xff377EEA),
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 0)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                                  child: ClipOval(
                                    child: ExtendedImage.network(
                                      _userModelController.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      width: 160,
                                      height: 160,
                                      cache: true,
                                      loadStateChanged: (state) {
                                        if (state.extendedImageLoadState == LoadState.loading) {
                                          return CircularProgressIndicator();
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              if (!_isSelected)
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/imgs/profile/img_profile_default_circle.png',
                                  width: 147,
                                  height: 147,
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
              ],
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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.to(() => FavoriteResort(getNickname: widget.nickName,getProfileImageUrl: '',));
                      },
                      child: Text(
                        '다음에 설정',
                        style: TextStyle(color: Color(0xff377EEA), fontSize: 16, fontWeight: FontWeight.bold),

                      ),
                      style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6))),
                          elevation: 0,
                          splashFactory: InkRipple.splashFactory,
                          minimumSize: Size(100, 56),
                          backgroundColor: Color(0xFFD8E7FD)),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_croppedFile != null) {
                          CustomFullScreenDialog.showDialog();
                          String _profileImageUrl =
                          await _imageController.setNewImage(_croppedFile!);
                          CustomFullScreenDialog.cancelDialog();
                          Get.to(() => FavoriteResort(getNickname: widget.nickName,getProfileImageUrl: _profileImageUrl,));
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
                          backgroundColor: Color(0xff377EEA)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
