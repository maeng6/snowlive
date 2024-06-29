import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/fleaMarket/vm_fleaMarketController.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FleaMarketImageScreen extends StatefulWidget {
  FleaMarketImageScreen({Key? key}) : super(key: key);

  @override
  State<FleaMarketImageScreen> createState() => _FleaMarketImageScreenState();
}

class _FleaMarketImageScreenState extends State<FleaMarketImageScreen> {
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
  final PageController _pageController = PageController(viewportFraction: 1);
  int _currentPage = 0;
  List<String> _itemImagesUrls = [];

  @override
  void initState() {
    super.initState();
    // 이미지 URL 리스트를 컨트롤러에서 가져와 저장
    _itemImagesUrls = _fleaModelController.itemImagesUrls?.cast<String>() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: GestureDetector(
            child: Icon(Icons.close, color: Colors.white),
            onTap: () => Navigator.pop(context),
          ),
          elevation: 0.0,
          title: Text(
            '${_currentPage + 1} / ${_fleaModelController.itemImagesUrls!.length}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
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
