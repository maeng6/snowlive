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
          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
        ),
        const SizedBox(height: SDSSpacing.md),
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
      WebScreenType.tablet => 3,
      WebScreenType.mobile => 2,
    };
    const spacing = SDSSpacing.xs;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 부모가 SingleChildScrollView라 GridView는 shrinkWrap + 스크롤 비활성이어야 한다
        // (중고거래 그리드와 같은 계산).
        final cellWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: talks.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cellWidth,
          ),
          itemBuilder: (_, index) {
            final talk = talks[index];
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onPhotoTap(index),
                child: WebNetworkImage(
                  url: talk.imageUrl,
                  width: cellWidth,
                  height: cellWidth,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
