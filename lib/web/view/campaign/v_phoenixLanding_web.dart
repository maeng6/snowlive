import 'dart:async';

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/campaign/ski_slope_actors_web.dart';
import 'package:com.snowlive/web/view/campaign/ski_slope_scene_web.dart';
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
// 카드 채움 — 어두운 4색. 창백한 설경 위에서 대비로 떠올라야 "콘텐츠 블록"으로
// 떨어져 나온다. 밝은 카드(배경과 같은 하늘색 계열)는 배경에 녹아서 접었다.
const _catFill = {
  'early_bird': SkiColors.cardEarly,
  'slow_rider': SkiColors.cardSlow,
  'best_rider': SkiColors.cardBest,
};
const _catCaption = {'slow_rider': '소요시간'};
// 시상 카테고리. 이 맵의 키 순서가 그대로 카드 순서가 된다.
//
// '패스트 라이더'(평균 속도 1위)는 **의도적으로 뺐다** — 슬로프에서 속도 경쟁을
// 부추기는 항목이라 위험하다는 판단. 서버는 여전히 fast_rider를 내려줄 수 있지만
// 화면에는 올리지 않는다. 다시 넣자는 얘기가 나오면 이 사유부터 확인할 것.
const _catMeta = {
  'early_bird': ['얼리버드 라이더', '가장 먼저 슬로프를 내려온 라이더'],
  'slow_rider': ['슬로우 라이더', '한 슬로프를 가장 오래 내려온 라이더'],
  'best_rider': ['베스트 라이더', '개장일 하루 가장 많이 탄 라이더'],
};

// 웹에서 user.user_id가 String으로 올 수 있어(UserViewModel.user는 dynamic) 정수로 정규화.
int? _asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}');

/// 당첨자 본인에게만 뜨는 '상품 받기' 버튼 노출 조건.
/// 카드(버튼을 그릴지)와 그리드(높이를 늘릴지)가 같은 판정을 써야 한다 —
/// 갈라지면 버튼은 뜨는데 높이가 그대로라 프사가 눌린다.
bool _canClaim(Map? winner) =>
    winner != null &&
    winner['winner_id'] != null &&
    _asInt(winner['user_id']) == _myUserId();

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

