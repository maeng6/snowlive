import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityListPagination_web.dart';
import 'package:com.snowlive/web/viewmodel/community/vm_communityUpload_web.dart';
import 'package:com.snowlive/web/widget/w_web_form_fields_web.dart';
import 'package:com.snowlive/web/widget/w_web_quill_editor_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 작성 폼 최대 폭(목업). 목록/상세(1136)보다 좁다 — 한 줄에 한 필드씩 놓는 폼이라
/// 넓히면 입력 박스만 길어지고 읽기 흐름이 나빠진다.
const double kCommunityFormMaxWidth = 800;

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
  final CommunityUploadViewModelWeb _vm = Get.find<CommunityUploadViewModelWeb>();
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
        return 620;
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
            constraints: const BoxConstraints(maxWidth: kCommunityFormMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(context),
                const SizedBox(height: SDSSpacing.xl),
                _buildForm(context),
              ],
            ),
          ),
        ),
      ),
    );

    if (isDesktop) return scrollArea;

    // 태블릿·모바일은 액션 버튼이 뷰포트 하단에 고정된다. 셸이 페이지를 Expanded에
    // 넣으므로 Stack의 bottom이 곧 뷰포트 하단이다. 콘텐츠가 가려지지 않도록
    // 바깥 Padding으로 스크롤 영역 자체를 줄인다(상세화면과 같은 패턴).
    // Stack 뒤가 비치면 셸 Scaffold의 표면 틴트가 바 위쪽에 띠로 보인다.
    // 페이지 배경을 흰색으로 깔아 막는다.
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.only(bottom: _bottomBarHeight), child: scrollArea),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar(context)),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    final isDesktop = context.isDesktop;
    return Row(
      children: [
        // 좌측 여백을 IconButton 기본 패딩이 먹지 않도록 폼 왼쪽에 정렬한다.
        IconButton(
          onPressed: () => Get.back(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.arrow_back, color: SDSColor.gray900, size: 24),
        ),
        const SizedBox(width: SDSSpacing.md),
        Text(
          '게시글 작성',
          style: SDSTextStyle.extraBold.copyWith(
            fontSize: isDesktop ? 22 : 18,
            color: SDSColor.gray900,
          ),
        ),
        if (isDesktop) ...[
          const Spacer(),
          _TempSaveButton(onTap: _onTempSave),
          const SizedBox(width: SDSSpacing.sm),
          Obx(() => _SubmitButton(
                enabled: _vm.canSubmit && !_vm.isSubmitting,
                isSubmitting: _vm.isSubmitting,
                onTap: _submit,
              )),
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
      padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.md, vertical: SDSSpacing.md),
      child: Row(
        children: [
          _TempSaveButton(onTap: _onTempSave),
          const SizedBox(width: SDSSpacing.sm),
          // 목업: 작성완료가 남은 폭을 전부 차지한다.
          Expanded(
            child: Obx(() => _SubmitButton(
                  enabled: _vm.canSubmit && !_vm.isSubmitting,
                  isSubmitting: _vm.isSubmitting,
                  onTap: _submit,
                  expand: true,
                )),
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
        WebFormTextField(
          compact: true,
          label: '제목',
          controller: _vm.titleController,
          hint: '글 제목을 입력해 주세요. (최대 50자 이내)',
          maxLength: 50,
          onChanged: (v) => _vm.changeTitleWritten(v.trim().isNotEmpty),
        ),
        const SizedBox(height: SDSSpacing.lg),
        Obx(() {
          final main = WebFormDropdownField<String>(
            compact: true,
            centerSheetOnTablet: true,
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
              compact: true,
              centerSheetOnTablet: true,
              label: '상세 종류',
              value: _vm.categorySub2,
              placeholder: kCommunityCategorySub2Placeholder,
              values: kCommunityCategorySub2List,
              labelOf: (v) => v,
              onSelected: _vm.selectCategorySub2,
            ),
          );
        }),
        const SizedBox(height: SDSSpacing.lg),
        const WebFormLabel('상세 설명', compact: true),
        WebQuillEditor(
          controller: _vm.quillController,
          focusNode: _vm.editorFocusNode,
          scrollController: _vm.editorScrollController,
          height: _editorHeight(context),
          placeholder: '게시글 내용을 작성해 주세요. (최대 5,000자 이내)\n\n'
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
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text('임시저장', style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
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
    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        disabledBackgroundColor: SDSColor.gray200,
        elevation: 0,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: expand ? 24 : 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                valueColor: AlwaysStoppedAnimation<Color>(SDSColor.snowliveWhite),
              ),
            ),
            const SizedBox(width: SDSSpacing.sm),
          ],
          Text(
            '작성 완료',
            style: SDSTextStyle.bold.copyWith(
              fontSize: 15,
              color: enabled ? SDSColor.snowliveWhite : SDSColor.gray400,
            ),
          ),
        ],
      ),
    );
  }
}
