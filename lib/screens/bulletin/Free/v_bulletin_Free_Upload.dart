import 'dart:io';
import 'package:com.snowlive/screens/bulletin/Free/v_bulletin_Free_List_Detail.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/bulletin/vm_bulletinFreeController.dart';
import '../../../controller/public/vm_imageController.dart';
import '../../../controller/user/vm_userModelController.dart';
import '../../../model/m_bulletinFreeModel.dart';
import '../../../widget/w_fullScreenDialog.dart';

class Bulletin_Free_Upload extends StatefulWidget {
  const Bulletin_Free_Upload({Key? key}) : super(key: key);

  @override
  State<Bulletin_Free_Upload> createState() => _Bulletin_Free_UploadState();
}

class _Bulletin_Free_UploadState extends State<Bulletin_Free_Upload> {
  List<XFile> _imageFiles = [];
  Map<String, String?> _tileSelected = {
    "구분": '',
  };
  bool? bulletinFreeImageSelected = false;
  int i = 0;
  int imageLength = 0;
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _itemDescribTextEditingController = TextEditingController();
  bool? isCategorySelected = false;
  String? SelectedCategory = '';
  String? SelectedLocation = '';
  String? title = '';
  final _formKey = GlobalKey<FormState>();

  ListTile buildCategoryListTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${bulletinFreeCategoryList[index]}',
        style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
      ),
      onTap: () async {
        isCategorySelected = true;
        SelectedCategory = bulletinFreeCategoryList[index];
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
            preferredSize: Size.fromHeight(44),
            child: AppBar(
              title: Text('자유 게시글 작성',
                style: SDSTextStyle.extraBold.copyWith(
                fontSize: 18,
                  color: SDSColor.gray900
              ),),
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
                      else{

                        if(isValid){
                          CustomFullScreenDialog.showDialog();
                          await _userModelController.bulletinFreeCountUpdate(_userModelController.uid);
                          await _imageController.setNewMultiImage_bulletinFree(_imageFiles, _userModelController.bulletinFreeCount);
                          await _bulletinFreeModelController.uploadBulletinFree(
                              displayName: _userModelController.displayName,
                              uid: _userModelController.uid,
                              profileImageUrl: _userModelController.profileImageUrl,
                              itemImagesUrls: _imageController.imagesUrlList,
                              title: _titleTextEditingController.text,
                              category: SelectedCategory,
                              description: _itemDescribTextEditingController.text,
                              bulletinFreeCount: _userModelController.bulletinFreeCount,
                              resortNickname: _userModelController.resortNickname
                          );

                          await _bulletinFreeModelController.getCurrentBulletinFree(
                              uid: _userModelController.uid,
                              bulletinFreeCount: _userModelController.bulletinFreeCount);

                          CustomFullScreenDialog.cancelDialog();
                          Get.off(() => Bulletin_Free_List_Detail());
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
                    SizedBox(
                      height: 16,
                    ),
                    // Row(
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () async {
                    //         if (imageLength >= 5) {
                    //           Get.dialog(
                    //             AlertDialog(
                    //               title: Text('사진 개수 초과'),
                    //             ),
                    //           );
                    //         } else {
                    //           CustomFullScreenDialog.showDialog();
                    //           try {
                    //             _imageFiles = await _imageController.getMultiImage(ImageSource.gallery);
                    //             CustomFullScreenDialog.cancelDialog();
                    //             if (_imageFiles.length <= 5) {
                    //               bulletinFreeImageSelected = true;
                    //               imageLength = _imageFiles.length;
                    //               setState(() {});
                    //             } else {
                    //               Get.dialog(
                    //                 AlertDialog(
                    //                   title: Text('사진 개수 초과'),
                    //                 ),
                    //               );
                    //             }
                    //           } catch (e) {
                    //             CustomFullScreenDialog.cancelDialog();
                    //           }
                    //         }
                    //       },
                    //       child: Container(
                    //         height: 90,
                    //         width: 90,
                    //         child: Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             IconButton(
                    //               onPressed: () async {
                    //                 if (imageLength >= 5) {
                    //                   Get.dialog(
                    //                     AlertDialog(
                    //                       title: Text('사진 개수 초과'),
                    //                     ),
                    //                   );
                    //                 } else {
                    //                   CustomFullScreenDialog.showDialog();
                    //                   try {
                    //                     _imageFiles = await _imageController.getMultiImage(ImageSource.gallery);
                    //                     CustomFullScreenDialog.cancelDialog();
                    //                     if (_imageFiles.length <= 5) {
                    //                       bulletinFreeImageSelected = true;
                    //                       imageLength = _imageFiles.length;
                    //                       setState(() {});
                    //                     } else {
                    //                       Get.dialog(
                    //                         AlertDialog(
                    //                           title: Text('사진 개수 초과'),
                    //                         ),
                    //                       );
                    //                     }
                    //                   } catch (e) {
                    //                     CustomFullScreenDialog.cancelDialog();
                    //                   }
                    //                 }
                    //               },
                    //               icon: Icon(Icons.camera_alt_rounded),
                    //               color: Color(0xFF949494),
                    //             ),
                    //             Transform.translate(
                    //               offset: Offset(0, -10),
                    //               child: Text(
                    //                 '$imageLength / 5',
                    //                 style: TextStyle(
                    //                   fontWeight: FontWeight.bold,
                    //                   fontSize: 15,
                    //                   color: Color(0xFF949494),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         decoration: BoxDecoration(
                    //           border: Border.all(
                    //             color: Colors.transparent,
                    //           ),
                    //           borderRadius: BorderRadius.circular(8),
                    //           color: Color(0xFFececec),
                    //         ),
                    //       ),
                    //     ),
                    //     SizedBox(
                    //       width: 8,
                    //     ),
                    //     if(_imageFiles.length == 0)
                    //       SizedBox(width: 8,),
                    //     if(_imageFiles.length == 0)
                    //       Text('사진은 게시글에 첨부됩니다.',
                    //         style: TextStyle(
                    //             color: Color(0xff949494),
                    //             fontSize: 12
                    //         ),
                    //       ),
                    //     Expanded(
                    //       child: SizedBox(
                    //         height: 120,
                    //         child: ListView.builder(
                    //           scrollDirection: Axis.horizontal,
                    //           shrinkWrap: true,
                    //           itemCount: imageLength,
                    //           itemBuilder: (context, index) {
                    //             return Row(
                    //               children: [
                    //                 Stack(children: [
                    //
                    //                   Container(
                    //                     decoration: BoxDecoration(
                    //                         border: Border.all(color: Color(0xFFECECEC)),
                    //                         borderRadius: BorderRadius.circular(8),
                    //                         color: Colors.white
                    //                     ),
                    //                     height: 90,
                    //                     width: 90,
                    //                     child: ClipRRect(
                    //                       borderRadius: BorderRadius.circular(7),
                    //                       child: Image.file(
                    //                         File(_imageFiles[index].path),
                    //                         fit: BoxFit.cover,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   Positioned(
                    //                     top: -8,
                    //                     right: -8,
                    //                     child: IconButton(
                    //                       onPressed: () {
                    //                         _imageFiles.removeAt(index);
                    //                         imageLength = _imageFiles.length;
                    //                         setState(() {});
                    //                       },
                    //                       icon: Icon(Icons.cancel), color: Color(0xFF111111),),
                    //                   ),
                    //                   if(index==0)
                    //                     Positioned(
                    //                       top: 68,
                    //                       child: Opacity(
                    //                         opacity:0.8,
                    //                         child: Container(
                    //                           decoration: BoxDecoration(
                    //                             border: Border.all(
                    //                                 color: Colors.transparent
                    //                             ),
                    //                             borderRadius: BorderRadius.only(
                    //                                 bottomRight: Radius.circular(8),
                    //                                 bottomLeft: Radius.circular(8)
                    //                             ),
                    //                             color: Colors.black87,
                    //                           ),
                    //                           height: 22,
                    //                           width: 90,
                    //                           child: ClipRRect(
                    //                             borderRadius: BorderRadius.circular(7),
                    //                             child: Text('대표사진',
                    //                               style: TextStyle(color: Colors.white,
                    //                                   fontSize: 12),
                    //                               textAlign: TextAlign.center,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                 ]),
                    //                 SizedBox(
                    //                   width: 8,
                    //                 )
                    //               ],
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     )
                    //   ],
                    // ),
                    Form(
                        key: _formKey,
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text('제목', style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.gray900
                                  ),),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: SDSColor.snowliveBlue,
                                  cursorHeight: 16,
                                  cursorWidth: 2,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  controller: _titleTextEditingController,
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 15
                                  ),
                                  strutStyle: StrutStyle(
                                      fontSize: 14, leading: 0),
                                  decoration: InputDecoration(
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    errorMaxLines: 2,
                                    errorStyle: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.red,
                                    ),
                                    labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintText: '글 제목을 입력해 주세요. (최대 50자)',
                                    labelText: '글 제목',
                                      contentPadding: EdgeInsets.only(
                                          top: 14, bottom: 14, left: 12, right: 12),
                                      fillColor: SDSColor.gray50,
                                      hoverColor: SDSColor.snowliveBlue,
                                      filled: true,
                                      focusColor: SDSColor.snowliveBlue,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: SDSColor.gray50),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      errorBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: SDSColor.red,
                                            strokeAlign: BorderSide.strokeAlignInside,
                                            width: 1.5),
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: SDSColor.snowliveBlue,
                                            strokeAlign: BorderSide.strokeAlignInside,
                                            width: 1.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                        borderRadius: BorderRadius.circular(6),
                                      )),
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
                                SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text('게시글 종류', style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.gray900
                                  ),),
                                ),
                                SizedBox(height: 8),
                                GestureDetector(
                                  onTap: (){
                                    showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        enableDrag: false,
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            height: 350,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                              color: SDSColor.snowliveWhite,
                                            ),
                                            padding: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 20),
                                                      child: Container(
                                                        height: 4,
                                                        width: 36,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: SDSColor.gray200,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '구분을 선택해주세요.',
                                                      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    SizedBox(height: 24),
                                                  ],
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
                                  child: Container(
                                    height: 48,
                                    width: _size.width - 32,
                                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: SDSColor.gray50
                                      ),
                                      color: SDSColor.gray50,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        (isCategorySelected!)
                                            ? Text('$SelectedCategory',
                                          style: SDSTextStyle.regular.copyWith(color: SDSColor.gray900, fontSize: 14),
                                        )
                                            : Text('구분',
                                          style: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                        ),
                                        Image.asset(
                                          'assets/imgs/icons/icon_textform_dropdown.png',
                                          fit: BoxFit.cover,
                                          width: 22,
                                          height: 22,
                                          color: SDSColor.gray700,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text('상세 설명', style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.gray900
                                  ),),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  maxLines: null,
                                  textAlignVertical: TextAlignVertical.top,
                                  cursorColor: SDSColor.snowliveBlue,
                                  cursorHeight: 16,
                                  cursorWidth: 2,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  controller: _itemDescribTextEditingController,
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 15
                                  ),
                                  strutStyle: StrutStyle(
                                      fontSize: 14, leading: 0),
                                  decoration: InputDecoration(
                                      alignLabelWithHint: true,
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      errorMaxLines: 2,
                                      errorStyle: SDSTextStyle.regular.copyWith(
                                        fontSize: 12,
                                        color: SDSColor.red,
                                      ),
                                      labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                      hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintText: '게시글 상세 내용을 작성해 주세요.\n \n 부적절한 부적절한 단어나 문장이 포함되는 경우 사전 고지없이 게시글 삭제가 될 수 있습니다.',
                                    labelText: '내용',
                                      contentPadding: EdgeInsets.only(
                                          top: 14, bottom: 14, left: 12, right: 12),
                                      fillColor: SDSColor.gray50,
                                      hoverColor: SDSColor.snowliveBlue,
                                      filled: true,
                                      focusColor: SDSColor.snowliveBlue,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: SDSColor.gray50),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      errorBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: SDSColor.red,
                                            strokeAlign: BorderSide.strokeAlignInside,
                                            width: 1.5),
                                      ),
                                      focusedBorder:  OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: SDSColor.snowliveBlue,
                                            strokeAlign: BorderSide.strokeAlignInside,
                                            width: 1.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent),
                                        borderRadius: BorderRadius.circular(6),
                                      )),
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
