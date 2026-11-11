import 'dart:async';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/campaign/ski_theme.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart' show HomeFooterWeb;
import 'package:com.snowlive/web/viewmodel/campaign/vm_phoenix_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 휘팍 개장빵 이벤트 랜딩 — 스키장 도트(픽셀아트) 테마.
/// 색/형태/스프라이트는 SNOWLIVE_EVENT_UI_GUIDE.md를 따른다(상단 헤더·채팅버튼 제외).

const _ootdTags = ['@phoenixhnr', '@snowlive', '#휘팍OOTD'];

// [임시] 개장빵 선착순 60명 등록 상태를 더미로 보여주기 위한 데모 플래그.
const bool _kDemo60 = true;

// 카드별 채움색 + 아이콘 스프라이트 + 아이콘 단색.
const _catFill = {
  'early_bird': SkiColors.yellow,
  'fast_rider': SkiColors.ice,
  'slow_rider': SkiColors.mint,
  'best_rider': SkiColors.pink,
};
const _catCaption = {'fast_rider': '속도', 'slow_rider': '소요시간'};
const _catMeta = {
  'early_bird': ['얼리버드 라이더', '가장 먼저 슬로프를 내려온 라이더'],
  'fast_rider': ['패스트 라이더', '평균 속도가 가장 빠른 세션'],
  'slow_rider': ['슬로우 라이더', '한 슬로프를 가장 오래 내려온 라이더'],
  'best_rider': ['베스트 라이더', '개장일 하루 가장 많이 탄 라이더'],
};

List<String> _catSprite(String cat) {
  switch (cat) {
    case 'early_bird':
      return spSun;
    case 'fast_rider':
      return spLightning;
    case 'slow_rider':
      return spSnowflake;
    default:
      return spStar;
  }
}

Color _catIconColor(String cat) {
  switch (cat) {
    case 'fast_rider':
      return SkiColors.red;
    case 'slow_rider':
      return SkiColors.deepBlue;
    default:
      return SkiColors.orange; // 얼리버드(해)·베스트(별)
  }
}

int? _myUserId() => Get.isRegistered<UserViewModel>()
    ? Get.find<UserViewModel>().user.user_id
    : null;

/// 원형 프로필(night 2px 외곽선).
// 프로필 아바타는 다른 웹 화면과 동일한 공용 WebAvatar를 사용한다
// (테두리 없는 원형 + 기본 프로필 PNG fallback + Firebase CORS 대응 로딩).
Widget _avatar(String url, double size) => WebAvatar(url: url, size: size);

/// 기록 표시 — 숫자/영문은 픽셀 폰트, 한글 단위는 본문 폰트.
Widget _pixelMetric(String s, Color color) {
  final spans = <TextSpan>[];
  final buf = StringBuffer();
  bool? asciiRun;
  void flush() {
    if (buf.isEmpty) return;
    spans.add(TextSpan(
      text: buf.toString(),
      style: asciiRun!
          ? pxLabel(11, color)
          : SDSTextStyle.bold.copyWith(color: color, fontSize: 12),
    ));
    buf.clear();
  }

  for (final r in s.runes) {
    final c = String.fromCharCode(r);
    final isAscii = RegExp(r'[0-9A-Za-z:./ ]').hasMatch(c);
    if (asciiRun != null && asciiRun != isAscii) flush();
    asciiRun = isAscii;
    buf.write(c);
  }
  flush();
  return Text.rich(TextSpan(children: spans), maxLines: 1, overflow: TextOverflow.ellipsis);
}

/// 태그 3개를 한번에 복사.
void _copyOotdTags() {
  Clipboard.setData(ClipboardData(text: _ootdTags.join(' ')));
  Get.rawSnackbar(
    message: '태그를 복사했어요  ${_ootdTags.join(' ')}',
    duration: const Duration(seconds: 2),
    backgroundColor: SkiColors.night,
    margin: const EdgeInsets.all(12),
    borderRadius: 0,
    snackPosition: SnackPosition.BOTTOM,
  );
}

