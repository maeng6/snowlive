import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_card_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('###,###,###,###');

/// 크루 멤버 한 줄. `랭킹 TOP 10 멤버`와 `멤버` 전체 화면이 같은 줄을 쓴다.
/// 멤버 목록의 **행 피치**(행 시작점 사이 거리).
/// 목업은 56인데 실제로 보면 행 사이가 떠 보여 **50**으로 좁혔다(사용자 확정) —
/// PC·태블릿은 행 박스(50)에 딱 맞아 간격이 0이 되고, 모바일만 8이 붙는다.
const double kCrewMemberRowPitch = 50;

/// 행 사이에 넣을 간격. 행 박스 높이는 랭킹 목록과 같은 규격(PC·태블릿 50 /
/// 모바일 42)이라, 피치 56에서 모자란 만큼만 빈 칸으로 채운다.
double crewMemberRowGap(BuildContext context) =>
    (kCrewMemberRowPitch - RankingRowMetrics.of(context).boxHeight)
        .clamp(0.0, kCrewMemberRowPitch);

/// 행이 hover 박스용으로 갖는 좌우 패딩(랭킹 목록과 같은 8).
const double kCrewMemberRowInset = SDSSpacing.sm;

/// 멤버 목록을 **행 패딩만큼 좌우로 빼내** 프로필 이미지가 페이지 여백선에
/// 정확히 서게 한다. hover 박스는 그만큼 여백 쪽으로 넘어간다(목업 정렬 기준).
///
/// ⚠️ [rowCount](가장 긴 열의 행 수)로 높이를 직접 계산해 못 박는다 — `OverflowBox`는
/// 부모 제약만큼 커지는데, 스크롤 안에서는 세로가 무한이라 높이를 주지 않으면
/// 레이아웃이 통째로 무너진다(행이 전부 겹쳐 보인다).
class CrewMemberListInset extends StatelessWidget {
  final int rowCount;
  final Widget child;

  const CrewMemberListInset({super.key, required this.rowCount, required this.child});

  @override
  Widget build(BuildContext context) {
    if (rowCount <= 0) return child;
    final double rows = rowCount.toDouble();
    final double height = rows * RankingRowMetrics.of(context).boxHeight +
        (rows - 1) * crewMemberRowGap(context);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) => OverflowBox(
          alignment: Alignment.center,
          minWidth: 0,
          maxWidth: constraints.maxWidth + kCrewMemberRowInset * 2,
          child: child,
        ),
      ),
    );
  }
}

/// 멤버 목록 스켈레톤 — **실제 목록과 같은 열 수·행 피치·좌우 빼내기**를 쓴다.
/// 랭킹 목록 스켈레톤(`RankingListSkeleton`)은 순위 숫자 열이 있어 여기엔 맞지 않는다.
class CrewMemberListSkeleton extends StatelessWidget {
  /// 전체 행 수(열로 나눠 담는다).
  final int count;

  /// 열 사이 간격 — 크루홈 48 / 멤버 화면은 폭별 값.
  final double columnGap;

  const CrewMemberListSkeleton({
    super.key,
    required this.count,
    required this.columnGap,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context.screenType == WebScreenType.mobile ? 1 : 2;
    final perColumn = (count / columns).ceil();
    final gap = crewMemberRowGap(context);

    return SkeletonShimmer(
      child: CrewMemberListInset(
        rowCount: perColumn,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) SizedBox(width: columnGap),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < perColumn; i++) ...[
                      if (i > 0) SizedBox(height: gap),
                      const _CrewMemberRowSkeleton(),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CrewMemberRowSkeleton extends StatelessWidget {
  const _CrewMemberRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final m = RankingRowMetrics.of(context);
    return Container(
      height: m.boxHeight,
      padding: EdgeInsets.symmetric(
        horizontal: kCrewMemberRowInset,
        vertical: m.verticalPadding,
      ),
      child: Row(
        children: [
          SkeletonBox(width: m.avatar, height: m.avatar, isCircle: true),
          SizedBox(width: m.nameGap),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: 110, height: 14),
                SizedBox(height: 4),
                SkeletonBox(width: 80, height: 12),
              ],
            ),
          ),
          const SizedBox(width: SDSSpacing.sm),
          const SkeletonBox(width: 56, height: 16),
          const SizedBox(width: 8),
          const SkeletonBox(width: 36, height: 36, radius: 8),
        ],
      ),
    );
  }
}

class CrewMemberRowWeb extends StatefulWidget {
  final CrewRanking member;
  final VoidCallback onTap;

  const CrewMemberRowWeb({super.key, required this.member, required this.onTap});

  @override
  State<CrewMemberRowWeb> createState() => _CrewMemberRowWebState();
}

