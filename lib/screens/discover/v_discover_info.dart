import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/screens/comments/v_liveTalk_Screen.dart';
import 'package:snowlive3/screens/v_webPage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../controller/vm_userModelController.dart';

class DiscoverScreen_Info extends StatefulWidget {
  @override
  _DiscoverScreen_InfoState createState() => _DiscoverScreen_InfoState();
}

class _DiscoverScreen_InfoState extends State<DiscoverScreen_Info> {
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
        'images/discover_info';

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '이모저모 소식통',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 14),
              Container(
                height: 180, // maintain a 16:9 aspect ratio
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        final urlSnapshot = await FirebaseFirestore.instance
                            .collection('discover_info_url')
                            .where('url', isEqualTo: imageUrls[index])
                            .get();
                        if (urlSnapshot.docs.isNotEmpty) {
                          String instaUrl = urlSnapshot.docs
                              .first['instaUrl'];
                          Get.to(() => WebPage(url: instaUrl));
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        // space between images
                        child: ExtendedImage.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          cache: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Center(
              child: Lottie.asset('assets/json/loadings_wht_final.json'));
        }
      },
    );
  }
}