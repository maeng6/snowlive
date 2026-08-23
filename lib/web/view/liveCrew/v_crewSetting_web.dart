import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_settings_row_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 크루 설정 허브. `#/livecrew-setting?id=334`
///
/// 항목은 **역할과 권한에 따라 그리지 않는다**(앱과 같은 규칙) — 크루장은 전부,
/// 운영진은 `permission_*`이 열린 것만, 일반 크루원은 `크루 탈퇴`만 보인다.
class CrewSettingViewWeb extends StatefulWidget {
  const CrewSettingViewWeb({super.key});

  @override
  State<CrewSettingViewWeb> createState() => _CrewSettingViewWebState();
}

class _CrewSettingViewWebState extends State<CrewSettingViewWeb> {
  final CrewSettingViewModelWeb _vm = Get.find<CrewSettingViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  int? _crewId;

  @override
  void initState() {
    super.initState();
    _crewId = int.tryParse(Get.parameters['id'] ?? '');
    final id = _crewId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _vm.crewId != id) _vm.load(id);
      });
    }
  }

  String get _crewRoute => '${WebRoutes.crewHome}?id=$_crewId';

  Future<void> _open(String route) async {
    await Get.toNamed('$route?id=$_crewId');
    // 돌아왔을 때 배지·목록이 옛 값으로 남지 않게 한다.
    if (mounted) await _vm.refresh();
  }

  Future<void> _onDeleteCrew() async {
    final ok = await showWebConfirmDialog(
      context: context,
      title: '정말 삭제하시겠어요?',
      confirmLabel: '삭제하기',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    final result = await _vm.deleteCrew();
    if (!mounted) return;
    if (!result.ok) {
      _toast(result.message ?? '잠시 후 다시 시도해 주세요.');
      return;
    }
    Get.offAllNamed(WebRoutes.liveCrew);
  }

  Future<void> _onWithdraw() async {
    final ok = await showWebConfirmDialog(
      context: context,
      title: '정말 탈퇴하시겠어요?',
      confirmLabel: '탈퇴하기',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    final result = await _vm.withdraw();
    if (!mounted) return;
    if (!result.ok) {
      _toast(result.message ?? '잠시 후 다시 시도해 주세요.');
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

  @override
  Widget build(BuildContext context) {
    return CrewSettingScaffoldWeb(
      title: '크루 설정',
      fallbackRoute: WebRoutes.liveCrew,
      child: Obx(_buildBody),
    );
  }

  Widget _buildBody() {
    // 세 값을 무조건 먼저 읽어야 Obx 구독이 확실히 걸린다.
    final info = _vm.info;
    final isLoading = _vm.isLoading;
    final hasError = _vm.hasError;
    final pending = _vm.applications.length;

    if (_crewId == null) {
      return const WebEmptyState(message: '크루 정보를 찾을 수 없어요.');
    }
    if (info == null) {
      if (hasError) return WebErrorState(onRetry: _vm.refresh);
      return isLoading ? const _SettingSkeleton() : const SizedBox(height: 200);
    }

    return CrewSettingGuard(
      isLoggedIn: _userVm.user.user_id != null,
      canOpen: _vm.canOpenSettings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CrewSettingSection(
            title: '일반',
            children: [
              if (_vm.canEditDescription)
                WebSettingsRow(
                  label: '크루 소개글',
                  onTap: () => _open(WebRoutes.crewSettingDesc),
                ),
              if (_vm.canEditNotice)
                WebSettingsRow(
                  label: '공지사항 추가',
                  onTap: () => _open(WebRoutes.crewSettingNotice),
                ),
              if (_vm.canManageCrew)
                WebSettingsRow(
                  label: '크루 이미지 및 컬러 설정',
                  onTap: () => _open(WebRoutes.crewSettingImage),
                ),
            ],
          ),
          CrewSettingSection(
            title: '크루원',
            children: [
              if (_vm.canManageApplications)
                WebSettingsRow(
                  label: '가입 신청 목록',
                  // 목업의 `NEW` — 대기 중인 신청이 있을 때만 띄운다.
                  badgeLabel: pending > 0 ? 'NEW' : null,
                  onTap: () => _open(WebRoutes.crewApplications),
                ),
              if (_vm.canManageCrew)
                WebSettingsRow(
                  label: '크루원 관리',
                  onTap: () => _open(WebRoutes.crewMemberAdmin),
                ),
              if (_vm.canManageCrew)
                WebSettingsRow(
                  label: '운영진 권한 설정',
                  onTap: () => _open(WebRoutes.crewPermissions),
                ),
            ],
          ),
          CrewSettingSection(
            title: '일반',
            children: [
              // 크루장은 삭제, 그 외 크루원은 탈퇴(앱과 같은 규칙).
              if (_vm.isLeader)
                WebSettingsRow(label: '크루 삭제', onTap: _onDeleteCrew)
              else
                WebSettingsRow(label: '크루 탈퇴', onTap: _onWithdraw),
            ],
          ),
          const SizedBox(height: SDSSpacing.md),
          Center(
            child: TextButton(
              onPressed: () => Get.offAllNamed(_crewRoute),
              child: Text(
                '크루홈으로',
                style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingSkeleton extends StatelessWidget {
  const _SettingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < 7; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            const SkeletonBox(height: 40, radius: 6),
          ],
        ],
      ),
    );
  }
}
