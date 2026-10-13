import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_friend.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_bestFriendListModel.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_profile_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 상단 친구 아이콘 → 앱의 '라이브중인 친구' 바텀시트와 동일한 팝업.
/// 친구 그리드(아바타 + 라이브 뱃지) + 위치정보(마지막 슬로프 · N분 전) + 친구 관리 바로가기.
Future<void> showFriendLivePopupWeb(BuildContext context) {
  return showWebOverlayModal<void>(
    context: context,
    alignment: Alignment.center,
    builder: (_, close) => _FriendLivePopup(close: close),
  );
}

class _FriendLivePopup extends StatefulWidget {
  final void Function([void result]) close;
  const _FriendLivePopup({required this.close});

  @override
  State<_FriendLivePopup> createState() => _FriendLivePopupState();
}

class _FriendLivePopupState extends State<_FriendLivePopup> {
  final FriendAPI _api = FriendAPI();
  bool _loading = true;
  List<FriendListModel> _friends = [];

  int? get _uid {
    if (!Get.isRegistered<UserViewModel>()) return null;
    final id = Get.find<UserViewModel>().user?.user_id;
    return (id is int) ? id : int.tryParse('$id');
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final ApiResponse res = await _api.fetchFriendList(userId: uid, bestFriend: false);
    if (!mounted) return;
    if (res.success && res.data is List) {
      _friends = FriendListResponse.fromJson(res.data as List).friends ?? [];
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text('라이브중인 친구',
                      style: SDSTextStyle.bold
                          .copyWith(fontSize: 16, color: SDSColor.gray900)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => widget.close(),
                    child: Icon(Icons.close, size: 20, color: SDSColor.gray500),
                  ),
                ],
              ),
              const SizedBox(height: SDSSpacing.md),
              Flexible(child: _body()),
              const SizedBox(height: SDSSpacing.sm),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    widget.close();
                    // 비로그인이면 로그인 화면으로, 로그인 상태면 친구 관리로.
                    Get.toNamed(_uid == null ? WebRoutes.login : WebRoutes.friend);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SDSColor.gray100,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(_uid == null ? '로그인' : '친구 관리 바로가기',
                      style: SDSTextStyle.bold
                          .copyWith(fontSize: 15, color: SDSColor.gray700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
      );
    }
    if (_uid == null) {
      return _centered('로그인하고 친구를 추가해보세요.');
    }
    if (_friends.isEmpty) {
      return _centered('친구를 등록해보세요.\n라이브중인 친구를 바로 확인할 수 있어요.');
    }
    return SingleChildScrollView(
      child: Wrap(
        spacing: 8,
        runSpacing: 16,
        children: _friends.map(_tile).toList(),
      ),
    );
  }

  Widget _centered(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Text(msg,
            textAlign: TextAlign.center,
            style: SDSTextStyle.regular
                .copyWith(fontSize: 14, color: SDSColor.gray500, height: 1.4)),
      );

  Widget _tile(FriendListModel f) {
    final info = f.friendInfo;
    final live = info.withinBoundary == true && info.revealWb == true;
    final slope = info.lastPassSlope ?? f.lastPassSlope;
    final passTime = info.lastPassTime ?? f.lastPassTime;
    final ago = (passTime != null && passTime.isNotEmpty)
        ? GetDatetime().getAgoString(passTime)
        : '';
    final sub = [
      if (slope != null && slope.isNotEmpty) slope,
      if (ago.isNotEmpty) ago,
    ].join(' · ');

    return SizedBox(
      width: 76,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          // 라이브 팝업은 닫지 않고, 프로필 다이얼로그를 그 위에 스택으로 띄운다.
          // (프로필 X를 눌러도 라이브중인 친구 팝업은 그대로 남는다.)
          await showFriendProfileModal(
            context,
            friendUserId: info.userId,
            initialName: info.displayName,
            initialAvatarUrl: info.profileImageUrlUser,
            initialAreWeFriend: true,
          );
        },
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                WebAvatar(
                  url: info.profileImageUrlUser,
                  size: 64,
                  borderColor: live ? SDSColor.snowliveBlue : null,
                  borderWidth: live ? 2 : 0,
                ),
                if (live)
                  Positioned(
                    bottom: -2,
                    child: Image.asset('assets/imgs/icons/icon_badge_live.png',
                        width: 34),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(info.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: SDSTextStyle.regular
                    .copyWith(fontSize: 12, color: SDSColor.gray900)),
            if (sub.isNotEmpty)
              Text(sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.regular
                      .copyWith(fontSize: 11, color: SDSColor.gray500)),
          ],
        ),
      ),
    );
  }
}
