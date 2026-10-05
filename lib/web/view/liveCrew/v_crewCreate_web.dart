import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_image_color_picker_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewcreate_image_picker_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewCreate_web.dart';
import 'package:com.snowlive/web/widget/w_web_form_fields_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 목업 본문 폭(가운데 한 줄로 세우는 폼이라 좁다). PC 목업(174:90051)도 같은 358이다
/// — 만들기 플로우는 세 폭 모두 **같은 레이아웃**을 쓴다(사용자 확정).
const double kCrewCreateContentMaxWidth = 358;

/// PC에서 `←`와 진행 버튼이 서는 줄의 폭. 목업은 콘텐츠 영역(1240) 좌우 220 안쪽
/// = 800이다. 본문(358)보다 넓어서 버튼이 화면 구석에 붙지 않는다.
const double kCrewCreateTopBarMaxWidth = 800;

/// 인트로 일러스트(모바일 크루 온보딩과 같은 에셋).
const String _kCrewIntroIllust = 'assets/imgs/imgs/img_livecrew_1.png';

/// 모바일 하단 고정 버튼 영역 높이(패딩 8+16 + 버튼 48).
const double _kMobileBarHeight = 72;

/// 제목 ↔ 부제 (목업 10).
const double _kTitleGap = 10;

