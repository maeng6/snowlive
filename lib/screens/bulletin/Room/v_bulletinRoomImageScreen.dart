import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:get/get.dart';

import '../../../controller/vm_bulletinRoomController.dart';


class BulletinRoomImageScreen extends StatefulWidget {
  BulletinRoomImageScreen({Key? key}) : super(key: key);

  @override
  State<BulletinRoomImageScreen> createState() =>
      _BulletinRoomImageScreenState();
}

class _BulletinRoomImageScreenState extends State<BulletinRoomImageScreen> {

  //TODO: Dependency Injection**************************************************
  BulletinRoomModelController _bulletinRoomModelController = Get.find<BulletinRoomModelController>();
  //TODO: Dependency Injection**************************************************

  int _currentPage = 0;
  List<String> _itemImagesUrls = [];

  @override
  void initState() {
    super.initState();
    // 이미지 URL 리스트를 컨트롤러에서 가져와 저장
    _itemImagesUrls = _bulletinRoomModelController.itemImagesUrls?.cast<String>() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Text(
            '${_currentPage + 1} / ${_itemImagesUrls.length}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          leading: GestureDetector(
            child: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0.0,
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: _itemImagesUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: ExtendedNetworkImageProvider(
                _itemImagesUrls[index],
                cache: true
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 7,
          );
        },
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(
          initialPage: _currentPage,
        ),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
      ),
    );
  }
}
