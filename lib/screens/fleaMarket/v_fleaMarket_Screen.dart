import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Screen.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import '../../model/m_brandModel.dart';
import '../../model/m_shopModel.dart';

class FleaMarketScreen extends StatefulWidget {
  FleaMarketScreen({Key? key}) : super(key: key);

  @override
  State<FleaMarketScreen> createState() => _FleaMarketScreenState();
}

class _FleaMarketScreenState extends State<FleaMarketScreen> {
  List<String> labels = ['스노우마켓', '판매내역', '채팅방'];
  int counter = 0;
  List<bool> isTap = [
    true,
    false,
    false,
  ];

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 3,
                ),
                ElevatedButton(
                  child: Text(
                    '판매목록',
                    style: TextStyle(
                        color: isTap[0]
                            ? Color(0xFFFFFFFF)
                            : Color(0xFF111111),
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
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
                    minimumSize: Size(54, 32),
                    backgroundColor: isTap[0]
                        ? Color(0xFF111111)
                        : Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                ElevatedButton(
                  child: Text(
                    '판매내역',
                    style: TextStyle(
                        color: isTap[1]
                            ? Color(0xFFFFFFFF)
                            : Color(0xFF111111)),
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
                      minimumSize: Size(54, 32),
                      backgroundColor: isTap[1]
                          ? Color(0xFF111111)
                          : Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                SizedBox(
                  width: 3,
                ),
                ElevatedButton(
                  child: Text(
                    '채팅방',
                    style: TextStyle(
                        color: isTap[2]
                            ? Color(0xFFFFFFFF)
                            : Color(0xFF111111)),
                  ),
                  onPressed: () {
                    print('판매내역 페이지로 전환');
                    setState(() {isTap[0] = false;
                    isTap[1] = false;
                    isTap[2] = true;});
                    print(isTap);
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(54, 32),
                      backgroundColor: (isTap[2])
                          ? Color(0xFF111111)
                          : Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
            if(isTap[0]==true)
              Expanded(child: FleaMarket_List_Screen()),
            if(isTap[1]==true)
              Expanded(child: FleaMarket_List_Screen()),
            if(isTap[2]==true)
              Expanded(child: FleaMarket_List_Screen())
          ],
        ),
      ),

    );
  }
}