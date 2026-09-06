import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewMemberList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 크루원 관리. `#/livecrew-member-admin?id=334`
///
/// 목업대로 **행을 누르면 바로 아래에 액션 패널이 펼쳐진다.** 역할 변경·강퇴는 확인 후
/// 즉시 적용하므로(사용자 확정) 별도 `저장하기` 버튼은 두지 않는다.
class CrewMemberAdminViewWeb extends StatefulWidget {
  const CrewMemberAdminViewWeb({super.key});

  @override
  State<CrewMemberAdminViewWeb> createState() => _CrewMemberAdminViewWebState();
}

class _CrewMemberAdminViewWebState extends State<CrewMemberAdminViewWeb> {
  final CrewSettingViewModelWeb _vm = Get.find<CrewSettingViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  int? _crewId;

  /// 액션 패널이 펼쳐진 멤버의 user_id. null이면 모두 닫힘.
  int? _expandedUserId;

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

  void _toast(String message) {
    showWebToast(
      context,
      message,
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }

  Future<void> _onChangeRole(CrewMember member) async {
    final userId = member.userInfo?.userId;
    if (userId == null) return;
    final toManager = (member.status ?? kCrewRoleMember) != kCrewRoleManager;
    final label = toManager ? '운영진으로 권한 부여' : '크루원으로 권한 변경';

    final ok = await showWebConfirmDialog(
      context: context,
      title: '$label하시겠어요?',
      confirmLabel: '변경하기',
    );
    if (!ok || !mounted) return;

    final result = await _vm.changeMemberRole(
      memberUserId: userId,
      status: toManager ? kCrewRoleManager : kCrewRoleMember,
    );
    if (!mounted) return;
    setState(() => _expandedUserId = null);
    _toast(result.ok ? '권한을 변경했습니다.' : (result.message ?? '잠시 후 다시 시도해 주세요.'));
  }

  Future<void> _onExpel(CrewMember member) async {
    final userId = member.userInfo?.userId;
    if (userId == null) return;
    final name = member.userInfo?.displayName ?? '';

    final ok = await showWebConfirmDialog(
      context: context,
      title: '정말 강퇴하시겠어요?',
      confirmLabel: '강퇴하기',
      isDestructive: true,
    );
    if (!ok || !mounted) return;

    final result = await _vm.expelMember(userId);
    if (!mounted) return;
    setState(() => _expandedUserId = null);
    _toast(result.ok
        ? '$name님을 강퇴했습니다.'
        : (result.message ?? '잠시 후 다시 시도해 주세요.'));
  }

  @override
  Widget build(BuildContext context) {
    return CrewSettingScaffoldWeb(
      title: '크루원 관리',
      showBack: true,
      fallbackRoute: '${WebRoutes.crewSetting}?id=$_crewId',
      child: CrewSettingGuard(
        isLoggedIn: _userVm.user.user_id != null,
        canOpen: _vm.canManageCrew,
        child: Obx(_buildList),
      ),
    );
  }

  Widget _buildList() {
    final members = _vm.members;
    final total = _vm.memberTotal;
    final count = members.length;

    if (count == 0) {
      if (_vm.isLoading) return const SizedBox(height: 120);
      return const WebEmptyState(message: '가입된 멤버가 없습니다');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '크루원 $total',
          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.md),
        for (final member in members) _buildRow(member),
      ],
    );
  }

  Widget _buildRow(CrewMember member) {
    final userId = member.userInfo?.userId;
    final role = member.status ?? kCrewRoleMember;
    final isLeaderRow = role == kCrewRoleLeader;
    final isExpanded = userId != null && userId == _expandedUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          cursor: isLeaderRow ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // 크루장 행은 바꿀 것이 없으니 펼치지 않는다(목업).
            onTap: isLeaderRow || userId == null
                ? null
                : () => setState(() => _expandedUserId = isExpanded ? null : userId),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  WebAvatar(url: member.userInfo?.profileImageUrlUser, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      member.userInfo?.displayName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                    ),
                  ),
                  CrewRoleBadge(role: role),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded) _buildActionPanel(member, role: role),
      ],
    );
  }

  /// 목업의 펼침 패널 — 테두리 카드 안에 두 줄.
  Widget _buildActionPanel(CrewMember member, {required String role}) {
    final toManager = role != kCrewRoleManager;
    return Container(
      margin: const EdgeInsets.only(bottom: SDSSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SDSColor.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelAction(
            label: toManager ? '운영진으로 권한 부여' : '크루원으로 권한 변경',
            onTap: () => _onChangeRole(member),
          ),
          _PanelAction(label: '강퇴하기', onTap: () => _onExpel(member)),
        ],
      ),
    );
  }
}

class _PanelAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PanelAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.md, vertical: 14),
        child: Text(
          label,
          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
        ),
      ),
    );
  }
}