class PhoenixLandingWeb extends StatelessWidget {
  const PhoenixLandingWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.put(PhoenixViewModelWeb());
    return Container(
      color: SkiColors.snow,
      child: WebStickyFooterScroll(
        onRefresh: vm.load,
        padding: EdgeInsets.zero,
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kWebDesktopListMaxWidth),
            child: Obx(() {
              if (vm.isLoading.value) {
                return const SizedBox(
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: SkiColors.deepBlue),
                  ),
                );
              }
              return _Content(vm: vm);
            }),
          ),
        ),
        // 풋터 좌우 여백은 본문과 공통(16).
        footer: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kWebDesktopListMaxWidth),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: HomeFooterWeb(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final PhoenixViewModelWeb vm;
  const _Content({required this.vm});

  @override
  Widget build(BuildContext context) {
    final ev = vm.openingEvent;
    final isMobile = context.screenType == WebScreenType.mobile;
    const gap = SizedBox(height: 32);

    final sections = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ev != null) ...[
          _openingSection(context, ev),
          gap,
          _OpenBreadCard(ev: ev, onRefresh: vm.refreshQuietly),
          gap,
        ],
        const _OotdPanel(),
        gap,
        _timeline(),
        const SizedBox(height: 28),
      ],
    );

    // 모바일: 배너는 좌우·상단 여백 없이 꽉 채우고(홈 히어로처럼), 본문만 좌우 16.
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroBanner(ev: ev),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
            child: sections,
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_HeroBanner(ev: ev), gap, sections],
      ),
    );
  }

  /// 섹션 제목(도트 제목 폰트 26px).
  Widget _sectionTitle(String t) =>
      Text(t, style: pxTitle(26, SkiColors.night));

  Widget _openingSection(BuildContext context, Map<String, dynamic> ev) {
    final status = ev['status'];
    final announced =
        status == 'announced' || status == 'closed' || status == 'archived';
    final lb = ev['leaderboard'] as Map?;
    final winners = ev['winners'] as Map?;
    final isMobile = context.screenType == WebScreenType.mobile;
    final cross = isMobile ? 2 : (context.screenType == WebScreenType.tablet ? 2 : 4);

    final cards = _catMeta.keys.map((cat) {
      final live = lb?[cat] as Map?;
      final won = winners?[cat] as Map?;
      return _awardCard(context, cat, live: live, winner: won, announced: announced);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          _sectionTitle('개장빵 이벤트'),
          const SizedBox(width: 10),
          _statusBadge(status),
        ]),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 172,
          ),
          itemBuilder: (_, i) => cards[i],
        ),
      ],
    );
  }

  Widget _statusBadge(String? status) {
    final map = {
      'scheduled': ['예정', SkiColors.sky],
      'open': ['진행중', SkiColors.mint],
      'closed': ['집계중', SkiColors.sky],
      'announced': ['발표', SkiColors.yellow],
    };
    final m = map[status] ?? ['', SkiColors.sky];
    // 라운드 처리 + 크기 축소.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: m[1] as Color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SkiColors.night, width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 5, height: 5,
          decoration: const BoxDecoration(
              color: SkiColors.night, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(m[0] as String,
            style: SDSTextStyle.bold.copyWith(color: SkiColors.night, fontSize: 11)),
      ]),
    );
  }

  Widget _awardCard(BuildContext context, String cat,
      {Map? live, Map? winner, required bool announced}) {
    final meta = _catMeta[cat]!;
    final fill = _catFill[cat]!;
    final caption = _catCaption[cat];
    final data = announced ? winner : live;
    final name = data?['display_name'];
    final metric = (data?['metric_label'] ?? '').toString();
    final slope = (data?['slope_label'] ?? '').toString();
    final profile = (data?['profile_image_url'] ?? '').toString();
    final winnerId = winner?['winner_id'];
    final isMine = winner != null && winner['user_id'] == _myUserId();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: skiBox(fill: fill, shadow: SkiColors.night),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 윗줄: 제목(아이콘 타일 제거).
          Text(meta[0], maxLines: 1, overflow: TextOverflow.ellipsis,
              style: pxTitle(17, SkiColors.night)),
          if (name != null) ...[
            // 가운뎃줄: 정사각 프사 + 큰 닉네임 — 세로 가운데 정렬.
            Expanded(
              child: Center(
                child: Row(children: [
                  _avatar(profile, 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: pxTitle(20, SkiColors.night)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            const SkiDashedLine(),
            const SizedBox(height: 8),
            // 아랫줄: 슬로프(왼) · 기록(오른).
            Row(children: [
              Expanded(
                child: slope.isEmpty
                    ? const SizedBox.shrink()
                    : Text(slope, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.bold.copyWith(
                            color: SkiColors.night, fontSize: 12)),
              ),
              if (metric.isNotEmpty) ...[
                const SizedBox(width: 6),
                if (caption != null) ...[
                  Text(caption,
                      style: SDSTextStyle.bold.copyWith(
                          color: SkiColors.night, fontSize: 12)),
                  const SizedBox(width: 4),
                ],
                _pixelMetric(metric, SkiColors.night),
              ],
            ]),
          ] else ...[
            const Spacer(),
            Text(announced ? '수상자 없음' : '아직 기록 없음',
                style: SDSTextStyle.bold.copyWith(color: SkiColors.night, fontSize: 13)),
            const Spacer(),
          ],
          if (isMine && winnerId != null) ...[
            const SizedBox(height: 10),
            _SkiButton(
              label: '상품 받기',
              full: true,
              onTap: () => Get.toNamed('${WebRoutes.phoenixClaim}?winner=$winnerId'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeline() {
    Widget colabCard({
      required Widget leading,
      required Widget title,
      required String sub,
    }) =>
        Container(
          padding: const EdgeInsets.all(14),
          // 옅은 딤(반투명 흰색) + 옅은 외곽선 — 뒤 배경은 은은히 비치되 글자 가독성 확보.
          decoration: BoxDecoration(
            color: SkiColors.snow.withOpacity(0.45),
            border: Border.all(
                color: SkiColors.night.withOpacity(0.3), width: 1.5),
          ),
          child: Row(children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 4),
                  Text(sub,
                      style: SDSTextStyle.bold.copyWith(
                          color: SkiColors.night, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: skiBox(fill: SkiColors.sky),
              child: Column(children: [
                Text('COMING', style: pxLabel(11, SkiColors.night)),
                const SizedBox(height: 3),
                Text('SOON', style: pxLabel(11, SkiColors.night)),
              ]),
            ),
          ]),
        );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('시즌 내내 이어지는 이벤트', style: pxTitle(26, SkiColors.night)),
        const SizedBox(height: 6),
        Text('휘닉스파크와 스노우라이브가 시즌 시작부터 끝까지 함께합니다.',
            style: SDSTextStyle.regular.copyWith(color: SkiColors.deepBlue, fontSize: 14)),
        const SizedBox(height: 14),
        // 1) 크리스마스 눈송이 상점 — 좌측 눈송이상점 이미지, 제목에 크리스마스 트리.
        colabCard(
          leading: Image.asset(
              'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
              width: 44, height: 44, fit: BoxFit.contain,
              filterQuality: FilterQuality.medium),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('크리스마스', style: pxTitle(20, SkiColors.night)),
                const SizedBox(width: 6),
                const PixelSprite(spXmasTree, scale: 2),
              ]),
              Text('눈송이 상점 이벤트', style: pxTitle(20, SkiColors.night)),
            ],
          ),
          sub: '12월, 눈송이 상점과 함께하는 특별 이벤트',
        ),
        const SizedBox(height: 14),
        // 2) 시즌말 휘닉스 어워즈 — 트로피.
        colabCard(
          leading: const PixelSprite(spTrophy, scale: 4),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('시즌말', style: pxTitle(20, SkiColors.night)),
              Text('휘닉스 어워즈', style: pxTitle(20, SkiColors.night)),
            ],
          ),
          sub: '시즌 종합점수 크루 시상식',
        ),
        const SizedBox(height: 14),
      ],
    );

    // 배경 = 투명 PNG 눈송이 상점 이미지. 페이드 없이 투명도 0.5로만 은은하게.
    return ClipRect(
      child: Stack(children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/imgs/imgs/snowballShop/img_colab_phoenix_bg.png',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.all(16), child: content),
      ]),
    );
  }
}

