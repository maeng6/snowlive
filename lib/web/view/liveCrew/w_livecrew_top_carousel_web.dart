import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_drag_scroll_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_home_sections_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';

/// 카드 한 변(목업 실측). 정사각이라 폭·높이 같은 값을 쓴다.
const double _kCardSize = 186;
const double _kCardGap = SDSSpacing.md;

/// 데스크탑에서 좌측 문구 블록이 차지하는 폭(목업 실측 288).
const double _kLeadWidth = 288;

/// 상단 캐러셀. **주제 하나만** 보여주고 좌우 화살표로 주제를 넘긴다
/// (`이번 시즌 슬로프 점령` → `신규 크루` → `오늘 라이브온` → …, 사용자 확정).
///
/// 우측 카드 줄은 **좌우 스크롤**(마우스 드래그·휠·터치)로 넘긴다 — 화살표는 카드를
/// 밀지 않는다. 넘길 수 있는 경계는 반투명하게 지워 더 있다는 걸 알린다.
///
/// 제목·부제·빈 문구는 [crewHomeSections]가 정한다.
class LiveCrewTopCarouselWeb extends StatefulWidget {
  /// 두 줄 제목(`\n` 포함).
  final String title;
  final String subtitle;

  /// 카드가 없을 때 레일 자리에 넣을 문구(비시즌의 `오늘 …` 섹션).
  final String emptyMessage;
  final List<CrewCard> crews;
  final Map<int, String> resortFullnames;
  final void Function(CrewCard crew) onCrewTap;

  /// 1위 카드를 크루 색으로 채울지(목업은 첫 섹션만).
  final bool highlightFirst;

  /// 이전/다음 **주제**로 넘기기. null이면 그 방향 화살표는 비활성.
  final VoidCallback? onPrevTopic;
  final VoidCallback? onNextTopic;

  const LiveCrewTopCarouselWeb({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.crews,
    required this.onCrewTap,
    this.highlightFirst = false,
    this.resortFullnames = const {},
    this.onPrevTopic,
    this.onNextTopic,
  });

  @override
  State<LiveCrewTopCarouselWeb> createState() => _LiveCrewTopCarouselWebState();
}

