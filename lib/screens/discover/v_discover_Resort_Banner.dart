import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/screens/v_webPage.dart';

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

  Stream<List<String>> getImagesStream() async* {
    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;
    String prefixPath =
        'images/banner_resort_notice/${_userModelController.favoriteResort}';

    while (true) {
      firebase_storage.ListResult result =
          await storage.ref().child(prefixPath).listAll();

      List<String> urls = [];
      for (firebase_storage.Reference ref in result.items) {
        String downloadUrl = await ref.getDownloadURL();
        urls.add(downloadUrl);
      }

      yield urls;
    }
  }

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
              child: Lottie.asset('assets/json/loadings_wht_final.json'));
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
          return (_imageUrls.isNotEmpty)
              ? GestureDetector(
            onTap: () async {
              final urlSnapshot = await FirebaseFirestore.instance
                  .collection('discover_banner_url')
                  .doc('${_userModelController.favoriteResort}')
                  .collection('1')
                  .where('url', isEqualTo: _imageUrls[_currentIndex]['url'])
                  .get();
              if (urlSnapshot.docs.isNotEmpty) {
                String landingUrl =
                urlSnapshot.docs.first['landingUrl'];
                Get.to(() => WebPage(url: landingUrl));
              }
            },
            child: Container(
              width: _size.width,
              child: ExtendedImage.network(
                _imageUrls[0]['url'], // 첫 번째 이미지만 보여줌
                cache: true,
                fit: BoxFit.scaleDown,
              ),
            ),
          )



      // final _imageUrls = snapshot.data!.docs;
      // return (_imageUrls.isNotEmpty)
      //     ? Column(
      //   children: [
      //     GestureDetector(
      //       onTap: () async {
      //         final urlSnapshot = await FirebaseFirestore.instance
      //             .collection('discover_banner_url')
      //             .doc('${_userModelController.favoriteResort}')
      //             .collection('1')
      //             .where('url', isEqualTo: _imageUrls[_currentIndex]['url'])
      //             .get();
      //         if (urlSnapshot.docs.isNotEmpty) {
      //           String landingUrl =
      //           urlSnapshot.docs.first['landingUrl'];
      //           Get.to(() => WebPage(url: landingUrl));
      //         }
      //       },
      //       child: Container(
      //         width: _size.width,
      //         child: CarouselSlider(
      //           carouselController: _carouselController,
      //           options: CarouselOptions(
      //             viewportFraction: 1.0,
      //             aspectRatio: 16 / 4,
      //             enlargeCenterPage: true,
      //             initialPage: 0,
      //             onPageChanged: (index, reason) {
      //               setState(() {
      //                 _currentIndex = index;
      //               });
      //             },
      //           ),
      //           items: _imageUrls.map((url) {
      //             return Builder(
      //               builder: (BuildContext context) {
      //                 return ExtendedImage.network(
      //                   url['url'],
      //                   cache: true,
      //                   fit: BoxFit.scaleDown,
      //                 );
      //               },
      //             );
      //           }).toList(),
      //         ),
      //       ),
      //     ),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: _imageUrls.map((url) {
      //         int index = _imageUrls.indexOf(url);
      //         return Container(
      //           width: 6,
      //           height: 6,
      //           margin: EdgeInsets.only(top: 12, right: 6),
      //           decoration: BoxDecoration(
      //             shape: BoxShape.circle,
      //             color: _currentIndex == index
      //                 ? Color(0xFF949494)
      //                 : Color(0xFFDEDEDE),
      //           ),
      //         );
      //       }).toList(),
      //     ),
      //   ],
      // ) // 배너 여러개일 경우 캐러셀 타입


          : Container();
    }
    else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return Center(
          child: Lottie.asset('assets/json/loadings_wht_final.json'));
    }
      },
    );
  }
}
