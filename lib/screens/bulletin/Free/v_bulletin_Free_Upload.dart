import 'dart:io' as io;
import 'package:com.snowlive/screens/bulletin/Free/v_bulletin_Free_List_Detail.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
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
  bool? isCategorySelected = false;
  String? SelectedCategory = '';
  String? SelectedLocation = '';
  String? title = '';
  final _formKey = GlobalKey<FormState>();
  late quill.QuillController _quillController = quill.QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
  }

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

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final imageUrl = await _uploadImageToServer(bytes); // 이미지 업로드 로직 구현 필요
      if (mounted) {
        setState(() {
          _imageFiles.add(pickedImage);
          _insertImage(imageUrl);
        });
      }
      print('pickImage : ${_imageFiles}');
    }
  }

  Future<String> _uploadImageToServer(Uint8List bytes) async {
    // 여기에 서버 업로드 로직을 구현하세요.
    // 서버에 업로드 후 이미지 URL을 반환합니다.
    return 'https://yourserver.com/uploaded_image.png';
  }

  void _insertImage(String imageUrl) {
    if (!mounted) return;
    final index = _quillController.selection.baseOffset;
    final length = _quillController.selection.extentOffset - index;
    _quillController.replaceText(index, length, quill.BlockEmbed.custom(CustomImageEmbed(imageUrl)), TextSelection.collapsed(offset: index + 1));
    print('insertImage : ${_imageFiles}');
  }

  @override
  void dispose() {
    _quillController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
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
                              description: _quillController.document.toPlainText(),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
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
                        ),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text('상세 설명', style: SDSTextStyle.regular.copyWith(
                                    fontSize: 12,
                                    color: SDSColor.gray900
                                ),),
                              ),
                              SizedBox(height: 8),
                              Column(
                                children: [
                                  quill.QuillToolbar.simple(
                                    configurations:
                                    quill.QuillSimpleToolbarConfigurations(
                                      controller: _quillController,
                                      sharedConfigurations: quill.QuillSharedConfigurations(
                                          dialogBarrierColor: SDSColor.snowliveBlack.withOpacity(0.3),
                                          dialogTheme: quill.QuillDialogTheme(
                                            buttonTextStyle: SDSTextStyle.bold.copyWith(
                                                color: SDSColor.gray900,
                                                fontSize: 16
                                            ),
                                            labelTextStyle: SDSTextStyle.bold.copyWith(
                                                color: SDSColor.gray400,
                                                fontSize: 14
                                            ),
                                            inputTextStyle:  SDSTextStyle.bold.copyWith(
                                                color: SDSColor.gray900,
                                                fontSize: 14
                                            ),
                                            dialogBackgroundColor: SDSColor.snowliveWhite,
                                          )
                                      ),
                                      showFontFamily: false,
                                      showFontSize: false,
                                      showBoldButton: true,
                                      showItalicButton: true,
                                      showSmallButton: false,
                                      showUnderLineButton: true,
                                      showStrikeThrough: true,
                                      showInlineCode: false,
                                      showColorButton: false,
                                      showBackgroundColorButton: false,
                                      showClearFormat: false,
                                      showAlignmentButtons: false,
                                      showLeftAlignment: false,
                                      showCenterAlignment: false,
                                      showRightAlignment: false,
                                      showJustifyAlignment: false,
                                      showHeaderStyle: false,
                                      showListNumbers: false,
                                      showListBullets: false,
                                      showListCheck: false,
                                      showCodeBlock: false,
                                      showQuote: false,
                                      showIndent: false,
                                      showLink: true,
                                      showUndo: false,
                                      showRedo: false,
                                      showDirection: false,
                                      showSearchButton: false,
                                      showSubscript: false,
                                      showSuperscript: false,
                                      showClipboardCut: false,
                                      showClipboardCopy: false,
                                      showClipboardPaste: false,
                                      customButtons: [
                                        quill.QuillToolbarCustomButtonOptions(
                                          icon: quill.QuillToolbarCustomButton(
                                            controller: _quillController,
                                            options: quill.QuillToolbarCustomButtonOptions(
                                              icon: Icon(Icons.image),
                                              onPressed: _pickImage,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 1000,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: SDSColor.gray50,
                                    ),
                                    child: Container(
                                      height: 1000,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: SDSColor.gray50,
                                      ),
                                      child: quill.QuillEditor(
                                        focusNode: _focusNode,
                                        scrollController: _scrollController,
                                        configurations: quill.QuillEditorConfigurations(
                                          controller: _quillController,
                                          padding: const EdgeInsets.all(16),
                                          scrollable: true,
                                          placeholder: 'Start writing your notes...',
                                          embedBuilders: [
                                            CustomEmbedBuilder(
                                              type: 'image',
                                              builder: _imageBuilder,
                                            ),
                                          ],
                                          customStyles: DefaultStyles(
                                            h1: DefaultTextBlockStyle(
                                              TextStyle(fontSize: 32, height: 1.15, fontWeight: FontWeight.w300),
                                              const HorizontalSpacing(0, 0),
                                              const VerticalSpacing(16, 0),
                                              const VerticalSpacing(0, 0),
                                              null,
                                            ),
                                            sizeSmall: TextStyle(fontSize: 9),
                                          ),
                                          onImagePaste: (imageBytes) async {
                                            final newFileName = 'imageFile-${DateTime.now().toIso8601String()}.png';
                                            final newPath = io.Directory.systemTemp.path + newFileName;
                                            final file = await io.File(newPath).writeAsBytes(imageBytes, flush: true);
                                            return file.path;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
          ),
        ),
      ),
    );
  }
}

Widget _imageBuilder(BuildContext context, String imageUrl, bool readOnly) {
  return Image.network(imageUrl);
}