Widget _pixelMetric(String s, Color color) {
  final spans = <InlineSpan>[];
  final buf = StringBuffer();
  bool? asciiRun;
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
              child: Text(buf.toString(), style: pxLabel(11, color)),
            ),
          )
        : TextSpan(
            text: buf.toString(),
            style: SDSTextStyle.bold.copyWith(color: color, fontSize: 12),
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
  final base = SDSTextStyle.bold.copyWith(color: color, fontSize: 12);
  return Text.rich(
    TextSpan(children: spans),
    maxLines: 1,
    softWrap: false,
    overflow: TextOverflow.ellipsis,
    style: base,
    strutStyle: const StrutStyle(
      fontFamily: 'Pretendard',
      fontSize: 12,
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
    return Container(
      color: SnowScene.snow,
      child: WebStickyFooterScroll(
        onRefresh: vm.load,
        padding: EdgeInsets.zero,
        // 배경(설경)은 폭 제한 **바깥에** 깔아 PC에서도 화면 끝까지 채운다.
        // 콘텐츠만 1280으로 묶이고, 넓어진 만큼 눈밭과 숲이 더 그려진다.
        content: Stack(children: [
          // 지형은 한 번 구운 비트맵, 라이더·리프트 의자만 매 프레임 움직인다.
          // pisteWidth는 두 레이어가 **같은 값**이어야 경로가 어긋나지 않는다.
          // 모바일은 화면이 좁아 양옆 숲이 제목까지 밀고 들어온다.
          // 제목 블록이 차지하는 세로 띠만 알려주고 그 안쪽 나무를 비운다.
          Positioned.fill(
            child: SkiSlopeBackground(
              pisteWidth: 980,
              clearTop: isMobile ? 60 : 0,
              clearBottom: isMobile ? 350 : 0,
            ),
          ),
          const Positioned.fill(child: SkiSlopeActors(pisteWidth: 980)),
          Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kWebDesktopListMaxWidth),
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
        children: [_HeroTitle(ev: ev), gap, sections],
      ),
    );
  }

  /// 섹션 제목 — 배경 설경 위에 바로 놓이므로 흰 외곽선 한 겹으로 어떤 음영
  /// 위에서도 읽히게 한다. 크기는 Galmuri11 도트 격자에 맞춘 22(11x2).
  Widget _sectionTitle(String t) => PixelOutlinedText(
        t,
        style: pxDot(22, SkiColors.night, bold: true),
        outline: SnowScene.paper,
        width: 1,
      );

  Widget _openingSection(BuildContext context, Map<String, dynamic> ev) {
    final status = ev['status'];
    final announced =
        status == 'announced' || status == 'closed' || status == 'archived';
    final lb = ev['leaderboard'] as Map?;
    final winners = ev['winners'] as Map?;
    final isMobile = context.screenType == WebScreenType.mobile;
    // 카테고리 수가 줄면 열도 같이 줄여야 한 줄이 고르게 찬다(4열에 3장이면
    // 오른쪽 한 칸이 비어 균형이 깨진다).
    final wide = _catMeta.length < 4 ? _catMeta.length : 4;
    final cross = isMobile
        ? 2
        : (context.screenType == WebScreenType.tablet ? 2 : wide);

    // 버튼이 뜨는 카드가 하나라도 있으면 **전체** 높이를 키운다. GridView의
    // mainAxisExtent는 칸 공통이라 카드별로 다르게 줄 수 없다.
    final anyClaim =
        _catMeta.keys.any((cat) => _canClaim(winners?[cat] as Map?));
    final cardExtent = anyClaim ? 226.0 : 172.0; // 버튼 44 + 간격 10

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
            mainAxisExtent: cardExtent,
          ),
          itemBuilder: (_, i) => cards[i],
        ),
      ],
    );
  }

  Widget _statusBadge(String? status) {
    // (라벨, 채움, 글자) — '발표'만 액션 블루라 글자를 흰색으로 뒤집는다.
    final map = {
      'scheduled': ['예정', SkiColors.sky, SkiColors.night],
      'open': ['진행중', SkiColors.mint, SkiColors.night],
      'closed': ['집계중', SkiColors.sky, SkiColors.night],
      'announced': ['발표', SkiColors.action, SkiColors.onAction],
    };
    final m = map[status] ?? ['', SkiColors.sky, SkiColors.night];
    final ink = m[2] as Color;
    // 라운드 처리 + 크기 축소.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      // 라운드를 빼고 다른 칩과 같은 각진 테두리로 — 여기만 알약이면 튄다.
      decoration: skiMarker(fill: m[1] as Color),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 5, height: 5,
          decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(m[0] as String,
            style: SDSTextStyle.bold.copyWith(color: ink, fontSize: 11)),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: skiSurface(fill: fill),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 윗줄: 제목(아이콘 타일 제거).
          Text(meta[0], maxLines: 1, overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.bold
                  .copyWith(color: SkiColors.onDarkDim, fontSize: 15)),
          if (name != null) ...[
            // 가운뎃줄: 정사각 프사 + 큰 닉네임 — 세로 가운데 정렬.
            Expanded(
              child: Center(
                child: Row(children: [
                  _avatar(profile, 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.extraBold
                            .copyWith(color: SkiColors.onDark, fontSize: 17)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            const SkiDashedLine(color: SkiColors.onDarkDim),
            const SizedBox(height: 8),
            // 아랫줄: 슬로프 · 기록을 한 덩어리로 가로 가운데 정렬.
            // 글꼴이 섞인 글줄의 세로 눈높이는 _pixelMetric 안에서 따로 맞춘다
            // (가로 정렬과 무관한 축이라 둘은 같이 쓴다).
            //
            // 모바일 2열에서는 카드 안쪽이 ~148px뿐이라 '파노(휘) 소요시간 6:45'
            // 같은 조합이 넘친다. Flexible로 두면 말줄임·줄바꿈이 생겨 값이
            // 잘리므로, 통째로 FittedBox에 넣어 **줄여서라도 전부** 보이게 한다.
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (slope.isNotEmpty)
                      Text(slope, maxLines: 1, softWrap: false,
                          style: SDSTextStyle.bold.copyWith(
                              color: SkiColors.onDarkDim, fontSize: 12)),
                    if (metric.isNotEmpty) ...[
                      if (slope.isNotEmpty) const SizedBox(width: 6),
                      if (caption != null) ...[
                        Text(caption, maxLines: 1, softWrap: false,
                            style: SDSTextStyle.bold.copyWith(
                                color: SkiColors.onDarkDim, fontSize: 12)),
                        const SizedBox(width: 4),
                      ],
                      _pixelMetric(metric, SkiColors.onDark),
                    ],
                  ],
                ),
              ),
            ),
          ] else ...[
            const Spacer(),
            Text(announced ? '수상자 없음' : '아직 기록 없음',
                style: SDSTextStyle.bold
                    .copyWith(color: SkiColors.onDarkDim, fontSize: 13)),
            const Spacer(),
          ],
          if (_canClaim(winner)) ...[
            const SizedBox(height: 10),
            _SkiButton(
              label: '상품 받기',
              full: true,
              onTap: () =>
                  Get.toNamed('${WebRoutes.phoenixClaim}?winner=$winnerId'),
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
          // 선착순 블록과 같은 불투명 흰색 — 반투명이면 뒤 설경이 비쳐서
          // 카드마다 바탕이 달라 보인다.
          decoration: skiSurface(fill: SkiColors.white),
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
              decoration: skiMarker(fill: SkiColors.sky),
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
        PixelOutlinedText(
          '시즌 내내 이어지는 이벤트',
          style: pxDot(22, SkiColors.night, bold: true),
          outline: SnowScene.paper,
          width: 1,
        ),
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
                Text('크리스마스',
                    style: SDSTextStyle.extraBold
                        .copyWith(color: SkiColors.night, fontSize: 17)),
                const SizedBox(width: 6),
                const PixelSprite(spXmasTree, scale: 2),
              ]),
              Text('눈송이 상점 이벤트',
                  style: SDSTextStyle.extraBold
                      .copyWith(color: SkiColors.night, fontSize: 17)),
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
              Text('시즌말',
                  style: SDSTextStyle.extraBold
                      .copyWith(color: SkiColors.night, fontSize: 17)),
              Text('휘닉스 어워즈',
                  style: SDSTextStyle.extraBold
                      .copyWith(color: SkiColors.night, fontSize: 17)),
            ],
          ),
          sub: '시즌 종합점수 크루 시상식',
        ),
        const SizedBox(height: 14),
      ],
    );

    // 배경 이미지를 깔지 않는다 — 파란 일러스트가 창백한 설경 위에서 혼자
    // 다른 그림이 된다. 눈밭이 그대로 비치는 쪽이 한 화면으로 읽힌다.
    return Padding(padding: const EdgeInsets.all(16), child: content);
  }
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
    final subtitle = (ev?['subtitle'] as String?)?.trim();

    // Galmuri11은 11px 비트맵 글꼴 — 11의 배수 크기에서만 획이 정수 도트로
    // 떨어진다. 외곽선 두께도 도트 한 칸(size/11)에 맞춰야 격자가 안 깨진다.
    final titleSize = isMobile ? 33.0 : 44.0;
    final dot = titleSize / 11;
    const ink = SkiColors.night;
    const paper = SnowScene.paper;

    return Padding(
      // 상단 여백은 배경 맨 위 산장(약 55px)을 비울 만큼만.
      padding: EdgeInsets.fromLTRB(
        16,
        isMobile ? 84 : 104,
        16,
        isMobile ? 40 : 60,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelOutlinedText(
            '26/27 SEASON',
            style: pxLabel(isMobile ? 10 : 12, SkiColors.deepBlue, spacing: 2),
            outline: paper,
            width: 2,
            align: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 22),
          // 제목 + 개장'빵' 바게트. 스프라이트는 정수 배율에서만 격자가 안
          // 깨지므로 13칸 기준 2·3배로 고정하고, 아주 좁은 화면에서만
          // FittedBox가 통째로 줄인다(글자만 줄이면 도트가 어긋난다).
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PixelOutlinedText(
                  title?.isNotEmpty == true ? title! : '휘팍 개장빵',
                  // 부제는 Regular로 둬서 위계를 남긴다.
                  style: pxDot(titleSize, ink, bold: true),
                  outline: paper,
                  width: dot,
                  align: TextAlign.center,
                ),
                const SizedBox(width: 8),
                PixelSprite(spBaguette, scale: isMobile ? 2 : 3),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 14 : 18),
          PixelOutlinedText(
            'PHOENIX PARK OPENING',
            style: pxLabel(isMobile ? 9 : 11, SkiColors.deepBlue, spacing: 3),
            outline: paper,
            width: 2,
            align: TextAlign.center,
          ),
          if (subtitle?.isNotEmpty == true) ...[
            SizedBox(height: isMobile ? 14 : 18),
            PixelOutlinedWrap(
              subtitle!,
              style: pxDot(22, ink),
              outline: paper,
              width: 2,
            ),
          ],
          SizedBox(height: isMobile ? 20 : 26),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            // 누를 수 없는 정보 칩이라 그림자를 빼고 표시 어법으로 둔다.
            decoration: skiMarker(fill: SkiColors.action),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PixelSprite(spFlagRed, scale: 2),
                const SizedBox(width: 8),
                Text('2026.11.20 OPEN', style: pxLabel(11, SkiColors.onAction)),
              ],
            ),
          ),
        ],
      ),
    );
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
      child: Text(widget.label,
          style: SDSTextStyle.bold
              .copyWith(color: SkiColors.onAction, fontSize: 15)),
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
        if (_asInt(w['user_id']) == _myUserId()) myWinnerId = w['winner_id'];
      }
    }
    final ordered = _recentFirst ? list.reversed.toList() : list.toList();
    final filled = (count / 5).ceil().clamp(0, 20);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: skiSurface(fill: SkiColors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const PixelSprite(spCoin, scale: 3),
            const SizedBox(width: 10),
            Expanded(
              child: Text('개장빵 선착순 100명',
                  style: SDSTextStyle.extraBold
                      .copyWith(color: SkiColors.night, fontSize: 17)),
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
                    // 테두리는 채움과 무관하게 night 하나로 — 빈 칸만 밝은
                    // 테두리를 쓰면 게이지가 두 가지 어법으로 갈린다.
                    decoration: skiMarker(
                      fill: i < filled ? SkiColors.action : SkiColors.sky,
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
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: skiControl(fill: SkiColors.snow),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const SkiSortIcon(size: 16),
                    const SizedBox(width: 6),
                    // 아이콘만 두면 무엇을 누르는 버튼인지 알 수 없어서
                    // 지금 적용된 정렬을 글자로 같이 띄운다.
                    Text(_recentFirst ? '최근 라이더부터' : '빠른 라이더부터',
                        style: SDSTextStyle.bold.copyWith(
                            color: SkiColors.night, fontSize: 13)),
                  ]),
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
    final mine = e['user_id'] != null && _asInt(e['user_id']) == _myUserId();
    return Column(children: [
      const SkiDashedLine(color: SkiColors.ice),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration:
            mine ? skiMarker(fill: SkiColors.yellow) : const BoxDecoration(),
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
      // 채움은 가장 짙은 톤 그대로 — 결과 카드 4색과 겹치지 않아야 CTA 블록으로
      // 따로 읽힌다. 그림자만 액션 블루로(기존 핑크는 옛 팔레트의 마지막 잔재였다).
      decoration: skiSurface(fill: SkiColors.panel),
      child: Stack(children: [
        const Positioned(top: 0, right: 0, child: PixelSprite(spHeart, scale: 4)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SNS OOTD', style: pxLabel(11, SkiColors.actionLit)),
            const SizedBox(height: 8),
            Text('베스트 드레서',
                style: SDSTextStyle.extraBold
                    .copyWith(color: SkiColors.snow, fontSize: 22)),
            const SizedBox(height: 8),
            Text('스키장 OOTD를 인스타에 올리고 태그하세요.\n좋아요를 가장 많이 받으신 분께 숙박권 1매 증정!',
                style: SDSTextStyle.regular.copyWith(
                    color: SkiColors.sky, fontSize: 14, height: 1.5)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in _ootdTags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: skiMarker(fill: SkiColors.deepBlue),
                  child: Text(t,
                      style: SDSTextStyle.bold.copyWith(color: SkiColors.snow, fontSize: 13)),
                ),
            ]),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: _SkiButton(label: '태그 복사', onTap: _copyOotdTags),
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
