import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewHome.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_drag_scroll_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_home_sections_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'dart:async';


import 'package:com.snowlive/web/widget/w_web_edge_fade_web.dart';
import 'package:flutter/material.dart';

/// 카드 한 변(목업 실측). 정사각이라 폭·높이 같은 값을 쓴다.
/// 카드 크기. 목업(161:38844)은 192×189인데 실제 화면에서 커 보여 한 단계 줄였다
/// (가로:세로 비율은 유지 — 세로가 살짝 짧다).
const double _kCardWidth = 168;
const double _kCardHeight = 166;

/// 모바일 카드 — 목업(161:50103) 121.9 × 120. 화면이 좁아 한 줄에 서너 장이
/// 보이도록 한 단계 더 줄인다(PC·태블릿은 위 값 그대로).
const double _kMobileCardWidth = 122;
const double _kMobileCardHeight = 120;

bool _isMobile(BuildContext context) => context.screenType == WebScreenType.mobile;
/// 카드 치수 — 스켈레톤이 같은 크기로 자리를 잡아야 해서 공개한다.
double crewCarouselCardWidth(BuildContext context) =>
    _isMobile(context) ? _kMobileCardWidth : _kCardWidth;
double crewCarouselCardHeight(BuildContext context) =>
    _isMobile(context) ? _kMobileCardHeight : _kCardHeight;

/// 레일(가로 리스트) 높이 = 카드 + 그림자 여유(위아래 16씩).
/// 카드보다 위아래로 여유를 둬야 hover 시 **떠오른 카드와 그림자가 잘리지 않는다**
/// — 가로 리스트는 제 높이 밖을 잘라낸다.
double crewCarouselRailHeight(BuildContext context) => crewCarouselCardHeight(context) + 32;

double _cardWidth(BuildContext context) => crewCarouselCardWidth(context);
double _cardHeight(BuildContext context) => crewCarouselCardHeight(context);
double _railHeight(BuildContext context) => crewCarouselRailHeight(context);

/// hover 시 카드가 떠오르는 높이.
const double _kCardLift = 3;

/// hover 시 확대 비율 — 들어올린 느낌을 더한다(너무 키우면 옆 카드와 겹쳐 보인다).
const double _kCardHoverScale = 1.015;
/// 카드 사이 간격 — PC·태블릿 16 / 모바일 10.
/// 모바일은 카드가 작아 16이면 휑하고, 목업값(6.35)은 너무 붙어 보여 가운데로 잡았다.
const double _kCardGap = SDSSpacing.md;
const double _kMobileCardGap = 10;
double _cardGap(BuildContext context) => _isMobile(context) ? _kMobileCardGap : _kCardGap;

/// 데스크탑 좌측 문구 블록 폭 — 목업 텍스트가 263이라 그보다 좁으면 타이틀이
/// 3줄로 접힌다. 263 + 캐러셀과의 간격 16.
const double _kLeadWidth = 279;

/// 상단 캐러셀. **주제 하나만** 보여주고 좌우 화살표로 주제를 넘긴다
/// (`이번 시즌 슬로프 점령` → `신규 크루` → `오늘 라이브온` → …).
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

  /// 지금 보고 있는 주제와 전체 개수. 전환 **방향**(좌/우)을 정하고 점 인디케이터를 그린다.
  final int topicIndex;
  final int topicCount;

  /// 점을 눌러 바로 그 주제로 가기.
  final ValueChanged<int>? onSelectTopic;

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
    this.topicIndex = 0,
    this.topicCount = 1,
    this.onSelectTopic,
  });

  @override
  State<LiveCrewTopCarouselWeb> createState() => _LiveCrewTopCarouselWebState();
}

