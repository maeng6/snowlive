import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:com.snowlive/screens/comments/v_liveTalk_Screen.dart';
import 'package:com.snowlive/screens/v_webPage.dart';
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('discover_info_url')
            .where('visable', isEqualTo: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData ||
              snapshot.data == null) {
            return Center(child: Lottie.asset('assets/json/loadings_wht_final.json'));
          }
          else if (snapshot.data!.docs.isNotEmpty) {
            final _imageUrls = snapshot.data!.docs;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '이모저모 소식통',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: 180, // adjust this height to fit your needs
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageUrls.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () async {
                          final urlSnapshot = await FirebaseFirestore.instance
                              .collection('discover_info_url')
                              .where('url', isEqualTo: _imageUrls[index]['url'])
                              .get();
                          if (urlSnapshot.docs.isNotEmpty) {
                            String instaUrl = urlSnapshot.docs.first['instaUrl'];
                            Get.to(() => WebPage(url: instaUrl));
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          // space between images
                          child: ExtendedImage.network(
                            _imageUrls[index]['url'],
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
          }
          else if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
                child: Lottie.asset('assets/json/loadings_wht_final.json'));
          }
          return Center(child: Lottie.asset('assets/json/loadings_wht_final.json'));
        }
    );
  }
}
