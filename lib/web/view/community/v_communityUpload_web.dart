import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityUpload_web.dart';
import 'package:com.snowlive/web/widget/w_web_floating_bottombar_web.dart';
import 'package:com.snowlive/web/widget/w_web_form_fields_web.dart';
import 'package:com.snowlive/web/widget/w_web_quill_editor_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 웹 커뮤니티 게시글 작성 화면.
///
/// 목업 기준 폭별 차이:
/// - 데스크탑: 임시저장/작성 완료가 **타이틀 줄 오른쪽 끝**
/// - 태블릿·모바일: 두 버튼이 **화면 하단 고정바**
class CommunityUploadViewWeb extends StatefulWidget {
  const CommunityUploadViewWeb({super.key});

  @override
  State<CommunityUploadViewWeb> createState() => _CommunityUploadViewWebState();
}

class _CommunityUploadViewWebState extends State<CommunityUploadViewWeb> {
  final CommunityUploadViewModelWeb _vm =
      Get.find<CommunityUploadViewModelWeb>();
  final UserViewModel _userVm = Get.find<UserViewModel>();

  /// 하단 고정바 높이(패딩 16*2 + 버튼 48).
  static const double _bottomBarHeight = 80;

  @override
  void initState() {
    super.initState();
    // 뷰모델이 fenix라 이전 작성 내용이 살아 있다. 새 글 화면은 항상 빈 상태로 연다.
    _vm.resetForm();
  }

  double _editorHeight(BuildContext context) {
    switch (context.screenType) {
      case WebScreenType.desktop:
        // 피그마 64:166140 — 에디터 박스 688.
        return 688;
      case WebScreenType.tablet:
        return 560;
      case WebScreenType.mobile:
        return 420;
    }
  }

