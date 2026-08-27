import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:com.snowlive/core/api/api_liveTalk.dart';
import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:com.snowlive/core/model/m_dailyRidingCard.dart';
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
  final Rxn<DailyRidingCard> _ridingCard = Rxn<DailyRidingCard>();
  final RxBool _isLoadingCard = false.obs;
  final RxInt _selectedCardType = 0.obs;

  DailyRidingCard? get ridingCard => _ridingCard.value;
  bool get isLoadingCard => _isLoadingCard.value;
  int get selectedCardType => _selectedCardType.value;

  /// 오늘 라이딩 기록 카드가 있는지. 모바일 앱과 같은 판정 —
  /// **카드가 존재하면 기록이 있는 것**이다(총 슬로프 수를 따로 보지 않는다).
  bool get hasRidingRecord => _ridingCard.value != null;

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

  /// 오늘의 라이딩 카드를 불러온다.
  ///
  /// ⚠️ `ranking/riding-record-card/`(리조트홈 요약 카드)가 아니라 **모바일 앱과
  /// 같은 `daily-riding-card-list`에서 오늘 날짜 카드를 찾는다**. 두 엔드포인트는
  /// 서로 다른 집계라서, 요약 카드 쪽은 오늘 라이딩을 했는데도 0으로 오는 경우가 있다.
  /// (v_liveTalk_main.dart의 `_showRidingCardSelection`과 같은 로직)
  Future<void> loadRidingCard(int userId) async {
    _isLoadingCard.value = true;
    try {
      final response = await RankingAPI().fetchDailyRidingCardList({'user_id': userId});
      if (!response.success) {
        debugPrint('[LiveTalkUpload] 데일리 카드 조회 실패: ${response.error}');
        _ridingCard.value = null;
        return;
      }
      final cards = (response.data as List)
          .map((item) => DailyRidingCard.fromJson(item as Map<String, dynamic>))
          .toList();
      _ridingCard.value = cards.firstWhereOrNull((card) => card.date == _todayKey());
    } catch (e) {
      debugPrint('[LiveTalkUpload] 데일리 카드 조회 예외: $e');
      _ridingCard.value = null;
    } finally {
      _isLoadingCard.value = false;
    }
  }

  /// 서버 `date` 필드와 같은 형식(`yyyy-MM-dd`). 앱과 동일하게 **기기 로컬 날짜**를 쓴다.
  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  /// 사진 글 등록. 성공하면 true.
  ///
  /// [crewId]를 주면 **크루톡**으로 올라간다. 이때 [secret]은 반드시 함께 지정한다
  /// (true=크루 안에서만 / false=전체공개). 서버 규칙은 앱과 같다.
  Future<bool> submitPhoto({
    required int userId,
    required String description,
    int? crewId,
    bool? secret,
  }) async {
    final file = _pickedImage.value;
    if (file == null) return false;
    return _submit(userId: userId, description: description, crewId: crewId, secret: secret, upload: () async {
      final urls = await _imageController.uploadLiveTalkImages(files: [file], userId: userId);
      return urls.isNotEmpty && urls.first.isNotEmpty ? urls.first : null;
    });
  }

  /// 라이딩 카드 글 등록 — 카드 위젯을 PNG로 캡처해서 올린다.
  Future<bool> submitCard({
    required int userId,
    required String description,
    required GlobalKey boundaryKey,
    int? crewId,
    bool? secret,
  }) async {
    return _submit(userId: userId, description: description, crewId: crewId, secret: secret, upload: () async {
      final bytes = await _captureCard(boundaryKey);
      if (bytes == null) return null;
      return _imageController.uploadLiveTalkPng(bytes: bytes, userId: userId);
    });
  }

  Future<bool> _submit({
    required int userId,
    required String description,
    required Future<String?> Function() upload,
    int? crewId,
    bool? secret,
  }) async {
    assert(crewId == null || secret != null, 'crewId가 있으면 secret을 지정해야 한다');
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
        if (crewId != null) 'crew_id': crewId,
        if (crewId != null) 'secret': secret,
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
