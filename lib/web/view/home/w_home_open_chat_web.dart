import 'dart:async';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/home/home_sections_web.dart';
import 'package:com.snowlive/web/viewmodel/home/vm_openChat_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 홈 우측 하단 오픈 채팅(피그마 4개 상태).
///
///  - **바**: `ic_openchat + 오픈 채팅 + ^`. 새 메시지가 오면 아래에 말풍선이
///    한 개씩 쌓인다(최대 [kHomeChatMaxBubbles]개, 각 3초 뒤 사라짐).
///  - **아이콘**: 페이지를 스크롤하면 53px 원형으로 줄어든다.
///  - **패널**: 바(또는 아이콘)를 누르면 펼쳐지는 채팅창(높이 497).
class HomeOpenChatWeb extends StatefulWidget {
  /// 페이지가 스크롤됐는지. 스크롤 중에는 아이콘으로 줄인다(요청).
  final bool isScrolled;

  const HomeOpenChatWeb({super.key, required this.isScrolled});

  @override
  State<HomeOpenChatWeb> createState() => _HomeOpenChatWebState();
}

/// 피그마 공통 스타일.
/// 보더는 피그마 실측 #ECECEC 대신 gray100(#EFEFEF)으로 통일(2026-09-16 결정).
const Color _kBorderColor = SDSColor.gray100;
const Color _kPanelBorderColor = Color(0xFFF5F5F5);
const Color _kInputFillColor = Color(0xFFF6F6F6);
const double _kHeaderHeight = 53;
const double _kPanelHeight = 497;

/// 모바일 시트 상단 여백 — 앱바(56) 아래부터 시트가 시작한다(피그마 1:19330).
const double _kSheetTopGap = 56;
const String _kChatIconAsset = 'assets/imgs/icons/ic_openchat.png';

/// 접힌 바 아래에 떠 있는 말풍선 하나.
class _BubbleEntry {
  final int id;
  final OpenChatMessage message;

  const _BubbleEntry({required this.id, required this.message});
}

