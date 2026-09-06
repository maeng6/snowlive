import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_scaffold_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/widget/w_web_form_fields_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 크루 소개글 작성/변경. `#/livecrew-desc?id=334`
class CrewSettingDescViewWeb extends StatefulWidget {
  const CrewSettingDescViewWeb({super.key});

  @override
  State<CrewSettingDescViewWeb> createState() => _CrewSettingDescViewWebState();
}

class _CrewSettingDescViewWebState extends State<CrewSettingDescViewWeb> {
  final CrewSettingViewModelWeb _vm = Get.find<CrewSettingViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final TextEditingController _controller = TextEditingController();

  int? _crewId;

  /// 현재 소개글을 한 번만 채운다(입력 중에 다시 덮어쓰지 않게).
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
        _prefill();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _prefill() {
    if (_prefilled || !mounted) return;
    final text = _vm.info?.description ?? '';
    if (_vm.info == null) return;
    _prefilled = true;
    _controller.text = text;
  }

  Future<void> _onSave() async {
    final result = await _vm.saveDescription(_controller.text);
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
    // 로딩이 끝난 뒤에 들어와도 값이 채워지게 매 빌드에서 한 번 시도한다.
    _prefill();

    return CrewSettingScaffoldWeb(
      title: '크루 소개글 작성/변경',
      showBack: true,
      fallbackRoute: '${WebRoutes.crewSetting}?id=$_crewId',
      actionLabel: '완료',
      onAction: _onSave,
      child: CrewSettingGuard(
        isLoggedIn: _userVm.user.user_id != null,
        canOpen: _vm.canEditDescription,
        child: WebFormTextField(
          label: '소개글',
          controller: _controller,
          hint: '크루 소개글을 입력해 주세요. (최대 $kCrewDescriptionMaxLength자 이내)',
          maxLength: kCrewDescriptionMaxLength,
          maxLines: 5,
          height: 160,
          inputFormatters: [LengthLimitingTextInputFormatter(kCrewDescriptionMaxLength)],
        ),
      ),
    );
  }
}
