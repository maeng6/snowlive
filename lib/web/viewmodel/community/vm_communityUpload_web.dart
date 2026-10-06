import 'dart:convert';

import 'package:com.snowlive/core/api/api_community.dart';
import 'package:com.snowlive/core/model/m_communityDetail.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart' as delta;
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/util/vm_imageController_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// 게시판 종류(상위) 선택지. 목록 탭 enum을 단일 출처로 삼는다(`전체`는 제외).
final List<String> kCommunityCategorySubList = CommunityCategoryTab.values
    .map((tab) => tab.categorySub)
    .whereType<String>()
    .toList();

/// 시즌방을 골랐을 때만 나오는 하위 선택지.
/// (모바일 lib/widget/w_category_sub2_commu_bulletin_room.dart와 동일)
const List<String> kCommunityCategorySub2List = ['방 임대', '방 구해요', '멤버모집'];

const String kCommunityCategorySubPlaceholder = '상위 카테고리';
const String kCommunityCategorySub2Placeholder = '하위 카테고리';

/// 하위 카테고리가 필요한 유일한 상위 값.
const String kCommunityCategoryRoom = '시즌방';

/// 커뮤니티는 게시판/이벤트 두 갈래인데 웹은 게시판만 노출한다(목록도 이 값으로 조회).
const String _kCategoryMain = '게시판';

/// 수정 화면에서 원글을 불러온 상태.
enum CommunityEditState {
  /// 새 글 모드(수정 아님).
  none,
  loading,
  ready,

  /// 글이 없거나(삭제됨) 조회 실패.
  notFound,

  /// 내 글이 아님.
  forbidden,
}

/// 웹 커뮤니티 게시글 작성·수정 뷰모델.
///
/// core의 [CommunityUploadViewModel]은 `dart:io`/`flutter_image_compress`/
/// `File.exists`에 의존해서 **웹에서 컴파일되지 않는다**. 그래서 웹 전용으로 둔다.
/// 수정도 같은 폼을 쓰므로(디자인이 올리기와 같다) 같은 뷰모델에 둔다.
class CommunityUploadViewModelWeb extends GetxController {
  CommunityUploadViewModelWeb({CommunityAPI? api, ImageControllerWeb? imageController})
      : _api = api ?? CommunityAPI(),
        _imageController = imageController ?? Get.put(ImageControllerWeb());

  final CommunityAPI _api;
  final ImageControllerWeb _imageController;

  final TextEditingController titleController = TextEditingController();
  final quill.QuillController quillController = quill.QuillController.basic();
  final FocusNode editorFocusNode = FocusNode();
  final ScrollController editorScrollController = ScrollController();

  final RxString _categorySub = kCommunityCategorySubPlaceholder.obs;
  final RxString _categorySub2 = kCommunityCategorySub2Placeholder.obs;
  final RxBool _isTitleWritten = false.obs;
  final RxBool _isSubmitting = false.obs;

  // ── 수정 모드 ──
  final Rx<CommunityEditState> _editState = CommunityEditState.none.obs;
  int? _editId;

  /// 웹 폼에 없는 값은 원글 그대로 다시 보낸다(PUT이라 빠지면 지워질 수 있다).
  String? _originalCategoryMain;
  String? _originalSnsUrl;

  CommunityEditState get editState => _editState.value;

  /// 본문에 삽입된 이미지: **blob URL → 원본 XFile**.
  /// 제출할 때 이 맵으로 원본을 찾아 업로드한다. Delta에 남은 blob URL에서
  /// 바이트를 되읽는 것보다 확실하고, 이미 업로드된 http URL과도 안 섞인다.
  final Map<String, XFile> _pendingImages = {};

  String get categorySub => _categorySub.value;
  String get categorySub2 => _categorySub2.value;
  bool get isTitleWritten => _isTitleWritten.value;
  bool get isSubmitting => _isSubmitting.value;
  bool get needsCategorySub2 => _categorySub.value == kCommunityCategoryRoom;

