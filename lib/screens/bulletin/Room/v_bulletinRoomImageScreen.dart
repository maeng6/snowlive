import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Detail.dart';

import '../../../controller/vm_bulletinRoomController.dart';


class BulletinRoomImageScreen extends StatefulWidget {
  BulletinRoomImageScreen({Key? key}) : super(key: key);


  @override
  State<BulletinRoomImageScreen> createState() => _BulletinRoomImageScreenState();
}

class _BulletinRoomImageScreenState extends State<BulletinRoomImageScreen> {


  //TODO: Dependency Injection**************************************************
  BulletinRoomModelController _bulletinRoomModelController = Get.find<BulletinRoomModelController>();
  //TODO: Dependency Injection**************************************************

  final PageController _pageController = PageController(viewportFraction: 1);

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return Dismissible(
      background: FleaMarket_List_Detail(),
      direction: DismissDirection.down,
      key: UniqueKey(),
      onDismissed: (_)=>Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(58),
          child: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
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
        body: Container(
          height: _size.height,
          width: _size.width,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bulletinRoomModelController.itemImagesUrls!.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                maxScale: 7,
                child: AspectRatio(
                  aspectRatio: 9 / 14,
                  child: ExtendedImage.network(
                    _bulletinRoomModelController.itemImagesUrls![index],
                    fit: BoxFit.contain,
                    width: _size.width,
                    height: _size.height,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