class _CrewMemberRowWebState extends State<CrewMemberRowWeb> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final stateMsg = member.stateMsg?.trim() ?? '';

    // 랭킹 목록 행과 **같은 규격**을 쓴다(공용 RankingRowMetrics) — 아바타·이름·
    // 소속·점수 크기와 행 높이가 화면마다 달라지면 바로 눈에 띈다.
    final m = RankingRowMetrics.of(context);

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
          // 높이를 공용 규격으로 못 박는다 — 두 줄의 line height가 행 높이를
          // 정하게 두면 스켈레톤·다른 목록과 어긋난다(랭킹 행과 같은 처리).
          height: m.boxHeight,
          padding: EdgeInsets.symmetric(
            horizontal: kCrewMemberRowInset,
            vertical: m.verticalPadding,
          ),
          child: Row(
            children: [
              WebAvatar(url: member.profileImageUrlUser, size: m.avatar),
              SizedBox(width: m.nameGap),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ⚠️ 줄 사이에 여백을 주지 않는다 — line height(20 + 17)만으로
                    // 행 내용 높이에 딱 맞는다(랭킹 행과 같은 계산).
                    Text(
                      member.displayName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular.copyWith(
                          fontSize: m.nameSize, height: 20 / 15, color: SDSColor.gray900),
                    ),
                    if (stateMsg.isNotEmpty)
                      Text(
                        stateMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.regular.copyWith(
                            fontSize: m.subSize, height: 17 / 13, color: SDSColor.gray500),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: SDSSpacing.sm),
              // 점수·티어도 랭킹 행과 동일(점수 regular, 티어 36).
              Text(
                '${_numberFormat.format((member.totalScore ?? 0).round())}점',
                style: SDSTextStyle.regular
                    .copyWith(fontSize: m.scoreSize, color: SDSColor.gray900),
              ),
              if (member.tierIconUrl?.isNotEmpty ?? false) ...[
                const SizedBox(width: 8),
                WebNetworkImage(
                  url: member.tierIconUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                  showPlaceholder: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 멤버를 탭했을 때 뜨는 프로필 팝업.
///
/// 친구 화면·랭킹과 **같은 [WebProfileCard]** 를 쓴다. 멤버 랭킹 응답에는 소속이 없어서
/// 지금 보고 있는 크루의 리조트·크루명을 그대로 넣는다(목업의 `휘닉스파크 · ALLDOMAN`).
Future<void> showCrewMemberProfileModal(
  BuildContext context, {
  required CrewRanking member,
  required String? crewName,
  required String? resortName,
}) {
  final isMobile = context.screenType == WebScreenType.mobile;
  return showWebOverlayModal<void>(
    context: context,
    alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
    padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(SDSSpacing.lg),
    builder: (_, close) => _CrewMemberProfileCard(
      member: member,
      crewName: crewName,
      resortName: resortName,
      isSheet: isMobile,
      onClose: close,
    ),
  );
}

class _CrewMemberProfileCard extends StatefulWidget {
  final CrewRanking member;
  final String? crewName;
  final String? resortName;
  final bool isSheet;
  final void Function([void result]) onClose;

  const _CrewMemberProfileCard({
    required this.member,
    required this.crewName,
    required this.resortName,
    required this.isSheet,
    required this.onClose,
  });

  @override
  State<_CrewMemberProfileCard> createState() => _CrewMemberProfileCardState();
}

class _CrewMemberProfileCardState extends State<_CrewMemberProfileCard> {
  bool _isSending = false;
  bool _requestSent = false;

  /// 이 사람과 이미 친구인지. null이면 아직 모른다(상세 조회 중) → 그동안 `친구 추가`를
  /// 누를 수 없게 해서 **이미 친구인 사람에게 요청이 가는 일**을 막는다.
  bool? _areWeFriend;

  @override
  void initState() {
    super.initState();
    _loadRelation();
  }

  Future<void> _loadRelation() async {
    final targetId = widget.member.userId;
    if (targetId == null) {
      if (mounted) setState(() => _areWeFriend = false);
      return;
    }
    // 이 응답에만 친구 관계(`are_we_friend`)가 들어 있다(목록·랭킹 응답에는 없다).
    final detail = await Get.find<FriendViewModelWeb>().fetchProfile(targetId);
    if (!mounted) return;
    setState(() => _areWeFriend = detail?.friendUserInfo.areWeFriend ?? false);
  }

  Future<void> _sendRequest() async {
    final targetId = widget.member.userId;
    if (targetId == null) return;
    final friendVm = Get.find<FriendViewModelWeb>();
    if (!friendVm.isLoggedIn) {
      showWebToast(context, '로그인이 필요해요.',
          alignment: widget.isSheet ? Alignment.bottomCenter : Alignment.topCenter);
      return;
    }
    setState(() => _isSending = true);
    final ok = await Get.find<FriendViewModelWeb>().sendRequest(targetId);
    if (!mounted) return;
    setState(() {
      _isSending = false;
      _requestSent = ok;
    });
    showWebToast(
      context,
      ok ? '친구 요청을 보냈습니다.' : '이미 친구이거나 요청 중이에요.',
      alignment: widget.isSheet ? Alignment.bottomCenter : Alignment.topCenter,
    );
  }

  /// 멤버 랭킹 응답에는 친구 관계가 없어서 상세 조회로 따로 확인한다(`_loadRelation`).
  Widget? _buildAction() {
    final friendVm = Get.find<FriendViewModelWeb>();
    // 크루원 목록에는 내 행도 있다 → 나를 열었으면 버튼을 그리지 않는다.
    if (friendVm.myUserId != null && friendVm.myUserId == widget.member.userId) return null;
    if (_requestSent) return const WebProfileStateBadge(label: '요청 보냄');
    if (_areWeFriend == true) {
      return const WebProfileStateBadge(label: '친구', isPositive: true);
    }
    return WebProfilePillButton(
      label: _isSending ? '요청 중…' : '친구 추가',
      // 관계를 모르는 동안(조회 중)에는 누를 수 없게 둔다.
      onTap: (_isSending || _areWeFriend == null) ? null : _sendRequest,
    );
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;

    return WebProfileCard(
      data: WebProfileCardData(
        userId: member.userId,
        avatarUrl: member.profileImageUrlUser,
        displayName: member.displayName,
        resortName: widget.resortName,
        crewName: widget.crewName,
        stateMsg: member.stateMsg,
      ),
      isSheet: widget.isSheet,
      onClose: widget.isSheet ? null : widget.onClose,
      action: _buildAction(),
      footer: WebProfileFooterButton(
        label: '프로필 보러가기',
        onTap: member.userId == null
            ? null
            : () {
                widget.onClose();
                Get.toNamed('${WebRoutes.userProfile}?id=${member.userId}');
              },
      ),
    );
  }
}
