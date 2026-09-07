import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_image_color_picker_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewcreate_image_picker_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewCreate_web.dart';
import 'package:com.snowlive/web/widget/w_web_form_fields_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 목업 본문 폭(가운데 한 줄로 세우는 폼이라 좁다).
const double kCrewCreateContentMaxWidth = 360;

/// 인트로 일러스트(모바일 크루 온보딩과 같은 에셋).
const String _kCrewIntroIllust = 'assets/imgs/imgs/img_livecrew_1.png';

/// 모바일 하단 고정 버튼 영역 높이(패딩 8+16 + 버튼 48).
const double _kMobileBarHeight = 72;

/// 이 높이보다 낮으면 색상 줄을 아래로 밀지 않는다(밀면 넘친다).
const double _kMobileSpacedMinHeight = 520;

/// 크루 만들기. 한 라우트 안에서 3단계로 진행한다(목업).
/// 0 = 소개 / 1 = 이름·베이스 스키장 / 2 = 이미지·대표 색상.
class CrewCreateViewWeb extends StatefulWidget {
  const CrewCreateViewWeb({super.key});

  @override
  State<CrewCreateViewWeb> createState() => _CrewCreateViewWebState();
}

class _CrewCreateViewWebState extends State<CrewCreateViewWeb> {
  final CrewCreateViewModelWeb _vm = Get.find<CrewCreateViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final TextEditingController _nameController = TextEditingController();

  int _step = 0;

  @override
  void initState() {
    super.initState();
    _vm.reset();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onBack() {
    if (_step > 0) {
      setState(() => _step -= 1);
      return;
    }
    // URL 직접 진입이면 돌아갈 화면이 없다 → 라이브크루 홈으로.
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }
    Get.offAllNamed(WebRoutes.liveCrew);
  }

  Future<void> _onNext() async {
    final ok = await _vm.validateName();
    if (!ok || !mounted) return;
    setState(() => _step = 2);
  }

  Future<void> _onPickImage() async {
    final picked = await showCrewImagePicker(context, initial: _vm.logoFile);
    if (picked != null) _vm.setLogoFile(picked);
  }

  Future<void> _onCreate() async {
    if (_userVm.user.user_id == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    final result = await _vm.create();
    if (!mounted) return;
    if (!result.ok) {
      Get.snackbar('알림', result.message ?? '크루 생성에 실패했어요. 잠시 후 다시 시도해주세요.');
      return;
    }
    await _showDoneDialog();
    if (!mounted) return;
    final crewId = result.crewId;
    // 만든 크루의 크루홈으로 보낸다. id를 못 받았으면 라이브크루 홈으로.
    if (crewId != null) {
      Get.offAllNamed('${WebRoutes.crewHome}?id=$crewId');
    } else {
      Get.offAllNamed(WebRoutes.liveCrew);
    }
  }

  Future<void> _showDoneDialog() {
    return showWebOverlayModal<void>(
      context: context,
      barrierDismissible: false,
      builder: (_, close) => Material(
        color: SDSColor.snowliveWhite,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 288),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(SDSSpacing.lg, SDSSpacing.lg, SDSSpacing.lg, SDSSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '크루 생성이 완료되었어요!',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                ),
                const SizedBox(height: SDSSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: close,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SDSColor.snowliveBlue,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      '확인',
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    // 모바일 목업은 진행 버튼이 **하단 고정 전체폭**이다(상단 우측 버튼은 없다).
    final isMobile = context.screenType == WebScreenType.mobile;

    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        isMobile ? _kMobileBarHeight : SDSSpacing.xl,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(isMobile: isMobile),
              const SizedBox(height: SDSSpacing.xl),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kCrewCreateContentMaxWidth),
                  child: Obx(() => _buildStep(
                        isMobile: isMobile,
                        availableHeight: constraints.maxHeight,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!isMobile) return scrollArea;

    // 콘텐츠가 짧으면 스크롤 영역 Container가 뷰포트를 못 채워 셸의 표면 색(연보라)이
    // 하단에 띠처럼 배어 나온다(실측) → 스택 전체에 흰 배경을 깔아 막는다.
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
      children: [
        scrollArea,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          // 흰 배경을 깔지 않으면 셸의 표면 색이 배어 나온다.
          child: Container(
            color: SDSColor.snowliveWhite,
            padding: const EdgeInsets.fromLTRB(SDSSpacing.md, SDSSpacing.sm, SDSSpacing.md, SDSSpacing.md),
            child: Obx(() => _buildPrimaryButton(fullWidth: true, isMobile: true)),
          ),
        ),
      ],
      ),
    );
  }

