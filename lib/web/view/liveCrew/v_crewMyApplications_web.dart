import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewApplyList.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewJoin_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart' show showWebConfirmDialog;
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 가입 신청한 크루(내 신청 내역). `#/livecrew-my-applications`
///
/// 가입한 크루가 없을 때, 승인 전 신청 내역을 보고 취소한다(앱 `가입 신청한 크루`와 동일).
///
/// 목업이 따로 없는 화면이라 **거울 화면인 `가입 신청 목록`(174:86001)과 크루 행을 쓰는
/// `크루 가입하기`(174:89293)의 확정값**을 그대로 따른다 — 공통 스캐폴드(여백·타이틀·
/// 진행 버튼), 머리줄 `신청한 크루 N`, 로고 48 행, 알약 버튼.
class CrewMyApplicationsViewWeb extends StatefulWidget {
  const CrewMyApplicationsViewWeb({super.key});

  @override
  State<CrewMyApplicationsViewWeb> createState() => _CrewMyApplicationsViewWebState();
}

class _CrewMyApplicationsViewWebState extends State<CrewMyApplicationsViewWeb> {
  final CrewJoinViewModelWeb _vm = Get.find<CrewJoinViewModelWeb>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.loadMyApplications();
    });
  }

  void _toast(String message) {
    showWebToast(
      context,
      message,
    );
  }

  Future<void> _onCancel(CrewApply apply) async {
    final crewId = apply.crewId;
    if (crewId == null) return;
    final ok = await showWebConfirmDialog(
      context: context,
      title: '가입 신청을 취소하시겠어요?',
      message: '취소하셔도 다음에 다시 가입 신청하실 수 있어요.',
      confirmLabel: '신청 취소',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    final result = await _vm.cancelApplication(crewId);
    if (!mounted) return;
    _toast(result.ok ? '가입 신청을 취소했습니다.' : (result.message ?? '잠시 후 다시 시도해 주세요.'));
  }

  @override
  Widget build(BuildContext context) {
    // 앱에는 하단에 `다른 크루 찾아보기` 고정 버튼이 있지만 웹에서는 두지 않는다
    // (사용자 확정) — 크루 찾기는 라이브크루 홈·GNB로 이미 들어갈 수 있다.
    return CrewSettingScaffoldWeb(
      title: '가입 신청한 크루',
      showBack: true,
      fallbackRoute: WebRoutes.liveCrew,
      child: Obx(_buildBody),
    );
  }

  Widget _buildBody() {
    // ⚠️ 분기 전에 관찰값을 모두 읽어야 Obx 구독이 확실히 걸린다.
    final isLoggedIn = _vm.isLoggedIn;
    final applications = _vm.myApplications.toList();
    final isLoading = _vm.isLoadingApplications;
    final hasError = _vm.hasApplicationsError;

    if (!isLoggedIn) {
      return const CrewSettingGuard(
        isLoggedIn: false,
        canOpen: false,
        child: SizedBox.shrink(),
      );
    }
    if (applications.isEmpty) {
      // 첫 조회 전에도 스켈레톤을 보여준다(빈 상태가 번쩍이지 않게).
      if (isLoading) return const _MyApplicationsSkeleton();
      if (hasError) return WebErrorState(onRetry: _vm.loadMyApplications);
      return const WebEmptyState(message: '가입 신청한 크루가 없어요.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 머리줄은 거울 화면(`신청한 유저 N`)과 같은 ExtraBold 14.
        Text(
          '신청한 크루 ${applications.length}',
          style: SDSTextStyle.extraBold.copyWith(fontSize: 14, color: SDSColor.gray900),
        ),
        // 머리줄 ↔ 첫 행 16 (목업 174:86001).
        const SizedBox(height: SDSSpacing.md),
        // 행 사이에 간격을 두지 않는다 — 행마다 상하 8 패딩이 있어 시각적으로 16이고,
        // hover 면이 끊기지 않는다(크루 가입하기 목록과 같은 처리).
        for (final apply in applications) _MyApplicationRow(apply: apply, onCancel: _onCancel),
      ],
    );
  }
}

