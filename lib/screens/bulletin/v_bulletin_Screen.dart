import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:com.snowlive/controller/vm_fleaChatController.dart';
import 'package:com.snowlive/screens/bulletin/Crew/v_bulletin_Crew_List_Screen.dart';
import 'package:com.snowlive/screens/bulletin/Room/v_bulletin_Room_List_Screen.dart';
import '../../controller/vm_bulletinCrewController.dart';
import '../../controller/vm_bulletinRoomController.dart';

class BulletinScreen extends StatefulWidget {
  BulletinScreen({Key? key}) : super(key: key);

  @override
  State<BulletinScreen> createState() => _BulletinScreenState();
}

class _BulletinScreenState extends State<BulletinScreen> {
  int counter = 0;
  List<bool> isTap = [
    true,
    false,
  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {

    //TODO : ****************************************************************
    Get.put(BulletinRoomModelController(), permanent: true);
    Get.put(BulletinCrewModelController(), permanent: true);
    Get.put(FleaChatModelController(), permanent: true);
    //TODO : ****************************************************************

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
              iconTheme: IconThemeData(size: 26, color: Colors.black87),
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
              elevation: 0.0,
              titleSpacing: 0,
              centerTitle: true,
              title: Text(
                '커뮤니티',
                style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              backgroundColor: Colors.white,
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
                                    '시즌방',
                                    style: TextStyle(
                                        color: (isTap[0])
                                            ? Color(0xFF111111)
                                            : Color(0xFFc8c8c8),
                                        fontWeight: (isTap[0])
                                            ? FontWeight.bold
                                        : FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    print('시즌방페이지로 전환');
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
                              width: 56,
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
                                    '단톡방/동호회',
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
                                    print('동호회 페이지로 전환');
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
                              width: 106,
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
                    Expanded(child: Bulletin_Room_List_Screen()),
                  if(isTap[1]==true)
                    Expanded(child: Bulletin_Crew_List_Screen()),
                ],
              ),
            ),
          ],
        ),
      )


    );
  }
}

