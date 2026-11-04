# 스노우라이브 마운틴 (온라인 스키장) — 프론트엔드 인수인계

웹 전용 3D 온라인 스키장. **Flutter 아님** — 순수 웹(three.js + Firebase)으로 돌아가는
독립 앱이다. 스라 웹 앱과 **같은 오리진**에 얹혀 로그인 세션을 공유한다.

- 라이브(QA): https://snowlive-web-qa.web.app/mountain/
- 진입: 스라 웹 좌측 메뉴 **"온라인 스키장"** → `/online-resort` 라우트가 `/mountain/?uid=<내uid>`로 전체이동
- 소스 파일: **`project/snowlive/web/mountain/index.html` 단 하나** (HTML+CSS+JS 전부 인라인)

---

## 1. 빌드 · 배포

```bash
cd project/snowlive
# (web/mountain/index.html 수정 후)
flutter build web -t lib/main_web.dart --no-tree-shake-icons   # web/ → build/web/ 복사
firebase deploy --only hosting:qa --project snowlive-cf446      # QA 배포
```
- `/mountain/`은 그냥 정적 파일이라 Flutter 코드와 무관. `flutter build web`은 `web/` 폴더를
  `build/web/`로 복사하는 용도일 뿐(엔진은 안 씀).
- **프로덕션 배포는 하지 말 것**(명시 지시 때만). QA만.

### 로컬에서 빠르게 보기
```bash
cd project/snowlive/web/mountain && python3 -m http.server 8080   # http://localhost:8080
```
- 로컬에서도 **멀티플레이는 동작**(게스트로 접속). 단 **로그인 닉네임/프로필/아바타 복원은
  안 됨**(같은 오리진 세션이 없어서). 그건 QA 배포 후 로그인 상태로 확인.
- 3D는 WebGL 필요 — 일반 브라우저면 OK. (헤드리스 테스트 땐 SwiftShader 플래그 필요)

---

## 2. 전체 구조 (index.html 안)

1. `<head>`
   - 기본 스타일 `<style>` (프로토타입 원본)
   - **UI 폴리시 `<style>`** (맨 끝, 글래스모피즘/그라데이션/알약 라벨 — 디자인 손볼 땐 여기)
2. `<body>`: 캔버스 `#c` + 모든 HUD/패널 DOM(`#gate` `#maker` `#hud` `#summitPanel`
   `#lodge` `#ticket` `#soundP` `#card` `#joystick` `#labels` 등)
3. `<script type="module">` — **Firebase 초기화**. `window.__fb` 노출:
   `{ ready, user, uid, ref(path), onValue, get, set, onDisconnect, serverTimestamp }`
4. 메인 `<script>` (IIFE) — 게임 전부. 끝에서 `window.__resort = { S, me, LIFT, ... }` 노출.

### 메인 스크립트 핵심 심볼
| 심볼 | 역할 |
|---|---|
| `S` | 전역 상태(`mode`, `stats`, `ch`, `slope`, `skiMode`, `tod` ...) |
| `me` | 내 플레이어 `{ opts, c(캐릭터), pos, yaw, pi(프로필img) }` |
| `bots[]` | **분위기용 가짜 캐릭터**(실유저 아님) |
| `makeChar(opts)` / `setColors` / `setGear` / `animChar` | 복셀 캐릭터 생성·색·장비·애니 |
| `TRAILS[]` | 슬로프 3종(솜사탕/자작나무/설원) 수치 |
| `setMode(m)` | 씬 전환(`gate` `maker` `base` `queue` `lift` `summit` `ski` `lodge` `card`) |
| `SND` | Web Audio 합성 사운드(BGM/바람/효과음) |
| `NET` | **멀티플레이·유저데이터**(아래 3장) |
| `JOY` | 이동 조이스틱 입력 벡터 |
| `labelAt(i,text,cls,wp,img)` | 머리 위 이름표(+아바타) 1개 그림 |

---

## 3. NET — 멀티플레이 · 유저 데이터 (전부 Firebase, Django 최소)

RTDB 경로(모두 `resort/` 하위, 규칙상 자유롭게 읽기/쓰기 가능):

