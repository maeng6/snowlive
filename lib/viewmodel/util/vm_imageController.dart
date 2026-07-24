import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/core/widget/w_fullScreenDialog.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart' as quill;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:com.snowlive/mobile/util/secure_storage_helper.dart';
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

  // 업로드 진행 상황 (1/5, 2/5 등 표시용)
  RxInt uploadProgress = 0.obs;      // 현재 완료된 업로드 수
  RxInt uploadTotal = 0.obs;         // 총 업로드할 이미지 수
  RxBool isUploading = false.obs;    // 업로드 진행 중 여부


  Future<List<String>> setNewMultiImageFlea({
    required List<XFile> newImages,
    required pk,
    Function(String requestType, String error)? onError,
  }) async {
    var metaData = SettableMetadata(contentType: 'image/jpeg');
    List<String> downloadUrlList = [];

    // 진행 상황 초기화
    uploadProgress.value = 0;
    uploadTotal.value = newImages.length;
    isUploading.value = true;

    print('📤 중고거래 이미지 업로드 시작 (총 ${newImages.length}장)');

    // ===== 1단계: 모든 이미지 병렬 압축 =====
    print('🔄 이미지 압축 시작 (병렬 처리)');
    List<File> compressedFiles = await Future.wait(
      newImages.asMap().entries.map((entry) async {
        int i = entry.key;
        XFile xfile = entry.value;
        File originalFile = File(xfile.path);

        try {
          File compressed = await _compressImage(originalFile);
          print("🔥 [$i] 압축 성공");
          return compressed;
        } catch (e) {
          print("⚠️ [$i] 압축 실패 → 원본 사용: $e");
          // 에러 로그 전송: 이미지 압축 실패
          onError?.call('flea_image_compress_failed', '[$i] $e');
          return originalFile;
        }
      }),
    );
    print('✅ 이미지 압축 완료 (${compressedFiles.length}장)');

    // ===== 2단계: 순차적으로 업로드 (순서 보장) =====
    for (int i = 0; i < compressedFiles.length; i++) {
      File fileToUpload = compressedFiles[i];
      Reference ref = FirebaseStorage.instance.ref('fleamarket/$pk/$i.jpg');

      int retry = 0;
      const int maxRetry = 3;
      bool uploaded = false;
      String? imageUrl;
      String? lastError;

      while (!uploaded && retry < maxRetry) {
        try {
          print("📌 [$i] 업로드 시도 ${retry + 1}/$maxRetry");
          await ref.putFile(fileToUpload, metaData);

          // URL 획득
          try {
            imageUrl = await ref.getDownloadURL();
            print("✅ [$i] 업로드 성공: $imageUrl");
            uploaded = true;
          } catch (urlError) {
            print("❌ [$i] URL 획득 실패: $urlError");
            // 에러 로그 전송: URL 획득 실패
            onError?.call('flea_image_url_failed', '[$i] $urlError');
            retry++;
            lastError = urlError.toString();
            await Future.delayed(const Duration(milliseconds: 600));
          }
        } catch (e) {
          retry++;
          lastError = e.toString();
          print("❌ [$i] Firebase 업로드 실패 → 재시도 ($retry/$maxRetry), error: $e");

          await Future.delayed(const Duration(milliseconds: 600));
        }
      }

      if (!uploaded || imageUrl == null) {
        print("🚨 [$i] 업로드 최종 실패 → 빈값 push");
        // 에러 로그 전송: Firebase 업로드 최종 실패
        onError?.call('flea_image_upload_failed', '[$i] $lastError');
        downloadUrlList.add("");
      } else {
        downloadUrlList.add(imageUrl);
      }

      // 진행 상황 업데이트 (UI에서 관찰 가능)
      uploadProgress.value = i + 1;
    }

    isUploading.value = false;
    print('📤 중고거래 이미지 업로드 종료');
    return downloadUrlList;
  }


