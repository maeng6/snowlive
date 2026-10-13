import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_title_row_link_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 데스크탑 전용 우측 열: `크루 만들기` / `크루 가입하기`.
/// **이미 크루에 속해 있으면** 버튼 대신 [myCrew] 카드를 보여준다 — 그 상태에서는
/// 만들기도 가입하기도 할 수 없다(한 계정 한 크루).
class LiveCrewSidebarWeb extends StatelessWidget {
  final CrewDetailInfo? myCrew;

  /// 승인 대기 중인 내 신청이 있는지 — 있을 때만 `가입 신청한 크루` 버튼을 둔다.
  final bool hasApplications;

  const LiveCrewSidebarWeb({super.key, this.myCrew, this.hasApplications = false});

  @override
  Widget build(BuildContext context) {
    final crew = myCrew;
    return Container(
      width: kWebSidebarWidth,
      // 내부 패딩 없음 — 목록과의 간격 40은 홈 Row가 담당하고, 상단은 칩 줄과
      // 같은 선에서 시작한다(목업 161:38007, 사이드바가 목록 섹션 옆에 붙는 구조).
      padding: EdgeInsets.zero,
      child: crew == null
          ? LiveCrewCtaButtons(hasApplications: hasApplications)
          : MyCrewCard(crew: crew),
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
  /// 승인 대기 중인 내 신청이 있는지.
  final bool hasApplications;

  const LiveCrewCtaButtons({super.key, this.hasApplications = false});

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
        _CtaOutlinedButton(
          label: '크루 가입하기',
          height: buttonHeight,
          onTap: () => Get.toNamed(WebRoutes.crewJoin),
        ),
        // 승인 대기 중인 신청이 **있을 때만** 입구를 둔다(사용자 확정) — 신청한 적
        // 없는 사람에게는 빈 화면으로 가는 버튼이다. `크루 가입하기`와 같은 라인
        // 버튼이고, 좁은 폭에서는 타이틀 줄 우측 텍스트 링크로 바뀐다.
        if (hasApplications) ...[
          const SizedBox(height: SDSSpacing.sm),
          _CtaOutlinedButton(
            label: '가입 신청한 크루',
            height: buttonHeight,
            onTap: () => Get.toNamed(WebRoutes.crewMyApplications),
          ),
        ],
      ],
    );
  }
}

/// 사이드바 CTA의 라인 버튼 — `크루 가입하기`·`가입 신청한 크루`가 공유한다.
/// 라인 버튼 hover는 웹 공통: 테두리·글자는 그대로, **면이 어두워진다**(흰 → gray50).
class _CtaOutlinedButton extends StatelessWidget {
  final String label;
  final double height;
  final VoidCallback onTap;

  const _CtaOutlinedButton({
    required this.label,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onTap,
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
          label,
          style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
        ),
      ),
    );
  }
}

/// `가입 신청한 크루` 입구의 **텍스트 버튼** — 우측 열이 접히는 태블릿·모바일에서
/// 라이브크루 타이틀 줄 **제일 우측**에 둔다(사용자 확정).
/// 규격·hover는 공용 [WebTitleRowLink] — 크루홈 모바일의 `가입 신청하기`와 같은 것이다.
class LiveCrewMyApplicationsLink extends StatelessWidget {
  const LiveCrewMyApplicationsLink({super.key});

  @override
  Widget build(BuildContext context) {
    return WebTitleRowLink(
      label: '가입 신청한 크루',
      onTap: () => Get.toNamed(WebRoutes.crewMyApplications),
    );
  }
}