  /// 단계별 진행 버튼. 모바일은 하단 고정, 그 외는 상단 우측(목업).
  /// 라벨이 폭에 따라 다르다 — 목업 그대로다.
  Widget _buildPrimaryButton({required bool fullWidth, required bool isMobile}) {
    final label = switch (_step) {
      0 => isMobile ? '크루 만들기' : '라이브크루 만들기',
      1 => '다음',
      // 모바일 목업은 마지막 단계도 `다음`이다(데스크탑은 `만들기`).
      _ => isMobile ? '다음' : '만들기',
    };
    final onPressed = switch (_step) {
      0 => () => setState(() => _step = 1),
      1 => _vm.canGoToImageStep ? _onNext : null,
      _ => _onCreate,
    };

    return ElevatedButton(
      onPressed: _vm.isSubmitting ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        disabledBackgroundColor: SDSColor.gray300,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: fullWidth ? 0 : 28, vertical: 15),
        minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite),
      ),
    );
  }

  /// 목업의 상단 줄 — 좌측 `←`, 우측 진행 버튼(1단계 `다음` / 2단계 `만들기`).
  /// 소개 단계와 모바일에는 우측 버튼이 없다(하단 전체폭 버튼을 쓴다).
  Widget _buildTopBar({required bool isMobile}) {
    return Row(
      children: [
        InkWell(
          onTap: _onBack,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(Icons.arrow_back, size: 24, color: SDSColor.gray900),
          ),
        ),
        const Spacer(),
        if (!isMobile && _step > 0)
          Obx(() => _buildPrimaryButton(fullWidth: false, isMobile: false)),
      ],
    );
  }

  Widget _buildStep({required bool isMobile, required double availableHeight}) {
    // ⚠️ Obx 빌더는 관찰 대상을 **무조건 하나 읽어야** 한다. 소개 단계는 뷰모델 값을
    // 하나도 안 쓰는데, 그대로 두면 GetX가 "improper use of a GetX"로 화면을 죽인다
    // (커뮤니티·친구 화면에서 두 번 겪었다).
    _vm.colorIndex;
    _vm.nameError;
    switch (_step) {
      case 0:
        return _buildIntro(isMobile: isMobile);
      case 1:
        return _buildInfo(isMobile: isMobile);
      default:
        return _buildImageAndColor(isMobile: isMobile, availableHeight: availableHeight);
    }
  }

  Widget _buildIntro({required bool isMobile}) {
    return Column(
      children: [
        Text(
          '친구들과 함께 즐길 수 있는\n라이브 크루와 함께해요',
          textAlign: TextAlign.center,
          style: SDSTextStyle.bold.copyWith(fontSize: 20, color: SDSColor.gray900, height: 1.4),
        ),
        const SizedBox(height: SDSSpacing.sm),
        Text(
          '라이브 크루를 통해 같은 라이딩 스타일의 친구들과\n교류하며 라이딩의 즐거움을 더 높여 보세요.',
          textAlign: TextAlign.center,
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500, height: 1.5),
        ),
        const SizedBox(height: SDSSpacing.xl),
        Image.asset(_kCrewIntroIllust, fit: BoxFit.contain),
        if (!isMobile) ...[
          const SizedBox(height: SDSSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: _buildPrimaryButton(fullWidth: true, isMobile: false),
          ),
        ],
      ],
    );
  }

  Widget _buildInfo({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '라이브크루 정보를 입력해 주세요',
          style: SDSTextStyle.bold.copyWith(fontSize: 20, color: SDSColor.gray900),
        ),
        const SizedBox(height: 6),
        Text(
          '간단한 정보 입력 후 친구들과 즐거운 크루 활동을 시작해 보세요',
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
        ),
        const SizedBox(height: SDSSpacing.xl),
        WebFormTextField(
          label: '라이브크루 이름',
          controller: _nameController,
          hint: '이름을 입력해주세요(최대 $kCrewNameMaxLength자 이내)',
          maxLength: kCrewNameMaxLength,
          inputFormatters: [LengthLimitingTextInputFormatter(kCrewNameMaxLength)],
          onChanged: _vm.setCrewName,
          helperText: '크루명은 한 번 설정한 뒤에 수정이 불가능합니다.',
          errorText: _vm.nameError,
          // 모바일 목업만 라벨에 `*`가 붙어 있다.
          isRequired: isMobile,
        ),
        const SizedBox(height: SDSSpacing.lg),
        WebFormDropdownField<int>(
          // 좁은 폭에서는 목업대로 짧은 라벨을 쓴다.
          label: isMobile ? '베이스 스키장' : '크루 베이스 스키장',
          value: _vm.resortName,
          placeholder: '베이스 스키장을 선택해주세요',
          values: List.generate(resortNameList.length, (i) => i),
          labelOf: (index) => resortNameList[index] ?? '',
          onSelected: _vm.selectResort,
          helperText: '베이스 리조트를 변경하면 자주가는 리조트도 함께 바뀝니다.',
          isRequired: isMobile,
        ),
      ],
    );
  }

  Widget _buildImageAndColor({required bool isMobile, required double availableHeight}) {
    // 색상 줄을 아래로 미는 건 화면이 충분히 높을 때만(억지로 늘리면 넘친다).
    final spaced = isMobile && availableHeight >= _kMobileSpacedMinHeight;

    final picker = CrewImageColorPicker(
      pickedFile: _vm.logoFile,
      color: _vm.selectedColor,
      colorIndex: _vm.colorIndex,
      onPickImage: _onPickImage,
      onRemoveImage: () => _vm.setLogoFile(null),
      onColorSelected: _vm.selectColor,
      fillHeight: spaced,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '라이브크루 이미지와 대표 색상을\n등록해 주세요',
          style: SDSTextStyle.bold.copyWith(fontSize: 20, color: SDSColor.gray900, height: 1.4),
        ),
        const SizedBox(height: 6),
        Text(
          '이미지와 대표 색상은 크루 설정에서 변경하실 수 있어요',
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
        ),
        const SizedBox(height: SDSSpacing.xxl),
        if (spaced)
          // Spacer를 쓰려면 높이가 정해져 있어야 한다.
          SizedBox(height: availableHeight - _kMobileBarHeight - 140, child: picker)
        else
          picker,
      ],
    );
  }
}
