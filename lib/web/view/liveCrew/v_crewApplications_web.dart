import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewApplyList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_scaffold_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 신청 메시지를 안 쓴 사람에게 대신 보여주는 문구(앱과 동일).
const String _kDefaultApplyTitle = '안녕하세요. 크루 가입 신청합니다.';

/// 가입 신청 목록. `#/livecrew-applications?id=334`
class CrewApplicationsViewWeb extends StatefulWidget {
  const CrewApplicationsViewWeb({super.key});

  @override
  State<CrewApplicationsViewWeb> createState() => _CrewApplicationsViewWebState();
}

class _CrewApplicationsViewWebState extends State<CrewApplicationsViewWeb> {
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

  void _toast(String message) {
    showWebToast(
      context,
      message,
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }

  Future<void> _onApprove(CrewApply apply) async {
    final name = apply.applicantUserInfo?.displayName ?? '';
    final ok = await showWebConfirmDialog(
      context: context,
      title: '가입 신청을 승인하시겠어요?',
      message: '가입 신청을 승인하시면 승인 즉시 가입됩니다.',
      confirmLabel: '수락하기',
    );
    if (!ok || !mounted) return;
    final result = await _vm.approveApplication(apply.applicantUserId!);
    if (!mounted) return;
    _toast(result.ok
        ? '$name님이 크루원이 되었습니다.'
        : (result.message ?? '잠시 후 다시 시도해 주세요.'));
  }

  Future<void> _onReject(CrewApply apply) async {
    final ok = await showWebConfirmDialog(
      context: context,
      title: '가입 신청을 거절하시겠어요?',
      message: '가입신청을 거절하시면 신청자의 목록에서도 삭제됩니다.',
      confirmLabel: '거절하기',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    final result = await _vm.rejectApplication(apply.applicantUserId!);
    if (!mounted) return;
    // ⚠️ 이 API는 body를 실은 DELETE다 — 서버 CORS가 막으면 여기로 떨어진다.
    _toast(result.ok ? '가입 신청을 거절했습니다.' : (result.message ?? '잠시 후 다시 시도해 주세요.'));
  }

  @override
  Widget build(BuildContext context) {
    return CrewSettingScaffoldWeb(
      title: '가입 신청 목록',
      showBack: true,
      fallbackRoute: '${WebRoutes.crewSetting}?id=$_crewId',
      child: CrewSettingGuard(
        isLoggedIn: _userVm.user.user_id != null,
        canOpen: _vm.canManageApplications,
        child: Obx(_buildList),
      ),
    );
  }

  Widget _buildList() {
    final applications = _vm.applications;
    final count = applications.length;
    final isLoading = _vm.isLoading;

    if (count == 0) {
      if (isLoading) return const SizedBox(height: 120);
      return const WebEmptyState(message: '가입 신청한 사람이 없어요');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '신청한 유저 $count',
          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.md),
        for (final apply in applications) ...[
          _buildRow(apply),
          const SizedBox(height: SDSSpacing.md),
        ],
      ],
    );
  }

  Widget _buildRow(CrewApply apply) {
    final info = apply.applicantUserInfo;
    final message = (apply.title?.trim().isNotEmpty ?? false)
        ? apply.title!.trim()
        : _kDefaultApplyTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            WebAvatar(
              url: info?.profileImageUrlUser,
              size: 36,
              userId: apply.applicantUserId ?? info?.userId,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                info?.displayName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
              ),
            ),
            _PillButton(
              label: '수락하기',
              // 목업: 수락은 연한 파랑 채움 + 파란 글씨.
              background: SDSColor.blue50,
              foreground: SDSColor.snowliveBlue,
              onTap: () => _onApprove(apply),
            ),
            const SizedBox(width: 6),
            _PillButton(
              label: '거절',
              background: SDSColor.snowliveWhite,
              foreground: SDSColor.gray900,
              hasBorder: true,
              onTap: () => _onReject(apply),
            ),
          ],
        ),
        const SizedBox(height: SDSSpacing.sm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: SDSColor.gray50,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            message,
            style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray700),
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool hasBorder;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        elevation: 0,
        shadowColor: Colors.transparent,
        side: hasBorder ? BorderSide(color: SDSColor.gray200) : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 13, color: foreground)),
    );
  }
}
