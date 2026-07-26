import 'dart:async';

import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart' show kFleamarketDefaultImage;
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 상세화면 이미지 클릭 시 뜨는 풀스크린 뷰어(라이트박스).
/// 어두운 배경 위에 이미지를 크게 보여주고, 좌우 화살표/닫기 버튼으로 조작한다.
///
/// WebAppShell(GNB)이 라우트 Navigator를 감싸는 구조라 Navigator.push로는 GNB를
/// 덮을 수 없다. 그래서 main_web.dart에 추가해 둔 최상위 Overlay를
/// `rootOverlay: true`로 직접 찾아 OverlayEntry를 꽂는 방식으로 화면 전체를 덮는다.
Future<void> showFleamarketImageViewerWeb({
  required BuildContext context,
  required List<Photo> photos,
  required int initialIndex,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final completer = Completer<void>();
  late final OverlayEntry entry;

  void close() {
    entry.remove();
    if (!completer.isCompleted) completer.complete();
  }

  entry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: FleamarketImageViewerWeb(photos: photos, initialIndex: initialIndex, onClose: close),
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

class FleamarketImageViewerWeb extends StatefulWidget {
  final List<Photo> photos;
  final int initialIndex;
  final VoidCallback onClose;

  const FleamarketImageViewerWeb({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.onClose,
  });

  @override
  State<FleamarketImageViewerWeb> createState() => _FleamarketImageViewerWebState();
}

class _FleamarketImageViewerWebState extends State<FleamarketImageViewerWeb> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.photos.length) return;
    setState(() => _index = index);
    Get.find<FleamarketDetailViewModel>().updateCurrentIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_index];

    return GestureDetector(
      // 이미지 바깥(딤 처리된 배경) 탭하면 닫힘
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
            // 버튼 줄을 이미지와 같은 폭 제약 안에 넣어서, 화면 양끝이 아니라
            // 이미지 바로 아래(이미지 좌우 끝에 맞춰) 붙도록 한다.
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    // 이미지 자체를 탭했을 때는 닫히지 않도록 이벤트 전파 차단
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (photo.urlFleaPhoto?.isNotEmpty ?? false)
                          ? WebNetworkImage(
                              url: photo.urlFleaPhoto,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                              fallback: Image.asset(kFleamarketDefaultImage, fit: BoxFit.contain),
                            )
                          : Image.asset(kFleamarketDefaultImage, fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.photos.length > 1)
                      Row(
                        children: [
                          _CircleIconButton(
                            icon: Icons.chevron_left,
                            onTap: _index > 0 ? () => _goTo(_index - 1) : null,
                          ),
                          const SizedBox(width: 8),
                          _CircleIconButton(
                            icon: Icons.chevron_right,
                            onTap: _index < widget.photos.length - 1 ? () => _goTo(_index + 1) : null,
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    _CircleIconButton(icon: Icons.close, onTap: widget.onClose),
                  ],
                ),
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
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: onTap == null ? Colors.black26 : Colors.black87),
        ),
      ),
    );
  }
}
