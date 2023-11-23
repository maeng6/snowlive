import 'dart:io';

import 'package:com.snowlive/controller/vm_commentController.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controller/vm_liveCrewModelController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../widget/w_fullScreenDialog.dart';
import '../../controller/vm_imageController.dart';

class Modify_liveTalk extends StatefulWidget {
  const Modify_liveTalk({Key? key}) : super(key: key);

  @override
  State<Modify_liveTalk> createState() => _Modify_liveTalkState();
}

class _Modify_liveTalkState extends State<Modify_liveTalk> {

  String? _initComment ;
  String? _initLiveTalkImageUrl;
  TextEditingController _liveTalkTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;
  String? _liveTalkImageUrl;
  bool _liveTalkImageSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CommentModelController _commentModelController = Get.find<CommentModelController>();
    _initComment = _commentModelController.comment;
    _initLiveTalkImageUrl = _commentModelController.livetalkImageUrl;
    _imageFile = null;

  }

  @override
  Widget build(BuildContext context) {
    //TODO : ****************************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
    CommentModelController _commentModelController = Get.find<CommentModelController>();
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
              title: Text('라이브톡 수정',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),),
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

                        String? livetalkImageUrl = _initLiveTalkImageUrl;
                        if (_imageFile != null) {
                          livetalkImageUrl = await _imageController.setNewImage_livetalk(_imageFile!, _userModelController.commentCount);
                          await _commentModelController.updateLivetalkImageUrl(livetalkImageUrl);
                        }

                        await _commentModelController.updateLiveTalk(
                            comment: _liveTalkTextEditingController.text,
                            uid: _commentModelController.uid,
                            commentCount: _commentModelController.commentCount,
                            livetalkImageUrl: livetalkImageUrl);
                        await _commentModelController.getCurrentLiveTalk(uid: _commentModelController.uid, commentCount: _commentModelController.commentCount);
                        CustomFullScreenDialog.cancelDialog();
                        Navigator.pop(context);
                        Get.back();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text('변경완료', style: TextStyle(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_initLiveTalkImageUrl != "")
                      Stack(
                        children: [
                          (_liveTalkImageSelected == false)
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  child: ExtendedImage.network(
                            _initLiveTalkImageUrl!,
                            cache: true,
                            //cacheHeight: 1600,
                            width: _size.width - 32,
                            height: _size.width - 32,
                            fit: BoxFit.cover,
                          ),
                                ),
                              )
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                            File(_initLiveTalkImageUrl!),
                            width: _size.width - 32,
                            height: _size.width - 32,
                            fit: BoxFit.cover,
                          ),
                              ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.cancel,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _initLiveTalkImageUrl = '';
                                  _liveTalkImageSelected = false;
                                  _imageFile = null;
                                });
                              },
                            ),)
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
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
                                                      CustomFullScreenDialog.cancelDialog();
                                                      _initLiveTalkImageUrl = _imageFile!.path;
                                                      _liveTalkImageSelected = true;
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
                                                      CustomFullScreenDialog.cancelDialog();
                                                      _initLiveTalkImageUrl = _imageFile!.path;
                                                      _liveTalkImageSelected = true;
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
                    SizedBox(
                      height: 36,
                    ),
                    Form(
                        key: _formKey,
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '라이브톡 내용',
                              style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF1F3F3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    onTap: (){
                                      _liveTalkTextEditingController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(offset: _liveTalkTextEditingController.text.length));
                                    },
                                    minLines: 1,
                                    maxLines: 50,
                                    textAlignVertical: TextAlignVertical.top,
                                    cursorColor: Color(0xff377EEA),
                                    cursorHeight: 16,
                                    cursorWidth: 2,
                                    textAlign: TextAlign.start,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    controller: _liveTalkTextEditingController..text = '$_initComment',
                                    onChanged: (comment){
                                      _initComment = comment;
                                    },
                                    strutStyle: StrutStyle(leading: 0.3),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        errorStyle: TextStyle(
                                          fontSize: 12,
                                        ),
                                        labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                        hoverColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                        hintText: '내용을 작성해 주세요. (최대 1,000자)',
                                        border: InputBorder.none,
                                        errorBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent),
                                        )
                                    ),
                                    validator: (val) {
                                      if (val!.length <= 1000 && val.length >= 0) {
                                        return null;
                                      } else if (val.length == 0 || val == "") {
                                        return '스라지기 라톡입력!';
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
