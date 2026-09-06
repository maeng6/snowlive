# 웹 로그인 — UI 작업 인수인계

작성일: 2026-07-23
브랜치: `web-login-refactor`
범위: **뷰모델까지 완료.** UI(View)·라우트 연결·온보딩 화면은 팀원 작업.

---

## 완료된 것 (건드리지 말 것 / 그대로 사용)

### 백엔드
- `POST /api/accounts/web-login/` (배포됨)
  - body: `{ "uid": "<firebase uid>" }`
  - 기존 유저: `200 {message:'login', user:{...}}`
  - 신규가입 필요: `404 {message:'온보딩이동'}`
  - 파이어스토어 이관: `201 {message:'이관성공', user:{...}}`
  - **device_id/device_token 안 건드림** (모바일 기기 지문 안전)

### 프론트 뷰모델 (신규)
- `core/api/api_login.dart` → `webLogin(uid)` 추가
- `web/viewmodel/auth/vm_login_web.dart` → **LoginViewModelWeb**
- `web/viewmodel/auth/vm_authcheck_web.dart` → **AuthCheckViewModelWeb**
- `web/routes/bindings_web.dart` → **WebLoginBinding** (두 VM lazyPut)

---

## LoginViewModelWeb — UI 연결 API

```dart
final vm = Get.find<LoginViewModelWeb>();

// 관찰 (Obx)
vm.status        // WebLoginStatus: idle/loading/success/needOnboarding/error
vm.isLoading     // bool
vm.errorMessage  // String

// 액션 (버튼)
vm.signInWithGoogle();
vm.signInWithApple();   // 애플은 Firebase 콘솔 설정 후 동작
vm.signOut();
```

**status에 따른 라우팅 (UI에서):**
| status | 할 일 |
|---|---|
| `loading` | 로딩 인디케이터 |
| `success` | 홈으로 (`Get.offAllNamed(...)`). UserViewModel 이미 세팅됨 |
| `needOnboarding` | 온보딩/가입 화면으로. `vm.pendingUid / pendingEmail / pendingDisplayName / pendingPhotoUrl` 사용 |
| `error` | `vm.errorMessage` 표시 |

## AuthCheckViewModelWeb — 자동로그인(스플래시/가드)

```dart
final auth = Get.find<AuthCheckViewModelWeb>();
auth.status  // WebAuthStatus: checking/authenticated/unauthenticated/needOnboarding
// onInit에서 checkAuth() 자동 호출. 필요 시 auth.checkAuth() 재호출.
```
| status | 라우팅 |
|---|---|
| `checking` | 스플래시 |
| `authenticated` | 홈 |
| `unauthenticated` | 로그인 |
| `needOnboarding` | 온보딩 |

---

## 팀원이 만들 것

1. **로그인 화면** `web/view/login/v_login_web.dart`
   - 구글/애플 버튼 → `vm.signInWithGoogle()` / `signInWithApple()`
   - `Obx`로 `vm.status`·`isLoading`·`errorMessage` 반영
2. **온보딩/가입 화면** (신규 유저) — `pendingUid` 등으로 프로필 입력 → 서버 register 호출 (기존 `LoginAPI().registerUser` 참고, 웹은 favorite_resort 등만 받으면 됨)
3. **스플래시/가드** — 앱 로드 시 `AuthCheckViewModelWeb.status`로 분기
4. **라우트 연결** `web/routes/routes_web.dart`
   ```dart
   static const login = '/login';
   GetPage(name: login, page: () => LoginViewWeb(), binding: WebLoginBinding()),
   ```
5. **main_web.dart 가드** — `initialRoute`를 스플래시/로그인 체크로 (현재는 바로 fleamarket)

---

## ⚠️ Firebase 콘솔 (런타임 전제조건)
- `Authentication → Settings → 승인된 도메인`: `localhost`, `snowlive.kr` 추가
- 구글: 승인 도메인만 하면 동작
- 애플(웹): Services ID 설정 필요 (Domains=`snowlive-cf446.firebaseapp.com`, Return URL=`https://snowlive-cf446.firebaseapp.com/__/auth/handler`)
- **구글부터 붙이는 걸 추천** (애플은 설정 후)

## 설계 원칙 (지켜주세요)
- 웹 로그인은 **device_id/token/secure_storage 안 씀** (Firebase 세션이 브라우저 유지)
- 서버 인증은 반드시 `web-login/` (find-user/compare-device-id 쓰지 말 것 — 모바일 기기 지문 덮어씀)
