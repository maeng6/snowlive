import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart' as quill;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';


class ImageController extends GetxController {
  var imageSource;
  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  List<String> imagesUrlList = [];


  Future<List<String>> setNewMultiImageFlea(
      {required List<XFile> newImages, required pk}) async {
    DateTime dateTime = DateTime.now();
    int i =0;
    var downloadUrlsingle;
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    List<String> downloadUrlList = [];
    while(i<newImages.length) {
      Reference ref = FirebaseStorage.instance.ref('fleamarket/#$pk/$i.jpg');
      await ref.putFile(File(newImages[i].path), metaData);
      downloadUrlsingle = await ref.getDownloadURL();
      downloadUrlList.add(downloadUrlsingle);
      i++;
    }
    return downloadUrlList;
  }

  Future<String> setNewImage_Crew({required XFile newImage,required crewID}) async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    String downloadUrl = '';
    if (newImage != null) {
      Reference ref = FirebaseStorage.instance.ref('crewLogo/$crewID.jpg');
      await ref.putFile(File(newImage.path), metaData);
      downloadUrl = await ref.getDownloadURL();
    } else {
      CustomFullScreenDialog.cancelDialog();
    }
    return downloadUrl;
  }


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
      }
    }
    return null;
  }


  Future<List<XFile>> getMultiImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    List<XFile> resizedImages = [];
    List<XFile> selectedImages = await _picker.pickMultiImage(imageQuality: 70);

    if(selectedImages.length <= 5) {
      if (selectedImages == null || selectedImages.isEmpty) {
        CustomFullScreenDialog.cancelDialog();
        return [];
      }
      for (XFile image in selectedImages) {
        File file = File(image.path);
        img.Image? originalImage = img.decodeImage(file.readAsBytesSync());

        if (originalImage != null) {
          Uint8List? compressedBytes;
          int quality = 100;

          do {
            img.Image resizedImage = img.copyResize(
                originalImage, width: originalImage.width ~/ 2);
            compressedBytes = img.encodeJpg(resizedImage, quality: quality);

            // Create a temporary file to check size
            Directory tempDir = await getTemporaryDirectory();
            File tempFile = File(p.join(tempDir.path, 'temp_${DateTime
                .now()
                .millisecondsSinceEpoch}.jpg'));
            await tempFile.writeAsBytes(compressedBytes);

            // Check file size
            int fileSizeMb = (await tempFile.length()) ~/ (1024 * 1024);

            if (fileSizeMb <= 1) {
              resizedImages.add(XFile(tempFile.path));
              break;
            } else {
              tempFile.deleteSync();
            }

            // Decrease quality to reduce file size
            quality -= 10;
          } while (quality > 0);
        }
      }
      return resizedImages;
    } else {
      resizedImages =[];
      Get.dialog(
        AlertDialog(
          title: Text('사진 개수 초과'),
        ),
      );
      return resizedImages;
    }
  }

  Future<String> setNewImage(XFile newImage) async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      print('Error: User ID is null');
      return '';
    }
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    String downloadUrl = '';
    try {
      Reference ref = FirebaseStorage.instance.ref('user_profile/$uid.jpg');
      await ref.putFile(File(newImage.path), metaData);
      downloadUrl = await ref.getDownloadURL();
      print('Download URL: $downloadUrl'); // 디버깅 메시지 추가
    } catch (e) {
      print('Error uploading image: $e'); // 에러 메시지 출력
    }
    return downloadUrl;
  }


  // Future<void> deleteProfileImage() async{
  //   String? uid = _userModelController.uid;
  //   await FirebaseStorage.instance.ref().child('images/profile/$uid.jpg').delete();
  // }

  //
  // Future<void> deleteCrewGalleryImage(String imageUrl, String crewID) async {
  //   final docRef = FirebaseFirestore.instance.collection('liveCrew').doc(crewID);
  //
  //   // Fetch the document from Firestore
  //   DocumentSnapshot docSnapshot = await docRef.get();
  //
  //   // Get the galleryUrlList from the document
  //   List<String> galleryUrlList = List<String>.from(docSnapshot['galleryUrlList']);
  //
  //   // Remove the image URL from the list
  //   galleryUrlList.remove(imageUrl);
  //
  //   // Update the document with the modified list
  //   await docRef.update({'galleryUrlList': galleryUrlList});
  //
  //   // Delete the image from Firebase Storage
  //   await FirebaseStorage.instance.refFromURL(imageUrl).delete();
  // }
  //
  // Future<void> deleteAllCrewGalleryImages(String crewID) async {
  //   final docRef = FirebaseFirestore.instance.collection('liveCrew').doc(crewID);
  //
  //   // Fetch the document from Firestore
  //   DocumentSnapshot docSnapshot = await docRef.get();
  //
  //   // Get the galleryUrlList from the document
  //   List<String> galleryUrlList = List<String>.from(docSnapshot['galleryUrlList']);
  //
  //   // Delete each image from Firebase Storage and remove from the list
  //   for (final imageUrl in galleryUrlList) {
  //     await deleteCrewGalleryImage(imageUrl, crewID);
  //   }
  // }

  Future<void> uploadDeltaImages(List<quill.Operation> ops, int bulletinFreeCount) async {
    for (var op in ops) {
      if (op.key == 'insert' && op.value is Map && op.value.containsKey('image')) {
        String localPath = op.value['image'];
        String downloadUrl = await _uploadImage(localPath, bulletinFreeCount);
        op.value['image'] = downloadUrl;
      }
    }
  }

  Future<String> _uploadImage(String localPath, int bulletinFreeCount) async {
    String? uid = await FlutterSecureStorage().read(key: 'uid');
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    String downloadUrl = '';

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref('images/bulletinFree/$uid#$bulletinFreeCount/$fileName');
      await ref.putFile(File(localPath), metaData);
      downloadUrl = await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
    }
    return downloadUrl;
  }



}

