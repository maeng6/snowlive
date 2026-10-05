import 'dart:math' as math;

import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewDetail.dart';
import 'package:com.snowlive/core/model/m_crewList.dart';
import 'package:com.snowlive/core/model/m_resortModel.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewJoin_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_card_web.dart';
import 'package:com.snowlive/web/widget/w_web_search_field_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 목업 실측 800(검색창과 결과 행이 넓게 눕는다).
const double kCrewJoinContentMaxWidth = 800;

/// 크루 가입하기 — 크루를 검색해 가입 신청한다. `#/livecrew-join`
///
/// `?resort=13`을 붙이면 그 스키장의 크루 **전체**를 보는 화면으로 쓴다
/// (라이브크루 홈의 목록은 서버가 리조트별 30개로 잘라 주기 때문에 그쪽에서 넘어온다).
class CrewJoinViewWeb extends StatefulWidget {
  const CrewJoinViewWeb({super.key});

  @override
  State<CrewJoinViewWeb> createState() => _CrewJoinViewWebState();
}

class _CrewJoinViewWebState extends State<CrewJoinViewWeb> {
  final CrewJoinViewModelWeb _vm = Get.find<CrewJoinViewModelWeb>();
  final TextEditingController _searchController = TextEditingController();

  /// 스키장별 전체보기로 들어온 경우의 리조트 id. 라우트 파라미터는 initState에서
  /// 잡아둔다 — 이후 Get.parameters가 비워질 수 있다.
  int? _resortId;

