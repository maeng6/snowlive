import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import '../../model/m_brandModel.dart';

class BrandWebBody extends StatelessWidget {
  const BrandWebBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(58),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppBar(
                iconTheme: IconThemeData(size: 26, color: Colors.black87),
                actions: [],
                centerTitle: false,
                titleSpacing: 0,
                title: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      '브랜드',
                      style: TextStyle(
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    )),
                backgroundColor: Colors.white,
                elevation: 0.0,
              )
            ],
          ),
        ),
        body: Column(
              children: [clothWebGridView(context)],
            ),
      ),
    );
  }
}

Widget clothWebGridView(BuildContext context) {
  final Size _size = MediaQuery.of(context).size;
  return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: GridView.builder(
          padding: EdgeInsets.only(top: 68, bottom: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68),
            itemCount: clothBrandNameList.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                            width: _size.width * 0.5 - 22,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: GestureDetector(
                                  onTap: () => Get.to(WebPage(
                                      url: '${clothBrandHomeUrlList[index]}')),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ExtendedImage.network(
                                          '${clothBrandImageUrlList[index]}',
                                          fit: BoxFit.cover,
                                          cache: true,
                                        ),
                                      ),
                                    ],
                                  )),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${clothBrandNameList[index]}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ));
}