/// 신청한 크루 한 줄. 규격은 **크루 가입하기 목록 행**(목업 174:89293)과 같다 —
/// 로고 48 · 간격 10 · 크루명 16 · 보조줄 13.
///
/// ⚠️ 이 화면만 **행 hover 면(gray50)을 쓰지 않는다**(사용자 확정) — 행 끝에 `신청취소`
/// 버튼이 있어서 hover 박스가 버튼과 겹쳐 보인다. 커서(손가락)로만 누를 수 있음을 알린다.
class _MyApplicationRow extends StatelessWidget {
  final CrewApply apply;
  final Future<void> Function(CrewApply) onCancel;

  const _MyApplicationRow({required this.apply, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final crew = apply.crewInfo;
    final crewId = apply.crewId;
    final logoUrl = crewLogoUrlOf(logoUrl: crew?.crewLogoUrl, color: crew?.color);
    // 보조줄은 가입하기 목록과 같은 `리조트 별명 · 소개`.
    final nick = crewResortNicknameOf(crew?.baseResortId);
    final desc = crew?.description?.trim().replaceAll('\n', ' ') ?? '';
    final subtitle = [if (nick.isNotEmpty) nick, if (desc.isNotEmpty) desc].join(' · ');

    return MouseRegion(
      cursor: crewId == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: crewId == null
            ? null
            : () => Get.toNamed('${WebRoutes.crewHome}?id=$crewId'),
        child: Padding(
          // hover 면이 없으니 좌우 여백도 뺀다 — 머리줄(`신청한 크루 N`)·`신청취소`가
          // 본문 좌우선에 딱 맞는다(가입 신청 목록과 같은 정렬).
          // 상하 8은 유지해 행 사이가 16으로 보이게 둔다.
          padding: const EdgeInsets.symmetric(vertical: SDSSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  // 라운드는 공용 비율(한 변의 0.2) — 기본 마크 이미지에 구워진
                  // 모서리와 곡률을 맞춘다.
                  borderRadius: BorderRadius.circular(crewLogoRadius(48)),
                  // 기본 크루 마크가 흰 카드라 테두리가 없으면 흰 배경에 묻힌다.
                  border: Border.all(color: SDSColor.gray100),
                ),
                clipBehavior: Clip.antiAlias,
                child: (logoUrl?.isNotEmpty ?? false)
                    ? WebNetworkImage(url: logoUrl, width: 48, height: 48)
                    : Container(color: SDSColor.gray100),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      crew?.crewName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular
                          .copyWith(fontSize: 16, color: SDSColor.gray900),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.regular
                            .copyWith(fontSize: 13, color: SDSColor.gray500),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: SDSSpacing.md),
              CrewPillButton(
                label: '신청취소',
                background: SDSColor.snowliveWhite,
                foreground: SDSColor.gray900,
                hasBorder: true,
                onTap: () => onCancel(apply),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 신청 내역 로딩 — **실제 행과 같은 구성**(머리줄 + 로고 48 + 이름 16 + 부제 13 + 알약)
/// 으로 그린다. 한 덩어리 막대로 두면 로딩이 끝나는 순간 레이아웃이 튄다.
class _MyApplicationsSkeleton extends StatelessWidget {
  const _MyApplicationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 머리줄(ExtraBold 14) 자리 + 아래 16.
          const SkeletonLine(width: 92, height: 17),
          const SizedBox(height: SDSSpacing.md),
          for (var i = 0; i < 3; i++)
            Padding(
              // 실제 행과 같은 패딩(상하 8만 — 행 hover 면이 없어 좌우 여백이 없다).
              padding: const EdgeInsets.symmetric(vertical: SDSSpacing.sm),
              child: Row(
                children: [
                  SkeletonBox(width: 48, height: 48, radius: crewLogoRadius(48)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 크루명(16) / 간격 4 / 부제(13) — 길이는 행마다 조금씩 다르게.
                        SkeletonLine(width: 120 + (i % 3) * 28, height: 18),
                        const SizedBox(height: 4),
                        SkeletonLine(width: 180 + (i % 2) * 40, height: 15),
                      ],
                    ),
                  ),
                  const SizedBox(width: SDSSpacing.md),
                  // 알약 버튼(높이 28) 자리.
                  const SkeletonBox(width: 66, height: 28, radius: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
