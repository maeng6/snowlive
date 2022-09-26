import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snowlive3/controller/vm_imageController.dart';
import 'package:snowlive3/screens/more/v_moreTab.dart';
import 'package:snowlive3/screens/onboarding/v_favoriteResort.dart';
import 'package:snowlive3/screens/onboarding/v_setNickname.dart';

import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class SetProfileImageMoreTab extends StatefulWidget {
  SetProfileImageMoreTab({Key? key}) : super(key: key);

  @override
  State<SetProfileImageMoreTab> createState() => _SetProfileImageMoreTabState();
}

class _SetProfileImageMoreTabState extends State<SetProfileImageMoreTab> {
  bool profileImage = false;

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
                        onTap: (){
                          showMaterialModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              height: 215,
                              child: Column(
                                children: [
                                  Text(
                                    '업로드 방법을 선택해주세요.',
                                    style: TextStyle(
                                        fontSize: 23, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '프로필 이미지를 나중에 업로드하길 원하시면,\n건너뛰기 버튼을 눌러주세요.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          CustomFullScreenDialog.showDialog();
                                          try {
                                            await _imageController
                                                .getSingleImage(ImageSource.gallery);
                                            CustomFullScreenDialog.cancelDialog();
                                            print(
                                                _userModelController.profileImageUrl);
                                            profileImage = true;
                                            setState(() {});
                                            Navigator.pop(context);
                                          } catch (e) {
                                            CustomFullScreenDialog.cancelDialog();
                                          }
                                        },
                                        child: Text(
                                          '앨범에서 선택',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: TextButton.styleFrom(
                                            splashFactory: InkRipple.splashFactory,
                                            minimumSize: Size(170, 56),
                                            backgroundColor: Color(0xff555555)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          CustomFullScreenDialog.showDialog();
                                          try {
                                            await _imageController
                                                .getSingleImage(ImageSource.camera);
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
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: TextButton.styleFrom(
                                            splashFactory: InkRipple.splashFactory,
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
                          child: ExtendedImage.network(
                            _userModelController.profileImageUrl!,
                            width: 100,
                            height: 100,
                            shape: BoxShape.circle,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: GestureDetector(
                        onTap: (){
                          showMaterialModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              height: 215,
                              child: Column(
                                children: [
                                  Text(
                                    '업로드 방법을 선택해주세요.',
                                    style: TextStyle(
                                        fontSize: 23, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '프로필 이미지를 나중에 업로드하길 원하시면,\n건너뛰기 버튼을 눌러주세요.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          CustomFullScreenDialog.showDialog();
                                          try {
                                            await _imageController
                                                .getSingleImage(ImageSource.gallery);
                                            CustomFullScreenDialog.cancelDialog();
                                            print(
                                                _userModelController.profileImageUrl);
                                            profileImage = true;
                                            setState(() {});
                                            Navigator.pop(context);
                                          } catch (e) {
                                            CustomFullScreenDialog.cancelDialog();
                                          }
                                        },
                                        child: Text(
                                          '앨범에서 선택',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: TextButton.styleFrom(
                                            splashFactory: InkRipple.splashFactory,
                                            minimumSize: Size(170, 56),
                                            backgroundColor: Color(0xff555555)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          CustomFullScreenDialog.showDialog();
                                          try {
                                            await _imageController
                                                .getSingleImage(ImageSource.camera);
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
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: TextButton.styleFrom(
                                            splashFactory: InkRipple.splashFactory,
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
                              border:
                                  Border.all(color: Colors.black12, width: 3)),
                          child: Icon(
                            Icons.image,
                            size: 150,
                          ),
                        ),//이 컨테이너가 이미지업로드 전에 보여주는 아이콘임
                      ),
                    ),
              Expanded(child: SizedBox()),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => MoreTab());
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
                    Get.offAll(() => MoreTab());
                  },
                  child: Text(
                    '취소',
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
