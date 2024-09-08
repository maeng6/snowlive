import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/viewmodel/vm_imageController.dart';
import 'package:path_provider/path_provider.dart';
import '../api/ApiResponse.dart';
import '../api/api_fleamarket.dart';
import '../model/m_fleamarket.dart';

class FleamarketUpdateViewModel extends GetxController {

  final ImageController imageController = Get.put(ImageController());
  final TextEditingController textEditingController_title = TextEditingController();
  final TextEditingController textEditingController_productName = TextEditingController();
  final TextEditingController textEditingController_sns = TextEditingController();
  final TextEditingController textEditingController_desc = TextEditingController();
  final TextEditingController itemPriceTextEditingController = TextEditingController();

  RxList<XFile> _imageFiles = <XFile>[].obs;
  RxList<String> _imageUrlList = <String>[].obs;
  RxBool _fleaImageSelected = false.obs;
  RxBool _negotiable = false.obs;
  RxInt _imageLength = 0.obs;
  RxList<Map<String, dynamic>> _photos = <Map<String, dynamic>>[].obs;
  RxString _selectedCategoryMain = '상위 카테고리'.obs;
  RxString _selectedCategorySub = '하위 카테고리'.obs;
  RxString _selectedTradeMethod = '거래방법 선택'.obs;
  RxString _selectedTradeSpot = '거래장소 선택'.obs;
  RxBool _isCategorySelected = true.obs;


  List<XFile?> get imageFiles => _imageFiles;
  List<String?> get imageUrlList => _imageUrlList;
  List<Map<String, dynamic>?> get photos => _photos;
  bool get fleaImageSelected => _fleaImageSelected.value;
  bool get negotiable => _negotiable.value;
  int get imageLength => _imageLength.value;
  String get selectedCategoryMain => _selectedCategoryMain.value;
  String get selectedCategorySub => _selectedCategorySub.value;
  String get selectedTradeMethod => _selectedTradeMethod.value;
  String get selectedTradeSpot => _selectedTradeSpot.value;
  bool get isCategorySelected => _isCategorySelected.value;

  Future<void> fetchFleamarketUpdateData({
    required textEditingController_title,
    required selectedCategorySub,
    required selectedCategoryMain,
    required textEditingController_productName,
    required itemPriceTextEditingController,
    required selectedTradeMethod,
    required selectedTradeSpot,
    required textEditingController_desc,
    required List<Photo>? photos,
  }) async {
    // Update text controllers and selected values
    this.textEditingController_title.text = textEditingController_title;
    this._selectedCategorySub.value = selectedCategorySub;
    this._selectedCategoryMain.value = selectedCategoryMain;
    this.textEditingController_productName.text = textEditingController_productName;
    this.itemPriceTextEditingController.text = itemPriceTextEditingController.toString();
    this._selectedTradeMethod.value = selectedTradeMethod;
    this._selectedTradeSpot.value = selectedTradeSpot;
    this.textEditingController_desc.text = textEditingController_desc;

    // Clear previous images
    this._imageFiles.clear();
    this._imageLength.value = 0;

    if (photos != null) {
      List<XFile> imageFiles = [];
      for (Photo photo in photos) {
        if (photo.urlFleaPhoto != null) {
          final url = photo.urlFleaPhoto!;
          try {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              final directory = await getTemporaryDirectory();
              final filePath = p.join(directory.path, '${photo.displayOrder ?? 0}.jpg');
              final file = File(filePath);
              await file.writeAsBytes(response.bodyBytes);

              // Add to the imageFiles list
              imageFiles.add(XFile(filePath));
            }
          } catch (e) {
            // Handle potential exceptions, such as network errors
            print("Error downloading image: $e");
          }
        }
      }
      this._imageFiles.addAll(imageFiles);
      this._imageLength.value = imageFiles.length;
    }
  }
  Future<void> getImageFromGallery() async {
    _imageFiles.value = await imageController.getMultiImage(ImageSource.gallery);
    if(_imageFiles.length <= 5){
      changeFleaImageSelected(true);
      setImageLength();
    }else {
      deleteImageFromGallery();
    }

  }
  void deleteImageFromGallery()  {
    _imageFiles.value =[];
  }


  void changeFleaImageSelected(bool boolean) {
    _fleaImageSelected.value = boolean;
  }

  void setImageLength() {
    _imageLength.value = _imageFiles.length;
  }

  void removeSelectedImage(index) {
    _imageFiles.removeAt(index);
  }

  void toggleNegotiable() {
    _negotiable.value = !_negotiable.value;
  }

  Future<void> getImageUrlList({required newImages, required user_id}) async {
    _imageUrlList.value = await imageController.setNewMultiImage(
        newImages: newImages, user_id: user_id);

    for (int i = 0; i < _imageUrlList.length; i++) {
      _photos.add({
        "display_order": i + 1,
        "url_flea_photo": _imageUrlList[i],
      });
    }
  }

  void setIsSelectedCategoryFalse() {
    _isCategorySelected.value = false;
  }

  void setIsSelectedCategoryTrue() {
    _isCategorySelected.value = true;
  }

  void resetCategorySub() {
    _selectedCategorySub.value = '하위 카테고리';
  }

  void selectCategoryMain(String selectedcategoryMain) {
    _selectedCategoryMain.value = selectedcategoryMain;
  }
  void selectCategorySub(String selectedcategorySub) {
    _selectedCategorySub.value = selectedcategorySub;
  }
  void selectTradeMethod(String selectTradeMethod) {
    _selectedTradeMethod.value = selectTradeMethod;
  }
  void selectTradeSpot(String selectTradeSpot) {
    _selectedTradeSpot.value = selectTradeSpot;
  }

  Future<void> uploadFleamarket(body, photos) async {

      ApiResponse response = await FleamarketAPI().uploadFleamarket(body,photos);
      if (response.success) {
        print('스노우마켓 업로드 완료');
      }
      else {
      }
    }





}
