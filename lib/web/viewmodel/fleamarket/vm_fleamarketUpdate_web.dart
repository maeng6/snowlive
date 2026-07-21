import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_fleamarket.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/web/viewmodel/util/vm_imageController_web.dart';

class FleamarketUpdateViewModelWeb extends GetxController {

  final ImageControllerWeb imageController = Get.put(ImageControllerWeb());
  int? _currentUserId;
  final TextEditingController textEditingController_title = TextEditingController();
  final TextEditingController textEditingController_productName = TextEditingController();
  final TextEditingController textEditingController_sns = TextEditingController();
  final TextEditingController textEditingController_desc = TextEditingController();
  final TextEditingController itemPriceTextEditingController = TextEditingController();

  @override
  void onClose() {
    textEditingController_title.dispose();
    textEditingController_productName.dispose();
    textEditingController_sns.dispose();
    textEditingController_desc.dispose();
    itemPriceTextEditingController.dispose();
    super.onClose();
  }

  RxList<XFile> _newImageFiles = <XFile>[].obs;
  RxList<String> _existingImageUrls = <String>[].obs;
  RxList<String> _imageUrlList = <String>[].obs;
  RxBool _fleaImageSelected = false.obs;
  RxBool _isGettingImageFromGallery = false.obs;
  RxBool _isTitleWritten = true.obs;
  RxBool _isProductNameWritten = true.obs;
  RxBool _isPriceWritten = true.obs;
  RxBool _isDescriptionWritten = true.obs;
  RxBool _negotiable = false.obs;
  RxInt _totalImageCount = 0.obs;
  RxList<Map<String, dynamic>> _photos = <Map<String, dynamic>>[].obs;
  RxString _selectedCategoryMain = '상위 카테고리'.obs;
  RxString _selectedCategorySub = '하위 카테고리'.obs;
  RxString _selectedTradeMethod = '거래방법 선택'.obs;
  RxString _selectedTradeSpot = '거래장소 선택'.obs;
  RxBool _isCategorySelected = true.obs;
  RxBool updateCacheHeight = false.obs;

  List<XFile?> get newImageFiles => _newImageFiles;
  List<String> get existingImageUrls => _existingImageUrls;
  List<String?> get imageUrlList => _imageUrlList;
  List<Map<String, dynamic>?> get photos => _photos;
  bool get fleaImageSelected => _fleaImageSelected.value;
  bool get isGettingImageFromGallery => _isGettingImageFromGallery.value;
  bool get isTitleWritten => _isTitleWritten.value;
  bool get isProductNameWritten => _isProductNameWritten.value;
  bool get isPriceWritten => _isPriceWritten.value;
  bool get isDescriptionWritten => _isDescriptionWritten.value;
  bool get negotiable => _negotiable.value;
  int get totalImageCount => _totalImageCount.value;
  String get selectedCategoryMain => _selectedCategoryMain.value;
  String get selectedCategorySub => _selectedCategorySub.value;
  String get selectedTradeMethod => _selectedTradeMethod.value;
  String get selectedTradeSpot => _selectedTradeSpot.value;
  bool get isCategorySelected => _isCategorySelected.value;

  Future<void> fetchFleamarketUpdateData({
    required String title,
    required String categorySub,
    required String categoryMain,
    required String productName,
    required dynamic price,
    required String tradeMethod,
    required String tradeSpot,
    required String desc,
    required List<Photo>? photos,
  }) async {
    textEditingController_title.text = title;
    _selectedCategorySub.value = categorySub;
    _selectedCategoryMain.value = categoryMain;
    textEditingController_productName.text = productName;
    itemPriceTextEditingController.text = price.toString();
    _selectedTradeMethod.value = tradeMethod;
    _selectedTradeSpot.value = tradeSpot;
    textEditingController_desc.text = desc;

    _existingImageUrls.clear();
    _newImageFiles.clear();

    if (photos != null) {
      final sortedPhotos = List<Photo>.from(photos)
        ..sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));

      for (var photo in sortedPhotos) {
        if (photo.urlFleaPhoto != null) {
          _existingImageUrls.add(photo.urlFleaPhoto!);
        }
      }
    }

    _updateTotalImageCount();
  }

  void _updateTotalImageCount() {
    _totalImageCount.value = _existingImageUrls.length + _newImageFiles.length;
  }

  Future<void> getImageFromGallery() async {
    changeIsGettingImageFromGallery(true);
    var imageList = await imageController.getMultiImage(ImageSource.gallery);
    if (imageList.isNotEmpty) {
      _newImageFiles.value = imageList;
    }
    _updateTotalImageCount();
    if (_totalImageCount.value <= 5) {
      changeFleaImageSelected(true);
    } else {
      _newImageFiles.clear();
      _updateTotalImageCount();
    }
    changeIsGettingImageFromGallery(false);
  }

  void removeExistingImage(int index) {
    _existingImageUrls.removeAt(index);
    _updateTotalImageCount();
  }

  void removeNewImage(int index) {
    _newImageFiles.removeAt(index);
    _updateTotalImageCount();
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

  void toggleNegotiable() {
    _negotiable.value = !_negotiable.value;
  }

  void toggleUpdateCacheHeight() {
    updateCacheHeight.value = !updateCacheHeight.value;
  }

  Future<void> getImageUrlList({required newImages, required pk, required int userId}) async {
    _currentUserId = userId;
    _imageUrlList.value = await imageController.setNewMultiImageFlea(
      newImages: newImages,
      pk: pk,
      onError: (String requestType, String error) {
        _sendFleaErrorLog(requestType: requestType, error: error);
      },
    );

    _photos.value = [];
    for (int i = 0; i < _imageUrlList.length; i++) {
      _photos.add({
        "display_order": i + 1,
        "url_flea_photo": _imageUrlList[i],
      });
    }
  }

  Future<void> _sendFleaErrorLog({
    required String requestType,
    required String error,
  }) async {
    if (_currentUserId == null) return;

    try {
      await FleamarketAPI().createErrorLog_flea({
        "user_id": _currentUserId,
        "request_type": requestType,
        "error": error,
      });
    } catch (e) {
      print('[FleaErrorLog] 로그 전송 실패: $e');
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
      print('스노우마켓 수정 완료');
    }
  }

  Future<void> deletePhotoUrls(body) async {
    ApiResponse response = await FleamarketAPI().deletePhotoUrls(body);
    if (response.success) {
      print('이미지 Url 삭제 완료');
    }
  }
}
