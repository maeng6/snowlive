import 'dart:async';
import 'dart:math' as math;

import 'package:com.snowlive/core/api/api_phoenix.dart'
    show kPhoenixClaimDemo, kDemoClaimedWinnerIds;
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart' show RankingUser;
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/ranking/w_ranking_profile_modal_web.dart'
    show showRankingProfileModal;
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/campaign/ski_slope_actors_web.dart';
import 'package:com.snowlive/web/view/campaign/ski_slope_scene_web.dart';
import 'package:com.snowlive/web/view/campaign/ski_theme.dart';
import 'package:com.snowlive/web/view/home/w_home_sections_web.dart' show HomeFooterWeb;
import 'package:com.snowlive/web/view/onboarding/w_onboarding_complete_modal_web.dart'
    show openAppStoreForCurrentPlatform;
import 'package:com.snowlive/web/viewmodel/campaign/vm_phoenix_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_sticky_footer_scroll_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// 아케이드 섹션 한글 폰트 — Do Hyeon. (영문·숫자는 pxLabel=Press Start 2P 유지)
TextStyle _kr(double size, Color color, {double height = 1.2, bool bold = false}) =>
    GoogleFonts.doHyeon(fontSize: size, color: color, height: height);

/// 휘팍 개장빵 이벤트 랜딩 — 스키장 도트(픽셀아트) 테마.
/// 색/형태/스프라이트는 SNOWLIVE_EVENT_UI_GUIDE.md를 따른다(상단 헤더·채팅버튼 제외).

const _ootdTags = ['@phoenixhnr', '@snowlive', '#휘팍OOTD'];

// [임시] 개장빵 선착순 60명 등록 상태를 더미로 보여주기 위한 데모 플래그.
const bool _kDemo60 = true;

// 기록 보조어 — 슬로우만 '소요시간'. (얼리버드/베스트는 metric 문자열에 포함)
const _catCaption = {'slow_rider': '소요시간'};
// 시상 카테고리. 이 맵의 키 순서가 그대로 카드 순서가 된다.
//
// '패스트 라이더'(평균 속도 1위)는 **의도적으로 뺐다** — 슬로프에서 속도 경쟁을
// 부추기는 항목이라 위험하다는 판단. 서버는 여전히 fast_rider를 내려줄 수 있지만
// 화면에는 올리지 않는다. 다시 넣자는 얘기가 나오면 이 사유부터 확인할 것.
const _catMeta = {
  'early_bird': ['얼리버드 라이더', '가장 먼저 라이딩'],
  'slow_rider': ['슬로우 라이더', '한 슬로프를 가장 오래 라이딩'],
  'best_rider': ['베스트 라이더', '가장 많이 라이딩'],
};

// ── 아케이드 픽셀아트 디자인 토큰 (개장빵 라이더 섹션) ──
const _ink = Color(0xFF1B2A4A);
const _inkSub = Color(0xFF56627F);
const _cardBg = Color(0xFFF7FAFF);
const _cardShadow = Color(0xFF9DB7DE);
const _dividerCol = Color(0xFFC5D5EC);
const _brandBlue = Color(0xFF1F5FBF);
// 스키장 카드 테두리/포인트 색 — 빨강→노랑→초록→파랑 순차 순환.
const _cardAccents = <Color>[
  Color(0xFFE4564E), // 빨강
  Color(0xFFE0A100), // 노랑(가독 위해 살짝 진한 톤)
  Color(0xFF2E9E63), // 초록
  _brandBlue,        // 파랑
];
const _btnBg = Color(0xFF2F6BE0);
const _titleShadow = Color(0xFFFFFFFF); // 흰색 하드 섀도

/// 카드별 스타일 — 테두리/아이콘/링 색, 영문 라벨색, 기록 숫자 섀도색,
/// 영문 라벨, 8×8 픽셀 아이콘.
class _CardStyle {
  final Color accent;
  final Color label;
  final Color numShadow;
  final String en;
  final List<List<int>> icon;
  const _CardStyle(this.accent, this.label, this.numShadow, this.en, this.icon);
}

const _sun = [
  [3, 0, 2, 1], [1, 1, 1, 1], [6, 1, 1, 1], [2, 2, 4, 4], [0, 3, 1, 2],
  [7, 3, 1, 2], [1, 6, 1, 1], [6, 6, 1, 1], [3, 7, 2, 1],
];
const _hourglass = [
  [1, 0, 6, 1], [2, 1, 4, 1], [3, 2, 2, 4], [2, 6, 4, 1], [1, 7, 6, 1],
];
const _crown = [
  [0, 1, 1, 2], [7, 1, 1, 2], [3, 1, 2, 2], [1, 2, 1, 1], [6, 2, 1, 1],
  [0, 3, 8, 3], [0, 7, 8, 1],
];

const _cardStyles = {
  'early_bird': _CardStyle(Color(0xFFE0554E), Color(0xFFB8302A),
      Color(0xFFF3A9A5), 'EARLY BIRD', _sun),
  'slow_rider': _CardStyle(Color(0xFFF2B632), Color(0xFF7A5200),
      Color(0xFFF7D98A), 'SLOW RIDER', _hourglass),
  'best_rider': _CardStyle(Color(0xFF3FAE7A), Color(0xFF1A6B45),
      Color(0xFFA5E0C4), 'BEST RIDER', _crown),
};

// 본문/보조 글자, 타일 배경.
const _bodyText = Color(0xFF3D4B6B);
const _tileBlue = Color(0xFFDCE9F8);
const _tileGold = Color(0xFFFFF3D1);

// 시즌 이벤트 아이콘(8×8).
const _snowflake = [
  [3, 0, 2, 8], [0, 3, 8, 2], [1, 1, 1, 1], [6, 1, 1, 1], [1, 6, 1, 1],
  [6, 6, 1, 1],
];
const _trophy = [
  [1, 0, 6, 1], [0, 1, 8, 2], [2, 3, 4, 1], [3, 4, 2, 2], [2, 6, 4, 1],
  [1, 7, 6, 1],
];

// OOTD 베스트 드레서 카드 전용.
const _ootdBg = Color(0xFFFFF4F7);
const _ootdBorder = Color(0xFFE05A8A);
const _ootdLabel = Color(0xFFA82D5C);
const _ootdTitleShadow = Color(0xFFF5B8CD);
const _ootdDivider = Color(0xFFF0C3D3);
const _heartColor = Color(0xFFE0554E);
// 8×8 인스타그램 글리프 — 둥근 네모 테두리 + 중앙 렌즈(다이아 원) + 우상단 점.
const _instagram = [
  [1, 0, 6, 1], [0, 1, 1, 6], [7, 1, 1, 6], [1, 7, 6, 1], // 둥근 네모 테두리
  [5, 1, 1, 1],                                            // 플래시 점
  [3, 2, 2, 1], [2, 3, 1, 1], [5, 3, 1, 1],                // 렌즈 위/어깨
  [2, 4, 1, 1], [5, 4, 1, 1], [3, 5, 2, 1],                // 렌즈 옆/아래
];
const _heart = [
  [1, 0, 2, 1], [5, 0, 2, 1], [0, 1, 8, 3], [1, 4, 6, 1], [2, 5, 4, 1],
  [3, 6, 2, 1],
];
const _heartShine = [
  [1, 1, 1, 1],
];

