import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:com.snowlive/screens/v_webPage.dart';

import '../../controller/vm_urlLauncherController.dart';
import '../../controller/vm_userModelController.dart';

class DiscoverScreen_ResortBanner extends StatefulWidget {
  @override
  _DiscoverScreen_ResortBannerState createState() =>
      _DiscoverScreen_ResortBannerState();
}

class _DiscoverScreen_ResortBannerState
    extends State<DiscoverScreen_ResortBanner> {
  UserModelController _userModelController = Get.find<UserModelController>();
  int _currentIndex = 0;
  CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
  }


  //TODO: Dependency Injection**************************************************
  UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();
  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('discover_banner_url')
          .doc('${_userModelController.instantResort}')
          .collection('1')
          .where('visable', isEqualTo: true)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        // 데이터 로드 중이라면
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        // 오류가 발생했다면
        else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        // 데이터가 없다면
        else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(); // 빈 컨테이너 반환
        }
        else if (snapshot.data!.docs.isNotEmpty) {

          final _imageUrls = snapshot.data!.docs;
          return Column(
            children: [
              GestureDetector(
                onTap: () async {

                  String landingUrl =
                  _imageUrls[_currentIndex]['landingUrl'];
                  _urlLauncherController.otherShare(contents: landingUrl);
                  try{
                    FirebaseAnalytics.instance.logEvent(
                      name: 'tap_banner_resortHome',
                      parameters: <String, dynamic>{
                        'user_id': _userModelController.uid,
                        'user_name': _userModelController.displayName,
                        'user_resort': _userModelController.favoriteResort
                      },
                    );
                  }catch(e, stackTrace){
                    print('GA 업데이트 오류: $e');
                    print('Stack trace: $stackTrace');
                  }

                },
                child: Container(
                  width: _size.width,
                  child: CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      enableInfiniteScroll: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 5),
                      viewportFraction: 1.0,
                      aspectRatio: 16 / 4,
                      enlargeCenterPage: true,
                      initialPage: 0,
                      onPageChanged: (index, reason) {
                          _currentIndex = index;
                      },
                    ),
                    items: _imageUrls.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ExtendedImage.network(
                            url['url'],
                            cache: true,
                            fit: BoxFit.scaleDown,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: _imageUrls.map((url) {
              //     int index = _imageUrls.indexOf(url);
              //     return Container(
              //       width: 6,
              //       height: 6,
              //       margin: EdgeInsets.only(top: 12, right: 6),
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: _currentIndex == index
              //             ? Color(0xFF949494)
              //             : Color(0xFFDEDEDE),
              //       ),
              //     );
              //   }).toList(),
              // ),
            ],
          );// 배너 여러개일 경우 캐러셀 타입

        }
        else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
