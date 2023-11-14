import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_fleaMarketController.dart';

class FleaMarketImageScreen extends StatefulWidget {
  FleaMarketImageScreen({Key? key}) : super(key: key);

  @override
  State<FleaMarketImageScreen> createState() => _FleaMarketImageScreenState();
}

class _FleaMarketImageScreenState extends State<FleaMarketImageScreen> {
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
  final PageController _pageController = PageController(viewportFraction: 1);
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
          leading: GestureDetector(
            child: Icon(Icons.close, color: Colors.white),
            onTap: () => Navigator.pop(context),
          ),
          elevation: 0.0,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${_currentPage + 1}/${_fleaModelController.itemImagesUrls!.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _fleaModelController.itemImagesUrls!.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  maxScale: 7,
                  child: AspectRatio(
                    aspectRatio: 9 / 14,
                    child: ExtendedImage.network(
                      _fleaModelController.itemImagesUrls![index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
