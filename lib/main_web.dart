import 'dart:html' as html;
import 'dart:math' as math;

import 'package:com.snowlive/firebase_options.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/analytics_web.dart';
import 'package:com.snowlive/web/util/web_page_title.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/paid/vm_paidVisibility_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_current_route_web.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_web_shell.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

/// 시스템 safe-area 인셋(상태바/노치·홈 인디케이터). index.html의 #safe-probe
/// computed padding(env(safe-area-inset-*))을 읽어 넣는다. 홈화면 추가(standalone)
/// PWA에서만 0이 아니고, 일반 브라우저 탭은 0이라 영향 없다.
final ValueNotifier<EdgeInsets> _safeInsets = ValueNotifier<EdgeInsets>(EdgeInsets.zero);

EdgeInsets _readSafeInsets() {
  try {
    final el = html.document.getElementById('safe-probe');
    if (el == null) return EdgeInsets.zero;
    final s = el.getComputedStyle();
    double px(String? v) =>
        double.tryParse((v ?? '').replaceAll('px', '').trim()) ?? 0.0;
    return EdgeInsets.fromLTRB(
        px(s.paddingLeft), px(s.paddingTop), px(s.paddingRight), px(s.paddingBottom));
  } catch (_) {
    return EdgeInsets.zero;
  }
}

