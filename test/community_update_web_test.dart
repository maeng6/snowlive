import 'dart:convert';

import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_community.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/view/community/v_communityUpload_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityUpload_web.dart';
import 'package:com.snowlive/web/viewmodel/util/vm_imageController_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

const int _me = 100;
const int _postId = 621;
const String _oldImage = 'https://firebasestorage.example/community/621/0.jpg';

Map<String, dynamic> _detailJson({int author = _me, List<Map<String, dynamic>>? description}) => {
      'community_id': _postId,
      'user_id': author,
      'category_main': '게시판',
      'category_sub': '시즌방',
      'category_sub2': '방 구해요',
      'sns_url': 'https://open.kakao.com/x',
      'title': '원래 제목',
      'thumb_img_url': _oldImage,
      'description': jsonEncode(description ??
          [
            {'insert': '원래 본문\n'},
            {
              'insert': {'image': _oldImage}
            },
            {'insert': '\n'},
          ]),
      'update_time': '2026-10-01T00:00:00Z',
      'upload_time': '2026-10-01T00:00:00Z',
      'views_count': 3,
      'user_info': {'user_id': author, 'display_name': '스노우'},
      'comment_count': 1,
      // 깨진 댓글이 있어도 수정 화면은 열려야 한다(댓글은 떼고 파싱).
      'comments': [
        {'broken': true}
      ],
    };

class _FakeCommunityAPI extends CommunityAPI {
  Map<String, dynamic>? detail;
  bool failDetail = false;
  final List<Map<String, dynamic>> updates = [];
  bool failUpdate = false;

  @override
  Future<ApiResponse> fetchCommunityDetails(int communityId, String userId) async {
    if (failDetail || detail == null) return ApiResponse.error({'detail': 'not found'});
    return ApiResponse.success(detail);
  }

  @override
  Future<ApiResponse> updateCommunity(int communityId, Map<String, dynamic> body) async {
    updates.add(body);
    return failUpdate ? ApiResponse.error({'detail': 'x'}) : ApiResponse.success({});
  }
}

class _FakeImageController extends ImageControllerWeb {
  final List<String?> stamps = [];
  int uploadCalls = 0;
  bool fail = false;

  @override
  Future<List<String>> uploadCommunityImages({
    required List<XFile> files,
    required int pk,
    String? fileStamp,
    Function(String requestType, String error)? onError,
  }) async {
    uploadCalls++;
    stamps.add(fileStamp);
    return [
      for (var i = 0; i < files.length; i++)
        fail ? '' : 'https://firebasestorage.example/${communityImagePath(pk: pk, index: i, fileStamp: fileStamp)}'
    ];
  }
}

