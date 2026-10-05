import 'dart:math' as math;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveTalk/w_livetalk_detail_body_web.dart'
    show LiveTalkImagePane;
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 사진 아래 정보 바 높이(목업 161:41674 — 카드 885 − 이미지 821 = 64).
const double _kBarHeight = 64;

/// 카드 최대 폭. 목업 실측은 821인데 실제 화면에서 작아 보여 **960**으로 키웠다
/// (사용자 확정) — 넓은 화면에서만 체감되고, 좁으면 아래 높이 상한이 먼저 걸린다.
const double _kMaxCardWidth = 960;

/// 카드 좌우에 비워 두는 열 폭 = 카드↔버튼 16 + 버튼 48.
/// **양쪽에 같은 폭을 두어** 카드가 화면 정중앙에 오게 한다(목업은 카드가 가운데고
/// 버튼이 카드 밖 오른쪽에 있다 — 버튼까지 묶어 가운데 정렬하면 카드가 왼쪽으로 밀린다).
const double _kActionColumnWidth = 16 + _kActionButtonSize;

/// 카드 밖 원형 버튼 지름(목업 161:41666).
const double _kActionButtonSize = 48;

/// 원형 버튼 사이 간격(목업 — PC 97 → 157, 모바일 133 → 193).
const double _kActionButtonGap = 12;

/// 모바일 정보 바 높이(목업 161:52899 — 카드 407 − 이미지 345).
const double _kMobileBarHeight = 62;

/// 모바일에서 카드 ↔ 아래 버튼 줄 간격(목업 615 → 631).
const double _kMobileActionGap = 16;

/// 카드가 차지할 수 있는 화면 높이 비율.
/// 이 상한이 없으면 창이 낮을 때 카드가 패딩 끝까지 차서 위아래 여백이 사라지고
/// 가운데가 아닌 것처럼 보인다. 목업 비율(0.88)보다 키운 값 — 팝업을 더 크게
/// 보고 싶다는 요청(사용자 확정)이라 여백만 남기고 최대한 채운다.
const double _kMaxCardHeightRatio = 0.96;

/// 크루 갤러리 사진 라이트박스.
///
/// 공용 [showWebImageViewer]를 쓰지 않는다 — 그쪽은 타이틀 바·줌 컨트롤·썸네일 스트립이
/// 레이아웃의 골격이고 이미 4개 화면이 의존한다. 목업은 "사진 + 흰 정보 바 + 카드 밖
/// 원형 버튼"이라 구조가 달라서, 딤·루트 Overlay만 [showWebOverlayModal]에서 빌려온다.
Future<void> showLiveCrewPhotoViewer(
  BuildContext context, {
  required List<LiveTalk> talks,
  required int initialIndex,
  required Map<int, CrewCard> crewIndex,
  required void Function(LiveTalk talk) onOpenLiveTalk,
  required Future<void> Function(LiveTalk talk, WebMoreAction action) onMoreAction,
}) {
  if (talks.isEmpty) return Future.value();
  return showWebOverlayModal<void>(
    context: context,
    padding: livecrewPhotoViewerPadding(context),
    builder: (_, close) => _CrewPhotoViewer(
      talks: talks,
      initialIndex: initialIndex.clamp(0, talks.length - 1),
      crewIndex: crewIndex,
      onOpenLiveTalk: onOpenLiveTalk,
      onMoreAction: onMoreAction,
      onClose: close,
    ),
  );
}

/// 딤 가장자리 여백. 카드 크기를 화면에서 직접 계산하므로 **모달 호스트와 뷰어가
/// 같은 값을 봐야** 한다 → 한 곳에 둔다.
EdgeInsets livecrewPhotoViewerPadding(BuildContext context) => EdgeInsets.symmetric(
      // 모바일 15 (목업 161:52899 — 카드 x=15, 폭 345) / PC·태블릿 40.
      horizontal: context.screenType == WebScreenType.mobile ? 15 : 40,
      vertical: 32,
    );