/// 가로 꽉 찬 픽셀 버튼 — 7.4 / 8.5 공용. 파인 테두리 3 ink + 섀도 (3,7).
Widget _widePixelButton({
  required String label,
  required VoidCallback onTap,
  double height = 48,
  double fontSize = 18,
  Color fill = _btnBg,
  Color textColor = const Color(0xFFFFFFFF),
}) =>
    Padding(
      padding: const EdgeInsets.only(left: 3, top: 3, right: 3, bottom: 7),
      child: Semantics(
        button: true,
        label: label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: CustomPaint(
              painter: const _PixelFrame(
                  border: _ink,
                  shadow: _cardShadow,
                  t: 3,
                  shadowOffset: Offset(3, 7)),
              child: ColoredBox(
                color: fill,
                child: SizedBox(
                  height: height,
                  width: double.infinity,
                  child: Center(
                    child: Text(label, style: _kr(fontSize, textColor)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

/// 32×32 픽셀 하트(하이라이트 1칸).
Widget _pixelHeart() => SizedBox(
      width: 32,
      height: 32,
      child: Stack(children: const [
        Positioned.fill(
            child: CustomPaint(painter: _PixelIcon(_heart, _heartColor))),
        Positioned.fill(
            child: CustomPaint(
                painter: _PixelIcon(_heartShine, Color(0xFFFFFFFF)))),
      ]),
    );

/// 28×28 픽셀 인스타그램 아이콘(OOTD 분홍 테마).
Widget _pixelInstagram() => const SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(painter: _PixelIcon(_instagram, _ootdBorder)),
    );

/// 라이더 설명용 **동그라미 i 버튼** — 누르면 픽셀 말풍선(꼬리가 버튼을 향함).
class _RiderInfoButton extends StatefulWidget {
  final String message;
  final Color accent;
  const _RiderInfoButton({required this.message, required this.accent});
  @override
  State<_RiderInfoButton> createState() => _RiderInfoButtonState();
}

class _RiderInfoButtonState extends State<_RiderInfoButton> {
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
          offset: const Offset(0, -2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 픽셀 말풍선 — 파인 모서리 테두리(섀도 없음) + 흰 바탕.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: CustomPaint(
                  painter: const _PixelFrame(
                      border: _ink, shadow: Color(0x00000000), t: 3),
                  child: ColoredBox(
                    color: const Color(0xFFFFFFFF),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Text(widget.message,
                          style: _kr(12, _ink).copyWith(height: 1.4)),
                    ),
                  ),
                ),
              ),
              // 꼬리 — i 버튼 쪽(아래)으로.
              const CustomPaint(size: Size(14, 8), painter: _BubbleTail()),
            ],
          ),
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggle,
          child: Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              shape: BoxShape.circle,
              border: Border.all(color: widget.accent, width: 1.5),
            ),
            child: Text('i',
                style: _kr(9, widget.accent).copyWith(height: 1.0)),
          ),
        ),
      ),
    );
  }
}

/// 말풍선 꼬리 — 흰 삼각형 + ink 테두리, 아래를 향한다(픽셀, AA 없음).
class _BubbleTail extends CustomPainter {
  const _BubbleTail();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final ink = Paint()
      ..color = _ink
      ..isAntiAlias = false;
    final white = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..isAntiAlias = false;
    canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..lineTo(w, 0)
          ..lineTo(w / 2, h)
          ..close(),
        ink);
    canvas.drawPath(
        Path()
          ..moveTo(3, 0)
          ..lineTo(w - 3, 0)
          ..lineTo(w / 2, h - 4)
          ..close(),
        white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 숙박권 티켓(애니메이션) — 광택이 주기적으로 스윽 지나가고 별이 반짝인다.
class _PrizeTicket extends StatefulWidget {
  const _PrizeTicket();
  @override
  State<_PrizeTicket> createState() => _PrizeTicketState();
}

class _PrizeTicketState extends State<_PrizeTicket>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  // 카드마다 제각각 지나가게 랜덤 위상.
  final double _phase = math.Random().nextDouble();
  @override
  void initState() {
    super.initState();
    // 5초에 한 번 광택이 지나간다.
    _c = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 접근성 '애니메이션 줄이기'면 정적.
    final Animation<double> anim = MediaQuery.disableAnimationsOf(context)
        ? const AlwaysStoppedAnimation<double>(0.08)
        : _c;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _TicketPainter(anim, _phase),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 6, 11, 6),
          child: Text('올리브영\n5,000원',
              textAlign: TextAlign.center,
              style: _kr(11, _ink).copyWith(height: 1.25)),
        ),
      ),
    );
  }
}

/// 금속 금색 티켓 + 흐르는 광택 + 반짝이는 별. [t](0~1)로 애니메이션, [phase] 오프셋.
class _TicketPainter extends CustomPainter {
  final Animation<double> t;
  final double phase;
  const _TicketPainter(this.t, this.phase) : super(repaint: t);

  double _tri(double x) {
    final p = x % 1.0;
    return p < 0.5 ? p * 2 : (1 - p) * 2; // 0→1→0 삼각파
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()..isAntiAlias = false;
    const border = _ink, hole = _cardBg;
    // 테두리(2px).
    p.color = border;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), p);
    // 금속 금색 밴드(상단 밝음 → 바닥 어두움).
    final iw = w - 4, ih = h - 4;
    final inner = Rect.fromLTWH(2, 2, iw, ih);
    // 금색 채우기는 아래에서.
    p.color = const Color(0xFFB07D12);
    canvas.drawRect(inner, p);
    p.color = const Color(0xFFE3B437);
    canvas.drawRect(Rect.fromLTWH(2, 2, iw, ih * 0.70), p);
    p.color = const Color(0xFFF7DE84);
    canvas.drawRect(Rect.fromLTWH(2, 2, iw, ih * 0.34), p);

    // 카드마다 다른 위상으로 — 세 개가 제각각 지나간다.
    final v = (t.value + phase) % 1.0;
    // 흐르는 광택 — 5초 주기 중 앞 20%(약 1초)에만 왼→오로 스윽 지나간다.
    if (v < 0.2) {
      final s = v / 0.2; // 0~1 빠른 스윕
      canvas.save();
      canvas.clipRect(inner);
      final sweep = -14 + (w + 28) * s;
      void diag(double bx, int len, double thick, Color c) {
        p.color = c;
        for (int k = 0; k < len; k++) {
          canvas.drawRect(Rect.fromLTWH(bx + k, (h - 5) - k, thick, thick), p);
        }
      }

      final glintLen = (h - 6).round();
      // 광택 띠는 옅게(약 25% 불투명).
      diag(sweep, glintLen, 2, const Color.fromRGBO(255, 244, 206, 0.25));
      diag(sweep + 5, glintLen, 1.5, const Color.fromRGBO(255, 251, 236, 0.28));
      canvas.restore();
    }

    // 반짝이는 별 — 위상 다르게 깜빡.
    void star(double cx, double cy, double a, double ph) {
      final b = _tri(v + ph);
      if (b < 0.15) return;
      p.color = Color.fromRGBO(255, 255, 255, 0.25 + 0.75 * b);
      canvas.drawRect(Rect.fromLTWH(cx, cy - a, 1, a * 2 + 1), p);
      canvas.drawRect(Rect.fromLTWH(cx - a, cy, a * 2 + 1, 1), p);
    }

    star(w - 9, 7, 3, 0.0);
    star(7, h - 8, 1.5, 0.5);

    // 양옆 가운데 반원 노치(카드색으로 파냄 + ink 테두리).
    const r = 4.0;
    p.color = border;
    canvas.drawCircle(Offset(0, h / 2), r, p);
    canvas.drawCircle(Offset(w, h / 2), r, p);
    p.color = hole;
    canvas.drawCircle(Offset(0, h / 2), r - 2, p);
    canvas.drawCircle(Offset(w, h / 2), r - 2, p);
  }

  @override
  bool shouldRepaint(_TicketPainter old) => false;
}

/// 픽셀 프레임 — 모서리가 한 칸 파인 테두리 + 오른쪽 아래 하드 섀도(blur 0).
/// 본체(child) 영역 **밖**으로 그려지므로 호출부가 그만큼 여백을 둔다.
class _PixelFrame extends CustomPainter {
  final Color border;
  final Color shadow;
  final double t;
  final Offset shadowOffset;
  const _PixelFrame({
    required this.border,
    required this.shadow,
    this.t = 4,
    this.shadowOffset = const Offset(6, 10),
  });
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()..isAntiAlias = false;
    p.color = shadow;
    canvas.drawRect(Rect.fromLTWH(shadowOffset.dx, shadowOffset.dy, w, h), p);
    p.color = border;
    canvas.drawRect(Rect.fromLTWH(0, -t, w, t), p); // 위
    canvas.drawRect(Rect.fromLTWH(0, h, w, t), p); // 아래
    canvas.drawRect(Rect.fromLTWH(-t, 0, t, h), p); // 왼쪽
    canvas.drawRect(Rect.fromLTWH(w, 0, t, h), p); // 오른쪽
  }

  @override
  bool shouldRepaint(_PixelFrame old) =>
      old.border != border ||
      old.shadow != shadow ||
      old.t != t ||
      old.shadowOffset != shadowOffset;
}