// 이미지 압축 함수 - HEIC 포맷 + 고해상도 + 저장소 권한 대응
  Future<File> _compressImage(File file) async {
    final compressedImage = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      format: CompressFormat.jpeg,
      quality: 70,
      // 업로드 속도 향상을 위해 1280px로 축소
      minWidth: 1280,
      minHeight: 1280,
    );

    // [2단계] HEIC 등 일부 포맷에서 null 반환 가능 → 대체 방식으로 변환
    if (compressedImage == null || compressedImage.isEmpty) {
      print('⚠️ FlutterImageCompress 반환값 null → image 패키지로 대체 변환');
      return await _compressImageFallback(file);
    }

    // [1단계] 앱 전용 임시 디렉토리에 저장 (저장소 권한 문제 해결)
    // - Android 11+ Scoped Storage에서도 항상 쓰기 가능
    // - 원본 파일 폴더(갤러리 등)에 쓰기 시도 X
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final compressedFile = File('${tempDir.path}/compressed_$timestamp.jpg');
    await compressedFile.writeAsBytes(compressedImage);

    return compressedFile;
  }

  // [2단계] 대체 압축 방식 - HEIC 등 FlutterImageCompress 실패 시 사용
  Future<File> _compressImageFallback(File file) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/fallback_$timestamp.jpg';

    // image 패키지로 디코딩 (HEIC 포함 대부분 포맷 지원)
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      print('❌ image 패키지 디코딩도 실패 → 원본 반환');
      return file;
    }

    // 업로드 속도 향상을 위해 1280px로 축소
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
      print('📐 리사이징: ${image.width}x${image.height}');
    }

    // JPEG로 인코딩하여 저장
    final jpegBytes = img.encodeJpg(image, quality: 70);
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(jpegBytes);

    print('✅ HEIC→JPEG 변환 성공: ${outputFile.path} (${jpegBytes.length} bytes)');
    return outputFile;
  }

  Future<String> setNewImage_Crew({
    required XFile newImage,
    required crewID,
    String? oldUrl,   // ← 이전 로고 URL (수정일 때만 넘겨줌)
    Function(String requestType, String error)? onError,
  }) async {
    final metaData = SettableMetadata(contentType: 'image/jpeg');
    String downloadUrl = '';

    try {
      File fileToUpload;
      try {
        fileToUpload = await _compressImage(File(newImage.path));
      } catch (e) {
        print('Crew image compress error, use original: $e');
        // 에러 로그 전송: 이미지 압축 실패
        onError?.call('crew_image_compress_failed', e.toString());
        fileToUpload = File(newImage.path);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${crewID}_$timestamp.jpg';
      final ref = FirebaseStorage.instance.ref('crewLogo/$fileName');

      try {
        await ref.putFile(fileToUpload, metaData);
      } catch (e) {
        print('Crew image upload error: $e');
        // 에러 로그 전송: Firebase 업로드 실패
        onError?.call('crew_image_upload_failed', e.toString());
        rethrow;
      }

      try {
        downloadUrl = await ref.getDownloadURL();
        print('Crew logo download URL: $downloadUrl');
      } catch (e) {
        print('Crew image URL error: $e');
        // 에러 로그 전송: URL 획득 실패
        onError?.call('crew_image_url_failed', e.toString());
        rethrow;
      }

      // 이전 로고 삭제 (크루 수정 시)
      if (oldUrl != null && oldUrl.isNotEmpty) {
        try {
          final oldRef = FirebaseStorage.instance.refFromURL(oldUrl);
          await oldRef.delete();
          print('Old crew logo deleted: $oldUrl');
        } catch (e) {
          print('Failed to delete old crew logo: $e');
        }
      }
    } catch (e) {
      print('Error uploading crew image: $e');
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
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            lockAspectRatio: false,  // 자유 비율 허용
          ),
          IOSUiSettings(
            aspectRatioLockEnabled: false,  // iOS 쪽은 아직 이 옵션을 사용할 수 있음
          ),
        ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(20),
          title: Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/imgs/imgs/img_error_1.png',
                  scale: 4,
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 5),
                Text(
                  '최대 5장까지 업로드 가능합니다',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

      return resizedImages;
    }
  }

  Future<String> setNewImage(
    XFile newImage, {
    Function(String requestType, String error)? onError,
  }) async {
    // Firebase Auth 대신 SecureStorage의 user_id 사용
    String? userId = await getSecureStorage().read(key: 'user_id');
    if (userId == null) {
      print('Error: User ID is null');
      onError?.call('profile_image_uid_null', 'User ID is null');
      return '';
    }

    final metaData = SettableMetadata(contentType: 'image/jpeg');

    try {
      // 1) 업로드할 파일 준비 (압축 시도 → 실패하면 원본 사용)
      File fileToUpload;
      try {
        fileToUpload = await _compressImage(File(newImage.path));
      } catch (e) {
        print('Image compress error, use original file: $e');
        // 에러 로그 전송: 이미지 압축 실패
        onError?.call('profile_image_compress_failed', e.toString());
        fileToUpload = File(newImage.path);
      }

      // 2) 매번 다른 파일명 생성 (user_id + timestamp)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.jpg';

      // 3) Firebase Storage 경로
      final ref = FirebaseStorage.instance.ref('user_profile/$fileName');

      // 4) 업로드
      try {
        await ref.putFile(fileToUpload, metaData);
      } catch (e) {
        print('Profile image upload error: $e');
        // 에러 로그 전송: Firebase 업로드 실패
        onError?.call('profile_image_upload_failed', e.toString());
        return '';
      }

      // 5) 다운로드 URL 가져오기
      try {
        final downloadUrl = await ref.getDownloadURL();
        print('Download URL: $downloadUrl');
        return downloadUrl;
      } catch (e) {
        print('Profile image URL error: $e');
        // 에러 로그 전송: URL 획득 실패
        onError?.call('profile_image_url_failed', e.toString());
        return '';
      }
    } catch (e) {
      print('Error uploading image: $e');
      onError?.call('profile_image_unknown_error', e.toString());
      return '';
    }
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
    String? uid = await getSecureStorage().read(key: 'uid');
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