class _CrewPhotoViewer extends StatefulWidget {
  final List<LiveTalk> talks;
  final int initialIndex;
  final Map<int, CrewCard> crewIndex;
  final void Function(LiveTalk talk) onOpenLiveTalk;
  final Future<void> Function(LiveTalk talk, WebMoreAction action) onMoreAction;
  final void Function([void result]) onClose;

  const _CrewPhotoViewer({
    required this.talks,
    required this.initialIndex,
    required this.crewIndex,
    required this.onOpenLiveTalk,
    required this.onMoreAction,
    required this.onClose,
  });

  @override
  State<_CrewPhotoViewer> createState() => _CrewPhotoViewerState();
}

class _CrewPhotoViewerState extends State<_CrewPhotoViewer>
    with SingleTickerProviderStateMixin {
  late int _index;

  /// 모바일 핀치 확대. 손을 떼면 [_zoomReset]이 원래 배율로 되돌린다.
  final TransformationController _zoomCtrl = TransformationController();
  late final AnimationController _zoomReset = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<Matrix4>? _zoomResetAnim;

  /// 확대하는 동안에는 **사진만 남긴다** — 정보 바·버튼을 숨기고 카드 배경도 지운다.
  bool _zooming = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _zoomReset.addListener(() {
      final anim = _zoomResetAnim;
      if (anim != null) _zoomCtrl.value = anim.value;
    });
  }

  @override
  void dispose() {
    _zoomReset.dispose();
    _zoomCtrl.dispose();
    super.dispose();
  }

  void _onZoomStart(ScaleStartDetails details) {
    // 되돌아가는 중에 다시 잡으면 그 자리에서 이어서 확대한다.
    _zoomReset.stop();
  }

  /// ⚠️ 확대 여부는 **update**에서 판단한다. `onInteractionStart`는 손가락 하나로
  /// 먼저 들어오고 두 번째 손가락이 뒤에 붙는 경우가 많아, start에서 두 개를
  /// 기다리면 확대가 아예 인식되지 않는다(실측: 클립도 안 풀리고 복귀도 안 돌았다).
  void _onZoomUpdate(ScaleUpdateDetails details) {
    if (_zooming) return;
    if (details.pointerCount >= 2 || details.scale != 1.0) {
      setState(() => _zooming = true);
    }
  }

  void _onZoomEnd(ScaleEndDetails details) {
    // 놓으면 제자리로 — 되돌아가는 동안에도 UI는 숨겨 둔다.
    if (_zoomCtrl.value == Matrix4.identity()) {
      if (_zooming) setState(() => _zooming = false);
      return;
    }
    _zoomResetAnim = Matrix4Tween(begin: _zoomCtrl.value, end: Matrix4.identity())
        .animate(CurvedAnimation(parent: _zoomReset, curve: Curves.easeOutCubic));
    _zoomReset.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      _zoomCtrl.value = Matrix4.identity();
      setState(() => _zooming = false);
    });
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.talks.length) return;
    setState(() => _index = index);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        widget.onClose();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        _goTo(_index - 1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _goTo(_index + 1);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final talk = widget.talks[_index];

    // ⚠️ 크기를 **화면에서 직접** 계산하고 위젯은 자기 크기만 차지한다.
    // 예전에는 LayoutBuilder로 가용 공간을 전부 받아 그 안에서 정렬했는데,
    // 그러면 모달 호스트(showWebOverlayModal)의 Alignment.center가 할 일이 없어져
    // 팝업이 상단에 붙었다. 다른 웹 팝업들과 같은 구조(= 내재 크기)로 맞춘다.
    final screen = MediaQuery.sizeOf(context);
    final modalPadding = livecrewPhotoViewerPadding(context);
    final availableWidth = screen.width - modalPadding.horizontal;
    final availableHeight = screen.height - modalPadding.vertical;

    // 버튼 자리 — PC·태블릿은 카드 **밖 좌우**, 모바일은 카드 **아래**라 비우는 쪽이 다르다.
    final reserved = isMobile ? 0.0 : _kActionColumnWidth * 2;
    final barHeight = isMobile ? _kMobileBarHeight : _kBarHeight;
    final cardWidth = math.max(160.0, math.min(_kMaxCardWidth, availableWidth - reserved));
    // 목업은 이미지가 정사각(모바일 345×345 / PC 821×821)이다 — 화면 높이가 모자랄
    // 때만 줄이고, 줄일 때도 위아래 여백이 남게 상한(0.88)을 둔다.
    final reservedHeight =
        isMobile ? _kMobileActionGap + _kActionButtonSize : 0.0;
    final imageSize = math.max(
      160.0,
      math.min(
        cardWidth,
        availableHeight * _kMaxCardHeightRatio - barHeight - reservedHeight,
      ),
    );
    final card = _buildCard(talk, width: cardWidth, imageHeight: imageSize);

    final body = isMobile
        // 모바일은 버튼이 카드 밖 **아래 가운데**에 나란히 선다(목업 161:52936/52939).
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              card,
              const SizedBox(height: _kMobileActionGap),
              IgnorePointer(
                ignoring: _zooming,
                child: AnimatedOpacity(
                  opacity: _zooming ? 0 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CircleMoreButton(
                        onSelected: (action) => widget.onMoreAction(talk, action),
                      ),
                      const SizedBox(width: _kActionButtonGap),
                      _CircleIconButton(icon: Icons.close, onTap: widget.onClose),
                    ],
                  ),
                ),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 좌측은 빈 열 — 오른쪽 버튼 열과 폭을 맞춰 카드를 가운데로 보낸다.
              const SizedBox(width: _kActionColumnWidth),
              card,
              SizedBox(
                width: _kActionColumnWidth,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildActions(talk, gap: _kActionButtonGap, vertical: true),
                  ),
                ),
              ),
            ],
          );

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      // 세로로도 자기 높이만 차지해야 모달이 가운데에 놓을 수 있다.
      child: IntrinsicHeight(child: body),
    );
  }

  List<Widget> _buildActions(LiveTalk talk, {required double gap, bool vertical = false}) {
    return [
      _CircleIconButton(icon: Icons.close, onTap: widget.onClose),
      SizedBox(width: vertical ? 0 : gap, height: vertical ? gap : 0),
      _CircleMoreButton(onSelected: (action) => widget.onMoreAction(talk, action)),
    ];
  }

  Widget _buildCard(LiveTalk talk, {required double width, required double imageHeight}) {
    final isMobile = context.screenType == WebScreenType.mobile;

    // 사진 비율이 제각각이라 잘라내지 않고(`contain`) 넣고, 남는 자리는
    // **같은 사진의 블러**로 채운다 — 라이브톡 상세와 같은 공용 위젯이다
    // (회색 바닥은 사진마다 테두리가 달라 보여서 버렸다).
    Widget image = SizedBox(
      width: width,
      height: imageHeight,
      child: LiveTalkImagePane(url: talk.imageUrl, gaplessPlayback: true),
    );

    if (isMobile) {
      image = InteractiveViewer(
        transformationController: _zoomCtrl,
        minScale: 1,
        maxScale: 4,
        // 확대한 사진이 카드 밖으로 넘쳐야 "사진만 떠오른" 느낌이 난다.
        clipBehavior: Clip.none,
        onInteractionStart: _onZoomStart,
        onInteractionUpdate: _onZoomUpdate,
        onInteractionEnd: _onZoomEnd,
        child: image,
      );
    }

    return Material(
      // 확대 중에는 카드 배경·모서리 클립을 지워 사진만 남긴다.
      color: _zooming ? Colors.transparent : SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: _zooming ? Clip.none : Clip.antiAlias,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            image,
            // 확대하는 동안에는 정보 바를 숨긴다(자리는 그대로 둔다 — 사진 위치가
            // 흔들리면 확대 중심이 튄다).
            IgnorePointer(
              ignoring: _zooming,
              child: AnimatedOpacity(
                opacity: _zooming ? 0 : 1,
                duration: const Duration(milliseconds: 150),
                child: _buildInfoBar(context, talk),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, LiveTalk talk) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final crewId = talk.crewId;
    final crew = crewId == null ? null : widget.crewIndex[crewId];
    final logoUrl = crewLogoUrlOf(logoUrl: crew?.crewLogoUrl, color: crew?.color);
    // 크루홈 응답 어느 리스트에도 없는 크루면(순위권 밖) 작성자 닉네임으로 대체한다.
    final title = crew?.crewName ?? talk.userInfo?.displayName ?? '';
    final time = talk.uploadTime != null ? GetDatetime().getAgoString(talk.uploadTime!) : '';
    final nick = crew?.baseResortNickname?.trim() ?? '';
    final sub = [if (nick.isNotEmpty) nick, if (time.isNotEmpty) time].join(' ');

    // 로고·간격·글자 모두 모바일이 한 단계 다르다(목업 161:52907).
    final logoSize = isMobile ? 36.0 : 32.0;

    return Container(
      height: isMobile ? _kMobileBarHeight : _kBarHeight,
      // 좌우 — PC·태블릿 20/20, 모바일 18/12 (목업).
      padding: EdgeInsets.only(left: isMobile ? 18 : 20, right: isMobile ? 12 : 20),
      child: Row(
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              // 공용 비율(한 변의 0.2).
              borderRadius: BorderRadius.circular(crewLogoRadius(logoSize)),
              border: Border.all(color: SDSColor.gray100),
            ),
            clipBehavior: Clip.antiAlias,
            child: (logoUrl?.isNotEmpty ?? false)
                ? WebNetworkImage(url: logoUrl, width: logoSize, height: logoSize)
                : Container(color: SDSColor.gray100),
          ),
          SizedBox(width: isMobile ? 7 : SDSSpacing.sm),
          // 모바일은 크루명 아래에 `리조트 N시간 전`이 **두 줄**로 붙는다(목업 161:52926).
          if (isMobile)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray500),
                    ),
                  ],
                ],
              ),
            )
          // 넓은 폭은 크루명과 `리조트 N시간 전`을 **한 Text로** 묶는다. Flexible 두 개 +
          // Spacer로 짜면 남은 폭을 서로 나눠 가져서 크루명이 통째로 사라진다(실측).
          else
            Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                  ),
                  // 이름 ↔ 부제 12 (목업). 글자를 한 Text에 묶으므로 공백 대신
                  // 투명 글자로 폭을 만든다 — WidgetSpan은 줄 높이를 흔든다.
                  if (sub.isNotEmpty)
                    const WidgetSpan(child: SizedBox(width: 12)),
                  if (sub.isNotEmpty)
                    TextSpan(
                      text: sub,
                      style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: SDSSpacing.sm),
          // 크루 사진은 곧 라이브톡 게시글이라 항상 갈 곳이 있다.
          InkWell(
            onTap: () => widget.onOpenLiveTalk(talk),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(
                    '라이브톡에서 보기',
                    style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                  ),
                  // 글자 ↔ 화살표 6, 화살표 20 · gray300 (목업 161:41707 실측).
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 20, color: SDSColor.gray300),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: _kActionButtonSize,
          height: _kActionButtonSize,
          // 목업(161:41668)은 흰 원 48에 검정 X — 회색이 아니다.
          child: Icon(icon, size: 26, color: SDSColor.gray900),
        ),
      ),
    );
  }
}

/// ⋯ 원형 버튼. 공용 [WebMoreButton]은 SVG 아이콘만 그려서 흰 원 모양이 안 나오므로
/// 앵커 링크 + [showWebFilterMenu](데스크탑 드롭다운 / 좁은 폭 시트 분기)만 같은 방식으로 쓴다.
class _CircleMoreButton extends StatefulWidget {
  final ValueChanged<WebMoreAction> onSelected;

  const _CircleMoreButton({required this.onSelected});

  @override
  State<_CircleMoreButton> createState() => _CircleMoreButtonState();
}

class _CircleMoreButtonState extends State<_CircleMoreButton> {
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    final selected = await showWebFilterMenu<WebMoreAction>(
      context: context,
      link: _link,
      values: const [WebMoreAction.reportPost, WebMoreAction.hideUser],
      labelOf: (a) => a.label,
      centerSheetOnTablet: true,
    );
    if (selected == null) return;
    widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: _CircleIconButton(icon: Icons.more_horiz, onTap: _open),
    );
  }
}
