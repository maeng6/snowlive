import 'package:com.snowlive/firebase_options.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_gnb_current_route_web.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:com.snowlive/web/widget/gnb/w_web_shell.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(UserViewModel(), permanent: true);
  // 게스트 우선 설계: initialRoute는 그대로 두고, 백그라운드에서 조용히
  // 기존 Firebase 세션 여부만 확인해 GNB의 로그인 상태 표시에 반영한다.
  Get.put(AuthCheckViewModelWeb(), permanent: true);

  runApp(const SnowliveWebApp());
}

class SnowliveWebApp extends StatelessWidget {
  const SnowliveWebApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '스노우라이브 - 중고거래',
      getPages: WebRoutes.pages,
      initialRoute: WebRoutes.fleamarketList,
      // 웹에서 좌우 슬라이드 전환은 "모바일 앱을 그대로 옮긴" 느낌의 가장 큰 원인이다.
      // GNB(사이드바/상단바)는 라우트 Navigator 바깥이라 고정된 채 콘텐츠만 바뀌는데,
      // 슬라이드를 쓰면 콘텐츠가 사이드바 밑에서 밀려 나오는 것처럼 보인다.
      // 방향성 없는 짧은 크로스페이드로 통일한다(일반적인 SPA 관례).
      // 150ms: 지연으로 인지되는 200ms 아래. Material 기본 300ms는 웹에선 느리게 느껴진다.
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 150),
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
        fontFamily: 'Pretendard',
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          // WebAppShell(GNB)이 라우트 Navigator를 감싸는 구조라, GNB까지 덮는
          // 진짜 풀스크린 오버레이(이미지 뷰어 등)는 라우트 Navigator보다 상위에
          // 있는 이 Overlay를 통해서만 열 수 있다 (Overlay.of(rootOverlay: true)로 접근).
          child: Overlay(
            initialEntries: [
              OverlayEntry(builder: (_) => WebAppShell(child: child!)),
            ],
          ),
        );
      },
    );
  }
}
