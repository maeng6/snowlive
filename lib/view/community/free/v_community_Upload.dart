import 'dart:convert';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityBulletinList.dart';
import 'package:com.snowlive/viewmodel/community/vm_communityUpload.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_bulletin_quill_toolbar.dart';
import 'package:com.snowlive/widget/w_category_main_commu_bulletin.dart';
import 'package:com.snowlive/widget/w_category_main_commu_event.dart';
import 'package:com.snowlive/widget/w_category_sub_commu_bulletin_room.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

import '../../../widget/w_community_Free_Quill_editor.dart';

class CommunityBulletinUpload extends StatelessWidget {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CommunityUploadViewModel _communityUploadViewModel = Get.find<CommunityUploadViewModel>();
  final CommunityBulletinListViewModel _communityBulletinListViewModel = Get.find<CommunityBulletinListViewModel>();

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    String? selectedCategory_main;
    String? selectedCategory_sub;



    return Obx(()=>Container(
          color: Colors.white,
          child: SafeArea(
            top: false,
            bottom: true,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(44),
                child: AppBar(
                  title: Text('게시글 작성',
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
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0.0,
                ),
              ),
              body: Container(
                height: _size.height - _statusBarSize - 44,
                child: GestureDetector(
                  onTap: (){
                    FocusScope.of(context).unfocus();
                  },
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Form(
                              key: _communityUploadViewModel.formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 14, left: 4),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('제목',
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 13,
                                                    color: SDSColor.gray900
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 2, top: 2),
                                                child: Container(
                                                  width: 4,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: SDSColor.red,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        TextFormField(
                                          textAlignVertical: TextAlignVertical.center,
                                          cursorColor: SDSColor.snowliveBlue,
                                          cursorHeight: 16,
                                          cursorWidth: 2,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          controller: _communityUploadViewModel.textEditingController_title,
                                          style: SDSTextStyle.regular.copyWith(fontSize: 15),
                                          strutStyle: StrutStyle(fontSize: 14, leading: 0),
                                          decoration: InputDecoration(
                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                              errorMaxLines: 2,
                                              errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                              labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                              hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                              hintText: '글 제목을 입력해 주세요. (최대 30자)',
                                              labelText: '글 제목',
                                              contentPadding: EdgeInsets.only(
                                                  top: 10, bottom: 10, left: 12, right: 12),
                                              fillColor: SDSColor.gray50,
                                              hoverColor: SDSColor.snowliveBlue,
                                              filled: true,
                                              focusColor: SDSColor.snowliveBlue,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(color: SDSColor.gray50),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.transparent),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          validator: (val) {
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              if (val!.length <= 30 && val.length >= 1) {
                                                _communityUploadViewModel.changeTitleWritten(true);
                                              } else {
                                                _communityUploadViewModel.changeTitleWritten(false);
                                              }
                                            });
                                            if (val!.length <= 30 && val.length >= 1) {
                                              return null;
                                            } else if (val.length == 0) {
                                              return '글 제목을 입력해주세요.';
                                            } else {
                                              return '최대 입력 가능한 글자 수를 초과했습니다.';
                                            }
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 32, left: 4),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('게시글 종류', style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 13,
                                                  color: SDSColor.gray900
                                              ),),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 2, top: 2),
                                                child: Container(
                                                  width: 4,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(10),
                                                    color: SDSColor.red,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Obx(() =>
                                        (_communityBulletinListViewModel.tapName == '게시판')
                                            ?Row(
                                          children: [
                                            Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    selectedCategory_main = await showModalBottomSheet<String>(
                                                      constraints: BoxConstraints(
                                                        maxHeight: 360,
                                                      ),
                                                      backgroundColor: Colors.transparent,
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (context) => CategoryMainCommuBulletinWidget(),
                                                    );
                                                    if(_communityUploadViewModel.isCategorySelected==true)
                                                      _communityUploadViewModel.resetCategorySub();
                                                    if(selectedCategory_main != null)
                                                      _communityUploadViewModel.selectCategoryMain(selectedCategory_main!);
                                                    _communityUploadViewModel.setIsSelectedCategoryFalse();
                                                  },
                                                  child: Container(
                                                    width:
                                                    (_communityUploadViewModel.selectedCategoryMain == '시즌방')
                                                    ? _size.width / 2 - 21
                                                    : _size.width - 32,
                                                    height: 48,
                                                    decoration: BoxDecoration(
                                                      color: SDSColor.gray50,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                                    child: Obx(()=>Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(_communityUploadViewModel.selectedCategoryMain,
                                                          style: SDSTextStyle.regular.copyWith(
                                                            color: _communityUploadViewModel.selectedCategoryMain == '상위 카테고리' ? SDSColor.gray400 : SDSColor.gray900,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Image.asset(
                                                          'assets/imgs/icons/icon_dropdown.png',
                                                          fit: BoxFit.cover,
                                                          width: 20,
                                                        ),
                                                      ],
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            (_communityUploadViewModel.selectedCategoryMain == '시즌방')
                                            ? SizedBox(width: 8)
                                            : Container(),
                                            (_communityUploadViewModel.selectedCategoryMain == '시즌방')
                                            ? GestureDetector(
                                              onTap: () async {
                                                if( _communityUploadViewModel.selectedCategoryMain == '시즌방')
                                                  selectedCategory_sub = await showModalBottomSheet<String>(
                                                    constraints: BoxConstraints(
                                                      maxHeight: 360,
                                                    ),
                                                    backgroundColor: Colors.transparent,
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) => CategorySubCommuBulletinRoomWidget(),
                                                  );
                                                  if(selectedCategory_sub != null) {
                                                    _communityUploadViewModel.selectCategorySub(selectedCategory_sub!);
                                                    _communityUploadViewModel.setIsSelectedCategoryTrue();
                                                  }
                                              },
                                              child: Container(
                                                width: _size.width / 2 - 21,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: SDSColor.gray50,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 12),
                                                child: Obx(()=>Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(_communityUploadViewModel.selectedCategorySub,
                                                      style: SDSTextStyle.regular.copyWith(
                                                        color: _communityUploadViewModel.selectedCategorySub == '하위 카테고리' ? SDSColor.gray400 : SDSColor.gray900,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Image.asset(
                                                      'assets/imgs/icons/icon_dropdown.png',
                                                      fit: BoxFit.cover,
                                                      width: 20,
                                                    ),
                                                  ],
                                                )),
                                              ),
                                            )
                                            : Container(),

                                          ],
                                        )
                                            :Row(
                                          children: [
                                            Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    selectedCategory_main = await showModalBottomSheet<String>(
                                                      constraints: BoxConstraints(
                                                        maxHeight: 360,
                                                      ),
                                                      backgroundColor: Colors.transparent,
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (context) => CategoryMainCommuEventWidget(),
                                                    );
                                                    if(_communityUploadViewModel.isCategorySelected==true)
                                                      _communityUploadViewModel.resetCategorySub();
                                                    if(selectedCategory_main != null)
                                                      _communityUploadViewModel.selectCategoryMain(selectedCategory_main!);
                                                    _communityUploadViewModel.setIsSelectedCategoryFalse();
                                                  },
                                                  child: Container(
                                                    width: _size.width - 32,
                                                    height: 48,
                                                    decoration: BoxDecoration(
                                                      color: SDSColor.gray50,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                                    child: Obx(()=>Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(_communityUploadViewModel.selectedCategoryMain,
                                                          style: SDSTextStyle.regular.copyWith(
                                                            color: _communityUploadViewModel.selectedCategoryMain == '상위 카테고리' ? SDSColor.gray400 : SDSColor.gray900,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Image.asset(
                                                          'assets/imgs/icons/icon_dropdown.png',
                                                          fit: BoxFit.cover,
                                                          width: 20,
                                                        ),
                                                      ],
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ],
                                        )
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 32, left: 4),
                                          child: Text('상세 설명', style: SDSTextStyle.regular.copyWith(
                                              fontSize: 13,
                                              color: SDSColor.gray900
                                          ),),
                                        ),
                                        SizedBox(height: 8),
                                        if (!_communityUploadViewModel.isReadOnly)
                                          BulletinQuillToolbar(
                                            controller: _communityUploadViewModel.quillController,
                                            focusNode: _communityUploadViewModel.focusNode,
                                          ),
                                        Builder(
                                          builder: (context) {
                                            return MyQuillEditor(
                                              configurations: QuillEditorConfigurations(
                                                sharedConfigurations: const QuillSharedConfigurations(
                                                  locale: Locale('ko'),
                                                ),
                                                controller: _communityUploadViewModel.quillController,
                                              ),
                                              scrollController: _communityUploadViewModel.scrollController,
                                              focusNode: _communityUploadViewModel.focusNode,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 120,
                            )
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: SDSColor.snowliveWhite,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: ElevatedButton(
                              onPressed: () async {

                                if(_communityUploadViewModel.isTitleWritten == true
                                    && _communityUploadViewModel.selectedCategoryMain != '상위 카테고리'
                                    && (_communityUploadViewModel.selectedCategoryMain != '시즌방' || (_communityUploadViewModel.selectedCategoryMain == '시즌방'&&_communityUploadViewModel.selectedCategorySub != '하위 카테고리'))
                                   ){

                                CustomFullScreenDialog.showDialog();
                                  await _communityUploadViewModel.createCommunityPost({
                                    "user_id": _userViewModel.user.user_id.toString(), // 필수 - 유저 ID
                                    "category_main":
                                    (_communityBulletinListViewModel.tapName=='게시판')
                                    ? "게시판"
                                    : "이벤트",    // 필수 - 메인 카테고리
                                    "category_sub": "${_communityUploadViewModel.selectedCategoryMain}",     // 필수 - 서브 카테고리
                                    "category_sub2": "${_communityUploadViewModel.selectedCategorySub}",     // 선택 - 시즌방서브카테고리
                                    "title": "${_communityUploadViewModel.textEditingController_title.text}",     // 필수 - 제목
                                    "thumb_img_url": "",
                                    "description": jsonEncode([{
                                      "insert": ""
                                    }])
                                  });

                                  print('임시글 생성 완료');
                                  await _communityUploadViewModel.uploadAndReplaceImageInDelta(_communityUploadViewModel.quillController.document.toDelta().toList(), _communityUploadViewModel.pk);
                                  print('이미지 링크 생성 완료');
                                  final deltaList = _communityUploadViewModel.quillController.document.toDelta().toList();
                                  final jsonString = jsonEncode(deltaList);
                                  print(jsonString);
                                  print(_communityUploadViewModel.findFirstInsertedImage(_communityUploadViewModel.quillController.document.toDelta().toList()));
                                  await _communityUploadViewModel.updateCommunityPost(_communityUploadViewModel.pk,
                                      {
                                        "user_id": _userViewModel.user.user_id.toString(),
                                        "thumb_img_url": _communityUploadViewModel.findFirstInsertedImage(_communityUploadViewModel.quillController.document.toDelta().toList()),
                                        "description" : jsonString
                                      });

                                  CustomFullScreenDialog.cancelDialog();
                                  Navigator.pop(context);
                                  await _communityBulletinListViewModel.fetchEventCommunity();
                                }


                              },
                              style: TextButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                ),
                                elevation: 0,
                                splashFactory: InkRipple.splashFactory,
                                minimumSize: Size(double.infinity, 48),
                                backgroundColor:
                                (_communityUploadViewModel.isTitleWritten == true
                                    && _communityUploadViewModel.selectedCategoryMain != '상위 카테고리'
                                    && (_communityUploadViewModel.selectedCategoryMain != '시즌방' || (_communityUploadViewModel.selectedCategoryMain == '시즌방'&&_communityUploadViewModel.selectedCategorySub != '하위 카테고리'))
                                   )
                                    ? SDSColor.snowliveBlue
                                    : SDSColor.gray200,
                              ),
                              child:

                               Text('작성 완료',
                                style: SDSTextStyle.bold.copyWith(
                                    color:
                                    (_communityUploadViewModel.isTitleWritten == true
                                        && _communityUploadViewModel.selectedCategoryMain != '상위 카테고리'
                                        && (_communityUploadViewModel.selectedCategoryMain != '시즌방' || (_communityUploadViewModel.selectedCategoryMain == '시즌방'&&_communityUploadViewModel.selectedCategorySub != '하위 카테고리'))
                                        )
                                    ? SDSColor.snowliveWhite
                                    : SDSColor.gray400,
                                    fontSize: 16),
                              )

                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}