/// 입력 단계 제목 — ExtraBold 24(줄높이 1.36) + 부제 Regular 14.
/// 부제는 목업이 **검정 40%** 라 gray500이 아니다(조금 더 진하다).
class _StepTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: 24,
            color: SDSColor.gray900,
            height: 1.36,
          ),
        ),
        const SizedBox(height: _kTitleGap),
        Text(
          subtitle,
          style: SDSTextStyle.regular.copyWith(
            fontSize: 14,
            color: SDSColor.gray900.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

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
    // 3단계에서 색을 고르면 **색마다 다른 마크 이미지**로 갈아끼운다 → 미리 받아 둔다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) precacheCrewDefaultLogos(context);
    });
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
      // 웹 표준 팝업 카드 스펙(라운드 16 / 최대폭 320 / 패딩 24,28,24,12 /
      // 타이틀 bold 16) — showWebConfirmDialog와 동일. 버튼 구성만 목업대로.
      builder: (_, close) => Material(
        color: SDSColor.snowliveWhite,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '크루 생성이 완료되었어요!',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
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
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 15,
                        color: SDSColor.snowliveWhite,
                      ),
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

    // 페이지 여백은 서브 페이지 공통값(PC 40/58 · 태블릿 20/20 · 모바일 16/16).
    // 하단만 화면별로 다르다 — 모바일은 고정 버튼 바 높이를 비운다.
    final pagePadding = webSubPagePadding(context);
    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        pagePadding.left,
        pagePadding.top,
        pagePadding.right,
        isMobile ? _kMobileBarHeight : SDSSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(isDesktop: isDesktop, isMobile: isMobile),
            // 바 ↔ 제목: PC 40 (목업 — 아이콘 bottom 151, 제목 192) / 그 외 32
            SizedBox(height: isDesktop ? 40 : SDSSpacing.xl),
            Center(
              child: ConstrainedBox(
                // 좁은 폭에서는 **페이지 여백(태블릿 20 / 모바일 16) 안쪽을 꽉 채운다** —
                // 358로 묶으면 태블릿에서 가운데 좁은 기둥처럼 떠 보인다(다른 화면과 다름).
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? kCrewCreateContentMaxWidth : double.infinity,
                ),
                child: Obx(() => _buildStep(isMobile: isMobile)),
              ),
            ),
          ],
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
              padding: const EdgeInsets.fromLTRB(
                SDSSpacing.md,
                SDSSpacing.sm,
                SDSSpacing.md,
                SDSSpacing.md,
              ),
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

    // 목업 comp_button — 라운드 5 · bold 16(줄높이 20).
    // 하단 전체폭 버튼은 높이 48, **상단 우측 버튼은 목업대로 40**(좌우 패딩 16·최소 폭 88).
    return ElevatedButton(
      onPressed: _vm.isSubmitting ? null : onPressed,
      // hover는 웹 공통 채움 버튼 규칙 — **배경에 검정 10%**를 섞어 어두워진다.
      // ⚠️ `elevation: 0`만으로는 부족하다. ElevatedButton은 hover에서 elevation을
      // 한 단계 올려 그림자를 만들므로 모든 상태의 elevation을 0으로 못 박는다.
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        animationDuration: Duration.zero,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return SDSColor.gray300;
          if (states.contains(WidgetState.hovered)) {
            return Color.alphaBlend(Colors.black.withValues(alpha: 0.1), SDSColor.snowliveBlue);
          }
          return SDSColor.snowliveBlue;
        }),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: fullWidth ? 0 : 16, vertical: 10),
        ),
        minimumSize: WidgetStatePropertyAll(
          fullWidth ? const Size(double.infinity, 48) : const Size(88, 40),
        ),
        // ⚠️ 웹 기본 compact density가 minimumSize 높이를 8 깎는다 → 표준으로 고정해야
        // 두 버튼 모두 실제로 48이 된다(fixedSize는 폭까지 묶어서 쓰지 않는다).
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(
          fontSize: 16,
          height: 20 / 16,
          color: SDSColor.snowliveWhite,
        ),
      ),
    );
  }

  /// 목업의 상단 줄 — 좌측 `←`, 우측 진행 버튼(1단계 `다음` / 2단계 `만들기`).
  /// 소개 단계와 모바일에는 우측 버튼이 없다(하단 전체폭 버튼을 쓴다).
  Widget _buildTopBar({required bool isDesktop, required bool isMobile}) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 공통 헤더 표준 뒤로가기(30, hover 페이드).
        // 좌측 히트 여백만 0 — 아이콘이 콘텐츠 좌측선에 붙는다.
        WebIconButton(
          onTap: _onBack,
          padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
          icon: const WebBackIcon(size: 30),
        ),
        const Spacer(),
        if (!isMobile && _step > 0)
          Obx(() => _buildPrimaryButton(fullWidth: false, isMobile: false)),
      ],
    );

    // PC는 목업처럼 **폭 800 줄**을 가운데 두어, 버튼이 넓은 화면 구석까지 밀려나지 않게 한다.
    if (!isDesktop) return row;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kCrewCreateTopBarMaxWidth),
        child: row,
      ),
    );
  }

  Widget _buildStep({required bool isMobile}) {
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
        return _buildImageAndColor(isMobile: isMobile);
    }
  }

  Widget _buildIntro({required bool isMobile}) {
    return Column(
      children: [
        // 소개 단계만 **가운데 정렬**이고 제목이 한 단계 크다(목업 comp_page_title).
        Text(
          '친구들과 함께 즐길 수 있는\n라이브 크루와 함께해요',
          textAlign: TextAlign.center,
          style: SDSTextStyle.bold.copyWith(fontSize: 26, color: SDSColor.gray900, height: 36 / 26),
        ),
        const SizedBox(height: _kTitleGap),
        Text(
          '라이브 크루를 통해 같은 라이딩 스타일의 친구들과\n교류하며 라이딩의 즐거움을 더 높여 보세요.',
          textAlign: TextAlign.center,
          style: SDSTextStyle.regular.copyWith(
            fontSize: 14,
            color: SDSColor.gray500,
            height: 22 / 14,
          ),
        ),
        // 부제 ↔ 일러스트 42 (목업 — 제목 블록 하단 패딩 30 + 12).
        const SizedBox(height: 42),
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
        _StepTitle(title: '라이브크루 정보를 입력해 주세요', subtitle: '간단한 정보 입력 후 친구들과 즐거운 크루 활동을 시작해 보세요'),
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

  Widget _buildImageAndColor({required bool isMobile}) {
    final picker = CrewImageColorPicker(
      pickedFile: _vm.logoFile,
      color: _vm.selectedColor,
      colorIndex: _vm.colorIndex,
      onPickImage: _onPickImage,
      onRemoveImage: () => _vm.setLogoFile(null),
      onColorSelected: _vm.selectColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepTitle(title: '라이브크루 이미지와 대표 색상을\n등록해 주세요', subtitle: '이미지와 대표 색상은 크루 설정에서 변경하실 수 있어요'),
        const SizedBox(height: SDSSpacing.xxl),
        // 모바일도 **고정 간격**으로 그냥 흐르게 둔다. 예전에는 색상 줄을 화면
        // 바닥(하단 버튼 바 위)으로 밀었는데, 제목 높이가 바뀌면 계산이 어긋나
        // 색상 줄이 버튼에 잘렸다. 스크롤 영역이 바 높이만큼 비워 두므로 안 가린다.
        picker,
      ],
    );
  }
}