void _login() {
  Get.put(UserViewModel()).updateUserModel_data(
      {'user_id': _me, 'date_joined': '2024-01-01T00:00:00Z'});
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('이미지 경로', () {
    test('새 글은 인덱스, 수정은 스탬프를 붙여 기존 사진을 덮어쓰지 않는다', () {
      expect(communityImagePath(pk: 621, index: 0), 'community/621/0.jpg');
      expect(communityImagePath(pk: 621, index: 1, fileStamp: '1700'), 'community/621/1700_1.jpg');
    });
  });

  group('수정 뷰모델', () {
    late _FakeCommunityAPI api;
    late _FakeImageController images;
    late CommunityUploadViewModelWeb vm;

    setUp(() {
      api = _FakeCommunityAPI()..detail = _detailJson();
      images = _FakeImageController();
      vm = CommunityUploadViewModelWeb(api: api, imageController: images);
    });

    test('원글로 폼을 채운다', () async {
      await vm.loadForEdit(communityId: _postId, userId: _me);
      expect(vm.editState, CommunityEditState.ready);
      expect(vm.titleController.text, '원래 제목');
      expect(vm.categorySub, '시즌방');
      expect(vm.categorySub2, '방 구해요');
      expect(vm.quillController.document.toPlainText(), startsWith('원래 본문'));
      expect(vm.canSubmit, isTrue);
    });

    test('남의 글은 권한 없음, 없는 글은 notFound', () async {
      api.detail = _detailJson(author: 999);
      await vm.loadForEdit(communityId: _postId, userId: _me);
      expect(vm.editState, CommunityEditState.forbidden);
      expect(vm.titleController.text, isEmpty);

      api.failDetail = true;
      await vm.loadForEdit(communityId: _postId, userId: _me);
      expect(vm.editState, CommunityEditState.notFound);
    });

    test('사진을 안 바꾸면 업로드 없이 한 번 저장 — 원글 category_main·sns_url 유지, 썸네일은 첫 사진', () async {
      await vm.loadForEdit(communityId: _postId, userId: _me);
      vm.titleController.text = '고친 제목';
      vm.selectCategorySub('자유');

      expect(await vm.submitEdit(userId: _me), isTrue);
      expect(images.uploadCalls, 0);
      expect(api.updates, hasLength(1));
      final body = api.updates.single;
      expect(body['title'], '고친 제목');
      expect(body['category_main'], '게시판');
      expect(body['category_sub'], '자유');
      // 시즌방에서 벗어나면 하위는 placeholder로 돌아간다(새 글과 같은 규칙).
      expect(body['category_sub2'], kCommunityCategorySub2Placeholder);
      expect(body['sns_url'], 'https://open.kakao.com/x');
      expect(body['thumb_img_url'], _oldImage);
      expect(jsonEncode(body['description']), contains(_oldImage));
    });

    test('본문에 사진이 없으면 썸네일은 빈 문자열', () async {
      api.detail = _detailJson(description: [
        {'insert': '글만\n'}
      ]);
      await vm.loadForEdit(communityId: _postId, userId: _me);
      await vm.submitEdit(userId: _me);
      expect(api.updates.single['thumb_img_url'], '');
    });

    test('새 사진은 스탬프 경로로 올리고 본문의 blob 주소를 바꾼다', () async {
      await vm.loadForEdit(communityId: _postId, userId: _me);
      vm.quillController.moveCursorToPosition(0);
      vm.insertImage(XFile('blob:http://localhost/new-1'));

      expect(await vm.submitEdit(userId: _me), isTrue);
      expect(images.uploadCalls, 1);
      expect(images.stamps.single, isNotNull);
      final description = api.updates.single['description'] as String;
      expect(description, isNot(contains('blob:')));
      expect(description, contains('community/$_postId/${images.stamps.single}_0.jpg'));
      expect(description, contains(_oldImage));
      // 새 사진을 맨 앞에 넣었으니 썸네일도 새 사진.
      expect(api.updates.single['thumb_img_url'], contains('${images.stamps.single}_0.jpg'));
    });

    test('사진 업로드가 실패하면 저장하지 않는다(깨진 blob 주소가 남지 않게)', () async {
      images.fail = true;
      await vm.loadForEdit(communityId: _postId, userId: _me);
      vm.insertImage(XFile('blob:http://localhost/new-1'));
      expect(await vm.submitEdit(userId: _me), isFalse);
      expect(api.updates, isEmpty);
    });

    test('새 글 폼으로 돌아가면 수정 상태가 비워진다', () async {
      await vm.loadForEdit(communityId: _postId, userId: _me);
      vm.resetForm();
      expect(vm.editState, CommunityEditState.none);
      expect(vm.titleController.text, isEmpty);
      expect(await vm.submitEdit(userId: _me), isFalse);
    });
  });

  group('화면', () {
    late _FakeCommunityAPI api;

    /// 본문 에디터(Quill)는 웹 전용 임베드 빌더를 써서 VM 테스트 러너에서는 그 자리만
    /// UnsupportedError로 그려진다(웹에서는 정상). 그 예외만 허용하고 나머지는 없어야 한다.
    void expectNoErrorsExceptWebEditor(WidgetTester tester) {
      Object? e;
      while ((e = tester.takeException()) != null) {
        expect('$e', contains('editorWebBuilders'), reason: '에디터 외 예외: $e');
      }
    }

    Future<void> pumpForm(WidgetTester tester, double width, {required bool isEdit}) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      Get.put(CommunityUploadViewModelWeb(api: api, imageController: _FakeImageController()));
      Get.put(CommunityListPaginationViewModelWeb());
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: isEdit ? '/community-update?id=$_postId' : '/community-upload',
        getPages: [
          GetPage(name: '/community-update', page: () => const Scaffold(body: CommunityUploadViewWeb(isEdit: true))),
          GetPage(name: '/community-upload', page: () => const Scaffold(body: CommunityUploadViewWeb())),
        ],
      ));
      await tester.pump(); // 첫 프레임 뒤 원글 조회
      await tester.pump(const Duration(milliseconds: 300));
    }

    setUp(() {
      api = _FakeCommunityAPI()..detail = _detailJson();
    });

    for (final width in <double>[1440, 800, 375]) {
      testWidgets('${width.toInt()}폭 수정: 원글이 채워지고 `수정 완료`만, 임시저장 없음', (tester) async {
        _login();
        await pumpForm(tester, width, isEdit: true);
        expectNoErrorsExceptWebEditor(tester);
        expect(find.text('게시글 수정'), findsOneWidget);
        expect(find.text('수정 완료'), findsOneWidget);
        expect(find.text('임시저장'), findsNothing);
        expect(find.widgetWithText(TextField, '원래 제목'), findsOneWidget);
      });

      testWidgets('${width.toInt()}폭 새 글은 그대로: `게시글 작성` · 임시저장 · 작성 완료', (tester) async {
        _login();
        await pumpForm(tester, width, isEdit: false);
        expectNoErrorsExceptWebEditor(tester);
        expect(find.text('게시글 작성'), findsOneWidget);
        expect(find.text('작성 완료'), findsOneWidget);
        expect(find.text('임시저장'), findsOneWidget);
      });
    }

    testWidgets('남의 글이면 안내만, 저장 버튼 없음', (tester) async {
      _login();
      api.detail = _detailJson(author: 999);
      await pumpForm(tester, 1440, isEdit: true);
      expectNoErrorsExceptWebEditor(tester);
      expect(find.text('내가 쓴 글만 수정할 수 있어요.'), findsOneWidget);
      expect(find.text('수정 완료'), findsNothing);
    });

    testWidgets('비로그인이면 로그인 안내', (tester) async {
      Get.put(UserViewModel());
      await pumpForm(tester, 1440, isEdit: true);
      expectNoErrorsExceptWebEditor(tester);
      expect(find.text('로그인이 필요해요.'), findsOneWidget);
      expect(find.text('수정 완료'), findsNothing);
    });
  });

  test('⋯ 메뉴에 수정하기가 있다', () {
    expect(WebMoreAction.edit.label, '수정하기');
  });
}
