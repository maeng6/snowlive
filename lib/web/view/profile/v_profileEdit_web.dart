import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/onboarding/w_onboarding_profile_image_picker_web.dart';
import 'package:com.snowlive/web/view/onboarding/w_onboarding_profile_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_onboarding_web.dart'
    show kOnboardingSexOptions, kOnboardingSkiOrBoardOptions;
import 'package:com.snowlive/web/viewmodel/profile/vm_profileEdit_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
import 'package:com.snowlive/web/widget/w_web_form_fields_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:com.snowlive/web/widget/w_web_switch_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// PC 폼 폭. 입력 항목이 짧아(닉네임 10자 등) 글쓰기 폼(800)처럼 넓히면 칸만 길어진다 →
/// 온보딩 프로필 단계(360)보다 조금 넓은 한 열.
const double _kFormMaxWidth = 480;

/// 내 프로필 편집. `#/profile-edit`
///
/// 목업이 없어 앱 프로필 수정과 **같은 항목**(사진 · 닉네임 · 상태메시지 · 자주가는 스키장 ·
/// 종목 · 성별 · 프로필 비공개)을 웹 폼 관례로 담았다 — PC는 헤더 오른쪽 `저장`,
/// 태블릿은 하단 고정바, 모바일은 플로팅 바(커뮤니티 글쓰기와 같은 배치).
/// 사진 원형 · 선택 모달 · 드롭다운은 온보딩 프로필 단계와 같은 위젯이다.
class ProfileEditViewWeb extends StatefulWidget {
  const ProfileEditViewWeb({super.key});

  @override
  State<ProfileEditViewWeb> createState() => _ProfileEditViewWebState();
}

class _ProfileEditViewWebState extends State<ProfileEditViewWeb> {
  final ProfileEditViewModelWeb _vm = Get.find<ProfileEditViewModelWeb>();

