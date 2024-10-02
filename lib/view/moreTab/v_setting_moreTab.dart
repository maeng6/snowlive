
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/moreTab/v_licenseListPage.dart';
import 'package:com.snowlive/view/v_webPage.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_authcheck.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_login.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class Setting_moreTabView extends StatelessWidget {

  final AuthCheckViewModel _authCheckViewModel = Get.find<AuthCheckViewModel>();
  final LoginViewModel _loginViewModel = Get.find<LoginViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
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
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    Get.to(() => WebPage(
                      url:
                      'https://sites.google.com/view/snowlive-termsofservice/%ED%99%88',
                    ));
                  },
                  title: Text(
                    '이용약관',
                    style: SDSTextStyle.bold.copyWith(
                        fontSize: 15,
                        color: SDSColor.gray900),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    Get.to(() => WebPage(
                      url:
                      'https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88',
                    ));
                  },
                  title: Text(
                    '개인정보처리방침',
                    style: SDSTextStyle.bold.copyWith(
                        fontSize: 15,
                        color: SDSColor.gray900),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    Get.to(() => WebPage(
                      url:
                      'https://sites.google.com/view/134creativelablocationinfo/%ED%99%88',
                    ));
                  },
                  title: Text(
                    '위치 정보 이용약관',
                    style: SDSTextStyle.bold.copyWith(
                        fontSize: 15,
                        color: SDSColor.gray900),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    Get.to(() => LicenseListPage());
                  },
                  title: Text(
                    '오픈소스라이선스',
                    style: SDSTextStyle.bold.copyWith(
                        fontSize: 15,
                        color: SDSColor.gray900),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    showModalBottomSheet(
                        backgroundColor: SDSColor.snowliveWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
                        context: context,
                        builder: (context) {
                          return SafeArea(
                            child: Container(
                              height: 175,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
                                child: Column(
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
                                      '로그아웃하시겠어요?',
                                      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              '취소',
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                              ),
                                              elevation: 0,
                                              splashFactory: InkRipple.splashFactory,
                                              minimumSize: Size(100, 56),
                                              backgroundColor: Color(0xff7C899D),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              Get.toNamed(AppRoutes.mainHome);
                                              await FlutterSecureStorage().delete(key: 'localUid');
                                              await FlutterSecureStorage().delete(key: 'device_id');
                                              await FlutterSecureStorage().delete(key: 'device_token');
                                              await FlutterSecureStorage().delete(key: 'user_id');
                                              await FirebaseAuth.instance.signOut();
                                              await _authCheckViewModel.userCheck();
                                            },
                                            child: Text(
                                              '확인',
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                              ),
                                              elevation: 0,
                                              splashFactory: InkRipple.splashFactory,
                                              minimumSize: Size(100, 56),
                                              backgroundColor: Color(0xFF3D83ED),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                ),
                            ),
                          );
                        });
                  },
                  title: Text(
                    '로그아웃',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF111111)),
                  ),
                  trailing: Image.asset(
                    'assets/imgs/icons/icon_arrow_g.png',
                    height: 24,
                    width: 24,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 5, top: 24),
              child: TextButton(
                style: TextButton.styleFrom(
                  surfaceTintColor: Colors.transparent,
                  overlayColor: Colors.transparent
                ),
                  onPressed: (){
                showModalBottomSheet(
                    backgroundColor: SDSColor.snowliveWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    ),
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Container(
                          height: 223,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
                            child: Column(
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
                                  '정말 스노우라이브를 탈퇴하시겠어요?',
                                  style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '스노우라이브를 탈퇴하시면 그동안 기록되었던 라이브온 기록과 랭킹 데이터, 게시글 등 모두 삭제됩니다.',
                                  textAlign: TextAlign.center,
                                  style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          '취소',
                                          style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(6)),
                                          ),
                                          elevation: 0,
                                          splashFactory: InkRipple.splashFactory,
                                          minimumSize: Size(100, 56),
                                          backgroundColor: Color(0xff7C899D),
                                        ),
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
                                          await _loginViewModel.deleteUser(userId: _userViewModel.user.user_id);
                                        },
                                        child: Text(
                                          '확인',
                                          style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(6)),
                                          ),
                                          elevation: 0,
                                          splashFactory: InkRipple.splashFactory,
                                          minimumSize: Size(100, 56),
                                          backgroundColor: Color(0xFF3D83ED),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
                  child: Padding(
                    padding: EdgeInsets.only(right: 30),
                    child: Text('회원탈퇴',
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 15,
                        color: SDSColor.gray500,
                          decoration: TextDecoration.underline,
                        decorationColor: SDSColor.gray500,
                        decorationThickness: 1,
                      ),
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}
