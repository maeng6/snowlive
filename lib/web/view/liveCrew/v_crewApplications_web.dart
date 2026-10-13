import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewApplyList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/alarm/vm_alarmCenter_web.dart' show AlarmBadgeWeb;
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 신청 메시지를 안 쓴 사람에게 대신 보여주는 문구(앱과 동일).
const String _kDefaultApplyTitle = '안녕하세요. 크루 가입 신청합니다.';

/// `수락하기` 배경(목업 174:86103) — 팔레트의 blue50(#ECF3FD)보다 진한 연파랑이라
/// 목업 값을 그대로 쓴다.
const Color _kApproveBackground = Color(0xFFD4E5FF);

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
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        if (_vm.crewId != id) await _vm.load(id);
        if (mounted) _clearCrewAlarm();
      });
    }
  }

  /// 신청 목록을 봤으니 크루홈 종의 `N`을 끈다(앱은 종을 누를 때 끈다 — 웹은 설정 ·
  /// 알림센터로 들어와도 꺼지게 화면 진입 기준). 권한 판정이 끝난 뒤에만.
  void _clearCrewAlarm() {
    final userId = _userVm.user.user_id;
    if (userId == null || !_vm.canManageApplications) return;
    AlarmBadgeWeb.clearCrew(userId);
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
      // ⚠️ 권한(canManageApplications)은 멤버 목록이 와야 판정된다. 알림에서 곧바로
      // 들어오면 아직 로드 전이라 내 역할을 몰라 '권한 없음'으로 보였다 — 가드를
      // Obx로 감싸 로드가 끝난 뒤 다시 판정하고, 로드 중에는 '권한 없음'을 띄우지
      // 않고 로딩 자리만 둔다(깜빡임·오판 방지).
      child: Obx(() {
        final loading = _vm.isLoading;
        final canOpen = _vm.canManageApplications;
        if (_userVm.user.user_id == null) {
          return const CrewSettingGuard(
            isLoggedIn: false,
            canOpen: false,
            child: SizedBox.shrink(),
          );
        }
        // 이 크루 데이터가 아직 안 왔거나(다른 크루/최초 진입) 로딩 중이면 판정 보류.
        // 권한을 모르는 동안은 목록 자리표시를 보여준다 — 빈 자리만 두면 화면이
        // 한 박자 비어 보이고, 권한이 없는 사람에게도 잠깐 목록 모양만 스친다.
        final notReady = _vm.crewId != _crewId || loading;
        if (notReady && !canOpen) return const CrewApplicationsSkeleton();
        return CrewSettingGuard(
          isLoggedIn: true,
          canOpen: canOpen,
          child: _buildList(),
        );
      }),
    );
  }

  Widget _buildList() {
    final applications = _vm.applications.toList();
    final count = applications.length;
    final isLoading = _vm.isLoading;

    if (count == 0) {
      if (isLoading) return const CrewApplicationsSkeleton();
      return const WebEmptyState(message: '가입 신청한 사람이 없어요');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 목업(174:86093) — ExtraBold 14.
        Text(
          '신청한 유저 $count',
          style: SDSTextStyle.extraBold.copyWith(fontSize: 14, color: SDSColor.gray900),
        ),
        // 머리줄 ↔ 첫 행 16 (목업 — 머리줄 16, 행 32).
        const SizedBox(height: SDSSpacing.md),
        for (final (index, apply) in applications.indexed) ...[
          // 신청자 사이 24 (목업 16에서 조금 띄움 — 메시지 박스가 붙어 있어 더 필요하다).
          if (index > 0) const SizedBox(height: 24),
          _buildRow(apply),
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
        // 줄 높이 32 = 아바타 크기(목업 174:86094).
        SizedBox(
          height: 32,
          child: Row(
            children: [
              WebAvatar(
                url: info?.profileImageUrlUser,
                size: 32,
                userId: apply.applicantUserId ?? info?.userId,
              ),
              // 아바타 ↔ 닉네임 10 (목업 — 아바타 32, 닉네임 x=42).
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  info?.displayName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.regular
                      .copyWith(fontSize: 15, height: 18 / 15, color: SDSColor.gray900),
                ),
              ),
              CrewPillButton(
                label: '수락하기',
                // 목업: 수락은 연한 파랑 채움 + 파란 글씨.
                background: _kApproveBackground,
                foreground: SDSColor.snowliveBlue,
                onTap: () => _onApprove(apply),
              ),
              // 버튼 사이 8 (목업 6에서 조금 띄움 — 사용자 확정).
              const SizedBox(width: 8),
              CrewPillButton(
                label: '거절',
                background: SDSColor.snowliveWhite,
                foreground: SDSColor.gray900,
                hasBorder: true,
                onTap: () => _onReject(apply),
              ),
            ],
          ),
        ),
        // 이름 줄 ↔ 메시지 박스 10.
        const SizedBox(height: 10),
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
