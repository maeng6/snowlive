import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_home_sections_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';

/// 선택한 칩의 크루 목록. 데스크탑 3열 / 태블릿 2열 / 모바일 1열이고,
/// 열은 **위에서 아래로** 채운다(목업).
class LiveCrewListGridWeb extends StatelessWidget {
  final List<CrewCard> crews;
  final void Function(CrewCard crew) onCrewTap;

  const LiveCrewListGridWeb({super.key, required this.crews, required this.onCrewTap});

  @override
  Widget build(BuildContext context) {
    if (crews.isEmpty) {
      return const WebEmptyState(message: '아직 크루가 없어요.');
    }

    final columns = switch (context.screenType) {
      WebScreenType.desktop => 3,
      WebScreenType.tablet => 2,
      WebScreenType.mobile => 1,
    };
    final chunks = splitIntoColumns(crews, columns);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < chunks.length; i++) ...[
            if (i > 0) Container(width: 1, color: SDSColor.gray100),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : SDSSpacing.md,
                  right: i == chunks.length - 1 ? 0 : SDSSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final crew in chunks[i])
                      _CrewListRow(crew: crew, onTap: () => onCrewTap(crew)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CrewListRow extends StatefulWidget {
  final CrewCard crew;
  final VoidCallback onTap;

  const _CrewListRow({required this.crew, required this.onTap});

  @override
  State<_CrewListRow> createState() => _CrewListRowState();
}

class _CrewListRowState extends State<_CrewListRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final crew = widget.crew;
    final logoUrl = crewLogoUrlOf(logoUrl: crew.crewLogoUrl, color: crew.color);
    final subtitle = crewRowSubtitle(crew);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? SDSColor.gray50 : SDSColor.snowliveWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.sm, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SDSColor.gray100),
                ),
                clipBehavior: Clip.antiAlias,
                child: (logoUrl?.isNotEmpty ?? false)
                    ? WebNetworkImage(url: logoUrl, width: 44, height: 44)
                    : Container(color: SDSColor.gray100),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      crew.crewName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
