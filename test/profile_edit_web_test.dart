import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_login.dart';
import 'package:com.snowlive/core/api/api_user.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/view/profile/v_profileEdit_web.dart';
import 'package:com.snowlive/web/view/profile/w_profile_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/profile/vm_profileEdit_web.dart';
import 'package:com.snowlive/web/viewmodel/util/vm_imageController_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_drawer.dart';
import 'package:com.snowlive/core/model/m_friendDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

const int _me = 100;
const String _oldPhoto =
    'https://firebasestorage.googleapis.com/v0/b/x/o/user_profile%2Fuid_1.jpg?alt=media';

Map<String, dynamic> _userJson({String name = '스노우', String? photo = _oldPhoto}) => {
      'user_id': _me,
      'uid': 'firebase-uid',
      'display_name': name,
      'profile_image_url_user': photo,
      'state_msg': '오늘도 출근',
      'favorite_resort': 13, // index 12
      'instant_resort': 5,
      'skiorboard': '스노보드',
      'sex': '남자',
      'hide_profile': false,
      'date_joined': '2024-01-01T00:00:00Z',
    };

class _FakeUserAPI extends UserAPI {
  Map<String, dynamic> user = _userJson();
  bool failGet = false;
  bool failUpdate = false;
  final List<Map<String, dynamic>> updates = [];

  @override
  Future<ApiResponse> getUserInfo(int user_id, {String? fcm_token}) async =>
      failGet ? ApiResponse.error({'detail': 'x'}) : ApiResponse.success(user);

  @override
  Future<ApiResponse> updateUserInfo(Map<String, dynamic> body) async {
    updates.add(body);
    if (failUpdate) return ApiResponse.error({'detail': 'x'});
    user = {...user, ...body, 'favorite_resort': body['favorite_resort']};
    return ApiResponse.success(user);
  }
}

class _FakeLoginAPI extends LoginAPI {
  final Set<String> taken = {'중복닉'};
  final List<String> checked = [];

  @override
  Future<ApiResponse> checkDisplayName(Map<String, dynamic> body) async {
    final name = body['display_name'] as String;
    checked.add(name);
    return taken.contains(name) ? ApiResponse.error({'detail': 'taken'}) : ApiResponse.success({});
  }
}

class _FakeImageController extends ImageControllerWeb {
  bool fail = false;
  int calls = 0;

  @override
  Future<String> uploadProfileImage({
    required XFile file,
    required String uid,
    Function(String requestType, String error)? onError,
  }) async {
    calls++;
    return fail ? '' : 'https://firebasestorage.googleapis.com/v0/b/x/o/user_profile%2F${uid}_new.jpg';
  }
}