// ── 상단 배너(캐러셀) ──
class _HeroBanner extends StatefulWidget {
  final Map<String, dynamic>? ev;
  const _HeroBanner({required this.ev});

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  final PageController _pc = PageController();
  int _index = 0;
  Timer? _timer;
  static const int _slides = 2;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pc.hasClients) return;
      _pc.animateToPage((_index + 1) % _slides,
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Stack(children: [
      Positioned.fill(
        child: PageView(
          controller: _pc,
          onPageChanged: (i) => setState(() => _index = i),
          children: [_eventSlide(), _ootdSlide()],
        ),
      ),
      // 캐러셀 점(8px 정사각).
      Positioned(
        left: 0, right: 0, bottom: 10,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < _slides; i++)
            Container(
              width: 8, height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: skiBox(fill: i == _index ? SkiColors.night : SkiColors.ice),
            ),
        ]),
      ),
    ]);

    return RepaintBoundary(
      child: Container(
        height: 330,
        decoration: const BoxDecoration(
          color: SkiColors.sky,
          border: Border(bottom: BorderSide(color: SkiColors.night, width: 4)),
        ),
        clipBehavior: Clip.hardEdge,
        child: content,
      ),
    );
  }

  Widget _snowBase() {
    // 하단 설산 + 장식 스프라이트.
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(children: [
          // 설산(폭 꽉 채움).
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: LayoutBuilder(builder: (_, c) {
              final scale = c.maxWidth / 39.0;
              return PixelSprite(spSnowMountain, scale: scale);
            }),
          ),
          // 왼쪽 아래 나무 2그루.
          const Positioned(bottom: 10, left: 16, child: PixelSprite(spTree, scale: 5)),
          const Positioned(bottom: 8, left: 70, child: PixelSprite(spTree, scale: 4)),
          // 깃발.
          const Positioned(bottom: 10, right: 150, child: PixelSprite(spFlagRed, scale: 4)),
          const Positioned(bottom: 10, right: 120, child: PixelSprite(spFlagBlue, scale: 4)),
          // 오른쪽 끝 나무.
          const Positioned(bottom: 10, right: 20, child: PixelSprite(spTree, scale: 5)),
          // 해, 구름.
          const Positioned(top: 16, right: 24, child: PixelSprite(spSun, scale: 5)),
          const Positioned(top: 30, right: 180, child: PixelSprite(spCloud, scale: 6)),
          const Positioned(top: 90, right: 90, child: PixelSprite(spCloud, scale: 4)),
        ]),
      ),
    );
  }

  Widget _eventSlide() {
    final ev = widget.ev;
    final title = ev?['title'] ?? '휘팍 개장빵 이벤트';
    final subtitle = ev?['subtitle'] ?? '스라X휘팍 26/27시즌 개장빵 이벤트!';
    return Stack(children: [
      _snowBase(),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('26/27 SEASON', style: pxLabel(11, SkiColors.deepBlue)),
            const SizedBox(height: 8),
            Text(title, style: pxTitle(36, SkiColors.night)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: SDSTextStyle.regular.copyWith(
                    color: SkiColors.deepBlue, fontSize: 14)),
            const SizedBox(height: 8),
            Text('휘닉스파크에서 라이브온하고 타면 자동 참여',
                style: SDSTextStyle.bold.copyWith(color: SkiColors.night, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: skiBox(fill: SkiColors.yellow, shadow: SkiColors.orange),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const PixelSprite(spFlagRed, scale: 2),
                const SizedBox(width: 8),
                Text('2026.11.20 OPEN', style: pxLabel(11, SkiColors.night)),
              ]),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _ootdSlide() {
    // SNS 느낌 — 인스타그램 도트 아이콘 + 태그 + 복사 버튼.
    return Stack(children: [
      const Positioned(right: 24, top: 36, child: PixelSprite(spInstagram, scale: 7)),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SNS OOTD', style: pxLabel(11, SkiColors.deepBlue)),
            const SizedBox(height: 8),
            Text('베스트 드레서', style: pxTitle(28, SkiColors.night)),
            const SizedBox(height: 6),
            Text('스키장 OOTD를 인스타에 올리고 태그하세요.\n가장 많은 좋아요를 받으면 숙박권 1매 증정!',
                style: SDSTextStyle.bold.copyWith(
                    color: SkiColors.night, fontSize: 13, height: 1.4)),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final t in _ootdTags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: skiBox(fill: SkiColors.deepBlue, border: SkiColors.ice),
                  child: Text(t,
                      style: SDSTextStyle.bold.copyWith(
                          color: SkiColors.snow, fontSize: 12)),
                ),
            ]),
            const SizedBox(height: 10),
            _SkiButton(
              label: '태그 복사',
              fill: SkiColors.yellow,
              shadow: SkiColors.orange,
              onTap: _copyOotdTags,
            ),
          ],
        ),
      ),
    ]);
  }
}

