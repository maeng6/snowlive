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
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: Scaffold(
            body: Column(
          children: [clothWebGridView()],
        )
        ),
      ),
    );
  }
}

Widget clothWebGridView() {

  return Expanded(
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 30,
              crossAxisSpacing: 20,
              childAspectRatio: 0.681),
          itemCount: clothBrandNameList.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 150, minHeight: 150, minWidth: 150) ,
                          decoration: BoxDecoration(
                            boxShadow:[
                          BoxShadow(
                          color: Colors.grey,
                          offset: Offset(1.0, 1.0),
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                          ),
                          BoxShadow(
                          color: Colors.white,
                          offset: Offset(-1.0, -1.0),
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                          ),
                            ] ,
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(20)
                              )
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GestureDetector(
                                onTap: ()=> Get.to(WebPage(url:'${clothBrandHomeUrlList[index]}' )),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ExtendedImage.network('${clothBrandImageUrlList[index]}',
                                        fit: BoxFit.fitHeight,
                                        cache:true,
                                      ),
                                    ),
                                  ],
                                )),
                          )
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('${clothBrandNameList[index]}',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 9,
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
              ],
            );
          }));
}