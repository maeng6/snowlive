import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_streamController_banner.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class Banner_resortHome extends StatefulWidget {
  @override
  _Banner_resortHomeState createState() =>
      _Banner_resortHomeState();
}

class _Banner_resortHomeState
    extends State<Banner_resortHome> {
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  CarouselController _carouselController = CarouselController();
  ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
  }
  StreamController_Banner _streamController_Banner = Get.find<StreamController_Banner>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: _streamController_Banner.bannerStream_resortHome.value,
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
                  otherShare(contents: landingUrl);
                  try {
                    FirebaseAnalytics.instance.logEvent(
                      name: 'tap_banner_resortHome',
                      parameters: <String, Object>{
                        'user_id': _userViewModel.user.user_id!,
                        'user_name': _userViewModel.user.display_name!,
                        'user_resort': _userViewModel.user.favorite_resort,
                        'banner_number': _currentIndexNotifier.value
                      },
                    );
                  } catch (e, stackTrace) {
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
