import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_card_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 랭킹 목록의 유저 행을 클릭했을 때 뜨는 프로필 미리보기.
///
/// 카드 본문은 친구 화면과 **같은 [WebProfileCard]** 를 쓴다. 랭킹 응답에는 상태메시지가
/// 없어서(`RankingUser`에 `state_msg` 없음) 그 줄만 비고, 나머지(아바타·이름·소속)는
/// 목록 응답에 이미 들어 있어 추가 조회가 필요 없다.
///
/// 딤이 GNB/상단바까지 덮도록 다른 팝업들과 같이 showWebOverlayModal 위에 올린다.
Future<void> showRankingProfileModal(BuildContext context, RankingUser user) {
  return showWebOverlayModal<void>(
    context: context,
    builder: (_, close) => _RankingProfileCard(user: user, onClose: close),
  );
}

class _RankingProfileCard extends StatefulWidget {
  final RankingUser user;
  final VoidCallback onClose;

  const _RankingProfileCard({required this.user, required this.onClose});

  @override
  State<_RankingProfileCard> createState() => _RankingProfileCardState();
}

class _RankingProfileCardState extends State<_RankingProfileCard> {
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
    final targetId = widget.user.userId;
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
    final targetId = widget.user.userId;
    if (targetId == null) return;
    final friendVm = Get.find<FriendViewModelWeb>();
    if (!friendVm.isLoggedIn) {
      showWebToast(context, '로그인이 필요해요.',
          alignment: context.screenType == WebScreenType.mobile
              ? Alignment.bottomCenter
              : Alignment.topCenter);
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
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }

  /// 랭킹 응답에는 친구 관계가 없어서 상세 조회로 따로 확인한다(`_loadRelation`).
  Widget? _buildAction() {
    final friendVm = Get.find<FriendViewModelWeb>();
    // 랭킹에는 내 행도 있다 → 나를 열었으면 버튼을 그리지 않는다.
    if (friendVm.myUserId != null && friendVm.myUserId == widget.user.userId) return null;
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
    final user = widget.user;

    return WebProfileCard(
      data: WebProfileCardData(
        userId: user.userId,
        avatarUrl: user.profileImageUrlUser,
        displayName: user.displayName,
        // 랭킹은 리조트를 `resort_nickname`으로 준다(친구 상세는 `favorite_resort`).
        resortName: user.resortNickname,
        crewName: user.crewName,
      ),
      onClose: widget.onClose,
      action: _buildAction(),
      footer: WebProfileFooterButton(
        label: '프로필 보러가기',
        onTap: user.userId == null
            ? null
            : () {
                // 팝업을 먼저 닫아야 프로필 화면 위에 딤이 남지 않는다.
                widget.onClose();
                Get.toNamed('${WebRoutes.userProfile}?id=${user.userId}');
              },
      ),
    );
  }
}
