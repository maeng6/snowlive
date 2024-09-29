import 'dart:io' as io;
import 'package:com.snowlive/api/api_community.dart';
import 'package:com.snowlive/viewmodel/util/vm_imageController.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart' as quill;
import 'package:path/path.dart' as path;

class CommunityUploadViewModel extends GetxController {
  var isLoading = true.obs;
  final TextEditingController textEditingController_title = TextEditingController();
  final TextEditingController textEditingController_snsUrl = TextEditingController();

  RxString _selectedCategorySub = '상위 카테고리'.obs;
  RxString _selectedCategorySub2 = '하위 카테고리'.obs;
  RxInt _pk = 0.obs;
  RxBool _isCategorySelected = true.obs;
  RxBool _isReadOnly = false.obs;
  Rx<quill.QuillController> _quillController = quill.QuillController.basic().obs;
  Rx<FocusNode> _focusNode = FocusNode().obs;
  Rx<ScrollController> _scrollController = ScrollController().obs;
  Rx<GlobalKey<FormState>> _formKey = GlobalKey<FormState>().obs;
  ImageController imageController = Get.put(ImageController());

  RxBool _isTitleWritten = false.obs;

  String get selectedCategorySub => _selectedCategorySub.value;
  String get selectedCategorySub2 => _selectedCategorySub2.value;
  int get pk => _pk.value;
  bool get isCategorySelected => _isCategorySelected.value;
  bool get isReadOnly => _isReadOnly.value;
  quill.QuillController get quillController => _quillController.value;
  FocusNode get focusNode => _focusNode.value;
  ScrollController get scrollController => _scrollController.value;
  GlobalKey<FormState> get formKey => _formKey.value;

  bool get isTitleWritten => _isTitleWritten.value;

  @override
  void onInit() {
    super.onInit();
    _quillController.value = quill.QuillController.basic();
  }



  // 커뮤니티 생성하기
  Future<void> createCommunityPost(Map<String, dynamic> body) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().createCommunityPost(body);

      if (response.success) {
        _pk.value = response.data['community_id'];
        print('커뮤니티 pk : $pk');
        print('Community post created successfully');
      } else {
        print('Failed to create community post: ${response.error}');
      }
    } catch (e) {
      print('Error creating community post: $e');
    } finally {
      isLoading.value = false;
    }
  }



  void setIsSelectedCategoryFalse() {
    _isCategorySelected.value = false;
  }

  void setIsSelectedCategoryTrue() {
    _isCategorySelected.value = true;
  }

  void resetCategorySub2() {
    _selectedCategorySub2.value = '하위 카테고리';
  }

  void selectCategorySub(String selectedcategorySub) {
    _selectedCategorySub.value = selectedcategorySub;
  }
  void selectCategorySub2(String selectedcategorySub2) {
    _selectedCategorySub2.value = selectedcategorySub2;
  }

  // 커뮤니티 수정하기
  Future<void> updateCommunityPost(pk,Map<String, dynamic> body) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().updateCommunity(pk, body);

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
          // Step 2: 로컬 이미지를 압축
          String compressedPath = await _compressImage(localPath);

          // Step 3: 압축된 이미지를 Firebase에 업로드
          String downloadUrl = await _uploadImage(compressedPath, pk);

          // Step 4: Delta 문서에서 로컬 이미지 경로를 Firebase URL로 대치
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

  Future<String> _compressImage(String filePath) async {
    final compressedImage = await FlutterImageCompress.compressWithFile(
      filePath,
      format: CompressFormat.jpeg,  // JPEG 포맷으로 압축
      quality: 85,  // 압축 품질 설정 (0에서 100)
    );

    // 압축된 이미지 파일을 새로운 경로에 저장
    final compressedFile = io.File('${path.dirname(filePath)}/compressed_${path.basename(filePath)}');
    await compressedFile.writeAsBytes(compressedImage!);

    return compressedFile.path;  // 압축된 파일의 경로 반환
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

  void changeTitleWritten(bool boolean) {
    _isTitleWritten.value = boolean;
  }





}