  /// 제목 + 상위 카테고리(+ 시즌방이면 하위까지)가 채워져야 등록할 수 있다.
  /// 본문은 필수가 아니다(모바일 앱과 동일).
  bool get canSubmit =>
      _isTitleWritten.value &&
      _categorySub.value != kCommunityCategorySubPlaceholder &&
      (!needsCategorySub2 || _categorySub2.value != kCommunityCategorySub2Placeholder);

  @override
  void onClose() {
    titleController.dispose();
    quillController.dispose();
    editorFocusNode.dispose();
    editorScrollController.dispose();
    super.onClose();
  }

  void changeTitleWritten(bool value) => _isTitleWritten.value = value;

  void selectCategorySub(String value) {
    _categorySub.value = value;
    // 시즌방에서 벗어나면 하위 값은 의미가 없다. 남겨두면 다시 시즌방을 골랐을 때
    // 이전 선택이 되살아나 사용자가 고르지 않은 값이 그대로 전송된다.
    if (value != kCommunityCategoryRoom) {
      _categorySub2.value = kCommunityCategorySub2Placeholder;
    }
  }

  void selectCategorySub2(String value) => _categorySub2.value = value;

  /// 편집 화면을 떠난 뒤에도 fenix로 뷰모델이 살아남으므로, 다음 진입에서
  /// 이전 글이 남지 않도록 명시적으로 비운다.
  void resetForm() {
    _editState.value = CommunityEditState.none;
    _editId = null;
    _originalCategoryMain = null;
    _originalSnsUrl = null;
    titleController.clear();
    quillController.document = quill.Document();
    _categorySub.value = kCommunityCategorySubPlaceholder;
    _categorySub2.value = kCommunityCategorySub2Placeholder;
    _isTitleWritten.value = false;
    _pendingImages.clear();
  }

