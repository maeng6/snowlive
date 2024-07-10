import 'dart:io';
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
import '../../controller/public/vm_bottomTabBarController.dart';
import '../../controller/ranking/vm_myRankingController.dart';
import '../../controller/resort/vm_resortModelController.dart';
import '../../controller/user/vm_allUserDocsController.dart';
import '../../controller/user/vm_userModelController.dart';
import '../../model/m_resortModel.dart';
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(58),
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
            body: Padding(
              padding: EdgeInsets.only(
                  top: _statusBarSize + 58,
                  left: 16,
                  right: 16,
                  bottom: _statusBarSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => SafeArea(
                            child: Container(
                              height: 187,
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
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 24,
                                        ),
                                        Text(
                                          '업로드 방법을 선택해주세요.',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF111111)),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '프로필 이미지를 나중에 설정 하시려면,\n기본 이미지로 설정해주세요.',
                                          style: TextStyle(
                                            color: Color(0xff666666),
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 24,
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
                                              style: TextStyle(
                                                  color: Color(0xff377EEA),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            style: TextButton.styleFrom(
                                                splashFactory: InkRipple.splashFactory,
                                                elevation: 0,
                                                minimumSize: Size(100, 56),
                                                backgroundColor: Color(0xFFD8E7FD),
                                                padding: EdgeInsets.symmetric(horizontal: 0)),
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
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            style: TextButton.styleFrom(
                                                splashFactory: InkRipple.splashFactory,
                                                elevation: 0,
                                                minimumSize: Size(100, 56),
                                                backgroundColor: Color(0xff377EEA),
                                                padding: EdgeInsets.symmetric(horizontal: 0)),
                                          ),
                                        ),
                                      ],
                                    ),
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
                              width: 160,
                              height: 160,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                backgroundImage:
                                FileImage(File(_croppedFile!.path)),
                              ),
                            ),
                          if (!profileImage && _isSelected && _userModelController.profileImageUrl != null)
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: ExtendedImage.network(
                                  _userModelController.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  width: 160,
                                  height: 160,
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
                                width: 147,
                                height: 147,
                              ),
                            ),
                          Positioned(
                              bottom: 13,
                              right: 8,
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
                  SizedBox(height: 30,),
                  Text('닉네임'),
                  SizedBox(height: 10,),
                  Form(
                    key: _formKey,
                    child: Container(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: Color(0xff377EEA),
                              cursorHeight: 16,
                              cursorWidth: 2,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: _textEditingController,
                              strutStyle: StrutStyle(leading: 0.3),
                              decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  errorStyle: TextStyle(
                                    fontSize: 12,
                                  ),
                                  labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                  hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                  hintText: '활동명 입력',
                                  labelText: '활동명',
                                  contentPadding: EdgeInsets.only(
                                      top: 20, bottom: 16, left: 16, right: 16),
                                  fillColor: Color(0xFFEFEFEF),
                                  hoverColor: Colors.transparent,
                                  filled: true,
                                  focusColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  errorBorder:  OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
                                  focusedBorder:  OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
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
                            SizedBox(height: 20),
                            Text('자주가는 스키장'),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final selectedIndex = await showModalBottomSheet<int>(
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
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Color(0xFFEFEFEF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedResortName ?? '자주가는 스키장 선택',
                                      style: TextStyle(
                                        color: selectedResortName == null ? Color(0xffb7b7b7) : Color(0xff111111),
                                        fontSize: 15,
                                      ),
                                    ),
                                    ExtendedImage.asset(
                                      'assets/imgs/icons/icon_dropdown.png',
                                      color: Color(0xFF111111),
                                      fit: BoxFit.cover,
                                      width: 24,
                                      height: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 5,),
                            Text('자주가는 스키장 관련 다양한 서비스를 즐길 수 있습니다',
                            style: TextStyle(
                              color: Color(0xFF949494),
                              fontSize: 12
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
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            right: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  children: [
                    Text('입력하신 기본 정보는 언제든지 변경 가능합니다',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFC8C8C8),
                    ),
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (_formKey.currentState!.validate() && selectedResortIndex != null) {
                          _displayName = _textEditingController.text;
                          isCheckedDispName = await _userModelController.checkDuplicateDisplayName(_displayName);
                          if (isCheckedDispName == true) {
                            if (_croppedFile != null) {
                              CustomFullScreenDialog.showDialog();
                              try {
                                _profileImageUrl = await _imageController.setNewImage(_croppedFile!);
                              } catch (e) {
                                // 에러 처리
                                print('Error: $e');
                              } finally {
                                CustomFullScreenDialog.cancelDialog();
                              }
                            }
                            CustomFullScreenDialog.showDialog();
                            await FlutterSecureStorage().write(key: 'uid', value: auth.currentUser!.uid);
                            await _userModelController.registerUser(
                                uid: auth.currentUser!.uid,
                                email: 'myd5416@naver.com',
                                favoriteResort: selectedResortIndex!,
                                deviceId: _notificationController.deviceID!,
                                deviceToken: _notificationController.deviceToken!,
                                displayName: _displayName,
                                profileImageUrlUser: _profileImageUrl ?? "");
                            print(_notificationController.deviceID);
                            await resortModelController.getSelectedResort(selectedResortIndex!);
                            // // await _loginController.createUserDoc(index: 0, token: _notificationController.deviceToken,deviceID: _notificationController.deviceID);
                            // await userModelController.updateNickname(_nickName);
                            // await userModelController.updateProfileImageUrl(_profileImageUrl ?? "");
                            // await userModelController.updateFavoriteResort(selectedResortIndex);
                            // await userModelController.updateInstantResort(selectedResortIndex);
                            // await userModelController.updateResortNickname(selectedResortIndex);
                            // await resortModelController.getSelectedResort(userModelController.favoriteResort!);
                            // await _allUserDocsController.getAllUserDocs();
                            _myRankingController.resetMyRankingData();
                            CustomFullScreenDialog.cancelDialog();
                            Get.offAll(() => MainHome(uid: auth.currentUser!.uid));
                          } else {
                            Get.dialog(AlertDialog(
                              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              content: Text(
                                '이미 존재하는 활동명입니다.\n다른 활동명을 입력해주세요.',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        '확인',
                                        style: TextStyle(fontSize: 15, color: Color(0xff377EEA), fontWeight: FontWeight.bold),
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
                          : Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '다음',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        elevation: 0,
                        splashFactory: InkRipple.splashFactory,
                        minimumSize: Size(double.infinity, 56),
                        backgroundColor: isLoading || !(_formKey.currentState?.validate() ?? false) || selectedResortIndex == null
                            ? Color(0xffDEDEDE)
                            : Color(0xff377EEA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}