  Future<void> _submit() async {
    final userId = _userVm.user.user_id;
    if (userId == null) {
      Get.snackbar('알림', '로그인이 필요합니다.');
      return;
    }
    if (!_vm.canSubmit) {
      Get.snackbar('알림', '제목과 게시판 종류를 입력해주세요.');
      return;
    }

    final pk = await _vm.submit(userId: userId);
    if (pk == null) {
      Get.snackbar('오류', '등록에 실패했습니다. 잠시 후 다시 시도해주세요.');
      return;
    }

    // 목록을 1페이지로 되돌려 새 글이 보이게 한다. loadFirstPage는 탭·정렬·검색을
    // 기본값으로 되돌리므로 쓰지 않는다(사용자가 걸어둔 필터가 날아간다).
    if (Get.isRegistered<CommunityListPaginationViewModelWeb>()) {
      Get.find<CommunityListPaginationViewModelWeb>().gotoPage(1);
    }
    Get.back();
    Get.snackbar('완료', '게시글이 등록되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;

    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        // 여백은 스크롤 영역 **안쪽**(웹 공통 규칙) — 바깥에 두면 스크롤바가
        // 브라우저 우측 끝이 아니라 콘텐츠 안쪽에 뜬다. 모바일은 콘텐츠가 하단
        // 플로팅 바 뒤로 지나가도록 바 높이만큼 하단 여백을 확보한다.
        padding: webSubPagePadding(
          context,
          bottom: isMobile
              ? kWebFloatingBottomBarHeight + SDSSpacing.md
              : SDSSpacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            // PC만 800 고정 중앙 — 태블릿·모바일은 제한 없이 화면(패딩 제외)을
            // 가득 채운다(중고거래 올리기와 동일 규칙).
            constraints: BoxConstraints(
              maxWidth: isDesktop ? kWebSubPageMaxWidth : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(context),
                // 헤더 줄 ↔ 폼 PC 40 / 태블릿·모바일 26 (중고거래 올리기와 동일).
                SizedBox(height: webFormHeaderGap(context)),
                _buildForm(context),
              ],
            ),
          ),
        ),
      ),
    );

    if (isDesktop) return scrollArea;

    // 모바일: 하단 플로팅 바 — 중고거래 올리기와 동일(페이드 + 버튼 48,
    // 콘텐츠가 바 뒤로 지나간다).
    if (isMobile) {
      return Container(
        color: SDSColor.snowliveWhite,
        child: Stack(
          children: [
            scrollArea,
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: WebFloatingBottomBar(
                child: _buildMobileBottomButtons(context),
              ),
            ),
          ],
        ),
      );
    }

    // 태블릿은 액션 버튼이 뷰포트 하단에 고정된다. 셸이 페이지를 Expanded에
    // 넣으므로 Stack의 bottom이 곧 뷰포트 하단이다. 콘텐츠가 가려지지 않도록
    // 바깥 Padding으로 스크롤 영역 자체를 줄인다(상세화면과 같은 패턴).
    // Stack 뒤가 비치면 셸 Scaffold의 표면 틴트가 바 위쪽에 띠로 보인다.
    // 페이지 배경을 흰색으로 깔아 막는다.
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: _bottomBarHeight),
            child: scrollArea,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  /// 모바일 하단 플로팅 바 버튼 줄 — 임시저장 100 고정(흰 배경) + 작성 완료
  /// 나머지, 간격 10. 버튼 규격(높이 48)은 중고거래 하단바와 동일.
  Widget _buildMobileBottomButtons(BuildContext context) {
    return Obx(() {
      final isSubmitting = _vm.isSubmitting;
      return Row(
        children: [
          SizedBox(
            width: 100,
            child: WebBottomBarButton(
              label: '임시저장',
              background: SDSColor.snowliveWhite,
              foreground: SDSColor.gray900,
              onTap: isSubmitting ? null : _onTempSave,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: WebBottomBarButton(
              label: '작성 완료',
              background: SDSColor.snowliveBlue,
              foreground: SDSColor.snowliveWhite,
              onTap: (_vm.canSubmit && !isSubmitting) ? _submit : null,
              leading: isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          SDSColor.snowliveWhite,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTitleRow(BuildContext context) {
    final isDesktop = context.isDesktop;
    // 서브 페이지 공통 헤더(뒤로 30 + 12 + bold 30) — 중고거래 폼에서 확정한 표준.
    return WebPageHeader(
      title: '게시글 작성',
      onBack: () => Get.back(),
      actions: [
        if (isDesktop) ...[
          _TempSaveButton(onTap: _onTempSave),
          // 버튼 사이 10 (중고거래 헤더와 동일).
          const SizedBox(width: 10),
          Obx(
            () => _SubmitButton(
              enabled: _vm.canSubmit && !_vm.isSubmitting,
              isSubmitting: _vm.isSubmitting,
              onTap: _submit,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(top: BorderSide(color: SDSColor.gray100)),
      ),
      // 좌우는 페이지 공통 여백과 맞춘다(태블릿 20 / 모바일 16) — 어긋나면
      // 버튼이 콘텐츠 라인 밖으로 삐져 보인다.
      padding: EdgeInsets.symmetric(
        horizontal: context.screenType == WebScreenType.tablet ? 20 : 16,
        vertical: SDSSpacing.md,
      ),
      child: Row(
        children: [
          // 하단바의 임시저장은 100 고정(중고거래 하단바와 동일).
          SizedBox(width: 100, child: _TempSaveButton(onTap: _onTempSave)),
          const SizedBox(width: SDSSpacing.sm),
          // 목업: 작성완료가 남은 폭을 전부 차지한다.
          Expanded(
            child: Obx(
              () => _SubmitButton(
                enabled: _vm.canSubmit && !_vm.isSubmitting,
                isSubmitting: _vm.isSubmitting,
                onTap: _submit,
                expand: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTempSave() => Get.snackbar('알림', '임시저장 기능은 준비 중이에요.');

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨은 표준 regular 14(compact 아님), 필드 간 30 — 중고거래 폼과 동일.
        WebFormTextField(
          label: '제목',
          controller: _vm.titleController,
          hint: '글 제목을 입력해 주세요. (최대 50자 이내)',
          maxLength: 50,
          onChanged: (v) => _vm.changeTitleWritten(v.trim().isNotEmpty),
        ),
        const SizedBox(height: 30),
        Obx(() {
          final main = WebFormDropdownField<String>(
            anchoredOnTablet: true,
            label: '게시판 종류',
            value: _vm.categorySub,
            placeholder: kCommunityCategorySubPlaceholder,
            values: kCommunityCategorySubList,
            labelOf: (v) => v,
            onSelected: _vm.selectCategorySub,
          );
          // 하위 카테고리는 시즌방에서만 의미가 있다(목록 행도 그때만 칩을 그린다).
          if (!_vm.needsCategorySub2) return main;
          return WebFormTwoColumnRow(
            left: main,
            right: WebFormDropdownField<String>(
              anchoredOnTablet: true,
              label: '상세 종류',
              value: _vm.categorySub2,
              placeholder: kCommunityCategorySub2Placeholder,
              values: kCommunityCategorySub2List,
              labelOf: (v) => v,
              onSelected: _vm.selectCategorySub2,
            ),
          );
        }),
        const SizedBox(height: 30),
        const WebFormLabel('상세 설명'),
        WebQuillEditor(
          controller: _vm.quillController,
          focusNode: _vm.editorFocusNode,
          scrollController: _vm.editorScrollController,
          height: _editorHeight(context),
          placeholder:
              '게시글 내용을 작성해 주세요. (최대 5,000자 이내)\n\n'
              '부적절한 단어나 문장이 포함되는 경우 사전 고지없이 게시글 삭제가 될 수 있습니다.',
          onPickImage: _vm.pickAndInsertImage,
        ),
      ],
    );
  }
}

/// 목업의 임시저장 — 테두리 없는 텍스트 버튼(세 폭 공통).
class _TempSaveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TempSaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 중고거래 헤더 버튼 규격 — 높이 40 고정(visualDensity에 눌리지 않게
    // SizedBox + minimumSize 병행), 패딩 16, 라운드 5, bold 16.
    return SizedBox(
      height: 40,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(
          '임시저장',
          style: SDSTextStyle.bold.copyWith(
            fontSize: 16,
            color: SDSColor.gray900,
          ),
        ),
      ),
    );
  }
}

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
    // 중고거래 헤더 버튼(판매하기) 규격 — 높이 40, 패딩 16, 라운드 5, bold 16.
    // 전체폭(하단바)은 높이 48 유지.
    final button = ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        disabledBackgroundColor: SDSColor.gray200,
        elevation: 0,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        minimumSize: expand ? const Size(double.infinity, 48) : const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(expand ? 6 : 5),
        ),
      ),
      // 라벨을 스피너로 "교체"하면 버튼 폭이 튀므로, 라벨은 두고 앞에 끼워 넣는다.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSubmitting) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  SDSColor.snowliveWhite,
                ),
              ),
            ),
            const SizedBox(width: SDSSpacing.sm),
          ],
          Text(
            '작성 완료',
            // 비활성도 흰 글자(gray200 배경) — 중고거래 판매하기와 동일.
            style: SDSTextStyle.bold.copyWith(
              fontSize: expand ? 15 : 16,
              color: SDSColor.snowliveWhite,
            ),
          ),
        ],
      ),
    );
    // visualDensity(웹 기본 compact)가 minimumSize 높이를 깎으므로 강제한다.
    return SizedBox(height: expand ? 48 : 40, child: button);
  }
}
