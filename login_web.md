# 웹 로그인 — UI 작업 가이드 (팀원용)

작성일: 2026-07-23
브랜치: `maeng`
범위: **로그인·자동로그인 뷰모델 + 백엔드 완료.** UI(View)·라우트 연결·**온보딩(신규가입) 뷰모델+화면**은 팀원 작업.

---

## 0. 한 줄 요약
웹 로그인은 **Firebase 팝업 로그인 → uid로 서버 조회(`web-login`) → UserViewModel 세팅** 이 전부다.
모바일과 달리 **device_id/token·secure_storage를 안 쓴다** (Firebase가 브라우저 세션을 자동 유지).

---

## 1. 모바일 vs 웹 (무엇이 바뀌나)

| 항목 | 📱 모바일(기존) | 🌐 웹(신규) |
|---|---|---|
| 로그인 | 네이티브 SDK(google_sign_in/apple) | Firebase `signInWithPopup` |
| 기기정보 device_id/token | 수집·전송 | **안 씀** |
| 세션 저장 | `secure_storage` | **Firebase 브라우저 세션 자동** |
| 서버 API | `find-user` / `compare-device-id` | **`web-login`** |
| 자동로그인 | secure_storage → compare-device-id | Firebase `authStateChanges()` |

> ⚠️ 웹에서 **절대 `find-user`/`compare-device-id`를 쓰지 말 것.** 그 API는 device 지문을 덮어써서 모바일 로그인 상태를 오염시킴. 웹은 반드시 `web-login`.

---

## 2. 완료된 것 (그대로 사용)

### 뷰모델 / API (신규)
| 파일 | 클래스/메서드 |
|---|---|
| `lib/core/api/api_login.dart` | `LoginAPI().webLogin({'uid': ...})` |
| `lib/web/viewmodel/auth/vm_login_web.dart` | **`LoginViewModelWeb`** |
| `lib/web/viewmodel/auth/vm_authcheck_web.dart` | **`AuthCheckViewModelWeb`** |
| `lib/web/routes/bindings_web.dart` | **`WebLoginBinding`** (위 두 VM lazyPut) |

### 백엔드 (배포됨)
`POST https://snowlive-api-c617725e2b78.herokuapp.com/api/accounts/web-login/`
- 요청: `{ "uid": "<firebase uid>" }` (uid만!)
- 응답:
  - `200 {message:'login', user:{...}}` — 기존 유저
  - `201 {message:'이관성공', user:{...}}` — 파이어스토어 이관
  - `404 {message:'온보딩이동'}` — **신규 유저(가입 필요)**
  - `400 {error:'uid가 필요합니다.'}`

---

## 3. LoginViewModelWeb — 로그인 화면용

```dart
final vm = Get.find<LoginViewModelWeb>();

// 관찰 (Obx로 감싸기)
vm.status        // enum WebLoginStatus
vm.isLoading     // bool
vm.errorMessage  // String

// 버튼 액션
vm.signInWithGoogle();
vm.signInWithApple();   // ⚠️ 애플은 Firebase 콘솔 설정 후 동작. 처음엔 구글만
vm.signOut();
```

**`WebLoginStatus` 값 → UI 처리:**
| status | UI |
|---|---|
| `idle` | 초기 |
| `loading` | 로딩 인디케이터 |
| `success` | **홈으로 라우팅** (UserViewModel 이미 세팅됨) |
| `needOnboarding` | **온보딩/가입 화면으로** (아래 pending 값 사용) |
| `error` | `vm.errorMessage` 표시 |

**신규 유저(`needOnboarding`)일 때 넘겨받는 값:**
```dart
vm.pendingUid          // Firebase uid (가입 시 서버로 보냄)
vm.pendingEmail        // Firebase 이메일
vm.pendingDisplayName  // Firebase 이름(있으면)
vm.pendingPhotoUrl     // Firebase 프로필 사진(있으면)
```

### 예시 (로그인 버튼)
```dart
Obx(() {
  final vm = Get.find<LoginViewModelWeb>();
  // status 변화에 따라 라우팅
  if (vm.status == WebLoginStatus.success) {
    // Get.offAllNamed(WebRoutes.home) 등 (프레임 이후 처리 권장)
  } else if (vm.status == WebLoginStatus.needOnboarding) {
    // Get.toNamed(WebRoutes.onboarding)
  }
  return ElevatedButton(
    onPressed: vm.isLoading ? null : vm.signInWithGoogle,
    child: vm.isLoading ? CircularProgressIndicator() : Text('구글로 로그인'),
  );
});
```
> 라우팅은 `ever(vm.statusRx, (s){...})` 리스너로 처리하는 게 더 깔끔함.

