import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_resortHome.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // url_launcher 패키지 추가

class Banner_resortHome extends StatefulWidget {
  @override
  _Banner_resortHomeState createState() => _Banner_resortHomeState();
}

class _Banner_resortHomeState extends State<Banner_resortHome> {
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  ResortHomeViewModel _resortHomeViewModel = Get.find<ResortHomeViewModel>();
  CarouselSliderController _carouselController = CarouselSliderController();
  ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _resortHomeViewModel.getBanner('home');
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: _resortHomeViewModel.bannerStream_home.value,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // 데이터 로드 중이라면
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }
        // 오류가 발생했다면
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        var data = snapshot.data?.data() as Map<String, dynamic>?;

        if (data != null) {
          List<dynamic> imageUrls = data['imageUrl'] ?? [];
          List<dynamic> landingUrls = data['landingUrl'] ?? [];
          List<dynamic> visibleList = data['visible'] ?? [];

          List<Widget> bannerWidgets = [];

          // 각 필드를 리스트로 순회하면서 배너 표시
          for (int i = 0; i < imageUrls.length; i++) {
            if (visibleList[i] == true) {
              bannerWidgets.add(
                GestureDetector(
                  onTap: () async {
                    String landingUrl = landingUrls[i];
                    if (landingUrl.isNotEmpty) {
                      await otherShare(contents: landingUrl);
                    }

                    try {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'tap_banner_resortHome',
                        parameters: <String, Object>{
                          'user_id': _userViewModel.user.user_id,
                          'user_name': _userViewModel.user.display_name,
                          'user_resort': _userViewModel.user.favorite_resort,
                          'banner_number': i
                        },
                      );
                    } catch (e, stackTrace) {
                      print('GA 업데이트 오류: $e');
                      print('Stack trace: $stackTrace');
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: _size.width,
                      child: ExtendedImage.network(
                        imageUrls[i],
                        cache: true,
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          if (bannerWidgets.isNotEmpty) {
            bool autoPlay = bannerWidgets.length > 1; // 배너가 1개 이상일 때만 롤링

            return Padding(
              padding: bannerWidgets.length > 0
                  ? EdgeInsets.only(bottom: 20)
                  : EdgeInsets.only(bottom: 20),
              child: CarouselSlider(
                items: bannerWidgets,
                carouselController: _carouselController,
                options: CarouselOptions(
                  autoPlay: autoPlay, // 배너가 1개일 때 롤링 비활성화
                  autoPlayInterval: Duration(seconds: 5),
                  aspectRatio: 360 / 86,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: autoPlay, // 배너가 1개일 때 롤링 비활성화
                  scrollPhysics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
                  enlargeCenterPage: false, // 중앙 배너 강조 해제
                  onPageChanged: (index, reason) {
                    _currentIndexNotifier.value = index;
                  },
                ),
              ),
            );
          } else {
            return SizedBox.shrink(); // 표시할 배너가 없을 때
          }
        } else {
          return Center(
            child: Text('No banner data available'),
          );
        }
      },
    );
  }
}