  @override
  void initState() {
    super.initState();
    _resortId = int.tryParse(Get.parameters['resort'] ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.search(null, _resortId);
    });
  }

  /// 스키장별로 들어왔으면 제목에 스키장 이름을 쓴다.
  String get _title {
    final id = _resortId;
    if (id == null) return '크루 가입하기';
    final index = id - 1;
    final name = (index >= 0 && index < resortNameList.length) ? resortNameList[index] : null;
    return (name?.isNotEmpty ?? false) ? '$name 크루' : '크루 가입하기';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 뒤로가기 — 돌아갈 화면이 없으면(URL 직접 진입) 라이브크루 홈으로.
  void _onBack() {
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }
    Get.offAllNamed(WebRoutes.liveCrew);
  }

  Future<void> _openCrew(Crew crew) async {
    final crewId = crew.crewId;
    if (crewId == null) return;
    final applied = await showCrewJoinModal(context, crew: crew, vm: _vm);
    if (applied == true && mounted) {
      showWebToast(
        context,
        '가입 신청을 보냈습니다.',
        alignment: context.screenType == WebScreenType.mobile
            ? Alignment.bottomCenter
            : Alignment.topCenter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ 페이지 여백은 **스크롤 영역 안쪽**에 둔다(웹 공통). 바깥 Container에 주면
    // 목록이 그 여백 선에서 잘리고 스크롤바도 브라우저 끝에 안 붙는다.
    final pagePadding = webSubPagePadding(context);

    return Container(
      color: SDSColor.snowliveWhite,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 본문 800 제한은 **PC에서만**. 태블릿은 폭이 800을 조금 넘는 구간
          // (840~1023)이 있어 그대로 두면 좌우가 20보다 크게 벌어지고 본문이
          // 800에 갇힌다 → 좁은 폭은 페이지 여백 안쪽을 꽉 채운다.
          final side = context.isDesktop
              ? math.max(
                  pagePadding.left,
                  (constraints.maxWidth - kCrewJoinContentMaxWidth) / 2,
                )
              : pagePadding.left;
          // 조건에 맞는 크루를 **전부** 그린다(전체 521개, 휘닉스 169개 — 실측).
          // Column에 다 쌓으면 한 프레임에 수백 개를 만들게 되므로 지연 렌더한다.
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(side, pagePadding.top, side, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // PC는 목업(174:89291)대로 **뒤로가기 없이** Bold 32 제목만 둔다
                      // (좌측 GNB가 늘 보여 돌아갈 길이 있다).
                      // 좁은 폭은 GNB가 접히므로 서브 페이지 공통 헤더
                      // (뒤로가기 + 타이틀 태블릿 24 / 모바일 20)를 쓴다.
                      if (context.isDesktop)
                        Text(
                          _title,
                          style: SDSTextStyle.bold.copyWith(
                            fontSize: webHomeTitleSize(context),
                            color: SDSColor.gray900,
                          ),
                        )
                      else
                        WebPageHeader(title: _title, onBack: _onBack),
                      // 타이틀 ↔ 검색창: PC 29(목업 — 타이틀 블록 pb19 + 검색 pt10) /
                      // 좁은 폭은 제목이 작아진 만큼 20.
                      SizedBox(height: context.isDesktop ? 29 : 20),
                      WebSearchField(
                        controller: _searchController,
                        hint: '크루 검색',
                        borderRadius: 6,
                        // 스키장별로 들어왔으면 그 스키장 안에서 검색한다.
                        onSubmitted: (keyword) => _vm.search(keyword, _resortId),
                      ),
                      // 검색창 ↔ 첫 행: PC 30(목업) / 좁은 폭 20.
                      SizedBox(height: context.isDesktop ? 30 : 20),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(side, 0, side, SDSSpacing.xl),
                sliver: Obx(_buildListSliver),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 결과가 없을 때는 한 덩어리, 있으면 지연 렌더 슬리버로 돌려준다.
  Widget _buildListSliver() {
    final crews = _vm.crews;
    final isLoading = _vm.isLoading;
    final hasError = _vm.hasError;
    final count = crews.length;

    if (count == 0) {
      final Widget body;
      if (hasError) {
        body = WebErrorState(onRetry: () => _vm.search(_vm.keyword, _resortId));
      } else if (isLoading) {
        body = const _CrewJoinSkeleton();
      } else {
        body = const WebEmptyState(message: '검색 결과가 없어요.');
      }
      return SliverToBoxAdapter(child: body);
    }

    return SliverList.builder(
      itemCount: count,
      itemBuilder: (_, index) => _CrewJoinRow(
        crew: crews[index],
        onTap: () => _openCrew(crews[index]),
      ),
    );
  }
}

/// 검색 결과 로딩 — **실제 행과 같은 구성**(로고 48 + 이름 16 + 부제 13)으로 그린다.
/// 한 덩어리 막대로 두면 로딩이 끝나는 순간 레이아웃이 튄다.
class _CrewJoinSkeleton extends StatelessWidget {
  const _CrewJoinSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < 6; i++)
            Padding(
              // 실제 행과 같은 패딩(좌우 8 · 상하 8).
              padding: const EdgeInsets.symmetric(
                  horizontal: SDSSpacing.sm, vertical: SDSSpacing.sm),
              child: Row(
                children: [
                  SkeletonBox(width: 48, height: 48, radius: crewLogoRadius(48)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 크루명(16) / 간격 4 / 부제(13) — 길이는 행마다 조금씩 다르게.
                        SkeletonLine(width: 120 + (i % 3) * 28, height: 18),
                        const SizedBox(height: 4),
                        SkeletonLine(width: 180 + (i % 2) * 40, height: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CrewJoinRow extends StatefulWidget {
  final Crew crew;
  final VoidCallback onTap;

  const _CrewJoinRow({required this.crew, required this.onTap});

  @override
  State<_CrewJoinRow> createState() => _CrewJoinRowState();
}

class _CrewJoinRowState extends State<_CrewJoinRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final crew = widget.crew;
    final logoUrl = crewLogoUrlOf(logoUrl: crew.crewLogoUrl, color: crew.color);
    // 목업 보조줄: `휘닉스 · 중앙대 보드 동아리`(리조트 별명 · 소개).
    final nick = crewResortNicknameOf(crew.baseResortId);
    final desc = crew.description?.trim().replaceAll('\n', ' ') ?? '';
    final subtitle = [if (nick.isNotEmpty) nick, if (desc.isNotEmpty) desc].join(' · ');

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
          padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.sm, vertical: 8),
          child: Row(
            children: [
              // 목업(174:89293) — 로고 48 라운드 8. 크루색 테두리는 목업에 없다.
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  // 라운드는 공용 비율(한 변의 0.2) — 기본 마크 이미지에 구워진
                  // 모서리와 곡률을 맞춘다.
                  borderRadius: BorderRadius.circular(crewLogoRadius(48)),
                  // 기본 크루 마크가 흰 카드라 테두리가 없으면 흰 배경에 묻힌다
                  // (크루 목록 행·팝업과 같은 gray100 선).
                  border: Border.all(color: SDSColor.gray100),
                ),
                clipBehavior: Clip.antiAlias,
                child: (logoUrl?.isNotEmpty ?? false)
                    ? WebNetworkImage(url: logoUrl, width: 48, height: 48)
                    : Container(color: SDSColor.gray100),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      crew.crewName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular.copyWith(fontSize: 16, color: SDSColor.gray900),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
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

/// 크루 미리보기 팝업 — `크루 구경하기` / `크루 가입하기` 두 버튼(목업).
/// 가입 신청을 보냈으면 `true`로 닫힌다.
Future<bool?> showCrewJoinModal(
  BuildContext context, {
  required Crew crew,
  required CrewJoinViewModelWeb vm,
}) {
  final isMobile = context.screenType == WebScreenType.mobile;
  return showWebOverlayModal<bool>(
    context: context,
    alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
    padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(SDSSpacing.lg),
    builder: (_, close) => _CrewJoinCard(
      crew: crew,
      vm: vm,
      isSheet: isMobile,
      onClose: close,
    ),
  );
}

class _CrewJoinCard extends StatefulWidget {
  final Crew crew;
  final CrewJoinViewModelWeb vm;
  final bool isSheet;
  final void Function([bool? result]) onClose;

  const _CrewJoinCard({
    required this.crew,
    required this.vm,
    required this.isSheet,
    required this.onClose,
  });

  @override
  State<_CrewJoinCard> createState() => _CrewJoinCardState();
}

class _CrewJoinCardState extends State<_CrewJoinCard> {
  CrewDetailInfo? _detail;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final crewId = widget.crew.crewId;
    if (crewId == null) return;
    // 목록 응답에는 멤버 수가 없다 → 팝업이 열릴 때 상세로 채운다.
    final detail = await widget.vm.fetchDetail(crewId);
    if (mounted) setState(() => _detail = detail);
  }

  Future<void> _apply() async {
    final crewId = widget.crew.crewId;
    if (crewId == null) return;
    setState(() => _isApplying = true);
    final result = await widget.vm.apply(
      crewId: crewId,
      crewLeaderUserId: _detail?.crewLeaderUserId ?? widget.crew.crewLeaderUserId,
    );
    if (!mounted) return;
    setState(() => _isApplying = false);
    if (result.ok) {
      widget.onClose(true);
      return;
    }
    showWebToast(
      context,
      result.message ?? '이미 신청했거나 잠시 후 다시 시도해 주세요.',
      alignment: widget.isSheet ? Alignment.bottomCenter : Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final crew = widget.crew;
    final logoUrl = crewLogoUrlOf(logoUrl: crew.crewLogoUrl, color: crew.color);
    final memberCount = _detail?.crewMemberTotal;
    // ⚠️ 상세(_detail)를 **먼저** 보면 리조트 줄이 `휘닉스` → `휘닉스파크`로 한 박자
    // 늦게 바뀐다. 목록 응답에 이미 `base_resort_id`가 있으므로 그 자리에서 정식
    // 이름을 만들어 쓰고, 못 찾을 때만 상세 값으로 떨어진다.
    final resort = crewResortFullnameOf(crew.baseResortId).isNotEmpty
        ? crewResortFullnameOf(crew.baseResortId)
        : (_detail?.baseResortFullname ?? '');
    final desc = crew.description?.trim() ?? _detail?.description?.trim() ?? '';

    // 크루 미리보기 팝업은 **공용 카드**로 그린다 — 라이브크루 홈·랭킹의 크루 팝업과
    // 같은 위젯(`showLiveCrewModal`)이라 여기만 따로 그리면 규격이 갈라진다.
    // 다른 점은 하단 버튼이 둘이라는 것뿐.
    final card = WebProfileCard(
      isSheet: widget.isSheet,
      // 시트는 닫기 X 대신 드래그 핸들을 쓴다.
      onClose: widget.isSheet ? null : widget.onClose,
      data: WebProfileCardData(
        avatarUrl: logoUrl,
        // 크루 로고는 72에 라운드 12인 사각(목업 106:19153).
        avatarSize: 72,
        avatarRadius: 12,
        displayName: crew.crewName,
        // 줄이 많아(이름·리조트·멤버수·소개) 간격을 한 단계 좁힌다.
        compactLines: true,
        resortName: resort.isEmpty ? null : resort,
        extraLine: memberCount == null ? null : '$memberCount명',
        // 멤버 수는 상세 API에서 늦게 온다 → 그 줄 자리를 미리 비워 둬야
        // 값이 도착할 때 팝업이 커지지 않는다.
        isExtraLineLoading: _detail == null,
        stateMsg: desc.isEmpty ? null : desc.replaceAll('\n', ' '),
      ),
      footer: Row(
        children: [
          Expanded(
            child: WebProfileFooterButton(
              label: '크루 구경하기',
              onTap: () {
                // 팝업을 먼저 닫아야 크루홈 위에 딤이 남지 않는다.
                widget.onClose();
                Get.toNamed('${WebRoutes.crewHome}?id=${crew.crewId}');
              },
            ),
          ),
          const SizedBox(width: SDSSpacing.sm),
          Expanded(
            child: WebProfileFooterButton(
              label: '크루 가입하기',
              background: SDSColor.snowliveBlue,
              foreground: SDSColor.snowliveWhite,
              onTap: _isApplying ? null : _apply,
            ),
          ),
        ],
      ),
    );

    // 짧은 뷰포트에서 넘치면 스크롤되게 한다.
    return SingleChildScrollView(child: card);
  }
}