  /// 자동로그인이 늦게 확정되면 그때 불러온다. 테스트처럼 인증 VM이 없는 환경에서는
  /// UserViewModel의 user_id만 본다.
  AuthCheckViewModelWeb? get _authVm =>
      Get.isRegistered<AuthCheckViewModelWeb>() ? Get.find<AuthCheckViewModelWeb>() : null;
  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    final auth = _authVm;
    if (auth != null) {
      _authWorker = ever<WebAuthStatus>(auth.statusRx, (status) {
        if (status == WebAuthStatus.authenticated) _load();
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    super.dispose();
  }

  void _load() {
    if (_vm.myUserId == null) return;
    // 이미 불러왔거나 불러오는 중이면 다시 부르지 않는다(입력 중인 내용이 날아간다).
    if (_vm.loadState == ProfileEditLoadState.ready ||
        _vm.loadState == ProfileEditLoadState.loading) {
      return;
    }
    _vm.load();
  }

  bool get _isGuest {
    final auth = _authVm;
    if (auth != null) return auth.status == WebAuthStatus.unauthenticated;
    return _vm.myUserId == null;
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

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else if (_vm.myUserId != null) {
      Get.offNamed('${WebRoutes.userProfile}?id=${_vm.myUserId}');
    } else {
      Get.offAllNamed(WebRoutes.home);
    }
  }

  Future<void> _save() async {
    final result = await _vm.save();
    if (!mounted) return;
    switch (result) {
      case ProfileEditResult.success:
        _goBack();
        _toast('프로필을 수정했어요.');
      case ProfileEditResult.nicknameTaken:
        // 닉네임 칸 아래에 문구가 뜬다.
        break;
      case ProfileEditResult.imageFailed:
        _toast('사진을 올리지 못했어요. 잠시 후 다시 시도해 주세요.');
      case ProfileEditResult.failed:
        _toast('프로필 수정에 실패했어요. 잠시 후 다시 시도해 주세요.');
    }
  }

  Future<void> _pickImage() async {
    final picked = await showOnboardingProfileImagePicker(context);
    if (picked != null) _vm.pickImage(picked);
  }

  /// 저장 버튼은 폼을 다 불러온 뒤에만 그린다.
  /// ⚠️ 이 값만 보는 Obx가 있으니 Rx를 **반드시** 읽는다.
  bool get _showActions => _vm.loadState == ProfileEditLoadState.ready;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;

    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        padding: webSubPagePadding(
          context,
          bottom: isMobile ? kWebFloatingBottomBarHeight + SDSSpacing.md : SDSSpacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? _kFormMaxWidth : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WebPageHeader(
                  title: '프로필 편집',
                  onBack: _goBack,
                  actions: [
                    if (isDesktop)
                      Obx(() => _showActions ? _buildSaveButton(expand: false) : const SizedBox.shrink()),
                  ],
                ),
                SizedBox(height: webFormHeaderGap(context)),
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );

    if (isDesktop) return scrollArea;

    final bar = Obx(() {
      if (!_showActions) return const SizedBox.shrink();
      if (isMobile) return WebFloatingBottomBar(child: _buildSaveButton(expand: true));
      return Container(
        decoration: BoxDecoration(
          color: SDSColor.snowliveWhite,
          border: Border(top: BorderSide(color: SDSColor.gray100)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: SDSSpacing.md),
        child: _buildSaveButton(expand: true),
      );
    });

    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          // 태블릿은 바가 콘텐츠를 가리지 않게 스크롤 영역을 줄인다(글쓰기와 같은 패턴).
          Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 0 : 80),
            child: scrollArea,
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: bar),
        ],
      ),
    );
  }

  Widget _buildSaveButton({required bool expand}) {
    return Obx(() {
      final enabled = _vm.canSave;
      final saving = _vm.isSaving;
      if (expand) {
        return WebBottomBarButton(
          label: '저장',
          background: SDSColor.snowliveBlue,
          foreground: SDSColor.snowliveWhite,
          onTap: enabled ? _save : null,
          leading: saving ? const _Spinner() : null,
        );
      }
      // PC 헤더 버튼 — 커뮤니티 글쓰기 `작성 완료`와 같은 규격(높이 40, 패딩 16, 라운드 5).
      return SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: enabled ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: SDSColor.snowliveBlue,
            disabledBackgroundColor: SDSColor.gray200,
            elevation: 0,
            shadowColor: Colors.transparent,
            overlayColor: Colors.transparent,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (saving) ...[const _Spinner(), const SizedBox(width: SDSSpacing.sm)],
              Text('저장', style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.snowliveWhite)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBody() {
    if (_isGuest) {
      return WebEmptyState(
        message: '로그인이 필요해요.',
        actionLabel: '로그인하기',
        onAction: () => Get.toNamed(WebRoutes.login),
      );
    }
    return Obx(() {
      switch (_vm.loadState) {
        case ProfileEditLoadState.ready:
          return _buildForm();
        case ProfileEditLoadState.failed:
          return WebEmptyState(
            message: '프로필을 불러오지 못했어요.',
            actionLabel: '다시 시도',
            onAction: _vm.load,
          );
        case ProfileEditLoadState.idle:
        case ProfileEditLoadState.loading:
          return const _FormSkeleton();
      }
    });
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Obx(() => ProfileImageCircleWeb(
                image: _vm.newImage,
                imageUrl: _vm.imageUrl,
                onPick: _pickImage,
                onRemove: _vm.removeImage,
              )),
        ),
        const SizedBox(height: SDSSpacing.xl),
        Obx(() => WebFormTextField(
              label: '닉네임',
              isRequired: true,
              controller: _vm.nicknameController,
              hint: '닉네임을 입력해 주세요.(최대 $kProfileNicknameMaxLength자)',
              maxLength: kProfileNicknameMaxLength,
              // 앱과 같이 공백 입력을 막는다.
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
              errorText: _vm.nicknameError,
            )),
        const SizedBox(height: SDSSpacing.md),
        WebFormTextField(
          label: '상태메시지',
          controller: _vm.stateMsgController,
          hint: '상태메시지를 입력해 주세요.(최대 $kProfileStateMsgMaxLength자)',
          maxLength: kProfileStateMsgMaxLength,
        ),
        const SizedBox(height: SDSSpacing.md),
        Obx(() => WebFormDropdownField<int>(
              label: '자주가는 스키장',
              isRequired: true,
              value: _vm.hasResort ? (resortNameList[_vm.resortIndex] ?? '') : '자주가는 스키장을 선택해주세요.',
              placeholder: '자주가는 스키장을 선택해주세요.',
              values: kOnboardingSelectableResortIndexes,
              labelOf: (index) => resortNameList[index] ?? '',
              onSelected: _vm.selectResort,
              helperText: '자주가는 스키장과 관련된 다양한 서비스를 즐길 수 있습니다',
              sheetShowsLabelTitle: true,
              sheetAlignStart: true,
            )),
        const SizedBox(height: SDSSpacing.md),
        Obx(() => WebFormDropdownField<String>(
              label: '종목',
              isRequired: true,
              value: _vm.skiOrBoard.isEmpty ? '스키 또는 스노보드 선택' : _vm.skiOrBoard,
              placeholder: '스키 또는 스노보드 선택',
              values: kOnboardingSkiOrBoardOptions,
              labelOf: (value) => value,
              onSelected: _vm.selectSkiOrBoard,
              sheetShowsLabelTitle: true,
              sheetAlignStart: true,
            )),
        const SizedBox(height: SDSSpacing.md),
        Obx(() => WebFormDropdownField<String>(
              label: '성별',
              isRequired: true,
              value: _vm.sex.isEmpty ? '성별 선택' : _vm.sex,
              placeholder: '성별 선택',
              values: kOnboardingSexOptions,
              labelOf: (value) => value,
              onSelected: _vm.selectSex,
              sheetShowsLabelTitle: true,
              sheetAlignStart: true,
            )),
        const SizedBox(height: SDSSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('프로필 비공개',
                      style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900)),
                  const SizedBox(height: 2),
                  Text('켜면 다른 사람에게 라이딩 통계·방명록·시즌 기록실이 보이지 않아요.',
                      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500)),
                ],
              ),
            ),
            Obx(() => WebSwitch(value: _vm.hideProfile, onChanged: _vm.setHideProfile)),
          ],
        ),
      ],
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(SDSColor.snowliveWhite),
      ),
    );
  }
}

/// 내 정보를 불러오는 동안의 자리 — 사진 원형 + 입력칸들.
class _FormSkeleton extends StatelessWidget {
  const _FormSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: SkeletonBox(width: 120, height: 120, isCircle: true)),
          const SizedBox(height: SDSSpacing.xl),
          for (var i = 0; i < 5; i++) ...[
            const SkeletonBox(width: 80, height: 16),
            const SizedBox(height: SDSSpacing.sm),
            const SkeletonBox(height: 48, radius: 6),
            const SizedBox(height: SDSSpacing.md),
          ],
        ],
      ),
    );
  }
}
