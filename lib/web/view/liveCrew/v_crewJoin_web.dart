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
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
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
    final isDesktop = context.isDesktop;

    return Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        SDSSpacing.xl,
      ),
      // 조건에 맞는 크루를 **전부** 그린다(전체 521개, 휘닉스 169개 — 실측).
      // Column에 다 쌓으면 한 프레임에 수백 개를 만들게 되므로 지연 렌더한다.
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kCrewJoinContentMaxWidth),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _title,
                      style: SDSTextStyle.extraBold.copyWith(fontSize: 28, color: SDSColor.gray900),
                    ),
                    const SizedBox(height: SDSSpacing.lg),
                    WebSearchField(
                      controller: _searchController,
                      hint: '크루 검색',
                      borderRadius: 8,
                      // 스키장별로 들어왔으면 그 스키장 안에서 검색한다.
                      onSubmitted: (keyword) => _vm.search(keyword, _resortId),
                    ),
                    const SizedBox(height: SDSSpacing.md),
                  ],
                ),
              ),
              Obx(_buildListSliver),
            ],
          ),
        ),
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

class _CrewJoinSkeleton extends StatelessWidget {
  const _CrewJoinSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          for (var i = 0; i < 6; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            const SkeletonBox(height: 44, radius: 8),
          ],
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
    final accent = crewColorOf(crew.color) ?? SDSColor.gray200;
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
          padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.sm, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent, width: 2),
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
                      style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray900),
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
    final accent = crewColorOf(crew.color) ?? SDSColor.gray200;
    final memberCount = _detail?.crewMemberTotal;
    final resort = _detail?.baseResortFullname ?? crewResortNicknameOf(crew.baseResortId);
    final desc = crew.description?.trim() ?? _detail?.description?.trim() ?? '';
    final subtitle = [if (desc.isNotEmpty) desc.replaceAll('\n', ' '), if (resort.isNotEmpty) resort]
        .join(' · ');

    final card = Material(
      color: SDSColor.snowliveWhite,
      borderRadius: widget.isSheet
          ? const BorderRadius.vertical(top: Radius.circular(20))
          : BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: widget.isSheet ? double.infinity : 390,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(SDSSpacing.lg, SDSSpacing.md, SDSSpacing.lg, SDSSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isSheet)
                // 목업 모바일은 닫기 X 대신 드래그 핸들이다.
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: SDSSpacing.md),
                  decoration: BoxDecoration(
                    color: SDSColor.gray200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              else
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: widget.onClose,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 20, color: SDSColor.gray400),
                    ),
                  ),
                ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: (logoUrl?.isNotEmpty ?? false)
                    ? WebNetworkImage(url: logoUrl, width: 76, height: 76)
                    : Container(color: SDSColor.gray100),
              ),
              const SizedBox(height: SDSSpacing.md),
              Text(
                crew.crewName ?? '',
                textAlign: TextAlign.center,
                style: SDSTextStyle.bold.copyWith(fontSize: 18, color: SDSColor.gray900),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                ),
              ],
              if (memberCount != null) ...[
                const SizedBox(height: SDSSpacing.sm),
                Text(
                  '$memberCount명',
                  style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                ),
              ],
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
                ),
              ],
              const SizedBox(height: SDSSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onClose();
                        Get.toNamed('${WebRoutes.crewHome}?id=${crew.crewId}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SDSColor.gray50,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        '크루 구경하기',
                        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray700),
                      ),
                    ),
                  ),
                  const SizedBox(width: SDSSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isApplying ? null : _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SDSColor.snowliveBlue,
                        disabledBackgroundColor: SDSColor.gray300,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        '크루 가입하기',
                        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.snowliveWhite),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // 짧은 뷰포트에서 넘치면 스크롤되게 한다.
    return SingleChildScrollView(child: card);
  }
}