/// 픽셀 점선 구분선 — 4px 칸 / 4px 빈칸 반복(주기 8), 높이 4.
class _PixelDivider extends CustomPainter {
  final Color color;
  const _PixelDivider(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..isAntiAlias = false
      ..color = color;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 4, 4), p);
    }
  }

  @override
  bool shouldRepaint(_PixelDivider old) => old.color != color;
}

/// 픽셀 아이콘(한 칸 = size.width/[grid]). 기본 8×8.
class _PixelIcon extends CustomPainter {
  final List<List<int>> cells;
  final Color color;
  final int grid;
  const _PixelIcon(this.cells, this.color, {this.grid = 8});
  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / grid;
    final p = Paint()
      ..isAntiAlias = false
      ..color = color;
    for (final c in cells) {
      canvas.drawRect(Rect.fromLTWH(c[0] * u, c[1] * u, c[2] * u, c[3] * u), p);
    }
  }

  @override
  bool shouldRepaint(_PixelIcon old) =>
      old.color != color || old.grid != grid || !identical(old.cells, cells);
}

// ── 선착순 50명 카드(§7) 토큰 ──
const _barFill = Color(0xFF2F6BE0);
const _countShadow = Color(0xFFA9C4F5);
const _listRing = Color(0xFFC5D5EC);
const _coinOutline = [[2, 0, 4, 1], [1, 1, 6, 1], [0, 2, 8, 4], [1, 6, 6, 1], [2, 7, 4, 1]];
const _coinFill = [[2, 1, 4, 1], [1, 2, 6, 4], [2, 6, 4, 1]];
const _coinMark = [[4, 2, 1, 4]];
const _coinShine = [[2, 2, 1, 2]];
// 6×8 그리드(위/아래 화살표).
const _sortArrows = [[2, 0, 2, 1], [1, 1, 4, 1], [0, 2, 6, 1], [0, 5, 6, 1], [1, 6, 4, 1], [2, 7, 2, 1]];

/// 32×32 픽셀 코인(외곽선→금색→홈→하이라이트).
Widget _pixelCoin() => SizedBox(
      width: 32,
      height: 32,
      child: Stack(children: const [
        Positioned.fill(child: CustomPaint(painter: _PixelIcon(_coinOutline, _ink))),
        Positioned.fill(child: CustomPaint(painter: _PixelIcon(_coinFill, Color(0xFFF2B632)))),
        Positioned.fill(child: CustomPaint(painter: _PixelIcon(_coinMark, Color(0xFFB8860B)))),
        Positioned.fill(child: CustomPaint(painter: _PixelIcon(_coinShine, Color(0xFFFFF3D1)))),
      ]),
    );

/// 20칸 진행 바 — 틀 ink + 패딩 3, 채움 blue / 빈칸 연파랑.
class _ProgressBar extends CustomPainter {
  final int filled; // 0~20
  const _ProgressBar(this.filled);
  @override
  void paint(Canvas canvas, Size size) {
    const n = 20, gap = 3.0, pad = 3.0;
    final p = Paint()..isAntiAlias = false;
    p.color = _ink;
    canvas.drawRect(Offset.zero & size, p);
    final innerW = size.width - pad * 2;
    final innerH = size.height - pad * 2;
    final cellW = (innerW - gap * (n - 1)) / n;
    for (int i = 0; i < n; i++) {
      p.color = i < filled ? _barFill : _tileBlue;
      canvas.drawRect(
          Rect.fromLTWH(pad + i * (cellW + gap), pad, cellW, innerH), p);
    }
  }

  @override
  bool shouldRepaint(_ProgressBar old) => old.filled != filled;
}

/// 깜빡이는 ▶ — 1초 주기 계단식 on/off. ▶ 위젯만 리빌드하고 RepaintBoundary로
/// 감싼다. ▶(U+25B6)는 픽셀 폰트에 글리프가 없어 기본 폰트로 그린다.
class _BlinkCaret extends StatefulWidget {
  final Color color;
  final double size;
  const _BlinkCaret(this.color, this.size);
  @override
  State<_BlinkCaret> createState() => _BlinkCaretState();
}

class _BlinkCaretState extends State<_BlinkCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: widget.color, fontSize: widget.size, height: 1.0);
    // 접근성 '애니메이션 줄이기'면 깜빡임을 끄고 항상 보이게 둔다.
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text('▶', style: style);
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Text(
          '▶',
          style: _c.value < 0.5
              ? style
              : style.copyWith(color: Colors.transparent),
        ),
      ),
    );
  }
}

// 웹에서 user.user_id가 String으로 올 수 있어(UserViewModel.user는 dynamic) 정수로 정규화.
int? _asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}');

/// 당첨자 본인에게만 뜨는 '상품 받기' 버튼 노출 조건.
/// 카드(버튼을 그릴지)와 그리드(높이를 늘릴지)가 같은 판정을 써야 한다 —
/// 갈라지면 버튼은 뜨는데 높이가 그대로라 프사가 눌린다.
bool _canClaim(Map? winner) =>
    winner != null &&
    winner['winner_id'] != null &&
    // 수상거부/상품미지급 등수(백엔드 claimable==false, 예: 휘팍 1·2등)는 버튼 숨김.
    winner['claimable'] != false &&
    // QA 데모: 본인 여부 무시하고 버튼 노출(백엔드가 실제 신청은 본인만 허용).
    (kPhoenixClaimDemo || _asInt(winner['user_id']) == _myUserId());

int? _myUserId() {
  if (!Get.isRegistered<UserViewModel>()) return null;
  return _asInt(Get.find<UserViewModel>().user.user_id);
}

/// 원형 프로필(night 2px 외곽선).
// 프로필 아바타는 다른 웹 화면과 동일한 공용 WebAvatar를 사용한다
// (테두리 없는 원형 + 기본 프로필 PNG fallback + Firebase CORS 대응 로딩).
Widget _avatar(String url, double size) => WebAvatar(url: url, size: size);

/// 기록 표시 — 숫자/영문은 픽셀 폰트, 한글 단위는 본문 폰트.
/// 픽셀 숫자를 아래로 미는 양(논리 px). 글꼴 디센더 때문에 생기는 착시 보정.
const double _kPixelNumberDrop = 1.5;

