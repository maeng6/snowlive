import 'dart:io';
import 'package:com.snowlive/screens/bulletin/Event/v_bulletin_Event_List_Detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/vm_bulletinEventController.dart';
import '../../../controller/vm_imageController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../model/m_bulletinEventModel.dart';
import '../../../widget/w_fullScreenDialog.dart';

class Bulletin_Event_Upload extends StatefulWidget {
  const Bulletin_Event_Upload({Key? key}) : super(key: key);

  @override
  State<Bulletin_Event_Upload> createState() => _Bulletin_Event_UploadState();
}

class _Bulletin_Event_UploadState extends State<Bulletin_Event_Upload> {
  Map<String, String?> _tileSelected = {
    "구분": '',
    "스키장": ''
  };
  bool? bulletinEventImageSelected = false;
  int i = 0;
  int imageLength = 0;
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _itemDescribTextEditingController = TextEditingController();
  TextEditingController _snsUrlTextEditingController = TextEditingController();
  bool? isCategorySelected = false;
  bool? isLocationSelected = false;
  String? SelectedCategory = '';
  String? SelectedLocation = '';
  String? title = '';
  final _formKey = GlobalKey<FormState>();

  XFile? _imageFile;
  String? _bulletinEventImageUrl;
  bool _bulletinEventImageSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageFile = null;
  }


  ListTile buildResortListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${bulletinEventResortList[index]}'),
      onTap: () async {
        isLocationSelected = true;
        SelectedLocation = bulletinEventResortList[index];
        _tileSelected['스키장'] = SelectedLocation;
        print(_tileSelected);
        Navigator.pop(context);
        setState(() {});
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  ListTile buildCategoryListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${bulletinEventCategoryList[index]}'),
      onTap: () async {
        isCategorySelected = true;
        SelectedCategory = bulletinEventCategoryList[index];
        _tileSelected['구분'] = SelectedCategory;
        print(_tileSelected);
        Navigator.pop(context);
        setState(() {});
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    //TODO : ****************************************************************
    Get.put(ImageController(), permanent: true);
    UserModelController _userModelController = Get.find<UserModelController>();
    BulletinEventModelController _bulletinEventModelController = Get.find<BulletinEventModelController>();
    ImageController _imageController = Get.find<ImageController>();
    //TODO : ****************************************************************

    Size _size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
              title: Text('클리닉/행사'),
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
                onTap: () {
                  Get.back();
                },
              ),
              actions: [
                TextButton(
                    onPressed: () async{
                      final isValid = _formKey.currentState!.validate();

                      if(_tileSelected["구분"]!.isEmpty){
                        Get.snackbar('선택되지않은 항목', '구분을 선택해주세요.',
                            margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            duration: Duration(milliseconds: 3000));
                      }
                      else if(_tileSelected["스키장"]!.isEmpty){
                        Get.snackbar('선택되지않은 항목', '스키장을 선택해주세요.',
                            margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            duration: Duration(milliseconds: 3000));
                      }
                      else{
                        String? bulletinEventImageUrl = "";
                        if(isValid){
                          CustomFullScreenDialog.showDialog();
                          await _userModelController.bulletinEventCountUpdate(_userModelController.uid);

                          if(_imageFile != null){
                            bulletinEventImageUrl = await _imageController.setNewImage_bulletinEvent(_imageFile!, _userModelController.bulletinEventCount);
                          }

                          await _bulletinEventModelController.uploadBulletinEvent(
                              displayName: _userModelController.displayName,
                              uid: _userModelController.uid,
                              profileImageUrl: _userModelController.profileImageUrl,
                              itemImagesUrl: bulletinEventImageUrl,
                              title: _titleTextEditingController.text,
                              category: SelectedCategory,
                              location: SelectedLocation,
                              description: _itemDescribTextEditingController.text,
                              bulletinEventCount: _userModelController.bulletinEventCount,
                              resortNickname: _userModelController.resortNickname,
                              snsUrl: _snsUrlTextEditingController.text
                          );
                          await _bulletinEventModelController.getCurrentBulletinEvent(
                              uid: _userModelController.uid,
                              bulletinEventCount: _userModelController.bulletinEventCount);

                          CustomFullScreenDialog.cancelDialog();
                          Get.off(() => Bulletin_Event_List_Detail());
                        }
                        _imageController.imagesUrlList.clear();
                      }

                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text('올리기', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D83ED)
                      ),),
                    ))
              ],
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ),
          body: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                        key: _formKey,
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: _size.width / 2 - 26,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isCategorySelected == true)
                                        Text(
                                          '구분',
                                          style:
                                          TextStyle(color: Color(0xff949494), fontSize: 12),
                                        ),
                                      TextButton(
                                          style: TextButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: EdgeInsets.symmetric(vertical: 6),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () {
                                            showModalBottomSheet(
                                                enableDrag: false,
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    color: Colors.white,
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 30),
                                                    height: _size.height * 0.45,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '구분을 선택해주세요.',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        Container(
                                                          color: Colors.white,
                                                          height: 30,
                                                        ),
                                                        Expanded(
                                                          child: ListView.builder(
                                                              padding: EdgeInsets.zero,
                                                              itemCount: 4,
                                                              itemBuilder: (context, index) {
                                                                return Builder(builder: (context) {
                                                                  return Column(
                                                                    children: [
                                                                      buildCategoryListTile(index),
                                                                      Divider(
                                                                        height: 20,
                                                                        thickness: 0.5,
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                              }),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          child: (isCategorySelected!)
                                              ? Text('$SelectedCategory', style: TextStyle(
                                              fontSize: 16, color: Color(0xFF111111)
                                          ),)
                                              : Text('구분', style: TextStyle(
                                              fontSize: 16, color: Color(0xFF949494)
                                          ),)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isLocationSelected==true)
                                      Text(
                                        '스키장',
                                        style:
                                        TextStyle(color: Color(0xff949494), fontSize: 12),
                                      ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            enableDrag: false,
                                            context: context,
                                            builder: (context) {
                                              return Container(
                                                color: Colors.white,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 30),
                                                height: _size.height * 0.8,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '스키장을 선택해주세요.',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    Container(
                                                      color: Colors.white,
                                                      height: 30,
                                                    ),
                                                    Expanded(
                                                      child: ListView.builder(
                                                          padding: EdgeInsets.zero,
                                                          itemCount: 14,
                                                          itemBuilder: (context, index) {
                                                            return Builder(builder: (context) {
                                                              return Column(
                                                                children: [
                                                                  buildResortListTile(index),
                                                                  Divider(
                                                                    height: 20,
                                                                    thickness: 0.5,
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                          }),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                      child: (isLocationSelected!)
                                          ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: Color(0xFFD5F7E0),
                                        ),
                                        padding: EdgeInsets.only(right: 10, left: 10, top: 4, bottom: 6),
                                        child: Text('$SelectedLocation', style: TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF17AD4A)
                                        ),),
                                      )
                                          : Padding(
                                        padding: EdgeInsets.only(bottom: 6),
                                        child: Text('스키장', style: TextStyle(
                                            fontSize: 16, color: Color(0xFF949494)
                                        ),),
                                      ),),
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: Color(0xFFECECEC),
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 4,
                                ),
                                TextFormField(
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: Color(0xff3D6FED),
                                  cursorHeight: 16,
                                  cursorWidth: 2,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  controller: _titleTextEditingController,
                                  strutStyle: StrutStyle(leading: 0.3),
                                  decoration: InputDecoration(
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    errorStyle: TextStyle(
                                      fontSize: 12,
                                    ),
                                    labelStyle: TextStyle(
                                        color: Color(0xff949494)
                                    ),
                                    hintStyle:
                                    TextStyle(color: Color(0xffDEDEDE), fontSize: 16),
                                    hintText: '글 제목을 입력해 주세요. (최대 50자)',
                                    labelText: '글 제목',
                                    contentPadding: EdgeInsets.symmetric(vertical: 2),
                                    border: InputBorder.none,
                                  ),
                                  validator: (val) {
                                    if (val!.length <= 50 && val.length >= 1) {
                                      return null;
                                    } else if (val.length == 0) {
                                      return '글 제목을 입력해주세요.';
                                    } else {
                                      return '최대 입력 가능한 글자 수를 초과했습니다.';
                                    }
                                  },
                                ),
                              ],
                            ),
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(
                                    height: 32,
                                    thickness: 0.5,
                                    color: Color(0xFFECECEC),
                                  ),
                                  TextFormField(
                                    maxLines: null,
                                    textInputAction: TextInputAction.newline,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.multiline,
                                    cursorColor: Color(0xff3D6FED),
                                    cursorHeight: 16,
                                    cursorWidth: 2,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    controller: _snsUrlTextEditingController,
                                    strutStyle: StrutStyle(leading: 0.3),
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      errorStyle: TextStyle(
                                        fontSize: 12,
                                      ),
                                      labelStyle: TextStyle(
                                          color: Color(0xff949494)
                                      ),
                                      hintStyle:
                                      TextStyle(color: Color(0xffDEDEDE), fontSize: 16),
                                      hintText: 'URL을 입력해주세요.(https:// 필수 입력)',
                                      labelText: 'SNS URL',
                                      border: InputBorder.none,
                                    ),
                                    validator: (val) {
                                      if (val!.length <= 1000 && val.length >= 0) {
                                        return null;
                                      } else {
                                        return '최대 입력 가능한 글자 수를 초과했습니다.';
                                      }
                                    },
                                  ),
                                  if(_bulletinEventImageSelected == true)
                                    Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 16),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.file(
                                              File(_bulletinEventImageUrl!),
                                              width: _size.width -32,
                                              height: _size.width -32,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 16,
                                          child: IconButton(
                                            icon: Icon(Icons.cancel,
                                              color: Colors.white,
                                            ),
                                            onPressed: (){
                                              setState(() {
                                                _bulletinEventImageSelected = false;
                                                _imageFile = null;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Color(0xFFDEDEDE))
                                      ),
                                      width: _size.width - 32,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) =>
                                                Container(
                                                  height: 179,
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
                                                                  Navigator.pop(context);
                                                                  CustomFullScreenDialog.showDialog();
                                                                  try {
                                                                    _imageFile = await _imageController.getSingleImage(ImageSource.camera);
                                                                    _bulletinEventImageUrl = _imageFile!.path;
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    _bulletinEventImageSelected = true;
                                                                    setState(() {});
                                                                  } catch (e) {
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                  }
                                                                },
                                                                child: Text(
                                                                  '사진 촬영',
                                                                  style: TextStyle(
                                                                      color: Color(0xFF3D83ED),
                                                                      fontSize: 15,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                                style: TextButton.styleFrom(
                                                                    splashFactory:
                                                                    InkRipple.splashFactory,
                                                                    elevation: 0,
                                                                    minimumSize: Size(100, 56),
                                                                    backgroundColor: Color(0xffCBE0FF),
                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () async {
                                                                  Navigator.pop(context);
                                                                  CustomFullScreenDialog.showDialog();
                                                                  try {
                                                                    _imageFile = await _imageController.getSingleImage(ImageSource.gallery);
                                                                    _bulletinEventImageUrl = _imageFile!.path;
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    _bulletinEventImageSelected = true;
                                                                    setState(() {});
                                                                  } catch (e) {
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
                                                                    backgroundColor:
                                                                    Color(0xff3D83ED),
                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 40,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                          );
                                        },
                                        child: Text(
                                          '이미지 업로드',
                                          style: TextStyle(
                                              color: Color(0xFF444444),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        style: TextButton.styleFrom(
                                            splashFactory: InkRipple.splashFactory,
                                            elevation: 0,
                                            minimumSize: Size(100, 48),
                                            backgroundColor: Color(0xffffffff),
                                            padding: EdgeInsets.symmetric(horizontal: 0)),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    maxLines: null,
                                    textAlignVertical: TextAlignVertical.center,
                                    cursorColor: Color(0xff3D6FED),
                                    cursorHeight: 16,
                                    cursorWidth: 2,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    controller: _itemDescribTextEditingController,
                                    strutStyle: StrutStyle(leading: 0.3),
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      errorStyle: TextStyle(
                                        fontSize: 12,
                                      ),
                                      labelStyle: TextStyle(
                                          color: Color(0xff949494)
                                      ),
                                      hintStyle:
                                      TextStyle(color: Color(0xffDEDEDE), fontSize: 16),
                                      hintText: '게시글 내용을 작성해 주세요. (최대 1,000자)',
                                      labelText: '내용',
                                      border: InputBorder.none,
                                    ),
                                    validator: (val) {
                                      if (val!.length <= 1000 && val.length >= 1) {
                                        return null;
                                      } else if (val.length == 0) {
                                        return '내용을 입력해주세요.';
                                      } else {
                                        return '최대 입력 가능한 글자 수를 초과했습니다.';
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
