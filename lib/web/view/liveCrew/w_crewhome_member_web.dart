import 'package:com.snowlive/web/util/web_profile_nav_web.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewMemberList.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crew_setting_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/crew/vm_crewSetting_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
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

/// 멤버 목록 묶음. 지금은 **자리만 잡고 아무것도 하지 않는다**(자식을 그대로 넘긴다).
///
/// 예전에는 행 패딩(8)만큼 좌우로 **빼내서** 프로필 이미지가 콘텐츠 좌측선에 서게
/// 했는데, 그러면 행 박스(hover 면)가 콘텐츠 폭을 좌우로 8씩 넘어갔다 —
/// **목록이 콘텐츠 너비를 벗어나 보인다**는 지적을 받았다(사용자 확정으로 제거).
///
/// 기준은 랭킹 홈이다. 거기도 행이 `horizontal: 8` 패딩을 갖지만 목록을 빼내지
/// 않아서, 행 박스가 콘텐츠 폭에 딱 맞고 순위·프로필은 8 안쪽에서 시작한다.
/// 이제 크루 멤버 목록도 같다.
///
/// 호출부를 건드리지 않고 남겨 둔다 — 세 화면(크루홈 TOP 10 · 시즌 랭킹 ·
/// 멤버 전체)이 쓰는 자리라, 다시 빼낼 일이 생기면 여기 한 곳만 고치면 된다.
class CrewMemberListInset extends StatelessWidget {
  /// 가장 긴 열의 행 수. 지금은 쓰지 않지만(높이를 못 박을 필요가 없어졌다)
  /// 호출부 API를 유지하려고 남겨 둔다.
  final int rowCount;
  final Widget child;