/// 아이콘 타일 — 28px 정사각 snow 타일 + 스프라이트. 탭하면 설명 말풍선(꼬리).
class _IconInfoTile extends StatefulWidget {
  final List<String> sprite;
  final Color mono;
  final String message;
  const _IconInfoTile({required this.sprite, required this.mono, required this.message});

  @override
  State<_IconInfoTile> createState() => _IconInfoTileState();
}

class _IconInfoTileState extends State<_IconInfoTile> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  void _toggle() => _entry == null ? _show() : _hide();
  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  void _show() {
    final overlay = Overlay.of(context);
    _entry = OverlayEntry(
      builder: (_) => Stack(children: [
        Positioned.fill(
          child: GestureDetector(
              behavior: HitTestBehavior.translucent, onTap: _hide),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -4),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: skiBox(fill: SkiColors.night, shadow: SkiColors.deepBlue),
                child: Text(widget.message,
                    style: SDSTextStyle.regular.copyWith(
                        color: SkiColors.snow, fontSize: 12, height: 1.4)),
              ),
            ),
            CustomPaint(size: const Size(14, 7), painter: _TailPainter()),
          ]),
        ),
      ]),
    );
    overlay.insert(_entry!);
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: skiBox(fill: SkiColors.snow),
          child: PixelSprite(widget.sprite, scale: 2, mono: widget.mono),
        ),
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = SkiColors.night
      ..isAntiAlias = false;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 도트 버튼 — 채움 + night 외곽선 + 단색 그림자. 누르면 그림자 없애고 4px 내림.
