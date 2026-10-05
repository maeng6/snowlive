import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_web_section_link_button_web.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_filter_sheet_web.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_edge_fade_web.dart';
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
    // ⚠️ 작성자 키는 최상위 `user_id`가 비는 응답이 있어 `user_info.user_id`로
    // 떨어뜨린다 — 둘 다 null로 보면 모든 글이 한 덩어리로 묶여 멤버가 하나만 뜬다.
    final key = talk.userId ?? talk.userInfo?.userId;
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
/// 크루홈에 그리는 사진 수 상한. 크루톡이 수백 장이어도 섹션이 끝없이 길어지면
/// 아래 내용(푸터 등)이 멀어진다 — 더 보려면 `전체 크루톡 보기`로 간다.
/// PC 5열 기준 4줄.
const int kCrewHomeTalkPreviewCount = 20;

/// `멤버별` 보기에서 보여줄 **멤버 수** 상한. 나머지는 `전체 크루톡 보기`에서.
const int kCrewHomeTalkMemberCount = 10;

/// 멤버 한 줄(가로 스크롤)에 보여줄 사진 수 상한.
const int kCrewHomeTalkPerMemberCount = 20;

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
            // 필터가 **왼쪽**, 전체보기 버튼이 오른쪽 끝(사용자 확정).
            FleamarketFilterPill<CrewTalkGroupMode>(
              label: mode.label,
              // 기본값(전체)이 아닐 때만 검정으로 채워 "필터가 걸렸다"를 알린다.
              isActive: mode != CrewTalkGroupMode.all,
              values: CrewTalkGroupMode.values,
              labelOf: (m) => m.label,
              onSelected: onModeChanged,
            ),
            // 전체 화면 진입 버튼 — 다른 섹션의 `전체 슬로프 보기`·`전체 멤버`와
            // **같은 규격**(테두리 gray100 · 라운드 6 · 패딩 12/10 · 높이 36 · Bold 13).
            if (talks.isNotEmpty && onSeeAll != null) ...[
              const SizedBox(width: SDSSpacing.sm),
              WebSectionLinkButton(label: '전체 크루톡 보기', onTap: onSeeAll!),
            ],
          ],
        ),
        const SizedBox(height: SDSSpacing.md),
        if (talks.isEmpty)
          const WebEmptyState(message: '아직 크루톡이 없어요')
        else if (mode == CrewTalkGroupMode.all)
          // 상한까지만 그린다(나머지는 `전체 크루톡 보기`에서).
          CrewTalkPhotoGrid(
            talks: talks.take(kCrewHomeTalkPreviewCount).toList(),
            onTalkTap: onTalkTap,
          )
        else
          _buildByMember(context),
      ],
    );
  }

  Widget _buildByMember(BuildContext context) {
    // 멤버별은 **사진 수가 아니라 멤버 수**로 상한을 둔다 — 전체 보기처럼 사진
    // 수로 자르면 뒤쪽 멤버가 통째로 사라지고, 앞 멤버의 줄도 몇 장 안 남는다.
    // 한 줄은 어차피 가로 스크롤이라 길어져도 화면을 밀어내지 않는다.
    final groups = groupCrewTalksByMember(talks)
        .take(kCrewHomeTalkMemberCount)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          if (i > 0) const SizedBox(height: SDSSpacing.lg),
          Row(
            children: [
              WebAvatar(
                url: groups[i].avatarUrl,
                size: 28,
                userId: groups[i].userId,
              ),
              const SizedBox(width: SDSSpacing.sm),
              Text(
                groups[i].name,
                style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
              ),
            ],
          ),
          const SizedBox(height: SDSSpacing.sm),
          _MemberPhotoStrip(
            talks: groups[i].talks.take(kCrewHomeTalkPerMemberCount).toList(),
            onTalkTap: onTalkTap,
          ),
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
      // 태블릿 4열(목업 161:93951 — 760 안에 192.7 × 4, 간격 2).
      WebScreenType.tablet => 4,
      WebScreenType.mobile => 2,
    };
    // 셀 사이 2 — 사진이 거의 맞붙은 모자이크다(목업 161:87165).
    const spacing = 2.0;

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
    // 가로 스크롤은 **화면 좌우 끝까지** 이어진다 — 페이지 여백만큼 양쪽으로
    // 비져 나가게 넓히고(OverflowBox), 같은 값을 ListView 안쪽 패딩으로 되돌려
    // 첫 사진은 여전히 콘텐츠 좌측선에 맞춘다. 사진이 여백 구간으로 흘러 들어가
    // 끊기지 않고 사라진다.
    //
    // ⚠️ 비져 나가는 폭은 **페이지 여백까지만**이다. PC 좌측은 GNB 사이드바
    // 바로 앞에서 멈춘다(더 넓히면 사이드바 위에 사진이 그려진다).
    final double bleed = webSubPagePadding(context).left;

    return SizedBox(
      height: _size,
      child: LayoutBuilder(
        builder: (context, constraints) => OverflowBox(
          alignment: Alignment.center,
          minWidth: 0,
          maxWidth: constraints.maxWidth + bleed * 2,
          // PC만 좌우 끝을 흰색으로 덮어 사진이 서서히 사라지게 한다
          // (라이브크루 캐러셀과 동일). 태블릿·모바일은 목업대로 화면 끝까지 그대로.
          child: _MaybeEdgeFade(
            enabled: context.isDesktop,
            child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: bleed),
            itemCount: talks.length,
            separatorBuilder: (_, __) => const SizedBox(width: SDSSpacing.xs),
            itemBuilder: (_, index) => _PhotoCell(
              talk: talks[index],
              size: _size,
              onTap: () => onTalkTap(talks[index]),
            ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [enabled]일 때만 좌우 흰색 페이드를 덮는다(끄면 자식을 그대로 통과시킨다).
class _MaybeEdgeFade extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const _MaybeEdgeFade({required this.enabled, required this.child});

  @override
  Widget build(BuildContext context) =>
      enabled ? WebEdgeFade(child: child) : child;
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

