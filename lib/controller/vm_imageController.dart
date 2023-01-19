import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import '../widget/w_fullScreenDialog.dart';

class ImageController extends GetxController {
  var imageSource;
  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  List<String> imagesUrlList = [];

  //TODO : ****************************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO : ****************************************************************

  Future<XFile?> getSingleImage(ImageSource) async {

    final ImagePicker _picker = ImagePicker();
    final XFile? image =
        await _picker.pickImage(imageQuality: 100, source: ImageSource);
    if (image != null) {
      return image;
    }else {
      CustomFullScreenDialog.cancelDialog();
    }
    return image;
  }

  Future<List<XFile>> getMultiImage(ImageSource) async {

    final ImagePicker _picker = ImagePicker();
    final List<XFile> selectedImages =
        await _picker.pickMultiImage(maxWidth: 640, maxHeight: 280, imageQuality: 100);
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

  Future<void> deleteProfileImage() async{
    String? uid = _userModelController.uid;
    await FirebaseStorage.instance.ref().child('images/profile/$uid.jpg').delete();

}

}
