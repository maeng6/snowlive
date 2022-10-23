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
    final double _statusBarSize = MediaQuery.of(context).padding.top;
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
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      ElevatedButton(
                        child: Text(
                          '의류',
                          style: TextStyle(
                              color: (isBrand)
                                  ? Color(0xFFFFFFFF)
                                  : Color(0xFF111111),
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        onPressed: () {
                          isBrand = true;
                          print('브랜드페이지로 전환');
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(54, 32),
                          backgroundColor: (isBrand)
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
                          '샵',
                          style: TextStyle(
                              color: (isBrand)
                                  ? Color(0xFF111111)
                                  : Color(0xFFFFFFFF)),
                        ),
                        onPressed: () {
                          isBrand = false;
                          print('샵페이지로 전환');
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(54, 32),
                            backgroundColor: (isBrand)
                                ? Color(0xFFFFFFFF)
                                : Color(0xFF111111),
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
                ),
              ],
              centerTitle: false,
              titleSpacing: 0,
              title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '브랜드',
                    style: GoogleFonts.notoSans(
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.w900,
                        fontSize: 23),
                  )),
              backgroundColor: Colors.white,
              elevation: 0.0,
            )
          ],
        ),
      ),
      body:
      (isBrand) ? clothWebGridView(context) : shopWebGridView(context),
    );
  }
}

Widget clothWebGridView(BuildContext context) {
  final double _statusBarSize = MediaQuery.of(context).padding.top;
  final Size _size = MediaQuery.of(context).size;
  return Padding(
    padding:  EdgeInsets.only(left: 16, right: 16,top:_statusBarSize ),
    child: GridView.builder(
        padding: EdgeInsets.only(top: 68, bottom: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 30,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8),
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
                  child: Container(
                      width: _size.width * 0.3,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Color(0xFFF5F5F5)),
                        shape: BoxShape.circle,
                        color: Color(0xFFF5F5F5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ExtendedImage.asset(
                          '${clothBrandImageAssetList[index]}',
                          width: 20,
                        ),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  '${clothBrandNameList[index]}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF111111)),
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
    padding: EdgeInsets.only(left: 16, right: 16,top: _statusBarSize ),
    child: GridView.builder(
        padding: EdgeInsets.only(top: 68, bottom: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 30,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8),
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
                  child: Container(
                      width: _size.width * 0.3,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Color(0xFFF5F5F5)),
                        shape: BoxShape.circle,
                        color: Color(0xFFF5F5F5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ExtendedImage.asset(
                          '${shopImageAssetList[index]}',
                          width: 20,
                        ),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${shopNameList[index]}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF111111)),
                ),
              ),
            ],
          );
        }),
  );
}
