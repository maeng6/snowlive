import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:extended_image/extended_image.dart';
import 'package:snowlive3/controller/vm_imageController.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_gallery_viewer.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

import '../comments/v_profileImageScreen.dart';

class CrewDetailPage_Gallery extends StatefulWidget {
  @override
  _CrewDetailPage_GalleryState createState() => _CrewDetailPage_GalleryState();
}

class _CrewDetailPage_GalleryState extends State<CrewDetailPage_Gallery> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO: Dependency Injection**************************************************

  XFile? _imageFile;
  final picker = ImagePicker();


  @override
  Widget build(BuildContext context) {

    ImageController _imageController =  Get.put(ImageController(), permanent: true);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('liveCrew')
              .where('crewID', isEqualTo: _liveCrewModelController.crewID)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('이미지 로드 실패');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            final galleryDoc = snapshot.data!.docs[0]['galleryUrlList'];
          return GridView.builder(
            itemCount: galleryDoc.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1, // Horizontal gap
              mainAxisSpacing: 1, // Vertical gap
            ),
            itemBuilder: (BuildContext context, int index) {
              String imageUrl = galleryDoc.reversed.toList()[index];
              return GestureDetector(
                onTap: (){
                  Get.to(() => PhotoViewerPage(
                      photoList: galleryDoc.reversed.toList(),
                      initialIndex: index
                  ));
                },
                child: ExtendedImage.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  cache: true,
                  loadStateChanged: (ExtendedImageState state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        return Center(child: CircularProgressIndicator());
                      case LoadState.completed:
                        return null;
                      case LoadState.failed:
                        return Icon(Icons.error);
                      default:
                        return null;
                    }
                  },
                ),
              );
            },
          );
        }
      ),
      floatingActionButton:
      (_liveCrewModelController.leaderUid == _userModelController.uid)
      ?FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) =>
                Container(
                  height: 162,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              '업로드 방법을 선택해주세요.',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111111)),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  CustomFullScreenDialog.showDialog();
                                  try {
                                    _imageFile = await _imageController.getSingleImage(ImageSource.camera);
                                    await _imageController.setNewImage_Crew_Gallery(newImage: _imageFile!, crewID: _liveCrewModelController.crewID!);
                                    CustomFullScreenDialog.cancelDialog();
                                    setState(() {});
                                  } catch (e) {
                                    CustomFullScreenDialog.cancelDialog();
                                  }
                                },
                                child: Text(
                                  '사진 촬영',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: TextButton.styleFrom(
                                    splashFactory:
                                    InkRipple.splashFactory,
                                    elevation: 0,
                                    minimumSize: Size(100, 56),
                                    backgroundColor:
                                    Color(0xff555555),
                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  CustomFullScreenDialog.showDialog();
                                  try {
                                    _imageFile = await _imageController.getSingleImage(ImageSource.gallery);
                                    await _imageController.setNewImage_Crew_Gallery(newImage: _imageFile!, crewID: _liveCrewModelController.crewID!);
                                    CustomFullScreenDialog.cancelDialog();
                                    setState(() {});
                                  } catch (e) {
                                    CustomFullScreenDialog.cancelDialog();
                                  }
                                },
                                child: Text(
                                  '앨범에서 선택',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: TextButton.styleFrom(
                                    splashFactory:
                                    InkRipple.splashFactory,
                                    elevation: 0,
                                    minimumSize: Size(100, 56),
                                    backgroundColor:
                                    Color(0xff2C97FB),
                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
          );
        },
        child: Icon(Icons.camera_alt_rounded),
      )
      :SizedBox(),
    );
  }
}
