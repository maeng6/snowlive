import 'dart:io';
import 'package:com.snowlive/viewmodel/vm_fleamarketUpload.dart';
import 'package:com.snowlive/widget/w_category_main_fleamarket.dart';
import 'package:com.snowlive/widget/w_tradeMethod_fleamarket.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../screens/snowliveDesignStyle.dart';
import '../viewmodel/vm_fleamarketList.dart';
import '../viewmodel/vm_user.dart';
import '../widget/w_category_sub_board_fleamarket.dart';
import '../widget/w_category_sub_ski_fleamarket.dart';
import '../widget/w_tradeSpot_fleamarket.dart';

class FleamarketUploadView extends StatelessWidget {

  final FleamarketUploadViewModel _fleamarketUploadViewModel = Get.find<FleamarketUploadViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FleamarketListViewModel _fleamarketListViewModel = Get.find<FleamarketListViewModel>();


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
            preferredSize: Size.fromHeight(58),
            child: AppBar(
              title: Text('내 물건 팔기'),
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
              elevation: 0.0,
            ),
          ),
          body: Obx(()=>GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              children: [
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('제목', style: SDSTextStyle.regular.copyWith(
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
                            TextFormField(
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
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('제품명', style: SDSTextStyle.regular.copyWith(
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
                            TextFormField(
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
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('상위 카테고리', style: SDSTextStyle.regular.copyWith(
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
                                    GestureDetector(
                                      onTap: () async {
                                        selectedCategory_main = await showModalBottomSheet<String>(
                                          constraints: BoxConstraints(
                                            maxHeight: _size.height - _statusBarSize - 44,
                                          ),
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          isScrollControlled: true,
                                          enableDrag: false,
                                          isDismissible: false,
                                          builder: (context) => CategoryMainFleamarketWidget(),
                                        );
                                        if(_fleamarketUploadViewModel.isCategorySelected==true)
                                          _fleamarketUploadViewModel.resetCategorySub();
                                        if(selectedCategory_main != null)
                                          _fleamarketUploadViewModel.selectCategoryMain(selectedCategory_main!);
                                        _fleamarketUploadViewModel.setIsSelectedCategoryFalse();
                                      },
                                      child: Container(
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
                                            ExtendedImage.asset(
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
                                SizedBox(width: 6,),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('하위 카테고리', style: SDSTextStyle.regular.copyWith(
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
                                    GestureDetector(
                                      onTap: () async {
                                        if(_fleamarketUploadViewModel.isCategorySelected==false && _fleamarketUploadViewModel.selectedCategoryMain == '스키'){
                                        selectedCategory_sub = await showModalBottomSheet<String>(
                                          constraints: BoxConstraints(
                                            maxHeight: _size.height - _statusBarSize - 44,
                                          ),
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          isScrollControlled: true,
                                          enableDrag: false,
                                          isDismissible: false,
                                          builder: (context) => CategorySubSkiFleamarketWidget(),
                                        );
                                        if(selectedCategory_sub != null) {
                                          _fleamarketUploadViewModel.selectCategorySub(selectedCategory_sub!);
                                          _fleamarketUploadViewModel.setIsSelectedCategoryTrue();
                                        }

                                        }else if(_fleamarketUploadViewModel.isCategorySelected==false && _fleamarketUploadViewModel.selectedCategoryMain == '스노보드'){
                                          selectedCategory_sub = await showModalBottomSheet<String>(
                                            constraints: BoxConstraints(
                                              maxHeight: _size.height - _statusBarSize - 44,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            isScrollControlled: true,
                                            enableDrag: false,
                                            isDismissible: false,
                                            builder: (context) => CategorySubBoardFleamarketWidget(),
                                          );
                                          if(selectedCategory_sub != null) {
                                            _fleamarketUploadViewModel.selectCategorySub(selectedCategory_sub!);
                                            _fleamarketUploadViewModel.setIsSelectedCategoryTrue();
                                          }
                                        }else{}
                                      },
                                      child: Container(
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
                                            ExtendedImage.asset(
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
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('가격', style: SDSTextStyle.regular.copyWith(
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
                            TextFormField(
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
                                if (val!.length <= 8 && val.length >= 1) {
                                return null;
                              } else if (val.length == 0) {
                                return '가격을 입력해주세요.';
                              } else {
                                return '최대 입력 가능한 글자 수를 초과했습니다.';
                              }
                              },
                            ),
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
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '가격 제안 가능 안내하기',
                                      style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {

                                      await _fleamarketUploadViewModel.getImageFromGallery();

                                      if (_fleamarketUploadViewModel.imageFiles.length <= 5) {

                                        _fleamarketUploadViewModel.changeFleaImageSelected(true);
                                        _fleamarketUploadViewModel.setImageLength();

                                      } else {
                                        Get.dialog(
                                          AlertDialog(
                                            title: Text('사진 개수 초과'),
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

                                            await _fleamarketUploadViewModel.getImageFromGallery();

                                            if (_fleamarketUploadViewModel.imageFiles.length <= 5) {

                                              _fleamarketUploadViewModel.changeFleaImageSelected(true);
                                              _fleamarketUploadViewModel.setImageLength();

                                            } else {
                                              Get.dialog(
                                                AlertDialog(
                                                  title: Text('사진 개수 초과'),
                                                ),
                                              );
                                            }

                                          },
                                          icon: Icon(Icons.camera_alt_rounded),
                                          color: Color(0xFF949494),
                                        ),
                                        Transform.translate(
                                          offset: Offset(0, -10),
                                          child: Text(
                                            '${_fleamarketUploadViewModel.imageLength} / 5',
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
                                if(_fleamarketUploadViewModel.imageLength == 0)
                                  SizedBox(width: 8,),
                                if(_fleamarketUploadViewModel.imageLength == 0)
                                  Text('대표사진은 처음 선택한 \n사진으로 등록됩니다.',
                                    style: TextStyle(
                                        color: Color(0xff949494),
                                        fontSize: 12
                                    ),
                                  ),
                                Expanded(
                                  child: SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: _fleamarketUploadViewModel.imageLength,
                                      itemBuilder: (context, index) {
                                        return Row(
                                          children: [
                                            Stack(children: [

                                              Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Color(0xFFECECEC)),
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
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('희망 거래 방법', style: SDSTextStyle.regular.copyWith(
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
                                    GestureDetector(
                                      onTap: () async {
                                        selectedCategory_tradeMethod = await showModalBottomSheet<String>(
                                          constraints: BoxConstraints(
                                            maxHeight: _size.height - _statusBarSize - 44,
                                          ),
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          isScrollControlled: true,
                                          enableDrag: false,
                                          isDismissible: false,
                                          builder: (context) => TradeMethodFleamarketWidget(),
                                        );
                                        if(selectedCategory_tradeMethod != null)
                                          _fleamarketUploadViewModel.selectTradeMethod(selectedCategory_tradeMethod!);
                                      },
                                      child: Container(
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
                                            ExtendedImage.asset(
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
                                SizedBox(width: 6,),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('희망 거래 장소', style: SDSTextStyle.regular.copyWith(
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
                                    GestureDetector(
                                      onTap: () async {
                                        selectedCategory_tradeSpot= await showModalBottomSheet<String>(
                                          constraints: BoxConstraints(
                                            maxHeight: _size.height - _statusBarSize - 44,
                                          ),
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          isScrollControlled: true,
                                          enableDrag: false,
                                          isDismissible: false,
                                          builder: (context) => TradeSpotFleamarketWidget(),
                                        );
                                        if(selectedCategory_tradeSpot != null)
                                          _fleamarketUploadViewModel.selectTradeSpot(selectedCategory_tradeSpot!);
                                      },
                                      child: Container(
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
                                            ExtendedImage.asset(
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
                              padding: const EdgeInsets.only(left: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('카카오 오픈채팅 URL', style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.gray900
                                  ),),
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
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
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
                              height: 220,
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                cursorColor: SDSColor.snowliveBlue,
                                cursorHeight: 16,
                                cursorWidth: 2,
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
                                  hintText: '상품에 대한 상세 설명을 작성해 주세요, (최대 1,000자 이내)\n\n부적절한 단어나 문장이 포함되는 경우 사전 고지없이 게시글 삭제가 될 수 있습니다.',
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
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          if(_fleamarketUploadViewModel.textEditingController_title.text != ''
                                && _fleamarketUploadViewModel.textEditingController_productName.text != ''
                                && _fleamarketUploadViewModel.selectedCategoryMain != '상위 카테고리'
                                && _fleamarketUploadViewModel.selectedCategorySub != '하위 카테고리'
                                && _fleamarketUploadViewModel.itemPriceTextEditingController.text != ''
                                && _fleamarketUploadViewModel.selectedTradeMethod != '거래방법 선택'
                                && _fleamarketUploadViewModel.selectedTradeSpot != '거래장소 선택'
                                && _fleamarketUploadViewModel.textEditingController_desc.text != '')
                            await _fleamarketUploadViewModel.getImageUrlList(
                                newImages: _fleamarketUploadViewModel.imageFiles,
                                user_id: _userViewModel.user.user_id);
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
                                  "sns_url": _fleamarketUploadViewModel.textEditingController_sns.text,
                                  "title": _fleamarketUploadViewModel.textEditingController_title.text,
                                  "description": _fleamarketUploadViewModel.textEditingController_desc.text,
                                },
                                _fleamarketUploadViewModel.photos
                            );
                          await _fleamarketListViewModel.fetchFleamarketData_total(userId: _userViewModel.user.user_id);
                          if(_fleamarketUploadViewModel.selectedCategoryMain == '스키')
                          await _fleamarketListViewModel.fetchFleamarketData_ski(userId: _userViewModel.user.user_id, categoryMain:'스키');
                          if(_fleamarketUploadViewModel.selectedCategoryMain == '스노보드')
                          await _fleamarketListViewModel.fetchFleamarketData_board(userId: _userViewModel.user.user_id, categoryMain:'스노보드');
                          await _fleamarketListViewModel.fetchFleamarketData_my(userId: _userViewModel.user.user_id, myflea: true);
                          Get.back();
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
                              _fleamarketUploadViewModel.textEditingController_title.text != ''
                                  && _fleamarketUploadViewModel.textEditingController_productName != ''
                                  && _fleamarketUploadViewModel.selectedCategoryMain != '상위 카테고리'
                                  && _fleamarketUploadViewModel.selectedCategorySub != '하위 카테고리'
                                  && _fleamarketUploadViewModel.itemPriceTextEditingController.text != ''
                                  && _fleamarketUploadViewModel.selectedTradeMethod != '거래방법 선택'
                                  && _fleamarketUploadViewModel.selectedTradeSpot != '거래장소 선택'
                                  && _fleamarketUploadViewModel.textEditingController_desc.text != ''
                          )
                              ?
                          SDSColor.snowliveBlue
                          : SDSColor.gray200,
                        ),
                        child: Text('시작하기',
                          style: SDSTextStyle.bold
                              .copyWith(color:
                          (
                          _fleamarketUploadViewModel.textEditingController_title.text != ''
                              && _fleamarketUploadViewModel.textEditingController_productName != ''
                              && _fleamarketUploadViewModel.selectedCategoryMain != '상위 카테고리'
                              && _fleamarketUploadViewModel.selectedCategorySub != '하위 카테고리'
                              && _fleamarketUploadViewModel.itemPriceTextEditingController.text != ''
                              && _fleamarketUploadViewModel.selectedTradeMethod != '거래방법 선택'
                              && _fleamarketUploadViewModel.selectedTradeSpot != '거래장소 선택'
                              && _fleamarketUploadViewModel.textEditingController_desc.text != ''
                          )
                          ? SDSColor.snowliveWhite
                              :SDSColor.gray500, fontSize: 16),
                        ),
                      ),
                    ))
              ],
            ),
          )),
        ),
      ),
    );
  }
}
