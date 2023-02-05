import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import '../../model/m_brandModel.dart';
import '../../model/m_shopModel.dart';

class BrandWebBody extends StatefulWidget {
  BrandWebBody({Key? key}) : super(key: key);

  @override
  State<BrandWebBody> createState() => _BrandWebBodyState();
}

class _BrandWebBodyState extends State<BrandWebBody> {
  List<String> labels = ['의류', '장비'];
  int counter = 0;
  bool isBrand = true;

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
              centerTitle: false,
              titleSpacing: 0,
              title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '브랜드',
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
                Stack(
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                child: Text(
                                  '의류 브랜드 17',
                                  style: TextStyle(
                                      color: (isBrand)
                                          ? Color(0xFF111111)
                                          : Color(0xFFC8C8C8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                                onPressed: () {
                                  print('브랜드페이지로 전환');
                                  setState(() {
                                    isBrand = true;
                                  });
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
                                width: _size.width * 0.5 -18,
                                height: 3,
                                color:
                                (isBrand) ? Color(0xFF111111) : Colors.transparent,
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                child: Text(
                                  '보드샵 6',
                                  style: TextStyle(
                                      color: (isBrand)
                                          ? Color(0xFFC8C8C8)
                                          : Color(0xFF111111),
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  print('샵페이지로 전환');
                                  setState(() {
                                    isBrand = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size(54, 10),
                                    backgroundColor: (isBrand)
                                        ? Color(0xFFFFFFFF)
                                        : Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                    elevation: 0,
                                    ),
                              ),
                              Container(
                                width: _size.width * 0.5 - 18,
                                height: 3,
                                color:
                                (isBrand) ? Colors.transparent : Color(0xFF111111),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isBrand == true) Expanded(child: clothWebGridView(context)),
                if (isBrand == false) Expanded(child: shopWebGridView(context)),
              ],
            ),
          )

    );
  }
}

Widget clothWebGridView(BuildContext context) {
  final double _statusBarSize = MediaQuery.of(context).padding.top;
  final Size _size = MediaQuery.of(context).size;
  return Padding(
    padding:  EdgeInsets.only(left: 16, right: 16 ),
    child: GridView.builder(
        padding: EdgeInsets.only(top: 12, bottom: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 10,
            childAspectRatio: 5),
        itemCount: clothBrandList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(
                      () => WebPage(url: '${clothBrandHomeUrlList[index]}')),
                  child: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Container(
                        width: _size.width,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFF0F1F2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: ExtendedImage.asset(
                                        '${clothBrandImageAssetList[index]}',
                                        width: 30,
                                        height: 30,
                                        scale: 4,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 18,
                                  ),
                                  Text(
                                    '${clothBrandNameList[index]}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF111111)),
                                  ),
                                ],
                              ),
                              Image.asset(
                                'assets/imgs/icons/icon_arrow_g.png',
                                height: 24,
                                width: 24,
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ),
            ],
          );
        }),
  );
}

Widget shopWebGridView(BuildContext context) {
  final double _statusBarSize = MediaQuery.of(context).padding.top;
  final Size _size = MediaQuery.of(context).size;
  return Padding(
    padding: EdgeInsets.only(left: 16, right: 16 ),
    child: GridView.builder(
        padding: EdgeInsets.only(top: 12, bottom: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 10,
            childAspectRatio: 5),
        itemCount: shopNameList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      Get.to(() => WebPage(url: '${shopHomeUrlList[index]}')),
                  child: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Container(
                        width: _size.width,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFF0F1F2),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(6),
                                      child: ExtendedImage.asset(
                                        '${shopImageAssetList[index]}',
                                        width: 30,
                                        height: 30,
                                        scale: 4,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 18,
                                  ),
                                  Text(
                                    '${shopNameList[index]}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF111111)),
                                  ),
                                ],
                              ),
                              Image.asset(
                                'assets/imgs/icons/icon_arrow_g.png',
                                height: 24,
                                width: 24,
                                opacity: AlwaysStoppedAnimation(.4),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ),

            ],
          );
        }),
  );
}
