import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewApplyList.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewJoin_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart' show showWebConfirmDialog;
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 본문 폭 — 한 줄짜리 목록이라 가입하기 페이지(800)보다 조금 좁게 둔다.
const double kCrewMyApplicationsMaxWidth = 720;

/// 가입 신청한 크루(내 신청 내역). `#/livecrew-my-applications`
///
/// 가입한 크루가 없을 때, 승인 전 신청 내역을 보고 취소한다(앱 `가입 신청한 크루`와 동일).
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

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }
    Get.offAllNamed(WebRoutes.liveCrew);
  }

  void _toast(String message) {
    showWebToast(
      context,
      message,
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
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
    return Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        padding: webSubPagePadding(context, bottom: 80),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kCrewMyApplicationsMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WebPageHeader(title: '가입 신청한 크루', onBack: _goBack),
                const SizedBox(height: SDSSpacing.xl),
                Obx(_buildBody),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_vm.isLoggedIn) {
      return const WebEmptyState(message: '로그인이 필요해요.');
    }
    final applications = _vm.myApplications;
    if (applications.isEmpty) {
      if (_vm.isLoadingApplications) return const SizedBox(height: 120);
      if (_vm.hasApplicationsError) {
        return WebErrorState(onRetry: _vm.loadMyApplications);
      }
      return _EmptyApplications(onBrowse: () => Get.toNamed(WebRoutes.crewJoin));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final apply in applications) ...[
          _buildRow(apply),
          const SizedBox(height: SDSSpacing.md),
        ],
        const SizedBox(height: SDSSpacing.md),
        // 앱처럼 하단에 다른 크루를 둘러보는 입구를 둔다.
        _BrowseMoreButton(onTap: () => Get.toNamed(WebRoutes.crewJoin)),
      ],
    );
  }

  Widget _buildRow(CrewApply apply) {
    final crew = apply.crewInfo;
    final logoUrl = crewLogoUrlOf(logoUrl: crew?.crewLogoUrl, color: crew?.color);
    final desc = crew?.description?.trim() ?? '';
    final crewId = apply.crewId;

    return MouseRegion(
      cursor: crewId == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: crewId == null
            ? null
            : () => Get.toNamed('${WebRoutes.crewHome}?id=$crewId'),
        child: Row(
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    crew?.crewName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            _CancelButton(onTap: () => _onCancel(apply)),
          ],
        ),
      ),
    );
  }
}

/// `신청취소` 알약 버튼 — 흰 바탕 + 회색 테두리(앱과 같은 톤).
class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        side: const BorderSide(color: SDSColor.gray200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Text('신청취소',
          style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
    );
  }
}

/// 신청 내역이 없을 때 — 안내 + 크루 둘러보기 버튼.
class _EmptyApplications extends StatelessWidget {
  final VoidCallback onBrowse;

  const _EmptyApplications({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const WebEmptyState(message: '가입 신청한 크루가 없어요.'),
        const SizedBox(height: SDSSpacing.lg),
        _BrowseMoreButton(onTap: onBrowse),
      ],
    );
  }
}

/// `다른 크루 찾아보기` — 파란 채움 버튼(앱과 같은 입구).
class _BrowseMoreButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BrowseMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 빈 상태(가운데 정렬 Column)든 목록 하단(stretch Column)이든 **같은 크기**로
    // 유지되게 폭을 고정하고 가운데에 둔다(앱 팝업 버튼과 같은 240).
    return Center(
      child: SizedBox(
        width: 240,
        height: webActionButtonHeight(context),
        child: ElevatedButton(
          onPressed: onTap,
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
            '다른 크루 찾아보기',
            style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
          ),
        ),
      ),
    );
  }
}
