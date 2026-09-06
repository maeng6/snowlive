import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 운영진 권한 설정. `#/livecrew-permissions?id=334`
///
/// 토글 3개를 바꿔두고 `저장하기`로 **한 번에** PUT 한다(앱은 토글마다 즉시 저장한다).
class CrewPermissionsViewWeb extends StatefulWidget {
  const CrewPermissionsViewWeb({super.key});

  @override
  State<CrewPermissionsViewWeb> createState() => _CrewPermissionsViewWebState();
}

class _CrewPermissionsViewWebState extends State<CrewPermissionsViewWeb> {
  final CrewSettingViewModelWeb _vm = Get.find<CrewSettingViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  int? _crewId;

  /// 화면에서 만지는 값. 서버 값으로 한 번 채운 뒤로는 사용자가 주인이다.
  bool? _join;
  bool? _desc;
  bool? _notice;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _crewId = int.tryParse(Get.parameters['id'] ?? '');
    final id = _crewId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        if (_vm.crewId != id) await _vm.load(id);
        if (mounted) setState(_prefill);
      });
    }
  }

  void _prefill() {
    if (_prefilled || _vm.info == null) return;
    _prefilled = true;
    _join = _vm.permissionJoin;
    _desc = _vm.permissionDesc;
    _notice = _vm.permissionNotice;
  }

  Future<void> _onSave() async {
    final result = await _vm.savePermissions(
      join: _join ?? false,
      desc: _desc ?? false,
      notice: _notice ?? false,
    );
    if (!mounted) return;
    if (!result.ok) {
      showWebToast(
        context,
        result.message ?? '저장에 실패했어요. 잠시 후 다시 시도해주세요.',
        alignment: context.screenType == WebScreenType.mobile
            ? Alignment.bottomCenter
            : Alignment.topCenter,
      );
      return;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return CrewSettingScaffoldWeb(
      title: '운영진 권한 설정',
      showBack: true,
      fallbackRoute: '${WebRoutes.crewSetting}?id=$_crewId',
      actionLabel: '저장하기',
      onAction: _onSave,
      child: CrewSettingGuard(
        isLoggedIn: _userVm.user.user_id != null,
        canOpen: _vm.canManageCrew,
        child: Obx(() {
          // 서버 값을 읽어야 하므로 구독을 걸고, 아직 안 채웠으면 여기서 채운다.
          final info = _vm.info;
          if (info != null) _prefill();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRow(
                title: '크루 가입 신청 허가 권한',
                description: '운영진 권한을 부여받은 크루원에게 크루에 들어온 가입 신청 허가 권한을 부여합니다.',
                value: _join ?? false,
                onChanged: (v) => setState(() => _join = v),
              ),
              _buildRow(
                title: '크루 소개글 변경 권한',
                value: _desc ?? false,
                onChanged: (v) => setState(() => _desc = v),
              ),
              _buildRow(
                title: '공지사항 추가 권한',
                value: _notice ?? false,
                onChanged: (v) => setState(() => _notice = v),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRow({
    required String title,
    String? description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SDSSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
                ),
                if (description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: SDSSpacing.md),
          CrewOnOffToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
