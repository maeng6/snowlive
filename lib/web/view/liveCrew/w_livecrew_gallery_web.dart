import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';

/// `우리 이런 크루입니다` — 여러 크루가 올린 **전체공개** 사진 모음.
///
/// 사진 한 장이 곧 라이브톡 게시글이다(크루 사진 전용 저장소가 서버에 없다).
/// 공개 여부 필터는 [crewGalleryTalks]에서 이미 걸러 넘겨받는다.
class LiveCrewGalleryWeb extends StatelessWidget {
  final List<LiveTalk> talks;
  final void Function(int index) onPhotoTap;

  const LiveCrewGalleryWeb({super.key, required this.talks, required this.onPhotoTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '우리 이런 크루입니다',
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
        ),
        // 제목 ↔ 그리드 16 (목업).
        const SizedBox(height: 16),
        if (talks.isEmpty)
          const WebEmptyState(message: '아직 사진이 없어요')
        else
          _buildGrid(context),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    final columns = switch (context.screenType) {
      WebScreenType.desktop => 5,
      // 태블릿 4열 — 목업(161:63990) 셀 192.67, 간격 2.
      WebScreenType.tablet => 4,
      WebScreenType.mobile => 2,
    };
    // 셀 사이 간격 2 — 사진이 거의 맞붙은 모자이크다(목업 161:39737~)
    const spacing = 2.0;
    // 셀은 정사각이 아니라 세로가 살짝 길다(173.2 × 175.8).
    const cellAspect = 175.8 / 173.2;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 부모가 SingleChildScrollView라 GridView는 shrinkWrap + 스크롤 비활성이어야 한다.
        // (중고거래 그리드와 같은 계산)
        final cellWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: talks.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cellWidth * cellAspect,
          ),
          itemBuilder: (_, index) => _PhotoCell(
            talk: talks[index],
            size: cellWidth,
            onTap: () => onPhotoTap(index),
          ),
        );
      },
    );
  }
}

/// 사진 한 칸. hover에서 **검정 8%**가 덮여 살짝 어두워진다(누를 수 있다는 신호)
class _PhotoCell extends StatefulWidget {
  final LiveTalk talk;
  final double size;
  final VoidCallback onTap;

  const _PhotoCell({required this.talk, required this.size, required this.onTap});

  @override
  State<_PhotoCell> createState() => _PhotoCellState();
}

class _PhotoCellState extends State<_PhotoCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            WebNetworkImage(
              url: widget.talk.imageUrl,
              width: widget.size,
              height: widget.size,
            ),
            // 사진마다 색이 달라 배경 틴트로는 반응이 안 보인다 → 위에 덮는다.
            // 전환은 웹 공통대로 애니메이션 없이 즉시.
            if (_hovered)
              ColoredBox(color: Colors.black.withValues(alpha: 0.08)),
          ],
        ),
      ),
    );
  }
}
