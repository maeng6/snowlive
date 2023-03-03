import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_fleaMarketController.dart';
import 'package:snowlive3/screens/fleaMarket/v_fleaMarket_List_Detail.dart';


class FleaMarketImageScreen extends StatefulWidget {
  FleaMarketImageScreen({Key? key}) : super(key: key);


  @override
  State<FleaMarketImageScreen> createState() => _FleaMarketImageScreenState();
}

class _FleaMarketImageScreenState extends State<FleaMarketImageScreen> {


  //TODO: Dependency Injection**************************************************
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
  //TODO: Dependency Injection**************************************************


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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CarouselSlider.builder(
                options: CarouselOptions(
                  aspectRatio: 9/14,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                ),
                itemCount:
                _fleaModelController.itemImagesUrls!.length,
                itemBuilder: (context, index, pageViewIndex) {
                  return Container(
                    child: StreamBuilder<Object>(
                        stream: null,
                        builder: (context, snapshot) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InteractiveViewer(
                                maxScale: 7,
                                child: ExtendedImage.network(
                                  _fleaModelController.itemImagesUrls![index],
                                  fit: BoxFit.cover,
                                  width: _size.width,
                                  height: _size.height,
                                ),
                              ),
                            ],
                          );
                        }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
