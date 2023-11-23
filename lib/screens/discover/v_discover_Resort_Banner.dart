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
  CarouselController _carouselController = CarouselController();
  ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

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
            child: SizedBox.shrink(),
          );
        }
        // 오류가 발생했다면
        else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        // 데이터가 없다면
        else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox.shrink();// 빈 컨테이너 반환
        }
        else if (snapshot.data!.docs.isNotEmpty) {

          final _imageUrls = snapshot.data!.docs;
          return Column(
            children: [
              GestureDetector(
                onTap: () async {

                  String landingUrl =
                  _imageUrls[_currentIndexNotifier.value]['landingUrl'];
                  _urlLauncherController.otherShare(contents: landingUrl);
                  try{
                    FirebaseAnalytics.instance.logEvent(
                      name: 'tap_banner_resortHome',
                      parameters: <String, dynamic>{
                        'user_id': _userModelController.uid,
                        'user_name': _userModelController.displayName,
                        'user_resort': _userModelController.favoriteResort,
                        'banner_number': _currentIndexNotifier.value
                      },
                    );
                  }catch(e, stackTrace){
                    print('GA 업데이트 오류: $e');
                    print('Stack trace: $stackTrace');
                  }

                },
                child: Container(
                  width: _size.width,
                  child: CarouselSlider.builder(
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
                        _currentIndexNotifier.value = index;
                      },
                    ),
                    itemCount: _imageUrls.length,
                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                      var url = _imageUrls[itemIndex];
                      return ExtendedImage.network(
                        url['url'],
                        cache: true,
                        fit: BoxFit.scaleDown,
                      );
                    },
                  ),
                ),
              ),
            ],
          );// 배너 여러개일 경우 캐러셀 타입

        }
        else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Center(
            child: SizedBox.shrink(),
          );
        }
      },
    );
  }
}
