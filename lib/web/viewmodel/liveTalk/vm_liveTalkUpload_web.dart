import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:com.snowlive/core/api/api_liveTalk.dart';
import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:com.snowlive/model/m_ridingRecordCard.dart';
import 'package:com.snowlive/web/viewmodel/util/vm_imageController_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// 웹 라이브톡 업로드 뷰모델 — 사진 글과 라이딩 기록 카드 글을 모두 담당한다.
///
/// 라이브톡 글은 `image_url` 하나 + `description`이 전부다. 라이딩 카드 글도
/// 별도 타입이 아니라 **카드를 PNG로 캡처해 image_url에 넣은 일반 글**이다
/// (모바일 앱과 동일). 그래서 피드는 카드 글을 특별히 구분하지 않는다.
class LiveTalkUploadViewModelWeb extends GetxController {
  final LiveTalkAPI _api = LiveTalkAPI();
  final ImageControllerWeb _imageController = Get.put(ImageControllerWeb());

  // ── 사진 글 ─────────────────────────────────────────────
  final Rxn<XFile> _pickedImage = Rxn<XFile>();
  XFile? get pickedImage => _pickedImage.value;
  bool get hasPickedImage => _pickedImage.value != null;

  // ── 라이딩 카드 글 ───────────────────────────────────────
  final Rxn<RidingRecordCard> _ridingCard = Rxn<RidingRecordCard>();
  final RxBool _isLoadingCard = false.obs;
  final RxInt _selectedCardType = 0.obs;

  RidingRecordCard? get ridingCard => _ridingCard.value;
  bool get isLoadingCard => _isLoadingCard.value;
  int get selectedCardType => _selectedCardType.value;

  /// 오늘 라이딩 기록이 있는지. 없으면 목업의 "앱 다운로드" 안내만 띄운다.
  /// 웹에서는 라이브온을 할 수 없으니 게스트·미라이딩 사용자는 항상 이 상태다.
  bool get hasRidingRecord => (_ridingCard.value?.totalSlopeCount ?? 0) > 0;

  final RxBool _isSubmitting = false.obs;
  bool get isSubmitting => _isSubmitting.value;

  void selectCardType(int type) => _selectedCardType.value = type;

  /// 화면을 다시 열 때 이전 상태가 남지 않도록 비운다(fenix라 VM이 살아남는다).
  void reset() {
    _pickedImage.value = null;
    _selectedCardType.value = 0;
  }

  /// 사진 선택. [fromCamera]면 모바일 브라우저에서 카메라가 열린다
  /// (데스크탑 브라우저는 파일 선택으로 동작한다 — 웹의 한계).
  Future<void> pickImage({bool fromCamera = false}) async {
    final picked = await ImagePicker().pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) _pickedImage.value = picked;
  }

  /// 드래그앤드롭으로 받은 파일을 그대로 쓴다(브라우저가 만든 blob URL).
  void setPickedImage(XFile file) => _pickedImage.value = file;

  Future<void> loadRidingCard(int userId) async {
    _isLoadingCard.value = true;
    try {
      final response = await RankingAPI().fetchRidingRecordCard({'user_id': userId});
      _ridingCard.value = response.success
          ? RidingRecordCard.fromJson(response.data as Map<String, dynamic>)
          : null;
      if (!response.success) {
        debugPrint('[LiveTalkUpload] 라이딩 카드 조회 실패: ${response.error}');
      }
    } catch (e) {
      debugPrint('[LiveTalkUpload] 라이딩 카드 조회 예외: $e');
      _ridingCard.value = null;
    } finally {
      _isLoadingCard.value = false;
    }
  }

  /// 사진 글 등록. 성공하면 true.
  Future<bool> submitPhoto({required int userId, required String description}) async {
    final file = _pickedImage.value;
    if (file == null) return false;
    return _submit(userId: userId, description: description, upload: () async {
      final urls = await _imageController.uploadLiveTalkImages(files: [file], userId: userId);
      return urls.isNotEmpty && urls.first.isNotEmpty ? urls.first : null;
    });
  }

  /// 라이딩 카드 글 등록 — 카드 위젯을 PNG로 캡처해서 올린다.
  Future<bool> submitCard({
    required int userId,
    required String description,
    required GlobalKey boundaryKey,
  }) async {
    return _submit(userId: userId, description: description, upload: () async {
      final bytes = await _captureCard(boundaryKey);
      if (bytes == null) return null;
      return _imageController.uploadLiveTalkPng(bytes: bytes, userId: userId);
    });
  }

  Future<bool> _submit({
    required int userId,
    required String description,
    required Future<String?> Function() upload,
  }) async {
    if (_isSubmitting.value) return false;
    _isSubmitting.value = true;
    try {
      final imageUrl = await upload();
      if (imageUrl == null) {
        debugPrint('[LiveTalkUpload] 이미지 업로드 실패');
        return false;
      }
      final response = await _api.create({
        'user_id': userId,
        'description': description,
        'image_url': imageUrl,
      });
      if (!response.success) {
        debugPrint('[LiveTalkUpload] 글 등록 실패: ${response.error}');
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('[LiveTalkUpload] 등록 예외: $e');
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 카드 위젯을 고화질 PNG로 캡처한다.
  ///
  /// ⚠️ [RepaintBoundary.toImage]는 **캔버스에 그려진 것만** 담는다. 그래서 카드
  /// 안 아바타는 `<img>` 폴백을 쓰는 WebNetworkImage가 아니라 `Image.network`로
  /// 그린다. Firebase Storage에 CORS 헤더가 없으면 그 디코드가 실패해서 캡처된
  /// 카드의 아바타가 기본 이미지로 남는다(버킷 CORS 설정으로 해결 가능).
  Future<Uint8List?> _captureCard(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (e) {
      debugPrint('[LiveTalkUpload] 카드 캡처 실패: $e');
      return null;
    }
  }
}