void _login() {
  Get.put(UserViewModel()).updateUserModel_data(_userJson());
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('뷰모델', () {
    late _FakeUserAPI userApi;
    late _FakeLoginAPI loginApi;
    late _FakeImageController images;
    late List<String> deleted;
    late ProfileEditViewModelWeb vm;

    setUp(() {
      _login();
      userApi = _FakeUserAPI();
      loginApi = _FakeLoginAPI();
      images = _FakeImageController();
      deleted = [];
      vm = ProfileEditViewModelWeb(
        userApi: userApi,
        loginApi: loginApi,
        imageController: images,
        deleteStorageFile: (url) async => deleted.add(url),
      )..onInit();
    });

    test('최신 내 정보로 폼을 채운다', () async {
      await vm.load();
      expect(vm.loadState, ProfileEditLoadState.ready);
      expect(vm.nicknameController.text, '스노우');
      expect(vm.stateMsgController.text, '오늘도 출근');
      expect(vm.imageUrl, _oldPhoto);
      expect(vm.resortIndex, 12);
      expect(vm.skiOrBoard, '스노보드');
      expect(vm.sex, '남자');
      expect(vm.hideProfile, isFalse);
      expect(vm.canSave, isTrue);
    });

    test('불러오기 실패는 failed', () async {
      userApi.failGet = true;
      await vm.load();
      expect(vm.loadState, ProfileEditLoadState.failed);
      expect(vm.canSave, isFalse);
    });

    test('닉네임 그대로면 중복검사 없이 앱과 같은 바디로 저장, 사진은 안 지운다', () async {
      await vm.load();
      vm.stateMsgController.text = '  새 상태  ';
      vm.selectResort(2);
      vm.setHideProfile(true);

      expect(await vm.save(), ProfileEditResult.success);
      expect(loginApi.checked, isEmpty);
      expect(images.calls, 0);
      expect(deleted, isEmpty);
      final body = userApi.updates.single;
      expect(body, {
        'user_id': _me,
        'display_name': '스노우',
        'state_msg': '새 상태',
        'profile_image_url_user': _oldPhoto,
        'hide_profile': true,
        'instant_resort': 5, // 기존값 유지
        'favorite_resort': 3, // index + 1
        'sex': '남자',
        'skiorboard': '스노보드',
      });
    });

    test('바꾼 닉네임이 중복이면 저장하지 않고 필드 아래 문구', () async {
      await vm.load();
      vm.nicknameController.text = '중복닉';
      expect(await vm.save(), ProfileEditResult.nicknameTaken);
      expect(vm.nicknameError, '이미 사용 중인 닉네임이에요.');
      expect(userApi.updates, isEmpty);
      // 다시 고치면 문구가 사라진다.
      vm.nicknameController.text = '새닉';
      expect(vm.nicknameError, isNull);
      expect(await vm.save(), ProfileEditResult.success);
      expect(loginApi.checked, ['중복닉', '새닉']);
    });

    test('새 사진: 먼저 올리고 저장 성공 후에야 이전 사진 파일을 지운다', () async {
      await vm.load();
      vm.pickImage(XFile('blob:http://localhost/p'));
      expect(await vm.save(), ProfileEditResult.success);
      expect(images.calls, 1);
      expect(userApi.updates.single['profile_image_url_user'], contains('firebase-uid_new.jpg'));
      expect(deleted, [_oldPhoto]);
    });

    test('사진 업로드 실패면 저장하지 않고 이전 사진도 그대로', () async {
      images.fail = true;
      await vm.load();
      vm.pickImage(XFile('blob:http://localhost/p'));
      expect(await vm.save(), ProfileEditResult.imageFailed);
      expect(userApi.updates, isEmpty);
      expect(deleted, isEmpty);
    });

    test('저장이 실패하면 이전 사진을 지우지 않는다', () async {
      userApi.failUpdate = true;
      await vm.load();
      vm.removeImage();
      expect(await vm.save(), ProfileEditResult.failed);
      expect(deleted, isEmpty);
    });

    test('사진 지우기 → 빈 주소(기본 이미지)로 저장 + 이전 파일 삭제', () async {
      await vm.load();
      vm.removeImage();
      expect(await vm.save(), ProfileEditResult.success);
      expect(userApi.updates.single['profile_image_url_user'], '');
      expect(deleted, [_oldPhoto]);
    });

    test('외부 주소(소셜 기본 사진 등)는 지우지 않는다', () async {
      userApi.user = _userJson(photo: 'https://k.kakaocdn.net/profile.jpg');
      await vm.load();
      vm.removeImage();
      await vm.save();
      expect(deleted, isEmpty);
    });

    test('닉네임이 비면 저장 불가', () async {
      await vm.load();
      vm.nicknameController.text = '';
      expect(vm.canSave, isFalse);
    });
  });

  group('화면', () {
    Future<void> pumpEdit(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      Get.put(ProfileEditViewModelWeb(
        userApi: _FakeUserAPI(),
        loginApi: _FakeLoginAPI(),
        imageController: _FakeImageController(),
        deleteStorageFile: (_) async {},
      ));
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: ProfileEditViewWeb())));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    for (final width in <double>[1440, 800, 375]) {
      testWidgets('${width.toInt()}폭: 내 정보가 채워지고 `저장`이 있다', (tester) async {
        _login();
        await pumpEdit(tester, width);
        // 프로필 사진은 테스트 HttpClient가 400을 준다 → 이미지 로딩 예외만 비운다.
        Object? e;
        while ((e = tester.takeException()) != null) {
          expect('$e', contains('HTTP request failed'), reason: '$e');
        }
        expect(find.text('프로필 편집'), findsOneWidget);
        expect(find.text('저장'), findsOneWidget);
        expect(find.widgetWithText(TextField, '스노우'), findsOneWidget);
        expect(find.text('휘닉스파크'), findsOneWidget);
        expect(find.text('프로필 비공개'), findsOneWidget);
      });
    }

    testWidgets('비로그인이면 로그인 안내, 저장 없음', (tester) async {
      Get.put(UserViewModel());
      await pumpEdit(tester, 1440);
      expect(find.text('로그인이 필요해요.'), findsOneWidget);
      expect(find.text('저장'), findsNothing);
    });
  });

  group('프로필 헤더', () {
    final info = FriendUserInfo.fromJson({
      'user_id': _me,
      'display_name': '스노우',
      'profile_image_url_user': null,
      'favorite_resort': '휘닉스파크',
      'favorite_resort_id': 13,
      'within_boundary': false,
      'reveal_wb': true,
      'hide_profile': false,
      'are_we_friend': false,
      'best_friend': false,
      'skiorboard': '스노보드',
      'sex': '남자',
    });

    Future<void> pumpHeader(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ProfileHeaderWeb(
            info: info,
            action: const Text('PC 액션'),
            mobileAction: const Text('모바일 액션'),
          ),
        ),
      ));
    }

    testWidgets('모바일은 정보 아래 mobileAction, 넓은 폭은 오른쪽 action', (tester) async {
      await pumpHeader(tester, 375);
      expect(find.text('모바일 액션'), findsOneWidget);
      expect(find.text('PC 액션'), findsNothing);
      expect(tester.getTopLeft(find.text('모바일 액션')).dy,
          greaterThan(tester.getBottomLeft(find.text('스노우')).dy));

      await pumpHeader(tester, 1440);
      expect(find.text('PC 액션'), findsOneWidget);
      expect(find.text('모바일 액션'), findsNothing);
    });
  });

  testWidgets('드로어 계정 그룹에 멤버십 업그레이드가 없다(기획 전 숨김)', (tester) async {
    _login();
    tester.view.physicalSize = const Size(375, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: WebGnbMenuPanel(onClose: () {}))));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('마이페이지'), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
    expect(find.text('멤버십 업그레이드'), findsNothing);
  });
}
