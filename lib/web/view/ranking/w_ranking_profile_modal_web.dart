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

  Future<void> _sendRequest() async {
    final targetId = widget.user.userId;
    if (targetId == null) return;

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
      // 랭킹 응답에는 친구 관계(`are_we_friend`)가 없어서 "이미 친구"인지 알 수 없다.
      // 눌러보게 두고 중복이면 서버가 막아주는 걸 문구로 알린다.
      action: _requestSent
          ? const WebProfilePillButton(label: '요청 보냄')
          : WebProfilePillButton(
              label: _isSending ? '요청 중…' : '친구 추가',
              onTap: _isSending ? null : _sendRequest,
            ),
      footer: WebProfileFooterButton(
        label: '프로필 보러가기',
        // 웹에는 아직 친구 상세 페이지가 없다(앱의 v_friendDetail은 방명록·라이딩 통계까지
        // 포함한 2600줄짜리 화면이라 별건이다).
        onTap: () => Get.snackbar('알림', '프로필 화면은 준비 중이에요.'),
      ),
    );
  }
}