---

## 4. AuthCheckViewModelWeb — 스플래시/자동로그인용

```dart
final auth = Get.find<AuthCheckViewModelWeb>();
auth.status;         // enum WebAuthStatus
auth.checkAuth();    // 재확인 필요 시 (onInit에서 자동 1회 호출됨)
auth.signOut();
```
| `WebAuthStatus` | 라우팅 |
|---|---|
| `checking` | 스플래시 |
| `authenticated` | 홈 |
| `unauthenticated` | 로그인 화면 |
| `needOnboarding` | 온보딩 |

앱 로드 시 Firebase가 저장된 세션을 복원하면 자동으로 로그인 상태가 됨.

---

## 5. 팀원이 만들 것 (UI + 온보딩 VM)

### (1) 로그인 화면 — `web/view/login/v_login_web.dart`
- 구글/애플 버튼 → `LoginViewModelWeb`의 메서드 호출
- `status` 관찰해 라우팅/에러표시

### (2) 온보딩(신규가입) — **VM+View 둘 다 팀원**
- 신규 유저(`needOnboarding`)가 닉네임·관심리조트 등 입력 → 서버 가입
- 참고: 모바일 `lib/viewmodel/onboarding_login/vm_setProfile.dart` (닉네임 중복확인 `LoginAPI().checkDisplayName`, 가입 `LoginAPI().registerUser`)
- 가입 body에 필요한 필드: `uid`(=pendingUid), `email`, `display_name`, `favorite_resort`, `profile_image_url_user` 등
  - `device_id`/`device_token`은 웹이므로 `'web'` 같은 placeholder로 보내거나 서버와 합의
  - 프로필 이미지 업로드는 웹 방식 필요(예: `image` 패키지 + Firebase Storage `putData`) — 플리마켓 `ImageControllerWeb` 참고

### (3) 스플래시/가드
- `AuthCheckViewModelWeb.status`로 홈/로그인/온보딩 분기

### (4) 라우트 연결 — `web/routes/routes_web.dart`
```dart
static const login = '/login';
static const onboarding = '/onboarding';
// pages 리스트에:
GetPage(name: login, page: () => LoginViewWeb(), binding: WebLoginBinding()),
GetPage(name: onboarding, page: () => OnboardingViewWeb(), binding: WebLoginBinding()),
```

### (5) `main_web.dart` 가드
- 현재는 `initialRoute: fleamarketList`로 바로 진입.
- 스플래시(또는 AuthCheck) 라우트를 initialRoute로 두고, `WebAuthStatus`에 따라 분기하도록 수정.
- `UserViewModel`은 이미 `Get.put(..., permanent: true)`로 상주 중 → 로그인 후 그대로 사용.

---

## 6. Firebase 콘솔 (런타임 전제조건)
- `Authentication → Settings → 승인된 도메인`에 추가: `localhost`, `snowlive.kr`
- **구글**: 승인 도메인만 하면 바로 동작 (추천: 구글부터)
- **애플(웹)**: Apple Services ID 설정 필요
  - Domains: `snowlive-cf446.firebaseapp.com`
  - Return URLs: `https://snowlive-cf446.firebaseapp.com/__/auth/handler`

---

## 7. 하지 말 것 (설계 원칙)
- ❌ 웹에서 `find-user`/`compare-device-id` 호출 (모바일 기기 지문 오염)
- ❌ 웹에서 `flutter_secure_storage`·`google_sign_in`(네이티브)·`sign_in_with_apple`(네이티브) 사용 — 웹 미지원
- ❌ device_id/device_token을 서버에 보내기 (웹은 무시)
- ✅ 반드시 `web-login` + Firebase 세션 사용

---

## 8. 파일 위치 맵
```
lib/core/api/api_login.dart                     # webLogin() (공통)
lib/core/viewmodel/vm_user.dart                 # UserViewModel (공통, 이미 상주)
lib/web/viewmodel/auth/vm_login_web.dart        # ✅ LoginViewModelWeb
lib/web/viewmodel/auth/vm_authcheck_web.dart    # ✅ AuthCheckViewModelWeb
lib/web/routes/bindings_web.dart                # ✅ WebLoginBinding
lib/web/view/login/                             # ← 팀원: 로그인 뷰
lib/web/view/onboarding/                        # ← 팀원: 온보딩 뷰
lib/web/viewmodel/auth/vm_onboarding_web.dart   # ← 팀원: 온보딩 VM (신규)
lib/main_web.dart                               # ← 팀원: 가드/initialRoute
```