Widget _pixelMetric(String s, Color color,
    {double asciiSize = 11, double hangulSize = 12, Shadow? shadow}) {
  final spans = <InlineSpan>[];
  final buf = StringBuffer();
  bool? asciiRun;
  final asciiStyle = shadow == null
      ? pxLabel(asciiSize, color)
      : pxLabel(asciiSize, color).copyWith(shadows: [shadow]);
  void flush() {
    if (buf.isEmpty) return;
    // 숫자는 Press Start 2P, 한글은 Pretendard라 한 문단에 두 글꼴이 섞인다.
    // 베이스라인만 맞추면 픽셀 글꼴이 베이스라인 위로 훨씬 높이 올라가 한글이
    // 아래로 처져 보인다. 픽셀 구간을 WidgetSpan으로 감싸 글줄 세로 중앙에 건다.
    spans.add(asciiRun!
        ? WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            // Press Start 2P는 디센더 자리가 커서 글자가 상자 위쪽에 몰린다.
            // 상자를 가운데 걸어도 글자만 떠 보이므로 레이아웃은 그대로 두고
            // 그리기만 아래로 민다(Padding을 쓰면 상자가 커져 다시 가운데가 밀린다).
            child: Transform.translate(
              offset: const Offset(0, _kPixelNumberDrop),
              child: Text(buf.toString(), style: asciiStyle),
            ),
          )
        : TextSpan(
            text: buf.toString(),
            style: _kr(hangulSize, color),
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
  // 루트 style과 strut을 못 박는다. WidgetSpan의 middle 정렬은 **그 문단의**
  // 글줄 높이를 기준으로 가운데를 잡는데, 카드마다 span 구성이 달라서
  // (한글+숫자 / 숫자만 / 숫자+한글) 기준 높이가 제각각이면 눈높이가 미세하게
  // 어긋난다. 한글 본문과 같은 값으로 고정해 세 카드가 같은 기준을 쓰게 한다.
  final base = SDSTextStyle.bold.copyWith(color: color, fontSize: hangulSize);
  return Text.rich(
    TextSpan(children: spans),
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.ellipsis,
    style: base,
    strutStyle: StrutStyle(
      fontFamily: 'Pretendard',
      fontSize: hangulSize,
      forceStrutHeight: true,
    ),
  );
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
    final isMobile = context.screenType == WebScreenType.mobile;
    // 설경 배경의 가로 폭(piste). 콘텐츠 폭(모바일은 화면 가득)에 맞춰 그린다.
    final double piste = isMobile ? 1340 : kWebSubPageMaxWidth;
    return Container(
      color: SnowScene.snow,
      child: WebStickyFooterScroll(
        onRefresh: vm.load,
        padding: EdgeInsets.zero,
        // 바디(배경 설경 포함)를 콘텐츠 폭에 맞춰 가운데 정렬한다 — 배경이 화면 끝까지
        // 퍼지지 않고 콘텐츠 영역만큼만 그려지고, 바깥은 SnowScene.snow 단색.
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kWebSubPageMaxWidth),
            child: Stack(children: [
          // 지형은 한 번 구운 비트맵, 라이더·리프트 의자만 매 프레임 움직인다.
          // pisteWidth는 두 레이어가 **같은 값**이어야 경로가 어긋나지 않는다.
          // 모바일은 화면이 좁아 양옆 숲이 제목까지 밀고 들어온다.
          // 제목 블록이 차지하는 세로 띠만 알려주고 그 안쪽 나무를 비운다.
          Positioned.fill(
            child: SkiSlopeBackground(
              pisteWidth: piste,
              clearTop: isMobile ? 60 : 0,
              clearBottom: isMobile ? 350 : 0,
            ),
          ),
          // 라이더는 **콘텐츠가 로드된 뒤에만** 띄운다. 첫 접속의 빈 화면에서
          // 라이더만 돌아다니는 어색함을 없앤다.
          Positioned.fill(
            child: Obx(() => vm.isLoading.value
                ? const SizedBox.shrink()
                // 하단 220px(풋터 쪽)엔 라이더·곤돌라가 내려오지 않게 한다.
                : SkiSlopeActors(pisteWidth: piste, bottomSafe: 220)),
          ),
          // 상단 중앙 — 산장(몽블랑 집) 대신 스노우라이브 앱아이콘. 저해상 디코드 후
          // nearest 업스케일로 픽셀아트 톤에 맞춘다(정사각).
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 16 : 22),
              child: Image.asset(
                'assets/imgs/logos/snowlive_pixel_logo_v4.png',
                width: isMobile ? 92 : 105,
                cacheWidth: 130,
                filterQuality: FilterQuality.none,
                isAntiAlias: false,
              ),
            ),
          ),
          Center(
          child: ConstrainedBox(
            // 콘텐츠 폭은 다른 서브페이지(커뮤니티 상세 등)와 동일하게 제한한다.
            // 배경 설경(SkiSlopeBackground)은 이 제한 바깥이라 PC에서도 풀블리드.
            constraints: const BoxConstraints(maxWidth: kWebSubPageMaxWidth),
            child: Obx(() {
              // 로그인 유저가 비동기로 늦게 로드돼도(새로고침 등) 상품받기 버튼이
              // 다시 그려지도록, _myUserId가 쓰는 UserViewModel Rx를 여기서 구독한다.
              if (Get.isRegistered<UserViewModel>()) {
                final uvm = Get.find<UserViewModel>();
                uvm.isLoading.value; // isLoading 구독
                uvm.user; // _user.value 구독
              }
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
        ]),
          ), // ConstrainedBox — 바디 폭 제한
        ), // Center
        // 풋터는 다른 페이지 공통 풋터와 동일 폭(1280)으로 둬 스토어 배지 정렬을 맞춘다.
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

/// OG·히어로 배너 **캡처 전용** 풀블리드 뷰 — 앱 네비/카드 없이 히어로 아트만.
/// (서버/디자인 배포 노출용 정적 이미지를 /#/phoenix-banner에서 스크린샷한다.)
class PhoenixBannerWeb extends StatelessWidget {
  const PhoenixBannerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PhoenixViewModelWeb()).load(); // 라이더 표시용 로드 트리거
    final isMobile = context.screenType == WebScreenType.mobile;
    return Container(
      color: SnowScene.snow,
      child: Stack(children: [
        Positioned.fill(
          child: SkiSlopeBackground(
            pisteWidth: 1340,
            clearTop: isMobile ? 60 : 0,
            clearBottom: 0,
          ),
        ),
        const Positioned.fill(
          child: SkiSlopeActors(pisteWidth: 1340, bottomSafe: 40),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: isMobile ? 16 : 22),
            child: Image.asset(
              'assets/imgs/logos/snowlive_pixel_logo_v4.png',
              width: isMobile ? 92 : 105,
              cacheWidth: 130,
              filterQuality: FilterQuality.none,
              isAntiAlias: false,
            ),
          ),
        ),
        const Align(
          alignment: Alignment.topCenter,
          child: _HeroTitle(ev: null),
        ),
      ]),
    );
  }
}

