import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Event/v_bulletin_Event_List_Screen.dart';
import 'Free/v_bulletin_Free_List_Screen.dart';

class BulletinScreen extends StatefulWidget {
  BulletinScreen({required this.tap_1,required this.tap_2 });

  bool? tap_1;
  bool? tap_2;

  @override
  State<BulletinScreen> createState() => _BulletinScreenState();
}

class _BulletinScreenState extends State<BulletinScreen> {
  int counter = 0;
  late List<bool?> isTap;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isTap = [
      widget.tap_1,
      widget.tap_2,
    ];

  }

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
                iconTheme: IconThemeData(size: 26, color: Colors.black87),
                elevation: 0.0,
                titleSpacing: 0,
                centerTitle: false,
                title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '커뮤니티',
                    style: TextStyle(
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 6),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Container(
                                  height: 40,
                                  child: ElevatedButton(
                                    child: Text(
                                      '자유게시판',
                                      style: TextStyle(
                                          color: (isTap[0]!)
                                              ? Color(0xFF111111)
                                              : Color(0xFFc8c8c8),
                                          fontWeight: (isTap[0]!)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 16),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      print('자유게시판으로 전환');
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
                                width: 78,
                                height: 3,
                                color:
                                (isTap[0]!) ? Color(0xFF111111) : Colors.transparent,
                              )
                            ],
                          ),
                        ),//자게
                        Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Container(
                                  height: 40,
                                  child: ElevatedButton(
                                    child: Text(
                                      '클리닉·행사',
                                      style: TextStyle(
                                          color: (isTap[1]!)
                                              ? Color(0xFF111111)
                                              : Color(0xFFc8c8c8),
                                          fontWeight:
                                          (isTap[1]!)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 16),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      print('클리닉 페이지로 전환');
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
                                width: 86,
                                height: 3,
                                color:
                                (isTap[1]!) ? Color(0xFF111111) : Colors.transparent,
                              )
                            ],
                          ),
                        ),//클리닉
                      ],
                    ),
                  ),
                  if(isTap[0]==true)
                    Expanded(child: Bulletin_Free_List_Screen()),
                  if(isTap[1]==true)
                    Expanded(child: Bulletin_Event_List_Screen()),

                ],
              ),
            ],
          ),
        )


    );
  }
}