void _trackSafeInsets() {
  void update() => _safeInsets.value = _readSafeInsets();
  update();
  WidgetsBinding.instance.addPostFrameCallback((_) => update());
  html.window.onResize.listen((_) => update()); // 회전도 resize를 동반한다
  // Flutter 엔진이 viewport 메타를 교체했다가 index.html의 옵저버가 cover를 다시
  // 넣는 사이, env 인셋이 잠깐 0→34로 돌아온다. resize 이벤트가 안 뜰 수 있어
  // 초기 몇 초간 몇 번 더 재측정해 안정된 값을 잡는다.
  for (final ms in const [300, 800, 1500, 3000]) {
    Future.delayed(Duration(milliseconds: ms), update);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _trackSafeInsets();
  await initializeDateFormatting('ko', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 일부 네트워크(프록시·브라우저 확장·기업망)에서 Firestore 기본 WebChannel 스트리밍이
  // 막혀 'Listen' RPC가 400/404로 끊긴다 → 배너(banner/homeHeroWeb)·오픈채팅 실시간이
  // 에러도 데이터도 없이 '로딩 중'에 멈춘다. 롱폴링 자동감지를 켜 그런 환경에서도
  // 실시간 구독이 붙게 한다(WebChannel이 되는 환경은 그대로 WebChannel 사용).
  FirebaseFirestore.instance.settings = const Settings(
    webExperimentalAutoDetectLongPolling: true,
  );

  Get.put(UserViewModel(), permanent: true);
  // 게스트 우선 설계: initialRoute는 그대로 두고, 백그라운드에서 조용히
  // 기존 Firebase 세션 여부만 확인해 GNB의 로그인 상태 표시에 반영한다.
  Get.put(AuthCheckViewModelWeb(), permanent: true);
  // 유료기능 진입점 노출 여부(어드민 출시 토글 OR 테스트대상) — GNB·친구 화면이 구독.
  Get.put(PaidVisibilityControllerWeb(), permanent: true);

  runApp(const SnowliveWebApp());
}

class SnowliveWebApp extends StatelessWidget {
  const SnowliveWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // 앱 전역 제목은 브랜드만 — 화면별 탭 제목은 아래 builder의 Title이 덮어쓴다.
      title: kWebBrandTitle,
      getPages: WebRoutes.pages,
      initialRoute: WebRoutes.home,
      // 라우트 전환 효과 없이 즉시 바뀐다 — 일반 웹페이지처럼 보이게 한다(사용자 확정).
      // GNB(사이드바/상단바)는 라우트 Navigator 바깥이라 어차피 고정이고 콘텐츠만 교체된다.
      defaultTransition: Transition.noTransition,
      transitionDuration: Duration.zero,
      // GNB(사이드바/드로어)의 활성 탭 볼드 표시가 라우트 변경을 따라오도록
      // 매 라우팅 시점에 현재 라우트를 반응형 신호에 반영한다.
      // routingCallback 자체가 Navigator가 라우트를 push하며 자신을 빌드하는
      // 도중에 동기 호출되기도 해서, 그 안에서 바로 Rx 값을 바꾸면 "build 중
      // setState 호출" 크래시가 난다 — 다음 프레임으로 미뤄서 반영한다.
      routingCallback: (routing) {
        if (routing == null) return;
        final current = routing.current;
        if (current.isEmpty) return;

        // 스낵바/다이얼로그/바텀시트도 이 콜백을 탄다. GetX는 current를 PageRoute일
        // 때만 갱신하므로(오버레이류는 이전 라우트명 그대로), "라우트가 실제로 바뀐
        // 경우"만 처리하면 셋 다 한 번에 걸러진다. 이 가드가 없으면 업로드 완료
        // 스낵바나 필터 바텀시트를 띄울 때마다 상단 진행바가 번쩍인다.
        if (current == currentRouteWeb.value) return;

        // 라우트 이동 자체에도 진행 신호를 준다. 새 화면의 뷰모델이 이어서 조회를
        // 시작하면 카운트가 유지되므로, 바는 데이터가 도착할 때까지 자연스럽게 이어진다.
        // (이것도 반응형 신호지만 begin/endPageLoading이 내부에서 빌드 중 반영을
        //  피하도록 한 틱 미루므로 여기서 바로 불러도 안전하다.)
        beginPageLoading();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          currentRouteWeb.value = current;
          // GA4 수동 page_view(해시 라우팅 SPA) — 실제 라우트 변경마다 1회.
          sendPageViewWeb(current);
          // 전환이 너무 빨리 끝나면 바가 깜빡이는 것처럼 보여서 최소 노출 시간을 둔다.
          Future.delayed(const Duration(milliseconds: 200), endPageLoading);
        });
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // 게시글 작성 화면의 Quill 툴바가 없으면 UnimplementedError로 죽는다.
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      theme: ThemeData(
        primaryColor: SDSColor.snowliveBlue,
        // 머티리얼3 스피너는 colorScheme.primary(기본 보라)를 쓴다 — 로딩
        // 인디케이터(CircularProgressIndicator)·RefreshIndicator 기본색을
        // 전역에서 스라블루로 고정한다(명시 color를 준 곳은 그대로 유지).
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: SDSColor.snowliveBlue,
        ),
        // 머티리얼3 기본 서피스 틴트(연보라)를 쓰지 않고 흰 배경으로 고정한다.
        scaffoldBackgroundColor: SDSColor.snowliveWhite,
        fontFamily: 'Pretendard',
        // 웹은 탭 리플(테마 기본 하늘색)을 쓰지 않는다 — 전역에서 끈다.
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        // 인풋 커서는 웹 공통 snowliveBlue. 높이는 전역 테마
        // 속성이 없어서 각 TextField에 cursorHeight(= fontSize + 2)로 지정한다.
        // 드래그 선택 영역도 같은 파랑 25% — 안 주면 Material 기본(보라)이 뜬다.
        // (커뮤니티 글쓰기 에디터가 쓰던 값을 웹 전체 공통으로 올렸다.)
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: SDSColor.snowliveBlue,
          selectionColor: SDSColor.snowliveBlue.withValues(alpha: 0.25),
          selectionHandleColor: SDSColor.snowliveBlue,
        ),
        // 웹 공통 스크롤바(PC/태블릿/모바일): 두께 6px, 알약형 라운드,
        // 뷰포트 우측 끝에서 4px 띄움. 스크롤뷰가 화면 전체 폭이어야 브라우저
        // 우측 끝에 붙는다 — 페이지 좌우 패딩은 스크롤뷰 "안쪽"에 둘 것.
        // 색은 기본값(onSurface 10%, hover 50%, drag 60%).
        scrollbarTheme: const ScrollbarThemeData(
          thickness: WidgetStatePropertyAll(6),
          radius: Radius.circular(3),
          crossAxisMargin: 4,
        ),
      ),
      builder: (context, child) {
        // WebAppShell(GNB)이 라우트 Navigator를 감싸는 구조라, GNB까지 덮는
        // 진짜 풀스크린 오버레이(이미지 뷰어 등)는 라우트 Navigator보다 상위에
        // 있는 이 Overlay를 통해서만 열 수 있다 (Overlay.of(rootOverlay: true)로 접근).
        final shell = Overlay(
          initialEntries: [
            // 홈화면 추가(standalone PWA)로 열 때 상태바/노치·홈 인디케이터 영역을
            // 시스템 safe-area 인셋만큼 자동으로 비운다(viewport-fit=cover로 엔진이
            // env(safe-area-inset-*)를 읽어 온다). 일반 브라우저 탭은 인셋이 0이라
            // 영향 없음. 풀스크린 오버레이(이미지 뷰어 등)는 이 Overlay보다 상위
            // rootOverlay로 열려 edge-to-edge를 유지한다.
            OverlayEntry(builder: (_) => SafeArea(child: WebAppShell(child: child!))),
          ],
        );
        // [Flutter 웹 프레임워크 버그 우회] 브라우저 창이 포커스를 받을 때
        // 기본 ReadingOrderTraversalPolicy가 포커스 가능한 위젯들을 rect(크기)로
        // 정렬하다가, 아직 레이아웃 안 된 위젯의 size를 읽어 "RenderBox was not laid out"
        // assert가 터진다(didChangeViewFocus→findFirstFocus 경로, 디버그 전용).
        // 앱 전체를 geometry 정렬을 하지 않는 WidgetOrderTraversalPolicy 그룹으로
        // 감싸 이 크래시를 없앤다(세로 레이아웃이라 탭 순서 차이는 사실상 없다).
        return FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          // 시스템 safe-area 인셋을 MediaQuery.padding에 주입한다. 웹 엔진이 이 값을
          // 안 넘겨줘서(SafeArea가 web에선 사실상 no-op) 홈화면 추가 PWA에서 하단
          // 버튼이 홈 인디케이터에 붙던 문제를 해결한다. 셸 안 SafeArea가 이 padding을 소비.
          child: ValueListenableBuilder<EdgeInsets>(
            valueListenable: _safeInsets,
            child: Obx(
              () => Title(
                title: webPageTitle(currentRouteWeb.value),
                color: SDSColor.snowliveBlue,
                child: shell,
              ),
            ),
            builder: (context, insets, titledShell) {
              // 엔진이 주는 padding(지원 시)과 probe 인셋을 max로 합친다 — 어느 쪽도
              // 0으로 덮지 않아, 엔진이 이미 safe-area를 주면 그대로 살리고 아니면 probe가 보충.
              final base = MediaQuery.of(context);
              final merged = EdgeInsets.fromLTRB(
                math.max(base.padding.left, insets.left),
                math.max(base.padding.top, insets.top),
                math.max(base.padding.right, insets.right),
                math.max(base.padding.bottom, insets.bottom),
              );
              return MediaQuery(
                data: base.copyWith(textScaler: TextScaler.linear(1.0), padding: merged),
                // 브라우저 탭 제목을 화면별로(`중고거래 | 스노우라이브`). shell은 밖에서 한 번
                // 만든 인스턴스라 제목이 바뀌어도 셸은 다시 빌드되지 않는다.
                child: titledShell!,
              );
            },
          ),
        );
      },
    );
  }
}
