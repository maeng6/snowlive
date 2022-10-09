import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snowlive3/controller/vm_imageController.dart';
import 'package:snowlive3/screens/onboarding/v_favoriteResort.dart';
import 'package:snowlive3/screens/onboarding/v_setNickname.dart';

import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class SetProfileImage_moreTab extends StatefulWidget {
  SetProfileImage_moreTab({Key? key}) : super(key: key);

  @override
  State<SetProfileImage_moreTab> createState() => _SetProfileImage_moreTabState();
}

class _SetProfileImage_moreTabState extends State<SetProfileImage_moreTab> {
  bool profileImage = false;
  XFile? _imageFile;

  @override
  void initState() {
    _imageFile = null;
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back),
            onTap: () => Get.back(result: () => SetNickname()),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    '변경할 프로필 이미지를\n업로드해 주세요.',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 40,
              ),
              (profileImage) //이 값이 true이면 이미지업로드가 된 상태이므로, 미리보기 띄움
                  ? Center(
                child: GestureDetector(
                  onTap: () {
                    showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        height: 215,
                        child: Column(
                          children: [
                            Text(
                              '업로드 방법을 선택해주세요.',
                              style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '프로필 이미지를 나중에 업로드하길 원하시면,\n건너뛰기 버튼을 눌러주세요.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    CustomFullScreenDialog.showDialog();
                                    try {
                                      _imageFile = await _imageController
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
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: TextButton.styleFrom(
                                      splashFactory:
                                      InkRipple.splashFactory,
                                      minimumSize: Size(170, 56),
                                      backgroundColor: Color(0xff555555)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    CustomFullScreenDialog.showDialog();
                                    try {
                                      _imageFile = await _imageController
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
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: TextButton.styleFrom(
                                      splashFactory:
                                      InkRipple.splashFactory,
                                      minimumSize: Size(170, 56),
                                      backgroundColor: Color(0xff2C97FB)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  child: Stack(
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            backgroundImage: FileImage(File(_imageFile!.path)),
                          ),
                        ),
                        Positioned(
                            left: 100,
                            child: GestureDetector(
                              child: Icon(Icons.cancel),
                              onTap: (){
                                profileImage = false;
                                _imageFile = null;
                                setState(() {});
                              },
                            )
                        ),
                      ]),
                ),
              )
                  : Center(
                child: GestureDetector(
                  onTap: () {
                    showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        height: 215,
                        child: Column(
                          children: [
                            Text(
                              '업로드 방법을 선택해주세요.',
                              style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    CustomFullScreenDialog.showDialog();
                                    try {
                                      _imageFile = await _imageController
                                          .getSingleImage(
                                          ImageSource.gallery);
                                      CustomFullScreenDialog
                                          .cancelDialog();
                                      print(_userModelController
                                          .profileImageUrl);
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
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: TextButton.styleFrom(
                                      splashFactory:
                                      InkRipple.splashFactory,
                                      minimumSize: Size(170, 56),
                                      backgroundColor: Color(0xff555555)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    CustomFullScreenDialog.showDialog();
                                    try {
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
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: TextButton.styleFrom(
                                      splashFactory:
                                      InkRipple.splashFactory,
                                      minimumSize: Size(170, 56),
                                      backgroundColor: Color(0xff2C97FB)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.grey, width: 3)),
                    child: Image.asset(
                        'assets/imgs/profile/profileImage.png'),
                  ), //이 컨테이너가 이미지업로드 전에 보여주는 아이콘임
                ),
              ),
              Expanded(child: SizedBox()),
              Center(
                child: ElevatedButton(
                  onPressed: () async{
                    if(_imageFile != null) {
                      CustomFullScreenDialog.showDialog();
                      String profileImageUrl = await _imageController
                          .setNewImage(_imageFile!);
                      await _userModelController.updateProfileImageUrl(
                          profileImageUrl);
                      CustomFullScreenDialog.cancelDialog();
                      Navigator.pop(context);
                    }else {
                      Get.snackbar('이미지를 선택해주세요.', '다음에 설정하시려면 돌아가기를 눌러주세요.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          duration: Duration(milliseconds: 2000));
                    }
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      splashFactory: InkRipple.splashFactory,
                      minimumSize: Size(350, 56),
                      backgroundColor: Color(0xff2C97FB)),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back();
                  },
                  child: Text(
                    '돌아가기',
                    style: TextStyle(color: Colors.grey),
                  ),
                  style: TextButton.styleFrom(
                      splashFactory: InkRipple.splashFactory,
                      minimumSize: Size(350, 56),
                      backgroundColor: Colors.white),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
