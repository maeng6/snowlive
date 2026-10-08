import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 데스크탑 전용 우측 열: `크루 만들기` / `크루 가입하기`.
/// **이미 크루에 속해 있으면** 버튼 대신 [myCrew] 카드를 보여준다 — 그 상태에서는
/// 만들기도 가입하기도 할 수 없다(한 계정 한 크루).
class LiveCrewSidebarWeb extends StatelessWidget {
  final CrewDetailInfo? myCrew;

  const LiveCrewSidebarWeb({super.key, this.myCrew});

  @override
  Widget build(BuildContext context) {
    final crew = myCrew;
    return Container(
      width: kWebSidebarWidth,
      // 내부 패딩 없음 — 목록과의 간격 40은 홈 Row가 담당하고, 상단은 칩 줄과
      // 같은 선에서 시작한다(목업 161:38007, 사이드바가 목록 섹션 옆에 붙는 구조).
      padding: EdgeInsets.zero,
      child: crew == null ? const LiveCrewCtaButtons() : MyCrewCard(crew: crew),
    );
  }
}

/// 내가 가입한 크루 요약 — 로고·이름·`리조트 · N명`과 크루홈으로 가는 버튼.
class MyCrewCard extends StatelessWidget {
  final CrewDetailInfo crew;

  const MyCrewCard({super.key, required this.crew});

  @override
  Widget build(BuildContext context) {
    final logoUrl = crewLogoUrlOf(logoUrl: crew.crewLogoUrl, color: crew.color);
    final resort = crew.baseResortFullname ?? crew.baseResortNickname ?? '';
    final members = crew.crewMemberTotal;
    final sub = [
      if (resort.isNotEmpty) resort,
      if (members != null) '$members명',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(SDSSpacing.md),
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(crewLogoRadius(44)),
                  border: Border.all(color: SDSColor.gray100),
                  color: SDSColor.snowliveWhite,
                ),
                clipBehavior: Clip.antiAlias,
                child: (logoUrl?.isNotEmpty ?? false)
                    ? WebNetworkImage(url: logoUrl, width: 44, height: 44)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      crew.crewName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                    ),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SDSSpacing.md),
          SizedBox(
            height: webActionButtonHeight(context),
            child: ElevatedButton(
              onPressed: () => Get.toNamed('${WebRoutes.crewHome}?id=${crew.crewId}'),
              // 채움 버튼 hover — 배경에 검정 10%(웹 공통).
              style: ButtonStyle(
                splashFactory: NoSplash.splashFactory,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                elevation: const WidgetStatePropertyAll(0),
                animationDuration: Duration.zero,
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.hovered)
                      ? Color.alphaBlend(
                          Colors.black.withValues(alpha: 0.1), SDSColor.snowliveBlue)
                      : SDSColor.snowliveBlue,
                ),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              child: Text(
                '내 크루 보기',
                style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 태블릿·모바일에서는 우측 열이 접히므로 본문 끝에 전체폭으로 같은 버튼을 놓는다
/// (커뮤니티가 쓰는 폴백 — 둘 중 하나만 보이므로 진입 경로가 중복되지 않는다).
class LiveCrewCtaButtons extends StatelessWidget {
  const LiveCrewCtaButtons({super.key});

  @override
  Widget build(BuildContext context) {
    // 높이는 공용 webActionButtonHeight(PC 44 / 그 외 48). 세로 패딩 대신 SizedBox로
    // 못 박는다 — 패딩만 두면 웹 기본 visualDensity가 8을 깎는다.
    final buttonHeight = webActionButtonHeight(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () => Get.toNamed(WebRoutes.crewCreate),
            // 채움 버튼 hover — 배경에 검정 10% 블렌드, 애니메이션·리플·그림자 없음(웹 공통).
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              elevation: const WidgetStatePropertyAll(0),
              animationDuration: Duration.zero,
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.hovered)
                    ? Color.alphaBlend(Colors.black.withValues(alpha: 0.1), SDSColor.snowliveBlue)
                    : SDSColor.snowliveBlue,
              ),
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            child: Text(
              '크루 만들기',
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
            ),
          ),
        ),
        const SizedBox(height: SDSSpacing.sm),
        SizedBox(
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: () => Get.toNamed(WebRoutes.crewJoin),
            // 라인 버튼 hover — 테두리·글자는 그대로, **면이 어두워진다**(흰 → gray50).
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              animationDuration: Duration.zero,
              side: const WidgetStatePropertyAll(BorderSide(color: SDSColor.gray200)),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.hovered)
                    ? SDSColor.gray50
                    : SDSColor.snowliveWhite,
              ),
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            child: Text(
              '크루 가입하기',
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
        ),
        // 로그인했을 때만 내 신청 내역 입구를 둔다(가입한 크루가 없을 때 신청·취소 확인용).
        if (Get.find<UserViewModel>().user.user_id != null) ...[
          const SizedBox(height: SDSSpacing.sm),
          _MyApplicationsSidebarLink(),
        ],
      ],
    );
  }
}

/// `가입 신청한 크루` 입구 — 사이드바 CTA 아래 가운데 텍스트 링크(hover 페이드).
class _MyApplicationsSidebarLink extends StatefulWidget {
  @override
  State<_MyApplicationsSidebarLink> createState() => _MyApplicationsSidebarLinkState();
}

class _MyApplicationsSidebarLinkState extends State<_MyApplicationsSidebarLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.toNamed(WebRoutes.crewMyApplications),
        child: Opacity(
          opacity: _hovered ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '가입 신청한 크루',
                  style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray600),
                ),
                const Icon(Icons.chevron_right, size: 16, color: SDSColor.gray600),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