class _HomeOpenChatWebState extends State<HomeOpenChatWeb>
    with SingleTickerProviderStateMixin {
  final OpenChatViewModelWeb _vm = Get.find<OpenChatViewModelWeb>();
  final TextEditingController _input = TextEditingController();
  final ScrollController _listController = ScrollController();

  bool _isOpen = false;
  Worker? _latestWorker;

  /// 모바일 바텀 시트(피그마 1:19330) — 앱바까지 딤으로 덮어야 해서
  /// 라우트 Navigator가 아니라 **루트 Overlay**에 직접 띄운다.
  OverlayEntry? _sheetEntry;
  late final AnimationController _sheetCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  /// 접힌 바 아래에 쌓인 말풍선들(오래된 것부터). 각자 3초 타이머로 사라진다.
  final List<_BubbleEntry> _bubbles = [];
  final Map<int, Timer> _bubbleTimers = {};
  int _bubbleSeq = 0;

  @override
  void initState() {
    super.initState();
    _latestWorker = ever(_vm.latestRx, (message) {
      if (message == null) return;
      if (_isOpen || _sheetEntry != null) {
        // 펼쳐 놓은 상태면 목록이 이미 보이므로 아래로 붙여준다.
        _scrollToBottom();
        return;
      }
      _pushBubble(message);
    });
  }

  @override
  void didUpdateWidget(HomeOpenChatWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 아이콘으로 접힐 때 남은 말풍선은 정리한다(높이가 53으로 딱 떨어지게).
    if (widget.isScrolled && !oldWidget.isScrolled && _bubbles.isNotEmpty) {
      setState(_clearBubbles);
    }
  }

  @override
  void dispose() {
    for (final timer in _bubbleTimers.values) {
      timer.cancel();
    }
    _latestWorker?.dispose();
    _input.dispose();
    _listController.dispose();
    _sheetEntry?.remove();
    _sheetEntry = null;
    _sheetCtrl.dispose();
    super.dispose();
  }

  /// 말풍선을 아래에 추가한다. 3개를 넘으면 오래된 것부터 밀어낸다.
  void _pushBubble(OpenChatMessage message) {
    final id = _bubbleSeq++;
    setState(() {
      _bubbles.add(_BubbleEntry(id: id, message: message));
      while (_bubbles.length > kHomeChatMaxBubbles) {
        final removed = _bubbles.removeAt(0);
        _bubbleTimers.remove(removed.id)?.cancel();
      }
    });
    _bubbleTimers[id] = Timer(kHomeChatBubbleDuration, () {
      _bubbleTimers.remove(id);
      if (!mounted) return;
      setState(() => _bubbles.removeWhere((bubble) => bubble.id == id));
    });
  }

  void _clearBubbles() {
    for (final timer in _bubbleTimers.values) {
      timer.cancel();
    }
    _bubbleTimers.clear();
    _bubbles.clear();
  }

  /// `reverse: true` 목록에서 최신은 오프셋 0이다.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      _listController.jumpTo(0);
    });
  }

  void _toggle() {
    // 모바일은 인라인 패널 대신 바텀 시트로 펼친다(피그마 1:19330).
    if (context.screenType == WebScreenType.mobile) {
      setState(_clearBubbles);
      _vm.clearLatest();
      _openMobileSheet();
      return;
    }
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) _clearBubbles();
    });
    if (_isOpen) {
      // 펼치면 말풍선은 역할이 끝났다.
      _vm.clearLatest();
      _scrollToBottom();
    }
  }

  // ── 모바일 바텀 시트 ──
  /// 딤(앱바 포함 전체 화면) + 앱바 아래부터 바닥까지 풀블리드 시트.
  void _openMobileSheet() {
    if (_sheetEntry != null) return;

    final entry = OverlayEntry(
      builder: (overlayCtx) {
        final Size screen = MediaQuery.sizeOf(overlayCtx);
        // 키패드가 올라오면 그만큼 시트를 줄이고 위로 붙인다(상단은 앱바 아래 고정).
        final double insets = MediaQuery.viewInsetsOf(overlayCtx).bottom;
        final double sheetHeight = (screen.height - _kSheetTopGap - insets)
            .clamp(200.0, screen.height);

        return AnimatedBuilder(
          animation: _sheetCtrl,
          builder: (context, child) => Stack(
            children: [
              // 스크림 — 탭하면 닫힌다.
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeMobileSheet,
                  child: Container(
                    color: Colors.black.withOpacity(0.4 * _sheetCtrl.value),
                  ),
                ),
              ),
              child!,
            ],
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _sheetCtrl,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: Padding(
                padding: EdgeInsets.only(bottom: insets),
                child: Material(
                  color: SDSColor.snowliveWhite,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: sheetHeight,
                    width: double.infinity,
                    child: Obx(
                      () => _buildPanelBody(
                        messages: _vm.messages,
                        onClose: _closeMobileSheet,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _sheetEntry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
    _sheetCtrl.forward(from: 0);
    _scrollToBottom();
  }

  Future<void> _closeMobileSheet() async {
    if (_sheetEntry == null) return;
    await _sheetCtrl.reverse();
    _sheetEntry?.remove();
    _sheetEntry = null;
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
      final messages = _vm.messages;
      _vm.latest;

      if (_isOpen) return _buildPanel(messages);

      // 접힌 상태 — 바 ↔ 원형 아이콘을 우측 기준으로 애니메이션 전환한다.
      return _buildCollapsed(isMobile);
    });
  }

  // ── 접힌 상태(바 ↔ 아이콘) ──
  /// 부모 Positioned가 우측을 고정하고 있어서, 폭이 328→53으로 줄면
  /// 자연스럽게 **오른쪽으로 접히는** 모양이 된다.
  Widget _buildCollapsed(bool isMobile) {
    final bool iconMode = widget.isScrolled;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 모바일은 부모 폭(화면 - 좌우 16)을 꽉 채우고, PC·태블릿은 328 고정.
        final double barWidth = isMobile ? constraints.maxWidth : 328;

        return Align(
          alignment: Alignment.bottomRight,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: iconMode ? 53 : barWidth,
                decoration: BoxDecoration(
                  color: SDSColor.snowliveWhite,
                  borderRadius: BorderRadius.circular(iconMode ? 36 : 16),
                  border: Border.all(color: _kBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      offset: const Offset(0, 2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 헤더 창(53 고정) — 바 헤더와 아이콘을 겹쳐 두고 페이드로 교체한다.
                    SizedBox(
                      height: _kHeaderHeight,
                      child: Stack(
                        children: [
                          // 바 헤더 — 항상 바 전체 폭으로 그리고, 줄어드는 동안 잘려 나간다.
                          IgnorePointer(
                            ignoring: iconMode,
                            child: AnimatedOpacity(
                              opacity: iconMode ? 0 : 1,
                              duration: const Duration(milliseconds: 150),
                              child: OverflowBox(
                                minWidth: barWidth,
                                maxWidth: barWidth,
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: barWidth,
                                  height: _kHeaderHeight,
                                  child: _buildHeader(isCollapsed: true),
                                ),
                              ),
                            ),
                          ),
                          // 아이콘(53x53 중앙).
                          IgnorePointer(
                            ignoring: !iconMode,
                            child: AnimatedOpacity(
                              opacity: iconMode ? 1 : 0,
                              duration: const Duration(milliseconds: 150),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: 53,
                                  height: 53,
                                  child: Center(
                                    child: Image.asset(
                                      _kChatIconAsset,
                                      width: 25,
                                      height: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 새 메시지 말풍선 스택 — 개수에 따라 높이가 자연스럽게 전환된다.
                    if (!iconMode)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: _bubbles.isEmpty
                            ? const SizedBox(width: double.infinity)
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (
                                      var i = 0;
                                      i < _bubbles.length;
                                      i++
                                    ) ...[
                                      if (i > 0) const SizedBox(height: 5),
                                      _BubbleIn(
                                        key: ValueKey(_bubbles[i].id),
                                        child: _MessageRow(
                                          message: _bubbles[i].message,
                                          myUserId: _vm.myUserId,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── 펼친 패널(PC·태블릿 인라인) ──
  Widget _buildPanel(List<OpenChatMessage> messages) {
    return _Surface(
      borderColor: _kPanelBorderColor,
      child: SizedBox(
        height: _kPanelHeight,
        child: _buildPanelBody(messages: messages, onClose: _toggle),
      ),
    );
  }

  /// 패널 내용부(헤더+리스트+입력) — 인라인 패널과 모바일 시트가 공유한다.
  Widget _buildPanelBody({
    required List<OpenChatMessage> messages,
    required VoidCallback onClose,
  }) {
    return Column(
      children: [
        _buildHeader(isCollapsed: false, onTap: onClose),
        Expanded(
          child: Stack(
            children: [
              messages.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(SDSSpacing.xl),
                      child: Center(
                        child: Text(
                          '아직 올라온 채팅이 없어요',
                          textAlign: TextAlign.center,
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 13,
                            color: SDSColor.gray400,
                          ),
                        ),
                      ),
                    )
                  // 채팅은 `reverse: true`로 그린다 — 열자마자 최신 메시지가 보이고
                  // (jumpTo 타이밍에 의존하지 않는다) 새 메시지도 자연히 아래에 쌓인다.
                  : ListView.builder(
                      controller: _listController,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: _MessageRow(
                          message: messages[messages.length - 1 - i],
                          myUserId: _vm.myUserId,
                        ),
                      ),
                    ),
              // 헤더 아래 화이트 페이드 — 스크롤 시 위쪽이 부드럽게 잘린다(피그마).
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 16,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0x00FFFFFF)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildInput(),
      ],
    );
  }

  /// 헤더(53): 아이콘 25 + '오픈 채팅' ExtraBold 14 + 접기/펼치기 화살표.
  Widget _buildHeader({required bool isCollapsed, VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ?? _toggle,
        child: SizedBox(
          height: _kHeaderHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Image.asset(_kChatIconAsset, width: 25, height: 25),
                const SizedBox(width: 6),
                Text(
                  '오픈 채팅',
                  style: SDSTextStyle.extraBold.copyWith(
                    fontSize: 14,
                    color: SDSColor.gray900,
                  ),
                ),
                const Spacer(),
                Icon(
                  isCollapsed
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: SDSColor.gray900,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 입력창(피그마): 컨테이너 패딩 12/10, 필드 #F6F6F6 radius 6,
  /// placeholder Regular 12 gray500, 우측 원형(22) 전송 버튼.
  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Container(
        // 입력 필드 높이 40 고정.
        height: 40,
        decoration: BoxDecoration(
          color: _kInputFillColor,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.only(left: 12, right: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                onSubmitted: (_) => _send(),
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 12,
                  color: SDSColor.gray900,
                ),
                cursorHeight: 14,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: '댓글을 남겨주세요',
                  hintStyle: SDSTextStyle.regular.copyWith(
                    fontSize: 12,
                    color: SDSColor.gray500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 입력 내용이 있고 전송 중이 아닐 때만 파란 활성 원.
            AnimatedBuilder(
              animation: _input,
              builder: (context, _) => Obx(() {
                // ⚠️ Obx는 관찰 대상을 반드시 읽어야 한다 — && 단축 평가로
                // isSending을 건너뛰면 improper use 예외가 난다.
                final bool isSending = _vm.isSending;
                final bool canSend =
                    _input.text.trim().isNotEmpty && !isSending;
                return MouseRegion(
                  cursor: canSend
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: GestureDetector(
                    onTap: canSend ? _send : null,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: canSend
                            ? SDSColor.snowliveBlue
                            : SDSColor.gray300,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// 흰 카드 표면(피그마) — radius 16 + 1px 보더 + 그림자(0,2,10 / 12%).
class _Surface extends StatelessWidget {
  final Widget child;
  final Color borderColor;

  const _Surface({required this.child, this.borderColor = _kBorderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      // Material 조상이 없으면 TextField/Text가 깨진다(투명 Material로 감싼다).
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

/// 말풍선 등장 애니메이션 — 페이드 + 아래에서 8px 상승.
class _BubbleIn extends StatelessWidget {
  final Widget child;

  const _BubbleIn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, value, animatedChild) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 8),
          child: animatedChild,
        ),
      ),
      child: child,
    );
  }
}

/// 메시지 한 줄(피그마).
/// 상대: blue50 말풍선 + 우측 시간 / 나: snowliveBlue 말풍선(흰 글씨) + 좌측 시간.
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
            style: SDSTextStyle.regular.copyWith(
              fontSize: 12,
              color: SDSColor.gray600,
            ),
          ),
        ),
      );
    }

    final isMine = message.isMine(myUserId);
    final time = message.createdAt == null
        ? ''
        : GetDatetime().getAgoString(message.createdAt!.toString());

    // 말풍선: radius 8, 패딩 14/10, Regular 12 (피그마 기준).
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMine ? SDSColor.snowliveBlue : SDSColor.blue50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message.text,
        style: SDSTextStyle.regular.copyWith(
          fontSize: 12,
          height: 1.3,
          color: isMine ? SDSColor.snowliveWhite : SDSColor.gray900,
        ),
      ),
    );

    // 시간: Regular 11 gray500, 말풍선 하단 정렬(피그마 기준 pb 2).
    final timeLabel = Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        time,
        style: SDSTextStyle.regular.copyWith(
          fontSize: 11,
          color: SDSColor.gray500,
        ),
      ),
    );

    return Row(
      mainAxisAlignment: isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: isMine
          ? [timeLabel, const SizedBox(width: 4), Flexible(child: bubble)]
          : [Flexible(child: bubble), const SizedBox(width: 4), timeLabel],
    );
  }
}
