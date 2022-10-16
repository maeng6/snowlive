import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:snowlive3/controller/vm_loginController.dart';
import 'package:snowlive3/screens/more/v_setProfileImage_moreTab.dart';
import 'package:snowlive3/screens/onboarding/v_favoriteResort.dart';
import 'package:snowlive3/screens/onboarding/v_setProfileImage.dart';
import 'package:snowlive3/screens/resort/v_resortHome.dart';
import 'package:snowlive3/screens/v_MainHome.dart';
import '../../controller/vm_resortModelController.dart';
import '../../controller/vm_userModelController.dart';

class MoreTab extends StatefulWidget {
  MoreTab({Key? key}) : super(key: key);

  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  TextEditingController _textEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection**************************************************
    UserModelController _userModelController = Get.find<UserModelController>();
    LoginController _loginController = Get.find<LoginController>();
    //TODO: Dependency Injection**************************************************

    return SafeArea(
      child: Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
          extendBodyBehindAppBar: true,
          body: Container(
            color: Colors.white,
            child: ListView(
              children: [
                SizedBox(
                  height: 30,
                ),
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  accountName: Row(
                    children: [
                      Text(
                        _userModelController.displayName!,
                        style: TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Stack(children: [
                        GestureDetector(
                            onTap: () {
                              _textEditingController.clear();
                              showMaterialModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    height: 215,
                                    child: Column(
                                      children: [
                                        Form(
                                          key: _formKey,
                                          child: TextFormField(
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            controller: _textEditingController,
                                            decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13),
                                                hintText:
                                                    '${_userModelController.displayName}',
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey))),
                                            validator: (val) {
                                              if (val!.length <= 20 &&
                                                  val.length >= 1) {
                                                return null;
                                              } else if (val.length == 0) {
                                                return '닉네임을 입력해주세요.';
                                              } else {
                                                return '최대 글자 수를 초과했습니다.';
                                              }
                                            },
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('취소',
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                                style: TextButton.styleFrom(
                                                    splashFactory:
                                                        InkRipple.splashFactory,
                                                    minimumSize: Size(150, 56),
                                                    backgroundColor:
                                                        Colors.white),
                                              ),
                                            ),
                                            InkWell(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    await _userModelController
                                                        .updateNickname(
                                                            _textEditingController
                                                                .text);
                                                    Get.snackbar(
                                                        '닉네임을 변경하였습니다.', '',
                                                        snackPosition:
                                                            SnackPosition
                                                                .BOTTOM,
                                                        backgroundColor:
                                                            Colors.white,
                                                        duration: Duration(
                                                            milliseconds:
                                                                1000));
                                                    Navigator.pop(context);
                                                  } else {
                                                    Get.snackbar('닉네임 저장 실패',
                                                        '올바른 닉네임을 입력해주세요.',
                                                        snackPosition:
                                                            SnackPosition
                                                                .BOTTOM,
                                                        backgroundColor:
                                                            Colors.white,
                                                        duration: Duration(
                                                            milliseconds:
                                                                1000));
                                                  }
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                },
                                                child: Text(
                                                  '변경',
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                                style: TextButton.styleFrom(
                                                    splashFactory:
                                                        InkRipple.splashFactory,
                                                    minimumSize: Size(150, 56),
                                                    backgroundColor:
                                                        Colors.white),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Image.asset(
                              'assets/imgs/icons/icon_edit_pencil.png',
                              height: 22,
                              width: 22,
                            )),
                      ])
                    ],
                  ),
                  accountEmail: Text(
                    _userModelController.userEmial!,
                    style: TextStyle(color: Color(0xFF949494), fontSize: 13),
                  ),
                  currentAccountPicture: (_userModelController
                              .profileImageUrl !=
                          null)
                      ? GestureDetector(
                          onTap: () => Get.to(() => SetProfileImage_moreTab()),
                          child: Stack(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                child: CircleAvatar(
                                    backgroundColor: Colors.grey[100],
                                    backgroundImage: NetworkImage(
                                      _userModelController.profileImageUrl!,
                                    )),
                              ),
                              Positioned(
                                  bottom: 10,
                                  right: 4,
                                  child: GestureDetector(
                                    child: ExtendedImage.asset(
                                        'assets/imgs/icons/icon_profile_add.png',
                                        height: 22,
                                        width: 22),
                                    onTap: () {},
                                  ))
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: () => Get.to(() => SetProfileImage_moreTab()),
                          child: Stack(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                child: CircleAvatar(
                                  backgroundColor: Colors.yellow[100],
                                  backgroundImage: AssetImage(
                                      'assets/imgs/profile/img_profile_default_circle.png'),
                                ),
                              ),
                              Positioned(
                                  left: 50,
                                  child: Icon(
                                    Icons.image_rounded,
                                    color: Colors.grey,
                                  ))
                            ],
                          ),
                        ),
                  decoration: BoxDecoration(color: Colors.white),
                ),
                SizedBox(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {},
                  title: Text(
                    '웹캠',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF111111)),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 16,
                    color: Color(0xFFF5F5F5),
                    thickness: 1,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    Get.to(() => FavoriteResort());
                  },
                  title: Text(
                    '자주가는 스키장 설정',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF111111)),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 16,
                    color: Color(0xFFF5F5F5),
                    thickness: 1,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {},
                  title: Text(
                    '라이선스',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF111111)),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Container(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/imgs/logos/snowliveLogo_black.png',
                        width: 112,
                        height: 38,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Riding with Snowlive',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      height: 215,
                                      child: Column(
                                        children: [
                                          Text('정말 탈퇴하시겠습니까?'),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('취소',
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                                style: TextButton.styleFrom(
                                                    splashFactory:
                                                        InkRipple.splashFactory,
                                                    minimumSize: Size(150, 56),
                                                    backgroundColor:
                                                        Colors.white),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _loginController.deleteUser(
                                                      _userModelController.uid);
                                                },
                                                child: Text('확인',
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                                style: TextButton.styleFrom(
                                                    splashFactory:
                                                        InkRipple.splashFactory,
                                                    minimumSize: Size(150, 56),
                                                    backgroundColor:
                                                        Colors.white),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Text(
                              '회원탈퇴',
                              style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                elevation: 0,
                                minimumSize: Size(170, 50)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      height: 215,
                                      child: Column(
                                        children: [
                                          Text('로그아웃 하시겠습니까?'),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('취소',
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                                style: TextButton.styleFrom(
                                                    splashFactory:
                                                        InkRipple.splashFactory,
                                                    minimumSize: Size(150, 56),
                                                    backgroundColor:
                                                        Colors.white),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _loginController.signOut();
                                                },
                                                child: Text('확인',
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                                style: TextButton.styleFrom(
                                                    splashFactory:
                                                        InkRipple.splashFactory,
                                                    minimumSize: Size(150, 56),
                                                    backgroundColor:
                                                        Colors.white),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Text(
                              '로그아웃',
                              style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[100],
                                elevation: 0,
                                minimumSize: Size(170, 50)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