class _SkiButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool full;
  final Color fill;
  final Color shadow;
  final Color textColor;
  const _SkiButton({
    required this.label,
    required this.onTap,
    this.full = false,
    this.fill = SkiColors.yellow,
    this.shadow = SkiColors.orange,
    this.textColor = SkiColors.night,
  });

  @override
  State<_SkiButton> createState() => _SkiButtonState();
}

class _SkiButtonState extends State<_SkiButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      height: 44,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: skiBox(fill: widget.fill, shadow: _down ? null : widget.shadow),
      child: Text(widget.label, style: pxTitle(17, widget.textColor)),
    );
    final btn = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: Transform.translate(
          offset: _down ? const Offset(4, 4) : Offset.zero,
          child: body,
        ),
      ),
    );
    return widget.full ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// 새로고침(코인 타일 탭).
class _RefreshIconButton extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _RefreshIconButton({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onRefresh(),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: skiBox(fill: SkiColors.snow),
        child: const Icon(Icons.refresh, color: SkiColors.night, size: 20),
      ),
    );
  }
}

/// 개장빵 선착순 100명 — 코인 + 20칸 게이지 + 순위 목록 + 정렬/더보기.
class _OpenBreadCard extends StatefulWidget {
  final Map<String, dynamic> ev;
  final Future<void> Function() onRefresh;
  const _OpenBreadCard({required this.ev, required this.onRefresh});

