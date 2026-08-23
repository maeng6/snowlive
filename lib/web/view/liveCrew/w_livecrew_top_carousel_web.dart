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

/// `오늘 가장 많은 슬로프를 점령한 크루` 캐러셀.
///
/// 좌우 화살표로 **카드 한 칸씩** 움직인다. 웹에 재사용할 캐러셀 위젯이 없어서
/// (중고거래 상세는 `carousel_slider` + 점 인디케이터, 이미지 뷰어의 화살표는 private)
/// `ScrollController.animateTo`로 직접 만든다.
class LiveCrewTopCarouselWeb extends StatefulWidget {
  final List<CrewCard> crews;
  final Map<int, String> resortFullnames;
  final void Function(CrewCard crew) onCrewTap;

  const LiveCrewTopCarouselWeb({
    super.key,
    required this.crews,
    required this.onCrewTap,
    this.resortFullnames = const {},
  });

  @override
  State<LiveCrewTopCarouselWeb> createState() => _LiveCrewTopCarouselWebState();
}

class _LiveCrewTopCarouselWebState extends State<LiveCrewTopCarouselWeb> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // 화살표 활성/비활성이 스크롤 위치를 따라가야 한다.
    _controller.addListener(_onScroll);
    // 첫 빌드 때는 컨트롤러가 아직 리스트에 붙지 않아 hasClients가 false다 →
    // 스크롤 이벤트가 없으면 화살표가 영구히 비활성으로 남는다(실측). 한 번 깨워준다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
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

  bool get _canGoBack => _controller.hasClients && _controller.offset > 1;

  bool get _canGoForward =>
      _controller.hasClients && _controller.offset < _controller.position.maxScrollExtent - 1;

  void _scrollBy(double delta) {
    if (!_controller.hasClients) return;
    final target = (_controller.offset + delta)
        .clamp(0.0, _controller.position.maxScrollExtent);
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

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
          '오늘 가장 많은\n슬로프를 점령한 크루',
          style: SDSTextStyle.bold.copyWith(fontSize: 20, color: SDSColor.gray900, height: 1.35),
        ),
        const SizedBox(height: 6),
        Text(
          '어느 크루가 최다 슬로프를 점령했을까?',
          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
        ),
        const SizedBox(height: SDSSpacing.md),
        Row(
          children: [
            _ArrowButton(
              icon: Icons.chevron_left,
              onTap: _canGoBack ? () => _scrollBy(-(_kCardSize + _kCardGap)) : null,
            ),
            const SizedBox(width: SDSSpacing.sm),
            _ArrowButton(
              icon: Icons.chevron_right,
              onTap: _canGoForward ? () => _scrollBy(_kCardSize + _kCardGap) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRail() {
    return _EdgeFade(
      // 더 넘길 수 있는 쪽만 흐려진다(목업: 잘린 카드가 경계에서 사라지는 효과).
      fadeLeft: _canGoBack,
      fadeRight: _canGoForward,
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
                // 오늘 1위 크루만 크루 색으로 채워 강조한다(목업의 초록 카드).
                isHighlighted: index == 0,
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
