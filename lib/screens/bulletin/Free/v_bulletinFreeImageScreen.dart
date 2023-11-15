import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarket_List_Detail.dart';
import '../../../controller/vm_bulletinFreeController.dart';

class BulletinFreeImageScreen extends StatefulWidget {
  BulletinFreeImageScreen({Key? key}) : super(key: key);

  @override
  State<BulletinFreeImageScreen> createState() => _BulletinFreeImageScreenState();
}

class _BulletinFreeImageScreenState extends State<BulletinFreeImageScreen> {


  //TODO: Dependency Injection**************************************************
  BulletinFreeModelController _bulletinFreeModelController = Get.find<BulletinFreeModelController>();
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
        body: CarouselSlider.builder(
          options: CarouselOptions(
            aspectRatio: 9/16,
            viewportFraction: 1,
            enableInfiniteScroll: false,
          ),
          itemCount:
          _bulletinFreeModelController.itemImagesUrls!.length,
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
                            _bulletinFreeModelController
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
      ),
    );
  }
}
