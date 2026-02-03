import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:com.snowlive/api/api_liveTalk.dart';
import 'package:com.snowlive/model/m_dailyRidingCard.dart';
import 'package:com.snowlive/model/m_liveTalk.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class LiveTalkViewModel extends GetxController {
  final LiveTalkAPI _api = LiveTalkAPI();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  // ============================================
  // 로딩 상태
  // ============================================
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool get isLoadingNextPage => isLoadingMore;
  RxBool isInitialLoaded = false.obs;  // 초기 데이터 로드 완료 여부
  RxBool isLoadingMyList = false.obs;
  RxBool isLoadingMoreMyList = false.obs;
  RxBool isLoadingDetail = false.obs;
  RxBool isSubmitting = false.obs;

  // ============================================
  // 게시글 목록
  // ============================================
  RxList<LiveTalk> liveTalkList = <LiveTalk>[].obs;
  RxList<LiveTalk> myLiveTalkList = <LiveTalk>[].obs;

  // 페이지네이션
  RxnString nextPageUrl = RxnString(null);
  RxnString previousPageUrl = RxnString(null);
  RxnString myNextPageUrl = RxnString(null);
  RxnString myPreviousPageUrl = RxnString(null);

  // 총 개수
  RxInt totalCount = 0.obs;
  RxInt myTotalCount = 0.obs;

  // 스크롤 컨트롤러
  ScrollController scrollController = ScrollController();
  ScrollController myScrollController = ScrollController();

  // FAB 표시 여부
  RxBool showFab = true.obs;
  RxBool showMyFab = true.obs;
  RxBool showScrollToTopButton = false.obs;

  // ============================================
  // 게시글 작성 관련
  // ============================================
  final TextEditingController textController = TextEditingController();
  RxBool isButtonEnabled = false.obs;
  RxBool isPosting = false.obs;
  Rxn<XFile> selectedImage = Rxn<XFile>();
  RxBool isUploadingImage = false.obs;

  // 라이딩 카드 선택 관련
  Rxn<DailyRidingCard> selectedRidingCard = Rxn<DailyRidingCard>();
  RxInt selectedRidingCardType = 0.obs;  // 선택된 카드의 타입 (0 또는 1)
  RxBool isRidingCardMode = false.obs;
  GlobalKey ridingCardKey = GlobalKey();

  // 입력 영역 높이 (FAB 위치 계산용)
  RxDouble inputAreaHeight = 60.0.obs;

  // ============================================
  // 댓글 작성 관련
  // ============================================
  final TextEditingController commentController = TextEditingController();
  RxBool isCommentButtonEnabled = false.obs;
  RxBool isLoadingComments = false.obs;
  Rxn<LiveTalk> currentLiveTalk = Rxn<LiveTalk>();
  RxList<LiveTalkComment> commentList = <LiveTalkComment>[].obs;

  // 답글 작성 모드
  RxBool isReplyMode = false.obs;
  Rxn<LiveTalkComment> replyTargetComment = Rxn<LiveTalkComment>();

  // 댓글 수정 모드
  RxBool isEditCommentMode = false.obs;
  Rxn<LiveTalkComment> editingComment = Rxn<LiveTalkComment>();
  RxInt editingCommentIndex = (-1).obs;

  // 답글 수정 모드
  RxBool isEditReplyMode = false.obs;
  Rxn<LiveTalkReply> editingReply = Rxn<LiveTalkReply>();
  RxInt editingReplyCommentIndex = (-1).obs;
  RxInt editingReplyIndex = (-1).obs;

  // ============================================
  // 게시글 상세
  // ============================================
  Rxn<LiveTalk> liveTalkDetail = Rxn<LiveTalk>();
  RxList<LiveTalkComment> comments = <LiveTalkComment>[].obs;

  // ============================================
  // Lifecycle
  // ============================================
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    myScrollController.addListener(_myScrollListener);
    textController.addListener(_updateButtonState);
    commentController.addListener(_updateCommentButtonState);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    myScrollController.removeListener(_myScrollListener);
    myScrollController.dispose();
    textController.dispose();
    commentController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    // FAB 숨기기/표시
    if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (showFab.value) showFab.value = false;
    } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!showFab.value) showFab.value = true;
    }

    // 맨 위로 버튼 표시
    showScrollToTopButton.value = scrollController.offset > 500;

    // 무한 스크롤
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && nextPageUrl.value != null) {
        fetchNextPage();
      }
    }
  }

  void _updateButtonState() {
    final hasText = textController.text.trim().isNotEmpty;
    final hasNewImage = selectedImage.value != null;
    final hasExistingImage = isEditMode.value &&
        editingLiveTalk.value?.imageUrl != null &&
        editingLiveTalk.value!.imageUrl!.isNotEmpty;
    final hasRidingCard = selectedRidingCard.value != null;
    isButtonEnabled.value = hasText || hasNewImage || hasExistingImage || hasRidingCard;
  }

  void _updateCommentButtonState() {
    isCommentButtonEnabled.value = commentController.text.trim().isNotEmpty;
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _myScrollListener() {
    // FAB 숨기기/표시
    if (myScrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (showMyFab.value) showMyFab.value = false;
    } else if (myScrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!showMyFab.value) showMyFab.value = true;
    }

    // 무한 스크롤
    if (myScrollController.position.pixels >= myScrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMoreMyList.value && myNextPageUrl.value != null) {
        fetchMyNextPage();
      }
    }
  }

  // ============================================
  // 1. 게시글 목록 관련
  // ============================================

  /// 전체 게시글 목록 조회
  Future<void> fetchLiveTalkList({bool refresh = false}) async {
    // refresh 시에는 리스트를 먼저 clear하지 않음 (데이터 받은 후 교체)
    if (refresh) {
      nextPageUrl.value = null;
    }
    isLoading.value = true;
    try {
      final response = await _api.fetchList({
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final listResponse = LiveTalkListResponse.fromJson(response.data);
        liveTalkList.value = listResponse.results ?? [];
        nextPageUrl.value = listResponse.next;
        previousPageUrl.value = listResponse.previous;
        totalCount.value = listResponse.count ?? 0;
        isInitialLoaded.value = true;  // 초기 로딩 완료 표시
      } else {
        print('❌ LiveTalk 목록 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('❌ LiveTalk 목록 조회 에러: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 목록 새로고침 (pull to refresh)
  Future<void> onRefresh() async {
    await fetchLiveTalkList(refresh: true);
  }

  /// 다음 페이지 조회
  Future<void> fetchNextPage() async {
    if (nextPageUrl.value == null || isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      final response = await _api.fetchList(
        {'user_id': _userViewModel.user.user_id},
        url: nextPageUrl.value,
      );

      if (response.success) {
        final listResponse = LiveTalkListResponse.fromJson(response.data);
        liveTalkList.addAll(listResponse.results ?? []);
        nextPageUrl.value = listResponse.next;
        previousPageUrl.value = listResponse.previous;
      }
    } catch (e) {
      print('❌ LiveTalk 다음 페이지 조회 에러: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 내 게시글 목록 조회
  Future<void> fetchMyLiveTalkList() async {
    isLoadingMyList.value = true;
    try {
      final response = await _api.fetchMyList({
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final listResponse = LiveTalkListResponse.fromJson(response.data);
        myLiveTalkList.value = listResponse.results ?? [];
        myNextPageUrl.value = listResponse.next;
        myPreviousPageUrl.value = listResponse.previous;
        myTotalCount.value = listResponse.count ?? 0;
      } else {
        print('❌ 내 LiveTalk 목록 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('❌ 내 LiveTalk 목록 조회 에러: $e');
    } finally {
      isLoadingMyList.value = false;
    }
  }

  /// 내 게시글 다음 페이지 조회
  Future<void> fetchMyNextPage() async {
    if (myNextPageUrl.value == null || isLoadingMoreMyList.value) return;

    isLoadingMoreMyList.value = true;
    try {
      final response = await _api.fetchMyList(
        {'user_id': _userViewModel.user.user_id},
        url: myNextPageUrl.value,
      );

      if (response.success) {
        final listResponse = LiveTalkListResponse.fromJson(response.data);
        myLiveTalkList.addAll(listResponse.results ?? []);
        myNextPageUrl.value = listResponse.next;
        myPreviousPageUrl.value = listResponse.previous;
      }
    } catch (e) {
      print('❌ 내 LiveTalk 다음 페이지 조회 에러: $e');
    } finally {
      isLoadingMoreMyList.value = false;
    }
  }

  /// 목록에서 게시글 삭제
  void removeFromList(int livetalkId) {
    liveTalkList.removeWhere((item) => item.livetalkId == livetalkId);
    myLiveTalkList.removeWhere((item) => item.livetalkId == livetalkId);
  }

  /// 목록 새로고침
  Future<void> refresh() async {
    await fetchLiveTalkList();
  }

  /// 내 목록 새로고침
  Future<void> refreshMyList() async {
    await fetchMyLiveTalkList();
  }

  void _updateLiveTalkInList(int livetalkId, bool? isLiked, int? likeCount) {
    // 전체 목록에서 업데이트
    final index = liveTalkList.indexWhere((item) => item.livetalkId == livetalkId);
    if (index != -1) {
      liveTalkList[index].isLiked = isLiked;
      liveTalkList[index].likeCount = likeCount;
      liveTalkList.refresh();
    }

    // 내 목록에서 업데이트
    final myIndex = myLiveTalkList.indexWhere((item) => item.livetalkId == livetalkId);
    if (myIndex != -1) {
      myLiveTalkList[myIndex].isLiked = isLiked;
      myLiveTalkList[myIndex].likeCount = likeCount;
      myLiveTalkList.refresh();
    }
  }

  // ============================================
  // 1-1. 게시글 작성 관련 (입력 영역)
  // ============================================

  // 수정 모드 관련
  RxBool isEditMode = false.obs;
  Rxn<LiveTalk> editingLiveTalk = Rxn<LiveTalk>();

  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        selectedImage.value = image;
        _updateButtonState();
      }
    } catch (e) {
      print('pickImageFromGallery error: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        selectedImage.value = image;
        _updateButtonState();
      }
    } catch (e) {
      print('pickImageFromCamera error: $e');
    }
  }

  /// 수정 모드 시작
  void startEditMode(LiveTalk liveTalk) {
    isEditMode.value = true;
    editingLiveTalk.value = liveTalk;
    textController.text = liveTalk.description ?? '';

    // ✅ 이전 선택 상태 정리 (추천)
    selectedImage.value = null;
    selectedRidingCard.value = null;
    isRidingCardMode.value = false;
    selectedRidingCardType.value = 0;

    _updateButtonState();
  }


  /// 수정 모드 취소
  void cancelEditMode() {
    isEditMode.value = false;
    editingLiveTalk.value = null;
    resetInput();
  }

  /// 게시물 수정 실행
  Future<bool> updateEditingPost() async {
    if (!isEditMode.value || editingLiveTalk.value == null) return false;
    if (isPosting.value) return false;

    final text = textController.text.trim();

    final hasNewRidingCard = selectedRidingCard.value != null; // ✅ 추가
    final hasNewImage = selectedImage.value != null;
    final hasExistingImage = editingLiveTalk.value!.imageUrl != null &&
        editingLiveTalk.value!.imageUrl!.isNotEmpty;

    // 텍스트도 없고 이미지도 없고 카드도 없으면 실패
    if (text.isEmpty && !hasNewRidingCard && !hasNewImage && !hasExistingImage) return false;

    isPosting.value = true;

    try {
      String? imageUrl;

      // ✅ 1) 라이딩 카드가 있으면 캡처 후 업로드 (수정에서도 필요)
      if (hasNewRidingCard) {
        // 프리뷰 렌더 완료 기다리기 (캡처 안정화)
        await WidgetsBinding.instance.endOfFrame;

        final cardImageFile = await captureRidingCardAsImage();
        if (cardImageFile == null) {
          Get.snackbar('오류', '라이딩 카드 캡처에 실패했습니다.');
          return false;
        }

        imageUrl = await _uploadImageFile(cardImageFile);
        if (imageUrl == null) {
          Get.snackbar('오류', '라이딩 카드 업로드에 실패했습니다.');
          return false;
        }
      }
      // ✅ 2) 새 이미지가 있으면 업로드
      else if (hasNewImage) {
        imageUrl = await _uploadImage(selectedImage.value!);
        if (imageUrl == null) {
          Get.snackbar('오류', '이미지 업로드에 실패했습니다.');
          return false;
        }
      }
      // ✅ 3) 기존 이미지 유지
      else if (hasExistingImage) {
        imageUrl = editingLiveTalk.value!.imageUrl;
      }
      // ✅ 4) 그 외: imageUrl = null → updatePost에서 ''로 변환되어 “삭제” 처리됨

      final success = await updatePost(
        livetalkId: editingLiveTalk.value!.livetalkId!,
        description: text,
        imageUrl: imageUrl,
      );

      if (success) {
        // ✅ 상태 정리 (수정 모드 종료 + 입력/선택 초기화)
        cancelEditMode(); // 내부에서 resetInput 호출
        await fetchLiveTalkList(refresh: true);
        return true;
      } else {
        Get.snackbar('오류', '게시물 수정에 실패했습니다.');
        return false;
      }
    } catch (e) {
      print('updateEditingPost error: $e');
      Get.snackbar('오류', '게시물 수정 중 오류가 발생했습니다.');
      return false;
    } finally {
      isPosting.value = false;
    }
  }


  void removeImage() {
    selectedImage.value = null;
    _updateButtonState();
  }

  /// 수정 모드에서 기존 이미지 삭제
  void removeExistingImage() {
    if (editingLiveTalk.value != null) {
      editingLiveTalk.value!.imageUrl = null;
      editingLiveTalk.refresh();
      _updateButtonState();
    }
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      isUploadingImage.value = true;

      // 이미지 압축
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 70,
        minWidth: 1280,
        minHeight: 1280,
      );

      if (compressedFile == null) return null;

      // Firebase Storage에 업로드
      final fileName = 'livetalk/${_userViewModel.user.user_id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      await ref.putFile(File(compressedFile.path), metadata);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('_uploadImage error: $e');
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<bool> createPost() async {
    if (isPosting.value) return false;

    final text = textController.text.trim();
    final hasImage = selectedImage.value != null;
    final hasRidingCard = selectedRidingCard.value != null;

    if (text.isEmpty && !hasImage && !hasRidingCard) return false;

    isPosting.value = true;

    try {
      String? imageUrl;

      // 라이딩 카드가 있으면 캡처 후 업로드
      if (hasRidingCard) {
        final cardImageFile = await captureRidingCardAsImage();
        if (cardImageFile != null) {
          imageUrl = await _uploadImageFile(cardImageFile);
          if (imageUrl == null) {
            Get.snackbar('오류', '라이딩 카드 업로드에 실패했습니다.');
            return false;
          }
        } else {
          Get.snackbar('오류', '라이딩 카드 캡처에 실패했습니다.');
          return false;
        }
      }
      // 이미지가 있으면 먼저 업로드
      else if (hasImage) {
        imageUrl = await _uploadImage(selectedImage.value!);
        if (imageUrl == null) {
          Get.snackbar('오류', '이미지 업로드에 실패했습니다.');
          return false;
        }
      }

      // 게시물 생성
      final newPost = await create(
        description: text.isNotEmpty ? text : '',
        imageUrl: imageUrl,
      );

      if (newPost != null) {
        // 입력 초기화
        resetInput();

        // 목록 새로고침
        await fetchLiveTalkList(refresh: true);

        return true;
      } else {
        Get.snackbar('오류', '게시물 작성에 실패했습니다.');
        return false;
      }
    } catch (e) {
      print('createPost error: $e');
      Get.snackbar('오류', '게시물 작성 중 오류가 발생했습니다.');
      return false;
    } finally {
      isPosting.value = false;
    }
  }

  /// File로 이미지 업로드 (라이딩 카드 캡처 이미지용)
  Future<String?> _uploadImageFile(File imageFile) async {
    try {
      isUploadingImage.value = true;

      // Firebase Storage에 업로드
      final fileName = 'livetalk/${_userViewModel.user.user_id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(contentType: 'image/png');

      await ref.putFile(imageFile, metadata);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('_uploadImageFile error: $e');
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  void resetInput() {
    textController.clear();
    selectedImage.value = null;
    selectedRidingCard.value = null;
    selectedRidingCardType.value = 0;
    isRidingCardMode.value = false;
    isButtonEnabled.value = false;
    inputAreaHeight.value = 60.0;
  }

  /// 라이딩 카드 선택 (카드 타입도 함께 저장)
  void selectRidingCard(DailyRidingCard card, {int cardType = 0}) {
    // 이미지 선택 해제
    selectedImage.value = null;
    // 라이딩 카드 선택
    selectedRidingCard.value = card;
    selectedRidingCardType.value = cardType;
    isRidingCardMode.value = true;
    _updateButtonState();
  }

  /// 라이딩 카드 선택 해제
  void removeRidingCard() {
    selectedRidingCard.value = null;
    selectedRidingCardType.value = 0;
    isRidingCardMode.value = false;
    _updateButtonState();
  }

  /// 라이딩 카드를 이미지로 캡처 (고화질)
  Future<File?> captureRidingCardAsImage() async {
    try {
      // ✅ 렌더 프레임 보장 (선택이지만 강추)
      await WidgetsBinding.instance.endOfFrame;

      final boundary = ridingCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 4.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final fileName = 'riding_card_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      return tempFile;
    } catch (e) {
      print('captureRidingCardAsImage error: $e');
      return null;
    }
  }


  /// 좋아요 토글 (인덱스 기반 - 피드 목록용)
  Future<void> toggleLikeByIndex(int index) async {
    final liveTalk = liveTalkList[index];
    final originalIsLiked = liveTalk.isLiked ?? false;
    final originalLikeCount = liveTalk.likeCount ?? 0;

    // Optimistic Update
    liveTalk.isLiked = !originalIsLiked;
    liveTalk.likeCount = originalLikeCount + (liveTalk.isLiked! ? 1 : -1);
    liveTalkList.refresh();

    try {
      final success = await toggleLike(liveTalk.livetalkId!);
      if (!success) {
        // 롤백
        liveTalk.isLiked = originalIsLiked;
        liveTalk.likeCount = originalLikeCount;
        liveTalkList.refresh();
      }
    } catch (e) {
      // 롤백
      liveTalk.isLiked = originalIsLiked;
      liveTalk.likeCount = originalLikeCount;
      liveTalkList.refresh();
      print('toggleLikeByIndex error: $e');
    }
  }

  /// 삭제 (뷰에서 사용하는 이름)
  Future<bool> deleteLiveTalk(int liveTalkId) async {
    return await deletePost(liveTalkId);
  }

  /// 신고 (뷰에서 사용하는 이름)
  Future<bool> reportLiveTalk(int liveTalkId) async {
    return await report(liveTalkId);
  }

  // ============================================
  // 2. 게시글 상세/CRUD
  // ============================================

  /// 게시글 상세 조회
  Future<void> fetchDetail(int livetalkId) async {
    isLoadingDetail.value = true;
    try {
      final response = await _api.fetchDetail({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        liveTalkDetail.value = LiveTalk.fromJson(response.data);
        comments.value = liveTalkDetail.value?.comments ?? [];
      } else {
        print('❌ LiveTalk 상세 조회 실패: ${response.error}');
      }
    } catch (e) {
      print('❌ LiveTalk 상세 조회 에러: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// 게시글 작성
  Future<LiveTalk?> create({
    required String description,
    String? imageUrl,
  }) async {
    isSubmitting.value = true;
    try {
      final body = {
        'user_id': _userViewModel.user.user_id,
        'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final response = await _api.create(body);

      if (response.success) {
        return LiveTalk.fromJson(response.data);
      } else {
        print('❌ LiveTalk 작성 실패: ${response.error}');
        return null;
      }
    } catch (e) {
      print('❌ LiveTalk 작성 에러: $e');
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 게시글 수정
  Future<bool> updatePost({
    required int livetalkId,
    required String description,
    String? imageUrl,
  }) async {
    isSubmitting.value = true;
    try {
      final body = {
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
        'description': description,
        'image_url': imageUrl ?? '',  // null이면 빈 문자열로 전송하여 이미지 삭제
      };

      final response = await _api.update(body);

      if (response.success) {
        liveTalkDetail.value = LiveTalk.fromJson(response.data);
        return true;
      } else {
        print('❌ LiveTalk 수정 실패: ${response.error}');
        return false;
      }
    } catch (e) {
      print('❌ LiveTalk 수정 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 게시글 삭제
  Future<bool> deletePost(int livetalkId) async {
    isSubmitting.value = true;
    try {
      final response = await _api.delete({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        removeFromList(livetalkId);
        return true;
      } else {
        print('❌ LiveTalk 삭제 실패: ${response.error}');
        return false;
      }
    } catch (e) {
      print('❌ LiveTalk 삭제 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 게시글 좋아요 토글 (목록용)
  Future<bool> toggleLike(int livetalkId) async {
    try {
      final response = await _api.toggleLike({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final likeResponse = LiveTalkLikeResponse.fromJson(response.data);
        _updateLiveTalkInList(livetalkId, likeResponse.liked, likeResponse.likeCount);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ LiveTalk 좋아요 토글 에러: $e');
      return false;
    }
  }

  /// 게시글 좋아요 토글 (상세용)
  Future<bool> toggleDetailLike() async {
    if (liveTalkDetail.value == null) return false;

    try {
      final response = await _api.toggleLike({
        'livetalk_id': liveTalkDetail.value!.livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final likeResponse = LiveTalkLikeResponse.fromJson(response.data);
        liveTalkDetail.value!.isLiked = likeResponse.liked;
        liveTalkDetail.value!.likeCount = likeResponse.likeCount;
        liveTalkDetail.refresh();
        // 목록에도 반영
        _updateLiveTalkInList(liveTalkDetail.value!.livetalkId!, likeResponse.liked, likeResponse.likeCount);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ LiveTalk 좋아요 토글 에러: $e');
      return false;
    }
  }

  /// 게시글 신고
  Future<bool> report(int livetalkId) async {
    try {
      final response = await _api.report({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        return true;
      } else {
        print('❌ LiveTalk 신고 실패: ${response.error}');
        return false;
      }
    } catch (e) {
      print('❌ LiveTalk 신고 에러: $e');
      return false;
    }
  }

  // ============================================
  // 3. 댓글 관련
  // ============================================

  /// 댓글 목록 조회 (LiveTalk 객체 기반 - 뷰에서 사용)
  /// [silent] true이면 로딩 인디케이터 없이 조용히 새로고침 (낙관적 UI 후 사용)
  Future<void> fetchCommentsForLiveTalk(LiveTalk liveTalk, {bool silent = false}) async {
    if (!silent) {
      isLoadingComments.value = true;
      commentList.clear();
    }
    currentLiveTalk.value = liveTalk;

    try {
      final response = await _api.fetchCommentList({
        'livetalk_id': liveTalk.livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      print('📝 댓글 조회 응답: success=${response.success}, data type=${response.data.runtimeType}');
      print('📝 댓글 조회 데이터: ${response.data}');

      if (response.success) {
        List<dynamic> results;
        if (response.data is List) {
          results = response.data;
        } else if (response.data is Map) {
          // results 또는 다른 키 확인
          if (response.data['results'] != null) {
            results = response.data['results'];
          } else if (response.data['comments'] != null) {
            results = response.data['comments'];
          } else {
            // Map 자체가 단일 결과인 경우
            results = [];
            print('📝 알 수 없는 Map 구조: ${response.data.keys}');
          }
        } else {
          results = [];
        }
        print('📝 파싱된 댓글 수: ${results.length}');
        commentList.value = results.map((item) => LiveTalkComment.fromJson(item)).toList();
        print('📝 commentList 길이: ${commentList.length}');
      }
    } catch (e) {
      print('❌ 댓글 목록 조회 에러: $e');
    } finally {
      if (!silent) {
        isLoadingComments.value = false;
      }
    }
  }

  /// 댓글 목록 조회 (ID 기반)
  Future<void> fetchComments(int livetalkId) async {
    try {
      final response = await _api.fetchCommentList({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        comments.value = (response.data as List)
            .map((item) => LiveTalkComment.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('❌ 댓글 목록 조회 에러: $e');
    }
  }

  /// 답글 모드 설정
  void setReplyMode(LiveTalkComment comment) {
    isReplyMode.value = true;
    replyTargetComment.value = comment;
  }

  /// 답글 모드 취소
  void cancelReplyMode() {
    isReplyMode.value = false;
    replyTargetComment.value = null;
  }

  /// 댓글 수정 모드 시작
  void startEditCommentMode(LiveTalkComment comment, int commentIndex) {
    // 다른 모드 취소
    cancelReplyMode();
    cancelEditReplyMode();

    isEditCommentMode.value = true;
    editingComment.value = comment;
    editingCommentIndex.value = commentIndex;
    commentController.text = comment.content ?? '';
    _updateCommentButtonState();
  }

  /// 댓글 수정 모드 취소
  void cancelEditCommentMode() {
    isEditCommentMode.value = false;
    editingComment.value = null;
    editingCommentIndex.value = -1;
    commentController.clear();
    isCommentButtonEnabled.value = false;
  }

  /// 답글 수정 모드 시작
  void startEditReplyMode(LiveTalkReply reply, int commentIndex, int replyIndex) {
    // 다른 모드 취소
    cancelReplyMode();
    cancelEditCommentMode();

    isEditReplyMode.value = true;
    editingReply.value = reply;
    editingReplyCommentIndex.value = commentIndex;
    editingReplyIndex.value = replyIndex;
    commentController.text = reply.content ?? '';
    _updateCommentButtonState();
  }

  /// 답글 수정 모드 취소
  void cancelEditReplyMode() {
    isEditReplyMode.value = false;
    editingReply.value = null;
    editingReplyCommentIndex.value = -1;
    editingReplyIndex.value = -1;
    commentController.clear();
    isCommentButtonEnabled.value = false;
  }

  /// 모든 입력 모드 취소
  void cancelAllInputModes() {
    cancelReplyMode();
    cancelEditCommentMode();
    cancelEditReplyMode();
  }

  /// 댓글 수정 실행 (컨트롤러 기반)
  Future<bool> updateCommentFromController() async {
    if (!isEditCommentMode.value || editingComment.value == null) return false;

    final text = commentController.text.trim();
    if (text.isEmpty) return false;

    try {
      final response = await _api.updateComment({
        'comment_id': editingComment.value!.commentId,
        'user_id': _userViewModel.user.user_id,
        'content': text,
      });

      if (response.success) {
        // commentList 업데이트
        if (editingCommentIndex.value >= 0 && editingCommentIndex.value < commentList.length) {
          commentList[editingCommentIndex.value].content = text;
          commentList.refresh();
        }

        cancelEditCommentMode();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 댓글 수정 에러: $e');
      return false;
    }
  }

  /// 답글 수정 실행 (컨트롤러 기반)
  Future<bool> updateReplyFromController() async {
    if (!isEditReplyMode.value || editingReply.value == null) return false;

    final text = commentController.text.trim();
    if (text.isEmpty) return false;

    try {
      final response = await _api.updateReply({
        'reply_id': editingReply.value!.replyId,
        'user_id': _userViewModel.user.user_id,
        'content': text,
      });

      if (response.success) {
        // commentList의 해당 답글 업데이트
        if (editingReplyCommentIndex.value >= 0 &&
            editingReplyCommentIndex.value < commentList.length) {
          final comment = commentList[editingReplyCommentIndex.value];
          if (comment.replies != null &&
              editingReplyIndex.value >= 0 &&
              editingReplyIndex.value < comment.replies!.length) {
            comment.replies![editingReplyIndex.value].content = text;
            commentList.refresh();
          }
        }

        cancelEditReplyMode();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 답글 수정 에러: $e');
      return false;
    }
  }

  /// 댓글 작성 (컨트롤러 기반 - 뷰에서 사용)
  Future<bool> createCommentFromController() async {
    if (currentLiveTalk.value == null) return false;

    final text = commentController.text.trim();
    if (text.isEmpty) return false;

    // 낙관적 UI: 임시 댓글을 먼저 추가
    final pendingComment = LiveTalkComment(
      commentId: -DateTime.now().millisecondsSinceEpoch,  // 임시 ID
      livetalkId: currentLiveTalk.value!.livetalkId,
      userId: _userViewModel.user.user_id,
      userInfo: LiveTalkUserInfo(
        userId: _userViewModel.user.user_id,
        displayName: _userViewModel.user.display_name,
        profileImageUrl: _userViewModel.user.profile_image_url_user,
      ),
      content: text,
      likeCount: 0,
      isLiked: false,
      replyCount: 0,
      replies: [],
      isPending: true,  // 게시 중 상태
    );

    commentList.add(pendingComment);
    commentController.clear();
    isCommentButtonEnabled.value = false;

    try {
      final response = await _api.createComment({
        'livetalk_id': currentLiveTalk.value!.livetalkId,
        'user_id': _userViewModel.user.user_id,
        'content': text,
      });

      if (response.success) {
        // 댓글 목록 조용히 새로고침 (임시 댓글이 실제 댓글로 교체됨)
        await fetchCommentsForLiveTalk(currentLiveTalk.value!, silent: true);

        // 피드 목록의 댓글 수 업데이트
        final index = liveTalkList.indexWhere((item) => item.livetalkId == currentLiveTalk.value!.livetalkId);
        if (index != -1) {
          liveTalkList[index].commentCount = (liveTalkList[index].commentCount ?? 0) + 1;
          liveTalkList.refresh();
        }

        return true;
      } else {
        // 실패 시 임시 댓글 제거
        commentList.removeWhere((c) => c.commentId == pendingComment.commentId);
      }
      return false;
    } catch (e) {
      // 에러 시 임시 댓글 제거
      commentList.removeWhere((c) => c.commentId == pendingComment.commentId);
      print('❌ 댓글 작성 에러: $e');
      return false;
    }
  }

  /// 답글 작성 (컨트롤러 기반 - 뷰에서 사용)
  Future<bool> createReplyFromController() async {
    if (replyTargetComment.value == null) return false;

    final text = commentController.text.trim();
    if (text.isEmpty) return false;

    final targetCommentId = replyTargetComment.value!.commentId;

    // 낙관적 UI: 임시 답글을 먼저 추가
    final pendingReply = LiveTalkReply(
      replyId: -DateTime.now().millisecondsSinceEpoch,  // 임시 ID
      commentId: targetCommentId,
      userId: _userViewModel.user.user_id,
      userInfo: LiveTalkUserInfo(
        userId: _userViewModel.user.user_id,
        displayName: _userViewModel.user.display_name,
        profileImageUrl: _userViewModel.user.profile_image_url_user,
      ),
      content: text,
      likeCount: 0,
      isLiked: false,
      isPending: true,  // 게시 중 상태
    );

    // 해당 댓글에 임시 답글 추가
    final commentIndex = commentList.indexWhere((c) => c.commentId == targetCommentId);
    if (commentIndex != -1) {
      commentList[commentIndex].replies ??= [];
      commentList[commentIndex].replies!.add(pendingReply);
      commentList.refresh();
    }

    commentController.clear();
    isCommentButtonEnabled.value = false;
    cancelReplyMode();

    try {
      final response = await _api.createReply({
        'comment_id': targetCommentId,
        'user_id': _userViewModel.user.user_id,
        'content': text,
      });

      if (response.success) {
        // 댓글 목록 조용히 새로고침 (임시 답글이 실제 답글로 교체됨)
        if (currentLiveTalk.value != null) {
          await fetchCommentsForLiveTalk(currentLiveTalk.value!, silent: true);
        }

        return true;
      } else {
        // 실패 시 임시 답글 제거
        if (commentIndex != -1) {
          commentList[commentIndex].replies?.removeWhere((r) => r.replyId == pendingReply.replyId);
          commentList.refresh();
        }
      }
      return false;
    } catch (e) {
      // 에러 시 임시 답글 제거
      if (commentIndex != -1) {
        commentList[commentIndex].replies?.removeWhere((r) => r.replyId == pendingReply.replyId);
        commentList.refresh();
      }
      print('❌ 답글 작성 에러: $e');
      return false;
    }
  }

  /// 댓글 좋아요 토글 (인덱스 기반)
  Future<void> toggleCommentLikeByIndex(int commentIndex) async {
    final comment = commentList[commentIndex];
    final originalIsLiked = comment.isLiked ?? false;
    final originalLikeCount = comment.likeCount ?? 0;

    // Optimistic Update
    comment.isLiked = !originalIsLiked;
    comment.likeCount = originalLikeCount + (comment.isLiked! ? 1 : -1);
    commentList.refresh();

    try {
      final response = await _api.toggleCommentLike({
        'comment_id': comment.commentId,
        'user_id': _userViewModel.user.user_id,
      });

      if (!response.success) {
        // 롤백
        comment.isLiked = originalIsLiked;
        comment.likeCount = originalLikeCount;
        commentList.refresh();
      }
    } catch (e) {
      // 롤백
      comment.isLiked = originalIsLiked;
      comment.likeCount = originalLikeCount;
      commentList.refresh();
      print('toggleCommentLikeByIndex error: $e');
    }
  }

  /// 답글 좋아요 토글 (인덱스 기반 - commentList 사용)
  Future<void> toggleReplyLikeByIndex(int commentIndex, int replyIndex) async {
    final comment = commentList[commentIndex];
    if (comment.replies == null || replyIndex >= comment.replies!.length) return;

    final reply = comment.replies![replyIndex];
    final originalIsLiked = reply.isLiked ?? false;
    final originalLikeCount = reply.likeCount ?? 0;

    // Optimistic Update
    reply.isLiked = !originalIsLiked;
    reply.likeCount = originalLikeCount + (reply.isLiked! ? 1 : -1);
    commentList.refresh();

    try {
      final response = await _api.toggleReplyLike({
        'reply_id': reply.replyId,
        'user_id': _userViewModel.user.user_id,
      });

      if (!response.success) {
        // 롤백
        reply.isLiked = originalIsLiked;
        reply.likeCount = originalLikeCount;
        commentList.refresh();
      }
    } catch (e) {
      // 롤백
      reply.isLiked = originalIsLiked;
      reply.likeCount = originalLikeCount;
      commentList.refresh();
      print('toggleReplyLikeByIndex error: $e');
    }
  }

  /// 댓글 작성
  Future<bool> createComment(int livetalkId, String content) async {
    isSubmitting.value = true;
    try {
      final response = await _api.createComment({
        'livetalk_id': livetalkId,
        'user_id': _userViewModel.user.user_id,
        'content': content,
      });

      if (response.success) {
        final newComment = LiveTalkComment.fromJson(response.data);
        comments.add(newComment);
        // 댓글 수 증가
        if (liveTalkDetail.value != null) {
          liveTalkDetail.value!.commentCount = (liveTalkDetail.value!.commentCount ?? 0) + 1;
          liveTalkDetail.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 댓글 작성 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 댓글 수정
  Future<bool> updateComment(int commentId, String content) async {
    isSubmitting.value = true;
    try {
      final response = await _api.updateComment({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
        'content': content,
      });

      if (response.success) {
        final index = comments.indexWhere((c) => c.commentId == commentId);
        if (index != -1) {
          comments[index] = LiveTalkComment.fromJson(response.data);
          comments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 댓글 수정 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 댓글 삭제
  Future<bool> deleteComment(int commentId) async {
    try {
      final response = await _api.deleteComment({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        comments.removeWhere((c) => c.commentId == commentId);
        // 댓글 수 감소
        if (liveTalkDetail.value != null) {
          liveTalkDetail.value!.commentCount = (liveTalkDetail.value!.commentCount ?? 1) - 1;
          liveTalkDetail.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 댓글 삭제 에러: $e');
      return false;
    }
  }

  /// 댓글 좋아요 토글
  Future<bool> toggleCommentLike(int commentId) async {
    try {
      final response = await _api.toggleCommentLike({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final likeResponse = LiveTalkLikeResponse.fromJson(response.data);
        final index = comments.indexWhere((c) => c.commentId == commentId);
        if (index != -1) {
          comments[index].isLiked = likeResponse.liked;
          comments[index].likeCount = likeResponse.likeCount;
          comments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 댓글 좋아요 토글 에러: $e');
      return false;
    }
  }

  /// 댓글 신고
  Future<bool> reportComment(int commentId) async {
    try {
      final response = await _api.reportComment({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
      });

      return response.success;
    } catch (e) {
      print('❌ 댓글 신고 에러: $e');
      return false;
    }
  }

  // ============================================
  // 4. 답글 관련
  // ============================================

  /// 답글 목록 조회
  Future<List<LiveTalkReply>> fetchReplies(int commentId) async {
    try {
      final response = await _api.fetchReplyList({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        return (response.data as List)
            .map((item) => LiveTalkReply.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ 답글 목록 조회 에러: $e');
      return [];
    }
  }

  /// 답글 작성
  Future<bool> createReply(int commentId, String content) async {
    isSubmitting.value = true;
    try {
      final response = await _api.createReply({
        'comment_id': commentId,
        'user_id': _userViewModel.user.user_id,
        'content': content,
      });

      if (response.success) {
        final newReply = LiveTalkReply.fromJson(response.data);
        // 해당 댓글의 replies에 추가
        final commentIndex = comments.indexWhere((c) => c.commentId == commentId);
        if (commentIndex != -1) {
          comments[commentIndex].replies ??= [];
          comments[commentIndex].replies!.add(newReply);
          comments[commentIndex].replyCount = (comments[commentIndex].replyCount ?? 0) + 1;
          comments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 답글 작성 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 답글 수정
  Future<bool> updateReply(int replyId, String content) async {
    isSubmitting.value = true;
    try {
      final response = await _api.updateReply({
        'reply_id': replyId,
        'user_id': _userViewModel.user.user_id,
        'content': content,
      });

      if (response.success) {
        // 답글 업데이트
        for (var comment in comments) {
          final replyIndex = comment.replies?.indexWhere((r) => r.replyId == replyId) ?? -1;
          if (replyIndex != -1) {
            comment.replies![replyIndex] = LiveTalkReply.fromJson(response.data);
            comments.refresh();
            break;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 답글 수정 에러: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// 답글 삭제 (commentId 포함)
  Future<bool> deleteReplyWithCommentId(int commentId, int replyId) async {
    try {
      final response = await _api.deleteReply({
        'reply_id': replyId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final commentIndex = comments.indexWhere((c) => c.commentId == commentId);
        if (commentIndex != -1) {
          comments[commentIndex].replies?.removeWhere((r) => r.replyId == replyId);
          comments[commentIndex].replyCount = (comments[commentIndex].replyCount ?? 1) - 1;
          comments.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 답글 삭제 에러: $e');
      return false;
    }
  }

  /// 답글 삭제 (replyId만 - 뷰에서 사용)
  Future<bool> deleteReply(int replyId) async {
    try {
      final response = await _api.deleteReply({
        'reply_id': replyId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        // 댓글 목록 새로고침
        if (currentLiveTalk.value != null) {
          await fetchCommentsForLiveTalk(currentLiveTalk.value!);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 답글 삭제 에러: $e');
      return false;
    }
  }

  /// 답글 좋아요 토글
  Future<bool> toggleReplyLike(int replyId) async {
    try {
      final response = await _api.toggleReplyLike({
        'reply_id': replyId,
        'user_id': _userViewModel.user.user_id,
      });

      if (response.success) {
        final likeResponse = LiveTalkLikeResponse.fromJson(response.data);
        // 답글 업데이트
        for (var comment in comments) {
          final replyIndex = comment.replies?.indexWhere((r) => r.replyId == replyId) ?? -1;
          if (replyIndex != -1) {
            comment.replies![replyIndex].isLiked = likeResponse.liked;
            comment.replies![replyIndex].likeCount = likeResponse.likeCount;
            comments.refresh();
            break;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 답글 좋아요 토글 에러: $e');
      return false;
    }
  }

  /// 답글 신고
  Future<bool> reportReply(int replyId) async {
    try {
      final response = await _api.reportReply({
        'reply_id': replyId,
        'user_id': _userViewModel.user.user_id,
      });

      return response.success;
    } catch (e) {
      print('❌ 답글 신고 에러: $e');
      return false;
    }
  }

  // ============================================
  // 5. 유틸리티
  // ============================================

  /// 상세 상태 초기화
  void resetDetail() {
    liveTalkDetail.value = null;
    comments.clear();
    isLoadingDetail.value = false;
    isSubmitting.value = false;
  }

  /// 전체 상태 초기화
  void resetAll() {
    liveTalkList.clear();
    myLiveTalkList.clear();
    nextPageUrl.value = null;
    previousPageUrl.value = null;
    myNextPageUrl.value = null;
    myPreviousPageUrl.value = null;
    totalCount.value = 0;
    myTotalCount.value = 0;
    resetDetail();
  }
}
