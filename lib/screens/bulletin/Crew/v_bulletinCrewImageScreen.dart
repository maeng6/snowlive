import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_fleaMarketController.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarket_List_Detail.dart';

import '../../../controller/vm_bulletinCrewController.dart';
import '../../../controller/vm_bulletinRoomController.dart';


class BulletinCrewImageScreen extends StatefulWidget {
  BulletinCrewImageScreen({Key? key}) : super(key: key);


  @override
  State<BulletinCrewImageScreen> createState() => _BulletinCrewImageScreenState();
}

class _BulletinCrewImageScreenState extends State<BulletinCrewImageScreen> {


  //TODO: Dependency Injection**************************************************
  BulletinCrewModelController _bulletinCrewModelController = Get.find<BulletinCrewModelController>();
  //TODO: Dependency Injection**************************************************

  int _currentPage = 0;


  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Text(
            '${_currentPage + 1} / ${_bulletinCrewModelController.itemImagesUrls!.length}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          leading: GestureDetector(
            child: Icon(Icons.close,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0.0,
        ),
      ),
      body: CarouselSlider.builder(
        options: CarouselOptions(
          aspectRatio: 9/16,
          viewportFraction: 1,
          enableInfiniteScroll: false,
          onPageChanged: (index, reason) {
            setState(() {
              _currentPage = index;
            });
          },
        ),
        itemCount:
        _bulletinCrewModelController.itemImagesUrls!.length,
        itemBuilder: (context, index, pageViewIndex) {
          return Container(
            child: StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InteractiveViewer(
                        maxScale: 7,
                        child: ExtendedImage.network(
                          _bulletinCrewModelController
                              .itemImagesUrls![index],
                          fit: BoxFit.cover,
                          width: _size.width,
                        ),
                      ),
                    ],
                  );
                }),
          );
        },
      ),
    );
  }
}
