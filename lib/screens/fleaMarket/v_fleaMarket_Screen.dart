import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/controller/vm_fleaChatController.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Screen.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_My_Screen.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_chatroom_List.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import '../../model/m_brandModel.dart';
import '../../model/m_shopModel.dart';

class FleaMarketScreen extends StatefulWidget {
  FleaMarketScreen({Key? key}) : super(key: key);

  @override
  State<FleaMarketScreen> createState() => _FleaMarketScreenState();
}

class _FleaMarketScreenState extends State<FleaMarketScreen> {
  List<String> labels = ['스노우마켓', '판매내역','채팅목록', ];
  int counter = 0;
  List<bool> isTap = [
    true,
    false,
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
    Get.put(FleaModelController(), permanent: true);
    Get.put(FleaChatModelController(), permanent: true);
    //TODO : ****************************************************************

    Size _size = MediaQuery.of(context).size;

    print(isTap);
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
              centerTitle: false,
              titleSpacing: 0,
              title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '스노우마켓',
                    style: GoogleFonts.notoSans(
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.w900,
                        fontSize: 22),
                  )),
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
              top: 50,
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
                      Column(
                        children: [
                          ElevatedButton(
                            child: Text(
                              '상품목록',
                              style: TextStyle(
                                  color: (isTap[0])
                                      ? Color(0xFF111111)
                                      : Color(0xFFC8C8C8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                            onPressed: () {
                              print('판매목록페이지로 전환');
                              setState(() {
                                isTap[0] = true;
                                isTap[1] = false;
                                isTap[2] = false;
                              });
                              print(isTap);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(54, 10),
                              backgroundColor: Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                          Container(
                            width: _size.width * 0.3333-12,
                            height: 3,
                            color:
                            (isTap[0]) ? Color(0xFF111111) : Colors.transparent,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            child: Text(
                              '내글보기',
                              style: TextStyle(
                                  color: (isTap[1])
                                      ? Color(0xFF111111)
                                      : Color(0xFFC8C8C8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                            onPressed: () {
                              print('판매내역 페이지로 전환');
                              setState(() {
                                isTap[0] = false;
                                isTap[1] = true;
                                isTap[2] = false;
                              });
                              print(isTap);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(54, 10),
                              backgroundColor: Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                          Container(
                            width: _size.width * 0.3333-12,
                            height: 3,
                            color:
                            (isTap[1]) ? Color(0xFF111111) : Colors.transparent,
                          )
                        ],
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            child: Text(
                              '채팅목록',
                              style: TextStyle(
                                  color: (isTap[2])
                                      ? Color(0xFF111111)
                                      : Color(0xFFC8C8C8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                            onPressed: () {
                              print('판매내역 페이지로 전환');
                              setState(() {isTap[0] = false;
                              isTap[1] = false;
                              isTap[2] = true;

                              });
                              print(isTap);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(54, 10),
                              backgroundColor: Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                          Container(
                            width: _size.width * 0.3333-12,
                            height: 3,
                            color:
                            (isTap[2]) ? Color(0xFF111111) : Colors.transparent,
                          )
                        ],
                      ),
                    ],
                  ),
                  if(isTap[0]==true)
                    Expanded(child: FleaMarket_List_Screen()),
                  if(isTap[1]==true)
                    Expanded(child: FleaMarket_My_Screen()),
                  if(isTap[2]==true)
                    Expanded(child: FleaMarket_Chatroom_List()),

                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}