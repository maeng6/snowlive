import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarket_alert.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketAlert.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_form_fields_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_delete_chip_web.dart';
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart' show showWebConfirmDialog;
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 목업 실측 802. 커뮤니티 작성 폼(800)과 같은 급의 좁은 폼 폭이다 —
/// 넓히면 입력창만 길어지고 칩이 한 줄에 너무 많이 늘어선다.
const double kFleamarketAlertContentMaxWidth = 800;

/// 키워드 알림 설정 진입 공통 처리(PC 사이드바·태블릿/모바일 하단바 공용).
/// 미로그인 확정 상태면 페이지에 들어가지 않고 로그인 유도 팝업을 띄운다 —
/// PC·태블릿·모바일 모두 동일. 자동로그인 확인 중(checking)이면 일단
/// 들여보낸다(페이지의 auth 워커가 늦은 확정을 처리한다).
Future<void> openFleamarketAlert(BuildContext context) async {
  final bool isGuest =
      Get.find<AuthCheckViewModelWeb>().status == WebAuthStatus.unauthenticated;
  if (!isGuest) {
    Get.toNamed(WebRoutes.fleamarketAlert);
    return;
  }
  final bool goLogin = await showWebConfirmDialog(
    context: context,
    title: '로그인이 필요해요',
    message: '키워드 알림 설정은 로그인 후 이용할 수 있어요.',
    confirmLabel: '로그인하기',
  );
  if (goLogin) Get.toNamed(WebRoutes.login);
}

/// 상위 카테고리에 따른 하위 카테고리 목록.
/// 값은 앱·웹 작성 폼과 동일하다(목업 모달에 그려진 항목은 더미다).
List<String> alertCategorySubListFor(String categoryMain) =>
    categoryMain == '스키' ? kFleamarketCategorySubSkiList : kFleamarketCategorySubBoardList;

enum _AlertTab {
  keyword('키워드 알림'),
  category('카테고리 알림');

  const _AlertTab(this.label);
  final String label;
}

/// 중고거래 키워드/카테고리 알림 설정 화면.
///
/// 코어 [FleamarketAlertViewModel]을 그대로 쓴다(웹 비호환 의존성이 없다).
/// 다만 그 뷰모델은 최대개수·중복·실패 안내를 **내부에서 `Get.snackbar`로 직접
/// 띄운다** — 여기서 같은 문구를 또 띄우지 않고 반환값만 본다.
class FleamarketAlertViewWeb extends StatefulWidget {
  const FleamarketAlertViewWeb({super.key});

  @override
  State<FleamarketAlertViewWeb> createState() => _FleamarketAlertViewWebState();
}

class _FleamarketAlertViewWebState extends State<FleamarketAlertViewWeb> {
  final FleamarketAlertViewModel _vm = Get.find<FleamarketAlertViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();

  final TextEditingController _keywordController = TextEditingController();

