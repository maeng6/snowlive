import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 페이지 이동/데이터 조회 중임을 알려주는 전역 상단 로딩바 신호.
/// 목록/랭킹 등 데이터를 불러오는 뷰모델이 조회 시작/종료 시 이 값을 같이 갱신하면,
/// GNB 상단에 고정된 [TopLoadingBar]가 자동으로 반응해서 얇은 진행 바를 보여준다
/// (유튜브/깃허브 등 웹에서 흔히 쓰는 상단 로딩 인디케이터 패턴).
final RxBool isGlobalPageLoading = false.obs;

/// 화면 최상단에 고정으로 두는 얇은 로딩바. 로딩 중이 아닐 때도 같은 높이(2px)의
/// 빈 공간을 유지해서 로딩바가 나타났다 사라질 때 레이아웃이 흔들리지 않게 한다.
class TopLoadingBar extends StatelessWidget {
  const TopLoadingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!isGlobalPageLoading.value) {
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
