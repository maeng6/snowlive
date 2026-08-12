import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_friendDetail.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_card_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 친구/유저 프로필 미리보기 팝업.
///
/// 목업: **데스크탑·태블릿은 화면 중앙 모달, 모바일은 드래그 핸들 바텀시트.**
/// 카드에 랭킹 정보는 넣지 않지만(요청) 소속·상태메시지·친구관계(`are_we_friend`)는
/// 친구 목록 응답에 없어서 열릴 때 상세 API로 따로 받는다.
///
/// [friendUserId]만 알면 열 수 있다(목록 행·검색 결과 모두 userId는 갖고 있다).
/// 이름/아바타는 목록에 이미 있으므로 [initialName]/[initialAvatarUrl]로 미리 넘겨
/// 로딩 중에도 누구인지 보이게 한다.
///
/// 팝업 안에서 친구 요청을 보냈으면 `true`로 닫힌다 → 호출자가 목록을 갱신할 수 있다.
Future<bool?> showFriendProfileModal(
  BuildContext context, {
  required int friendUserId,
  String? initialName,
  String? initialAvatarUrl,
}) {
  final isMobile = context.screenType == WebScreenType.mobile;
  return showWebOverlayModal<bool>(
    context: context,
    // 모바일은 하단에 붙는 시트라 좌우 여백이 없어야 한다.
    alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
    padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(SDSSpacing.lg),
    builder: (_, close) => _FriendProfileSheet(
      friendUserId: friendUserId,
      initialName: initialName,
      initialAvatarUrl: initialAvatarUrl,
      isSheet: isMobile,
      onClose: close,
    ),
  );
}

class _FriendProfileSheet extends StatefulWidget {
  final int friendUserId;
  final String? initialName;
  final String? initialAvatarUrl;
  final bool isSheet;
  final void Function([bool? result]) onClose;

  const _FriendProfileSheet({
    required this.friendUserId,
    required this.initialName,
    required this.initialAvatarUrl,
    required this.isSheet,
    required this.onClose,
  });

  @override
  State<_FriendProfileSheet> createState() => _FriendProfileSheetState();
}

class _FriendProfileSheetState extends State<_FriendProfileSheet> {
  final FriendViewModelWeb _vm = Get.find<FriendViewModelWeb>();

  FriendDetailModel? _detail;
  bool _isSending = false;

  /// 요청을 보냈으면 버튼을 되돌리지 않는다(연달아 누르면 서버가 중복으로 막는다).
  bool _requestSent = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail = await _vm.fetchProfile(widget.friendUserId);
    if (!mounted) return;
    setState(() => _detail = detail);
  }

  Future<void> _sendRequest() async {
    setState(() => _isSending = true);
    final ok = await _vm.sendRequest(widget.friendUserId);
    if (!mounted) return;
    setState(() {
      _isSending = false;
      _requestSent = ok;
    });
    // 요청은 "추가됨"이 아니라 상대 수락을 기다리는 상태다 → 문구를 구분한다.
    showWebToast(
      context,
      ok ? '친구 요청을 보냈습니다.' : '이미 친구이거나 요청 중이에요.',
      alignment: widget.isSheet ? Alignment.bottomCenter : Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _detail?.friendUserInfo;

    final data = WebProfileCardData(
      userId: widget.friendUserId,
      avatarUrl: info?.profileImageUrlUser ?? widget.initialAvatarUrl,
      displayName: info?.displayName ?? widget.initialName,
      // 친구 상세는 리조트를 `favorite_resort`로 준다(랭킹은 `resort_nickname`).
      resortName: info?.favoriteResort,
      crewName: info?.crewName,
      stateMsg: info?.stateMsg,
    );

    return WebProfileCard(
      data: data,
      isSheet: widget.isSheet,
      onClose: widget.isSheet ? null : () => widget.onClose(_requestSent),
      action: _buildAction(info),
      footer: WebProfileFooterButton(
        label: '프로필 보러가기',
        // 웹에는 아직 친구 상세 페이지가 없다(앱의 v_friendDetail은 방명록·라이딩 통계까지
        // 포함한 2600줄짜리 화면이라 별건이다).
        onTap: () => Get.snackbar('알림', '프로필 화면은 준비 중이에요.'),
      ),
    );
  }

  Widget _buildAction(FriendUserInfo? info) {
    if (_requestSent) {
      return const WebProfilePillButton(label: '요청 보냄');
    }
    // 상세를 받기 전에는 관계를 모르므로 버튼을 눌러도 되게 두되, 이미 친구면 표시만 한다.
    if (info?.areWeFriend ?? false) {
      return const WebProfilePillButton(label: '내 친구');
    }
    return WebProfilePillButton(
      label: _isSending ? '요청 중…' : '친구 추가',
      onTap: _isSending ? null : _sendRequest,
    );
  }
}