/// 앱 홈 배너(가로 띠, 360:86) **캡처 전용** — 로고·제목·상품을 한 줄로.
class PhoenixStripWeb extends StatelessWidget {
  const PhoenixStripWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SnowScene.snow,
      child: Stack(children: [
        const Positioned.fill(
          child: SkiSlopeBackground(pisteWidth: 1340, clearTop: 0, clearBottom: 0),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/imgs/logos/snowlive_pixel_logo_v4.png',
                  height: 118,
                  cacheWidth: 300,
                  filterQuality: FilterQuality.none,
                  isAntiAlias: false,
                ),
                const SizedBox(width: 30),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('26/27 SEASON OPEN',
                        style: pxLabel(9, _brandBlue, spacing: 1)),
                    const SizedBox(height: 9),
                    PixelOutlinedText(
                      '스라 개장빵 이벤트',
                      style: _kr(40, _ink),
                      outline: SnowScene.paper,
                      width: 40 / 11,
                      ring: SkiColors.night,
                      align: TextAlign.left,
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                // 상품 칩(올리브영 상품권 5,000원).
                CustomPaint(
                  painter: const _PixelFrame(
                      border: _ink,
                      shadow: _cardShadow,
                      t: 3,
                      shadowOffset: Offset(3, 5)),
                  child: ColoredBox(
                    color: _btnBg,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('올리브영 상품권',
                              style:
                                  _kr(13, const Color(0xFFFFFFFF), bold: true)),
                          const SizedBox(height: 2),
                          Text('5,000원',
                              style:
                                  _kr(16, const Color(0xFFFFD23F), bold: true)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _Content extends StatelessWidget {
  final PhoenixViewModelWeb vm;
  const _Content({required this.vm});

  @override
  Widget build(BuildContext context) {
    // 전국 스키장: 어드민에서 개장일 입력된 이벤트들(각 리조트 카드).
    final events = vm.events.toList();
    final ev = events.isNotEmpty ? events.first : null;
    final isMobile = context.screenType == WebScreenType.mobile;

    final sections = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _resortsSection(context, events),
        const SizedBox(height: 28),
      ],
    );

    // 모바일: 배너는 좌우·상단 여백 없이 꽉 채우고(홈 히어로처럼), 본문만 좌우 16.
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroTitle(ev: ev),
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
        children: [_HeroTitle(ev: ev), const SizedBox(height: 32), sections],
      ),
    );
  }

  /// 스키장별 개장빵 1~3등 — 어드민에서 개장일 입력한 리조트 카드만.
  Widget _resortsSection(BuildContext context, List<Map<String, dynamic>> events) {
    // 카드(헤더 포함)는 본문 폭의 약 2/3로 좁혀 가운데 정렬한다. 모바일은 화면이
    // 이 값보다 좁아 자동으로 꽉 차므로 영향 없다(데스크탑/태블릿만 제한).
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 512),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _arcadeHeader(context),
            const SizedBox(height: 11),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text('곧 개장하는 스키장이 열려요!',
                    textAlign: TextAlign.center, style: _kr(14, _inkSub)),
              )
            else
              for (int i = 0; i < events.length; i++) ...[
                if (i > 0) const SizedBox(height: 22),
                _resortCard(context, events[i], i),
              ],
          ],
        ),
      ),
    );
  }

  /// 아케이드 헤더 — `개장빵 라이더` + 공통 안내(i): 스키장별 가장 먼저 라이딩한 1~3등.
  Widget _arcadeHeader(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '개장빵 라이더',
              style: _kr(24, _ink, bold: true).copyWith(
                height: 1.2,
                letterSpacing: 1,
                shadows: const [
                  Shadow(color: Color(0xFFC6DEF6), offset: Offset(3, 3), blurRadius: 0),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const _RiderInfoButton(
                message: '스키장별 가장 먼저 라이딩한 1~3등', accent: _brandBlue),
          ],
        ),
      );

  /// 닉네임은 6자 넘으면 말줄임.
  String _clipName(String s) => s.length > 6 ? '${s.substring(0, 6)}…' : s;

  /// 리조트 1장 — 상단(영문/한글 스키장명 + 올리브영 티켓), 아래 1~3등 세로 리스트.
  /// 개장 전(라이더 없음)이면 '개장 전' 표시.
  Widget _resortCard(BuildContext context, Map<String, dynamic> ev, int idx) {
    // 카드마다 빨강→노랑→초록→파랑 순으로 테두리·포인트 색을 번갈아 준다.
    final accent = _cardAccents[idx % _cardAccents.length];
    final en = (ev['resort_name_en'] ?? '').toString();
    final ko = (ev['resort_name_ko'] ?? '').toString();
    final openDate = (ev['open_date_label'] ?? '').toString();
    var prelaunch = ev['is_prelaunch'] == true;
    var top3 = ((ev['top3'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    // QA 데모: 당첨자 없는 첫 카드에 더미 1~3등을 넣어 상품받기 버튼을 보여준다.
    if (kPhoenixClaimDemo && idx == 0 && top3.isEmpty) {
      prelaunch = false;
      top3 = [
        {'rank': 1, 'display_name': '데모 라이더', 'crew_name': '데모크루',
         'winner_id': 999001, 'user_id': 0, 'profile_image_url': '',
         'metric_label': '', 'slope_label': ''},
        {'rank': 2, 'display_name': '눈보라', 'crew_name': '',
         'winner_id': 999002, 'user_id': 0, 'profile_image_url': '',
         'metric_label': '', 'slope_label': '', 'has_claim': true}, // 신청완료 예시

        {'rank': 3, 'display_name': '파우더러', 'crew_name': '스노우',
         'winner_id': 999003, 'user_id': 0, 'profile_image_url': '',
         'metric_label': '', 'slope_label': ''},
      ];
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 상단 행: 영문 스키장명 + 한글 스키장명 · 올리브영 티켓.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(en, style: pxLabel(7, accent, spacing: 1)),
                  const SizedBox(height: 5),
                  // 풀네임(크게) + 그 옆에 개장일.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(ko,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _kr(22, _ink, bold: true)),
                      ),
                      if (openDate.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text('$openDate 개장',
                              style: _kr(11, _inkSub)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            _prizeTicket(),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 4,
          child: CustomPaint(painter: const _PixelDivider(_dividerCol)),
        ),
        const SizedBox(height: 12),
        if (prelaunch || top3.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(child: Text('개장 전', style: _kr(14, _inkSub))),
          )
        else
          for (int i = 0; i < top3.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _riderRow(context, top3[i], accent),
          ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, right: 6, bottom: 10),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _PixelFrame(border: accent, shadow: _cardShadow),
          child: ColoredBox(
            color: _cardBg,
            child: Padding(padding: const EdgeInsets.all(12), child: content),
          ),
        ),
      ),
    );
  }

  /// 순위 — 채우기 없이 '1등/2등/3등' 텍스트. (1 금 / 2 은 / 3 동 색)
  Widget _rankNumber(int rank) {
    const cols = {1: Color(0xFFF2A900), 2: Color(0xFF8F9BB3), 3: Color(0xFFCB7B3F)};
    return SizedBox(
      width: 42,
      height: 42,
      child: Center(
        child: Text('$rank등',
            style: _kr(18, cols[rank] ?? _inkSub, bold: true)
                .copyWith(height: 1.0)),
      ),
    );
  }

  /// 1~3등 한 줄 — 뱃지 + 링프사 + 닉네임/크루 + (당첨자 본인이면 상품받기 / 아니면 첫 하강 시각·슬로프).
  Widget _riderRow(BuildContext context, Map data, Color accent) {
    final rank = (data['rank'] as num?)?.toInt() ?? 0;
    final name = (data['display_name'] ?? '').toString();
    final crew = (data['crew_name'] ?? '').toString();
    final metric = (data['metric_label'] ?? '').toString();
    final slope = (data['slope_label'] ?? '').toString();
    final profile = (data['profile_image_url'] ?? '').toString();
    final userId = (data['user_id'] as num?)?.toInt();
    final winnerId = data['winner_id'];
    final canClaim = _canClaim(Map<String, dynamic>.from(data));
    // 이미 신청했으면(백엔드 has_claim, 또는 데모에서 제출한 winner_id) '신청완료'.
    final claimed = data['has_claim'] == true ||
        (kPhoenixClaimDemo &&
            winnerId is int &&
            kDemoClaimedWinnerIds.contains(winnerId));

    void openProfile() {
      if (userId == null) return;
      showRankingProfileModal(
        context,
        RankingUser(
          userId: userId,
          displayName: name,
          profileImageUrlUser: profile,
          crewName: crew.isEmpty ? null : crew,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _rankNumber(rank),
        const SizedBox(width: 10),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: openProfile, child: _avatar(profile, 42)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: openProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _kr(16, _ink).copyWith(height: 1.0)),
                  if (crew.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(crew,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _kr(10, _inkSub.withValues(alpha: 0.75))),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (canClaim)
          _claimButton(winnerId, accent, claimed: claimed)
        else if (metric.isNotEmpty || slope.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (metric.isNotEmpty)
                _pixelMetric(metric, _ink, asciiSize: 12, hangulSize: 11),
              if (slope.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(slope,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: _kr(10, _inkSub)),
              ],
            ],
          ),
      ],
    );
  }

  /// 원형 프사 + 카드색 링(두께 3). 기존 WebAvatar(캐시·기본이미지) 그대로.
  Widget _ringAvatar(String url, Color accent) => Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        child: ClipOval(child: _avatar(url, 34)),
      );

  /// 기록 — 얼리버드/슬로우는 보조어 + 숫자, 베스트는 숫자 + '회'.
  /// 숫자는 Press Start 2P + 하드 섀도(카드별 색). 값 문자열은 기존 그대로.
  Widget _record(String cat, String? caption, String metric, Color numShadow) {
    // 기록 숫자의 색상 음영 제거.
    final numText = _pixelMetric(metric, _ink, asciiSize: 13, hangulSize: 12);
    if (caption == null) return numText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(caption, style: _kr(10, _inkSub)),
        const SizedBox(width: 5),
        Flexible(child: numText),
      ],
    );
  }

  /// 숙박권 티켓 — 광택이 스윽 지나가고 별이 반짝이는 애니메이션.
  Widget _prizeTicket() => const _PrizeTicket();

  /// '상품 받기' 버튼 — 파인 모서리 픽셀 테두리 + 하드 섀도.
  /// [claimed](이미 신청함)이면 '신청완료'로 바뀌고 회색·비활성(탭 불가)이 된다.
  Widget _claimButton(dynamic winnerId, Color fill, {bool claimed = false}) {
    final Color bg = claimed ? const Color(0xFFC3CAD3) : fill;
    // 밝은 배경색(노란색·회색 등)은 흰 글씨 대비가 약해 어두운 잉크로 쓴다.
    final textColor =
        bg.computeLuminance() > 0.5 ? _ink : const Color(0xFFFFFFFF);
    final label = claimed ? '신청완료' : '상품 받기';

    Widget frame = Padding(
      // 테두리(3)·섀도(3,7)만큼 여백.
      padding: const EdgeInsets.only(left: 3, top: 3, right: 3, bottom: 7),
      child: CustomPaint(
        painter: const _PixelFrame(
            border: _ink, shadow: _cardShadow, t: 3,
            shadowOffset: Offset(3, 7)),
        child: ColoredBox(
          color: bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Text(label, style: _kr(13, textColor)),
          ),
        ),
      ),
    );

    if (claimed) {
      // 비활성 — 탭/커서 없음.
      return Opacity(opacity: 0.8, child: Semantics(button: true, enabled: false, label: label, child: frame));
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: () =>
              Get.toNamed('${WebRoutes.phoenixClaim}?winner=$winnerId'),
          child: frame,
        ),
      ),
    );
  }

  Widget _timeline() {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 9.1 섹션 헤더 — 왼쪽 정렬, 간격 12. 흰 외곽선 대신 하드 섀도.
        Text('SEASON EVENT',
            style: pxLabel(10, _brandBlue, spacing: 1)),
        const SizedBox(height: 12),
        Text('시즌 내내 이어지는 이벤트',
            style: _kr(28, _ink, bold: true).copyWith(
              height: 1.2,
              shadows: const [
                Shadow(color: _titleShadow, offset: Offset(3, 3), blurRadius: 0),
              ],
            )),
        const SizedBox(height: 12),
        Text('휘닉스파크와 스노우라이브가\n시즌 시작부터 끝까지 함께합니다.',
            style: _kr(15, _bodyText, height: 1.5)),
        const SizedBox(height: 18),
        _eventCard(
          border: const Color(0xFF2F6BE0),
          leading: Image.asset(
              'assets/imgs/imgs/snowballShop/icon_snowballshop_whiteball.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium),
          label: '크리스마스',
          labelColor: const Color(0xFF1F5FBF),
          title: '눈송이 상점 이벤트',
          desc: '12월, 눈송이 상점과 함께하는 특별 이벤트',
        ),
        const SizedBox(height: 14),
        _eventCard(
          border: const Color(0xFFF2B632),
          leading: const PixelSprite(spTrophy, scale: 4),
          label: '새해 이벤트',
          labelColor: const Color(0xFF7A5200),
          title: '휘닉스 어워즈',
          desc: '1월과 2월, 크루 시상식!',
        ),
      ],
    );
    return Padding(padding: const EdgeInsets.all(16), child: content);
  }

  /// 9.2 시즌 이벤트 카드 — 픽셀 프레임 + (원래) 아이콘 + COMING SOON 배지.
  Widget _eventCard({
    required Color border,
    required Widget leading,
    required String label,
    required Color labelColor,
    required String title,
    required String desc,
  }) {
    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 48, height: 48, child: Center(child: leading)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _kr(14, labelColor)),
              const SizedBox(height: 6),
              // 제목은 줄바꿈 금지 — 폰트를 줄이고 한 줄 말줄임.
              Text(title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: _kr(16, _ink).copyWith(height: 1.2)),
              const SizedBox(height: 6),
              Text(desc, style: _kr(14, _inkSub, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _comingSoonBadge(),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, right: 6, bottom: 10),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _PixelFrame(border: border, shadow: _cardShadow),
          child: ColoredBox(
            color: _cardBg,
            child: Padding(padding: const EdgeInsets.all(16), child: body),
          ),
        ),
      ),
    );
  }

  /// 9.3 COMING SOON 배지 — 파인 모서리 테두리 두께 3 ink, 섀도 없음, 고정 폭.
  Widget _comingSoonBadge() => Padding(
        padding: const EdgeInsets.all(3),
        child: CustomPaint(
          painter: const _PixelFrame(
              border: _ink, shadow: Color(0x00000000), t: 3),
          child: ColoredBox(
            color: _tileBlue,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('COMING',
                      style: pxLabel(8, _ink).copyWith(height: 1.6)),
                  Text('SOON', style: pxLabel(8, _ink).copyWith(height: 1.6)),
                ],
              ),
            ),
          ),
        ),
      );
}

