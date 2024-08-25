import 'dart:io';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/controller/public/vm_imageController.dart';
import 'package:com.snowlive/screens/onboarding/v_favoriteResort.dart';
import '../../controller/login/vm_loginController.dart';
import '../../controller/login/vm_notificationController.dart';
import '../../controller/ranking/vm_myRankingController.dart';
import '../../controller/resort/vm_resortModelController.dart';
import '../../controller/user/vm_allUserDocsController.dart';
import '../../controller/user/vm_userModelController.dart';
import '../../model_2/m_resortModel.dart';
import '../../widget/w_fullScreenDialog.dart';
import '../v_MainHome.dart';

class SetProfile extends StatefulWidget {
  SetProfile({Key? key}) : super(key: key);

  @override
  State<SetProfile> createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {
  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _displayName;
  bool? isCheckedDispName;

  bool isLoading = false;
  bool profileImage = false;
  XFile? _imageFile;
  XFile? _croppedFile;
  bool _isSelected = true;
  String? _profileImageUrl;
  String? selectedResortName;
  int? selectedResortIndex;

  //TODO: Dependency Injection********************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  ResortModelController resortModelController = Get.find<ResortModelController>();
  LoginController _loginController = Get.find<LoginController>();
  NotificationController _notificationController = Get.find<NotificationController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  MyRankingController _myRankingController = Get.find<MyRankingController>();
  ImageController _imageController = Get.put(ImageController(), permanent: true);
  //TODO: Dependency Injection********************************************

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ); // 상단 StatusBar 생성
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: (Platform.isAndroid)
            ? Brightness.light
            : Brightness.dark //ios:dark, android:light
    ));

    _isSelected = _userModelController.profileImageUrl?.isNotEmpty ?? false;
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
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: false,
            titleSpacing: 0,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: _statusBarSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
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
                                        onPressed: () async {
                                          CustomFullScreenDialog.showDialog();
                                          try {
                                            _imageFile = await _imageController.getSingleImage(ImageSource.camera);
                                            if (_imageFile != null) {
                                              _croppedFile = await _imageController.cropImage(_imageFile);
                                            }
                                            if (_croppedFile != null) {
                                              profileImage = true;
                                              setState(() {});
                                            }
                                          } catch (e) {
                                            CustomFullScreenDialog.cancelDialog();
                                          }
                                          CustomFullScreenDialog.cancelDialog();
                                          Navigator.pop(context);
                                        },
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
                                        onPressed: () async {
                                          CustomFullScreenDialog.showDialog();
                                          try {
                                            _imageFile = await _imageController.getSingleImage(ImageSource.gallery);
                                            if (_imageFile != null) {
                                              _croppedFile = await _imageController.cropImage(_imageFile);
                                            }
                                            if (_croppedFile != null) {
                                              profileImage = true;
                                              setState(() {});
                                            }
                                          } catch (e) {
                                            CustomFullScreenDialog.cancelDialog();
                                          }
                                          CustomFullScreenDialog.cancelDialog();
                                          Navigator.pop(context);
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
                    child: Stack(
                      children: [
                        if (profileImage && _croppedFile != null)
                          Container(
                            width: 120,
                            height: 120,
                            child: CircleAvatar(
                              backgroundColor: SDSColor.gray50,
                              backgroundImage:
                              FileImage(File(_croppedFile!.path)),
                            ),
                          ),
                        if (!profileImage && _isSelected && _userModelController.profileImageUrl != null)
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: ExtendedImage.network(
                                _userModelController.profileImageUrl!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                                cache: true,
                                loadStateChanged: (state) {
                                  if (state.extendedImageLoadState == LoadState.loading) {
                                    return CircularProgressIndicator();
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        if (!profileImage && (!_isSelected || _userModelController.profileImageUrl == null))
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
                        Positioned(
                            bottom: 4,
                            right: 4,
                            child: GestureDetector(
                              child: ExtendedImage.asset(
                                  profileImage
                                      ? 'assets/imgs/icons/icon_profile_delete.png'
                                      : 'assets/imgs/icons/icon_profile_add.png',
                                  scale: 4),
                              onTap: () {
                                if (profileImage) {
                                  profileImage = false;
                                  _croppedFile = null;
                                }
                                setState(() {});
                              },
                            )),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40,),
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
                  key: _formKey,
                  child: Container(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: SDSColor.snowliveBlue,
                            cursorHeight: 16,
                            cursorWidth: 2,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            controller: _textEditingController,
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
                                hintText: '닉네임을 입력해 주세요.(최대 8자)',
                                labelText: '닉네임을 입력해 주세요.(최대 8자)',
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
                              if (val!.length <= 8 && val.length >= 1) {
                                return null;
                              } else if (val.length == 0) {
                                return '활동명을 입력해주세요.';
                              } else {
                                return '최대 입력 가능한 글자 수를 초과했습니다.';
                              }
                            },
                          ),
                          SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text('자주가는 스키장', style: SDSTextStyle.regular.copyWith(
                                fontSize: 12,
                                color: SDSColor.gray900
                            ),),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              final selectedIndex = await showModalBottomSheet<int>(
                                constraints: BoxConstraints(
                                  maxHeight: _size.height - _statusBarSize - 44,
                                ),
                                backgroundColor: Colors.transparent,
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => FavoriteResort(),
                              );
                              if (selectedIndex != null) {
                                setState(() {
                                  selectedResortIndex = selectedIndex;
                                  selectedResortName = resortNameList[selectedResortIndex!];
                                });
                              }
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: SDSColor.gray50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedResortName ?? '자주가는 스키장 선택',
                                    style: SDSTextStyle.regular.copyWith(
                                      color: selectedResortName == null ? SDSColor.gray400 : SDSColor.gray900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  ExtendedImage.asset(
                                    'assets/imgs/icons/icon_dropdown.png',
                                    fit: BoxFit.cover,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text('자주가는 스키장과 관련된 다양한 서비스를 즐길 수 있습니다',
                              style: SDSTextStyle.regular.copyWith(
                                  color: SDSColor.gray500,
                                  fontSize: 12
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  '입력하신 기본 정보는 언제든지 변경 가능합니다',
                  style: SDSTextStyle.regular.copyWith(
                    decoration: TextDecoration.none,
                    fontSize: 12,
                    color: SDSColor.gray400,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  if (_formKey.currentState!.validate() &&
                      selectedResortIndex != null) {
                    _displayName = _textEditingController.text;
                    isCheckedDispName =
                    await _userModelController.checkDuplicateDisplayName(
                        _displayName);
                    if (isCheckedDispName == true) {
                      if (_croppedFile != null) {
                        CustomFullScreenDialog.showDialog();
                        try {
                          _profileImageUrl =
                          await _imageController.setNewImage(_croppedFile!);
                        } catch (e) {
                          // 에러 처리
                          print('Error: $e');
                        } finally {
                          CustomFullScreenDialog.cancelDialog();
                        }
                      }
                      CustomFullScreenDialog.showDialog();
                      await FlutterSecureStorage().write(
                          key: 'uid', value: auth.currentUser!.uid);
                      await _userModelController.registerUser(
                          uid: auth.currentUser!.uid,
                          email: 'myd5416@naver.com',
                          favoriteResort: selectedResortIndex!,
                          deviceId: _notificationController.deviceID!,
                          deviceToken: _notificationController.deviceToken!,
                          displayName: _displayName,
                          profileImageUrlUser: _profileImageUrl ?? "");
                      print(_notificationController.deviceID);
                      await resortModelController
                          .getSelectedResort(selectedResortIndex!);
                      _myRankingController.resetMyRankingData();
                      CustomFullScreenDialog.cancelDialog();
                      Get.offAll(() => MainHome(uid: auth.currentUser!.uid));
                    } else {
                      Get.dialog(AlertDialog(
                        actionsPadding: EdgeInsets.only(
                            bottom: 24, left: 24, right: 24, top: 30),
                        contentPadding:
                        EdgeInsets.only(left: 28, right: 28, top: 30),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        buttonPadding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                        content: Container(
                          width: 232,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '이미 존재하는 활동명이에요',
                                style: SDSTextStyle.bold.copyWith(
                                    fontSize: 16, color: SDSColor.gray900),
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  '다른 사용자의 닉네임과 중복되지 않는\n다른 닉네임을 사용해주세요.',
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14, color: SDSColor.gray500),
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
                                    style: SDSTextStyle.bold.copyWith(
                                        fontSize: 16,
                                        color: SDSColor.gray900),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ));
                    }
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  '시작하기',
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
                  backgroundColor: isLoading ||
                      !(_formKey.currentState?.validate() ?? false) ||
                      selectedResortIndex == null
                      ? SDSColor.gray200
                      : SDSColor.snowliveBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
