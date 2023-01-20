import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';

class FleaMarket_List_Detail extends StatefulWidget {
  FleaMarket_List_Detail({Key? key}) : super(key: key);


  @override
  State<FleaMarket_List_Detail> createState() => _FleaMarket_List_DetailState();
}

class _FleaMarket_List_DetailState extends State<FleaMarket_List_Detail> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
//TODO: Dependency Injection**************************************************



  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
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
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ),
          body: Column(
            children: [
              CarouselSlider.builder(
          options: CarouselOptions(
          height: 200,
              viewportFraction: 1,
              reverse: true,
              enableInfiniteScroll: false,
             ),
          itemCount: 3,
          itemBuilder: (context, index, pageViewIndex) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: 44,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/imgs/splash_screen/splash1.png',)
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
              SizedBox(
                height: 20,
              ),
              Container(
                   child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          ExtendedImage.asset(
                              'assets/imgs/profile/img_profile_default_circle.png',
                              shape: BoxShape.circle,
                              borderRadius:
                              BorderRadius.circular(20),
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                            ),
                        SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '닉네임',
                                      //chatDocs[index].get('displayName'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF111111)),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '시간',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF949494),
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  ListTile(
                    leading: Text('카테고리'),
                    title: Text('데크'),
                  ),
                  ListTile(
                    leading: Text('제품명'),
                    title: Text('보드보드'),
                  ),
                  ListTile(
                    leading: Text('가격'),
                    title: Text('1,000원'),
                  ),
                  ListTile(
                    leading: Text('거래지역'),
                    title: Text('휘닉스평창'),
                  ),
                  ListTile(
                    leading: Text('거래방식'),
                    title: Text('직거래'),
                  ),
                  ListTile(
                    title: Text('상세설명'),
                    subtitle: Text('설명'),
                  )
                ]
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {  },
                child: Text('메세지 보내기'),
              )
          ],
          ),
        ),
      ),
    );
  }
}

