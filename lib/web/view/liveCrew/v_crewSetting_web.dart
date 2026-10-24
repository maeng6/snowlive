import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return CrewSettingScaffoldWeb(
      title: '크루 설정',
      fallbackRoute: WebRoutes.liveCrew,
      // 크루홈에서 push로 들어오는 화면이라 뒤로가기를 띄운다(하위 설정 화면들과 통일).
      showBack: true,
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
        ],
      ),
    );
  }
}

/// 설정 허브 로딩 자리표시 — **실제 화면과 같은 구조**(섹션 제목 + 행 묶음)로 그린다.
///
/// 예전에는 높이 40짜리 네모 7개를 12 간격으로 세웠는데, 실제는 섹션 제목이 끼고
/// 행 피치가 51이라 데이터가 도착하는 순간 목록이 230px 가까이 밀려났다.
/// 자리값은 모두 실제 위젯에서 가져온다 —
/// 섹션 제목 줄 27 + 아래 8(`CrewSettingSection`), 행 피치 51(`WebSettingsRow`:
/// 글줄 27 + 상하 12), 섹션 사이 40.
class _SettingSkeleton extends StatelessWidget {
  const _SettingSkeleton();

  /// 섹션별 행 수 — `일반`(소개글·공지·이미지) / `크루원`(신청·관리·권한) / `일반`(삭제).
  /// 권한에 따라 줄어들 수 있지만, 자리표시는 **가장 흔한 경우**(크루장)로 잡는다.
  static const List<int> _rowsPerSection = [3, 3, 1];

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var s = 0; s < _rowsPerSection.length; s++) ...[
            // 섹션 제목(Bold 13, 줄높이 27) + 아래 8.
            const SizedBox(
              height: 27,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonLine(width: 40, height: 16),
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _rowsPerSection[s]; i++)
              // 행 피치 51 — 글자(27)는 가운데, 오른쪽 꺾쇠(24) 자리까지 둔다.
              SizedBox(
                height: 51,
                child: Row(
                  children: [
                    SkeletonLine(width: 96 + (i % 3) * 36, height: 20),
                    const Spacer(),
                    const SkeletonBox(width: 24, height: 24, radius: 4),
                  ],
                ),
              ),
            // 섹션 사이 40.
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
}
