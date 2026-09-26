import 'dart:async';
import 'dart:math' as math;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 웹 공용 이미지 라이트박스(커뮤니티 본문·중고거래 갤러리 공용).
///
/// 브레이크포인트별로 구성이 다르다 — 모바일은 이미지 + `‹ › ✕`만, 태블릿은
/// 하단 가로 줌 컨트롤 + 썸네일. 데스크탑은 네이버 부동산식:
/// 제목·`n / N`·✕가 뷰포트 상단에, `‹ ›`는 브라우저 양끝 세로 중앙에 붙고
/// 줌 컨트롤(흰 알약 패널)은 눕혀서 이미지 아래 중앙에 둔다.
///
/// `Navigator.push`로는 GNB를 덮을 수 없어서(셸이 라우트 Navigator를 감싼다)
/// main_web.dart가 셸보다 위에 깔아둔 최상위 Overlay에 직접 꽂는다.
///
/// [onIndexChanged]는 뒤에 있는 캐러셀 등과 인덱스를 맞춰야 할 때 쓴다(중고거래 갤러리).
Future<void> showWebImageViewer({
  required BuildContext context,
  required String title,
  required List<String> imageUrls,
  required int initialIndex,
  ValueChanged<int>? onIndexChanged,
}) {
  if (imageUrls.isEmpty) return Future.value();

  final overlay = Overlay.of(context, rootOverlay: true);
  final completer = Completer<void>();
  late final OverlayEntry entry;
  var isClosed = false;

  void close() {
    if (isClosed) return;
    isClosed = true;
    entry.remove();
    completer.complete();
  }

  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: _WebImageViewer(
        title: title,
        imageUrls: imageUrls,
        initialIndex: initialIndex.clamp(0, imageUrls.length - 1),
        onIndexChanged: onIndexChanged,
        onClose: close,
      ),
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

/// 프로필 사진·크루 로고 한 장을 확대해서 본다(앱과 동일).
///
/// 사진이 한 장이면 뷰어가 썸네일·화살표를 자동으로 감추고 `✕`만 남긴다.
Future<void> showWebPhotoViewer(
  BuildContext context, {
  required String? url,
  String title = '',
}) {
  if (url == null || url.isEmpty) return Future.value();
  return showWebImageViewer(
    context: context,
    title: title,
    imageUrls: [url],
    initialIndex: 0,
  );
}

class _WebImageViewer extends StatefulWidget {
  final String title;
  final List<String> imageUrls;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback onClose;

  const _WebImageViewer({
    required this.title,
    required this.imageUrls,
    required this.initialIndex,
    required this.onIndexChanged,
    required this.onClose,
  });

  @override
  State<_WebImageViewer> createState() => _WebImageViewerState();
}

/// 딤 색(목업). Overlay 최상위에 한 겹으로만 깐다.
/// 라이브톡 상세 오버레이도 같은 농도를 쓴다(사진 확대 계열 공통).
const Color kWebImageViewerBackdropColor = Color(0xD9000000);
const Color _kBackdropColor = kWebImageViewerBackdropColor;

/// 데스크탑에서 이미지·제목·썸네일이 공유하는 콘텐츠 열 최대폭(목업 실측 약 780).
const double _kContentMaxWidth = 780;

/// 상단 바(제목 + `n / N`) 최소폭. 아주 좁고 긴 사진이면 이미지 폭이 몇십 px까지
/// 내려가는데, 그대로 물리면 `n / N`이 잘려서 최소폭은 지켜준다.
const double _kTopBarMinWidth = 200;

class _WebImageViewerState extends State<_WebImageViewer>
    with SingleTickerProviderStateMixin {
  static const double _minScale = 0.5;
  static const double _maxScale = 4;
  static const double _step = 0.25;

  /// 썸네일 타일 64, hover 시 72까지 커진다. 활성 링(흰 [_kThumbRing])은 타일
  /// **바깥을 덮어** 그린다 — 레이아웃 폭에는 안 들어가서 썸네일 사이 시각 간격
  /// 6px가 유지되고, 링은 옆 간격·딤 위로 겹친다.
  static const double _kThumbSize = 64;
  static const double _kThumbHoverSize = 72;
  static const double _kThumbRing = 3;

  late int _index;
  final TransformationController _transform = TransformationController();
  double _scale = 1;

  /// hover 중인 썸네일 인덱스(없으면 null) — 스트립 확대 애니메이션용.
  int? _hoveredThumb;

  /// 무대는 정사각(가용 영역의 min(가로, 세로))이라 사진 비율과 무관하고,
  /// 뷰포트 크기가 바뀔 때만 달라진다 — 레이아웃 뒤에 실측해 이미지 레이어에 쓴다.
  final GlobalKey _imageKey = GlobalKey();

  /// 실제 이미지는 컬럼 안이 아니라 **화면 전체를 덮는 InteractiveViewer 레이어**에
  /// 그린다 — 컬럼 안에 두면 히트 영역이 무대 사각형에 갇혀서, 확대로
  /// 커진 이미지의 바깥 부분을 드래그할 수 없다. 컬럼의 무대 자리는 빈 SizedBox로
  /// 자리만 잡고, 실측한 무대 사각형([_stageRect], [_stackKey] 좌표계)에 이미지를
  /// 얹는다.
  final GlobalKey _stackKey = GlobalKey();
  Rect? _stageRect;

  /// 모바일 핀치 확대 후 손을 떼면 원래 배율로 스르륵 복귀시키는 애니메이션.
  late final AnimationController _snapBackCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  void dispose() {
    _snapBackCtrl.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.imageUrls.length) return;
    setState(() {
      _index = index;
      // 확대한 채로 다음 사진으로 넘어가면 줌이 그대로 새어 나간다 → 매번 리셋.
      _resetZoom();
    });
    widget.onIndexChanged?.call(index);
  }

  void _resetZoom() {
    _scale = 1;
    _transform.value = Matrix4.identity();
  }

  void _setScale(double next) {
    // Matrix4.scale은 좌상단(0,0) 기준이라 그대로 쓰면 확대할수록 이미지가
    // 우하단으로 밀려난다 → 무대 중앙점을 앵커로 잡아 가운데에서 커지게 한다.
    // (좌표계는 화면 전체 레이어 기준이라 무대 사각형의 중앙점을 쓴다.)
    final Offset anchor = _stageRect?.center ?? Offset.zero;
    setState(() {
      _scale = next.clamp(_minScale, _maxScale);
      _transform.value = Matrix4.identity()
        ..translateByDouble(anchor.dx, anchor.dy, 0, 1)
        ..scaleByDouble(_scale, _scale, 1, 1)
        ..translateByDouble(-anchor.dx, -anchor.dy, 0, 1);
    });
  }

  /// 무대 자리의 실측값을 반영한다 — 폭은 상단 바에, 사각형(레이어 좌표)은 이미지
  /// 레이어에 쓴다. 레이아웃 뒤에만 알 수 있어 프레임 끝에서 재고, 값이 그대로면
  /// setState를 건너뛴다(무한 루프 방지).
  void _measureImage() {
    if (!mounted) return;
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || stack == null || !stack.hasSize) return;
    final width = box.size.width;
    if (width <= 0) return;
    final rect = box.localToGlobal(Offset.zero, ancestor: stack) & box.size;
    if (_stageRect != null &&
        (_stageRect!.left - rect.left).abs() < 0.5 &&
        (_stageRect!.top - rect.top).abs() < 0.5 &&
        (_stageRect!.width - rect.width).abs() < 0.5) {
      return;
    }
    setState(() => _stageRect = rect);
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureImage());
  }

  /// 스와이프 판정용 드래그 궤적(InteractiveViewer의 인터랙션 콜백에서 기록).
  Offset? _swipeStart;
  Offset? _swipeLast;

  /// 태블릿·모바일에서 확대되지 않은 상태의 가로 드래그는 장 넘김으로 처리한다.
  /// 확대 중에는 드래그가 이미지 이동이어야 하므로 판정하지 않는다.
  void _handleSwipeEnd() {
    final start = _swipeStart;
    final last = _swipeLast;
    _swipeStart = null;
    _swipeLast = null;
    if (start == null || last == null) return;
    if (context.isDesktop) return;
    if (_transform.value.getMaxScaleOnAxis() > 1.05) return;
    final dx = last.dx - start.dx;
    final dy = last.dy - start.dy;
    // 세로 성분이 더 크거나 이동이 짧으면 스와이프가 아니다.
    if (dx.abs() < 60 || dx.abs() < dy.abs()) return;
    _goTo(dx < 0 ? _index + 1 : _index - 1);
  }

  /// 모바일: 핀치를 놓으면 원래 배율(1)로 스르륵 복귀한다(피드 미리보기식 줌).
  /// 태블릿·PC는 확대 상태를 유지한다.
  void _maybeSnapBack() {
    if (context.screenType != WebScreenType.mobile) return;
    final current = _transform.value;
    if ((current.getMaxScaleOnAxis() - 1).abs() < 0.01) return;
    final anim = Matrix4Tween(
      begin: current,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(parent: _snapBackCtrl, curve: Curves.easeOut));
    void tick() => _transform.value = anim.value;
    anim.addListener(tick);
    _snapBackCtrl.forward(from: 0).whenCompleteOrCancel(() {
      anim.removeListener(tick);
      _scale = 1;
    });
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
    final screenType = context.screenType;
    final isMobile = screenType == WebScreenType.mobile;
    // 태블릿도 데스크탑 배치(상단 바 뷰포트 고정, `‹ ›` 양끝, ✕ 우상단)를 쓴다.
    final isDesktopLike = !isMobile;
    final total = widget.imageUrls.length;
    _scheduleMeasure();

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Stack(
        children: [
          // 딤은 콘텐츠와 섞지 않고 독립 레이어로 깐다. Container(color:)에 padding·child를
          // 같이 얹었을 때 딤이 화면에 나타나지 않는 경우가 있었다.
          Positioned.fill(
            child: GestureDetector(
              // 배경 탭하면 닫힘
              onTap: widget.onClose,
              child: const ColoredBox(color: _kBackdropColor),
            ),
          ),
          // Overlay는 Material 밖이라, 감싸지 않으면 모든 글자에 노란 이중 밑줄(에러 스타일)이 붙는다.
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                // 모바일은 이미지·썸네일이 화면 끝까지 닿는 풀블리드(피그마 46:11719).
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 0 : 24,
                  vertical: 16,
                ),
                child: Stack(
                  key: _stackKey,
                  // 확대된 이미지가 패딩 영역 밖까지 그려져야 해서 잘라내지 않는다.
                  clipBehavior: Clip.none,
                  children: [
                    // 이미지 레이어 — 화면 전체가 InteractiveViewer라 확대로 커진
                    // 이미지의 어느 부분에서든 드래그로 이동할 수 있다.
                    // Stack 첫 자식이라 상단바·화살표·컨트롤들보다 아래에 그려진다.
                    // 무대 사각형은 실측 후에만 아니까 첫 프레임은 비워둔다.
                    if (_stageRect != null)
                      Positioned.fill(
                        child: InteractiveViewer(
                          transformationController: _transform,
                          minScale: _minScale,
                          maxScale: _maxScale,
                          clipBehavior: Clip.none,
                          onInteractionStart: (d) {
                            // 복귀 애니메이션 중 다시 잡으면 멈추고 이어서 조작.
                            _snapBackCtrl.stop();
                            _swipeStart = d.focalPoint;
                            _swipeLast = d.focalPoint;
                          },
                          onInteractionUpdate: (d) => _swipeLast = d.focalPoint,
                          onInteractionEnd: (_) {
                            _handleSwipeEnd();
                            _maybeSnapBack();
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fromRect(
                                rect: _stageRect!,
                                child: GestureDetector(
                                  // 이미지 영역 탭은 배경 닫힘으로 안 새게 막는다.
                                  onTap: () {},
                                  behavior: HitTestBehavior.opaque,
                                  child: WebNetworkImage(
                                    url: widget.imageUrls[_index],
                                    width: _stageRect!.width,
                                    height: _stageRect!.height,
                                    fit: BoxFit.contain,
                                    gaplessPlayback: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Center(
                      child: ConstrainedBox(
                        // 데스크탑도 이미지·줌 컨트롤·썸네일은 한 열(약 780)로 정렬.
                        constraints: BoxConstraints(
                          maxWidth: isDesktopLike
                              ? _kContentMaxWidth
                              : double.infinity,
                        ),
                        child: Column(
                          children: [
                            if (isDesktopLike)
                              // 데스크탑 상단 바는 뷰포트에 붙는 Positioned라
                              // (네이버 부동산식), 무대가 침범하지 않게 높이만
                              // 비워둔다(바 48 + 간격 20).
                              const SizedBox(height: 68)
                            else ...[
                              // 모바일: 제목·카운터를 상단 중앙에 세로로 쌓는다
                              // (피그마 46:11719).
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: SDSTextStyle.bold.copyWith(
                                  fontSize: 16,
                                  color: SDSColor.snowliveWhite,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_index + 1} / $total',
                                style: SDSTextStyle.regular.copyWith(
                                  fontSize: 16,
                                  color: SDSColor.snowliveWhite,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            Expanded(
                              child: Padding(
                                // 모바일은 뷰어 전체가 풀블리드(패딩 0)라, 이미지
                                // 무대에만 좌우 16을 준다(썸네일은 끝까지 유지).
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16 : 0,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, box) {
                                    // PC·태블릿: 사진 비율과 무관한 **정사각 고정
                                    // 무대**(피그마 46:14659의 678×678 대응).
                                    // 모바일: 세로 가용영역 전체를 무대로 써서
                                    // 세로 사진이 크게 나온다(사진은 contain).
                                    // 실제 이미지는 화면 전체 레이어(위 Stack 첫
                                    // 자식)에 그리고, 여기는 자리만 잡는 빈 박스다
                                    // — 실측(_imageKey)해서 레이어에 물려준다.
                                    final double side = math.min(
                                      box.maxWidth,
                                      box.maxHeight,
                                    );
                                    return Center(
                                      child: SizedBox(
                                        key: _imageKey,
                                        width: isMobile ? box.maxWidth : side,
                                        height: isMobile ? box.maxHeight : side,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // 이미지 ↔ 하단 컨트롤 20.
                            const SizedBox(height: 20),
                            if (isDesktopLike) ...[
                              // 네이버 부동산식: 이미지 → 줌 아이콘 줄 → 썸네일.
                              // 우측 세로 패널이던 줌 컨트롤을 그대로 눕혀서
                              // 하단 중앙에 둔다.
                              _buildZoomControls(vertical: false),
                              if (total > 1) ...[
                                // 줌 알약 ↔ 썸네일 32.
                                const SizedBox(height: 32),
                                _buildThumbnails(),
                              ],
                            ] else ...[
                              // 모바일: 이미지 → 썸네일 → `‹ › ✕`(피그마 46:11719,
                              // 썸네일은 시안 밖 추가 요청).
                              if (total > 1) ...[
                                _buildThumbnails(),
                                const SizedBox(height: 20),
                              ],
                              _buildBottomButtons(total),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (isDesktopLike) ...[
                      // 상단 바: 제목(좌) · `n / N`(중앙) · ✕(우) — 뷰포트 기준.
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 48,
                          child: LayoutBuilder(
                            builder: (context, bar) {
                              final counterStyle = SDSTextStyle.regular
                                  .copyWith(
                                    fontSize: 16,
                                    color: SDSColor.snowliveWhite,
                                  );
                              // 긴 제목은 중앙 카운터 왼쪽 40px 앞에서 자른다
                              // (카운터 폭은 자릿수마다 달라 실측한다).
                              final counterPainter = TextPainter(
                                text: TextSpan(
                                  text: '${_index + 1} / $total',
                                  style: counterStyle,
                                ),
                                textDirection: TextDirection.ltr,
                              )..layout();
                              final double maxTitleWidth = math.max(
                                _kTopBarMinWidth,
                                bar.maxWidth / 2 -
                                    counterPainter.width / 2 -
                                    40,
                              );
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: maxTitleWidth,
                                      ),
                                      child: Text(
                                        widget.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: SDSTextStyle.bold.copyWith(
                                          fontSize: 16,
                                          color: SDSColor.snowliveWhite,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${_index + 1} / $total',
                                    style: counterStyle,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: WebIconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 28,
                                        color: SDSColor.snowliveWhite,
                                      ),
                                      onTap: widget.onClose,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      // `‹ ›`는 브라우저 양끝(여백 30) 세로 중앙에 붙는다.
                      // 탭 존은 원형(48)보다 넓게 — 화면 안쪽 42/상하 86씩 깔아서
                      // 대략 96×220 영역 어디를 눌러도 넘어간다.
                      // 바깥쪽 6은 가로 패딩 24와 합쳐 뷰포트 여백 30을 만든다.
                      if (total > 1) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _CircleIconButton(
                            iconBuilder: (c) => _arrowIcon(c, toRight: false),
                            hoverShift: -3,
                            hitPadding: const EdgeInsets.fromLTRB(
                              6,
                              86,
                              42,
                              86,
                            ),
                            onTap: _index > 0 ? () => _goTo(_index - 1) : null,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _CircleIconButton(
                            iconBuilder: (c) => _arrowIcon(c, toRight: true),
                            hoverShift: 3,
                            hitPadding: const EdgeInsets.fromLTRB(
                              42,
                              86,
                              6,
                              86,
                            ),
                            onTap: _index < total - 1
                                ? () => _goTo(_index + 1)
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnails() {
    // 목업은 썸네일 스트립이 열 가운데 정렬이다. shrinkWrap이라 Center 안에서
    // 내용만큼만 넓어지고, 넘칠 때는 열 폭까지 차면서 그대로 스크롤된다.
    // 썸네일 64, 간격 6, 활성 링 흰색 3(타일 바깥에 덮임),
    // hover 시 72로 스르륵 커지며(150ms easeOut) 옆 썸네일을 밀어낸다 —
    // 바깥 AnimatedContainer의 **폭**이 실제로 변해서 리스트가 다시 흐른다.
    return Center(
      child: SizedBox(
        // 링이 타일 위아래로 3px씩 삐져나오므로 그만큼 여유를 준다.
        height: _kThumbHoverSize + _kThumbRing * 2,
        child: GestureDetector(
          onTap: () {},
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: widget.imageUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final isCurrent = i == _index;
              final double size = _hoveredThumb == i
                  ? _kThumbHoverSize
                  : _kThumbSize;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hoveredThumb = i),
                onExit: (_) => setState(() => _hoveredThumb = null),
                child: GestureDetector(
                  onTap: () => _goTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    width: size,
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      width: size,
                      height: size,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              // 원본 이미지가 커서 썸네일 로딩이 느리다. 로딩
                              // 진행 이벤트가 안 오는 환경에서도 자리표시가
                              // 보이도록, 이미지 **뒤에** 스켈레톤을 항상 깔고
                              // 첫 프레임이 도착하면 이미지가 위를 덮는다.
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  const SkeletonShimmer(child: SkeletonBox()),
                                  WebNetworkImage(
                                    url: widget.imageUrls[i],
                                    width: size,
                                    height: size,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 활성 링: 이미지 **바깥**을 덮는다(위 상수 주석 참고).
                          Positioned(
                            left: -_kThumbRing,
                            top: -_kThumbRing,
                            right: -_kThumbRing,
                            bottom: -_kThumbRing,
                            child: IgnorePointer(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.easeOut,
                                decoration: BoxDecoration(
                                  // 이미지 radius 8 + 링 3 = 동심원 11.
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                    width: _kThumbRing,
                                    color: isCurrent
                                        ? SDSColor.snowliveWhite
                                        : Colors.transparent,
                                  ),
                                ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls({required bool vertical}) {
    // 아이콘은 돋보기 대신 심플하게 + / − / 모서리만 있는 포커스(crop_free).
    final gap = vertical
        ? const SizedBox(height: 10)
        // 가로 배치 항목 간격 6.
        : const SizedBox(width: 6);
    final children = [
      _ViewerTextButton(
        label: '확대',
        icon: Icons.add,
        onTap: () => _setScale(_scale + _step),
      ),
      gap,
      _ViewerTextButton(
        label: '축소',
        icon: Icons.remove,
        onTap: () => _setScale(_scale - _step),
      ),
      gap,
      _ViewerTextButton(
        label: '맞춤',
        icon: Icons.crop_free,
        onTap: () => setState(_resetZoom),
      ),
    ];
    return GestureDetector(
      onTap: () {},
      // 목업은 버튼 3개가 각각 흰 카드가 아니라 **흰 패널 하나로 묶여** 있다.
      // 라벨 없이 아이콘 26만, 상하 패딩 12.
      // 좌우 끝은 높이 무관하게 완전한 반원(스타디움).
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: vertical
              ? const EdgeInsets.symmetric(vertical: 14, horizontal: 6)
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Flex(
            direction: vertical ? Axis.vertical : Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(int total) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (total > 1) ...[
            _CircleIconButton(
              iconBuilder: (c) => _arrowIcon(c, toRight: false),
              hoverShift: -3,
              onTap: _index > 0 ? () => _goTo(_index - 1) : null,
            ),
            // 화살표 사이 16, ✕ 앞 32 (피그마 46:14659 실측 17/34 근사).
            const SizedBox(width: 16),
            _CircleIconButton(
              iconBuilder: (c) => _arrowIcon(c, toRight: true),
              hoverShift: 3,
              onTap: _index < total - 1 ? () => _goTo(_index + 1) : null,
            ),
            const SizedBox(width: 32),
          ],
          _CircleIconButton(
            iconBuilder: (c) => Icon(Icons.close, size: 24, color: c),
            onTap: widget.onClose,
          ),
        ],
      ),
    );
  }
}

/// [_buildZoomControls]의 묶음 패널 안에 들어가는 항목 하나 — 아이콘만 쓰고
/// 이름은 툴팁으로 보여준다.
class _ViewerTextButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ViewerTextButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ViewerTextButton> createState() => _ViewerTextButtonState();
}

class _ViewerTextButtonState extends State<_ViewerTextButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // 아이콘 26.
    // hover는 웹 공통 규칙 — 60% 투명도 150ms 페이드.
    return Tooltip(
      message: widget.label,
      // 검정 배경·흰 글자, 아이콘 위쪽에 표시.
      preferBelow: false,
      verticalOffset: 24,
      decoration: BoxDecoration(
        color: SDSColor.snowliveBlack,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: SDSTextStyle.regular.copyWith(
        fontSize: 12,
        color: SDSColor.snowliveWhite,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedOpacity(
            opacity: _hovered ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: SizedBox(
              width: 44,
              child: Icon(widget.icon, size: 26, color: SDSColor.gray900),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatefulWidget {
  /// 비활성이면 흐린 색이 내려오므로, 아이콘은 색을 받아 그리는 빌더로 받는다.
  final Widget Function(Color color) iconBuilder;
  final VoidCallback? onTap;

  /// hover 시 아이콘만 가로로 살짝 미는 거리(px). 화살표가 자기 방향을
  /// 가리키게 왼쪽은 음수, 오른쪽은 양수. 0이면 효과 없음.
  final double hoverShift;

  /// 눈에 보이는 원형(48) 둘레로 넓히는 투명 탭 존 여백. 좌우 이동 화살표처럼
  /// 놓치기 쉬운 버튼에 쓴다 — 존 어디를 눌러도 탭이고 hover 효과도
  /// 존 전체에서 걸린다. 원형의 화면상 위치는 그대로 두고 존만 비대칭으로 넓힐 수
  /// 있게 패딩으로 받는다. null이면 원형 크기 그대로
  final EdgeInsets? hitPadding;

  const _CircleIconButton({
    required this.iconBuilder,
    required this.onTap,
    this.hoverShift = 0,
    this.hitPadding,
  });

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final double dx = _hovered && enabled ? widget.hoverShift : 0;
    // 피그마 46:14659: 원형 48, 그림자 없는 플랫 화이트
    final Widget circle = Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (h) => setState(() => _hovered = h),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(dx, 0, 0),
              child: widget.iconBuilder(
                enabled ? Colors.black87 : Colors.black26,
              ),
            ),
          ),
        ),
      ),
    );
    final EdgeInsets? hitPadding = widget.hitPadding;
    if (hitPadding == null) return circle;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Padding(padding: hitPadding, child: circle),
      ),
    );
  }
}

Widget _arrowIcon(Color color, {required bool toRight}) {
  return Icon(
    toRight ? Icons.chevron_right : Icons.chevron_left,
    size: 30,
    color: color,
  );
}
