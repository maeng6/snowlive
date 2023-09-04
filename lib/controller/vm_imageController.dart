import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snowlive3/controller/vm_liveCrewModelController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import '../widget/w_fullScreenDialog.dart';

class ImageController extends GetxController {
  var imageSource;
  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  List<String> imagesUrlList = [];

  //TODO : ****************************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  //TODO : ****************************************************************

  Future<XFile?> getSingleImage(ImageSource) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(imageQuality: 70, source: ImageSource);
    if (image != null) {
      return image;
    }else {
      return null;
    }
  }

  Future<XFile?> cropImage(XFile? imageFile) async {
    if (imageFile != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
        AndroidUiSettings(
            lockAspectRatio: false
        ),
        IOSUiSettings(

        ),]
      );

      if (croppedFile != null) {
        return XFile(croppedFile.path);
      } else {
        CustomFullScreenDialog.cancelDialog();
      }
    }
    return null;
  }



  Future<List<XFile>> getMultiImage(ImageSource) async {
    List<XFile> selectedImages = [];
    final ImagePicker _picker = ImagePicker();
    selectedImages =
        await _picker.pickMultiImage(imageQuality: 70);
    if (selectedImages != null) {
      return selectedImages;
    }else {
      CustomFullScreenDialog.cancelDialog();
    }
    return selectedImages;

  }

  Future<String> setNewImage(XFile newImage) async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    String downloadUrl = '';
    if (newImage != null) {
      Reference ref = FirebaseStorage.instance.ref('images/profile/$uid.jpg');
      await ref.putFile(File(newImage.path), metaData);
      downloadUrl = await ref.getDownloadURL();
    } else {
      CustomFullScreenDialog.cancelDialog();
    }
    return downloadUrl;
  }

  Future<String> setNewImage_Crew({required XFile newImage,required crewID}) async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    String downloadUrl = '';
    if (newImage != null) {
      Reference ref = FirebaseStorage.instance.ref('images/crewLogo/$crewID.jpg');
      await ref.putFile(File(newImage.path), metaData);
      downloadUrl = await ref.getDownloadURL();
    } else {
      CustomFullScreenDialog.cancelDialog();
    }
    return downloadUrl;
  }

  Future<List<String>> setNewMultiImage(List<XFile> newImages,fleaCount) async {
    int i =0;
    var downloadUrlsingle;
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    List<String> downloadUrl = [];
    if (newImages != null) {

      while(i<newImages.length) {
        Reference ref = FirebaseStorage.instance.ref('images/fleamarket/$uid#$fleaCount/#$i.jpg');
        await ref.putFile(File(newImages[i].path), metaData);
        downloadUrlsingle = await ref.getDownloadURL();
        downloadUrl.add(downloadUrlsingle);
        i++;
      }
    } else {
      CustomFullScreenDialog.cancelDialog();
    }
    imagesUrlList.addAll(downloadUrl);
    return downloadUrl;
  }

  Future<List<String>> setNewMultiImage_bulletinRoom(List<XFile> newImages,bulletinRoomCount) async {
    int i =0;
    var downloadUrlsingle;
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    List<String> downloadUrl = [];
    if (newImages != null) {

      while(i<newImages.length) {
        Reference ref = FirebaseStorage.instance.ref('images/bulletinRoom/$uid#$bulletinRoomCount/#$i.jpg');
        await ref.putFile(File(newImages[i].path), metaData);
        downloadUrlsingle = await ref.getDownloadURL();
        downloadUrl.add(downloadUrlsingle);
        i++;
      }
    } else {
      CustomFullScreenDialog.cancelDialog();
    }
    imagesUrlList.addAll(downloadUrl);
    return downloadUrl;
  }

  Future<List<String>> setNewMultiImage_bulletinCrew(List<XFile> newImages,bulletinCrewCount) async {
    int i =0;
    var downloadUrlsingle;
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    List<String> downloadUrl = [];
    if (newImages != null) {

      while(i<newImages.length) {
        Reference ref = FirebaseStorage.instance.ref('images/bulletinCrew/$uid#$bulletinCrewCount/#$i.jpg');
        await ref.putFile(File(newImages[i].path), metaData);
        downloadUrlsingle = await ref.getDownloadURL();
        downloadUrl.add(downloadUrlsingle);
        i++;
      }
    } else {
      CustomFullScreenDialog.cancelDialog();
    }
    imagesUrlList.addAll(downloadUrl);
    return downloadUrl;
  }

  Future<void> deleteProfileImage() async{
    String? uid = _userModelController.uid;
    await FirebaseStorage.instance.ref().child('images/profile/$uid.jpg').delete();
}

  Future<void> deleteLiveTalkImage({required String uid,required int count}) async {

    await FirebaseStorage.instance.ref().child('images/livetalk/$uid#$count.jpg').delete();
  }

  Future<String> setNewImage_livetalk(XFile newImage, commentCount) async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    String downloadUrl = '';
    if (newImage != null) {
      Reference ref = FirebaseStorage.instance.ref('images/livetalk/$uid#$commentCount.jpg');
      await ref.putFile(File(newImage.path), metaData);
      downloadUrl = await ref.getDownloadURL();
      print("이미지 업로드 완료: $downloadUrl"); // 로그 추가
    } else {
      CustomFullScreenDialog.cancelDialog();
    }
    return downloadUrl;
  }

  Future<String> setNewImage_Crew_Gallery({required XFile newImage, required String crewID}) async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    String downloadUrl = '';

    if (newImage != null) {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = '$crewID\_$timestamp.jpg';

      try {
        // 폴더 존재 여부 확인
        ListResult listResult = await FirebaseStorage.instance.ref('images/crewGallery/$crewID/').listAll();
        bool folderExists = listResult.items.isNotEmpty;

        if (!folderExists) {
          // 폴더가 존재하지 않으면 생성
          await FirebaseStorage.instance.ref('images/crewGallery/$crewID/').putData(Uint8List.fromList([]));
        }

        // 이미지 업로드
        Reference ref = FirebaseStorage.instance.ref('images/crewGallery/$crewID/$fileName');
        await ref.putFile(File(newImage.path), metaData);

        // 다운로드 URL 가져오기
        downloadUrl = await ref.getDownloadURL();

        // Firestore에 URL 추가
        FirebaseFirestore.instance
            .collection('liveCrew')
            .doc(_liveCrewModelController.crewID)
            .set({
          'galleryUrlList': FieldValue.arrayUnion([downloadUrl]),
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error creating folder or uploading image: $e');
      }
    } else {
      CustomFullScreenDialog.cancelDialog();
    }

    return downloadUrl;
  }

  Future<List<String>> setNewMultiImages_Crew_Gallery({required List<XFile> newImages, required String crewID}) async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    List<String> downloadUrls = [];

    try {
      for (final newImage in newImages) {
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String fileName = '$crewID\_$timestamp.jpg';

        // 폴더 존재 여부 확인
        ListResult listResult = await FirebaseStorage.instance.ref('images/crewGallery/$crewID/').listAll();
        bool folderExists = listResult.items.isNotEmpty;

        if (!folderExists) {
          // 폴더가 존재하지 않으면 생성
          await FirebaseStorage.instance.ref('images/crewGallery/$crewID/').putData(Uint8List.fromList([]));
        }

        // 이미지 업로드
        Reference ref = FirebaseStorage.instance.ref('images/crewGallery/$crewID/$fileName');
        await ref.putFile(File(newImage.path), metaData);

        // 다운로드 URL 가져오기
        String downloadUrl = await ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      // Firestore에 URL 추가
      final docRef = FirebaseFirestore.instance.collection('liveCrew').doc(_liveCrewModelController.crewID);
      await docRef.set({
        'galleryUrlList': FieldValue.arrayUnion(downloadUrls),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating folder or uploading images: $e');
    }

    return downloadUrls;
  }



  Future<void> deleteCrewGalleryImage(String imageUrl, String crewID) async {
    final docRef = FirebaseFirestore.instance.collection('liveCrew').doc(crewID);

    // Fetch the document from Firestore
    DocumentSnapshot docSnapshot = await docRef.get();

    // Get the galleryUrlList from the document
    List<String> galleryUrlList = List<String>.from(docSnapshot['galleryUrlList']);

    // Remove the image URL from the list
    galleryUrlList.remove(imageUrl);

    // Update the document with the modified list
    await docRef.update({'galleryUrlList': galleryUrlList});

    // Delete the image from Firebase Storage
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();
  }

  Future<void> deleteAllCrewGalleryImages(String crewID) async {
    final docRef = FirebaseFirestore.instance.collection('liveCrew').doc(crewID);

    // Fetch the document from Firestore
    DocumentSnapshot docSnapshot = await docRef.get();

    // Get the galleryUrlList from the document
    List<String> galleryUrlList = List<String>.from(docSnapshot['galleryUrlList']);

    // Delete each image from Firebase Storage and remove from the list
    for (final imageUrl in galleryUrlList) {
      await deleteCrewGalleryImage(imageUrl, crewID);
    }
  }


}