  @override
  State<_OpenBreadCard> createState() => _OpenBreadCardState();
}

class _OpenBreadCardState extends State<_OpenBreadCard> {
  static const int _kPageSize = 10; // 한 페이지 10명.
  bool _recentFirst = true;
  final PageController _pageCtrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ev = widget.ev;
    final lb = ev['leaderboard'] as Map?;
    final winners = ev['winners'] as Map?;
    var list = ((winners?['open_bread'] ?? lb?['open_bread']) as List?) ?? const [];
    // [임시 데모] 등록자 60명 가정 — 실데이터가 적으면 더미로 채워 보여준다.
    if (_kDemo60 && list.length < 60) {
      list = List.generate(60, (i) {
        final n = i + 1;
        // 09:00부터 1분씩 증가 — 순위(등록순)와 시간이 어긋나지 않게.
        final total = 9 * 60 + i;
        final hh = (total ~/ 60).toString().padLeft(2, '0');
        final mi = (total % 60).toString().padLeft(2, '0');
        return {
          'rank': n,
          'display_name': '라이더${n.toString().padLeft(2, '0')}',
          'metric_label': '오전 $hh:$mi',
          'profile_image_url': '',
          'user_id': -n,
        };
      });
    }
    final count = list.length;

    dynamic myWinnerId;
    if (winners != null) {
      for (final w in (winners['open_bread'] as List? ?? const [])) {
        if (w['user_id'] == _myUserId()) myWinnerId = w['winner_id'];
      }
    }
    final ordered = _recentFirst ? list.reversed.toList() : list.toList();
    final filled = (count / 5).ceil().clamp(0, 20);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: skiBox(fill: SkiColors.white, shadow: SkiColors.night),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const PixelSprite(spCoin, scale: 3),
            const SizedBox(width: 10),
            Expanded(
              child: Text('개장빵 선착순 100명', style: pxTitle(20, SkiColors.night)),
            ),
            Text('$count/100', style: pxLabel(12, SkiColors.night)),
          ]),
          const SizedBox(height: 12),
          // 20칸 게이지.
          SizedBox(
            height: 14,
            child: Row(children: [
              for (int i = 0; i < 20; i++) ...[
                Expanded(
                  child: Container(
                    decoration: skiBox(
                      fill: i < filled ? SkiColors.mint : SkiColors.sky,
                      border: i < filled ? SkiColors.night : SkiColors.ice,
                    ),
                  ),
                ),
                if (i != 19) const SizedBox(width: 2),
              ],
            ]),
          ),
          if (myWinnerId != null) ...[
            const SizedBox(height: 12),
            _SkiButton(
              label: '개장빵 상품 받기',
              onTap: () => Get.toNamed('${WebRoutes.phoenixClaim}?winner=$myWinnerId'),
            ),
          ],
          if (count > 0) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() {
                  _recentFirst = !_recentFirst;
                  _page = 0;
                  if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
                }),
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: skiBox(fill: SkiColors.snow),
                  child: const SkiSortIcon(size: 18),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 10명씩 캐러셀(좌우 스와이프). 아래 점 인디케이터로 페이지 표시.
            _carousel(ordered),
          ],
        ],
      ),
    );
  }

  /// 10명씩 좌우 스와이프 캐러셀 + 점 인디케이터.
  Widget _carousel(List ordered) {
    final total = ordered.length;
    final pages = (total / _kPageSize).ceil();
    // 한 페이지(최대 10행) 높이 — 행당 약 46px.
    const pageHeight = _kPageSize * 46.0;
    final cur = _page.clamp(0, pages - 1);

    // 인스타그램식 점: 최대 5개까지만 창(window)으로 보여주고, 넘치는 끝은 작게 표시.
    const maxDots = 5;
    int start = 0, end = pages;
    if (pages > maxDots) {
      start = (cur - 2).clamp(0, pages - maxDots);
      end = start + maxDots;
    }

    return Column(
      children: [
        SizedBox(
          height: pageHeight,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: pages,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (_, p) {
              final s = p * _kPageSize;
              final e = (s + _kPageSize).clamp(0, total);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = s; i < e; i++) _rankRow(ordered[i], i),
                ],
              );
            },
          ),
        ),
        if (pages > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int p = start; p < end; p++)
                _dot(
                  p,
                  cur,
                  // 창 끝에 더 많은 페이지가 숨어 있으면 끝 점을 작게(줄임표시).
                  small: pages > maxDots &&
                      ((p == start && start > 0) || (p == end - 1 && end < pages)),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _dot(int p, int cur, {bool small = false}) {
    final active = p == cur;
    // 선택된 점은 색만 진하게 — 크기는 늘리지 않는다.
    final double w = small ? 5 : 8;
    final double h = small ? 5 : 8;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _page = p);
        _pageCtrl.animateToPage(p,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: active ? SkiColors.night : SkiColors.ice,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _rankRow(Map e, int idx) {
    final rank = e['rank'];
    final name = (e['display_name'] ?? '').toString();
    final metric = (e['metric_label'] ?? '').toString();
    final profile = (e['profile_image_url'] ?? '').toString();
    // 내 아이디가 리스트에 있을 때 내 줄만 노란 하이라이트.
    final mine = e['user_id'] != null && e['user_id'] == _myUserId();
    return Column(children: [
      const SkiDashedLine(color: SkiColors.ice),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration:
            mine ? skiBox(fill: SkiColors.yellow) : const BoxDecoration(),
        child: Row(children: [
          SizedBox(
            width: 34,
            child: Text('$rank', style: pxLabel(12, SkiColors.deepBlue)),
          ),
          _avatar(profile, 29),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.bold.copyWith(color: SkiColors.night, fontSize: 15)),
          ),
          _pixelMetric(metric, SkiColors.deepBlue),
        ]),
      ),
    ]);
  }
}

