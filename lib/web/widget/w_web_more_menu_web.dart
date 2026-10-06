import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart' show showWebConfirmDialog;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

export 'package:com.snowlive/web/widget/w_web_popup_web.dart' show showWebConfirmDialog;

/// 신고/차단 API가 정상 등록과 중복을 모두 success로 돌려주기 때문에 결과를 나눠서
/// 화면이 다른 안내를 띄울 수 있게 한다.
enum WebActionResult { done, duplicated, failed }

enum WebMoreAction {
  reportPost('게시글 신고하기'),
  report('신고하기'),
  hideUser('이 회원의 모든 글 숨기기'),
  edit('수정하기'),
  delete('삭제하기');

  const WebMoreAction(this.label);

  final String label;
}

/// ⋯ 트리거. 데스크탑=앵커 드롭다운(딤 없음) / 태블릿=중앙 딤 / 모바일=하단 딤 은
/// 공용 [showWebFilterMenu]가 이미 전부 처리한다(새로 만들지 않는다).
class WebMoreButton extends StatefulWidget {
  final List<WebMoreAction> actions;
  final ValueChanged<WebMoreAction> onSelected;
  final double iconSize;

  /// 태블릿에서도 데스크탑처럼 앵커 드롭다운을 띄울지(기본은 중앙 딤 시트).
  /// 중고거래 상세(판매자 행·댓글)만 true — 기본값을 바꾸면 다른 호출자의
  /// 태블릿 프레젠테이션이 전부 바뀌는 회귀가 된다.
  final bool dropdownOnTablet;

  const WebMoreButton({
    super.key,
    required this.actions,
    required this.onSelected,
    this.iconSize = 20,
    this.iconAsset = 'assets/imgs/icons/icon_header_more_web.svg',
    this.iconColor,
    this.dropdownOnTablet = false,
    this.hitPadding = 2,
  });

  /// ⋯ 아이콘 에셋. 기본은 웹 공통 SVG — 앱과 아이콘을 맞춰야 하는 화면
  /// (중고거래 상세)만 앱 에셋(png)으로 바꾼다.
  final String iconAsset;

  /// 아이콘 틴트 색. null이면 에셋 원색 그대로.
  final Color? iconColor;

  /// 히트 영역 확보용 여백(사방). 기본 2 — 아이콘 26 기준 클릭 영역 30.
  final double hitPadding;

  @override
  State<WebMoreButton> createState() => _WebMoreButtonState();
}

class _WebMoreButtonState extends State<WebMoreButton> {
  /// 앵커 링크는 ⋯ 아이콘 **자체에만** 감는다. 부모에 감으면 드롭다운 위치가 틀어진다.
  final LayerLink _link = LayerLink();

  /// hover 시 아이콘 60% 투명도(웹 공통 아이콘 hover 규칙).
  bool _hovered = false;

