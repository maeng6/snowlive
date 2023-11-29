import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/screens/bulletin/Crew/v_bulletin_Crew_List_Screen.dart';
import 'package:com.snowlive/screens/bulletin/v_bulletin_Screen.dart';
import 'package:com.snowlive/screens/v_MainHome.dart';
import '../../../controller/vm_bulletinCrewController.dart';
import '../../../controller/vm_bulletinFreeController.dart';
import '../../../controller/vm_bulletinRoomController.dart';
import '../../../controller/vm_imageController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../model/m_bulletinCrewModel.dart';
import '../../../model/m_bulletinFreeModel.dart';
import '../../../model/m_bulletinRoomModel.dart';
import '../../../widget/w_fullScreenDialog.dart';

class Bulletin_Free_ModifyPage extends StatefulWidget {
  const Bulletin_Free_ModifyPage({Key? key}) : super(key: key);

  @override
  State<Bulletin_Free_ModifyPage> createState() => _Bulletin_Free_ModifyPageState();
}

class _Bulletin_Free_ModifyPageState extends State<Bulletin_Free_ModifyPage> {
  List<XFile> _imageFiles = [];
  Map<String, String?> _tileSelected = {
    "구분": '',
    "스키장": ''
  };
  bool? bulletinFreeImageSelected = false;
  int i = 0;
  int imageLength = 0;
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _itemDescribTextEditingController = TextEditingController();
  bool? isCategorySelected = false;
  bool? isLocationSelected = false;
  bool? isMethodSelected = false;
  bool? isModifiedImageSelected = false;
  RxString? SelectedCategory = ''.obs;
  RxString? SelectedLocation = ''.obs;
  RxString? SelectedMethod = ''.obs;
  String? title = '';
  final _formKey = GlobalKey<FormState>();
  RxList? _imageUrls=[].obs;
  String? _initTitle ;
  String? _initdescrip ;

  ListTile buildCategoryListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${bulletinFreeCategoryList[index]}'),
      onTap: () async {
        isCategorySelected = true;
        SelectedCategory!.value = bulletinFreeCategoryList[index];
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
    BulletinFreeModelController _bulletinFreeModelController = Get.find<BulletinFreeModelController>();
    _imageUrls!.addAll(_bulletinFreeModelController.itemImagesUrls!);
    SelectedCategory = _bulletinFreeModelController.category!.obs;
    _initTitle =_bulletinFreeModelController.title;
    _initdescrip =_bulletinFreeModelController.description;
  }

