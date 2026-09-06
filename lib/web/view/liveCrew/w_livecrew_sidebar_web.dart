import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kLiveCrewSidebarWidth = 280;

/// 데스크탑 전용 우측 열: `크루 만들기` / `크루 가입하기`.
class LiveCrewSidebarWeb extends StatelessWidget {
  const LiveCrewSidebarWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kLiveCrewSidebarWidth,
      // 좌측 타이틀 줄만큼 내려서 시작한다(다른 화면들과 같은 규격).
      padding: const EdgeInsets.only(left: SDSSpacing.lg, top: 56),
      child: const LiveCrewCtaButtons(),
    );
  }
}

/// 태블릿·모바일에서는 우측 열이 접히므로 본문 끝에 전체폭으로 같은 버튼을 놓는다
/// (커뮤니티가 쓰는 폴백 — 둘 중 하나만 보이므로 진입 경로가 중복되지 않는다).
class LiveCrewCtaButtons extends StatelessWidget {
  const LiveCrewCtaButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => Get.toNamed(WebRoutes.crewCreate),
          style: ElevatedButton.styleFrom(
            backgroundColor: SDSColor.snowliveBlue,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text(
            '크루 만들기',
            style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite),
          ),
        ),
        const SizedBox(height: SDSSpacing.sm),
        OutlinedButton(
          onPressed: () => Get.toNamed(WebRoutes.crewJoin),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: SDSColor.gray200),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text(
            '크루 가입하기',
            style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
          ),
        ),
      ],
    );
  }
}