/// SNS OOTD 이벤트 — 유일한 어두운(night) 패널.
class _OotdPanel extends StatelessWidget {
  const _OotdPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: skiBox(fill: SkiColors.night, shadow: SkiColors.pink),
      child: Stack(children: [
        const Positioned(top: 0, right: 0, child: PixelSprite(spHeart, scale: 4)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SNS OOTD', style: pxLabel(11, SkiColors.yellow)),
            const SizedBox(height: 8),
            Text('베스트 드레서', style: pxTitle(26, SkiColors.snow)),
            const SizedBox(height: 8),
            Text('스키장 OOTD를 인스타에 올리고 태그하세요.\n좋아요를 가장 많이 받으신 분께 숙박권 1매 증정!',
                style: SDSTextStyle.regular.copyWith(
                    color: SkiColors.sky, fontSize: 14, height: 1.5)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in _ootdTags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: skiBox(fill: SkiColors.deepBlue, border: SkiColors.ice),
                  child: Text(t,
                      style: SDSTextStyle.bold.copyWith(color: SkiColors.snow, fontSize: 13)),
                ),
            ]),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: _SkiButton(
                label: '태그 복사',
                fill: SkiColors.yellow,
                shadow: SkiColors.orange,
                onTap: _copyOotdTags,
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

/// 하단 장식 — sky 띠 + 계단식 눈밭 + 나무/깃발.
class _BottomDecoration extends StatelessWidget {
  const _BottomDecoration();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(top: 28),
        decoration: const BoxDecoration(
          color: SkiColors.sky,
          border: Border(top: BorderSide(color: SkiColors.night, width: 4)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(children: const [
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: SizedBox(height: 56, child: ColoredBox(color: SkiColors.snow)),
          ),
          Positioned(bottom: 20, left: 24, child: PixelSprite(spTree, scale: 5)),
          Positioned(bottom: 18, left: 86, child: PixelSprite(spTree, scale: 4)),
          Positioned(bottom: 20, right: 70, child: PixelSprite(spFlagRed, scale: 4)),
          Positioned(bottom: 20, right: 40, child: PixelSprite(spFlagBlue, scale: 4)),
        ]),
      ),
    );
  }
}
