import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 댓글/답글 입력 한 줄. 커뮤니티·중고거래 공용이고, 인라인(태블릿·데스크탑)과
/// 하단 고정바(모바일)가 같은 위젯을 쓴다.
///
/// 전송 버튼은 **입력이 있을 때만 활성화**된다(모바일 앱과 동일).
class WebCommentInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final bool isSubmitting;

  /// null이면 게스트 → 누르면 로그인 안내만 띄운다.
  final Future<void> Function(String text)? onSubmit;
  final VoidCallback? onGuestTap;

  /// 입력창 왼쪽에 붙는 위젯(중고거래 비밀댓글 자물쇠 토글). null이면 그리지 않는다.
  final Widget? leading;

  const WebCommentInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.isSubmitting = false,
    this.onSubmit,
    this.onGuestTap,
    this.leading,
  });

  @override
  State<WebCommentInput> createState() => _WebCommentInputState();
}

class _WebCommentInputState extends State<WebCommentInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant WebCommentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _onTextChanged();
    }
  }

  @override
  void dispose() {
    // 컨트롤러는 호출자 소유다. 리스너만 떼고 dispose는 하지 않는다.
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  Future<void> _submit() async {
    if (widget.isSubmitting) return;
    if (widget.onSubmit == null) {
      widget.onGuestTap?.call();
      return;
    }
    final text = widget.controller.text.trim();
    // 한글 IME 조합 중 엔터가 확정과 겹쳐 빈 문자열이 들어오는 경우가 있다.
    if (text.isEmpty) return;
    await widget.onSubmit!(text);
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = widget.onSubmit == null;

    return Container(
      decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.leading != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 4),
              child: widget.leading!,
            ),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              readOnly: isGuest,
              onTap: isGuest ? widget.onGuestTap : null,
              onSubmitted: (_) => _submit(),
              textInputAction: TextInputAction.send,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: widget.hintText,
                hintStyle: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
              ),
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
          const SizedBox(width: 8),
          // 색은 입력 유무만 따른다. 게스트는 입력창이 readOnly라 항상 회색이지만,
          // 눌렀을 때 로그인 안내는 떠야 하므로 탭은 살려둔다.
          _SendButton(
            active: _hasText && !widget.isSubmitting,
            onTap: (isGuest || (_hasText && !widget.isSubmitting)) ? _submit : null,
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  /// 파란색(=보낼 수 있음) 여부. 탭 가능 여부와는 별개다.
  final bool active;
  final VoidCallback? onTap;

  const _SendButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: active ? SDSColor.snowliveBlue : SDSColor.gray200,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_upward, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// 모바일 하단 고정바 위에 뜨는 "OOO님에게 답글쓰는중" 스트립.
class WebReplyTargetBar extends StatelessWidget {
  final String targetName;
  final VoidCallback onCancel;

  const WebReplyTargetBar({super.key, required this.targetName, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: SDSColor.blue50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$targetName님에게 답글쓰는중',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.snowliveBlue),
            ),
          ),
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Icon(Icons.close, size: 18, color: SDSColor.gray500),
          ),
        ],
      ),
    );
  }
}
