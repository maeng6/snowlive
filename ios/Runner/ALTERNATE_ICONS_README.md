# iOS 대체 아이콘(Alternate App Icons) 마무리 단계

서버(리조트인포 resort-home의 `app_icon_variant`) → 앱이 `UIApplication.setAlternateIconName`으로
홈화면 아이콘을 전환한다. 코드/plist는 모두 배선돼 있고, **아래 Xcode 수동 단계만**
남았다(루스 PNG를 Runner 타겟에 포함시켜야 실제로 번들됨).

## 이미 완료된 것
- `AppDelegate.swift`: `app_icon` MethodChannel (`setIcon`/`currentIcon`) 등록 완료.
- `Info.plist`: `CFBundleIcons > CFBundleAlternateIcons`에 `AppIconXmas`, `AppIconNewyear` 선언 완료.
- 루스 아이콘 파일 생성 완료(이 폴더): `AppIconXmas@2x.png`(120), `AppIconXmas@3x.png`(180),
  `AppIconNewyear@2x.png`(120), `AppIconNewyear@3x.png`(180). **알파 없음(불투명)** — iOS 요구사항 충족.
  ※ 현재는 기본 앱아이콘과 똑같은 더미(플레이스홀더)다. 디자이너 아트로 교체할 것(같은 파일명·크기 유지).

## 남은 수동 단계 (Xcode에서 1회)
1. Xcode로 `ios/Runner.xcworkspace` 열기.
2. 좌측 네비게이터에서 **Runner 그룹**에 위 4개 PNG를 드래그해 추가.
   - "Copy items if needed" 체크 불필요(이미 폴더에 있음), **Add to targets: Runner** 반드시 체크.
3. 파일 4개를 선택 → 우측 File Inspector의 **Target Membership → Runner** 체크 확인.
4. (선택) Build Phases → **Copy Bundle Resources**에 4개가 들어갔는지 확인.
5. 실기기/시뮬레이터 빌드 후, 서버 `app_icon_variant`를 바꿔(또는 디버그로 `setIcon` 호출)
   아이콘이 바뀌는지 확인.

## 유의사항 (iOS)
- `setAlternateIconName` 호출 시 **"앱 아이콘이 변경되었습니다" 시스템 팝업이 뜨는 게 Apple 기본 동작**이다.
  팝업을 숨기는 비공식 우회(UIViewController presentation 스위즐)가 있으나 **심사 리젝 리스크**가 있어
  기본 구현에는 넣지 않았다. 필요 시 별도 결정.
- 대체 아이콘 PNG는 **알파 채널이 없어야** 한다(있으면 검정/리젝). 생성 스크립트에서 `-alpha remove`로 처리됨.
- 아이패드까지 지원하려면 76pt@2x(152), 83.5pt@2x(167) 크기도 추가 권장(현재는 iPhone 60pt@2x/@3x만).
- 변형을 늘리려면: (a) 새 루스 PNG 추가 + 타겟 멤버십, (b) Info.plist에 키 추가,
  (c) `AppDelegate.swift iconNames` 맵, (d) Android `activity-alias`+`MainActivity iconAliases`,
  (e) 백엔드 `Riding_config.APP_ICON_CHOICES`에 키 추가 — 다섯 곳을 함께 맞춰야 한다.
