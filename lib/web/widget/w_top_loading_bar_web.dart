import 'dart:async';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 페이지 이동/데이터 조회 중임을 알려주는 전역 상단 진행바 신호
/// (유튜브/깃허브 등 웹에서 흔히 쓰는 상단 로딩 인디케이터 패턴).
///
/// 단일 bool이 아니라 **참조 카운트**인 이유: 한 화면에서 여러 조회가 동시에 돌 수 있다.
/// 예를 들어 랭킹 홈은 개인/크루 뷰모델이 같이 조회를 시작하는데, bool이면 먼저 끝난
/// 쪽이 아직 로딩 중인 다른 쪽까지 바를 꺼버린다.
///
/// 직접 값을 건드리지 말고 [beginPageLoading]/[endPageLoading] 또는
/// 짝을 자동으로 맞춰주는 [withPageLoading]을 쓸 것.
final RxInt _pageLoadingCount = 0.obs;

/// 진행 중인 로딩이 하나라도 있는지. (뷰에서 읽기용)
bool get isPageLoading => _pageLoadingCount.value > 0;

void beginPageLoading() => _bump(1);

void endPageLoading() => _bump(-1);

/// 카운트 반영을 **항상 한 틱 미룬다.**
///
/// 이 값은 [TopLoadingBar]의 Obx가 구독하는 반응형 값이라, 위젯 빌드 도중에 쓰면
/// "setState() or markNeedsBuild() called during build"로 죽는다. 그런데 호출 지점이
/// 하필 빌드 도중에 동기 실행되는 곳들이다:
///  - GetMaterialApp의 routingCallback: 첫 라우트 push는 runApp의 attachRootWidget
///    (= buildScope) 안에서 일어난다.
///  - 뷰모델 onInit: State 필드 초기화에서 Get.find를 하면 element mount 중,
///    즉 역시 buildScope 안에서 lazyPut된 컨트롤러가 생성되며 onInit이 돈다.
/// 호출자마다 addPostFrameCallback으로 감싸는 대신 여기서 한 번에 막는다.
/// 마이크로태스크는 진행 중인 동기 빌드가 끝난 뒤에 실행되므로 안전하고,
/// 한 프레임도 안 되는 지연이라 눈에 보이지 않는다.
void _bump(int delta) {
  scheduleMicrotask(() {
    final next = _pageLoadingCount.value + delta;
    // 중복 end 호출로 음수가 되면 이후 begin이 0을 못 넘겨서 바가 영영 안 뜬다 — 0에서 멈춘다.
    if (next >= 0) _pageLoadingCount.value = next;
  });
}

/// begin/end 짝을 강제하는 래퍼. 예외가 나도 finally에서 반드시 카운트를 되돌린다.
Future<T> withPageLoading<T>(Future<T> Function() task) async {
  beginPageLoading();
  try {
    return await task();
  } finally {
    endPageLoading();
  }
}

/// 화면 최상단에 고정으로 두는 얇은 진행바. 로딩 중이 아닐 때도 같은 높이(2px)의
/// 빈 공간을 유지해서 바가 나타났다 사라질 때 레이아웃이 흔들리지 않게 한다.
class TopLoadingBar extends StatelessWidget {
  const TopLoadingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!isPageLoading) {
        return const SizedBox(height: 2);
      }
      return const SizedBox(
        height: 2,
        child: LinearProgressIndicator(
          minHeight: 2,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(SDSColor.snowliveBlue),
        ),
      );
    });
  }
}
