import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class LiveTalkImageScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const LiveTalkImageScreen({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<LiveTalkImageScreen> createState() => _LiveTalkImageScreenState();
}

class _LiveTalkImageScreenState extends State<LiveTalkImageScreen> {
  late int _currentPage;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: AppBar(
          backgroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: GestureDetector(
            child: const Icon(Icons.close, color: Colors.white),
            onTap: () => Navigator.pop(context),
          ),
          elevation: 0.0,
          title: null,
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        pageController: _pageController,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: ExtendedNetworkImageProvider(
              widget.imageUrls[index],
              cache: true,
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 7,
            initialScale: PhotoViewComputedScale.contained,
            basePosition: Alignment.center,
          );
        },
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              backgroundColor: SDSColor.gray100.withOpacity(0.2),
              color: SDSColor.gray300.withOpacity(0.6),
            ),
          ),
        ),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
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