  const CrewMemberListInset({super.key, required this.rowCount, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

/// 멤버 목록 스켈레톤 — **실제 목록과 같은 열 수·행 피치·좌우 빼내기**를 쓴다.
/// 랭킹 목록 스켈레톤(`RankingListSkeleton`)은 순위 숫자 열이 있어 여기엔 맞지 않는다.
class CrewMemberListSkeleton extends StatelessWidget {
  /// 전체 행 수(열로 나눠 담는다).
  final int count;

  /// 순위 칸([CrewMemberRankedRowWeb])이 있는 목록이면 그 자리도 잡는다(크루홈 TOP 10).
  final bool showRank;

  /// 순위 칸 폭 — 실제 목록과 **같은 값**을 넘겨야 로딩이 끝날 때 순위 열이 안 튄다.
  final double? rankWidth;

  /// 열 사이 간격 — 크루홈 48 / 멤버 화면은 폭별 값.
  final double columnGap;

  const CrewMemberListSkeleton({
    super.key,
    required this.count,
    required this.columnGap,
    this.rankWidth,
    this.showRank = false,
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
                      // 순위 자리도 **행 프레임 안쪽**에 둔다(실제 행과 같은 구조).
                      _CrewMemberRowSkeleton(
                        leading: showRank
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: rankWidth ?? kCrewMemberRankWidth,
                                    child: const SkeletonBox(width: 12, height: 14),
                                  ),
                                  SizedBox(
                                      width: RankingRowMetrics.of(context).rankGap),
                                ],
                              )
                            : null,
                      ),
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
  /// 아바타 앞 자리(순위 숫자). 실제 행의 `leading`과 같은 위치다.
  final Widget? leading;

  const _CrewMemberRowSkeleton({this.leading});

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
          if (leading != null) leading!,
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

/// 순위 칸 폭(크루원 시즌 랭킹 · 크루홈 TOP 10 공용).
/// 순위 칸 기본 폭 — 세 자리(`226`)까지 들어간다. **목록이 보여주는 최대 순위에
/// 맞춰 줄이는 게 좋다**(크루홈 TOP 10은 두 자리면 충분하다) → 호출부에서
/// `rankWidth`로 넘긴다. 못 넘길 때의 안전한 기본값으로만 쓴다.
const double kCrewMemberRankWidth = 28;

/// 순위 칸 폭을 **가장 큰 순위에 맞춰** 잰다. 랭킹 홈 `rankColumnWidth`와 같은 방식
/// (Bold 14 · 최소 16)이라 목록 사이에서 순위 열 폭이 어긋나지 않는다.
double crewMemberRankWidth(BuildContext context, int maxRank) {
  final painter = TextPainter(
    text: TextSpan(
      text: '$maxRank',
      style: SDSTextStyle.bold.copyWith(fontSize: 14),
    ),
    // intl이 같은 이름의 TextDirection을 내보내 충돌하므로 컨텍스트에서 가져온다.
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  // 한 자리만 있는 목록에서도 숫자가 답답해 보이지 않게 최소폭을 둔다(랭킹 홈과 동일).
  return painter.width < 16 ? 16 : painter.width;
}

/// 순위 숫자 + 멤버 한 줄. 크루홈 `랭킹 TOP 10 멤버`와 `크루원 시즌 랭킹`이 같이 쓴다.
///
/// 서버 `overall_rank`는 **전체 랭킹** 순위라 크루 안 순위로는 맞지 않는다 →
/// 호출하는 쪽이 목록 순서로 [rank]를 매긴다(앱과 동일).
class CrewMemberRankedRowWeb extends StatelessWidget {
  final int rank;
  final CrewRanking member;
  final VoidCallback onTap;

  /// 순위 칸 폭. 목록이 보여주는 **가장 큰 순위**에 맞춰 넘긴다
  /// (`crewMemberRankWidth`). 안 넘기면 세 자리 기준 기본값.
  final double? rankWidth;

  const CrewMemberRankedRowWeb({
    super.key,
    required this.rank,
    required this.member,
    required this.onTap,
    this.rankWidth,
  });

  @override
  Widget build(BuildContext context) {
    final m = RankingRowMetrics.of(context);

    // ⚠️ hover 박스(=행 프레임)는 **순위까지 감싼다**(랭킹 홈과 같은 구조).
    // 순위를 프레임 밖에 두면 박스가 좌측 32 안쪽 · 우측 8 바깥으로 비대칭이 되어
    // 목록이 콘텐츠 폭을 넘어 보인다(사용자 지적). 프레임이 전체를 감싸면
    // 빼낸 8이 좌우 대칭이 되고, 순위와 티어가 콘텐츠 좌·우선에 정확히 선다.
    return CrewMemberRowWeb(
      member: member,
      onTap: onTap,
      // 순위 숫자 — 랭킹 홈과 같은 규격(Bold 14 · 좌측 정렬 · 순위 ↔ 프로필 간격은
      // `RankingRowMetrics.rankGap`). 폭은 세 자리(`226`)까지 들어가는 28 고정 —
      // 랭킹 홈은 페이지마다 TextPainter로 재지만, 크루 안 순위는 자리 수가
      // 거의 변하지 않아 고정값이 목록 사이에서 더 안정적이다.
      leading: Row(
        children: [
          SizedBox(
            width: rankWidth ?? kCrewMemberRankWidth,
            child: Text(
              '$rank',
              maxLines: 1,
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
            ),
          ),
          SizedBox(width: m.rankGap),
        ],
      ),
    );
  }
}

class CrewMemberRowWeb extends StatefulWidget {
  final CrewRanking member;
  final VoidCallback onTap;

  /// 아바타 **앞**에 들어가는 내용(크루홈·시즌 랭킹의 순위 숫자).
  /// 행 프레임(hover 박스·패딩) 안쪽에 들어가므로 좌우 정렬이 아바타와 함께 맞는다.
  final Widget? leading;

  const CrewMemberRowWeb({
    super.key,
    required this.member,
    required this.onTap,
    this.leading,
  });

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
              if (widget.leading != null) widget.leading!,
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
              const SizedBox(width: 8),
              // 점수가 있으면 티어 아이콘, 없으면(점수 없음) '-'.
              (member.tierIconUrl?.isNotEmpty ?? false)
                  ? MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            showWebTierImageViewer(context, url: member.tierIconUrl),
                        child: WebNetworkImage(
                          url: member.tierIconUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                          showPlaceholder: false,
                          smoothDownscale: true,
                        ),
                      ),
                    )
                  : const SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: Text('-',
                            style: TextStyle(fontSize: 16, color: SDSColor.gray400)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 멤버 **전체 목록**용 한 줄 — 아바타 + 이름 + 소속 스키장 + 역할 배지.
/// 랭킹이 아니라 전원 목록(앱 `/crew/{id}/members/`)이라 **점수·티어를 두지 않는다**
/// (앱 멤버 화면과 같은 의미). 규격(행 높이·아바타·이름 크기)은 랭킹 행과 공유한다.
class CrewMemberProfileRowWeb extends StatefulWidget {
  final CrewMember member;
  final VoidCallback onTap;

  const CrewMemberProfileRowWeb({super.key, required this.member, required this.onTap});

  @override
  State<CrewMemberProfileRowWeb> createState() => _CrewMemberProfileRowWebState();
}

class _CrewMemberProfileRowWebState extends State<CrewMemberProfileRowWeb> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final info = widget.member.userInfo;
    final role = widget.member.status ?? kCrewRoleMember;
    final resort = info?.favoriteResortNickname?.trim() ?? '';
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
          height: m.boxHeight,
          padding: EdgeInsets.symmetric(
            horizontal: kCrewMemberRowInset,
            vertical: m.verticalPadding,
          ),
          child: Row(
            children: [
              WebAvatar(url: info?.profileImageUrlUser, size: m.avatar),
              SizedBox(width: m.nameGap),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 역할 배지는 닉네임 **바로 오른쪽**(사용자 확정). 닉네임이 길면
                    // 닉네임만 말줄임되고 배지는 항상 보인다. 크루원은 배지를 생략한다
                    // (목업: 크루장/운영진만 강조).
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            info?.displayName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SDSTextStyle.regular.copyWith(
                                fontSize: m.nameSize, height: 20 / 15, color: SDSColor.gray900),
                          ),
                        ),
                        if (role == kCrewRoleLeader || role == kCrewRoleManager) ...[
                          const SizedBox(width: 6),
                          CrewRoleBadge(role: role, compact: true),
                        ],
                      ],
                    ),
                    if (resort.isNotEmpty)
                      Text(
                        resort,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.regular.copyWith(
                            fontSize: m.subSize, height: 17 / 13, color: SDSColor.gray500),
                      ),
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
  return showCrewMemberProfileModalRaw(
    context,
    userId: member.userId,
    avatarUrl: member.profileImageUrlUser,
    displayName: member.displayName,
    stateMsg: member.stateMsg,
    crewName: crewName,
    resortName: resortName,
  );
}

/// 멤버 프로필 팝업(원시 필드판). 멤버 전체 목록은 랭킹(`CrewRanking`)이 아니라
/// 멤버 응답(`CrewMember`)을 쓰므로, 두 곳이 같은 카드를 띄울 수 있게 필드로 받는다.
Future<void> showCrewMemberProfileModalRaw(
  BuildContext context, {
  required int? userId,
  required String? avatarUrl,
  required String? displayName,
  required String? stateMsg,
  required String? crewName,
  required String? resortName,
}) {
  final isMobile = context.screenType == WebScreenType.mobile;
  return showWebOverlayModal<void>(
    context: context,
    alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
    padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(SDSSpacing.lg),
    builder: (_, close) => _CrewMemberProfileCard(
      userId: userId,
      avatarUrl: avatarUrl,
      displayName: displayName,
      stateMsg: stateMsg,
      crewName: crewName,
      resortName: resortName,
      isSheet: isMobile,
      onClose: close,
    ),
  );
}

class _CrewMemberProfileCard extends StatefulWidget {
  final int? userId;
  final String? avatarUrl;
  final String? displayName;
  final String? stateMsg;
  final String? crewName;
  final String? resortName;
  final bool isSheet;
  final void Function([void result]) onClose;

