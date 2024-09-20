
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/moreTab/v_licenseListPage.dart';
import 'package:com.snowlive/view/v_webPage.dart';
import 'package:com.snowlive/viewmodel/onboarding_login/vm_authcheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class setting_moreTab extends StatelessWidget {

  final AuthCheckViewModel _authCheckViewModel = Get.find<AuthCheckViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      ),
      body: ListView(
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
              '위치정보이용약관',
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
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            minVerticalPadding: 20,
            onTap: () {
              Get.to(() => LicenseListPage());
            },
            title: Text(
              '오픈소스라이선스',
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
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            minVerticalPadding: 20,
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      color: Colors.white,
                      height: 180,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              '로그아웃하시겠습니까?',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111111)),
                            ),
                            SizedBox(
                              height: 30,
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
                                          color: Color(0xFF3D83ED),
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                        splashFactory: InkRipple
                                            .splashFactory,
                                        elevation: 0,
                                        minimumSize:
                                        Size(100, 56),
                                        backgroundColor:
                                        Color(0xFF3D83ED).withOpacity(0.2),
                                        padding:
                                        EdgeInsets.symmetric(
                                            horizontal: 0)),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      Get.offAllNamed(AppRoutes.mainHome);
                                      await FlutterSecureStorage().delete(key: 'localUid');
                                      await FlutterSecureStorage().delete(key: 'device_id');
                                      await FlutterSecureStorage().delete(key: 'device_token');
                                      await FlutterSecureStorage().delete(key: 'user_id');
                                      _authCheckViewModel.userCheck();
                                    },
                                    child: Text(
                                      '확인',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                        splashFactory: InkRipple
                                            .splashFactory,
                                        elevation: 0,
                                        minimumSize:
                                        Size(100, 56),
                                        backgroundColor:
                                        Color(0xFF3D83ED),
                                        padding:
                                        EdgeInsets.symmetric(
                                            horizontal: 0)),
                                  ),
                                ),
                              ],
                            )
                          ],
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
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            minVerticalPadding: 20,
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      color: Colors.white,
                      height: 180,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              '정말 탈퇴하시겠습니까?',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111111)),
                            ),
                            SizedBox(
                              height: 30,
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
                                          color: Color(0xFF3D83ED),
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                        splashFactory: InkRipple
                                            .splashFactory,
                                        elevation: 0,
                                        minimumSize:
                                        Size(100, 56),
                                        backgroundColor:
                                        Color(0xFF3D83ED).withOpacity(0.2),
                                        padding:
                                        EdgeInsets.symmetric(
                                            horizontal: 0)),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      //회원탈퇴처리

                                    },
                                    child: Text(
                                      '확인',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    style: TextButton.styleFrom(
                                        splashFactory: InkRipple
                                            .splashFactory,
                                        elevation: 0,
                                        minimumSize:
                                        Size(100, 56),
                                        backgroundColor:
                                        Color(0xFF3D83ED),
                                        padding:
                                        EdgeInsets.symmetric(
                                            horizontal: 0)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  });
            },
            title: Text(
              '회원탈퇴',
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
          )
        ],
      ),
    );
  }
}
