import 'dart:typed_data';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImageControllerWeb extends GetxController {
  List<String> imagesUrlList = [];

  RxInt uploadProgress = 0.obs;
  RxInt uploadTotal = 0.obs;
  RxBool isUploading = false.obs;

  Future<List<String>> setNewMultiImageFlea({
    required List<XFile> newImages,
    required pk,
    Function(String requestType, String error)? onError,
  }) {
    return _uploadAll(
      files: newImages,
      pathOf: (i) => 'fleamarket/$pk/$i.jpg',
      errorPrefix: 'flea',
      onError: onError,
    );
  }

  /// 커뮤니티 본문에 삽입된 이미지 업로드. 압축·재시도는 중고거래와 완전히 같고
  /// Storage 경로만 다르다(모바일 앱도 `community/$pk/`에 올린다).
  Future<List<String>> uploadCommunityImages({
    required List<XFile> files,
    required int pk,
    Function(String requestType, String error)? onError,
  }) {
    return _uploadAll(
      files: files,
      pathOf: (i) => 'community/$pk/$i.jpg',
      errorPrefix: 'community',
      onError: onError,
    );
  }

  /// 라이브톡 사진. 모바일 앱과 같은 경로 규칙(`livetalk/{userId}_{ts}.jpg`)을 쓴다.
  Future<List<String>> uploadLiveTalkImages({
    required List<XFile> files,
    required int userId,
    Function(String requestType, String error)? onError,
  }) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return _uploadAll(
      files: files,
      pathOf: (i) => 'livetalk/${userId}_${stamp + i}.jpg',
      errorPrefix: 'livetalk',
      onError: onError,
    );
  }

  /// 온보딩·프로필 수정에서 쓰는 프로필 이미지 1장 업로드. 실패하면 빈 문자열.
  ///
  /// ⚠️ 파일명 키로 **Firebase uid**를 받는다. 모바일 앱은 SecureStorage의 `user_id`로
  /// 파일명을 만드는데(`vm_imageController.dart:377`), 가입 단계에서는 `user_id`가
  /// 아직 없어서 항상 빈 URL이 돼 **온보딩에서 고른 사진이 저장되지 않는다.**
  /// 웹은 그 시점에도 확실히 있는 uid를 쓴다(경로 규칙 `user_profile/{키}_{ts}.jpg`는 동일).
  Future<String> uploadProfileImage({
    required XFile file,
    required String uid,
    Function(String requestType, String error)? onError,
  }) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final urls = await _uploadAll(
      files: [file],
      pathOf: (_) => 'user_profile/${uid}_$stamp.jpg',
      errorPrefix: 'profile',
      onError: onError,
    );
    return urls.isEmpty ? '' : urls.first;
  }

  /// 이미 바이트로 만들어진 이미지(라이딩 카드 캡처 PNG) 1장 업로드.
  /// 압축을 거치지 않는다 — 캡처 결과를 다시 인코딩하면 글자가 뭉개진다.
  Future<String?> uploadLiveTalkPng({
    required Uint8List bytes,
    required int userId,
  }) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance.ref('livetalk/${userId}_$stamp.png');
    try {
      await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// 실패한 자리에는 빈 문자열이 들어간다(순서는 입력과 1:1로 유지).
  Future<List<String>> _uploadAll({
    required List<XFile> files,
    required String Function(int index) pathOf,
    required String errorPrefix,
    Function(String requestType, String error)? onError,
  }) async {
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    List<String> downloadUrlList = [];

    uploadProgress.value = 0;
    uploadTotal.value = files.length;
    isUploading.value = true;

    List<Uint8List> compressedDataList = await Future.wait(
      files.asMap().entries.map((entry) async {
        int i = entry.key;
        XFile xfile = entry.value;

        try {
          Uint8List compressed = await _compressImageWeb(xfile);
          return compressed;
        } catch (e) {
          onError?.call('${errorPrefix}_image_compress_failed', '[$i] $e');
          return await xfile.readAsBytes();
        }
      }),
    );

    for (int i = 0; i < compressedDataList.length; i++) {
      Uint8List data = compressedDataList[i];
      Reference ref = FirebaseStorage.instance.ref(pathOf(i));

      int retry = 0;
      const int maxRetry = 3;
      bool uploaded = false;
      String? imageUrl;
      String? lastError;

      while (!uploaded && retry < maxRetry) {
        try {
          await ref.putData(data, metaData);

          try {
            imageUrl = await ref.getDownloadURL();
            uploaded = true;
          } catch (urlError) {
            onError?.call('${errorPrefix}_image_url_failed', '[$i] $urlError');
            retry++;
            lastError = urlError.toString();
            await Future.delayed(const Duration(milliseconds: 600));
          }
        } catch (e) {
          retry++;
          lastError = e.toString();
          await Future.delayed(const Duration(milliseconds: 600));
        }
      }

      if (!uploaded || imageUrl == null) {
        onError?.call('${errorPrefix}_image_upload_failed', '[$i] $lastError');
        downloadUrlList.add("");
      } else {
        downloadUrlList.add(imageUrl);
      }

      uploadProgress.value = i + 1;
    }

    isUploading.value = false;
    return downloadUrlList;
  }

  Future<Uint8List> _compressImageWeb(XFile xfile) async {
    final bytes = await xfile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      return bytes;
    }

    const int maxSize = 1280;
    if (image.width > maxSize || image.height > maxSize) {
      final double ratio = image.width > image.height
          ? maxSize / image.width
          : maxSize / image.height;
      image = img.copyResize(
        image,
        width: (image.width * ratio).toInt(),
        height: (image.height * ratio).toInt(),
        interpolation: img.Interpolation.linear,
      );
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 70));
  }

  Future<List<XFile>> getMultiImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    List<XFile> selectedImages = await picker.pickMultiImage(imageQuality: 70);

    if (selectedImages.length > 5) {
      // Get.dialog는 셸 안쪽 Navigator에 붙어서 딤이 GNB를 못 덮는다.
      // 뷰모델이라 BuildContext가 없으므로 GetX가 들고 있는 오버레이 컨텍스트를 쓴다.
      final overlayContext = Get.overlayContext;
      if (overlayContext != null) {
        showWebOverlayModal<void>(
          context: overlayContext,
          builder: (_, close) => Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.all(20),
              child: Text(
                '최대 5장까지 업로드 가능합니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
      return [];
    }

    return selectedImages;
  }
}
