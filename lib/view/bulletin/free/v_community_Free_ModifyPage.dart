import 'dart:convert';
import 'dart:io';
import 'package:dart_quill_delta/dart_quill_delta.dart' as quill;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/bulletin/vm_bulletinFreeController.dart';
import '../../../screens/snowliveDesignStyle.dart';
import '../../../viewmodel/vm_imageController.dart';
import '../../../controller/user/vm_userModelController.dart';
import '../../../model_2/m_bulletinFreeModel.dart';
import '../../../widget/w_fullScreenDialog.dart';

class CommunityFreeModifyView extends StatefulWidget {
  const CommunityFreeModifyView({Key? key}) : super(key: key);

  @override
  State<CommunityFreeModifyView> createState() => _CommunityFreeModifyViewState();
}

class _CommunityFreeModifyViewState extends State<CommunityFreeModifyView> {
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
  bool? isModifiedImageSelected = false;
  RxString? SelectedCategory = ''.obs;
  RxString? SelectedLocation = ''.obs;
  String? title = '';
  final _formKey = GlobalKey<FormState>();
  RxList? _imageUrls=[].obs;
  String? _initTitle ;
  String? _initdescrip ;
  late quill.QuillController _quillController = quill.QuillController.basic();


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
    _quillController = quill.QuillController.basic();
  }

  @override
  Widget build(BuildContext context) {
    //TODO : ****************************************************************
    Get.put(ImageController(), permanent: true);
    UserModelController _userModelController = Get.find<UserModelController>();
    BulletinFreeModelController _bulletinFreeModelController = Get.find<BulletinFreeModelController>();
    ImageController _imageController = Get.find<ImageController>();
    //TODO : ****************************************************************


    Future<void> _modifyBulletin() async {
      final isValid = _formKey.currentState!.validate();

      if (_tileSelected["구분"]!.isEmpty) {
        Get.snackbar(
          '선택되지않은 항목',
          '구분을 선택해주세요.',
          margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: Duration(milliseconds: 3000),
        );
      } else {
        if (isValid) {
          CustomFullScreenDialog.showDialog();
          await _userModelController.bulletinFreeCountUpdate(_userModelController.uid);

          // bulletinFreeCount가 null인지 확인하고 초기화
          int bulletinFreeCount = _userModelController.bulletinFreeCount ?? 0;

          await _imageController.setNewMultiImage_bulletinFree(_imageFiles, bulletinFreeCount);

          // Delta 문서의 이미지를 Firebase Storage에 업로드
          List<quill.Operation> ops = _quillController.document.toDelta().toList();
          await _imageController.uploadDeltaImages(ops, bulletinFreeCount);

          final deltaJson = jsonEncode(ops);

          if (isModifiedImageSelected == true) {
            await _bulletinFreeModelController.updateBulletinFree(
              displayName: _userModelController.displayName,
              uid: _userModelController.uid,
              profileImageUrl: _userModelController.profileImageUrl,
              itemImagesUrls: _imageController.imagesUrlList,
              title: _titleTextEditingController.text,
              category: SelectedCategory!.value,
              location: SelectedLocation!.value,
              description: deltaJson, // Quill 문서를 Delta 형식으로 저장
              bulletinFreeCount: bulletinFreeCount,
              resortNickname: _userModelController.resortNickname,
              likeCount: _bulletinFreeModelController.likeCount,
              hot: _bulletinFreeModelController.hot,
              score: _bulletinFreeModelController.score,
              viewerUid: _bulletinFreeModelController.viewerUid,
              timeStamp: _bulletinFreeModelController.timeStamp,
            );
          } else {
            await _bulletinFreeModelController.updateBulletinFree(
              displayName: _userModelController.displayName,
              uid: _userModelController.uid,
              profileImageUrl: _userModelController.profileImageUrl,
              itemImagesUrls: _imageUrls,
              title: _titleTextEditingController.text,
              category: SelectedCategory!.value,
              location: SelectedLocation!.value,
              description: deltaJson, // Quill 문서를 Delta 형식으로 저장
              bulletinFreeCount: bulletinFreeCount,
              resortNickname: _userModelController.resortNickname,
              likeCount: _bulletinFreeModelController.likeCount,
              hot: _bulletinFreeModelController.hot,
              score: _bulletinFreeModelController.score,
              viewerUid: _bulletinFreeModelController.viewerUid,
              timeStamp: _bulletinFreeModelController.timeStamp,
            );
          }

          await _bulletinFreeModelController.getCurrentBulletinFree(
              uid: _userModelController.uid,
              bulletinFreeCount: bulletinFreeCount
          );

          CustomFullScreenDialog.cancelDialog();

          for (int i = 0; i < 2; i++) {
            Get.back();
          }

          _imageController.imagesUrlList.clear();
        }
      }
    }

    TextButton(
      onPressed: _modifyBulletin,
      child: Padding(
        padding: EdgeInsets.only(right: 10),
        child: Text(
          '수정완료',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3D83ED),
          ),
        ),
      ),
    );




    Size _size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: AppBar(
              title: Text('게시글 수정',
                style: SDSTextStyle.extraBold.copyWith(
                    fontSize: 18,
                    color: SDSColor.gray900
                ),
              ),
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
                    onPressed: _modifyBulletin,
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
