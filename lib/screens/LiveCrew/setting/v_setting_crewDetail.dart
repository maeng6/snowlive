import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_imageController.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/screens/LiveCrew/setting/v_setting_SNS.dart';
import 'package:snowlive3/screens/LiveCrew/setting/v_setting_description.dart';
import 'package:snowlive3/screens/LiveCrew/setting/v_setting_notice.dart';
import 'package:snowlive3/screens/LiveCrew/setting/v_setting_setLogo&Color.dart';
import 'package:snowlive3/screens/LiveCrew/setting/v_setting_delegation.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../widget/w_fullScreenDialog.dart';

class Setting_crewDetail extends StatelessWidget {
  Setting_crewDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection**************************************************
    LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
    UserModelController _userModelController = Get.find<UserModelController>();
    Get.put(ImageController(), permanent: true);
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
      body: Column(
        children: [
          if(_liveCrewModelController.leaderUid == _userModelController.uid)
            Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    Get.to(()=>SetModifyNotice_crewDetail());
                  },
                  title: Text(
                    '공지사항 변경',
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
                ), //공지사항변경
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    Get.to(()=>SetModifyDescription_crewDetail());
                  },
                  title: Text(
                    '소개글 변경',
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
                ), //소개글변경
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    print(_liveCrewModelController.crewColor);
                    Get.to(()=>SetCrewLogoColor_setting(
                        crewColor:
                        (_liveCrewModelController.crewColor != null && _liveCrewModelController.crewColor != '')
                            ? _liveCrewModelController.crewColor
                            : 0xffF1F1F3
                    ));
                  },
                  title: Text(
                    '로고∙컬러 변경',
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
                ), //로고컬러변경
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    Get.to(() => SetSNSlink_crewDetail());
                  },
                  title: Text(
                    'SNS 링크 연결하기',
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
                ), //sns링크연결하기
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  minVerticalPadding: 20,
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            color: Colors.white,
                            height: 220,
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
                                    '크루장을 위임하시겠습니까?',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111111)),
                                  ),SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    '크루장을 위임하면 되돌릴 수 없으며, 위임하는 즉시 적용됩니다. 계속하시겠습니까?',
                                    style: TextStyle(
                                      color: Color(0xff666666),
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 24,
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
                                              Color(0xff3D83ED).withOpacity(0.2),
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
                                            Get.to(()=>Setting_delegation());
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
                    '크루장 위임',
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
                ), //크루장위임
              ],
            ),
          (_liveCrewModelController.leaderUid == _userModelController.uid)
                ? ListTile(
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
                                '라이브 크루를 삭제하시겠습니까?',
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
                                          Color(0xff3D83ED).withOpacity(0.2),
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
                                        if(_liveCrewModelController.memberUidList!.length == 1) {
                                          try {
                                            Navigator.pop(context);
                                            CustomFullScreenDialog.showDialog();
                                            await _imageController.deleteAllCrewGalleryImages('${_liveCrewModelController.crewID}');
                                            await _liveCrewModelController
                                                .deleteCrew(crewID: _liveCrewModelController.crewID);
                                            await _userModelController.getCurrentUser_crew(_userModelController.uid);
                                            CustomFullScreenDialog.cancelDialog();
                                            for(int i=0; i<2; i++){
                                              await _userModelController.getCurrentUser(_userModelController.uid);
                                              Get.back();
                                            }
                                          } catch (e) {
                                            print('삭제 오류');
                                            for(int i=0; i<2; i++){
                                              await _userModelController.getCurrentUser(_userModelController.uid);
                                              Get.back();
                                            }
                                          }
                                        }else{
                                          Get.dialog(AlertDialog(
                                            contentPadding: EdgeInsets.only(
                                                bottom: 0,
                                                left: 20,
                                                right: 20,
                                                top: 30),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10.0)),
                                            buttonPadding:
                                            EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 0),
                                            content: Text(
                                              '모든 회원을 내보낸 뒤에 삭제할 수 있습니다.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15),
                                            ),
                                            actions: [
                                              Row(
                                                children: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                            context);
                                                      },
                                                      child: Text(
                                                        '확인',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xFF949494),
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        ),
                                                      )),
                                                ],
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                              )
                                            ],
                                          ));

                                        }

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
                                          Color(0xff3D83ED),
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
                '크루 삭제',
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
                : ListTile(
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
                                '라이브 크루를 탈퇴하시겠습니까?',
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
                                          Color(0xff3D83ED).withOpacity(0.2),
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
                                          Navigator.pop(context);
                                          CustomFullScreenDialog.showDialog();
                                          await _liveCrewModelController.deleteCrewMember(crewID: _liveCrewModelController.crewID, memberUid: _userModelController.uid);
                                          await _userModelController.getCurrentUser(_userModelController.uid);
                                          CustomFullScreenDialog.cancelDialog();
                                          for(int i=0; i<2; i++){
                                            Get.back();
                                          }
                                        }catch(e){
                                          print('삭제 오류');
                                          Navigator.pop(context);
                                        }

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
                                          Color(0xff3D83ED),
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
                '크루 탈퇴',
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
            ), // 크루삭제
        ],
      ),
    );
  }
}
