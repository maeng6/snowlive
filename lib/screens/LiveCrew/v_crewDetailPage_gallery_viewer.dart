import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/public/vm_imageController.dart';
import 'package:com.snowlive/controller/liveCrew/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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

  bool _showAppBar = true;

  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
      _showAppBar
          ? AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 5),
            child:
            (_liveCrewModelController.leaderUid == _userModelController.uid)
                ?IconButton(
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
              icon: Icon(Icons.delete_forever_sharp, size: 26, color: Colors.white,),
            )
                :SizedBox(),
          )
        ],
        backgroundColor: Colors.black12,
        leading: GestureDetector(
          child: Image.asset(
            'assets/imgs/icons/icon_snowLive_back_white.png',
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
        centerTitle: true,
      )
          :null,
      body: GestureDetector(
        onTap: _toggleAppBar,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: widget.photoList.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: ExtendedNetworkImageProvider(
                        widget.photoList[index],
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
                  initialPage: _currentIndex,
                ),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
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


