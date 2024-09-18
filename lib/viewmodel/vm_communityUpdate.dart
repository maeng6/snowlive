import 'dart:convert';
import 'dart:io' as io;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart' as quill;
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:com.snowlive/viewmodel/vm_imageController.dart';
import 'package:path/path.dart' as path;

import '../api/api_community.dart';

class CommunityUpdateViewModel extends GetxController {

  final ImageController imageController = Get.put(ImageController());
  final TextEditingController textEditingController_title = TextEditingController();
  var isLoading = true.obs;

  quill.Document? description;
  Rx<quill.QuillController> _quillController = quill.QuillController.basic().obs;
  RxBool _isReadOnly = false.obs;
  Rx<FocusNode> _focusNode = FocusNode().obs;
  RxString _selectedCategoryMain = '상위 카테고리'.obs;
  RxString _selectedCategorySub = '하위 카테고리'.obs;
  RxBool _isCategorySelected = true.obs;
  Rx<GlobalKey<FormState>> _formKey = GlobalKey<FormState>().obs;
  Rx<ScrollController> _scrollController = ScrollController().obs;

  String get selectedCategoryMain => _selectedCategoryMain.value;
  String get selectedCategorySub => _selectedCategorySub.value;
  bool get isCategorySelected => _isCategorySelected.value;
  quill.QuillController get quillController => _quillController.value;
  GlobalKey<FormState> get formKey => _formKey.value;
  bool get isReadOnly => _isReadOnly.value;
  FocusNode get focusNode => _focusNode.value;
  ScrollController get scrollController => _scrollController.value;

  Future<void> fetchCommunityUpdateData({
    required String textEditingController_title,
    required String selectedCategorySub,
    required String selectedCategoryMain,
    required String description, // JSON 문자열로 변경
  }) async {
    this.textEditingController_title.text = textEditingController_title;
    this._selectedCategorySub.value = selectedCategorySub;
    this._selectedCategoryMain.value = selectedCategoryMain;

    // JSON 문자열을 Delta로 변환 후 Document 생성
    final delta = quill.Delta.fromJson(json.decode(description));
    final document = quill.Document.fromDelta(delta);

    _quillController.value = quill.QuillController(
      document: document,
      selection: TextSelection.collapsed(offset: 0),
    );
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

  // 커뮤니티 수정하기
  Future<void> updateCommunityPost(pk,Map<String, dynamic> body) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().updateCommunity(pk, body);
      print(pk);

      if (response.success) {
        print('Community post updated successfully');
      } else {
        print('Failed to updated community post: ${response.error}');
      }
    } catch (e) {
      print('Error updating community post: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadAndReplaceImageInDelta(List<quill.Operation> ops, int pk) async {
    for (var op in ops) {
      if (op.key == 'insert' && op.value is Map && op.value.containsKey('image')) {
        String localPath = op.value['image'];

        // Step 1: 이미지가 로컬에 저장되어 있는지 확인
        if (await io.File(localPath).exists()) {

          // Step 2: 로컬에 저장된 이미지를 Firebase에 업로드
          String downloadUrl = await _uploadImage(localPath, pk);

          // Step 3: Delta 문서에서 로컬 이미지 경로를 Firebase URL로 대치
          op.value['image'] = downloadUrl;
        }
      }
    }
  }

  Future<String> _uploadImage(String localPath, int pk) async {
    // Firebase에 이미지 업로드하는 과정
    io.File file = io.File(localPath);
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('community')
        .child('$pk/${path.basename(file.path)}');

    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

    // Firebase Storage에서 다운로드 URL 가져오기
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  String? findFirstInsertedImage(ops) {
    for (var op in ops) {
      // 'insert'에 'image'가 있는 경우 찾기
      if (op.key == 'insert' && op.value is Map && op.value.containsKey('image')) {
        // 처음 찾은 이미지 경로 반환
        return op.value['image'];
      }
    }
    // 이미지가 없으면 null 반환
    return null;
  }



}
