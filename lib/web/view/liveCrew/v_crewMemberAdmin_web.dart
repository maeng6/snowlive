import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewMemberList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_scaffold_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 행을 누르면 뜨는 메뉴 항목. 라벨은 현재 역할에 따라 달라져 호출부가 만든다.
enum _MemberAction { changeRole, expel }

/// 크루원 관리. `#/livecrew-member-admin?id=334`
///
/// 목업대로 **행을 누르면 바로 아래에 액션 패널이 펼쳐진다.** 역할 변경·강퇴는 확인 후
/// 즉시 적용하므로 별도 `저장하기` 버튼은 두지 않는다.
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
    final members = _vm.members.toList();
    final total = _vm.memberTotal;
    final count = members.length;

    if (count == 0) {
      if (_vm.isLoading) return const CrewMemberAdminSkeleton();
      return const WebEmptyState(message: '가입된 멤버가 없습니다');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 머리줄은 설정 하위 목록 공통 — `가입 신청 목록`·`가입 신청한 크루`와 같은
        // ExtraBold 14(목업 174:86093), 아래 16.
        Text(
          '크루원 $total',
          style: SDSTextStyle.extraBold.copyWith(fontSize: 14, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.md),
        for (final member in members) _buildRow(member),
      ],
    );
  }

  Widget _buildRow(CrewMember member) {
    final role = member.status ?? kCrewRoleMember;
    return _MemberAdminRow(
      member: member,
      role: role,
      onChangeRole: () => _onChangeRole(member),
      onExpel: () => _onExpel(member),
    );
  }
}

/// 크루원 한 줄. 누르면 **공용 앵커 드롭다운**(⋯ 메뉴·필터와 같은 것)이 열린다 —
/// PC는 행 아래에 붙는 패널, 태블릿·모바일은 딤 시트로 자동 전환된다.
/// 예전에는 행 아래를 밀어내며 펼쳐지는 자체 카드였는데, 같은 성격의 메뉴가
/// 화면마다 다르게 보여서 공용으로 맞췄다(사용자 확정).
class _MemberAdminRow extends StatefulWidget {
  final CrewMember member;
  final String role;
  final VoidCallback onChangeRole;
  final VoidCallback onExpel;

  const _MemberAdminRow({
    required this.member,
    required this.role,
    required this.onChangeRole,
    required this.onExpel,
  });

  @override
  State<_MemberAdminRow> createState() => _MemberAdminRowState();
}

class _MemberAdminRowState extends State<_MemberAdminRow> {
  /// 앵커 링크 — 드롭다운이 이 행을 따라다닌다(스크롤해도 붙어 있게).
  final LayerLink _link = LayerLink();

  bool get _isLeaderRow => widget.role == kCrewRoleLeader;

  Future<void> _open() async {
    final selected = await showWebFilterMenu<_MemberAction>(
      context: context,
      link: _link,
      values: _MemberAction.values,
      labelOf: (a) => switch (a) {
        _MemberAction.changeRole => widget.role == kCrewRoleManager
            ? '크루원으로 권한 변경'
            : '운영진으로 권한 부여',
        _MemberAction.expel => '강퇴하기',
      },
      // 태블릿은 화면 가운데 시트로 띄운다(⋯ 메뉴와 같은 설정).
      centerSheetOnTablet: true,
    );
    if (selected == null) return;
    switch (selected) {
      case _MemberAction.changeRole:
        widget.onChangeRole();
      case _MemberAction.expel:
        widget.onExpel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: _isLeaderRow ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // 크루장 행은 바꿀 것이 없으니 메뉴를 열지 않는다(목업).
          onTap: _isLeaderRow ? null : _open,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                WebAvatar(
                  url: widget.member.userInfo?.profileImageUrlUser,
                  size: 36,
                  userId: widget.member.userInfo?.userId,
                ),
                const SizedBox(width: 12),
                // 역할 배지는 **닉네임 바로 옆**에 붙인다(사용자 확정) — 행 오른쪽
                // 끝에 두면 긴 닉네임과 멀어져 누구 배지인지 잘 안 읽힌다.
                // 닉네임이 길면 닉네임만 줄고 배지는 밀리지 않는다.
                Flexible(
                  child: Text(
                    widget.member.userInfo?.displayName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 15, color: SDSColor.gray900),
                  ),
                ),
                const SizedBox(width: 8),
                CrewRoleBadge(role: widget.role),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

