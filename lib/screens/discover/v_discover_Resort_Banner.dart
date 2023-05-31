import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/screens/v_webPage.dart';

import '../../controller/vm_userModelController.dart';

class DiscoverScreen_ResortBanner extends StatefulWidget {
  @override
  _DiscoverScreen_ResortBannerState createState() => _DiscoverScreen_ResortBannerState();
}

class _DiscoverScreen_ResortBannerState extends State<DiscoverScreen_ResortBanner> {
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
    return StreamBuilder<List<String>>(
        stream: getImagesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<String>? imageUrls = snapshot.data;
            return Padding(
              padding: EdgeInsets.only(left: 12, right: 12),
              child:
              (imageUrls!.isNotEmpty)
              ? Column(
                children: [
                  GestureDetector(

                    onTap: () async{
                      final urlSnapshot = await FirebaseFirestore.instance
                          .collection('discover_banner_url')
                          .doc('${_userModelController.favoriteResort}')
                          .collection('1')
                          .where('url', isEqualTo: imageUrls[_currentIndex])
                          .get();
                      if (urlSnapshot.docs.isNotEmpty) {
                        String landingUrl = urlSnapshot.docs.first['landingUrl'];
                        Get.to(() => WebPage(url: landingUrl));
                      }

                    },
                    child: CarouselSlider(
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        height: 107,
                        viewportFraction: 1.0,
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        initialPage: 0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                      items: imageUrls.map((url) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Image.network(
                              url,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: Lottie.asset('assets/json/loadings_wht_final.json'),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error);
                              },
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageUrls.map((url) {
                      int index = imageUrls.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                          _currentIndex == index ? Colors.blue : Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/imgs/icons/icon_nodata.png',
                    scale: 4,
                    width: 73,
                    height: 73,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text('게시물이 없습니다.',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF949494)
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(child: Lottie.asset('assets/json/loadings_wht_final.json'));
          }
        },
      );
  }
}