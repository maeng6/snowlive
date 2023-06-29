import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/screens/LiveCrew/v_liveCrewHome.dart';
import '../../controller/vm_userModelController.dart';
import '../../widget/w_fullScreenDialog.dart';

class Setting_crewDetail extends StatelessWidget {
  Setting_crewDetail({Key? key, required this.crewID}) : super(key: key);

  String? crewID;

  @override
  Widget build(BuildContext context) {
    //TODO: Dependency Injection**************************************************
    LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
    UserModelController _userModelController = Get.find<UserModelController>();
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
                                      if(_liveCrewModelController.memberUidList!.length == 1) {
                                        try {
                                          Navigator.pop(context);
                                          CustomFullScreenDialog.showDialog();
                                          await _liveCrewModelController
                                              .deleteCrew(crewID: crewID);
                                          await _userModelController
                                              .deleteMyCrew();
                                          CustomFullScreenDialog.cancelDialog();
                                          Get.to(() => LiveCrewHome());
                                        } catch (e) {
                                          print('삭제 오류');
                                          Navigator.pop(context);
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
                                        Navigator.pop(context);
                                        CustomFullScreenDialog.showDialog();
                                        await _liveCrewModelController.deleteCrewMember(crewID: crewID, memberUid: _userModelController.uid);
                                        CustomFullScreenDialog.cancelDialog();
                                        Get.to(()=>LiveCrewHome());
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
          ),
        ],
      ),
    );
  }
}