  _AlertTab _tab = _AlertTab.keyword;
  Worker? _authWorker;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.fetchAllAlerts());
    // 자동로그인이 늦게 확정되면 최초 조회가 user_id 없이 조용히 실패해 빈 화면이 남는다.
    // 로그인 후 돌아온 경우에도 이 워커가 걸린다 → 로그인 유도 화면을 본문으로 바꿔야
    // 하므로 재조회와 함께 setState도 해준다(게스트 분기는 build에서 읽는다).
    _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (status) {
      if (status != WebAuthStatus.authenticated) return;
      _vm.fetchAllAlerts();
      if (mounted) setState(() {});
    });
    // 입력에 따라 '등록하기' 활성 상태가 바뀐다.
    _keywordController.addListener(_onKeywordChanged);
  }

  @override
  void dispose() {
    // 해제하지 않으면 라우트를 왕복할 때마다 리스너가 쌓여 재조회가 여러 번 나간다.
    _authWorker?.dispose();
    _keywordController.removeListener(_onKeywordChanged);
    _keywordController.dispose();
    super.dispose();
  }

  void _onKeywordChanged() => setState(() {});

  /// 사이드바·하단바로 들어왔으면 pop하면 되지만, URL 직접 진입이나 새로고침 뒤에는
  /// pop할 히스토리가 없어 [Get.back]이 아무 일도 하지 않는다. 그때는 중고거래
  /// 목록으로 보낸다(커뮤니티·중고거래 상세와 같은 처리).
  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      Get.offAllNamed(WebRoutes.fleamarketList);
    }
  }

  bool get _isGuest => _authVm.status == WebAuthStatus.unauthenticated;

  bool get _canSubmit {
    if (_isSubmitting) return false;
    if (_tab == _AlertTab.keyword) {
      return _keywordController.text.trim().isNotEmpty &&
          _vm.keywordAlerts.length < FleamarketAlertViewModel.maxKeywordCount;
    }
    return _vm.categoryAlerts.length < FleamarketAlertViewModel.maxCategoryCount;
  }

  Future<void> _onSubmit() async {
    if (_tab == _AlertTab.keyword) {
      await _addKeyword();
    } else {
      await _addCategory();
    }
  }

  Future<void> _addKeyword() async {
    final keyword = _keywordController.text.trim();
    if (keyword.isEmpty) return;

    setState(() => _isSubmitting = true);
    final ok = await _vm.createKeywordAlert(keyword: keyword);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    // 실패 안내는 뷰모델이 이미 띄웠다. 성공했을 때만 입력창을 비운다.
    if (ok) _keywordController.clear();
  }

  Future<void> _addCategory() async {
    // 상위 → 하위 2단계. 배경 탭으로 닫으면 null이 와서 중단된다.
    final main = await _pickCategory(title: '상위 카테고리', values: kFleamarketCategoryMainList);
    if (main == null || !mounted) return;

    final sub = await _pickCategory(title: '하위 카테고리', values: alertCategorySubListFor(main));
    if (sub == null || !mounted) return;

    setState(() => _isSubmitting = true);
    await _vm.createCategoryAlert(categoryMain: main, categorySub: sub);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  Future<String?> _pickCategory({required String title, required List<String> values}) {
    return showWebFilterSheet<String>(
      context: context,
      values: values,
      labelOf: (v) => v,
      title: title,
      showTitle: true,
      // 목업: 데스크탑·태블릿은 화면 중앙 딤 모달, 모바일은 하단 시트.
      alignItemsStart: true,
      centerOnTablet: true,
      centerOnDesktop: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;

    final Widget scroll = SingleChildScrollView(
      // 여백은 스크롤 영역 안쪽(서브 페이지 공통) — 모바일은 콘텐츠가 하단
      // 플로팅 바 뒤로 지나가도록 바 높이만큼 하단 여백을 확보한다.
      padding: webSubPagePadding(
        context,
        bottom: isMobile && !_isGuest
            ? kWebFloatingBottomBarHeight + SDSSpacing.md
            : SDSSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          // PC만 800 고정 중앙 — 태블릿·모바일은 제한 없이 화면(패딩 제외)을
          // 가득 채운다(올리기·수정·상세와 동일 규칙).
          constraints: BoxConstraints(
            maxWidth: isDesktop
                ? kFleamarketAlertContentMaxWidth
                : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleRow(isMobile),
              // 타이틀 ↔ 탭 PC 40(피그마 64:105620) / 태블릿·모바일 26
              // (올리기 헤더↔폼과 동일 규칙).
              SizedBox(height: isDesktop ? 40 : 26),
              if (_isGuest) _buildGuestBody() else ..._buildBody(),
            ],
          ),
        ),
      ),
    );

    // PC·태블릿은 '등록하기'가 타이틀 줄 우측이라 하단바가 없다(올리기와 동일).
    if (!isMobile || _isGuest) {
      return Container(color: SDSColor.snowliveWhite, child: scroll);
    }

    // 모바일: 하단 플로팅 바 — 목록·올리기 하단바와 동일 규격(페이드 + 버튼 48).
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          scroll,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: WebFloatingBottomBar(
              child: _SubmitButton(
                enabled: _canSubmit,
                isSubmitting: _isSubmitting,
                onTap: _onSubmit,
                expand: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(bool isMobile) {
    // 서브 페이지 공통 헤더 표준(WebPageHeader) — 타이틀·뒤로가기 크기는
    // 위젯이 브레이크포인트별로 처리한다. PC·태블릿은 등록하기가 우측에 온다.
    return WebPageHeader(
      title: '키워드 알림 설정',
      onBack: _goBack,
      actions: [
        if (!isMobile && !_isGuest)
          _SubmitButton(enabled: _canSubmit, isSubmitting: _isSubmitting, onTap: _onSubmit),
      ],
    );
  }

  /// 이 화면의 데이터는 전부 로그인 전용이다(뷰모델이 user_id 없으면 조용히 return).
  /// 빈 목록만 보여주면 왜 비었는지 알 수 없어 로그인을 유도한다.
  Widget _buildGuestBody() {
    return WebEmptyState(
      message: '로그인하고 관심 키워드·카테고리 알림을 받아보세요.',
      actionLabel: '로그인하기',
      onAction: () => Get.toNamed(WebRoutes.login),
    );
  }

  List<Widget> _buildBody() {
    return [
      // 탭: bold 16, 비활성 gray200, 1px 세로선 구분자, 간격 10 (피그마 64:105852).
      WebTextTabs<_AlertTab>(
        values: _AlertTab.values,
        selected: _tab,
        labelOf: (v) => v.label,
        onSelected: (v) {
          if (v == _tab) return;
          setState(() => _tab = v);
        },
        fontSize: 16,
        inactiveBold: true,
        inactiveColor: SDSColor.gray200,
        lineDivider: true,
        dividerGap: 10,
      ),
      // 탭 ↔ 폼 40 (피그마 64:105620).
      const SizedBox(height: 40),
      if (_tab == _AlertTab.keyword) ...[
        WebFormTextField(
          label: '키워드 알림 추가',
          controller: _keywordController,
          hint: '예. 버튼, 플레이트',
          maxLength: 20,
        ),
        // 인풋 ↔ 헬퍼 10, 헬퍼 12 gray500 (피그마 64:105712 —
        // WebFormTextField 내장 헬퍼는 간격 6·gray400이라 직접 그린다).
        const SizedBox(height: 10),
        Text(
          '알림 받고 싶은 키워드를 입력해주세요.',
          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
        ),
        // 폼 ↔ 카운터 30 (피그마 64:105620).
        const SizedBox(height: 30),
      ],
      Obx(() => _tab == _AlertTab.keyword ? _buildKeywordList() : _buildCategoryList()),
    ];
  }

  Widget _buildKeywordList() {
    final items = _vm.keywordAlerts;
    return _buildCountedList(
      counterLabel: '등록된 키워드',
      count: items.length,
      max: FleamarketAlertViewModel.maxKeywordCount,
      isLoading: _vm.isKeywordLoading.value,
      emptyMessage: '등록된 키워드가 아직 없어요',
      chips: [
        for (final KeywordAlert item in items)
          WebDeleteChip(
            label: item.keyword ?? '',
            onDelete: () {
              final id = item.keywordAlertId;
              if (id != null) _vm.deleteKeywordAlert(keywordAlertId: id);
            },
          ),
      ],
    );
  }

  Widget _buildCategoryList() {
    final items = _vm.categoryAlerts;
    return _buildCountedList(
      counterLabel: '등록된 카테고리',
      count: items.length,
      max: FleamarketAlertViewModel.maxCategoryCount,
      isLoading: _vm.isCategoryLoading.value,
      emptyMessage: '등록된 카테고리가 아직 없어요',
      chips: [
        for (final CategoryAlert item in items)
          WebDeleteChip(
            label: '${item.categoryMain ?? ''} > ${item.categorySub ?? ''}',
            onDelete: () {
              final id = item.categoryAlertId;
              if (id != null) _vm.deleteCategoryAlert(categoryAlertId: id);
            },
          ),
      ],
    );
  }

  /// `등록된 OO n/10` 한 줄 + 칩 Wrap(또는 빈 상태). 목업은 카운터를 한 줄로 쓴다
  /// (모바일 앱의 좌우 분리 Row가 아니다).
  Widget _buildCountedList({
    required String counterLabel,
    required int count,
    required int max,
    required bool isLoading,
    required String emptyMessage,
    required List<Widget> chips,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$counterLabel $count/$max',
          style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
        ),
        // 카운터 ↔ 칩 8 (피그마 64:105620).
        const SizedBox(height: SDSSpacing.sm),
        if (chips.isEmpty)
          // 첫 로딩 중에 '없어요'를 먼저 보여주면 데이터가 오는 순간 깜빡인다.
          isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : WebEmptyState(message: emptyMessage)
        else
          // 칩 간격 6 (피그마 64:105810).
          Wrap(spacing: 6, runSpacing: 6, children: chips),
      ],
    );
  }
}

