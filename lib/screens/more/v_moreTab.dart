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
          backgroundColor: Color(0xFFF2F4F6),
          extendBodyBehindAppBar: true,
          body: Container(
            color: Colors.white,
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Row(
                    children: [
                      Text(
                        _userModelController.displayName!,
                        style: TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 7,
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
                                                          SnackPosition.BOTTOM,
                                                      backgroundColor:
                                                          Colors.white,
                                                      duration: Duration(
                                                          milliseconds: 1000));
                                                  Navigator.pop(context);
                                                } else {
                                                  Get.snackbar('닉네임 저장 실패',
                                                      '올바른 닉네임을 입력해주세요.',
                                                      snackPosition:
                                                          SnackPosition.BOTTOM,
                                                      backgroundColor:
                                                          Colors.white,
                                                      duration: Duration(
                                                          milliseconds: 1000));
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
                          child: Icon(
                            Icons.edit,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ),
                      ])
                    ],
                  ),
                  accountEmail: Text(
                    _userModelController.userEmial!,
                    style: TextStyle(color: Colors.grey),
                  ),
                  currentAccountPicture: (_userModelController
                              .profileImageUrl !=
                          null)
                      ? GestureDetector(
                          onTap: () => Get.to(() => SetProfileImage_moreTab()),
                          child: Stack(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                child: CircleAvatar(
                                    backgroundColor: Colors.grey[100],
                                    backgroundImage: NetworkImage(
                                      _userModelController.profileImageUrl!,
                                    )),
                              ),
                              Positioned(
                                  left: 50,
                                  child: Icon(
                                    Icons.image_rounded,
                                    color: Colors.grey,
                                  ))
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: () => Get.to(() => SetProfileImage_moreTab()),
                          child: Stack(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                child: CircleAvatar(
                                  backgroundColor: Colors.yellow[100],
                                  backgroundImage: AssetImage(
                                      'assets/imgs/profile/profileImage.png'),
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
                ListTile(
                  onTap: () {},
                  title: Text(
                    '날씨',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                Divider(
                  thickness: 1,
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    '웹캠',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                Divider(
                  thickness: 1,
                ),
                ListTile(
                  onTap: () {
                    Get.to(() => FavoriteResort());
                  },
                  title: Text(
                    '자주가는 스키장 설정',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                Divider(
                  thickness: 1,
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    'SnowLive',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                Divider(
                  thickness: 1,
                ),
                ListTile(
                  onTap: () {},
                  title: Text(
                    '라이선스',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                SizedBox(
                  height: 50,
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
                        height: 5,
                      ),
                      Text(
                        'Riding with Snowlive',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(
                        height: 20,
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
                              style: TextStyle(color: Colors.black87),
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
                              style: TextStyle(color: Colors.black87),
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
