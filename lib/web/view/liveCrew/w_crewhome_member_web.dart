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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('###,###,###,###');

/// 크루 멤버 한 줄. `랭킹 TOP 10 멤버`와 `멤버` 전체 화면이 같은 줄을 쓴다.
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
              WebAvatar(url: member.profileImageUrlUser, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      member.displayName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                    ),
                    if (stateMsg.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        stateMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SDSTextStyle.regular.copyWith(fontSize: 11, color: SDSColor.gray500),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: SDSSpacing.sm),
              Text(
                '${_numberFormat.format((member.totalScore ?? 0).round())}점',
                style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
              ),
              if (member.tierIconUrl?.isNotEmpty ?? false) ...[
                const SizedBox(width: 6),
                WebNetworkImage(
                  url: member.tierIconUrl,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
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