class _LiveCrewTopCarouselWebState extends State<LiveCrewTopCarouselWeb>
    with SingleTickerProviderStateMixin {
  /// `keepScrollOffset: false`가 중요하다 — true면 `jumpTo`가 끝날 때마다
  /// `saveScrollOffset()`이 `PageStorage.maybeOf(storageContext)`를 조회하는데,
  /// 자동 스크롤 타이머가 **레일이 막 트리에서 빠진 프레임**에 걸리면
  /// "Looking up a deactivated widget's ancestor is unsafe"로 터진다.
  /// 이 레일은 주제가 바뀌면 어차피 0으로 되돌리므로 위치를 저장할 이유가 없다.
  final ScrollController _controller = ScrollController(keepScrollOffset: false);

  /// 자동으로 흘러가는 타이머. 목록을 두 번 이어 붙여(아래 `_loopCount`) 끝에 닿으면
  /// 한 바퀴 길이만큼 되돌려서 끊김 없이 반복한다.
  Timer? _autoScroll;

  /// 사용자가 보고 있거나 직접 끌고 있는 동안에는 멈춘다.
  bool _paused = false;

  /// 주제 전환 애니메이션. 누른 화살표 방향으로 새 내용이 들어온다.
  late final AnimationController _topicCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1,
  );

  /// 새 내용이 들어오는 방향(+1 = 오른쪽에서, -1 = 왼쪽에서).
  double _enterDirection = 1;

  /// 들어올 때의 가로 이동량(px) — 카드 줄은 크게, 문구는 작게 움직인다.
  static const double _kRailEnterShift = 24;
  static const double _kLeadEnterShift = 8;

  /// 카드 등장 연출을 켜 두는 구간. **주제가 바뀐 직후에만** 켠다 —
  /// 계속 켜 두면 자동 스크롤로 다시 들어오는 카드마다 떠올라서 깜빡여 보인다.
  bool _staggerActive = true;
  Timer? _staggerTimer;

  void _playStagger() {
    _staggerTimer?.cancel();
    _staggerActive = true;
    // 마지막 카드 지연(240) + 재생(220)보다 넉넉히.
    _staggerTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _staggerActive = false);
    });
  }

  /// 프레임당 이동량(px). 60fps에서 초당 약 33px(0.4 = 24px에서 한 단계 올림).
  static const double _stepPerFrame = 0.55;

  /// 목록을 몇 번 이어 붙일지. 아주 크게 잡고 **가운데에서 시작**해 좌우 양쪽으로
  /// 사실상 무한히 끌 수 있게 한다(경계에서 jumpTo로 되돌리면 끌던 손이 끊긴다).
  /// 카드는 지연 생성이고 칸 폭이 고정(`itemExtent`)이라 이 숫자가 커도 비용이 없다.
  static const int _loopCount = 400;

  /// 한 바퀴(원본 목록 하나)의 길이.
  double _lapExtent(int count) => count * (_cardWidth(context) + _cardGap(context));

  /// 시작 위치 — 가운데 바퀴. 여기서 왼쪽으로도 200바퀴를 끌 수 있다.
  double _startOffset(int count) => _lapExtent(count) * (_loopCount ~/ 2);

  /// 목록이 바뀌었을 때(주제 전환) 레일을 시작 위치로 돌린다.
  void _resetRail() {
    if (!_controller.hasClients) return;
    _controller.jumpTo(_canLoop ? _startOffset(widget.crews.length) : 0);
  }

  /// 자동 스크롤을 걸 만큼 카드가 있는지(한 화면에 다 들어오면 움직일 이유가 없다).
  bool get _canLoop => widget.crews.length > 2;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _playStagger();
    // 첫 레이아웃 뒤라야 스크롤 위치를 잡을 수 있다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _resetRail());
  }

  @override
  void didUpdateWidget(LiveCrewTopCarouselWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicIndex == widget.topicIndex) return;
    // 주제가 바뀌면 새 목록을 처음부터 보여준다(이전 스크롤 위치가 남으면 중간부터 보인다).
    _resetRail();
    // 누른 방향대로 새 내용이 밀려 들어온다 → 어느 쪽으로 넘어갔는지가 읽힌다.
    // 끝 ↔ 처음으로 **순환**할 때는 인덱스 크기만 보면 방향이 거꾸로 나오므로
    // 그 두 경우를 따로 집어낸다.
    final last = widget.topicCount - 1;
    if (oldWidget.topicIndex == last && widget.topicIndex == 0) {
      _enterDirection = 1;
    } else if (oldWidget.topicIndex == 0 && widget.topicIndex == last) {
      _enterDirection = -1;
    } else {
      _enterDirection = widget.topicIndex > oldWidget.topicIndex ? 1 : -1;
    }
    _topicCtrl.forward(from: 0);
    _playStagger();
  }

  @override
  void dispose() {
    _autoScroll?.cancel();
    _staggerTimer?.cancel();
    _topicCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 전환 중 가로로 밀어 주는 래퍼. 레일은 ListView가 하나뿐이어야 해서
  /// (스크롤 컨트롤러가 둘에 붙으면 터진다) 교체 대신 **들어오는 연출만** 준다.
  Widget _slideIn(Widget child, double shift) {
    final curved = CurvedAnimation(parent: _topicCtrl, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curved,
      builder: (_, inner) => Transform.translate(
        offset: Offset((1 - curved.value) * shift * _enterDirection, 0),
        child: Opacity(opacity: curved.value.clamp(0, 1), child: inner),
      ),
      child: child,
    );
  }

  void _startAutoScroll() {
    _autoScroll?.cancel();
    // 약 60fps. Ticker 대신 타이머를 쓰는 이유는 멈춤/재개가 단순해서다.
    _autoScroll = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || _paused || !_canLoop) return;
      if (!_controller.hasClients || !_controller.position.hasContentDimensions) return;
      // 레일이 트리에서 빠지는 중이면(주제 전환·폭 변경으로 리빌드) 건드리지 않는다.
      if (!(_controller.position.context.storageContext.mounted)) return;
      // 사용자가 끌고 있는 중에는 건드리지 않는다.
      if (_controller.position.isScrollingNotifier.value) return;

      final max = _controller.position.maxScrollExtent;
      if (max <= 0) return;
      final next = _controller.offset + _stepPerFrame;
      // 끝 바퀴에 닿기 전에 한 바퀴 뒤로 접어 둔다(그림이 같아 티가 안 난다).
      // 400바퀴라 실제로는 거의 걸리지 않는 안전장치다.
      final lap = _lapExtent(widget.crews.length);
      _controller.jumpTo(next > max - lap ? next - lap : next);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final lead = _slideIn(_buildLead(), _kLeadEnterShift);
    final rail = _slideIn(_buildRail(), _kRailEnterShift);

    if (isDesktop) {
      // 좌측은 **문구 → 점 인디케이터 → 좌우 화살표** 순, 우측은 레일(목업 161:38007).
      return Row(
        // 좌측 문구는 캐러셀 세로 가운데에 온다(목업: 텍스트 중심과 캐러셀 중심이 같다).
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: _kLeadWidth, child: lead),
          Expanded(child: rail),
        ],
      );
    }

    {
      // 좁은 폭에서는 **카드 줄이 위, 문구가 아래**다(태블릿 목업 161:62234 —
      // 레일 y=127.5, 문구 y=318). 레일은 페이지 여백을 넘어 화면 끝까지 흐른다.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fullBleedRail(context, rail),
          // 카드 ↔ 문구: 태블릿 30 / 모바일 24.5(목업). 레일이 카드 아래로 그림자
          // 여유 16을 품고 있어 그만큼 뺀 값을 준다.
          SizedBox(height: _isMobile(context) ? 8 : 14),
          lead,
        ],
      );
    }

  }

  /// 레일을 페이지 여백 밖(화면 좌우 끝)까지 넓힌다. 카드가 가장자리에서 잘려
  /// 보여야 "옆에 더 있다"가 전달된다(목업 레일 x=-32 ~ 814).
  /// ⚠️ 높이를 못 박지 않으면 Column 안에서 자식이 아예 안 그려진다.
  Widget _fullBleedRail(BuildContext context, Widget rail) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: _railHeight(context),
      child: OverflowBox(
        minWidth: screenWidth,
        maxWidth: screenWidth,
        minHeight: _railHeight(context),
        maxHeight: _railHeight(context),
        child: rail,
      ),
    );
  }

  /// 화살표는 카드가 아니라 **주제**를 넘긴다. 왼쪽의 점은 전체 몇 개 중
  /// 몇 번째 주제인지 알려주고, 눌러서 바로 갈 수도 있다.
  Widget _buildDots() => _TopicDots(
        count: widget.topicCount,
        index: widget.topicIndex,
        onSelect: widget.onSelectTopic,
      );

  Widget _buildArrows() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ArrowButton(icon: Icons.chevron_left, onTap: widget.onPrevTopic),
          // 화살표 사이 10 (목업).
          const SizedBox(width: 10),
          _ArrowButton(icon: Icons.chevron_right, onTap: widget.onNextTopic),
        ],
      );

  Widget _buildLead() {
    final isDesktop = context.isDesktop;
    // 좁은 폭에서는 제목이 한 줄로 흐른다(목업 — PC의 두 줄 줄바꿈을 쓰지 않는다).
    final title = isDesktop ? widget.title : widget.title.replaceAll('\n', ' ');
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          // 제목 — PC·태블릿 20 / 모바일 18 (목업 161:50213 높이 23).
          style: SDSTextStyle.bold.copyWith(
            fontSize: _isMobile(context) ? 18 : 20,
            color: SDSColor.gray900,
            height: 1.35,
          ),
        ),
        // 제목 ↔ 부제: PC 6 / 좁은 폭 4 (목업).
        SizedBox(height: isDesktop ? 6 : 4),
        Text(
          widget.subtitle,
          style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
        ),
      ],
    );

    // PC는 문구 아래에 점 인디케이터, 그 아래에 화살표가 붙는다.
    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          texts,
          const SizedBox(height: 10),
          if (widget.topicCount > 1) ...[
            _buildDots(),
            const SizedBox(height: 20),
          ],
          _buildArrows(),
        ],
      );
    }

    // 좁은 폭에서는 화살표가 문구 **오른쪽 끝**에 서고(목업 Frame 996 x=702)
    // 점 인디케이터는 PC와 같이 **문구 아래** 왼쪽에 붙는다.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: texts),
            const SizedBox(width: SDSSpacing.md),
            _buildArrows(),
          ],
        ),
        if (widget.topicCount > 1) ...[
          const SizedBox(height: 10),
          _buildDots(),
        ],
      ],
    );
  }

  Widget _buildRail() {
    // 비시즌에는 `오늘 …` 리스트가 0개로 온다 → 섹션은 두고 안내만 보여준다.
    if (widget.crews.isEmpty) {
      return Container(
        height: _railHeight(context),
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

    final count = widget.crews.length;
    // 같은 목록을 수백 번 이어 붙이고 가운데에서 시작한다 → 좌우 어느 쪽으로 끌어도
    // 끝이 안 나온다(실제로 만들어지는 카드는 화면에 보이는 몇 개뿐).
    final itemCount = _canLoop ? count * _loopCount : count;

    return WebEdgeFade(
      // 자동으로 흐르는 동안 양 끝이 항상 흰색으로 덮인다(목업).
      child: MouseRegion(
        // 마우스를 올리면 멈춰서 읽거나 누를 수 있게 한다.
        onEnter: (_) => _paused = true,
        onExit: (_) => _paused = false,
        child: SizedBox(
          height: _railHeight(context),
          // 마우스로 끌어서도 넘길 수 있게 한다(웹 기본값은 휠만 허용).
          child: WebHorizontalDragScroll(
            // ⚠️ `itemExtent` 필수 — 크기가 제각각인 목록은 먼 위치로 점프할 때
            // **처음부터 항목을 만들어 가며** 그 지점을 찾는다. 가운데 바퀴에서
            // 시작하는 구조라 그러면 진입 순간 카드 수천 개를 만드느라 멈춘다(실측).
            // 폭을 고정하면 바로 계산으로 찾아간다. 간격은 칸 안쪽 패딩으로 준다.
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemExtent: _cardWidth(context) + _cardGap(context),
              itemBuilder: (_, index) {
                final crew = widget.crews[index % count];
                // 카드는 칸 왼쪽에 붙이고 오른쪽 여백이 카드 사이 간격이 된다.
                // 세로는 레일 가운데 — 위아래 여유가 그림자 자리다.
                return Padding(
                  padding: EdgeInsets.only(right: _cardGap(context)),
                  child: Center(
                  // 주제가 바뀌면 키가 바뀌어 등장 애니메이션이 다시 돈다
                  // (카드가 30ms씩 밀려 떠오르며 "새 묶음"이 깔린 느낌을 준다).
                  child: _StaggerIn(
                    key: ValueKey('${widget.topicIndex}:$index'),
                    order: index % count,
                    // 전환 직후에만 연출한다 — 자동 스크롤로 되들어오는 카드는 그냥 보인다.
                    animate: _staggerActive,
                    child: _CrewCarouselCard(
                      crew: crew,
                      // 1위 크루만 크루 색으로 채워 강조한다(목업의 파란 카드).
                      isHighlighted: widget.highlightFirst && index % count == 0,
                      resortFullnames: widget.resortFullnames,
                      onTap: () => widget.onCrewTap(crew),
                    ),
                  ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 주제를 넘기는 화살표. 목업(161:38957) — **24 원 · 배경 gray50 · 화살표 검정**
/// (흰 배경 + 회색 테두리가 아니다).
/// hover에서는 **배경 검정 · 화살표 흰색**으로 반전된다(사용자 확정) — 화살표가 작아서
/// 배경 틴트만으로는 반응이 거의 안 보인다.
class _ArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, this.onTap});

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final isHovered = enabled && _hovered;
    final background = isHovered ? SDSColor.gray900 : SDSColor.gray50;
    final Color iconColor;
    if (!enabled) {
      iconColor = SDSColor.gray300;
    } else {
      iconColor = isHovered ? SDSColor.snowliveWhite : SDSColor.gray900;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: background,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          // hover 반응은 배경색이 담당한다(웹 공통 — 리플·오버레이 없음).
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          child: SizedBox(
            // 목업은 24인데 실제 화면에서 작아 눌러지는 느낌이 없어 28로 키웠다(사용자 확정)
            width: 36,
            height: 36,
            child: Icon(widget.icon, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _CrewCarouselCard extends StatefulWidget {
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
  State<_CrewCarouselCard> createState() => _CrewCarouselCardState();
}

class _CrewCarouselCardState extends State<_CrewCarouselCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final crew = widget.crew;
    final accent = crewColorOf(crew.color) ?? SDSColor.snowliveBlue;
    // 기본은 회색. **마우스를 올린 카드만** 그 크루의 색으로 채워지고 그림자가 뜬다.
    final active = _hovered;
    final background = active ? accent : SDSColor.gray50;
    final nameColor = active ? SDSColor.snowliveWhite : SDSColor.gray900;
    final subColor = active ? SDSColor.snowliveWhite.withValues(alpha: 0.8) : SDSColor.gray500;
    final logoUrl = crewLogoUrlOf(logoUrl: crew.crewLogoUrl, color: crew.color);
    final subtitle = crewCardSubtitle(crew, resortFullnames: widget.resortFullnames);
    final isMobile = _isMobile(context);
    // 로고 — 목업: PC 64 / 모바일 50.8(161:50105).
    final logoSize = isMobile ? 50.0 : 64.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        // 색만 바뀌는 게 아니라 **살짝 떠오르면서 커진다** — 집어 올린 느낌.
        // 확대는 카드 중심 기준이라 좌우로도 조금씩 자란다.
        transform: active
            ? (Matrix4.identity()
              ..translate(0.0, -_kCardLift)
              ..scale(_kCardHoverScale))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          // 그림자 두 겹 — 가까운 그림자가 바닥에 닿는 느낌을, 먼 그림자가 깊이를 만든다.
          // 둘 다 그 크루 색을 머금는다.
          boxShadow: active
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    offset: const Offset(0, 2),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    offset: const Offset(0, 6),
                    blurRadius: 16,
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
        child: SizedBox(
          width: _cardWidth(context),
          height: _cardHeight(context),
          child: Padding(
            // 카드가 작아진 만큼 상단 여백도 한 단계 줄였다(목업 28).
            // 모바일은 카드가 122×120이라 여백·로고·글자를 한 단계씩 더 줄인다.
            padding: isMobile
                ? const EdgeInsets.fromLTRB(10, 16, 10, 10)
                : const EdgeInsets.fromLTRB(14, 22, 14, 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: SDSColor.snowliveWhite,
                    // 공용 비율(한 변의 0.2).
                    borderRadius: BorderRadius.circular(crewLogoRadius(logoSize)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (logoUrl?.isNotEmpty ?? false)
                      ? WebNetworkImage(url: logoUrl, width: logoSize, height: logoSize)
                      : null,
                ),
                SizedBox(height: isMobile ? 10 : SDSSpacing.md),
                Text(
                  crew.crewName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: isMobile ? 12 : 14, color: nameColor),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: isMobile ? 10 : 11, color: subColor),
                  ),
                ],
              ],
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }
}

/// 카드 하나의 등장 연출 — [order]만큼 늦게 시작해 아래에서 떠오르며 나타난다.
/// 주제가 바뀔 때 키가 바뀌어 다시 실행된다.
class _StaggerIn extends StatefulWidget {
  final int order;

  /// false면 연출 없이 그대로 그린다(자동 스크롤 중 되들어오는 카드).
  final bool animate;
  final Widget child;

  const _StaggerIn({
    super.key,
    required this.order,
    required this.animate,
    required this.child,
  });

  @override
  State<_StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<_StaggerIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    if (!widget.animate) {
      _ctrl.value = 1;
      return;
    }
    // 30ms씩 밀되 너무 길어지지 않게 8장까지만(= 최대 240ms) 늦춘다.
    final delay = Duration(milliseconds: widget.order.clamp(0, 8) * 30);
    Future<void>.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curved,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, (1 - curved.value) * 6),
        child: Opacity(opacity: curved.value.clamp(0, 1), child: child),
      ),
      child: widget.child,
    );
  }
}

/// 주제 점 인디케이터 — 모두 같은 크기의 원이고 **현재 주제만 진하다**.
class _TopicDots extends StatelessWidget {
  final int count;
  final int index;
  final ValueChanged<int>? onSelect;

  const _TopicDots({required this.count, required this.index, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          MouseRegion(
            cursor: onSelect == null ? MouseCursor.defer : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onSelect == null ? null : () => onSelect!(i),
              // 점이 작아서 히트 영역을 세로로 넓힌다.
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == index ? SDSColor.gray900 : SDSColor.gray200,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