class _LiveCrewTopCarouselWebState extends State<LiveCrewTopCarouselWeb> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // 경계 페이드가 스크롤 위치를 따라가야 한다.
    _controller.addListener(_onScroll);
    // 첫 빌드 때는 컨트롤러가 아직 리스트에 붙지 않아 hasClients가 false다 →
    // 스크롤 이벤트가 없으면 페이드 판정이 갱신되지 않는다. 한 번 깨워준다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(LiveCrewTopCarouselWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 주제가 바뀌면 새 목록을 처음부터 보여준다(이전 스크롤 위치가 남으면 중간부터 보인다).
    if (oldWidget.title != widget.title && _controller.hasClients) {
      _controller.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (mounted) setState(() {});
  }

  bool get _canFadeLeft => _controller.hasClients && _controller.offset > 1;

  bool get _canFadeRight =>
      _controller.hasClients && _controller.offset < _controller.position.maxScrollExtent - 1;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final lead = _buildLead();
    final rail = _buildRail();

    if (!isDesktop) {
      // 좁은 폭에서는 문구가 위, 카드가 아래 한 줄이다.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [lead, const SizedBox(height: SDSSpacing.md), rail],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: _kLeadWidth, child: lead),
        Expanded(child: rail),
      ],
    );
  }

  Widget _buildLead() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: SDSTextStyle.bold.copyWith(fontSize: 20, color: SDSColor.gray900, height: 1.35),
        ),
        const SizedBox(height: 6),
        Text(
          widget.subtitle,
          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
        ),
        const SizedBox(height: SDSSpacing.md),
        // 화살표는 카드가 아니라 **주제**를 넘긴다(사용자 확정).
        Row(
          children: [
            _ArrowButton(icon: Icons.chevron_left, onTap: widget.onPrevTopic),
            const SizedBox(width: SDSSpacing.sm),
            _ArrowButton(icon: Icons.chevron_right, onTap: widget.onNextTopic),
          ],
        ),
      ],
    );
  }

  Widget _buildRail() {
    // 비시즌에는 `오늘 …` 리스트가 0개로 온다 → 섹션은 두고 안내만 보여준다(사용자 확정).
    if (widget.crews.isEmpty) {
      return Container(
        height: _kCardSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: SDSColor.gray50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.emptyMessage,
          textAlign: TextAlign.center,
          style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
        ),
      );
    }

    return _EdgeFade(
      // 더 넘길 수 있는 쪽만 흐려진다(목업: 잘린 카드가 경계에서 사라지는 효과).
      fadeLeft: _canFadeLeft,
      fadeRight: _canFadeRight,
      child: SizedBox(
        height: _kCardSize,
        // 마우스로 끌어서도 넘길 수 있게 한다(웹 기본값은 휠만 허용).
        child: WebHorizontalDragScroll(
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemCount: widget.crews.length,
            separatorBuilder: (_, __) => const SizedBox(width: _kCardGap),
            itemBuilder: (_, index) {
              final crew = widget.crews[index];
              return _CrewCarouselCard(
                crew: crew,
                // 1위 크루만 크루 색으로 채워 강조한다(목업의 파란 카드).
                isHighlighted: widget.highlightFirst && index == 0,
                resortFullnames: widget.resortFullnames,
                onTap: () => widget.onCrewTap(crew),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 가로 목록의 **넘길 수 있는 쪽 경계를 반투명하게** 지운다(목업).
///
/// 카드를 잘라서 끝내지 않고 서서히 사라지게 해 더 있다는 것을 알린다. 마스크라서
/// 흰 배경을 덮어 그리는 방식(그라데이션 오버레이)과 달리 배경색과 무관하게 동작한다.
class _EdgeFade extends StatelessWidget {
  final bool fadeLeft;
  final bool fadeRight;
  final Widget child;

  /// 흐려지는 구간 폭(카드 한 장의 1/3 정도).
  static const double _fadeWidth = 64;

  const _EdgeFade({
    required this.fadeLeft,
    required this.fadeRight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 양쪽 다 끝이면 마스크를 걸지 않는다(불필요한 레이어 합성을 피한다).
    if (!fadeLeft && !fadeRight) return child;

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        final fade = (_fadeWidth / bounds.width).clamp(0.0, 0.4);
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            fadeLeft ? const Color(0x00FFFFFF) : const Color(0xFFFFFFFF),
            const Color(0xFFFFFFFF),
            const Color(0xFFFFFFFF),
            fadeRight ? const Color(0x00FFFFFF) : const Color(0xFFFFFFFF),
          ],
          stops: [0, fade, 1 - fade, 1],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: SDSColor.snowliveWhite,
      shape: CircleBorder(side: BorderSide(color: SDSColor.gray200)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 20, color: enabled ? SDSColor.gray900 : SDSColor.gray300),
        ),
      ),
    );
  }
}

class _CrewCarouselCard extends StatelessWidget {
  final CrewCard crew;
  final bool isHighlighted;
  final Map<int, String> resortFullnames;
  final VoidCallback onTap;

  const _CrewCarouselCard({
    required this.crew,
    required this.isHighlighted,
    required this.resortFullnames,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = crewColorOf(crew.color) ?? SDSColor.snowliveBlue;
    final background = isHighlighted ? accent : SDSColor.gray50;
    final nameColor = isHighlighted ? SDSColor.snowliveWhite : SDSColor.gray900;
    final subColor = isHighlighted ? SDSColor.snowliveWhite.withOpacity(0.8) : SDSColor.gray500;
    final logoUrl = crewLogoUrlOf(logoUrl: crew.crewLogoUrl, color: crew.color);
    final subtitle = crewCardSubtitle(crew, resortFullnames: resortFullnames);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: _kCardSize,
          height: _kCardSize,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: SDSSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: SDSColor.snowliveWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (logoUrl?.isNotEmpty ?? false)
                      ? WebNetworkImage(url: logoUrl, width: 64, height: 64)
                      : null,
                ),
                const SizedBox(height: SDSSpacing.md),
                Text(
                  crew.crewName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.bold.copyWith(fontSize: 14, color: nameColor),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular.copyWith(fontSize: 11, color: subColor),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
