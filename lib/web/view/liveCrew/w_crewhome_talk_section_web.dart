import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:flutter/material.dart';

/// 크루톡 섹션의 묶음 방식(목업의 `전체` / `멤버별` 드롭다운).
enum CrewTalkGroupMode {
  all('전체'),
  byMember('멤버별');

  const CrewTalkGroupMode(this.label);
  final String label;
}

/// 작성자별로 묶는다. 목업 `멤버별` 모드가 작성자 한 줄 + 그 사람 사진 스트립이다.
/// 서버가 주는 순서(최신순)를 그대로 유지한다.
List<({int? userId, String name, String? avatarUrl, List<LiveTalk> talks})>
    groupCrewTalksByMember(List<LiveTalk> talks) {
  final order = <int?>[];
  final buckets = <int?, List<LiveTalk>>{};
  for (final talk in talks) {
    final key = talk.userId;
    if (!buckets.containsKey(key)) {
      buckets[key] = [];
      order.add(key);
    }
    buckets[key]!.add(talk);
  }
  return [
    for (final key in order)
      (
        userId: key,
        name: buckets[key]!.first.userInfo?.displayName ?? '',
        avatarUrl: buckets[key]!.first.userInfo?.profileImageUrl,
        talks: buckets[key]!,
      ),
  ];
}

/// 크루홈의 `크루톡 N` 섹션.
///
/// ⚠️ **크루별 크루톡을 조회하는 API가 아직 없다.** `POST /api/livetalk/list/`는
/// `crew_id`를 무시하고 전체 목록을 돌려주고(실측), 크루별 전용 엔드포인트는 404다.
/// 그래서 지금은 항상 빈 목록이 들어와 빈 상태가 보인다 — 서버가 필터를 열어주면
/// 뷰모델에서 목록만 채워주면 이 위젯은 그대로 동작한다.
class CrewHomeTalkSectionWeb extends StatelessWidget {
  final List<LiveTalk> talks;
  final CrewTalkGroupMode mode;
  final ValueChanged<CrewTalkGroupMode> onModeChanged;
  final void Function(LiveTalk talk) onTalkTap;

  /// 크루톡 전체 목록 화면으로 가는 진입점. 목업에는 이 링크가 없지만 목록 화면
  /// (`크루톡` 피드)으로 갈 길이 그 화면 말고는 없어서 사진이 있을 때만 노출한다.
  final VoidCallback? onSeeAll;

  const CrewHomeTalkSectionWeb({
    super.key,
    required this.talks,
    required this.mode,
    required this.onModeChanged,
    required this.onTalkTap,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              // 목업의 제목 옆 숫자는 올라온 크루톡 개수다.
              talks.isEmpty ? '크루톡' : '크루톡 ${talks.length}',
              style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
            ),
            const Spacer(),
            if (talks.isNotEmpty && onSeeAll != null) ...[
              InkWell(
                onTap: onSeeAll,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    '더보기',
                    style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray600),
                  ),
                ),
              ),
              const SizedBox(width: SDSSpacing.sm),
            ],
            WebDropdownTextButton<CrewTalkGroupMode>(
              label: mode.label,
              values: CrewTalkGroupMode.values,
              labelOf: (m) => m.label,
              onSelected: onModeChanged,
            ),
          ],
        ),
        const SizedBox(height: SDSSpacing.md),
        if (talks.isEmpty)
          const WebEmptyState(message: '아직 크루톡이 없어요')
        else if (mode == CrewTalkGroupMode.all)
          CrewTalkPhotoGrid(talks: talks, onTalkTap: onTalkTap)
        else
          _buildByMember(context),
      ],
    );
  }

  Widget _buildByMember(BuildContext context) {
    final groups = groupCrewTalksByMember(talks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          if (i > 0) const SizedBox(height: SDSSpacing.lg),
          Row(
            children: [
              WebAvatar(url: groups[i].avatarUrl, size: 28),
              const SizedBox(width: SDSSpacing.sm),
              Text(
                groups[i].name,
                style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
              ),
            ],
          ),
          const SizedBox(height: SDSSpacing.sm),
          _MemberPhotoStrip(talks: groups[i].talks, onTalkTap: onTalkTap),
        ],
      ],
    );
  }
}

/// 정사각 사진 그리드(`전체` 모드). 크루톡 목록이 없어도 이 위젯은 재사용 가능하다.
class CrewTalkPhotoGrid extends StatelessWidget {
  final List<LiveTalk> talks;
  final void Function(LiveTalk talk) onTalkTap;

  const CrewTalkPhotoGrid({super.key, required this.talks, required this.onTalkTap});

  @override
  Widget build(BuildContext context) {
    final columns = switch (context.screenType) {
      WebScreenType.desktop => 5,
      WebScreenType.tablet => 3,
      WebScreenType.mobile => 2,
    };
    const spacing = SDSSpacing.xs;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return GridView.builder(
          // 부모가 SingleChildScrollView라 스크롤을 꺼야 한다.
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: talks.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cellWidth,
          ),
          itemBuilder: (_, index) => _PhotoCell(
            talk: talks[index],
            size: cellWidth,
            onTap: () => onTalkTap(talks[index]),
          ),
        );
      },
    );
  }
}

/// 멤버별 모드의 가로 스트립. 사진이 많으면 옆으로 스크롤한다.
class _MemberPhotoStrip extends StatelessWidget {
  final List<LiveTalk> talks;
  final void Function(LiveTalk talk) onTalkTap;

  static const double _size = 176;

  const _MemberPhotoStrip({required this.talks, required this.onTalkTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: talks.length,
        separatorBuilder: (_, __) => const SizedBox(width: SDSSpacing.xs),
        itemBuilder: (_, index) => _PhotoCell(
          talk: talks[index],
          size: _size,
          onTap: () => onTalkTap(talks[index]),
        ),
      ),
    );
  }
}

class _PhotoCell extends StatelessWidget {
  final LiveTalk talk;
  final double size;
  final VoidCallback onTap;

  const _PhotoCell({required this.talk, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = talk.imageUrl;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: (url?.isNotEmpty ?? false)
            ? WebNetworkImage(url: url, width: size, height: size)
            : Container(
                width: size,
                height: size,
                color: SDSColor.gray50,
                alignment: Alignment.center,
                // 사진 없는 글(텍스트만)도 크루톡이라 자리를 차지한다.
                child: Padding(
                  padding: const EdgeInsets.all(SDSSpacing.sm),
                  child: Text(
                    talk.description ?? '',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray600),
                  ),
                ),
              ),
      ),
    );
  }
}
