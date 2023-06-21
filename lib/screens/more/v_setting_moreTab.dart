import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_imageController.dart';
import 'package:snowlive3/screens/more/friend/v_repoList.dart';
import '../../controller/vm_loginController.dart';
import '../../controller/vm_userModelController.dart';

class setting_moreTab extends StatelessWidget {
  const setting_moreTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection**************************************************
    Get.put(ImageController(), permanent: true);
    UserModelController _userModelController = Get.find<UserModelController>();
    LoginController _loginController = Get.find<LoginController>();
    ImageController _imageController = Get.find<ImageController>();
    //TODO: Dependency Injection**************************************************
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
                                        Color(0xff555555),
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
                                      try{
                                        await _imageController.deleteProfileImage();
                                      }catch(e){print('프사 없음');}
                                      await _loginController
                                          .deleteUser(
                                          uid: _userModelController.uid,
                                          fleaCount: _userModelController.fleaCount
                                      );
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
                                        Color(0xff2C97FB),
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
