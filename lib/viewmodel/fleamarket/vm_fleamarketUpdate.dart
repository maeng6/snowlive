import 'dart:io';
import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_fleamarket.dart';
import 'package:com.snowlive/model/m_fleamarket.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/viewmodel/util/vm_imageController.dart';
import 'package:path_provider/path_provider.dart';

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
  RxBool _isGettingImageFromGallery = false.obs;
  RxBool _isTitleWritten = true.obs;
  RxBool _isProductNameWritten = true.obs;
  RxBool _isPriceWritten = true.obs;
  RxBool _isDescriptionWritten = true.obs;
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
  bool get isGettingImageFromGallery => _isGettingImageFromGallery.value;
  bool get isTitleWritten => _isTitleWritten.value;
  bool get isProductNameWritten => _isProductNameWritten.value;
  bool get isPriceWritten => _isPriceWritten.value;
  bool get isDescriptionWritten => _isDescriptionWritten.value;
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
    _imageFiles.clear();
    _imageLength.value = 0;

    if (photos != null) {
      print('이미지 다운로드 시작');

      // 병렬로 이미지를 다운로드하기 위한 Future 리스트 생성 (displayOrder 기억)
      List<Future<Map<String, dynamic>?>> downloadTasks = photos.map((photo) async {
        if (photo.urlFleaPhoto != null) {
          final url = photo.urlFleaPhoto!;
          try {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              final directory = await getTemporaryDirectory();
              final filePath = p.join(directory.path, '${photo.displayOrder ?? 0}.jpg');
              final file = File(filePath);
              await file.writeAsBytes(response.bodyBytes);

              // XFile과 displayOrder를 함께 반환
              return {
                'file': XFile(filePath),
                'displayOrder': photo.displayOrder ?? 0
              };
            }
          } catch (e) {
            // 에러 처리
            print("이미지 다운로드 에러: $e");
          }
        }
        return null;  // null 반환
      }).toList();

      // 병렬로 이미지 다운로드 처리
      List<Map<String, dynamic>?> imageFiles = await Future.wait(downloadTasks);

      // displayOrder 순서대로 정렬
      imageFiles = imageFiles.where((element) => element != null).toList();
      imageFiles.sort((a, b) => (a!['displayOrder'] as int).compareTo(b!['displayOrder'] as int));

      // 최종적으로 _imageFiles에 정렬된 이미지들 할당
      _imageFiles.value = imageFiles.map((e) => e!['file'] as XFile).toList();
      // 이미지 길이 업데이트
      _imageLength.value = _imageFiles.length;

      print('이미지 다운로드 및 정렬 완료');
    }
  }





  Future<void> getImageFromGallery() async {
    changeIsGettingImageFromGallery(true);
    _imageFiles.value = await imageController.getMultiImage(ImageSource.gallery);
    if(_imageFiles.length <= 5){
      changeFleaImageSelected(true);
      setImageLength();
    }else {
      deleteImageFromGallery();
    }
    changeIsGettingImageFromGallery(false);
  }
  void deleteImageFromGallery()  {
    _imageFiles.value =[];
  }


  void changeFleaImageSelected(bool boolean) {
    _fleaImageSelected.value = boolean;
  }

  void changeIsGettingImageFromGallery(bool boolean) {
    _isGettingImageFromGallery.value = boolean;
  }

  void changeTitleWritten(bool boolean) {
    _isTitleWritten.value = boolean;
  }

  void changeProductNameWritten(bool boolean) {
    _isProductNameWritten.value = boolean;
  }

  void changePriceWritten(bool boolean) {
    _isPriceWritten.value = boolean;
  }

  void changeDescriptionWritten(bool boolean) {
    _isDescriptionWritten.value = boolean;
  }

  void setImageLength() {
    _imageLength.value = _imageFiles.length;
  }

  void removeSelectedImage(index) {
    _imageFiles.removeAt(index);
    update();
  }

  void toggleNegotiable() {
    _negotiable.value = !_negotiable.value;
  }

  Future<void> getImageUrlList({required newImages, required pk}) async {
    _imageUrlList.value = await imageController.setNewMultiImageFlea(
        newImages: newImages, pk: pk);

      _photos.value = [];
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

  Future<void> updateFleamarket(fleamarketId, body, photos) async {

      ApiResponse response = await FleamarketAPI().updateFleamarket(fleamarketId, body, photos);
      if (response.success) {
        print('스노우마켓 업로드 완료');
      }
      else {
      }
    }

  Future<void> deletePhotoUrls( body) async {

    ApiResponse response = await FleamarketAPI().deletePhotoUrls(body);
    if (response.success) {
      print('이미지 Url 삭제 완료');
    }
    else {
    }
  }





}