/// 목업의 `등록하기`. 데스크탑은 타이틀 줄 우상단의 작은 버튼, 그 외는 하단 전체폭.
class _SubmitButton extends StatelessWidget {
  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onTap;
  final bool expand;

  const _SubmitButton({
    required this.enabled,
    required this.isSubmitting,
    required this.onTap,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    // 컴팩트(PC 헤더)는 업로드 헤더 버튼(판매하기)과 동일 규격 —
    // 높이 40 고정(visualDensity에 눌리지 않게 SizedBox + minimumSize 병행),
    // 패딩 16, 라운드 5, bold 16, 비활성은 gray200 배경에 흰 글자 유지.
    final button = ElevatedButton(
      onPressed: enabled ? onTap : null,
      // hover는 그림자·리플 대신 배경에 검정 10% 블렌드 즉시 적용 —
      // 사이드바·하단바·팝업 박스 버튼과 동일한 웹 공통 규칙.
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        animationDuration: Duration.zero,
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? SDSColor.gray200
              : states.contains(WidgetState.hovered)
                  ? Color.alphaBlend(
                      Colors.black.withValues(alpha: 0.1), SDSColor.snowliveBlue)
                  : SDSColor.snowliveBlue,
        ),
        minimumSize: WidgetStatePropertyAll(
          expand ? const Size(double.infinity, 48) : const Size(0, 40),
        ),
        padding: WidgetStatePropertyAll(
          expand ? null : const EdgeInsets.symmetric(horizontal: 16),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            // 전체폭(모바일 플로팅 바)은 목록 하단바 버튼과 같은 라운드 6.
            borderRadius: BorderRadius.circular(expand ? 6 : 5),
          ),
        ),
      ),
      // 제출 중에는 라벨을 **투명하게 남겨** 버튼 폭을 고정한 채,
      // 그 자리에 스피너만 가운데로 띄운다(라벨 앞에 끼우는 방식 아님).
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: isSubmitting ? 0 : 1,
            child: Text(
              '등록하기',
              style: SDSTextStyle.bold.copyWith(
                // 전체폭(모바일 플로팅 바)은 목록 하단바 버튼과 같은 bold 15.
                fontSize: expand ? 15 : 16,
                color: SDSColor.snowliveWhite,
              ),
            ),
          ),
          if (isSubmitting)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
        ],
      ),
    );
    // visualDensity(웹 기본 compact)가 minimumSize 높이를 ~8px 깎으므로
    // 두 변형 모두 SizedBox로 높이를 강제한다(전체폭 48 / 컴팩트 40).
    return SizedBox(height: expand ? 48 : 40, child: button);
  }
}