  Future<void> _open() async {
    final selected = await showWebFilterMenu<WebMoreAction>(
      context: context,
      link: _link,
      values: widget.actions,
      labelOf: (a) => a.label,
      centerSheetOnTablet: true,
      dropdownOnTablet: widget.dropdownOnTablet,
    );
    if (selected == null) return;
    widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _open,
          child: Padding(
            padding: EdgeInsets.all(widget.hitPadding),
            child: AnimatedOpacity(
              opacity: _hovered ? 0.6 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: widget.iconAsset.endsWith('.svg')
                  ? SvgPicture.asset(
                      widget.iconAsset,
                      width: widget.iconSize,
                      height: widget.iconSize,
                      colorFilter: widget.iconColor == null
                          ? null
                          : ColorFilter.mode(
                              widget.iconColor!,
                              BlendMode.srcIn,
                            ),
                    )
                  : Image.asset(
                      widget.iconAsset,
                      width: widget.iconSize,
                      height: widget.iconSize,
                      fit: BoxFit.contain,
                      color: widget.iconColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ⋯ 메뉴 선택 후 공통 처리: 확인 다이얼로그 → 실행 → 결과 안내.
///
/// **시트가 닫히기를 기다린 뒤에** 확인 다이얼로그를 연다. 시트의 onTap 안에서 바로
/// 열면 배리어가 두 겹 쌓인다.
Future<void> handleWebMoreAction(
  BuildContext context, {
  required WebMoreAction action,
  Future<bool> Function()? onDelete,
  Future<WebActionResult> Function()? onReport,
  Future<WebActionResult> Function()? onHideUser,
  Future<void> Function()? onEdit,
}) async {
  switch (action) {
    case WebMoreAction.edit:
      // 수정은 되돌릴 수 있는 이동이라 확인 없이 바로 연다.
      await onEdit?.call();

    case WebMoreAction.delete:
      if (onDelete == null) return;
      final ok = await showWebConfirmDialog(
        context: context,
        title: '이 글을 삭제하시겠어요?',
        confirmLabel: '삭제하기',
        isDestructive: true,
      );
      if (!ok) return;
      final done = await onDelete();
      Get.snackbar(done ? '삭제 완료' : '삭제 실패', done ? '삭제되었어요.' : '잠시 후 다시 시도해 주세요.');

    case WebMoreAction.report:
    case WebMoreAction.reportPost:
      if (onReport == null) return;
      final ok = await showWebConfirmDialog(
        context: context,
        title: '이 회원을 신고하시겠습니까?',
        message: '신고가 일정 횟수 이상 누적되면 해당 게시물이 삭제 처리됩니다',
        confirmLabel: '신고하기',
      );
      if (!ok) return;
      _showResult(await onReport(), doneTitle: '신고 완료', doneMessage: '신고가 접수되었어요.',
          duplicatedTitle: '신고 중복', duplicatedMessage: '이미 신고한 대상이에요.');

    case WebMoreAction.hideUser:
      if (onHideUser == null) return;
      final ok = await showWebConfirmDialog(
        context: context,
        title: '이 회원의 모든 글을 숨기시겠습니까?',
        message: '숨김해제는 [더보기 - 친구 - 설정 - 차단목록]에서 하실 수 있습니다.',
        confirmLabel: '숨기기',
      );
      if (!ok) return;
      _showResult(await onHideUser(), doneTitle: '차단 완료', doneMessage: '차단한 유저의 게시글은 숨김처리됩니다.',
          duplicatedTitle: '중복 차단', duplicatedMessage: '이미 차단한 유저입니다.');
  }
}

/// 신고/차단 API 응답을 [WebActionResult]로 변환한다.
///
/// 이 API들은 정상 등록(201)과 중복(400)을 **모두 success로** 돌려주고 구분이 응답
/// message 문자열에만 있다. core 뷰모델의 같은 메서드들은 내부에서
/// `CustomFullScreenDialog.cancelDialog()`(= `Get.back()`)를 불러 **현재 라우트를
/// pop 시키므로** 웹에서는 쓰지 말고 API를 직접 호출한 뒤 이 함수로 감쌀 것.
Future<WebActionResult> mapWebActionResponse(Future<dynamic> Function() call) async {
  try {
    final response = await call();
    if (response.success != true) return WebActionResult.failed;
    final data = response.data;
    final message = (data is Map) ? '${data['message'] ?? ''}' : '';
    return message.toLowerCase().contains('already')
        ? WebActionResult.duplicated
        : WebActionResult.done;
  } catch (e) {
    return WebActionResult.failed;
  }
}

void _showResult(
  WebActionResult result, {
  required String doneTitle,
  required String doneMessage,
  required String duplicatedTitle,
  required String duplicatedMessage,
}) {
  switch (result) {
    case WebActionResult.done:
      Get.snackbar(doneTitle, doneMessage);
    case WebActionResult.duplicated:
      Get.snackbar(duplicatedTitle, duplicatedMessage);
    case WebActionResult.failed:
      Get.snackbar('처리 실패', '잠시 후 다시 시도해 주세요.');
  }
}

// showWebConfirmDialog는 w_web_popup_web.dart로 이동했다(아래 export로 호환 유지).
