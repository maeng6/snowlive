import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_imageController.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class PhotoViewerPage extends StatefulWidget {
  final List<dynamic> photoList;
  final int initialIndex;

  const PhotoViewerPage({required this.photoList, required this.initialIndex});

  @override
  _PhotoViewerPageState createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  ImageController _imageController = Get.find<ImageController>();
  //TODO: Dependency Injection**************************************************

  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: (){
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        color: Colors.white,
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                '이미지를 삭제하시겠습니까?',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111111)),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        '취소',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                      style: TextButton.styleFrom(
                                          splashFactory: InkRipple
                                              .splashFactory,
                                          elevation: 0,
                                          minimumSize:
                                          Size(100, 56),
                                          backgroundColor:
                                          Color(0xff555555),
                                          padding:
                                          EdgeInsets.symmetric(
                                              horizontal: 0)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        CustomFullScreenDialog.showDialog();
                                       await _imageController.deleteCrewGalleryImage(
                                            widget.photoList[_currentIndex], _liveCrewModelController.crewID!);
                                       CustomFullScreenDialog.cancelDialog();
                                       Navigator.pop(context);
                                       Navigator.pop(context);
                                      },
                                      child: Text(
                                        '확인',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                      style: TextButton.styleFrom(
                                          splashFactory: InkRipple
                                              .splashFactory,
                                          elevation: 0,
                                          minimumSize:
                                          Size(100, 56),
                                          backgroundColor:
                                          Color(0xff2C97FB),
                                          padding:
                                          EdgeInsets.symmetric(
                                              horizontal: 0)),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: Icon(Icons.delete),
            ),
          )
        ],
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back.png',
            scale: 4,
            width: 26,
            height: 26,
          ),
          onTap: () async{
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
        titleSpacing: 0,

      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.photoList.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return ExtendedImage.network(
                    widget.photoList[index],
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: (state) {
                      return GestureConfig(
                        minScale: 0.9,
                        animationMinScale: 0.7,
                        maxScale: 3.0,
                        animationMaxScale: 3.5,
                        speed: 1.0,
                        inertialSpeed: 100.0,
                        initialScale: 1.0,
                        inPageView: true,
                      );
                    },
                  );
                },
              ),
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: Visibility(
                  visible: _userModelController.uid == _liveCrewModelController.crewID,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    color: Colors.black54,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            _imageController.deleteCrewGalleryImage(widget.photoList[_currentIndex], _liveCrewModelController.crewID!);
                          },
                          child: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


