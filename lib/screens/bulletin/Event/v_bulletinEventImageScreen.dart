import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:get/get.dart';
import '../../../controller/vm_bulletinEventController.dart';

class BulletinEventImageScreen extends StatefulWidget {
  BulletinEventImageScreen({Key? key}) : super(key: key);

  @override
  State<BulletinEventImageScreen> createState() =>
      _BulletinEventImageScreenState();
}

class _BulletinEventImageScreenState extends State<BulletinEventImageScreen> {

  //TODO: Dependency Injection**************************************************
  BulletinEventModelController _bulletinEventModelController = Get.find<BulletinEventModelController>();
  //TODO: Dependency Injection**************************************************

  int _currentPage = 0;
  String? _itemImagesUrl;

  @override
  void initState() {
    super.initState();
    // 이미지 URL 리스트를 컨트롤러에서 가져와 저장
    _itemImagesUrl = _bulletinEventModelController.itemImagesUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
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
      body: PhotoView(
        imageProvider: _itemImagesUrl!.isNotEmpty
            ? ExtendedNetworkImageProvider(
            _itemImagesUrl!,
            cache: true
        )
            : AssetImage('assets/imgs/profile/img_profile_default_.png') as ImageProvider,
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 7,
      ),
    );
  }
}
