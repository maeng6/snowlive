# PaceFace 연동 기능 구현 가이드 (Snowlive 측)

## Context

PaceFace 앱에서 "스노우라이브와 연동하기" 기능이 이미 구현되어 있다.
Snowlive 앱에서는 PaceFace가 보낸 딥링크를 수신하고, 자신의 user_id를 콜백으로 돌려주는 역할을 해야 한다.

- 커스텀 URL 스킴 기반 앱간 통신
- PaceFace 패키지: `com.paceface` / Snowlive 패키지: `com.snowlive`
- 현재 Snowlive에는 딥링크 설정이 없는 상태

---

## 연동 플로우 (전체)

```
[PaceFace 설정] → "스노우라이브와 연동하기" 탭
  → snowlive://paceface-link?paceface_user_id=XXX 열기
  → [Snowlive 앱] ★ 여기부터 구현 ★
       → 로그인된 user_id 확인 (SecureStorage에서 읽기)
       → paceface://snowlive-callback?snowlive_user_id=YYY 열기
  → [PaceFace 앱] 콜백 수신 → API 호출 → 연동 완료
```

**Snowlive가 할 일: `snowlive://paceface-link` 수신 → `paceface://snowlive-callback` 전송**

---

## Step 1: `pubspec.yaml` — `app_links` 패키지 추가

`url_launcher`는 이미 있음 (^6.3.1). 아래만 추가:

```yaml
# Deep Linking
app_links: ^6.3.2
```

추가 위치: `url_launcher` 아래.

---

## Step 2: iOS 설정

**파일:** `ios/Runner/Info.plist`

### 2-1. CFBundleURLTypes에 `snowlive` 스킴 dict 추가

기존 Google Sign-In 스킴 dict 아래에 추가:

```xml
<dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
        <string>snowlive</string>
    </array>
</dict>
```

### 2-2. LSApplicationQueriesSchemes에 `paceface` 추가

현재 빈 배열 `<array/>`을 아래로 교체:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>paceface</string>
</array>
```

---

## Step 3: Android 설정

**파일:** `android/app/src/main/AndroidManifest.xml`

### 3-1. MainActivity에 intent-filter 추가

기존 FLUTTER_NOTIFICATION_CLICK intent-filter 아래에 추가:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="snowlive" />
</intent-filter>
```

### 3-2. `<queries>`에 paceface 패키지 추가

현재 queries 섹션이 없으면 `</application>` 뒤에 추가:

```xml
<queries>
    <package android:name="com.paceface" />
</queries>
```

이미 queries가 있으면 그 안에 `<package android:name="com.paceface" />` 추가.

---

## Step 4: 딥링크 핸들링 서비스 (신규 파일)

**파일 (신규):** `lib/service/deep_link_service.dart`

### 동작 로직

1. `AppLinks`로 `snowlive://` 스킴의 URI 수신 리스닝
2. `snowlive://paceface-link?paceface_user_id=XXX` 수신 시:
   - SecureStorage에서 snowlive의 `user_id` 읽기
   - user_id가 있으면 (로그인 상태) → `paceface://snowlive-callback?snowlive_user_id={user_id}` 열기
   - user_id가 없으면 (비로그인) → 무시

### 기존 패턴 참고

snowlive 프로젝트의 기존 패턴을 따라야 한다:

- SecureStorage 접근: `getSecureStorage()` 함수 사용 (`lib/util/secure_storage_helper.dart`)
- user_id 읽기: `await getSecureStorage().read(key: 'user_id')`
- URL 열기: `url_launcher` 패키지의 `launchUrl()` 사용
- GetxService 상속, `onInit`/`onClose` 패턴

### 구현 코드

```dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:com.snowlive/util/secure_storage_helper.dart';
// ↑ import 경로는 프로젝트의 실제 패키지명에 맞춰 수정

class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void onInit() {
    super.onInit();
    _appLinks = AppLinks();
    _listenDeepLinks();
    _handleInitialLink();
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _onUri(uri);
    } catch (_) {}
  }

  void _listenDeepLinks() {
    _sub = _appLinks.uriLinkStream.listen(_onUri);
  }

  void _onUri(Uri uri) {
    if (uri.scheme == 'snowlive' && uri.host == 'paceface-link') {
      _handlePacefaceLink();
    }
  }

  Future<void> _handlePacefaceLink() async {
    final userIdStr = await getSecureStorage().read(key: 'user_id');
    if (userIdStr == null || userIdStr.isEmpty) return;

    final callbackUri = Uri.parse(
      'paceface://snowlive-callback?snowlive_user_id=$userIdStr',
    );
    await launchUrl(callbackUri, mode: LaunchMode.externalApplication);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
```

**주의:** import 경로의 패키지명은 `pubspec.yaml`의 `name` 필드를 확인하여 맞출 것.

---

## Step 5: `lib/main.dart` — DeepLinkService 등록

Services 등록 섹션에 추가:

```dart
import 'package:snowlive/service/deep_link_service.dart';
```

`main()` 함수 내 기존 `Get.put()` 블록에 추가:

```dart
Get.put(DeepLinkService(), permanent: true);
```

위치: `Get.put(UserViewModel(), permanent: true);` 아래.

---

## 파일 목록 요약

| 구분 | 파일 | 변경 내용 |
|------|------|-----------|
| 수정 | `pubspec.yaml` | `app_links: ^6.3.2` 추가 |
| 수정 | `ios/Runner/Info.plist` | `snowlive` URL스킴 + `LSApplicationQueriesSchemes`에 `paceface` |
| 수정 | `android/app/src/main/AndroidManifest.xml` | intent-filter + queries |
| 신규 | `lib/service/deep_link_service.dart` | 딥링크 수신 + 콜백 전송 |
| 수정 | `lib/main.dart` | DeepLinkService 등록 |

---

## 검증 방법

1. `flutter pub get` 성공
2. `flutter analyze` — 에러/경고 없음
3. iOS/Android 빌드 성공
4. (PaceFace와 함께 테스트) PaceFace에서 "스노우라이브 연동" 탭 → snowlive 앱 열림 → 자동으로 PaceFace로 콜백 → 연동 완료

---

## 주의사항

- Snowlive 측에서는 API 호출이 없다. 단순히 자신의 user_id를 콜백 URL에 담아 돌려주기만 하면 된다.
- PaceFace 측에서 콜백을 받아 서버에 저장하는 로직은 이미 구현 완료.
- `_handleInitialLink()`는 앱이 종료된 상태에서 딥링크로 열렸을 때를 처리한다.
- `uriLinkStream`은 앱이 이미 실행 중일 때 딥링크를 처리한다.
