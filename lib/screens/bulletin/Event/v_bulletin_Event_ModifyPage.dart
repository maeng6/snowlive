import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/bulletin/vm_bulletinEventController.dart';
import '../../../viewmodel/vm_imageController.dart';
import '../../../controller/user/vm_userModelController.dart';
import '../../../model_2/m_bulletinEventModel.dart';
import '../../../widget/w_fullScreenDialog.dart';

class Bulletin_Event_ModifyPage extends StatefulWidget {
  const Bulletin_Event_ModifyPage({Key? key}) : super(key: key);

  @override
  State<Bulletin_Event_ModifyPage> createState() => _Bulletin_Event_ModifyPageState();
}

class _Bulletin_Event_ModifyPageState extends State<Bulletin_Event_ModifyPage> {
  List<XFile> _imageFiles = [];
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
  bool? isMethodSelected = false;
  bool? isModifiedImageSelected = false;
  RxString? SelectedCategory = ''.obs;
  RxString? SelectedLocation = ''.obs;
  RxString? SelectedMethod = ''.obs;
  String? title = '';
  final _formKey = GlobalKey<FormState>();
  String? _initTitle ;
  String? _initdescrip ;
  String? _initBulletinEventImageUrl;
  String? _initSnsUrl;

  XFile? _imageFile;

  ListTile buildResortListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${bulletinEventResortList[index]}'),
      onTap: () async {
        isLocationSelected = true;
        SelectedLocation!.value = bulletinEventResortList[index];
        _tileSelected['리조트'] = SelectedLocation!.value;
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
        SelectedCategory!.value = bulletinEventCategoryList[index];
        _tileSelected['구분'] = SelectedCategory!.value;
        print(_tileSelected);
        Navigator.pop(context);
        setState(() {});
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageFile = null;
    BulletinEventModelController _bulletinEventModelController = Get.find<BulletinEventModelController>();
    SelectedCategory = _bulletinEventModelController.category!.obs;
    SelectedLocation = _bulletinEventModelController.location!.obs;
    _initTitle =_bulletinEventModelController.title;
    _initdescrip =_bulletinEventModelController.description;
    _initBulletinEventImageUrl = _bulletinEventModelController.itemImagesUrl;
    _initSnsUrl = _bulletinEventModelController.snsUrl;
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
              title: Text('클리닉·행사'),
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
                      String? bulletinEventImageUrl = "";
                      if(isValid){
                        CustomFullScreenDialog.showDialog();
                        if(_imageFile != null){
                          bulletinEventImageUrl = await _imageController.setNewImage_bulletinEvent(_imageFile!, _bulletinEventModelController.bulletinEventCount);
                        }
                        (isModifiedImageSelected==true)
                            ? await _bulletinEventModelController.updateBulletinEvent(
                            displayName: _userModelController.displayName,
                            uid: _userModelController.uid,
                            profileImageUrl: _userModelController.profileImageUrl,
                            itemImagesUrl: bulletinEventImageUrl,
                            title: _titleTextEditingController.text,
                            category: SelectedCategory!.value,
                            location: SelectedLocation!.value,
                            description: _itemDescribTextEditingController.text,
                            bulletinEventCount: _bulletinEventModelController.bulletinEventCount,
                            resortNickname: _userModelController.resortNickname,
                            timeStamp: _bulletinEventModelController.timeStamp,
                            snsUrl: _snsUrlTextEditingController.text,
                        )
                            : await _bulletinEventModelController.updateBulletinEvent(
                            displayName: _userModelController.displayName,
                            uid: _userModelController.uid,
                            profileImageUrl: _userModelController.profileImageUrl,
                            itemImagesUrl: _initBulletinEventImageUrl,
                            title: _titleTextEditingController.text,
                            category: SelectedCategory!.value,
                            location: SelectedLocation!.value,
                            description: _itemDescribTextEditingController.text,
                            bulletinEventCount: _bulletinEventModelController.bulletinEventCount,
                            resortNickname: _userModelController.resortNickname,
                            timeStamp: _bulletinEventModelController.timeStamp,
                            snsUrl: _snsUrlTextEditingController.text,
                        );
                        CustomFullScreenDialog.cancelDialog();
                        for(int i=0; i<2; i++){
                          Get.back();
                        }
                      }
                      _imageController.imagesUrlList.clear();

                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text('수정완료', style: TextStyle(
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
                    SizedBox(
                      height: 16,
                    ),
                    Form(
                        key: _formKey,
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                                              itemCount: 3,
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
                                          child: Text('${SelectedCategory!.value}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF111111)
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
                                                      '리조트를 선택해주세요.',
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
                                                          itemCount: 13,
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
                                      child:Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: Color(0xFFD5F7E0),
                                        ),
                                        padding: EdgeInsets.only(right: 10, left: 10, top: 4, bottom: 6),
                                        child: Text('${SelectedLocation!.value}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF17AD4A)),
                                        ),
                                      ),
                                    ),
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
                                  controller: _titleTextEditingController..text='$_initTitle',
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
                                  Column(
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
                                        textAlignVertical: TextAlignVertical.center,
                                        cursorColor: Color(0xff377EEA),
                                        cursorHeight: 16,
                                        cursorWidth: 2,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        controller: _snsUrlTextEditingController..text = '$_initSnsUrl',
                                        onChanged: (snsUrl){
                                          _initSnsUrl = snsUrl;
                                          print(snsUrl);
                                        },
                                        strutStyle: StrutStyle(leading: 0.3),
                                        decoration: InputDecoration(
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
                                    ],
                                  ),
                                  if(_initBulletinEventImageUrl != '')
                                    Stack(
                                      children: [
                                        (isModifiedImageSelected == false)
                                            ? Padding(
                                              padding: const EdgeInsets.only(top: 16),
                                              child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                              child: ExtendedImage.network(
                                                _initBulletinEventImageUrl!,
                                                cache: true,
                                                //cacheHeight: 1600,
                                                width: _size.width - 32,
                                                height: _size.width - 32,
                                                fit: BoxFit.cover,
                                              ),
                                          ),
                                        ),
                                            )
                                            : Padding(
                                          padding: const EdgeInsets.only(top: 16),
                                              child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.file(
                                              File(_initBulletinEventImageUrl!),
                                              width: _size.width - 32,
                                              height: _size.width - 32,
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
                                                isModifiedImageSelected = false;
                                                _initBulletinEventImageUrl = '';
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
                                                                    _initBulletinEventImageUrl = _imageFile!.path;
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    isModifiedImageSelected = true;
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
                                                                    _initBulletinEventImageUrl = _imageFile!.path;
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    isModifiedImageSelected = true;
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
                                    controller: _itemDescribTextEditingController..text='$_initdescrip',
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
