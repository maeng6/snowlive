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
| `makeChar(opts)` / `setColors` / `setGear` / `animChar` | 캐릭터 생성·색·장비·애니. 관절마다 둥근 덮개가 있어 자세를 바꿔도 몸이 갈라지지 않음. 장비 옵션: `hat`(helmet/beanie)·`cap`(머리 색)·`lens`(고글)·`neck`(넥워머, ''=없음)·`glove`. 키 약 1.75m, 머리는 키의 1/7 |
| `wearOf` / `outfits` | 장비별 옷(실제 착용 사진 참고). 핵심: **스키복은 스키니, 보드복은 위아래 모두 오버핏**. 스키복 = `jacket`·`accent`·`pants`·`skiFit`(slim 하나: 허리 잡힌 핏 재킷+옆구리·팔 대비 패널, 다리에 붙는 바지) — 원에잇 스키복 참고. 보드복 = `bJacket`·`bAccent`·`bPants`·`boardFit`(track 트랙 셋업 / anorak 아노락): 어깨가 떨어지는 박스형 블루종+통 아주 넓은 바지 — 비에스래빗·스페셜게스트 참고. 예전 핏 이름은 `FIT_ALIAS`로 변환 |
| `binding` / 다리 `skB`·`sb` | 장비별 부츠·바인딩. 스키 = 정강이까지 오는 셸 부츠(발 부분 셸은 고정, 커프 `cuffG`는 발목 관절을 축으로 정강이 각도만큼 앞으로 기울어 다리를 감쌈. 버클·파워 스트랩)+스키 바인딩(플레이트·토피스·힐피스·브레이크). 보드 = 푹신한 보드 부츠+바인딩(베이스플레이트·하이백·힐컵·발목/발가락 스트랩). `userData.gearOnly`로 장비에 맞는 것만 보임 |
| `SNOW_MAT` / `GROOM_MAT` / `SNOWU` | 설면 셰이더(저니 모래 렌더링 기법 응용): 대비 강한 확산광·색 있는 그림자·바람결 물결(가파를수록 또렷)·역광 테두리·오션 스페큘러(해 쪽 빛의 길)·글리터·해 쪽 안개 산란. 그림자 맵과 가로등 빛도 받음. `SNOWU`는 모든 설면이 공유하는 시간대 값 |
| `MODEL` / `attachModel` / `driveModel` / `buildKK` | **캐릭터 모델**: `models/kaykit/kk_mage.glb`(남)·`kk_rogue.glb`(여) — KayKit Adventurers(CC0) 2~3등신 저폴리. 애니메이션·무기·모자·망토를 뺀 경량판(약 240KB, 뼈 이름 `upperleg_l` 식). `KK_S`(0.75)배로 붙여 키 약 1.65m(`KK_H`). 리그의 `LEG`·`HIP`도 이 모델 다리 기준이라 무릎을 굽혀도 발이 땅에 붙음. 관절 리그 자세를 매 프레임 모델 뼈대로 옮김(`BONE_MAP`, T자세 팔은 `ARM_DOWN`만큼 내린 상태를 차렷으로, 골반 이동은 `/KK_S`). 머리(얼굴·머리카락) 메시만 보이고 몸·팔·다리 메시는 숨김. **옷·장갑은 링 단면을 이어 붙여 직접 설계**(`jacket`/`pants`/`gloves`/`tube`): 스키 `slim`(슬림·칼라·소맷단 포인트), 보드 `track`(박시·밑단·소맷단·지퍼), `anorak`(더 길고 박시·캥거루 포켓·하프 지퍼), 바지 `pantsS`(슬림, 부츠 안)·`pantsB`(와이드, 부츠 덮음), 벙어리장갑(팔 메시로 손 크기 측정). 링마다 뼈 가중치 하나라 옷감이 구겨지지 않음. 헬멧·비니·고글은 기존 부품을 `HEAD_GEAR`배로 키워 큰 머리에 씌움. 부츠·바인딩은 다리가 짧아 `BOOT_Y`만큼 높이만 줄임, 폴은 0.62배. `driveModel` 끝에서 부츠·스키(`gearG`)는 모델 발목에, 폴은 모델 손(`hand`~`handslot`)에 맞춤. 1인칭 눈높이 1.2/스키 1.0/턱 0.78m, 이름표 1.95m. 원기둥·구 몸은 `muteProc`으로 숨김. 체형 옵션 `body`(male/female) = 얼굴 선택 |
| `fitGear` | 스키 길이 ≈ 키 − 12cm, 보드 길이 ≈ 키 × 0.87 |
| `jointsOf` / `animChar` 끝부분 | 사람다운 움직임: 모든 관절이 목표 자세를 부드럽게 따라감(보간), 팔꿈치(`userData.elbow`), 서 있을 때 숨쉬기·체중 이동·두리번, 폴은 팔 자세와 상관없이 아래·뒤를 향함. 팔다리는 근육 곡선(`muscle`), 몸통은 어깨 경사·가슴 굴곡(`humanize`) |
| `POST.shafts` / `MIST` / `greatPeak` | 배경: 해 쪽 빛줄기(갓 레이, 실내에선 끔), 산허리 안개 띠(지면 위 0~60m에만), 멀리 노을을 받는 큰 봉우리(`PEAK_MAT`은 안개를 덜 받음). 시간대별 양은 `TOD`의 `shaft`·`mist` |
| `DUST` / `DRIFT` / `updateAir` | 다이아몬드 더스트(해 쪽에서 반짝이는 공기 중 얼음 결정)·설면 위 눈가루. 바람 방향 `WIND`는 설면 물결무늬와 같음 |
| `TOD` / `blendTod` / `skyMat` / `POST` | 시간대 팔레트(낮·노을·야간·새벽)를 프레임마다 부드럽게 섞음. 하늘 그라데이션·해/달·별, 블룸+비네팅 후처리(`renderFrame`) |
| `TRAILS[]` | 슬로프 3종(솜사탕/자작나무/설원) 수치 |
| `setMode(m)` | 씬 전환(`gate` `maker` `base` `queue` `lift` `summit` `ski` `lodge` `card`) |
| `SND` | Web Audio 합성 사운드(BGM/바람/효과음) |
| `NET` | **멀티플레이·유저데이터**(아래 3장) |
| `JOY` | 조이스틱(`#joy`, 터치 기기만) 입력 벡터. 베이스·정상에선 앞뒤 이동+방향 전환, 하강에선 좌우 턴·아래 감속·위 웅크리기 |
| `skiPhysics` / `autoSteer` / `SKI` | 하강 물리. 경사·마찰·공기저항으로 가속, 사이드컷 반경 안의 턴은 카빙(속도 유지), 넘으면 스키딩(감속). 자동 하강은 `autoSteer`가 턴 폭으로 `TRAILS[].auto` 속도를 맞춤 |
| `legFlex` / `animChar` 'ski' 포즈 | 다리 IK(고관절·무릎·발목). 보드는 토/힐사이드, 스키는 바깥발 길게·안쪽발 짧게 + 앵귤레이션·폴 플랜트 |
| `S.view` / `setView` / `followHeading` | 3인칭(기본)·1인칭. 이동 방향을 시선이 따라가고 드래그로 둘러보기, 휠·핀치·V키·`#viewBtn`으로 전환 |
| `sprayFrom` / `leaveTracks` / `drawSpeedFx` | 눈 효과(턴 스프레이·설면 자국)와 속도감(설면 질감·경계 폴대·속도선·비네팅·시야각) |
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
- **팔레트/닉네임풀**: `SKI_JACKETS/SKI_ACCENTS/SKI_PANTS`, `BOARD_JACKETS/BOARD_ACCENTS/BOARD_PANTS`, `CAPS/SKINS/LENSES/NECKS/GLOVES`, `NAMES`. 장비를 늘릴 땐 실제 스키·보드 복장 기준으로.
- **시간대 색**: `TOD`의 `lit`(빛)·`shade`(그림자)·`hor/zen`(하늘)·`glit`(반짝임)·`bloom`.
- **디자인**: `<head>` 끝의 폴리시 `<style>`. 글꼴은 Gowun Batang(제목·숫자)·Gowun Dodum(본문).
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