  @override
  Widget build(BuildContext context) {
    //TODO : ****************************************************************
    Get.put(ImageController(), permanent: true);
    UserModelController _userModelController = Get.find<UserModelController>();
    BulletinFreeModelController _bulletinFreeModelController = Get.find<BulletinFreeModelController>();
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
              title: Text('시즌방'),
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

                      if(isValid){
                        CustomFullScreenDialog.showDialog();
                        await _imageController.setNewMultiImage_bulletinFree(_imageFiles, _bulletinFreeModelController.bulletinFreeCount);
                        (isModifiedImageSelected==true)
                            ? await _bulletinFreeModelController.updateBulletinFree(
                            displayName: _userModelController.displayName,
                            uid: _userModelController.uid,
                            profileImageUrl: _userModelController.profileImageUrl,
                            itemImagesUrls: _imageController.imagesUrlList,
                            title: _titleTextEditingController.text,
                            category: SelectedCategory!.value,
                            location: SelectedLocation!.value,
                            description: _itemDescribTextEditingController.text,
                            bulletinFreeCount: _bulletinFreeModelController.bulletinFreeCount,
                            resortNickname: _userModelController.resortNickname,
                            likeCount: _bulletinFreeModelController.likeCount,
                            hot: _bulletinFreeModelController.hot,
                            score: _bulletinFreeModelController.score,
                            viewerUid: _bulletinFreeModelController.viewerUid,
                            timeStamp: _bulletinFreeModelController.timeStamp
                        )
                            : await _bulletinFreeModelController.updateBulletinFree(
                            displayName: _userModelController.displayName,
                            uid: _userModelController.uid,
                            profileImageUrl: _userModelController.profileImageUrl,
                            itemImagesUrls: _imageUrls,
                            title: _titleTextEditingController.text,
                            category: SelectedCategory!.value,
                            location: SelectedLocation!.value,
                            description: _itemDescribTextEditingController.text,
                            bulletinFreeCount: _bulletinFreeModelController.bulletinFreeCount,
                            resortNickname: _userModelController.resortNickname,
                            likeCount: _bulletinFreeModelController.likeCount,
                            hot: _bulletinFreeModelController.hot,
                            score: _bulletinFreeModelController.score,
                            viewerUid: _bulletinFreeModelController.viewerUid,
                            timeStamp: _bulletinFreeModelController.timeStamp
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (imageLength >= 5) {
                              Get.dialog(
                                AlertDialog(
                                  title: Text('사진 개수 초과'),
                                ),
                              );
                            } else {
                              CustomFullScreenDialog.showDialog();
                              try {
                                _imageFiles = await _imageController.getMultiImage(ImageSource.gallery);
                                CustomFullScreenDialog.cancelDialog();
                                if (_imageFiles.length <= 5) {
                                  bulletinFreeImageSelected = true;
                                  imageLength = _imageFiles.length;
                                  setState(() {});
                                } else {
                                  Get.dialog(
                                    AlertDialog(
                                      title: Text('사진 개수 초과'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                CustomFullScreenDialog.cancelDialog();
                              }
                            }
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    if (imageLength >= 5) {
                                      Get.dialog(
                                        AlertDialog(
                                          title: Text('사진 개수 초과'),
                                        ),
                                      );
                                    } else {
                                      CustomFullScreenDialog.showDialog();
                                      try {
                                        _imageFiles = await _imageController.getMultiImage(ImageSource.gallery);
                                        CustomFullScreenDialog.cancelDialog();
                                        if (_imageFiles.length <= 5) {
                                          bulletinFreeImageSelected = true;
                                          imageLength = _imageFiles.length;
                                          setState(() {});
                                        } else {
                                          Get.dialog(
                                            AlertDialog(
                                              title: Text('사진 개수 초과'),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        CustomFullScreenDialog.cancelDialog();
                                      }
                                    }
                                  },
                                  icon: Icon(Icons.camera_alt_rounded),
                                  color: Color(0xFF949494),
                                ),
                                Transform.translate(
                                  offset: Offset(0, -10),
                                  child: Text(
                                    '$imageLength / 5',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF949494),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Color(0xFFececec),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        if(_imageFiles.length == 0)
                          SizedBox(width: 8,),
                        if(_imageUrls!.length==0 && _imageFiles.length==0)
                          Text('사진은 게시글에 첨부됩니다.',
                            style: TextStyle(
                                color: Color(0xff949494),
                                fontSize: 12
                            ),
                          ),
                        (isModifiedImageSelected==true)
                            ?Expanded(
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: imageLength,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Stack(children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Color(0xFFECECEC)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        height: 90,
                                        width: 90,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(7),
                                          child: Image.file(
                                            File(_imageFiles[index].path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -8,
                                        right: -8,
                                        child: IconButton(
                                          onPressed: () {
                                            _imageFiles.removeAt(index);
                                            imageLength = _imageFiles.length;
                                            setState(() {});
                                          },
                                          icon: Icon(Icons.cancel), color: Color(0xFF111111),),
                                      ),
                                      if(index==0)
                                        Positioned(
                                          top: 68,
                                          child: Opacity(
                                            opacity:0.8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.transparent
                                                ),
                                                borderRadius: BorderRadius.only(
                                                    bottomRight: Radius.circular(8),
                                                    bottomLeft: Radius.circular(8)
                                                ),
                                                color: Colors.black87,
                                              ),
                                              height: 22,
                                              width: 90,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(7),
                                                child: Text('대표사진',
                                                  style: TextStyle(color: Colors.white,
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ]),
                                    SizedBox(
                                      width: 8,
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                            :Expanded(
                          child: SizedBox(
                            height: 100,
                            child:
                            Obx(() => ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: _imageUrls!.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Stack(children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Color(0xFFECECEC)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        height: 90,
                                        width: 90,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(7),
                                          child: Image.network(
                                            '${_imageUrls![index]}',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -8,
                                        right: -8,
                                        child: IconButton(
                                          onPressed: () {
                                            _imageUrls!.removeAt(index);
                                            setState(() {
                                            });
                                          },
                                          icon: Icon(Icons.cancel), color: Color(0xFF111111),),
                                      ),
                                      if(index==0)
                                        Positioned(
                                          top: 68,
                                          child: Opacity(
                                            opacity:0.8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.transparent
                                                ),
                                                borderRadius: BorderRadius.only(
                                                    bottomRight: Radius.circular(8),
                                                    bottomLeft: Radius.circular(8)
                                                ),
                                                color: Colors.black87,
                                              ),
                                              height: 22,
                                              width: 90,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(7),
                                                child: Text('대표사진',
                                                  style: TextStyle(color: Colors.white,
                                                      fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ]),
                                    SizedBox(
                                      width: 8,
                                    )
                                  ],
                                );
                              },
                            )),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 30,
                      width: 100,
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
                                          child: Text('${SelectedCategory!.value}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF111111)
                                            ),)),
                                    ],
                                  ),
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
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: Color(0xFFECECEC),
                            ),
                            Container(
                              height: _size.height-500,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFormField(
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
