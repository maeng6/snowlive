import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_image_color_picker_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_scaffold_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewcreate_image_picker_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewCreate_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// 크루 이미지 및 컬러 설정. `#/livecrew-image?id=334`
class CrewSettingImageViewWeb extends StatefulWidget {
  const CrewSettingImageViewWeb({super.key});

  @override
  State<CrewSettingImageViewWeb> createState() => _CrewSettingImageViewWebState();
}

class _CrewSettingImageViewWebState extends State<CrewSettingImageViewWeb> {
  final CrewSettingViewModelWeb _vm = Get.find<CrewSettingViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  int? _crewId;
  XFile? _pickedLogo;

  /// × 로 기존 로고를 지웠는지. 저장할 때 `crew_logo_url: ''`을 보낸다.
  bool _removedLogo = false;

  /// 선택한 색 인덱스. 서버 값으로 초기화한다.
  int? _colorIndex;

  @override
  void initState() {
    super.initState();
    _crewId = int.tryParse(Get.parameters['id'] ?? '');
    final id = _crewId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        if (_vm.crewId != id) await _vm.load(id);
        if (mounted) setState(() {});
      });
    }
  }

  /// 서버 색 문자열 → 팔레트 인덱스. 팔레트에 없으면 첫 색.
  int get _resolvedColorIndex {
    final picked = _colorIndex;
    if (picked != null) return picked;
    final current = crewColorOf(_vm.info?.color);
    if (current == null) return 0;
    for (var i = 0; i < kCrewColors.length; i++) {
      if (kCrewColors[i].toARGB32() == current.toARGB32()) return i;
    }
    return 0;
  }

  Future<void> _onPickImage() async {
    final picked = await showCrewImagePicker(context, initial: _pickedLogo);
    if (picked != null && mounted) {
      setState(() {
        _pickedLogo = picked;
        _removedLogo = false;
      });
    }
  }

  void _onRemoveImage() {
    setState(() {
      _pickedLogo = null;
      _removedLogo = true;
    });
  }

  Future<void> _onSave() async {
    final result = await _vm.saveImageAndColor(
      newLogo: _pickedLogo,
      removeLogo: _removedLogo,
      colorHex: crewColorToHex(kCrewColors[_resolvedColorIndex]),
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
      title: '크루 이미지 및 컬러 설정',
      showBack: true,
      fallbackRoute: '${WebRoutes.crewSetting}?id=$_crewId',
      actionLabel: '완료',
      onAction: _onSave,
      child: CrewSettingGuard(
        isLoggedIn: _userVm.user.user_id != null,
        canOpen: _vm.canManageCrew,
        child: Obx(() {
          // 서버 값(색·로고)을 읽어야 하므로 구독을 걸어둔다.
          final info = _vm.info;
          return Padding(
            padding: const EdgeInsets.only(top: SDSSpacing.lg),
            child: CrewImageColorPicker(
              pickedFile: _pickedLogo,
              currentLogoUrl: _removedLogo ? null : info?.crewLogoUrl,
              color: kCrewColors[_resolvedColorIndex],
              colorIndex: _resolvedColorIndex,
              onPickImage: _onPickImage,
              onRemoveImage: _onRemoveImage,
              onColorSelected: (index) => setState(() => _colorIndex = index),
            ),
          );
        }),
      ),
    );
  }
}
