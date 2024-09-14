import 'dart:io';
import 'package:com.snowlive/viewmodel/vm_friendDetailUpdate.dart';
import 'package:com.snowlive/widget/w_favoriteResort.dart';
import 'package:com.snowlive/widget/w_sex.dart';
import 'package:com.snowlive/widget/w_skiorboard.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../screens/snowliveDesignStyle.dart';
import '../../viewmodel/vm_friendDetail.dart';
import '../../viewmodel/vm_user.dart';

class FriendDetailUpdateView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final FriendDetailUpdateViewModel _friendDetailUpdateViewModel = Get.find<FriendDetailUpdateViewModel>();
    final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
    final UserViewModel _userViewModel = Get.find<UserViewModel>();

    final double _statusBarSize = MediaQuery.of(context).padding.top;
    int? selectedIndex;
    String? selectedSkiOrBoard;
    String? selectedSex;
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: AppBar(
            leading: GestureDetector(
              child: Image.asset(
                'assets/imgs/icons/icon_snowLive_back.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
              onTap: () {
                _friendDetailUpdateViewModel.cancelSelectedImage();
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) => SafeArea(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                  color: SDSColor.snowliveWhite,
                                ),
                                padding: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
                                height: 210,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                          '업로드 방법을 선택해주세요.',
                                          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '프로필 이미지를 나중에 설정 하시려면,\n기본 이미지로 설정해주세요.',
                                          style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500, height: 1.4),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed:
                                                () => _friendDetailUpdateViewModel.uploadImage(ImageSource.camera),
                                            child: Text(
                                              '사진 촬영',
                                              style: SDSTextStyle.bold.copyWith(
                                                  color: SDSColor.snowliveWhite,
                                                  fontSize: 16),
                                            ),
                                            style: TextButton.styleFrom(
                                                splashFactory: InkRipple.splashFactory,
                                                elevation: 0,
                                                minimumSize: Size(100, 48),
                                                backgroundColor: SDSColor.sBlue500
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _friendDetailUpdateViewModel.uploadImage(ImageSource.gallery);
                                            },
                                            child: Text(
                                              '앨범에서 선택',
                                              style: SDSTextStyle.bold.copyWith(
                                                  color: SDSColor.snowliveWhite,
                                                  fontSize: 16),
                                            ),
                                            style: TextButton.styleFrom(
                                              splashFactory: InkRipple.splashFactory,
                                              elevation: 0,
                                              minimumSize: Size(100, 48),
                                              backgroundColor: SDSColor.snowliveBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Obx(() => Stack(
                          children: [
                            if (_friendDetailUpdateViewModel.croppedFile != null)
                              Container(
                                width: 120,
                                height: 120,
                                child: CircleAvatar(
                                  backgroundColor: SDSColor.gray50,
                                  backgroundImage: FileImage(File(_friendDetailUpdateViewModel.croppedFile!.path)),
                                ),
                              )
                            else if (_friendDetailUpdateViewModel.profileImageUrl.isNotEmpty)
                              Container(
                                width: 120,
                                height: 120,
                                child: CircleAvatar(
                                  backgroundColor: SDSColor.gray50,
                                  backgroundImage: NetworkImage(_friendDetailUpdateViewModel.profileImageUrl),
                                ),
                              )
                            else
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/imgs/profile/img_profile_default_circle.png',
                                  width: 120,
                                  height: 120,
                                ),
                              ),

                            // 삭제 버튼 또는 추가 버튼 위치
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                child: ExtendedImage.asset(
                                  _friendDetailUpdateViewModel.croppedFile != null || _friendDetailUpdateViewModel.profileImageUrl.isNotEmpty
                                      ? 'assets/imgs/icons/icon_profile_delete.png'
                                      : 'assets/imgs/icons/icon_profile_add.png',
                                  scale: 4,
                                ),
                                onTap: () {
                                  // 이미지가 선택되어 있거나 기존 네트워크 이미지가 있으면 삭제
                                  if (_friendDetailUpdateViewModel.croppedFile != null || _friendDetailUpdateViewModel.profileImageUrl.isNotEmpty) {
                                    _friendDetailUpdateViewModel.setCroppedFile(null);
                                    _friendDetailUpdateViewModel.setProfileImageUrl('');
                                  }
                                },
                              ),
                            ),
                          ],
                        )),


                      ),
                      SizedBox(height: 30,),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('닉네임', style: SDSTextStyle.regular.copyWith(
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
                      Form(
                        key: _friendDetailUpdateViewModel.formKey,
                        child: Container(
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Stack(
                                  children: [
                                    TextFormField(
                                      textAlignVertical: TextAlignVertical.center,
                                      cursorColor: SDSColor.snowliveBlue,
                                      cursorHeight: 16,
                                      cursorWidth: 2,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _friendDetailUpdateViewModel.textEditingController_displayName..text,
                                      style: SDSTextStyle.regular.copyWith(fontSize: 15),
                                      strutStyle: StrutStyle(fontSize: 14, leading: 0),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(RegExp(r'\s')), // 띄어쓰기 입력 차단
                                      ],
                                      decoration: InputDecoration(
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        errorMaxLines: 2,
                                        errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                        labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                        hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                        hintText: '닉네임을 입력해 주세요.(최대 10자)',
                                        labelText: '닉네임을 입력해 주세요.(최대 10자)',
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
                                          if ((val!.length <= 10 && val.length >= 1)
                                              &&  _friendDetailUpdateViewModel.textEditingController_displayName.text != _friendDetailUpdateViewModel.displayName) {
                                            _friendDetailUpdateViewModel.toggleCheckDisplayname(true);
                                            _friendDetailUpdateViewModel.toggleIsCheckedDisplayName(false);
                                          } else {
                                            _friendDetailUpdateViewModel.toggleCheckDisplayname(false);
                                            _friendDetailUpdateViewModel.toggleIsCheckedDisplayName(true);

                                          }
                                        });
                                        if (val!.length <= 10 && val.length >= 1) {
                                          return null;
                                        } else if (val.length == 0) {
                                          return '활동명을 입력해주세요.';
                                        } else {
                                          return '최대 입력 가능한 글자 수를 초과했습니다.';
                                        }
                                      },
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: TextButton(
                                        onPressed: (_friendDetailUpdateViewModel.activeCheckDisplaynameButton == true && !_friendDetailUpdateViewModel.isCheckedDisplayName)
                                            ? () async {
                                          print(_friendDetailUpdateViewModel.textEditingController_displayName.text);
                                          await _friendDetailUpdateViewModel.checkDisplayName({
                                            "display_name": _friendDetailUpdateViewModel.textEditingController_displayName.text,
                                          });
                                          FocusScope.of(context).unfocus();
                                          if (!_friendDetailUpdateViewModel.isCheckedDisplayName)
                                            Get.dialog(
                                                AlertDialog(
                                                  actionsPadding: EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 30),
                                                  contentPadding: EdgeInsets.only(left: 28, right: 28, top: 30),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  buttonPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                                                  content: Container(
                                                    width: 232,
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text('이미 존재하는 활동명이에요',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(top: 8),
                                                          child: Text(
                                                            '다른 사용자의 닉네임과 중복되지 않는\n다른 닉네임을 사용해주세요.',
                                                            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: 240,
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: Text(
                                                              '확인',
                                                              style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ));
                                        }
                                            : (){},
                                        child: _friendDetailUpdateViewModel.isCheckedDisplayName
                                            ? Text('검사완료', style: SDSTextStyle.bold.copyWith(
                                            color: SDSColor.gray500
                                        ),
                                        )
                                            : Text('중복검사',style: SDSTextStyle.bold.copyWith(
                                            color: _friendDetailUpdateViewModel.activeCheckDisplaynameButton == true
                                                ? SDSColor.snowliveBlue
                                                : SDSColor.gray600
                                        ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                                SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('상태메세지', style: SDSTextStyle.regular.copyWith(
                                          fontSize: 12,
                                          color: SDSColor.gray900
                                      ),),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Stack(
                                  children: [
                                    TextFormField(
                                      textAlignVertical: TextAlignVertical.center,
                                      cursorColor: SDSColor.snowliveBlue,
                                      cursorHeight: 16,
                                      cursorWidth: 2,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _friendDetailUpdateViewModel.textEditingController_stateMsg..text,
                                      style: SDSTextStyle.regular.copyWith(fontSize: 15),
                                      strutStyle: StrutStyle(fontSize: 14, leading: 0),
                                      decoration: InputDecoration(
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        errorMaxLines: 2,
                                        errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                        labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                        hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                        hintText: '상태메세지를 입력해 주세요.(최대 20자)',
                                        labelText: '상태메세지를 입력해 주세요.(최대 20자)',
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
                                        if (val!.length <= 20 && val.length >= 0) {
                                          return null;
                                        } else {
                                          return '최대 입력 가능한 글자 수를 초과했습니다.';
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('자주가는 스키장', style: SDSTextStyle.regular.copyWith(
                                          fontSize: 12,
                                          color: SDSColor.gray900
                                      ),),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    selectedIndex = await showModalBottomSheet<int>(
                                      constraints: BoxConstraints(
                                        maxHeight: _size.height - _statusBarSize - 44,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      isScrollControlled: true,
                                      enableDrag: false,
                                      isDismissible: false,
                                      builder: (context) => FavoriteResortWidget(),
                                    );
                                    if(selectedIndex != null)
                                      _friendDetailUpdateViewModel.selectResortInfo(selectedIndex!);
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
                                        Text(
                                          _friendDetailUpdateViewModel.selectedResortName == ''
                                              ? '자주가는 스키장 선택'
                                              : _friendDetailUpdateViewModel.selectedResortName,
                                          style: SDSTextStyle.regular.copyWith(
                                            color: _friendDetailUpdateViewModel.selectedResortName == '' ? SDSColor.gray400 : SDSColor.gray900,
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
                                SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text('자주가는 스키장과 관련장된 다양한 서비스를 즐길 수 있습니다',
                                    style: SDSTextStyle.regular.copyWith(
                                        color: SDSColor.gray500,
                                        fontSize: 12
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text('종목', style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.gray900
                                  ),),
                                ),
                                SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    selectedSkiOrBoard = await showModalBottomSheet<String>(
                                      constraints: BoxConstraints(
                                        maxHeight: _size.height - _statusBarSize - 44,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      isDismissible: false,
                                      enableDrag: false,
                                      isScrollControlled: true,
                                      builder: (context) => SkiorboardWidget(),
                                    );
                                    if(selectedSkiOrBoard != null)
                                      _friendDetailUpdateViewModel.selectSkiOrBoard(selectedSkiOrBoard!);
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: SDSColor.gray50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Obx(()=> Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _friendDetailUpdateViewModel.selectedSkiOrBoard == ''
                                              ? '스키 또는 스노보드 선택'
                                              : _friendDetailUpdateViewModel.selectedSkiOrBoard,
                                          style: SDSTextStyle.regular.copyWith(
                                            color: _friendDetailUpdateViewModel.selectedSkiOrBoard == '' ? SDSColor.gray400 : SDSColor.gray900,
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
                                SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text('성별', style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.gray900
                                  ),),
                                ),
                                SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    selectedSex = await showModalBottomSheet<String>(
                                      constraints: BoxConstraints(
                                        maxHeight: _size.height - _statusBarSize - 44,
                                      ),
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      isDismissible: false,
                                      enableDrag: false,
                                      isScrollControlled: true,
                                      builder: (context) => SexWidget(),
                                    );
                                    if(selectedSex != null)
                                      _friendDetailUpdateViewModel.selectSex(selectedSex!);
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: SDSColor.gray50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Obx(()=> Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _friendDetailUpdateViewModel.selectedSex == ''
                                              ? '성별 선택'
                                              : _friendDetailUpdateViewModel.selectedSex,
                                          style: SDSTextStyle.regular.copyWith(
                                            color: _friendDetailUpdateViewModel.selectedSex == '' ? SDSColor.gray400 : SDSColor.gray900,
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
                          ),
                        ),
                      ),
                      SizedBox(height: 50,),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Obx(() =>
                  (_friendDetailUpdateViewModel.selectedResortIndex != 99 && _friendDetailUpdateViewModel.displayName != '')
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        await _friendDetailUpdateViewModel.getImageUrl();
                        await _friendDetailUpdateViewModel.updateFriendDetail(
                            {
                              "user_id": _userViewModel.user.user_id,    //필수 - 수정할 유저id
                              "display_name": _friendDetailUpdateViewModel.textEditingController_displayName.text,
                              "state_msg": _friendDetailUpdateViewModel.textEditingController_stateMsg.text,    //선택
                              "profile_image_url_user": _friendDetailUpdateViewModel.profileImageUrl,
                              "hide_profile": _userViewModel.user.hide_profile,    //선택 - 프로필 비공개 설정에서만 씀
                              "instant_resort":_userViewModel.user.instant_resort,
                              "favorite_resort":_friendDetailUpdateViewModel.selectedResortIndex+1,
                              "sex": _friendDetailUpdateViewModel.selectedSex,
                              "skiorboard": _friendDetailUpdateViewModel.selectedSkiOrBoard
                            }
                        );
                        await _friendDetailViewModel.fetchFriendDetailInfo(
                          userId: _userViewModel.user.user_id,
                          friendUserId: _userViewModel.user.user_id,
                          season: _friendDetailViewModel.seasonDate,
                        );
                        Get.back();
                      },
                      style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        elevation: 0,
                        splashFactory: InkRipple.splashFactory,
                        minimumSize: Size(double.infinity, 48),
                        backgroundColor: SDSColor.snowliveBlue,
                      ),
                      child: Text('수정하기',
                        style: SDSTextStyle.bold
                            .copyWith(color: SDSColor.snowliveWhite, fontSize: 16),
                      ),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('수정하기',
                        style: SDSTextStyle.bold
                            .copyWith(color: SDSColor.snowliveWhite, fontSize: 16),
                      ),
                      style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          elevation: 0,
                          splashFactory: InkRipple.splashFactory,
                          minimumSize: Size(double.infinity, 48),
                          backgroundColor:  SDSColor.gray200
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