  /// 사진 선택 → 커서 위치에 삽입. 실제 업로드는 제출할 때 한 번에 한다
  /// (Storage 경로에 게시글 pk가 필요한데, pk는 생성 API 응답으로만 나온다).
  Future<void> pickAndInsertImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    insertImage(picked);
  }

  /// 고른 사진을 커서 위치에 넣는다(업로드는 제출 때).
  void insertImage(XFile picked) {
    _pendingImages[picked.path] = picked;

    final index = quillController.selection.baseOffset;
    final length = quillController.selection.extentOffset - index;
    quillController
      ..skipRequestKeyboard = true
      ..replaceText(index, length, quill.BlockEmbed.image(picked.path), null)
      ..moveCursorToPosition(index + 1);
  }

  /// 등록. 성공하면 새 게시글 id, 실패하면 null.
  ///
  /// 이미지가 있으면 모바일 앱과 같은 2단계다 — 생성으로 pk를 받아야 Storage
  /// 경로(`community/$pk/`)가 정해지기 때문. 이미지가 없으면 1회 호출로 끝낸다.
  Future<int?> submit({required int userId}) async {
    if (_isSubmitting.value) return null;
    _isSubmitting.value = true;
    try {
      final ops = quillController.document.toDelta().toList();
      final localImages = <String>[
        for (final op in ops)
          if (_localImageUrlOf(op) case final url?) url,
      ];

      final baseBody = <String, dynamic>{
        'user_id': userId.toString(),
        'category_main': _kCategoryMain,
        'category_sub': _categorySub.value,
        // 시즌방이 아니면 서버에 문자열 '하위 카테고리'가 그대로 저장된다.
        // 앱이 그렇게 보내고 실데이터도 전부 그 상태라 웹도 맞춘다.
        'category_sub2': _categorySub2.value,
        'title': titleController.text.trim(),
      };

      if (localImages.isEmpty) {
        final pk = await _create({
          ...baseBody,
          'thumb_img_url': null,
          'description': jsonEncode(ops.map((op) => op.toJson()).toList()),
        });
        return pk;
      }

      final pk = await _create({
        ...baseBody,
        'thumb_img_url': null,
        // 본문은 이미지 URL을 확정한 뒤 수정 호출로 채운다. 여기서 blob URL을
        // 실어 보내면 업로드가 실패했을 때 못 여는 링크가 그대로 저장된다.
        'description': jsonEncode([
          {'insert': '\n'}
        ]),
      });
      if (pk == null) return null;

      final files = localImages.map((url) => _pendingImages[url]!).toList();
      final uploaded = await _imageController.uploadCommunityImages(files: files, pk: pk);

      final urlMap = <String, String>{};
      for (var i = 0; i < localImages.length; i++) {
        // 실패한 자리는 빈 문자열로 오므로 치환하지 않고 그대로 둔다.
        if (i < uploaded.length && uploaded[i].isNotEmpty) {
          urlMap[localImages[i]] = uploaded[i];
        }
      }

      final replaced = _replaceImageUrls(ops, urlMap);
      final ok = await _update(pk, {
        'user_id': userId.toString(),
        'thumb_img_url': uploaded.firstWhere((url) => url.isNotEmpty, orElse: () => ''),
        'description': jsonEncode(replaced),
      });
      // 본문 저장에 실패해도 글 자체는 이미 만들어졌다. id를 돌려주되 호출자가
      // 안내할 수 있도록 로그를 남긴다.
      if (!ok) debugPrint('[CommunityUploadWeb] 본문 저장 실패 (pk=$pk)');
      return pk;
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 수정할 글을 불러와 폼을 채운다. 상세 화면처럼 **URL의 id로 직접 조회**하므로
  /// 수정 화면에서 새로고침해도 폼이 비지 않는다(조회수는 올리지 않는다).
  Future<void> loadForEdit({required int communityId, required int userId}) async {
    resetForm();
    _editId = communityId;
    _editState.value = CommunityEditState.loading;
    try {
      final response = await _api.fetchCommunityDetails(communityId, userId.toString());
      if (_editId != communityId) return; // 그 사이 다른 글로 바뀜
      if (!response.success || response.data is! Map) {
        _editState.value = CommunityEditState.notFound;
        return;
      }
      // 댓글은 필요 없고, 댓글 한 건이 깨지면 fromJson 전체가 실패하므로 떼고 넘긴다
      // (상세 뷰모델과 같은 방어).
      final map = Map<String, dynamic>.from(response.data as Map)..remove('comments');
      final detail = CommunityDetailModel.fromJson(map);
      if (detail.userId != userId) {
        _editState.value = CommunityEditState.forbidden;
        return;
      }

      titleController.text = detail.title ?? '';
      _isTitleWritten.value = titleController.text.trim().isNotEmpty;
      final sub = detail.categorySub;
      _categorySub.value = (sub != null && kCommunityCategorySubList.contains(sub))
          ? sub
          : kCommunityCategorySubPlaceholder;
      final sub2 = detail.categorySub2;
      _categorySub2.value = (sub2 != null && kCommunityCategorySub2List.contains(sub2))
          ? sub2
          : kCommunityCategorySub2Placeholder;
      // 원글 Document를 그대로 물리면 편집이 상세 화면 모델까지 바꾼다 → Delta로 복사.
      final original = detail.description ?? quill.Document();
      quillController.document = quill.Document.fromDelta(original.toDelta());
      _originalCategoryMain = detail.categoryMain;
      _originalSnsUrl = detail.snsUrl;
      _editState.value = CommunityEditState.ready;
    } catch (e) {
      debugPrint('[CommunityUploadWeb] 수정 원글 조회 실패: $e');
      if (_editId == communityId) _editState.value = CommunityEditState.notFound;
    }
  }

  /// 수정 저장. 새로 넣은 사진만 올리고(**고유 파일명** — 기존 사진을 덮어쓰지 않게),
  /// 본문의 blob 주소를 바꾼 뒤 한 번에 저장한다.
  ///
  /// 앱은 본문을 `임시내용`으로 먼저 저장한 뒤 다시 저장하는 2단계라 중간에 실패하면
  /// 본문이 날아간다. 수정은 pk를 이미 알아서 업로드부터 하면 저장이 1회로 끝난다.
  Future<bool> submitEdit({required int userId}) async {
    final pk = _editId;
    if (pk == null || _editState.value != CommunityEditState.ready) return false;
    if (_isSubmitting.value) return false;
    _isSubmitting.value = true;
    try {
      final ops = quillController.document.toDelta().toList();
      final localImages = <String>[
        for (final op in ops)
          if (_localImageUrlOf(op) case final url?) url,
      ];

      var description = ops.map((op) => Map<String, dynamic>.from(op.toJson())).toList();
      if (localImages.isNotEmpty) {
        final files = localImages.map((url) => _pendingImages[url]!).toList();
        final uploaded = await _imageController.uploadCommunityImages(
          files: files,
          pk: pk,
          fileStamp: '${DateTime.now().millisecondsSinceEpoch}',
        );
        final urlMap = <String, String>{};
        for (var i = 0; i < localImages.length; i++) {
          if (i < uploaded.length && uploaded[i].isNotEmpty) {
            urlMap[localImages[i]] = uploaded[i];
          }
        }
        // 올리지 못한 사진이 있으면 저장하지 않는다 — blob 주소가 저장되면 다른 기기에서
        // 못 여는 깨진 이미지가 남는다. 사용자는 그대로 다시 시도할 수 있다.
        if (urlMap.length != localImages.length) return false;
        description = _replaceImageUrls(ops, urlMap);
      }

      return await _update(pk, {
        'user_id': userId.toString(),
        'category_main': _originalCategoryMain ?? _kCategoryMain,
        'category_sub': _categorySub.value,
        // 새 글과 같은 규칙 — 시즌방이 아니면 '하위 카테고리' 문자열 그대로.
        'category_sub2': _categorySub2.value,
        'title': titleController.text.trim(),
        if (_originalSnsUrl != null) 'sns_url': _originalSnsUrl,
        'thumb_img_url': firstImageUrl(description) ?? '',
        'description': jsonEncode(description),
      });
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 본문(Delta JSON) 첫 이미지 주소 — 목록 썸네일(`thumb_img_url`). 앱과 같은 규칙.
  @visibleForTesting
  static String? firstImageUrl(List<Map<String, dynamic>> ops) {
    for (final op in ops) {
      final insert = op['insert'];
      if (insert is Map && insert['image'] is String) return insert['image'] as String;
    }
    return null;
  }

  /// 아직 업로드되지 않은 로컬 이미지(blob)면 그 URL, 아니면 null.
  String? _localImageUrlOf(delta.Operation op) {
    final data = op.data;
    if (data is! Map) return null;
    final source = data['image'];
    if (source is! String) return null;
    return _pendingImages.containsKey(source) ? source : null;
  }

  List<Map<String, dynamic>> _replaceImageUrls(
    List<delta.Operation> ops,
    Map<String, String> urlMap,
  ) {
    return ops.map((op) {
      final json = Map<String, dynamic>.from(op.toJson());
      final insert = json['insert'];
      if (insert is Map && insert['image'] is String) {
        final uploadedUrl = urlMap[insert['image']];
        if (uploadedUrl != null) {
          json['insert'] = {...insert, 'image': uploadedUrl};
        }
      }
      return json;
    }).toList();
  }

  Future<int?> _create(Map<String, dynamic> body) async {
    try {
      final response = await _api.createCommunityPost(body);
      if (response.success) return response.data['community_id'] as int?;
      debugPrint('[CommunityUploadWeb] 생성 실패: ${response.error}');
    } catch (e) {
      debugPrint('[CommunityUploadWeb] 생성 예외: $e');
    }
    return null;
  }

  Future<bool> _update(int pk, Map<String, dynamic> body) async {
    try {
      final response = await _api.updateCommunity(pk, body);
      if (response.success) return true;
      debugPrint('[CommunityUploadWeb] 수정 실패: ${response.error}');
    } catch (e) {
      debugPrint('[CommunityUploadWeb] 수정 예외: $e');
    }
    return false;
  }
}
