import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FleaMarketImageScreen extends StatefulWidget {
  final List<String> itemImagesUrls;  // 이미지 URL 리스트를 받을 변수
  final int initialIndex;  // 처음 보여줄 이미지의 인덱스

  FleaMarketImageScreen({Key? key, required this.itemImagesUrls, required this.initialIndex}) : super(key: key);

  @override
  State<FleaMarketImageScreen> createState() => _FleaMarketImageScreenState();
}

class _FleaMarketImageScreenState extends State<FleaMarketImageScreen> {
  late int _currentPage;
  late List<String> _itemImagesUrls;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;  // 처음 인덱스를 받아서 설정
    _itemImagesUrls = widget.itemImagesUrls;  // 이미지 리스트를 받아서 설정
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
            '${_currentPage + 1} / ${_itemImagesUrls.length}',
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
