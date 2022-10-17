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

    Size _size = MediaQuery.of(context).size;


    //TODO : ****************************************************************
    Get.put(ImageController(), permanent: true);
    UserModelController _userModelController = Get.find<UserModelController>();
    ImageController _imageController = Get.find<ImageController>();
    //TODO : ****************************************************************


    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    '변경할 프로필 이미지를\n업로드해 주세요.',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: _size.height *0.14,
              ),
              (profileImage) //이 값이 true이면 이미지업로드가 된 상태이므로, 미리보기 띄움
                  ? Center(
                child: GestureDetector(
                  onTap: () {
                    showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    '업로드 방법을 선택해주세요.',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111111)),
                                  ),
                                  SizedBox(height: 30,),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        CustomFullScreenDialog.showDialog();
                                        try {
                                          _imageFile = await _imageController
                                              .getSingleImage(
                                              ImageSource.gallery);
                                          CustomFullScreenDialog.cancelDialog();
                                          profileImage = true;
                                          setState(() {});
                                          Navigator.pop(context);
                                        } catch (e) {
                                          CustomFullScreenDialog.cancelDialog();
                                        }
                                      },
                                      child: Text(
                                        '앨범에서 선택',
                                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      style: TextButton.styleFrom(
                                          splashFactory:
                                          InkRipple.splashFactory,
                                          elevation: 0,
                                          minimumSize: Size(100, 56),
                                          backgroundColor: Color(0xff555555),
                                          padding: EdgeInsets.symmetric(horizontal: 0)),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        CustomFullScreenDialog.showDialog();
                                        try {
                                          _imageFile = await _imageController
                                              .getSingleImage(
                                              ImageSource.camera);
                                          CustomFullScreenDialog.cancelDialog();
                                          profileImage = true;
                                          setState(() {});
                                          Navigator.pop(context);
                                        } catch (e) {
                                          CustomFullScreenDialog.cancelDialog();
                                        }
                                      },
                                      child: Text(
                                        '사진 촬영',
                                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      style: TextButton.styleFrom(
                                          splashFactory:
                                          InkRipple.splashFactory,
                                          elevation: 0,
                                          minimumSize: Size(100, 56),
                                          backgroundColor: Color(0xff2C97FB),
                                          padding: EdgeInsets.symmetric(horizontal: 0)),
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
                        Container(
                          width: 160,
                          height: 160,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            backgroundImage: FileImage(File(_imageFile!.path)),
                          ),
                        ),
                        Positioned(
                            bottom: 13,
                            right: 8,
                            child: GestureDetector(
                              child: ExtendedImage.asset('assets/imgs/icons/icon_profile_delete.png', scale: 4),
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
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    '업로드 방법을 선택해주세요.',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111111)),
                                  ),
                                  SizedBox(height: 44,),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
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
                                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      style: TextButton.styleFrom(
                                          splashFactory:
                                          InkRipple.splashFactory,
                                          elevation: 0,
                                          minimumSize: Size(100, 56),
                                          backgroundColor: Color(0xff555555),
                                          padding: EdgeInsets.symmetric(horizontal: 0)),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: ElevatedButton(
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
                                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      style: TextButton.styleFrom(
                                          splashFactory:
                                          InkRipple.splashFactory,
                                          elevation: 0,
                                          minimumSize: Size(100, 56),
                                          backgroundColor: Color(0xff2C97FB),
                                          padding: EdgeInsets.symmetric(horizontal: 0)),
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
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          backgroundImage:
                          NetworkImage(_userModelController.profileImageUrl!),
                        ),
                      ),
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            backgroundImage:
                            AssetImage('assets/imgs/profile/img_profile_default_circle.png'),
                          ),
                        ),
                      Positioned(
                          bottom: 13,
                          right: 8,
                          child: GestureDetector(
                            child: ExtendedImage.asset('assets/imgs/icons/icon_profile_add.png', scale: 4),
                            onTap: () {
                            },
                          )
                      ),
                    ],
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
                      backgroundColor:
                      (_imageFile != null)
                      ? Color(0xff377EEA)
                      : Color(0xffDEDEDE)),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