  const _CrewMemberProfileCard({
    required this.userId,
    required this.avatarUrl,
    required this.displayName,
    required this.stateMsg,
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
    final targetId = widget.userId;
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
    final targetId = widget.userId;
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
    if (friendVm.myUserId != null && friendVm.myUserId == widget.userId) return null;
    if (_requestSent) return const WebProfileStateBadge(label: '요청 보냄');
    if (_areWeFriend == true) {
      return const WebProfileStateBadge(label: '내 친구', isPositive: true);
    }
    return WebProfilePillButton(
      label: _isSending ? '요청 중…' : '친구 추가',
      // 관계를 모르는 동안(조회 중)에는 누를 수 없게 둔다.
      onTap: (_isSending || _areWeFriend == null) ? null : _sendRequest,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebProfileCard(
      data: WebProfileCardData(
        userId: widget.userId,
        avatarUrl: widget.avatarUrl,
        displayName: widget.displayName,
        resortName: widget.resortName,
        crewName: widget.crewName,
        stateMsg: widget.stateMsg,
      ),
      isSheet: widget.isSheet,
      onClose: widget.isSheet ? null : widget.onClose,
      action: _buildAction(),
      footer: WebProfileFooterButton(
        label: '프로필 보러가기',
        onTap: widget.userId == null
            ? null
            : () {
                widget.onClose();
                pushWebProfileRoute(widget.userId!);
              },
      ),
    );
  }
}
