import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:com.snowlive/screens/more/friend/invitation/v_inviteListPage_friend.dart';
import 'package:com.snowlive/screens/more/friend/invitation/v_invitedListPage_friend.dart';
import '../../../../controller/user/vm_userModelController.dart';

class InvitationScreen_friend extends StatefulWidget {
  InvitationScreen_friend({Key? key}) : super(key: key);

  @override
  State<InvitationScreen_friend> createState() => _InvitationScreen_friendState();
}

class _InvitationScreen_friendState extends State<InvitationScreen_friend> {
  int counter = 0;
  List<bool> isTap = [
    true,
    false,
  ];

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
                onTap: () {
                  Get.back();
                },
              ),
              iconTheme: IconThemeData(size: 26, color: Colors.black87),
              centerTitle: true,
              titleSpacing: 0,
              title: Text(
                '친구추가',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
            )
          ],
        ),
      ),
      body:
      SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 44,
              child: Container(
                width: _size.width,
                height: 1,
                color: Color(0xFFECECEC),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '요청받은 목록',
                                    style: TextStyle(
                                        color: (isTap[0])
                                            ? Color(0xFF111111)
                                            : Color(0xFFc8c8c8),
                                        fontWeight: (isTap[0])
                                            ? FontWeight.bold
                                        : FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  onPressed: () async{
                                    HapticFeedback.lightImpact();
                                    print('요청받은 목록으로 전환');
                                    setState(() {
                                      isTap[0] = true;
                                      isTap[1] = false;
                                    });
                                    print(isTap);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: 3,
                              color:
                              (isTap[0]) ? Color(0xFF111111) : Colors.transparent,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '요청중인 목록',
                                    style: TextStyle(
                                        color: (isTap[1])
                                            ? Color(0xFF111111)
                                            : Color(0xFFc8c8c8),
                                        fontWeight:
                                        (isTap[1])
                                            ? FontWeight.bold
                                        : FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    print('요청중인 목록으로 전환');
                                    setState(() {
                                      isTap[0] = false;
                                      isTap[1] = true;
                                    });
                                    print(isTap);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(top: 0),
                                    minimumSize: Size(40, 10),
                                    backgroundColor: Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: 3,
                              color:
                              (isTap[1]) ? Color(0xFF111111) : Colors.transparent,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  if(isTap[0]==true)
                    Expanded(child: InvitedListPage_friend()),
                  if(isTap[1]==true)
                    Expanded(child: InviteListPage_friend()),
                ],
              ),
            ),
          ],
        ),
      )


    );
  }
}

