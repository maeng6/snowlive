import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_fleamarket_alert.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketAlert.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_form_fields_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_delete_chip_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 목업 실측 802. 커뮤니티 작성 폼(800)과 같은 급의 좁은 폼 폭이다 —
/// 넓히면 입력창만 길어지고 칩이 한 줄에 너무 많이 늘어선다.
const double kFleamarketAlertContentMaxWidth = 800;

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

  /// 하단 고정바 높이(패딩 16*2 + 버튼 48).
  static const double _bottomBarHeight = 80;

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

    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        SDSSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kFleamarketAlertContentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(isDesktop),
                const SizedBox(height: SDSSpacing.lg),
                if (_isGuest) _buildGuestBody() else ..._buildBody(),
              ],
            ),
          ),
        ),
      ),
    );

    // 데스크탑은 '등록하기'가 타이틀 줄 우상단이라 하단바가 없다.
    if (isDesktop || _isGuest) return scrollArea;

    // 태블릿·모바일은 버튼이 뷰포트 하단에 고정된다. 셸이 페이지를 Expanded에 넣으므로
    // Stack의 bottom이 곧 뷰포트 하단이다. Stack 뒤가 비치면 셸 Scaffold의 표면 틴트가
    // 바 위쪽에 라벤더 띠로 보이므로 페이지 배경을 흰색으로 깔아 막는다.
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.only(bottom: _bottomBarHeight), child: scrollArea),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar()),
        ],
      ),
    );
  }

  Widget _buildTitleRow(bool isDesktop) {
    return Row(
      children: [
        IconButton(
          onPressed: _goBack,
          // 좌측 여백을 콘텐츠 왼쪽 끝에 정렬한다.
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.arrow_back, color: SDSColor.gray900, size: 24),
        ),
        const SizedBox(width: SDSSpacing.md),
        Text(
          '키워드 알림 설정',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: isDesktop ? 22 : 18,
            color: SDSColor.gray900,
          ),
        ),
        if (isDesktop && !_isGuest) ...[
          const Spacer(),
          _SubmitButton(enabled: _canSubmit, isSubmitting: _isSubmitting, onTap: _onSubmit),
        ],
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(top: BorderSide(color: SDSColor.gray100)),
      ),
      padding: const EdgeInsets.all(SDSSpacing.md),
      child: _SubmitButton(
        enabled: _canSubmit,
        isSubmitting: _isSubmitting,
        onTap: _onSubmit,
        expand: true,
      ),
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
      WebTextTabs<_AlertTab>(
        values: _AlertTab.values,
        selected: _tab,
        labelOf: (v) => v.label,
        onSelected: (v) {
          if (v == _tab) return;
          setState(() => _tab = v);
        },
      ),
      const SizedBox(height: SDSSpacing.lg),
      if (_tab == _AlertTab.keyword) ...[
        WebFormTextField(
          label: '키워드 알림 추가',
          controller: _keywordController,
          hint: '예: 버튼, 플레이트',
          maxLength: 20,
          helperText: '알림 받고 싶은 키워드를 입력해주세요.',
        ),
        const SizedBox(height: SDSSpacing.lg),
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
        const SizedBox(height: SDSSpacing.md),
        if (chips.isEmpty)
          // 첫 로딩 중에 '없어요'를 먼저 보여주면 데이터가 오는 순간 깜빡인다.
          isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : WebEmptyState(message: emptyMessage)
        else
          Wrap(spacing: SDSSpacing.sm, runSpacing: SDSSpacing.sm, children: chips),
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
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        disabledBackgroundColor: SDSColor.gray200,
        elevation: 0,
        minimumSize: expand ? const Size(double.infinity, 48) : null,
        padding: expand
            ? null
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSubmitting) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: SDSSpacing.sm),
          ],
          Text(
            '등록하기',
            style: SDSTextStyle.bold.copyWith(
              fontSize: expand ? 16 : 14,
              color: enabled ? SDSColor.snowliveWhite : SDSColor.gray400,
            ),
          ),
        ],
      ),
    );
  }
}