| 경로 | 내용 |
|---|---|
| `resort/channels/{ch}/players/{uid}` | **실시간 접속자**(위치·yaw·pose·외형·닉네임`n`·프로필`pi`). 10Hz 발행, onDisconnect 자동 제거 |
| `resort/avatars/{uid}` | **저장된 아바타**(jacket/cap/pants/skin/gear/ski/boardColor). 로그인 유저만 |

NET 메서드: `init()`(config 로드) · `connect()` · `publish()`(내 상태) ·
`upsert()`(원격 반영) · `tick(dt)`(보간·발행, 루프에서 호출) · `labels()` ·
`fetchName()`(닉네임/프로필) · `loadAvatar()` / `saveAvatar()`.

- **내 정체**: `window.__fb.uid`(로그인) → 없으면 URL `?uid=`(스라에서 넘겨줌) → 없으면 `guest_...`.
  `NET.realUid`가 true일 때만 닉네임/프로필/아바타 저장·복원.
- 원격 유저는 `makeChar`로 실제 3D 캐릭터로 렌더(렌더캡 = config `render_cap`, 기본 30, 가까운 순).

### Django 백엔드 (안정화 완료 — 평소엔 안 건드림)
`https://snowlive-api-...herokuapp.com/api/online-resort/`
- `GET config/` → `{ rtdb_url, rtdb_root, default_channel, render_cap, channels[] }`
- `GET me/?uid=` → `{ found, user_id, display_name, profile_image, gear }`
  (`gear`는 유저 테이블 `skiorboard`를 'ski'|'board'|''로 매핑 → 접속 시 캐릭터 장비 기본값. 프론트는 `fetchName()`에서 적용하고, 사용자가 렌탈샵에서 바꾸거나 저장아바타가 있으면 그걸 우선)
- (소스: `project/python/snowlive_api/snowlive/online_resort_app/`, **모델 없음**)

---

## 4. 확장 포인트 (대부분 백엔드 無)

- **외형에 새 필드** 추가: `publish()`의 전송 객체 + `optsFrom()`/`upsert()`에 키 추가,
  `makeChar` 파츠/`setColors`에 반영.
- **새 실시간 데이터**(채팅·이모지·점수판 등): 그냥 `window.__fb.ref('resort/<원하는경로>')` +
  `set`/`onValue`/`get`. **규칙 수정 불필요**(resort/* 전체 허용).
- **새 건물/시설**: `building({...})` 호출 + `FAC`에 등록 + `facility(id)` 분기 + 필요 시 `setMode`.
- **팔레트/닉네임풀**: `JACKETS/CAPS/PANTS/SKINS`, `NAMES`.
- **디자인**: `<head>` 끝의 폴리시 `<style>`.
- **사운드**: `SND`(합성). 에셋 BGM 넣으려면 여기 교체.

### 백엔드가 필요한 경우(지금은 미진행)
1. 게임 기록("오늘의 라이딩" 리프트/하강 등)을 **스라 유저 DB에 영구 저장** → Django 엔드포인트 신설.
2. 완전히 새로운 서버 로직/집계.

---

## 5. 알아둘 점 (caveats)

- **`bots`는 가짜**(연출). 실제 접속자는 NET이 그린다. 봇을 없애려면 `bots` 생성부(`addBot`)와
  `update()`의 봇 루프를 제거.
- RTDB `resort/*`는 **공개 읽기/쓰기**(규칙 완화됨). 코스메틱/프레즌스 전용 네임스페이스라 OK.
  민감 데이터는 넣지 말 것. 넣는다면 `database.rules.json` 조이기.
- **"오늘의 라이딩" 기록은 세션 한정**(서버 저장 안 됨) — 위 "백엔드 필요 경우 1".
- 게스트(미로그인)는 매 접속 임시 uid → 아바타/닉네임 유지 안 됨(정상).
- Firebase 설정값(apiKey 등)은 index.html 모듈에 인라인(웹 클라 키라 공개 OK).

문의: 이 파일 + `snowlive_online_resort` 메모 참고.