// ── 상단 배너(캐러셀) ──
/// 히어로 — 배경 픽셀 슬로프 위에 바로 얹는 도트 타이틀.
/// 판때기(카드)를 두면 배경 설산이 가려지므로 글자만 올린다.
class _HeroTitle extends StatelessWidget {
  final Map<String, dynamic>? ev;
  const _HeroTitle({required this.ev});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final title = (ev?['title'] as String?)?.trim();

    // 메인 제목은 **Do Hyeon**(한글 통일). 도현이 얇아 약 10% 키우고(기존 44→48),
    // 외곽선 두께는 기존 값(글꼴 크기/11) 유지.
    final titleSize = isMobile ? 40.0 : 52.0;
    final dot = (isMobile ? 33.0 : 44.0) / 11;
    const ink = SkiColors.night;
    const paper = SnowScene.paper;

    // 커서 줄 — [점선] ▶ Snowlive X Phoenixpark [점선]. 양옆 점선이 남는 폭을 채워
    // 글자가 항상 묶음 가운데에 온다.
    // 양끝 점선은 각 2개만(폭 12 → 4px 칸 두 개).
    const dash2 = SizedBox(
        width: 12, height: 4, child: CustomPaint(painter: _PixelDivider(_cardShadow)));
    final cursorLine = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        dash2,
        const SizedBox(width: 8),
        _BlinkCaret(_brandBlue, 8),
        const SizedBox(width: 6),
        Text('26/27 SEASON OPEN', style: pxLabel(9, _brandBlue, spacing: 1)),
        const SizedBox(width: 8),
        dash2,
      ],
    );

    // 메인 제목(빵 이모티콘 제거).
    final titleStack = PixelOutlinedText(
      '스라 개장빵 이벤트',
      style: _kr(titleSize, ink),
      outline: paper,
      width: dot,
      ring: SkiColors.night,
      align: TextAlign.center,
    );

    // 오픈일 리본 — 파랑(날짜) + 노랑(OPEN), **텍스트 폭만큼만**. 가운데 정렬.
    final ribbon = Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 3, top: 3, right: 3, bottom: 7),
        child: Semantics(
          label: '전국 스키장 개장빵 이벤트',
          child: CustomPaint(
            painter: const _PixelFrame(
                border: _ink,
                shadow: _cardShadow,
                t: 3,
                shadowOffset: Offset(3, 7)),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ColoredBox(
                    color: _btnBg,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PixelSprite(spFlagRed, scale: 2),
                          const SizedBox(width: 10),
                          Text('올리브영 상품권',
                              style: _kr(14, const Color(0xFFFFFFFF),
                                  bold: true)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 3, child: ColoredBox(color: _ink)),
                  ColoredBox(
                    color: const Color(0xFFFFD23F),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Center(
                        child:
                            Text('5,000원', style: _kr(14, _ink, bold: true)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // 커서 줄·제목·리본을 **같은 폭**(묶음)으로 — 좌우 끝이 한 세로선에 맞는다.
    // 좁은 화면에선 화면폭(패딩 안)까지, 넓은 화면에선 440으로 캡.
    return Padding(
      // 상단 로고(topCenter 오버레이) 아래로 커서 줄이 내려오도록 — 로고와
      // 겹치지 않게 패딩을 키운다.
      padding: EdgeInsets.fromLTRB(16, isMobile ? 90 : 107, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cursorLine, // Expanded 점선이 묶음 폭까지 길게 채운다
              const SizedBox(height: 5),
              // 제목은 묶음 폭 안에서 가운데 — 한 줄 고정(넘치면 통째 축소).
              Center(child: FittedBox(fit: BoxFit.scaleDown, child: titleStack)),
              const SizedBox(height: 18),
              ribbon,
              const SizedBox(height: 12),
              // 오픈 리본 아래 — 작은 '참가방법' 리본(탭 → 안내 다이얼로그).
              _joinMethodRibbon(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 작은 '참가방법' 리본 — OPEN 리본보다 한 단계 작게. 누르면 안내 다이얼로그.
  Widget _joinMethodRibbon(BuildContext context) => Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Semantics(
            button: true,
            label: '참가방법 보기',
            child: GestureDetector(
              onTap: () => _showJoinMethodDialog(context),
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 2, top: 2, right: 2, bottom: 5),
                child: CustomPaint(
                  painter: const _PixelFrame(
                      border: _ink,
                      shadow: _cardShadow,
                      t: 2,
                      shadowOffset: Offset(2, 5)),
                  child: ColoredBox(
                    color: const Color(0xFFFFFFFF),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('참가방법', style: _kr(13, _ink)),
                          const SizedBox(width: 6),
                          Text('?', style: pxLabel(9, _brandBlue)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

}

/// 제목 왼쪽의 **노란 제설기** — 눈을 제목 위로 뿌리는 픽셀 애니메이션.
class _SnowCannonSpray extends StatefulWidget {
  const _SnowCannonSpray();
  @override
  State<_SnowCannonSpray> createState() => _SnowCannonSprayState();
}

class _SnowCannonSprayState extends State<_SnowCannonSpray>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> anim = MediaQuery.disableAnimationsOf(context)
        ? const AlwaysStoppedAnimation<double>(0.35)
        : _c;
    return RepaintBoundary(
      child: CustomPaint(painter: _SnowCannonPainter(anim)),
    );
  }
}

class _SnowCannonPainter extends CustomPainter {
  final Animation<double> t;
  _SnowCannonPainter(this.t) : super(repaint: t);

  static const _yellow = Color(0xFFF2C21E);
  static const _yellowLit = Color(0xFFFFE07A);
  static const _yellowDark = Color(0xFFC08E10);
  static const _blue = Color(0xFF2F5BA6);
  static const _blueDark = Color(0xFF203F78);
  static const _snow = Color(0xFFFFFFFF);

  // 결정적 의사난수(픽셀마다 고정 — 프레임마다 깜빡이지 않게).
  double _rnd(int i, int salt) {
    final x = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
    return x - x.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    final w = size.width, h = size.height;
    // 배경 소나무 크기(~30px). 도트 1칸 = 3px. 더 왼쪽에, **고개를 위로 든** 제설기.
    const u = 3.0;
    const ox = -4.0; // 더 왼쪽으로
    final oy = h * 0.5 - 5 * u;
    _drawMachine(canvas, p, ox, oy, u);
    // 노즐 = 드럼 **맨 위**(고개를 들었다) — 여기서 눈이 곧게 위로 나간다.
    _drawPlume(canvas, p, w, h, ox + 4.2 * u, oy + 0.3 * u);
  }

  /// 소나무 도트 스타일(3px 블록) 제설기 — 파란 받침 + **위를 향해 고개 든** 노란 드럼.
  void _drawMachine(Canvas canvas, Paint p, double ox, double oy, double u) {
    void blk(double gx, double gy, double gw, double gh, Color c) {
      p.color = c;
      canvas.drawRect(Rect.fromLTWH(ox + gx * u, oy + gy * u, gw * u, gh * u), p);
    }

    // ── 드럼(가파르게 위로 — 계단식 3단) ──
    blk(1, 5, 3, 3, _yellow); // 아래 단
    blk(2, 3, 3, 2, _yellow); // 중간 단(오른쪽+위)
    blk(3, 1, 3, 2, _yellow); // 윗 단(노즐 쪽)
    // 왼/윗면 밝게.
    blk(1, 5, 1, 3, _yellowLit);
    blk(2, 3, 1, 2, _yellowLit);
    blk(3, 1, 1, 2, _yellowLit);
    // 오른/아랫면 어둡게.
    blk(3, 5, 1, 3, _yellowDark);
    blk(4, 3, 1, 2, _yellowDark);
    blk(5, 1, 1, 2, _yellowDark);
    // 뒤쪽 팬 그릴(드럼 아래).
    blk(1, 6, 2, 2, _yellowDark);
    blk(1, 6, 1, 1, _yellowLit); // 반짝
    // 맨 위 노즐 링 + 구멍.
    blk(3, 0, 3, 1, _yellowLit);
    blk(5, 0, 1, 1, _yellowDark);
    // 드럼 위 눈.
    blk(3, 0, 2, 1, _snow);

    // ── 파란 받침(펌프 하우징) ──
    blk(1, 7, 1, 1, _blueDark); // 호스(드럼→받침)
    blk(0, 8, 5, 2, _blue); // 몸통
    blk(0, 8, 5, 1, _blueDark); // 윗 음영
    blk(1, 9, 2, 1, _blueDark); // 점검창
    blk(0, 10, 1, 1, _blueDark); // 왼 다리
    blk(4, 10, 1, 1, _blueDark); // 오른 다리
  }

  /// 제설기가 **눈을 곧게 위로 쏘아 올렸다가** 중력으로 글자 위로 쏟아지게 —
  /// 아래선 좁은 기둥, 위로 갈수록 퍼져 떨어진다. 부드러운(블러) 눈송이.
  void _drawPlume(Canvas canvas, Paint p, double w, double h, double mx, double my) {
    const body = Color(0xFFAEC6E0); // 쿨 그레이블루(연기 몸통) — 연한 배경 대비
    const n = 96;
    final puff = Paint()..isAntiAlias = true;
    for (int i = 0; i < n; i++) {
      final sp = 0.5 + _rnd(i, 1) * 0.7;
      final tau = (t.value * sp + _rnd(i, 2)) % 1.0;
      // 각도를 낮춰 — 살짝 오른쪽으로 기운 사선으로 쏘고 위로 갈수록 퍼진다.
      double x = mx + tau * (24 + _rnd(i, 6) * 24) +
          (_rnd(i, 3) - 0.5) * (3 + tau * tau * 40);
      // 완만한 아치 — 솟았다가 중력으로 글자 위로 떨어진다(각도 ↓).
      final up = 120 + _rnd(i, 7) * 48;
      final grav = 150 + _rnd(i, 8) * 55;
      double y = my - up * tau + grav * tau * tau;
      // 피어올랐다 끝까지 옅게 — 글자 위에 쏟아지듯.
      final fade = math.min(1.0, tau * 5) * (1 - tau * 0.5);
      final r = 3.5 + _rnd(i, 5) * 4 + tau * 4; // 크게, 번질수록 더 큼
      puff.maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5);
      puff.color = body.withValues(alpha: (0.6 * fade).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), r, puff);
      puff.color = _snow.withValues(alpha: (0.95 * fade).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x - r * 0.2, y - r * 0.25), r * 0.64, puff);
    }
  }

  @override
  bool shouldRepaint(_SnowCannonPainter old) => false;
}

/// 참가방법 안내 다이얼로그 — 아케이드 픽셀 프레임. 1번 단계에 앱 다운로드 버튼.
void _showJoinMethodDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: const Color(0x99000000),
    builder: (ctx) {
      Widget step(String n, String text, {Widget? trailing}) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 번호 배지 — 파란 픽셀 사각형.
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      color: _brandBlue,
                      child: Text(n,
                          style: pxLabel(10, const Color(0xFFFFFFFF))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(text, style: _kr(15, _ink, height: 1.35)),
                      ),
                    ),
                  ],
                ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 8),
                    child: trailing,
                  ),
              ],
            ),
          );

      // 앱 다운로드 버튼(딥링크) — 파란 픽셀 버튼.
      final downloadBtn = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Semantics(
          button: true,
          label: '스노우라이브 앱 다운로드',
          child: GestureDetector(
            onTap: openAppStoreForCurrentPlatform,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 3, top: 3, right: 3, bottom: 7),
              child: CustomPaint(
                painter: const _PixelFrame(
                    border: _ink,
                    shadow: _cardShadow,
                    t: 3,
                    shadowOffset: Offset(3, 7)),
                child: ColoredBox(
                  color: _btnBg,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('▼', style: pxLabel(9, const Color(0xFFFFFFFF))),
                        const SizedBox(width: 8),
                        Text('앱 다운로드',
                            style: _kr(14, const Color(0xFFFFFFFF))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Material(
              color: const Color(0x00000000),
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 4, top: 4, right: 6, bottom: 10),
                child: CustomPaint(
                  painter:
                      const _PixelFrame(border: _ink, shadow: _cardShadow),
                  child: ColoredBox(
                    color: const Color(0xFFFFFFFF),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 헤더 — 타이틀 + 닫기.
                          Row(
                            children: [
                              Expanded(
                                child: Text('참가방법',
                                    style: _kr(22, _ink, bold: true)),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(ctx).pop(),
                                  child: Text('✕',
                                      style: _kr(18, _inkSub)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 4,
                            child: CustomPaint(
                                painter: const _PixelDivider(_cardShadow)),
                          ),
                          const SizedBox(height: 10),
                          step('1', '스노우라이브 앱 다운로드',
                              trailing: downloadBtn),
                          step('2', '스키장에서 라이브온!'),
                          step('3', '라이딩하면 스키장별 선착순 1~3등 자동 집계'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
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
                decoration: skiMarker(fill: SkiColors.night),
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
          decoration: skiMarker(fill: SkiColors.snow),
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
/// 액션 버튼 — 색은 액션 블루 하나로 고정한다. 호출부마다 색을 넘기게 두면
/// 버튼마다 색이 갈려서 "누르는 것"이라는 신호가 흐려진다.
class _SkiButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool full;
  const _SkiButton({
    required this.label,
    required this.onTap,
    this.full = false,
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
      decoration: skiControl(
          fill: SkiColors.action,
          shadow: SkiColors.actionShadow,
          pressed: _down),
      // 좁은 카드에서도 한 줄 유지 — 넘치면 글자를 줄여 맞춘다(줄바꿈 금지).
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(widget.label,
            maxLines: 1,
            softWrap: false,
            style: SDSTextStyle.bold
                .copyWith(color: SkiColors.onAction, fontSize: 15)),
      ),
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
          offset: _down ? const Offset(kSkiPress, kSkiPress) : Offset.zero,
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
        decoration: skiControl(fill: SkiColors.snow),
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
    // [임시 데모] 등록자 50명 가정 — 실데이터가 적으면 더미로 채워 보여준다.
    if (_kDemo60 && list.length < 50) {
      list = List.generate(50, (i) {
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
        // 수상거부 등수(claimable==false)는 본인이어도 상품받기 버튼을 안 띄운다.
        if (_asInt(w['user_id']) == _myUserId() && w['claimable'] != false) {
          myWinnerId = w['winner_id'];
        }
      }
    }
    final ordered = _recentFirst ? list.reversed.toList() : list.toList();
    final filled = (count / 50 * 20).floor().clamp(0, 20); // 20칸 = 50명 기준

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 상단 행 — (FIRST 50 / 제목) + 현재/정원.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FIRST 50',
                      style: pxLabel(9, const Color(0xFF7A5200), spacing: 1)),
                  const SizedBox(height: 6),
                  Text('개장빵 선착순 50명', style: _kr(20, _ink)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('$count/50',
                style: pxLabel(12, _ink).copyWith(shadows: const [
                  Shadow(color: _countShadow, offset: Offset(2, 2), blurRadius: 0),
                ])),
          ],
        ),
        const SizedBox(height: 14),
        Semantics(
          label: '50명 중 $count명 달성',
          child: SizedBox(
            height: 18,
            child: CustomPaint(painter: _ProgressBar(filled)),
          ),
        ),
        if (myWinnerId != null) ...[
          const SizedBox(height: 14),
          _widePixelButton(
            label: '개장빵 상품 받기',
            onTap: () =>
                Get.toNamed('${WebRoutes.phoenixClaim}?winner=$myWinnerId'),
          ),
        ],
        if (count > 0) ...[
          const SizedBox(height: 14),
          Align(alignment: Alignment.centerRight, child: _sortButton()),
          const SizedBox(height: 6),
          _carousel(ordered),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, right: 6, bottom: 10),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: const _PixelFrame(border: _ink, shadow: _cardShadow),
          child: ColoredBox(
            color: _cardBg,
            child: Padding(padding: const EdgeInsets.all(16), child: content),
          ),
        ),
      ),
    );
  }

  /// 정렬 토글 버튼 — 흰 배경, 파인 테두리 3 ink + 섀도 (3,7). 라벨은 기존 로직값.
  Widget _sortButton() => Padding(
        padding: const EdgeInsets.only(left: 3, top: 3, right: 3, bottom: 7),
        child: Semantics(
          button: true,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() {
                _recentFirst = !_recentFirst;
                _page = 0;
                if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
              }),
              child: CustomPaint(
                painter: const _PixelFrame(
                    border: _ink,
                    shadow: _cardShadow,
                    t: 3,
                    shadowOffset: Offset(3, 7)),
                child: ColoredBox(
                  color: const Color(0xFFFFFFFF),
                  child: SizedBox(
                    height: 44,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 16,
                              child: CustomPaint(
                                  painter: _PixelIcon(_sortArrows, _ink, grid: 6)),
                            ),
                            const SizedBox(width: 8),
                            Text(_recentFirst ? '최근 라이더부터' : '빠른 라이더부터',
                                style: _kr(16, _ink)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// 10명씩 좌우 스와이프 + 숫자 페이지 버튼.
  Widget _carousel(List ordered) {
    final total = ordered.length;
    final pages = (total / _kPageSize).ceil();
    const rowH = 52.0;
    const pageHeight = _kPageSize * rowH;
    final cur = _page.clamp(0, pages - 1);

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
        // 마지막 행 아래에도 점선 1줄.
        SizedBox(
          height: 4,
          child: CustomPaint(painter: const _PixelDivider(_dividerCol)),
        ),
        if (pages > 1) ...[
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            runSpacing: 2,
            children: [for (int p = 0; p < pages; p++) _pageButton(p, cur)],
          ),
        ],
      ],
    );
  }

  /// 숫자 페이지 버튼 — 터치 44, 안쪽 36 사각형.
  Widget _pageButton(int p, int cur) {
    final active = p == cur;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _page = p);
        _pageCtrl.animateToPage(p,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      },
      child: Semantics(
        button: true,
        selected: active,
        label: '${p + 1}페이지',
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: ColoredBox(
                color: active ? _ink : _tileBlue,
                child: Center(
                  child: Text('${p + 1}',
                      style: pxLabel(
                          11, active ? const Color(0xFFFFFFFF) : _ink)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rankRow(Map e, int idx) {
    final rank = e['rank'];
    final name = (e['display_name'] ?? '').toString();
    final metric = (e['metric_label'] ?? '').toString();
    final profile = (e['profile_image_url'] ?? '').toString();
    final mine = e['user_id'] != null && _asInt(e['user_id']) == _myUserId();
    return Column(children: [
      SizedBox(
        height: 4,
        child: CustomPaint(painter: const _PixelDivider(_dividerCol)),
      ),
      SizedBox(
        height: 48,
        child: ColoredBox(
          color: mine ? const Color(0xFFFFF6CC) : const Color(0x00000000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: Text('$rank', style: pxLabel(12, _brandBlue)),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      color: _listRing, shape: BoxShape.circle),
                  child: ClipOval(child: _avatar(profile, 32)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _kr(20, _ink)),
                ),
                const SizedBox(width: 10),
                _pixelMetric(metric, _ink, asciiSize: 12, hangulSize: 13),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}

/// SNS OOTD 이벤트 — 유일한 어두운(night) 패널.
class _OotdPanel extends StatelessWidget {
  const _OotdPanel();

  @override
  Widget build(BuildContext context) {
    // 그라데이션 제거 → 분홍 픽셀 프레임. 문구·태그·복사 동작은 기존 그대로.
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1) 상단 행 — 좌: SNS OOTD + 베스트 드레서, 우: 하트.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _pixelInstagram(),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text('베스트 드레서',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _kr(28, _ink, bold: true).copyWith(
                          // 줄높이 1.0으로 글자 박스를 조여 아이콘·티켓과
                          // 세로 중심이 맞게 한다.
                          height: 1.0,
                          shadows: const [
                            Shadow(
                                color: _ootdTitleShadow,
                                offset: Offset(2, 2),
                                blurRadius: 0),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // 라이더 카드와 동일한 숙박권 티켓.
            const _PrizeTicket(),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 4,
          child: CustomPaint(painter: const _PixelDivider(_ootdDivider)),
        ),
        const SizedBox(height: 14),
        // 3) 본문.
        Text('스키장 OOTD를 인스타에 올리고 태그하세요.\n추첨을 통해 숙박권 1매 증정!',
            style: _kr(14, _bodyText, height: 1.5)),
        const SizedBox(height: 14),
        // 4) 태그 칩 — 하드 섀도 (3,3) 분홍.
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final t in _ootdTags)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: const BoxDecoration(
                color: _ink,
                boxShadow: [
                  BoxShadow(
                      color: _ootdBorder,
                      offset: Offset(3, 3),
                      blurRadius: 0),
                ],
              ),
              child: Text(t,
                  style: _kr(16, const Color(0xFFFFFFFF))),
            ),
        ]),
        const SizedBox(height: 14),
        // 5) 태그 복사 — 가로 꽉 찬 버튼.
        _widePixelButton(
            label: '태그 복사',
            onTap: _copyOotdTags,
            fill: const Color(0xFFFFFFFF),
            textColor: _ink),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, right: 6, bottom: 10),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: const _PixelFrame(border: _ootdBorder, shadow: _cardShadow),
          child: ColoredBox(
            color: _ootdBg,
            child: Padding(padding: const EdgeInsets.all(16), child: content),
          ),
        ),
      ),
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
