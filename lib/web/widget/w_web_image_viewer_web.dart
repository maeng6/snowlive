import 'dart:async';

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

class _WebImageViewerState extends State<_WebImageViewer> {
  static const double _minScale = 0.5;
  static const double _maxScale = 4;
  static const double _step = 0.25;

  late int _index;
  final TransformationController _transform = TransformationController();
  double _scale = 1;

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

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: GestureDetector(
        // 배경 탭하면 닫힘
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.withOpacity(0.85),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildTopBar(total),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        // 이미지 영역 탭은 배경으로 전파되지 않게 막는다.
                        onTap: () {},
                        child: InteractiveViewer(
                          transformationController: _transform,
                          minScale: _minScale,
                          maxScale: _maxScale,
                          child: Center(
                            child: WebNetworkImage(
                              url: widget.imageUrls[_index],
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 데스크탑은 목업대로 줌 컨트롤이 우측 세로 배치다.
                    if (isDesktop) ...[
                      const SizedBox(width: 16),
                      _buildZoomControls(vertical: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 태블릿은 하단 가로 배치.
              if (!isMobile && !isDesktop) ...[
                _buildZoomControls(vertical: false),
                const SizedBox(height: 12),
              ],
              if (!isMobile && total > 1) ...[
                _buildThumbnails(),
                const SizedBox(height: 12),
              ],
              _buildBottomButtons(total),
            ],
          ),
        ),
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
    return SizedBox(
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
      child: vertical
          ? Column(mainAxisSize: MainAxisSize.min, children: children)
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: children),
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
            const SizedBox(width: 12),
          ],
          _CircleIconButton(icon: Icons.close, onTap: widget.onClose),
        ],
      ),
    );
  }
}

class _ViewerTextButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ViewerTextButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: SDSColor.gray900),
                Text(label, style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray900)),
              ],
            ),
          ),
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
