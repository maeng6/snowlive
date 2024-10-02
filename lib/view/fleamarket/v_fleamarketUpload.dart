import 'dart:io';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketUpload.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_category_main_fleamarket.dart';
import 'package:com.snowlive/widget/w_category_sub_board_fleamarket.dart';
import 'package:com.snowlive/widget/w_category_sub_ski_fleamarket.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:com.snowlive/widget/w_tradeMethod_fleamarket.dart';
import 'package:com.snowlive/widget/w_tradeSpot_fleamarket.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../viewmodel/fleamarket/vm_fleamarketUpdate.dart';

class FleamarketUploadView extends StatelessWidget {

  final FleamarketUploadViewModel _fleamarketUploadViewModel = Get.find<FleamarketUploadViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FleamarketListViewModel _fleamarketListViewModel = Get.find<FleamarketListViewModel>();
  final FleamarketUpdateViewModel _fleamarketUpdateViewModel = Get.find<FleamarketUpdateViewModel>();

  final FocusNode titleFocusNode = FocusNode();
  final FocusNode productNameFocusNode = FocusNode();
  final FocusNode priceFocusNode = FocusNode();
  final FocusNode urlFocusNode = FocusNode();
  final FocusNode descFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    String? selectedCategory_main;
    String? selectedCategory_sub;
    String? selectedCategory_tradeMethod;
    String? selectedCategory_tradeSpot;

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
              title: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Column(
                  children: [
                    Text(
                      '내 물건 팔기',
                      style: SDSTextStyle.extraBold.copyWith(
                          color: SDSColor.gray900,
                          fontSize: 18),
                    ),
                  ],
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
              backgroundColor: Colors.white,
              foregroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0.0,
            ),
          ),
          body: GestureDetector(
            onTap: (){
              titleFocusNode.unfocus();
              productNameFocusNode.unfocus();
              priceFocusNode.unfocus();
              urlFocusNode.unfocus();
              descFocusNode.unfocus();
              FocusScope.of(context).unfocus();
            },
            child: Obx(()=>Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
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
                          focusNode: titleFocusNode,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: SDSColor.snowliveBlue,
                          cursorHeight: 16,
                          cursorWidth: 2,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _fleamarketUploadViewModel.textEditingController_title,
                          style: SDSTextStyle.regular.copyWith(fontSize: 15),
                          strutStyle: StrutStyle(fontSize: 14, leading: 0),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            errorMaxLines: 2,
                            errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                            labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                            hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                            hintText: '글 제목을 입력해 주세요.(최대 50자 이내)',
                            contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 50),
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
                              if (val!.length <= 50 && val.length >= 1) {
                                _fleamarketUploadViewModel.changeTitleWritten(true);
                              } else {
                                _fleamarketUploadViewModel.changeTitleWritten(false);
                              }
                            });
                            if (val!.length <= 50 && val.length >= 1) {
                              return null;
                            } else if (val.length == 0) {
                              return '제목을 입력해주세요.';
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
                              Text('제품명', style: SDSTextStyle.regular.copyWith(
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
                        TextFormField(
                          focusNode: productNameFocusNode,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: SDSColor.snowliveBlue,
                          cursorHeight: 16,
                          cursorWidth: 2,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _fleamarketUploadViewModel.textEditingController_productName,
                          style: SDSTextStyle.regular.copyWith(fontSize: 15),
                          strutStyle: StrutStyle(fontSize: 14, leading: 0),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            errorMaxLines: 2,
                            errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                            labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                            hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                            hintText: '제품명을 입력해 주세요.(최대 30자 이내)',
                            contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 50),
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
                                _fleamarketUploadViewModel.changeProductNameWritten(true);
                              } else {
                                _fleamarketUploadViewModel.changeProductNameWritten(false);
                              }
                            });
                            if (val!.length <= 30 && val.length >= 1) {
                              return null;
                            } else if (val.length == 0) {
                              return '제품명을 입력해주세요.';
                            } else {
                              return '최대 입력 가능한 글자 수를 초과했습니다.';
                            }
                          },
                        ),
                        Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 32, left: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('상위 카테고리',
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
                                GestureDetector(
                                  onTap: () async {
                                    titleFocusNode.unfocus();
                                    productNameFocusNode.unfocus();
                                    priceFocusNode.unfocus();
                                    urlFocusNode.unfocus();
                                    descFocusNode.unfocus();
                                    FocusScope.of(context).unfocus();
                                    selectedCategory_main = await showModalBottomSheet<String>(
                                      constraints: BoxConstraints(
                                        maxHeight: 300,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => CategoryMainFleamarketWidget(),
                                    );
                                    if(_fleamarketUploadViewModel.isCategorySelected==true)
                                      _fleamarketUploadViewModel.resetCategorySub();
                                    if(selectedCategory_main != null)
                                      _fleamarketUploadViewModel.selectCategoryMain(selectedCategory_main!);
                                    _fleamarketUploadViewModel.setIsSelectedCategoryFalse();
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
                                        Text(_fleamarketUploadViewModel.selectedCategoryMain,
                                          style: SDSTextStyle.regular.copyWith(
                                            color: _fleamarketUploadViewModel.selectedCategoryMain == '상위 카테고리' ? SDSColor.gray400 : SDSColor.gray900,
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
                            SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 32, left: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('하위 카테고리', style: SDSTextStyle.regular.copyWith(
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
                                GestureDetector(
                                  onTap: () async {
                                    titleFocusNode.unfocus();
                                    productNameFocusNode.unfocus();
                                    priceFocusNode.unfocus();
                                    urlFocusNode.unfocus();
                                    descFocusNode.unfocus();
                                    FocusScope.of(context).unfocus();
                                    if( _fleamarketUploadViewModel.selectedCategoryMain == '스키'){
                                      selectedCategory_sub = await showModalBottomSheet<String>(
                                        constraints: BoxConstraints(
                                          maxHeight: 480,
                                        ),
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => CategorySubSkiFleamarketWidget(),
                                      );
                                      if(selectedCategory_sub != null) {
                                        _fleamarketUploadViewModel.selectCategorySub(selectedCategory_sub!);
                                        _fleamarketUploadViewModel.setIsSelectedCategoryTrue();
                                      }

                                    }else if(_fleamarketUploadViewModel.selectedCategoryMain == '스노보드'){
                                      selectedCategory_sub = await showModalBottomSheet<String>(
                                        constraints: BoxConstraints(
                                          maxHeight: 480,
                                        ),
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => CategorySubBoardFleamarketWidget(),
                                      );
                                      if(selectedCategory_sub != null) {
                                        _fleamarketUploadViewModel.selectCategorySub(selectedCategory_sub!);
                                        _fleamarketUploadViewModel.setIsSelectedCategoryTrue();
                                      }
                                    }else{}
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
                                        Text(_fleamarketUploadViewModel.selectedCategorySub,
                                          style: SDSTextStyle.regular.copyWith(
                                            color: _fleamarketUploadViewModel.selectedCategorySub == '하위 카테고리' ? SDSColor.gray400 : SDSColor.gray900,
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
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 32, left: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('가격',
                                style: SDSTextStyle.regular.copyWith(
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
                        TextFormField(
                          focusNode: priceFocusNode,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: SDSColor.snowliveBlue,
                          cursorHeight: 16,
                          cursorWidth: 2,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _fleamarketUploadViewModel.itemPriceTextEditingController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                          ],
                          style: SDSTextStyle.regular.copyWith(fontSize: 15),
                          strutStyle: StrutStyle(fontSize: 14, leading: 0),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            errorMaxLines: 2,
                            errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                            labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                            hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                            hintText: '금액을 입력해 주세요.',
                            contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 50),
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
                              if (val!.length <= 10 && val.length >= 1) {
                                _fleamarketUploadViewModel.changePriceWritten(true);
                              } else {
                                _fleamarketUploadViewModel.changePriceWritten(false);
                              }
                            });
                            if (val!.length <= 10 && val.length >= 1) {
                              return null;
                            } else if (val.length == 0) {
                              return '가격을 입력해주세요.';
                            } else {
                              return '최대 입력 가능한 글자 수를 초과했습니다.';
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: (){
                            _fleamarketUploadViewModel.toggleNegotiable();
                          },
                          child: Row(
                            children: [
                              Obx(() => Image.asset(
                                _fleamarketUploadViewModel.negotiable==true
                                    ? 'assets/imgs/icons/icon_check_filled.png'
                                    : 'assets/imgs/icons/icon_check_unfilled.png',
                                height: 24,
                                width: 24,
                              )),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '가격 제안 가능 안내하기',
                                  style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 32, left: 4),
                              child: Text('사진 업로드',
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 13,
                                    color: SDSColor.gray900
                                ),),
                            ),
                            SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        titleFocusNode.unfocus();
                                        productNameFocusNode.unfocus();
                                        priceFocusNode.unfocus();
                                        urlFocusNode.unfocus();
                                        descFocusNode.unfocus();
                                        await _fleamarketUploadViewModel.getImageFromGallery();
                                        if (_fleamarketUploadViewModel.imageFiles.length <= 5) {
                                          _fleamarketUploadViewModel.changeFleaImageSelected(true);
                                          _fleamarketUploadViewModel.setImageLength();
                                        } else {
                                          Get.dialog(
                                            AlertDialog(
                                              backgroundColor: SDSColor.snowliveWhite,
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16)),
                                              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                              content: Container(
                                                height: 80,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '사진 갯수가 5장을 초과했어요.',
                                                      textAlign: TextAlign.center,
                                                      style: SDSTextStyle.bold.copyWith(
                                                          color: SDSColor.gray900,
                                                          fontSize: 16
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Text(
                                                      '사진을 5장 이내로 업로드해주세요.',
                                                      textAlign: TextAlign.center,
                                                      style: SDSTextStyle.regular.copyWith(
                                                        color: SDSColor.gray500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                Padding(
                                                  padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          child: TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              style: TextButton.styleFrom(
                                                                backgroundColor: Colors.transparent, // 배경색 투명
                                                                splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                              ),
                                                              child: Text('확인',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 17,
                                                                  color: SDSColor.gray900,
                                                                ),
                                                              )
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
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
                                                titleFocusNode.unfocus();
                                                productNameFocusNode.unfocus();
                                                priceFocusNode.unfocus();
                                                urlFocusNode.unfocus();
                                                descFocusNode.unfocus();
                                                await _fleamarketUploadViewModel.getImageFromGallery();
                                                if (_fleamarketUploadViewModel.imageFiles.length <= 5) {
                                                  _fleamarketUploadViewModel.changeFleaImageSelected(true);
                                                  _fleamarketUploadViewModel.setImageLength();
                                                } else {
                                                  Get.dialog(
                                                    AlertDialog(
                                                      backgroundColor: SDSColor.snowliveWhite,
                                                      contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(16)),
                                                      buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                      content: Container(
                                                        height: 80,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              '사진 갯수가 5장을 초과했어요.',
                                                              textAlign: TextAlign.center,
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  color: SDSColor.gray900,
                                                                  fontSize: 16
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Text(
                                                              '사진을 5장 이내로 업로드해주세요.',
                                                              textAlign: TextAlign.center,
                                                              style: SDSTextStyle.regular.copyWith(
                                                                color: SDSColor.gray500,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        Padding(
                                                          padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  child: TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      style: TextButton.styleFrom(
                                                                        backgroundColor: Colors.transparent, // 배경색 투명
                                                                        splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                      ),
                                                                      child: Text('확인',
                                                                        style: SDSTextStyle.bold.copyWith(
                                                                          fontSize: 17,
                                                                          color: SDSColor.gray900,
                                                                        ),
                                                                      )
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: Icon(Icons.camera_alt_rounded,
                                                size: 28,),
                                              color: SDSColor.gray400,
                                            ),
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.transparent,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          color: SDSColor.gray100,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    (_fleamarketUploadViewModel.isGettingImageFromGallery == true)
                                        ?ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.transparent,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          color: SDSColor.gray100,
                                        ),
                                        height: 90,
                                        width: 90,
                                        child: Center( // 인디케이터를 중앙에 배치
                                          child: SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 4,
                                                      backgroundColor: SDSColor.gray100,
                                                      color: SDSColor.gray300.withOpacity(0.6),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                        :Expanded(
                                      child: SizedBox(
                                        height: 90,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: _fleamarketUploadViewModel.imageLength,
                                          itemBuilder: (context, index) {
                                            return Row(
                                              children: [
                                                Stack(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            border: Border.all(color: SDSColor.gray100),
                                                            borderRadius: BorderRadius.circular(8),
                                                            color: Colors.white
                                                        ),
                                                        height: 90,
                                                        width: 90,
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(7),
                                                          child: Image.file(
                                                            File(_fleamarketUploadViewModel.imageFiles[index]!.path),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: -8,
                                                        right: -8,
                                                        child: IconButton(
                                                            onPressed: () {
                                                              _fleamarketUploadViewModel.removeSelectedImage(index);
                                                              _fleamarketUploadViewModel.setImageLength();
                                                            },
                                                            icon: Container(
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.circle, // 버튼이 원형인 경우
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black.withOpacity(0.2),
                                                                      spreadRadius: 2,
                                                                      blurRadius: 2,
                                                                      offset: Offset(0, 1),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Icon(Icons.cancel)), color: SDSColor.snowliveWhite),
                                                      ),
                                                      if(index==0)
                                                        Positioned(
                                                          bottom: 0,
                                                          left: 1,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors.transparent
                                                              ),
                                                              borderRadius: BorderRadius.only(
                                                                  bottomRight: Radius.circular(8),
                                                                  bottomLeft: Radius.circular(8)
                                                              ),
                                                              color: SDSColor.snowliveBlack.withOpacity(0.7),
                                                            ),
                                                            height: 22,
                                                            width: 88,
                                                            child: Padding(
                                                              padding: EdgeInsets.only(top: 1),
                                                              child: Text('대표사진',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    color: Colors.white,
                                                                    fontSize: 12),
                                                                textAlign: TextAlign.center,
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
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${_fleamarketUploadViewModel.imageLength}',
                                        style: SDSTextStyle.bold.copyWith(
                                          fontSize: 12,
                                          color: SDSColor.gray900,
                                        ),
                                      ),
                                      Text(
                                        '/5장',
                                        style: SDSTextStyle.regular.copyWith(
                                          fontSize: 12,
                                          color: SDSColor.gray500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text('대표 사진은 처음 선택한 사진으로 자동 등록됩니다.',
                                    style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.gray500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 32, left: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('희망 거래 방법', style: SDSTextStyle.regular.copyWith(
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
                                GestureDetector(
                                  onTap: () async {
                                    titleFocusNode.unfocus();
                                    productNameFocusNode.unfocus();
                                    priceFocusNode.unfocus();
                                    urlFocusNode.unfocus();
                                    descFocusNode.unfocus();
                                    selectedCategory_tradeMethod = await showModalBottomSheet<String>(
                                      constraints: BoxConstraints(
                                        maxHeight: 360,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => TradeMethodFleamarketWidget(),
                                    );
                                    if(selectedCategory_tradeMethod != null)
                                      _fleamarketUploadViewModel.selectTradeMethod(selectedCategory_tradeMethod!);
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
                                        Text(_fleamarketUploadViewModel.selectedTradeMethod,
                                          style: SDSTextStyle.regular.copyWith(
                                            color: _fleamarketUploadViewModel.selectedTradeMethod == '거래방법 선택' ? SDSColor.gray400 : SDSColor.gray900,
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
                            SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 32, left: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('희망 거래 장소', style: SDSTextStyle.regular.copyWith(
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
                                GestureDetector(
                                  onTap: () async {
                                    titleFocusNode.unfocus();
                                    productNameFocusNode.unfocus();
                                    priceFocusNode.unfocus();
                                    urlFocusNode.unfocus();
                                    descFocusNode.unfocus();
                                    FocusScope.of(context).unfocus();
                                    selectedCategory_tradeSpot= await showModalBottomSheet<String>(
                                      constraints: BoxConstraints(
                                        maxHeight: _size.height - _statusBarSize - 44,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => TradeSpotFleamarketWidget(),
                                    );
                                    if(selectedCategory_tradeSpot != null)
                                      _fleamarketUploadViewModel.selectTradeSpot(selectedCategory_tradeSpot!);
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
                                        Text(_fleamarketUploadViewModel.selectedTradeSpot,
                                          style: SDSTextStyle.regular.copyWith(
                                            color: _fleamarketUploadViewModel.selectedTradeSpot == '거래장소 선택' ? SDSColor.gray400 : SDSColor.gray900,
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
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 32, left: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('카카오 오픈채팅 URL', style: SDSTextStyle.regular.copyWith(
                                  fontSize: 13,
                                  color: SDSColor.gray900
                              ),),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          focusNode: urlFocusNode,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: SDSColor.snowliveBlue,
                          cursorHeight: 16,
                          cursorWidth: 2,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _fleamarketUploadViewModel.textEditingController_sns,
                          style: SDSTextStyle.regular.copyWith(fontSize: 15),
                          strutStyle: StrutStyle(fontSize: 14, leading: 0),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            errorMaxLines: 2,
                            errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                            labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                            hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                            hintText: 'URL',
                            contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 50),
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
                            if (val == null || val.isEmpty) {
                              return null;  // 입력이 없으면 검증 통과
                            }

                            // 앞뒤 공백 제거 후 공백 확인
                            if (val.trim() != val) {
                              return '앞뒤 공백이 포함될 수 없습니다.';
                            }

                            // 중간 공백이 포함되었는지 확인
                            final regex = RegExp(r'^\S+$');
                            if (!regex.hasMatch(val)) {
                              return '문자 사이에 공백이 포함될 수 없습니다.';
                            }

                            // 한글 자음, 모음 및 완성된 한글 포함 여부 검증
                            final koreanRegex = RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣ]');
                            if (koreanRegex.hasMatch(val)) {
                              return '한글 자음, 모음 또는 완성된 한글이 포함될 수 없습니다.';
                            }

                            // URL이 'https://open.kakao.com'으로 시작하는지 검증
                            if (!val.startsWith('https://open.kakao.com')) {
                              return '유효한 URL을 입력해주세요.';
                            }

                            return null;  // 모든 검증을 통과하면 null 반환
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('카카오톡에서 오픈채팅 URL을 복사할 경우, 다른 텍스트가 함께 복사되기 때문에 URL 부분만 입력되도록 확인 후 입력 부탁드립니다.',
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 12,
                              color: SDSColor.gray500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 32, left: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('상세 설명', style: SDSTextStyle.regular.copyWith(
                                  fontSize: 12,
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
                        Container(
                          height: 240,
                          child: TextFormField(
                            focusNode: descFocusNode,
                            textAlignVertical: TextAlignVertical.top,
                            cursorColor: SDSColor.snowliveBlue,
                            cursorHeight: 16,
                            cursorWidth: 2,
                            maxLines: null,
                            minLines: null,
                            expands: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: _fleamarketUploadViewModel.textEditingController_desc,
                            style: SDSTextStyle.regular.copyWith(fontSize: 15),
                            strutStyle: StrutStyle(fontSize: 14, leading: 0),
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              errorMaxLines: 2,
                              errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                              labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                              hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                              hintText: '상품에 대한 상세 설명을 작성해 주세요.\n(최대 1,000자 이내)\n\n부적절한 단어나 문장이 포함되는 경우 사전 고지없이 게시글 삭제가 될 수 있습니다.',
                              hintMaxLines: 20,
                              contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
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
                                if (val!.length <= 1000 && val.length >= 1) {
                                  _fleamarketUploadViewModel.changeDescriptionWritten(true);
                                } else {
                                  _fleamarketUploadViewModel.changeDescriptionWritten(false);
                                }
                              });
                              if (val!.length <= 1000 && val.length >= 1) {
                                return null;
                              } else if (val.length == 0) {
                                return '상세 설명을 입력해주세요.';
                              } else {
                                return '최대 입력 가능한 글자 수를 초과했습니다.';
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 100,
                        )
                      ],
                    ),
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
                          if(_fleamarketUploadViewModel.isTitleWritten == true
                              && _fleamarketUploadViewModel.isProductNameWritten == true
                              && _fleamarketUploadViewModel.selectedCategoryMain != '상위 카테고리'
                              && _fleamarketUploadViewModel.selectedCategorySub != '하위 카테고리'
                              && _fleamarketUploadViewModel.isPriceWritten == true
                              && _fleamarketUploadViewModel.selectedTradeMethod != '거래방법 선택'
                              && _fleamarketUploadViewModel.selectedTradeSpot != '거래장소 선택'
                              && _fleamarketUploadViewModel.isDescriptionWritten == true){
                            CustomFullScreenDialog.showDialog();
                            await _fleamarketUploadViewModel.uploadFleamarket(
                                {
                                  "user_id": _userViewModel.user.user_id,
                                  "product_name": _fleamarketUploadViewModel.textEditingController_productName.text,
                                  "category_main": _fleamarketUploadViewModel.selectedCategoryMain,
                                  "category_sub": _fleamarketUploadViewModel.selectedCategorySub,
                                  "price": _fleamarketUploadViewModel.itemPriceTextEditingController.text,
                                  "negotiable": _fleamarketUploadViewModel.negotiable,
                                  "method": _fleamarketUploadViewModel.selectedTradeMethod,
                                  "spot": _fleamarketUploadViewModel.selectedTradeSpot,
                                  "sns_url": _fleamarketUploadViewModel.textEditingController_sns.text.trim(),
                                  "title": _fleamarketUploadViewModel.textEditingController_title.text,
                                  "description": _fleamarketUploadViewModel.textEditingController_desc.text,
                                }
                            );
                            await _fleamarketUploadViewModel.getImageUrlList(
                                newImages: _fleamarketUploadViewModel.imageFiles,
                                pk: _fleamarketUploadViewModel.pk);
                            await _fleamarketUpdateViewModel.updateFleamarket(
                                _fleamarketUploadViewModel.pk,
                                {
                                  "user_id": _userViewModel.user.user_id,
                                  "product_name": _fleamarketUploadViewModel.textEditingController_productName.text,
                                  "category_main": _fleamarketUploadViewModel.selectedCategoryMain,
                                  "category_sub": _fleamarketUploadViewModel.selectedCategorySub,
                                  "price": _fleamarketUploadViewModel.itemPriceTextEditingController.text,
                                  "negotiable": _fleamarketUploadViewModel.negotiable,
                                  "method": _fleamarketUploadViewModel.selectedTradeMethod,
                                  "spot": _fleamarketUploadViewModel.selectedTradeSpot,
                                  "sns_url": _fleamarketUploadViewModel.textEditingController_sns.text.trim(),
                                  "title": _fleamarketUploadViewModel.textEditingController_title.text,
                                  "description": _fleamarketUploadViewModel.textEditingController_desc.text,
                                },
                                _fleamarketUploadViewModel.photos
                            );
                            CustomFullScreenDialog.cancelDialog();
                            Get.back();
                            await _fleamarketListViewModel.fetchAllFleamarket_afterUpload();
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
                          (
                              _fleamarketUploadViewModel.isTitleWritten == true
                                  && _fleamarketUploadViewModel.isProductNameWritten == true
                                  && _fleamarketUploadViewModel.selectedCategoryMain != '상위 카테고리'
                                  && _fleamarketUploadViewModel.selectedCategorySub != '하위 카테고리'
                                  && _fleamarketUploadViewModel.isPriceWritten == true
                                  && _fleamarketUploadViewModel.selectedTradeMethod != '거래방법 선택'
                                  && _fleamarketUploadViewModel.selectedTradeSpot != '거래장소 선택'
                                  && _fleamarketUploadViewModel.isDescriptionWritten == true
                          )
                              ?
                          SDSColor.snowliveBlue
                              : SDSColor.gray200,
                        ),
                        child: Text('작성 완료',
                          style: SDSTextStyle.bold.copyWith(color:
                          (
                              _fleamarketUploadViewModel.isTitleWritten == true
                                  && _fleamarketUploadViewModel.isProductNameWritten == true
                                  && _fleamarketUploadViewModel.selectedCategoryMain != '상위 카테고리'
                                  && _fleamarketUploadViewModel.selectedCategorySub != '하위 카테고리'
                                  && _fleamarketUploadViewModel.isPriceWritten == true
                                  && _fleamarketUploadViewModel.selectedTradeMethod != '거래방법 선택'
                                  && _fleamarketUploadViewModel.selectedTradeSpot != '거래장소 선택'
                                  && _fleamarketUploadViewModel.isDescriptionWritten == true
                          )
                              ? SDSColor.snowliveWhite
                              :SDSColor.gray400, fontSize: 16),
                        ),
                      ),
                    ))
              ],
            )),
          ),
        ),
      ),
    );
  }
}
