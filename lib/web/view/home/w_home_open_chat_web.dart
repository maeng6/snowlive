import 'dart:async';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/viewmodel/home/vm_openChat_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 홈 우측 하단 오픈 채팅.
///
/// 상태가 셋이다(목업·요청).
///  - **바**: `💬 오픈 채팅 ^` 접힌 줄. 새 메시지가 오면 그 위에 말풍선을 5초만 띄운다.
///  - **아이콘**: 페이지를 스크롤하면 원형 아이콘으로 줄어든다.
///  - **패널**: 바(또는 아이콘)를 누르면 펼쳐지는 채팅창.
class HomeOpenChatWeb extends StatefulWidget {
  /// 페이지가 스크롤됐는지. 스크롤 중에는 아이콘으로 줄인다(요청).
  final bool isScrolled;

  const HomeOpenChatWeb({super.key, required this.isScrolled});

  @override
  State<HomeOpenChatWeb> createState() => _HomeOpenChatWebState();
}

class _HomeOpenChatWebState extends State<HomeOpenChatWeb> {
  final OpenChatViewModelWeb _vm = Get.find<OpenChatViewModelWeb>();
  final TextEditingController _input = TextEditingController();
  final ScrollController _listController = ScrollController();

  bool _isOpen = false;
  Timer? _bubbleTimer;
  Worker? _latestWorker;

  @override
  void initState() {
    super.initState();
    // 새 메시지가 올라오면 말풍선을 5초만 띄운다(요청).
    _latestWorker = ever(_vm.latestRx, (message) {
      if (message == null) return;
      _bubbleTimer?.cancel();
      _bubbleTimer = Timer(kHomeChatBubbleDuration, () {
        if (mounted) _vm.clearLatest();
      });
      // 펼쳐 놓은 상태면 목록이 이미 보이므로 아래로 붙여준다.
      if (_isOpen) _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    _latestWorker?.dispose();
    _input.dispose();
    _listController.dispose();
    super.dispose();
  }

  /// `reverse: true` 목록에서 최신은 오프셋 0이다.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      _listController.jumpTo(0);
    });
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      // 펼치면 말풍선은 역할이 끝났다.
      _vm.clearLatest();
      _scrollToBottom();
    }
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    if (!_vm.isLoggedIn) {
      showWebToast(context, '로그인이 필요해요.');
      return;
    }
    _input.clear();
    final ok = await _vm.send(text);
    if (!mounted) return;
    if (!ok) {
      showWebToast(context, '메시지를 보내지 못했어요.');
      return;
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;

    return Obx(() {
      // Obx는 관찰 대상을 **분기 전에** 한 번 읽어야 한다(안 읽으면 improper use 예외).
      final latest = _vm.latest;
      final messages = _vm.messages;

      if (_isOpen) return _buildPanel(isMobile, messages);

      // 스크롤 중에는 아이콘, 아니면 바(+말풍선).
      if (widget.isScrolled) return _buildIcon();
      return _buildBar(latest, isMobile);
    });
  }

  // ── 접힌 바 ──
  Widget _buildBar(OpenChatMessage? latest, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Surface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isCollapsed: true),
              // 새 메시지 말풍선 — 5초 뒤 사라진다.
              if (latest != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(SDSSpacing.md, 0, SDSSpacing.md, SDSSpacing.md),
                  child: _MessageRow(message: latest, myUserId: _vm.myUserId),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 스크롤 중 아이콘 ──
  Widget _buildIcon() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Material(
        color: SDSColor.snowliveWhite,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: SDSColor.gray900.withValues(alpha: 0.2),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _toggle,
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.chat_bubble, size: 22, color: SDSColor.snowliveBlue),
          ),
        ),
      ),
    );
  }

  // ── 펼친 패널 ──
  Widget _buildPanel(bool isMobile, List<OpenChatMessage> messages) {
    return _Surface(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: isMobile
              ? MediaQuery.sizeOf(context).height * 0.8
              : 470,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isCollapsed: false),
            Divider(height: 1, color: SDSColor.gray100),
            Flexible(
              child: messages.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(SDSSpacing.xl),
                      child: Text(
                        '아직 올라온 채팅이 없어요',
                        textAlign: TextAlign.center,
                        style: SDSTextStyle.regular
                            .copyWith(fontSize: 13, color: SDSColor.gray400),
                      ),
                    )
                  // 채팅은 `reverse: true`로 그린다 — 열자마자 최신 메시지가 보이고
                  // (jumpTo 타이밍에 의존하지 않는다) 새 메시지도 자연히 아래에 쌓인다.
                  : ListView.builder(
                      controller: _listController,
                      reverse: true,
                      padding: const EdgeInsets.all(SDSSpacing.md),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(top: SDSSpacing.sm),
                        child: _MessageRow(
                          message: messages[messages.length - 1 - i],
                          myUserId: _vm.myUserId,
                        ),
                      ),
                    ),
            ),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isCollapsed}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.md, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble, size: 18, color: SDSColor.snowliveBlue),
              const SizedBox(width: SDSSpacing.sm),
              Text(
                '오픈 채팅',
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
              ),
              const Spacer(),
              Icon(
                isCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 22,
                color: SDSColor.gray600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(SDSSpacing.md, 0, SDSSpacing.md, SDSSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: SDSColor.gray50,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.only(left: SDSSpacing.md, right: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                onSubmitted: (_) => _send(),
                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray900),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: '댓글을 남겨주세요',
                  hintStyle:
                      SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
                ),
              ),
            ),
            Obx(() {
              final isSending = _vm.isSending;
              return IconButton(
                onPressed: isSending ? null : _send,
                icon: Icon(
                  Icons.arrow_upward,
                  size: 18,
                  color: isSending ? SDSColor.gray300 : SDSColor.gray500,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: SDSColor.gray100,
                  minimumSize: const Size(28, 28),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 흰 카드 표면(그림자·라운드). 바·패널이 같은 모양을 쓴다.
class _Surface extends StatelessWidget {
  final Widget child;

  const _Surface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(12),
      elevation: 6,
      shadowColor: SDSColor.gray900.withValues(alpha: 0.15),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// 메시지 한 줄. 내 메시지는 오른쪽 파란 말풍선, 남의 메시지는 왼쪽 회색(목업).
class _MessageRow extends StatelessWidget {
  final OpenChatMessage message;
  final int? myUserId;

  const _MessageRow({required this.message, required this.myUserId});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: SDSColor.gray100,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            message.text,
            textAlign: TextAlign.center,
            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray600),
          ),
        ),
      );
    }

    final isMine = message.isMine(myUserId);
    final time = message.createdAt == null
        ? ''
        : GetDatetime().getAgoString(message.createdAt!.toString());

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isMine ? SDSColor.snowliveBlue : SDSColor.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message.text,
        style: SDSTextStyle.regular.copyWith(
          fontSize: 13,
          height: 1.3,
          color: isMine ? SDSColor.snowliveWhite : SDSColor.gray800,
        ),
      ),
    );

    final timeLabel = Text(
      time,
      style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray400),
    );

    return Row(
      mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: isMine
          ? [timeLabel, const SizedBox(width: 6), Flexible(child: bubble)]
          : [Flexible(child: bubble), const SizedBox(width: 6), timeLabel],
    );
  }
}
