import 'dart:async';
import 'dart:math' as math;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 웹 공용 이미지 라이트박스(커뮤니티 본문·중고거래 갤러리 공용).
///
/// 브레이크포인트별로 구성이 다르다 — 모바일은 이미지 + `‹ › ✕`만, 태블릿·데스크탑은
/// 썸네일 스트립과 확대/축소/맞춤 컨트롤이 붙는다(데스크탑은 우측 세로 배치).
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
const Color _kBackdropColor = Color(0xD9000000);

/// 데스크탑에서 이미지·제목·썸네일이 공유하는 콘텐츠 열 최대폭(목업 실측 약 780).
const double _kContentMaxWidth = 780;

/// 상단 바(제목 + `n / N`) 최소폭. 아주 좁고 긴 사진이면 이미지 폭이 몇십 px까지
/// 내려가는데, 그대로 물리면 `n / N`이 잘려서 최소폭은 지켜준다.
const double _kTopBarMinWidth = 200;

class _WebImageViewerState extends State<_WebImageViewer> {
  static const double _minScale = 0.5;
  static const double _maxScale = 4;
  static const double _step = 0.25;

  late int _index;
  final TransformationController _transform = TransformationController();
  double _scale = 1;

  /// 목업은 제목과 `n / N`이 **이미지 폭에 맞춰** 이미지 바로 위에 놓인다.
  /// 이미지는 BoxFit.contain이라 폭이 사진 비율·화면 크기에 따라 매번 달라져서,
  /// 실제로 그려진 폭을 재서 상단 바에 그대로 물려준다(비율을 미리 알 수 없다).
  final GlobalKey _imageKey = GlobalKey();
  double? _imageWidth;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  void dispose() {
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
    setState(() {
      _scale = next.clamp(_minScale, _maxScale);
      _transform.value = Matrix4.identity()..scale(_scale);
    });
  }

  /// 그려진 이미지 폭을 상단 바에 반영한다. 레이아웃 뒤에만 알 수 있어
  /// 프레임 끝에서 재고, 값이 그대로면 setState를 건너뛴다(무한 루프 방지).
  void _measureImage() {
    if (!mounted) return;
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final width = box.size.width;
    if (width <= 0) return;
    if (_imageWidth != null && (_imageWidth! - width).abs() < 0.5) return;
    setState(() => _imageWidth = width);
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureImage());
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
    final isDesktop = screenType == WebScreenType.desktop;
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          // 목업의 데스크탑 뷰어는 이미지·제목·썸네일이 한 열(약 780)로
                          // 정렬돼 있고, 줌 컨트롤만 그 밖 우측에 떠 있다.
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? _kContentMaxWidth : double.infinity,
                          ),
                          child: Column(
                            children: [
                              // 아직 못 쟀으면(첫 프레임) 열 폭 그대로 → 다음 프레임에 이미지 폭으로.
                              SizedBox(
                                width: _imageWidth == null
                                    ? null
                                    : math.max(_imageWidth!, _kTopBarMinWidth),
                                child: _buildTopBar(total),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: GestureDetector(
                                  // 이미지 영역 탭은 배경으로 전파되지 않게 막는다.
                                  onTap: () {},
                                  child: InteractiveViewer(
                                    transformationController: _transform,
                                    minScale: _minScale,
                                    maxScale: _maxScale,
                                    child: Center(
                                      // 사진이 로드되면서 폭이 바뀌는 순간에도 다시 재야 한다
                                      // (부모는 리빌드되지 않으므로 크기 변경 알림으로 잡는다).
                                      child: NotificationListener<SizeChangedLayoutNotification>(
                                        onNotification: (_) {
                                          _scheduleMeasure();
                                          return true;
                                        },
                                        child: SizeChangedLayoutNotifier(
                                          key: _imageKey,
                                          child: WebNetworkImage(
                                            url: widget.imageUrls[_index],
                                            fit: BoxFit.contain,
                                            gaplessPlayback: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // 태블릿은 줌 컨트롤을 하단 가로 배치.
                              if (!isMobile && !isDesktop) ...[
                                _buildZoomControls(vertical: false),
                                const SizedBox(height: 12),
                              ],
                              // 목업 순서: 이미지 → `‹ › ✕` → 썸네일 스트립.
                              _buildBottomButtons(total),
                              if (!isMobile && total > 1) ...[
                                const SizedBox(height: 16),
                                _buildThumbnails(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 데스크탑은 목업대로 줌 컨트롤이 우측에 세로로 떠 있다.
                    if (isDesktop) ...[
                      const SizedBox(width: 16),
                      _buildZoomControls(vertical: true),
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

  Widget _buildTopBar(int total) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${_index + 1} / $total',
          style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
        ),
      ],
    );
  }

  Widget _buildThumbnails() {
    // 목업은 썸네일 스트립이 열 가운데 정렬이다. shrinkWrap이라 Center 안에서
    // 내용만큼만 넓어지고, 넘칠 때는 열 폭까지 차면서 그대로 스크롤된다.
    return Center(
      child: SizedBox(
        height: 56,
        child: GestureDetector(
          onTap: () {},
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: widget.imageUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final isCurrent = i == _index;
              return GestureDetector(
                onTap: () => _goTo(i),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCurrent ? SDSColor.snowliveBlue : Colors.white24,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: WebNetworkImage(url: widget.imageUrls[i], width: 56, height: 56),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls({required bool vertical}) {
    final children = [
      _ViewerTextButton(label: '확대', icon: Icons.zoom_in, onTap: () => _setScale(_scale + _step)),
      _ViewerTextButton(label: '축소', icon: Icons.zoom_out, onTap: () => _setScale(_scale - _step)),
      _ViewerTextButton(label: '맞춤', icon: Icons.fit_screen, onTap: () => setState(_resetZoom)),
    ];
    return GestureDetector(
      onTap: () {},
      // 목업은 버튼 3개가 각각 흰 카드가 아니라 **흰 패널 하나로 묶여** 있다.
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Flex(
          direction: vertical ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: children,
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
              icon: Icons.chevron_left,
              onTap: _index > 0 ? () => _goTo(_index - 1) : null,
            ),
            const SizedBox(width: 12),
            _CircleIconButton(
              icon: Icons.chevron_right,
              onTap: _index < total - 1 ? () => _goTo(_index + 1) : null,
            ),
            // 목업은 ✕가 화살표 쌍보다 한 칸 더 떨어져 있다(닫기와 이동을 구분).
            const SizedBox(width: 24),
          ],
          _CircleIconButton(icon: Icons.close, onTap: widget.onClose),
        ],
      ),
    );
  }
}

/// [_buildZoomControls]의 묶음 패널 안에 들어가는 항목 하나(아이콘 + 라벨).
class _ViewerTextButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ViewerTextButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: SDSColor.gray900),
            const SizedBox(height: 2),
            Text(label, style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray900)),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: onTap == null ? Colors.black26 : Colors.black87),
        ),
      ),
    );
  }
}
