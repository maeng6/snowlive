import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:get/get.dart';

import '../../../controller/vm_bulletinFreeController.dart';

class BulletinFreeImageScreen extends StatefulWidget {
  BulletinFreeImageScreen({Key? key}) : super(key: key);

  @override
  State<BulletinFreeImageScreen> createState() =>
      _BulletinFreeImageScreenState();
}

class _BulletinFreeImageScreenState extends State<BulletinFreeImageScreen> {

  //TODO: Dependency Injection**************************************************
  BulletinFreeModelController _bulletinFreeModelController = Get.find<BulletinFreeModelController>();
  //TODO: Dependency Injection**************************************************

  int _currentPage = 0;
  List<String> _itemImagesUrls = [];

  @override
  void initState() {
    super.initState();
    // 이미지 URL 리스트를 컨트롤러에서 가져와 저장
    _itemImagesUrls = _bulletinFreeModelController.itemImagesUrls?.cast<String>() ?? [];
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
